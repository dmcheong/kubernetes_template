

Check_last="${Check_last:-0}"
actual_shell="$(ps -p $(ps -p $$ -o ppid=) -o comm=)"

# Commands auto tune 
echo -n "curent used shell : "
case "${actual_shell}" in
    bash)
        echo "bash : OK"
        ;;
    zsh)
        echo "zsh  : OK"
        ;;
    ksh)
        echo "ksh : too old exiting"
				exit 1
        ;;
	   sh) echo "sh : Not compatible une bash"
		     exit 1
			  ;;
     *)
        echo "unknown : exiting"
				exit 1
        ;;
esac

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color



function check_dependencies() 
{
	#|# Description :
	#|# Validate that all required system binaries used by the library are available.
	#|# This function checks the presence of each dependency in the system PATH.
	#|# If one or more dependencies are missing, an error is raised.
	#|#
	#|# Parameters :
	#|# None
	#|#
	#|# Behavior :
	#|# - Builds stack trace context (Function_PATH)
	#|# - Logs execution context in debug mode
	#|# - Iterates over required binaries list
	#|# - Detects missing commands using `command -v`
	#|# - If missing dependencies are found:
	#|#     → emits error message (EdEMessage)
	#|#     → returns 1
	#|# - If all dependencies are present:
	#|#     → emits success message (EdSMessage)
	#|#     → returns 0
	#|#
	#|# Dependencies :
	#|# - set_message() for logging
	#|#
	#|# Usage :
	#|# check_dependencies
	#|#
	#|# Return :
	#|# - 0 → all dependencies available
	#|# - 1 → missing dependencies detected
	############ STACK_TRACE_BUILDER #####################
	local Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	set_message "debug" "0" "current function path : [ ${Function_PATH} ]"

	local _deps=("ps" "tput" "date" "dirname" "expr" "printf" "tr" "mkdir" "openssl")
	local _missing=()
	local _dep=""

	set_message "check" "1" "Checking system dependencies"

	for _dep in "${_deps[@]}"
	do
		if ! command -v "${_dep}" >/dev/null 2>&1
		then
			_missing+=("${_dep}")
		fi
	done

	if [[ ${#_missing[@]} -gt 0 ]]
	then		
		set_message "EdEMessage" "1" "Missing dependencies: ${_missing[*]}"
	else 
		set_message "EdSMessage" "1" "All dependencies are available"
	fi

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$(dirname "${Function_PATH}")"
	####################################################
}

function print_header() 
{
	#|# Description :
	#|# This function prints a formatted header block in the terminal.
	#|# It displays a title (passed as parameter) surrounded by separator lines,
	#|# using color formatting variables.
	#|# Parameters :
	#|# ${1} : Title to display inside the header

	#|# Dependencies :
	#|# - Requires color variables to be defined beforehand:
	#|#   BLUE : color code for header text
	#|#   NC   : reset color (No Color)

	#|# Behavior :
	#|# - Adds an empty line before and after the header for readability
	#|# - Prints a top separator line
	#|# - Prints the provided title centered with padding
	#|# - Prints a bottom separator line

	#|# Output :
	#|# Example rendering:
	#|#   ═══════════════════════════════════════════════════════════════
	#|#     My Title
	#|#   ═══════════════════════════════════════════════════════════════

	echo ""
	echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
	echo -e "${BLUE}  ${1}${NC}"
	echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
	echo ""
}

function error_CTRL() 
{
	#|# Description :
	#|# Centralized error handling and post-action execution controller.
	#|# This function evaluates the result of a previous command and routes the
	#|# outcome to the message handler with appropriate severity (success, warning,
	#|# or error). It also supports optional execution hooks for success and failure
	#|# scenarios, enabling controlled workflow chaining.
	#|#
	#|# Parameters :
	#|# ${1} : _result
	#|#        Return code to evaluate (typically $? from previous command) (Mandatory)
	#|#
	#|# ${2} : _result_msg
	#|#        Message to display depending on the result (Optional but recommended)
	#|#
	#|# ${3} : _force_level
	#|#        Error level to enforce in case of failure (default: 1)
	#|#        Used as exit code when triggering an error message (Optional)
	#|#
	#|# ${4} : _internal_call
	#|#        Internal call flag:
	#|#        1 → emits a preliminary "check" message before evaluation
	#|#        0/empty → no preliminary message (Optional)
	#|#
	#|# ${5} : _internal_call_base_message
	#|#        Message displayed when _internal_call is enabled (Optional)
	#|#
	#|# ${6} : _on_fail_action
	#|#        Command or function to execute if result is not 0 (Optional)
	#|#        Executed only if defined (non-empty)
	#|#
	#|# ${7} : _on_sucess_action
	#|#        Command or function to execute if result is 0 (Optional)
	#|#        Executed only if defined (non-empty)
	#|#
	#|# Behavior :
	#|# - Builds and updates the stack trace context (Function_PATH)
	#|# - Logs current execution context in debug mode
	#|# - If _internal_call == 1:
	#|#     → emits a "check" message before evaluating result
	#|# - If _result == 0:
	#|#     → emits success message (EdSMessage)
	#|#     → executes _on_sucess_action if defined
	#|# - If _result != 0:
	#|#     → if _on_fail_action is defined:
	#|#         - emits error message with level 0 (non-blocking)
	#|#         - executes _on_fail_action
	#|#     → else:
	#|#         - emits error message with _force_level (may trigger exit)
	#|#
	#|# Dependencies :
	#|# - set_message() : centralized logging and exit control
	#|# - Bash context variables: FUNCNAME, dirname
	#|#
	#|# Usage :
	#|# error_CTRL "${?}" "Operation completed"
	#|# error_CTRL "${?}" "Directory created" "2" "1" "Creating directory"
	#|# error_CTRL "${?}" "Step failed" "1" "1" "Processing step" "cleanup_function" ""
	#|#
	#|# Output :
	#|# - Success → formatted success message + optional success action execution
	#|# - Failure → formatted error message + optional failure action execution
	#|#
	#|# Return :
	#|# - No explicit return value
	#|# - May terminate execution via set_message depending on _force_level
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	set_message "debug" "0" "current function path : [ ${_Function_PATH} ]  | Function Name [ ${_Function_Name} ]  "

	local _result="${1}"
	local _result_msg="${2}"
  local _force_level="${3:-1}"
	local _internal_call="${4}"
	local _internal_call_base_message="${5}"
	local _on_fail_action="${6}"
	local _on_sucess_action="${7}"

	if [[ ${_internal_call} -eq 1 ]]
    then 
			set_message "check" "0" "${_internal_call_base_message}"
  fi 


	if [[ "${_result}" = "0" ]]
		then		
			set_message "EdSMessage" "${_result}" "${_result_msg}"
			if [ ! -z ${_on_sucess_action} ]
			   then 
				 		${_on_sucess_action}
			fi
		else
		  if [ ! -z ${_on_fail_action} ]
			   then 
				    set_message "EdEMessage" "0" "${_result_msg}"
				 		${_on_fail_action}
				 else 
				   	set_message "EdEMessage" "${_force_level}" "${_result_msg}"
			fi	
	fi

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$(dirname ${Function_PATH})"
	####################################################
}

function Empty_Var_Control() 
{
	#|# Description :
	#|# Validates that a provided variable is defined and not empty.
	#|# Implements a guard mechanism to prevent execution with invalid inputs.
	#|# Supports internal/external call modes and a test mode to bypass hard failure.
	#|#
	#|# Parameters :
	#|# ${1} : _variable_to_check
	#|#        Value to validate (Mandatory)
	#|#
	#|# ${2} : _variable_name
	#|#        Logical name of the variable for logging (Mandatory)
	#|#
	#|# ${3} : _exit_code
	#|#        Exit code in case of failure (Optional, default: 1)
	#|#
	#|# ${4} : _internal_call
	#|#        Control display mode:
	#|#        1 → full message workflow (check + success/error)
	#|#        0/empty → minimal output (error only)
	#|#
	#|# ${5} : _test_mode
	#|#        Test mode flag:
	#|#        1 → disables blocking error behavior (no exit, low severity)
	#|#        0/empty → normal behavior
	#|#
	#|# Behavior :
	#|# - Builds and updates a stack trace path (Function_PATH)
	#|# - Logs current execution context (debug level)
	#|# - Adjusts error severity depending on test mode
	#|# - Validates variable content:
	#|#     → If empty or undefined:
	#|#         - Emits standardized error message (EdEMessage)
	#|#         - Exit instruction available but intentionally commented
	#|#     → If valid:
	#|#         - Emits success message (EdSMessage) when internal mode is enabled
	#|# - Output verbosity depends on internal/external call mode
	#|#
	#|# Dependencies :
	#|# - set_message(): centralized logging system
	#|# - Bash context variables: FUNCNAME, dirname
	#|#
	#|# Usage example :
	#|# Empty_Var_Control "${my_var}" "my_var" "2" "1" "0"
	#|#
	#|# Output :
	#|# - Success → validation confirmation (optional)
	#|# - Failure → standardized error message
	#|#
	#|# Return :
	#|# - Logical success (0) if variable is valid
	#|# - Intended exit with _exit_code on failure (currently disabled)
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	set_message "debug" "0" "current function path : [ ${_Function_PATH} ]  | Function Name [ ${_Function_Name} ]  "

	local _variable_to_check="${1}"
	local _variable_name="${2}"
	local _exit_code="${3:-1}"
	local _internal_call="${4}"
	local _test_mode="${5}"
  
	# configure errLevel for test pupose ( won t exit on error)
  if [[ ${_test_mode} -eq 1 ]]
	   	then 
				local _errLevel="0"
		  else 
			  local _errLevel="8"
	fi 
  
	# configure diplay of message if external or internal call defaul to internal
	if [[ ${_internal_call} -eq 1 ]]
	   then 
				set_message "check" "1" "Validating variable [ ${_variable_name} ] is not empty "
				if [[ -z "${_variable_to_check}" ]]
					then		
						set_message "EdEMessage" "${_errLevel}" "empty or undefined"
						# exit "${_exit_code}"
					else
						set_message "EdSMessage" "1" "empty value: ${_variable_name}"
				fi
			else 
				if [[ -z "${_variable_to_check}" ]]
					then		
						echo ""
						set_message "check" "1" "Validating variable [ ${_variable_name} ] is not empty "
						set_message "EdEMessage" "${_errLevel}" "empty or undefined"
						# exit "${_exit_code}"
				fi
	fi 

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$(dirname ${Function_PATH})"
	####################################################
}

function set_message() 
{
	#|# Description :
	#|# Centralized message handling and display function.
	#|# This function formats and outputs messages with timestamp, color coding,
	#|# and alignment. It standardizes all script outputs (debug, info, check,
	#|# success, warning, error) and manages error exit behavior.
	#|# Parameters :
	#|# ${1} : _message_type
	#|#        Type of message to display (Mandatory)
	#|#        Allowed values :
	#|#          - debug       : Debug messages (displayed only if DEBUG_MODE=1)
	#|#          - info        : Informational messages
	#|#          - check       : Inline check messages (used with alignment system)
	#|#          - EdSMessage  : Success message
	#|#          - EdWMessage  : Warning message
	#|#          - EdEMessage  : Error message (can trigger exit)
	#|#          - warn        : Simple warning (non-aligned)
	#|#
	#|# ${2} : _message_level
	#|#        Message level / severity (Mandatory)
	#|#        - Used for conditional behavior (e.g. exit on error)
	#|#        - If > 0 in EdEMessage → triggers exit with this code
	#|#
	#|# ${3} : _message_content
	#|#        Message content to display (Mandatory)
	#|# Behavior :
	#|# - Initializes terminal properties (Set_terminal_properties)
	#|# - Generates a timestamp for each message
	#|# - Applies color formatting based on message type
	#|# - Routes message to appropriate output format
	#|# - For "check" messages:
	#|#     → prints inline message (no newline)
	#|#     → calculates message length for alignment (set_length)
	#|# - For "EdSMessage" / "EdWMessage" / "EdEMessage":
	#|#     → aligns output using computed padding (add_string)
	#|# - For "debug":
	#|#     → displayed only if DEBUG_MODE=1
	#|# - For "EdEMessage":
	#|#     → exits script if _message_level != 0
	#|# Dependencies :
	#|# - Set_terminal_properties() : initializes terminal width
	#|# - get_length()              : computes string length
	#|# - set_length()              : computes alignment padding
	#|# - Global variables:
	#|#     DEBUG_MODE   : enables debug output
	#|#     add_string   : alignment padding string
	#|#     line_length  : length of current check message
	#|# Output :
	#|# - Formatted message printed to stdout
	#|# - May terminate script on error (EdEMessage with level > 0)
	#|# Notes :
	#|# - Uses ANSI escape codes for colors
	#|# - Uses echo -e for formatting (may vary across shells)
	#|# - "check" messages are designed to be followed by a status message
	#|#   (SUCCESS / ERROR) aligned on the same line

	Set_terminal_properties

	local _message_type="${1}"
	local _message_level="${2}"
	local _message_content="${3} "
	local _timestamp=$(date '+%Y-%m-%d %H:%M:%S')



  if [ ${Check_last} = "1" ] && [ "${_message_type}" = "check" ]
	  then 
		  echo -e "${NC}]"
			Check_last="0"
	fi

	case "${_message_type}" in
	"debug")
		if [[ "${DEBUG_MODE}" = "1" ]]
  		then		
				echo -e "[${BLUE}DEBUG${NC}]\t${_timestamp} - ${_message_content}"
		fi
		;;
	"info")
				echo -e "[${BLUE}INFO${NC}]\t${_timestamp} - ${_message_content}"
		;;
	"check")
		Check_last="1"
		#echo -en "\n"
		line_length=$(get_length "$(echo -e "[${BLUE}CHECK${NC}]\t${_timestamp} - ${_message_content}")")
		echo -en "[${BLUE}CHECK${NC}]\t${_timestamp} - ${_message_content}"
		set_length "$(echo -e "[${BLUE}CHECK${NC}]\t${_timestamp} - ${_message_content}")"
		;;
	"EdSMessage")
		set_length "\t[${GREEN}SUCCESS${NC}] - ${_message_content}"
   	echo -e "${add_string}\t[${GREEN}SUCCESS${NC}] - ${_message_content}"
		;;
	"EdWMessage")
		set_length "\t[${YELLOW}WARNING${NC}] - ${_message_content}"
    echo -e "${add_string}\t[${YELLOW}WARNING${NC}] - ${_message_content}"
		;;
	"EdEMessage")
    # echo "_message_content: ${_message_content} | _message_level: ${_message_level} | add_string: ${add_string}"
		set_length "\t[${RED}ERROR${NC}] - ${_message_content}"
		if [ ${_message_level} -eq 0 ]
      then	
        echo -e "${add_string}\t[${RED}ERROR${NC}] - ${_message_content}"
		  else
        echo -e "${add_string}\t[${RED}ERROR${NC}] - ${_message_content}"
        exit ${_message_level}
		fi
		;;
	"warn")
		echo -e "\t[${YELLOW}WARNING${NC}] - ${_message_content}"
		;;
	"console")
		echo -e "          ${_message_content}"
		;;
	*)
		echo -e "[${NC}UNKNOWN${NC}]\t${_timestamp} - ${_message_content}"
		;;
	esac
}

function Set_terminal_properties() 
{
	#|# Retrieve and compute terminal display properties
	#|# This function determines the current terminal width using `tput cols`
	#|# and calculates a derived column width (_col1_width) by subtracting
	#|# a fixed offset (40 characters). This can be used to format aligned output.
	# Get the width of the terminal
	_terminal_width="$(tput cols)"
	_col1_width="$(($_terminal_width - 40))"
}

function get_length() 
{
	#|# Return the length of a given string
	#|# This function takes a single argument (string input),
	#|# computes its length using Bash parameter expansion (${#var}),
	#|# and outputs the result to stdout.
	local str="${1}"
	echo "${#str}"
}

function set_length() 
{
	#|# Description :
	#|# This function calculates and generates a padding string used to align
	#|# terminal output messages. It ensures that status messages (e.g., SUCCESS,
	#|# ERROR) are visually aligned to the right based on terminal width.
	#|# Parameters :
	#|# ${1} : str
	#|#        Input string used as reference for alignment calculation (Mandatory)
	#|# Behavior :
	#|# - Computes the length of the provided string using get_length()
	#|# - Calculates the remaining space available using global column width (_col1_width)
	#|#   and previously computed line length (line_length)
	#|# - Builds a padding string (add_string) filled with '-' characters
	#|#   to match the required spacing
	#|# Dependencies :
	#|# - get_length() function
	#|# - Global variables:
	#|#     _col1_width : maximum width available for content alignment
	#|#     line_length : length of the current line content
	#|#     add_string  : output variable containing generated padding
	#|# Output :
	#|# - Sets global variable 'add_string' with computed padding
	#|# - No direct stdout output
	#|# Notes :
	#|# - The 'length' variable is computed but not used directly in current logic
	#|# - Relies on external initialization of _col1_width and line_length

	local str="${1}"
	local length=$(get_length "$str")
	length_add=$(expr ${_col1_width} - ${line_length} - 10 )
	add_string="$(printf "%-${length_add}s" "-")"
}

function Do_check_dir_null_or_slash() 
{
	#|# Var to set  :
	#|# Path_To_test : The path of the directory to test
	#|# ${1}         : First parameter, used to set Path_To_test
	#|# ${2}         : Second parameter, user to set if it colled in internal 
	#|#
	#|# Description : This function checks if the provided directory path is either empty
	#|# or just a root slash ('/'). If either condition is met, an error message is displayed.
	#|#
	#|# Basic Usage :
	#|#               Do_check_dir_null_or_slash "My_directory_path" ""
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	set_message "debug" "0" "current function path : [ ${Function_PATH} ]  | function Name [ ${Function_Name} ]  "

	local Path_To_test="${1}"
	local _internal_call="${2}"
	local _test_mode="${3}"
  
	# configure errLevel for test pupose ( won t exit on error)
  if [[ ${_test_mode} -eq 1 ]]
	   	then 
				local errLevel="0"
		  else 
			  local errLevel="4"
	fi 
  
	# configure diplay of message if external or internal call defaul to internal
	if [[ ${_internal_call} -eq 1 ]]
	   then 
				set_message "check" "0" "Checking directory: [ ${Path_To_test} ] "
	fi 

	# Check if the path is empty
	if [ -z "${Path_To_test}" ]
    then
		  set_message "EdEMessage" "${errLevel}" "Error ON PATH: [ Value is NULL ]"
	  else 
			if [ "${Path_To_test}" == "/" ]
				then
					set_message "EdEMessage" "${errLevel}" "Error ON PATH: [ Value is / ]"
				else 
				  if [[ ${_internal_call} -eq 1 ]]
	  			  then 
							set_message "EdSMessage" "0" ""
					fi 
			fi
	fi 
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$(dirname ${Function_PATH})"
	####################################################
}

function set_new_directory() 
{
	#|# Var to set  :
	#|# Base_param_Dir_To_Create    : The directory path to control and create if necessary
	#|# ${1}                        : First parameter, used to set Base_param_Dir_To_Create
	#|#
	#|# Description : This function checks if a directory exists, and if not, it creates it.
	#|# If the directory path is invalid or the directory cannot be created, appropriate
	#|# messages are displayed. It also prevents the function from being run more than once.
	#|#
	#|# Basic Usage :
	#|#               set_new_directory "My_Directory"
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	set_message "debug" "0" "current function path : [ ${Function_PATH} ]  | function Name [ ${Function_Name} ]  "

	local Base_param_Dir_To_Create="${1}"
	local level=${2:-1}

	Do_check_dir_null_or_slash "${Base_param_Dir_To_Create}" "" "" 
	set_message "check" "${level}" "Checking directory: [ ${Base_param_Dir_To_Create} ] "
	if [[ -z ${runned} ]]
  	then
			runned=0
	fi

	if [[ ${runned} -gt 1 ]]
    then		
    set_message "EdEMessage" "${level}" "NOT CREATED"
	else
		# Check if the directory exists
		if [ -d "${Base_param_Dir_To_Create}" ]
  		then	
				set_message "EdSMessage" "${level}" "Present"
				runned="0"
			else
				set_message "EdWMessage" "${level}" "Not Present, creating..."
				mkdir -p "${Base_param_Dir_To_Create}"
				runned=$(expr ${runned} + 1)
				set_new_directory "${Base_param_Dir_To_Create}" "${level}"
		fi
	fi
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$(dirname ${Function_PATH})"
	####################################################
}

function File_Read()
{
	#|# Data_miner                             : Use this var to set which function or cmd to make data mining in line
	#|# ${1}                                   : Use this var to set Data_miner
	#|# use "<<" to send file to function
	#|# Basic usage : File_Read ["data miner"] << file
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	#set_message "debug" "0" "current function path : [ ${Function_PATH} ]  | function Name [ ${Function_Name} ] "

	Data_miner="${1}"

	Empty_Var_Control "${Data_miner}" "Data_miner" "4"

	while read Internal_myline
		do
			if [ -z "${Data_miner}" ]
				then	
					echo " Line DATA : [ ${Internal_myline} ] "
				else
					${Data_miner} "${Internal_myline}"
			fi
			Internal_myline=""
	done

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$(dirname ${Function_PATH})"
	####################################################
}

function set_interleave_message()
{
	echo ""
	echo "###############################################################################"
	echo ""
}

function set_spacer_message()
{
	echo ""
	echo ""
}

function set_console_line()
{
	#|# Print a full-width separator line based on terminal size

    local char="${1:--}"
    local cols="$(tput cols 2>/dev/null)"
    
    if [ -z "${cols}" ]
    	then
        cols="80"
    fi

    printf '%*s\n' "${cols}" '' | tr ' ' "${char}"
}

function filename()
{
	_filname_get="${1}"
	echo ${_filname_get} | awk -F\/ '{ print $NF }'
}

function do_load_file() 
{
	#|# Description :
	#|# Dynamically load (source) a shell file if it exists.
	#|# This function is used to modularize script execution by conditionally
	#|# sourcing external libraries or components at runtime.
	#|#
	#|# Parameters :
	#|# ${1} : _file_to_source
	#|#        Absolute or relative path to the shell file to source (Mandatory)
	#|#
	#|# ${2} : _load_comment
	#|#        Optional contextual message displayed during loading (Optional)
	#|#
	#|# Behavior :
	#|# - Extracts the filename from the provided path using filename()
	#|# - Emits a "check" message indicating the loading attempt
	#|# - Verifies if the file exists on the filesystem
	#|# - If the file exists:
	#|#     → sources the file using `source`
	#|#     → checks the return code of the sourcing operation
	#|#         - If success (exit code 0):
	#|#             → emits a success message (EdSMessage)
	#|#         - If failure:
	#|#             → emits an error message (EdEMessage) with level 5
	#|# - If the file does not exist:
	#|#     → emits a success message indicating that the file is not present
	#|#
	#|# Dependencies :
	#|# - set_message() : centralized logging system
	#|# - filename()    : utility function to extract file name from path
	#|#
	#|# Usage :
	#|# do_load_file "${root_path}/bin/script.sh" "initialization script"
	#|#
	#|# Return :
	#|# - No explicit return value
	#|# - May terminate execution via set_message in case of failure

	local _file_to_source="${1}"
	local _load_comment="${2}"
  local _file_name="$(filename ${_file_to_source})"
  


  set_message "check" "0" "loading ${_file_name} ${_load_comment}"
   
	if [ -f ${_file_to_source} ]
		then 
		  source "${_file_to_source}"
				if [[ ${?} -eq 0 ]] 
					then
						set_message "EdSMessage" "0" "Loaded"
					else
						set_message "EdEMessage" "5" "Failled"
				fi
		else 
			set_message "EdEMessage" "8" "file not found"
	fi

}

function Internet_Http_Get {
	#|# Description :
	#|# Download a file over HTTP/HTTPS using wget and store it in a target directory.
	#|# This function builds a full download URL from provided parameters, ensures the
	#|# destination directory exists, and manages download execution with validation
	#|# and standardized logging.
	#|#
	#|# Parameters :
	#|# ${1} : _base_url
	#|#        Base URL used for download (Mandatory)
	#|#        Example: https://example.com/packages
	#|#
	#|# ${2} : _base_downladed_file_name
	#|#        File name to download (Mandatory)
	#|#        Example: package.tar.gz
	#|#
	#|# ${3} : _download_directory
	#|#        Target directory where the file will be stored (Mandatory)
	#|#        Example: /tmp/downloads
	#|#
	#|# ${4} : _additional_url_parameters
	#|#        Optional URL suffix or query string (Optional)
	#|#        Example: ?token=abc123
	#|#
	#|# Behavior :
	#|# - Builds and updates the stack trace context (Function_PATH)
	#|# - Logs execution context in debug mode
	#|# - Validates all mandatory input variables using Empty_Var_Control()
	#|# - Constructs the full download URL from base URL, file name, and optional parameters
	#|# - Ensures target directory exists using set_new_directory()
	#|# - Emits a check message before starting the download
	#|# - If the file already exists in the target directory:
	#|#     → emits a warning message (EdWMessage)
	#|#     → skips download
	#|# - If the file does not exist:
	#|#     → executes wget with directory prefix option
	#|#     → validates file presence after download
	#|#         - If file is missing:
	#|#             → emits an error message (EdEMessage) with level 2
	#|#         - If file exists:
	#|#             → emits a success message (EdSMessage)
	#|#
	#|# Dependencies :
	#|# - wget
	#|# - Empty_Var_Control()
	#|# - set_new_directory()
	#|# - set_message()
	#|# - dirname
	#|#
	#|# Usage :
	#|# Internet_Http_Get "https://example.com" "file.tar.gz" "/tmp/downloads"
	#|# Internet_Http_Get "https://example.com" "file.tar.gz" "/tmp/downloads" "?auth=token"
	#|#
	#|# Return :
	#|# - No explicit return value
	#|# - May terminate execution through set_message on error
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	set_message "debug" "0" "current function path : [ ${Function_PATH} ] "

	local _base_url="${1}"
	local _base_downladed_file_name="${2}"
	local _download_directory="${3}"
	local _additional_url_parameters="${4}"

	Empty_Var_Control "${_base_url}"                 "_base_url"                 "2" "1" "0"
	Empty_Var_Control "${_base_downladed_file_name}" "_base_downladed_file_name" "2" "1" "0"
	Empty_Var_Control "${_download_directory}"       "_download_directory"       "2" "1" "0"
  
	
	local _full_download_url="${_base_url}/${_base_downladed_file_name}${_additional_url_parameters}"
	
	set_new_directory "${_download_directory}"
  
	set_message "check" "1" "Downloading file : [ ${_base_downladed_file_name} ] "
	if [ -e "${_download_directory}/${_base_downladed_file_name}" ]
		then		
			set_message "EdWMessage" "1" "File Allready Downloaded : [ ${_base_downladed_file_name} ] "
		else
			wget -q --directory-prefix=${_download_directory} ${_full_download_url}
			if [ ! -e "${_download_directory}/${_base_downladed_file_name}" ]
				then		
					set_message "EdEMessage" "2" " Full URL : [ ${_base_downladed_file_name} : Failled ]  "
				else
					set_message "EdSMessage" "1" ""
		fi
	fi

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$(dirname ${Function_PATH})"
	####################################################
}

function Do_apt_update ()
{
	#|# Description : This function updates the package definition files on Debian-like systems, ensuring the package catalog is up to date.
	#|#
	#|# Variables    : None
	#|#
	#|# Base usage   : Do_apt_autoupdate
	#|#
	#|# Send Back    : Updates the system's package catalog.
	############ STACK_TRACE_BUILDER #####################
	Function_PATH="${Function_PATH}/${FUNCNAME[0]}"
	######################################################
  set_message "debug" "0" "current function path : [ ${Function_PATH} ]  | function Name [ ${Function_Name} ] "

  set_message "chack" "0" "Package Catalogue update"
  if [ ${_apt_update_runed} = 1 ]
		then 
     	set_message "EdSMessage" "1" "already done"
    else
      sudo apt-get update > /dev/null 2>&1 
      error_CTRL "${?}" "status for package catalogue update: " "Not Installed" "4" "" "" "nomsg"
			_apt_update_runed="1"
  fi 
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	#################################################### 
}

function Do_apt_install_package ()
{
	#|# Description :
	#|# Install a specified package using the APT package manager on Debian-based systems.
	#|# This function ensures idempotent behavior by first checking whether the package
	#|# is already installed before attempting installation. It integrates with the
	#|# centralized error handling system (error_CTRL) for consistent execution control.
	#|#
	#|# Parameters :
	#|# ${1} : _package_name
	#|#        Name of the package to install (Mandatory)
	#|#        Example: nginx, curl, docker.io
	#|#
	#|# Behavior :
	#|# - Builds and updates the stack trace context (Function_PATH)
	#|# - Logs current execution context in debug mode
	#|# - Validates that _package_name is not empty using Empty_Var_Control()
	#|# - Calls Test_apt_package_presence() to determine installation status
	#|# - If aptPackageStatus == "NOT INSTALLED":
	#|#     → emits a check message before installation
	#|#     → executes `apt-get install -y` silently
	#|#     → delegates result handling to error_CTRL()
	#|# - If aptPackageStatus == "INSTALLED":
	#|#     → no action performed (idempotent behavior)
	#|#
	#|# Dependencies :
	#|# - apt-get
	#|# - Test_apt_package_presence()
	#|# - error_CTRL()
	#|# - Empty_Var_Control()
	#|# - set_message()
	#|# - Global variable:
	#|#     aptPackageStatus : must be set by Test_apt_package_presence()
	#|#
	#|# Usage :
	#|# Do_apt_install_package "nginx"
	#|#
	#|# Output :
	#|# - Emits formatted messages through set_message()
	#|# - Executes package installation if required
	#|#
	#|# Return :
	#|# - No explicit return value
	#|# - Execution flow controlled via error_CTRL()
	############ STACK_TRACE_BUILDER #####################
	Function_PATH="${Function_PATH}/${FUNCNAME[0]}"
	######################################################
	set_message "debug" "0" "current function path : [ ${Function_PATH} ]"
  local _package_name="${1}"
	Empty_Var_Control "${_package_name}" "_package_name" "2" "1" "0"

  Test_apt_package_presence "${_package_name}"
    
  if [ "${aptPackageStatus}" = "NOT INSTALLED" ]
		then 
	    set_message "chack" "0" "installing package : [ ${_package_name} ]" 
      apt-get install "${_package_name}" -y > /dev/null 2>&1 
			error_CTRL "${?}" "" "0" "1" "" 
  fi

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	#################################################### 
}

function Do_apt_uninstall_package ()
{
	#|# Description :
	#|# Uninstall a specified package using the APT package manager on Debian-based systems.
	#|# This function first checks if the package is currently installed, then performs
	#|# a removal operation only if necessary. It integrates with the centralized error
	#|# handling mechanism (error_CTRL) to standardize execution flow and messaging.
	#|#
	#|# Parameters :
	#|# ${1} : _package_name
	#|#        Name of the package to uninstall (Mandatory)
	#|#        Example: nginx, curl, docker.io
	#|#
	#|# Behavior :
	#|# - Builds and updates the stack trace context (Function_PATH)
	#|# - Logs current execution context in debug mode
	#|# - Calls Test_apt_package_presence() to determine installation status
	#|# - If aptPackageStatus == "INSTALLED":
	#|#     → emits a check message before uninstall
	#|#     → executes `apt-get remove -y` silently
	#|#     → delegates result handling to error_CTRL()
	#|# - If aptPackageStatus != "INSTALLED":
	#|#     → no action performed (idempotent behavior)
	#|#
	#|# Dependencies :
	#|# - apt-get
	#|# - Test_apt_package_presence()
	#|# - error_CTRL()
	#|# - set_message()
	#|# - Global variable:
	#|#     aptPackageStatus : must be set by Test_apt_package_presence()
	#|#
	#|# Usage :
	#|# Do_apt_uninstall_package "nginx"
	#|#
	#|# Output :
	#|# - Emits formatted messages through set_message()
	#|# - Executes package removal if applicable
	#|#
	#|# Return :
	#|# - No explicit return value
	#|# - Execution flow controlled via error_CTRL()
	############ STACK_TRACE_BUILDER #####################
	Function_PATH="${Function_PATH}/${FUNCNAME[0]}"
	######################################################
  set_message "debug" "0" "current function path : [ ${Function_PATH} ]  | function Name [ ${Function_Name} ] "

  local _package_name="${1}"

  Test_apt_package_presence "${_package_name}"
    
		    
  if [ "${aptPackageStatus}" = "INSTALLED" ]
		then 
	    set_message "chack" "0" "uninstalling package : [ ${_package_name} ]" 
      apt-get remove "${_package_name}" -y > /dev/null 2>&1 
			error_CTRL "${?}" "" "0" "1" "" 
  fi


   
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	#################################################### 
}

function Test_apt_package_presence ()
{
	#|# Description :
	#|# Check whether a given package is installed on the system using the APT/DPKG
	#|# package manager. This function relies on dpkg-query and integrates with
	#|# error_CTRL to handle success and failure workflows through callback functions.
	#|#
	#|# Parameters :
	#|# ${1} : _package_name
	#|#        Name of the package to check (Mandatory)
	#|#        Example: curl, nginx, docker.io
	#|#
	#|# Behavior :
	#|# - Builds and updates the stack trace context (Function_PATH)
	#|# - Logs current execution context in debug mode
	#|# - Validates that _package_name is not empty using Empty_Var_Control()
	#|# - Emits a check message before performing the lookup
	#|# - Executes `dpkg-query --show` to determine package presence
	#|# - Delegates result handling to error_CTRL:
	#|#     → If package is found (exit code 0):
	#|#         - triggers Test_apt_package_presence_sub_i (success callback)
	#|#         - sets aptPackageStatus to "INSTALLED"
	#|#     → If package is not found (exit code != 0):
	#|#         - triggers Test_apt_package_presence_sub_u (failure callback)
	#|#         - sets aptPackageStatus to "NOT INSTALLED"
	#|#
	#|# Dependencies :
	#|# - dpkg-query
	#|# - Empty_Var_Control()
	#|# - error_CTRL()
	#|# - set_message()
	#|# - Callback functions:
	#|#     Test_apt_package_presence_sub_i
	#|#     Test_apt_package_presence_sub_u
	#|# - Global variable:
	#|#     aptPackageStatus : updated with installation status
	#|#
	#|# Usage :
	#|# Test_apt_package_presence "curl"
	#|#
	#|# Output :
	#|# - Emits formatted messages through set_message()
	#|# - Updates aptPackageStatus variable
	#|#
	#|# Return :
	#|# - No explicit return value
	#|# - Result handled via callbacks and global state (aptPackageStatus)
	############ STACK_TRACE_BUILDER #####################
	Function_PATH="${Function_PATH}/${FUNCNAME[0]}"
	######################################################
	set_message "debug" "0" "current function path : [ ${Function_PATH} ]  | function Name [ ${Function_Name} ] "

	local _package_name="${1}"
	Empty_Var_Control "${_package_name}" "_package_name" "2" "1" "0"

	set_message "chack" "0" "searching for installed package : [ ${_package_name} ] " 
	dpkg-query --show "${_package_name}" > /dev/null 2>&1
	error_CTRL "${?}" "" "0" "1" "" "Test_apt_package_presence_sub_i" "Test_apt_package_presence_sub_u"

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	#################################################### 
}

function Test_apt_package_presence_sub_i ()
{
	#|# Description :
	#|# Callback function used in conjunction with error_CTRL to handle the
	#|# "package present" scenario during APT package checks.
	#|# This function is typically triggered via the _on_sucess_action hook when
	#|# a package presence test succeeds.
	#|#
	#|# Parameters :
	#|# None
	#|#
	#|# Behavior :
	#|# - Builds and updates the stack trace context (Function_PATH)
	#|# - Logs current execution context in debug mode
	#|# - Sets the global variable aptPackageStatus to "INSTALLED"
	#|# - Does not perform any output except debug logging
	#|#
	#|# Dependencies :
	#|# - set_message() : for debug logging
	#|# - error_CTRL()  : caller function using this as callback
	#|# - Global variable:
	#|#     aptPackageStatus : status flag updated by this function
	#|#
	#|# Usage :
	#|# error_CTRL "${?}" "Package detected" "0" "1" "Checking package" "" "Test_apt_package_presence_sub_i"
	#|#
	#|# Output :
	#|# - Debug message only (if DEBUG_MODE=1)
	#|#
	#|# Return :
	#|# - No explicit return value
	#|# - Updates global state via aptPackageStatus
	############ STACK_TRACE_BUILDER #####################
	Function_PATH="${Function_PATH}/${FUNCNAME[0]}"
	######################################################
	set_message "debug" "0" "current function path : [ ${Function_PATH} ] "

	aptPackageStatus="INSTALLED"

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

function Test_apt_package_presence_sub_u ()
 {
	#|# Description :
	#|# Callback function used in conjunction with error_CTRL to handle the
	#|# "package not present" scenario during APT package checks.
	#|# This function is typically triggered via the _on_fail_action hook when
	#|# a package presence test fails.
	#|#
	#|# Parameters :
	#|# None
	#|#
	#|# Behavior :
	#|# - Builds and updates the stack trace context (Function_PATH)
	#|# - Logs current execution context in debug mode
	#|# - Sets the global variable aptPackageStatus to "NOT INSTALLED"
	#|# - Does not perform any output except debug logging
	#|#
	#|# Dependencies :
	#|# - set_message() : for debug logging
	#|# - error_CTRL()  : caller function using this as callback
	#|# - Global variable:
	#|#     aptPackageStatus : status flag updated by this function
	#|#
	#|# Usage :
	#|# error_CTRL "${?}" "Package missing" "0" "1" "Checking package" "Test_apt_package_presence_sub_u" ""
	#|#
	#|# Output :
	#|# - Debug message only (if DEBUG_MODE=1)
	#|#
	#|# Return :
	#|# - No explicit return value
	#|# - Updates global state via aptPackageStatus
	############ STACK_TRACE_BUILDER #####################
	Function_PATH="${Function_PATH}/${FUNCNAME[0]}"
	######################################################
	set_message "debug" "0" "current function path : [ ${Function_PATH} ]  | function Name [ ${Function_Name} ] "

	aptPackageStatus="NOT INSTALLED"

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

function do_gitea_create_secret()
{
	#|# Description :
	#|# This function creates or updates a repository secret in a Gitea instance
	#|# using the REST API (Gitea Actions secrets endpoint).
	#|#
	#|# The secret is stored at the repository level and can be consumed inside
	#|# Gitea Actions workflows via the `secrets.*` context.
	#|#
	#|# The function performs input validation using Empty_Var_Control before
	#|# issuing the API request.
	#|#
	#|# Parameters :
	#|# ${1} : _secret_name
	#|#        Name of the secret to create or update (Mandatory)
	#|#
	#|# ${2} : _secret_value
	#|#        Value of the secret (Mandatory)
	#|#
	#|# Required Environment Variables :
	#|# GITEA_ORG_or_USER : Organization or user owning the repository (Mandatory)
	#|# GITEA_REPO        : Repository name (Mandatory)
	#|# GITEA_URL         : Base URL of the Gitea instance (Mandatory)
	#|# GITEA_TOKEN       : API token with sufficient rights to manage secrets (Mandatory)
	#|#
	#|# Behavior :
	#|# - Validates all required inputs and environment variables
	#|# - Sends an HTTP PUT request to the Gitea API endpoint
	#|# - Creates the secret if it does not exist
	#|# - Updates the secret if it already exists
	#|#
	#|# API Endpoint :
	#|# PUT /api/v1/repos/{owner}/{repo}/actions/secrets/{secret_name}
	#|#
	#|# Security Notes :
	#|# - The secret value is transmitted via HTTPS and stored encrypted by Gitea
	#|# - Avoid logging or exposing ${_secret_value} in stdout/stderr
	#|# - Ensure GITEA_TOKEN is protected and not exposed in logs
	#|#
	#|# Return :
	#|# - 0 if the API call succeeds (HTTP 2xx expected)
	#|# - Non-zero if validation fails or curl encounters an error
	#|#
	#|# Dependencies :
	#|# - curl must be installed and available in PATH
	#|# - Empty_Var_Control function must be defined
	#|#
	local _secret_name="${1}"
  local _secret_value="${2}"
   
	Empty_Var_Control "${_secret_name}"       "_secret_name"       "2" "1" "0"
	Empty_Var_Control "${_secret_value}"      "_secret_value"      "2" "1" "0"
  Empty_Var_Control "${GITEA_ORG_or_USER}"  "GITEA_ORG_or_USER"  "2" "1" "0"
	Empty_Var_Control "${GITEA_REPO}"         "GITEA_REPO"         "2" "1" "0"
  Empty_Var_Control "${GITEA_URL}"          "GITEA_URL"          "2" "1" "0"

  curl \
  --request PUT \
  --header "Authorization: token ${GITEA_TOKEN}" \
  --header "Content-Type: application/json" \
  --data "{\"data\":\"${_secret_value}\"}" \
  "${GITEA_URL}/api/v1/repos/${GITEA_ORG_or_USER}/${GITEA_REPO}/actions/secrets/${_secret_name}"
}


do_generate_password() 
{
    local length=${1}
    openssl rand -base64 $((length * 3 / 4)) | tr -d '=+/' | head -c "$length"
}

# Fonction pour générer une clé longue
do_generate_key() 
{
    openssl rand -base64 96 | tr -d '\n'
}




if [[ -f docker-container.sh ]]
  then
		set_message "check" "0" "Loading docker-container.sh"
		. docker-container.sh
fi



check_dependencies
core_functions_loaded="1"
