function print_header() 
{
	echo ""
	echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
	echo -e "${BLUE}  ${1}${NC}"
	echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
	echo ""
}

function error_CTRL() 
{
	#|# Var to set :
	#|# \_result                      : Use this var to set the result code to check ( Mandatory )
	#|# ${1}                          : Use this var to set [ _result ]
	#|# \_result_msg                  : Use this var to set the message to display based on result ( Optional )
	#|# ${2}                          : Use this var to set [ _result_msg ]
	#|#
	#|#  Base usage  : error_CTRL "${?}" "Operation completed successfully"
	#|#
	#|# Description : This function manages basic error control and displays messages based on the result
	#|#
	#|# Send Back : Exit code 0 on success, exit code with defined level on error
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	set_message "debug" "0" "current function path : [ ${Function_PATH} ] | Function Name [ ${Function_Name} ]"

	local _result="${1}"
	local _result_msg="${2}"
    local _force_level="${3:-1}"

    #echo "_result: ${_result} | _result_msg: ${_result_msg} | _force_level: ${_force_level}" 
	#Empty_Var_Control "${_result}" "result" "1"

	if [[ "${_result}" = "0" ]]
    then		
        set_message "EdSMessage" "0" "${_result_msg}"
	else
		set_message "EdEMessage" "${_force_level}" "${_result_msg}"
	fi

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$(dirname ${Function_PATH})"
	####################################################
}

function Empty_Var_Control() 
{
	#|# Var to set :
	#|# \_variable_to_check           : Variable content to validate ( Mandatory )
	#|# \_variable_name               : Name of the variable for error messages ( Mandatory )
	#|# \_exit_code                   : Exit code if variable is empty ( Optional - default: 1 )
	#|# ${1}                          : Use this var to set [ _variable_to_check ]
	#|# ${2}                          : Use this var to set [ _variable_name ]
	#|# ${3}                          : Use this var to set [ _exit_code ]
	#|#
	#|# Base usage  : Empty_Var_Control "${my_var}" "my_var" "2"
	#|#
	#|# Description : Validates that a variable is not empty and exits with specified code if empty
	#|#
	#|# Send Back : Exit code 0 if variable has content, specified exit code if empty
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	set_message "debug" "0" "current function path : [ ${_Function_PATH} ] | Function Name [ ${_Function_Name} ]"

	local _variable_to_check="${1}"
	local _variable_name="${2}"
	local _exit_code="${3:-1}"

	set_message "check" "1" "Validating variable [ ${_variable_name} ] is not empty"
	if [[ -z "${_variable_to_check}" ]]
    then		
        set_message "EdEMessage" "1" "empty or undefined"
		exit "${_exit_code}"
	else
		set_message "EdSMessage" "1" "is set with value: ${_variable_to_check}"
	fi

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$(dirname ${Function_PATH})"
	####################################################
}

function set_message() 
{
	#|# Var to set :
	#|# \_message_type                : Type of message (debug|info|EdSMessage|EdEMessage|warn|check) ( Mandatory )
	#|# \_message_level               : Level of message (0-4) ( Mandatory )
	#|# \_message_content             : Content of the message ( Mandatory )
	#|# ${1}                          : Use this var to set [ _message_type ]
	#|# ${2}                          : Use this var to set [ _message_level ]
	#|# ${3}                          : Use this var to set [ _message_content ]
	#|#
	#|# Base usage  : set_message "info" "0" "Operation started"
	#|#
	#|# Description : Centralized message display function with color coding and formatting
	#|#
	#|# Send Back : Formatted message output to stdout/stderr
	local _message_type="${1}"
	local _message_level="${2}"
	local _message_content="${3} "
	local _timestamp=$(date '+%Y-%m-%d %H:%M:%S')

	# Color codes
	local _RED='\033[0;31m'
	local _GREEN='\033[0;32m'
	local _YELLOW='\033[1;33m'
	local _BLUE='\033[0;34m'
	local _CYAN='\033[0;36m'
	local _NC='\033[0m' # No Color

	case "${_message_type}" in
	"debug")
		if [[ "${DEBUG_MODE}" = "1" ]]
        then    echo -e "[${_BLUE}DEBUG${_NC}]\t${_timestamp} - ${_message_content}"
		fi
		;;
	"info")
		if [[ ${_message_level} -eq 0 ]]
        then    echo -e "[${_BLUE}INFO${_NC}]\t${_timestamp} - ${_message_content}"

		else
			echo -e "[${_CYAN}INFO${_NC}]\t${_timestamp} - ${_message_content}" >>${log_file}
		fi
		;;
	"check")
		echo -en "\n"
		line_length=$(get_length "$(echo -e "[${_BLUE}CHECK${_NC}]\t${_timestamp} - ${_message_content}")")
		if [[ ${_message_level} -eq 0 ]]
        then
  		    echo -en "[${_BLUE}CHECK${_NC}]\t${_timestamp} - ${_message_content}"
  		else
	  		echo -en "[${_CYAN}CHECK${_NC}]\t${_timestamp} - ${_message_content}" >>${log_file}
		fi
		set_length "$(echo -e "[${_BLUE}CHECK${_NC}]\t${_timestamp} - ${_message_content}")"
		;;
	"EdSMessage")
		set_length "\t[${_GREEN}SUCCESS${_NC}] - ${_message_content}"
		if [[ ${Ed_msgage_display} -eq 0 ]]
        then
      	    echo -e "${add_string}\t[${_GREEN}SUCCESS${_NC}] - ${_message_content}"
        else
            echo -e "${add_string}\t[${_GREEN}SUCCESS${_NC}] - ${_message_content}" >>${log_file}
		fi
		;;
	"EdWMessage")
		set_length "\t[${_YELLOW}WARNING${_NC}] - ${_message_content}"
        if [[ ${_message_level} -eq 0 ]]
        then	
  		    echo -e "${add_string}\t[${_YELLOW}WARNING${_NC}] - ${_message_content}"
        else
            echo -e "${add_string}\t[${_YELLOW}WARNING${_NC}] - ${_message_content}" >>${log_file}
		fi
		;;
	"EdEMessage")
    # echo "_message_content: ${_message_content} | _message_level: ${_message_level} | add_string: ${add_string}"
		set_length "\t[${_RED}ERROR${_NC}] - ${_message_content}"
		if [[ ${_message_level} -eq 0 ]]
        then		
            echo -e "${add_string}\t[${_RED}ERROR${_NC}] - ${_message_content}"
        else
            echo -e "${add_string}\t[${_RED}ERROR${_NC}] - ${_message_content}" >>${log_file}
        Ed_msgage_display="0"
        exit ${_message_level}
		fi
		;;
	"warn")
		echo -e "\t[${_YELLOW}WARNING${_NC}] - ${_message_content}"
		;;
	*)
		echo -e "[${_NC}UNKNOWN${_NC}]\t${_timestamp} - ${_message_content}"
		;;
	esac
}

function Set_terminal_properties() 
{
	_terminal_width="$(tput cols 2>/dev/null)"
	[[ -z "${_terminal_width}" ]] && _terminal_width="120"
	_col1_width="$(( _terminal_width - 60 ))"
}

function get_length() 
{
	local str="$1"
	echo "${#str}"
}

function set_length() 
{
	local str="${1}"
	local length
	length=$(get_length "$str")

	[[ -z "${_col1_width}" ]] && Set_terminal_properties
	[[ -z "${line_length}" ]] && line_length="0"

	length_add="$(( _col1_width - line_length ))"

	[[ "${length_add}" -lt 1 ]] && length_add=1
	[[ "${length_add}" -gt 30 ]] && length_add=30

	add_string="$(printf "%-${length_add}s" "-")"
}

function Dir_null_or_slash() 
{
	#|# Var to set  :
	#|# Path_To_test : The path of the directory to test
	#|# ${1}         : First parameter, used to set Path_To_test
	#|#
	#|# Description : This function checks if the provided directory path is either empty
	#|# or just a root slash ('/'). If either condition is met, an error message is displayed.
	#|#
	#|# Basic Usage :
	#|#               Dir_null_or_slash "My_directory_path"
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	set_message "debug" "0" "current function path : [ ${Function_PATH} ]  | function Name [ ${Function_Name} ]"

	local Path_To_test="${1}"
	set_message "check" "1" "Checking directory: [ ${Path_To_test} ]"
	# Check if the path is empty
	if [ -z "${Path_To_test}" ]
    then
        set_message "EdEMessage" "1" "Error ON PATH: [ Value is NULL ]"
	else
		# Check if the path is just a root slash ('/')
		if [ "${Path_To_test}" = "/" ]
    then 
        set_message "EdEMessage" "1" "Error ON PATH: [ Value is / ]"
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
	set_message "debug" "0" "current function path : [ ${Function_PATH} ]  | function Name [ ${Function_Name} ]"

	local Base_param_Dir_To_Create="${1}"
	local level=${2:-1}

	Dir_null_or_slash "${Base_param_Dir_To_Create}"
	set_message "check" "${level}" "Checking directory: [ ${Base_param_Dir_To_Create} ]"
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
  then			set_message "EdSMessage" "${level}" "Present"
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

function File_Read {
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

	while read Internal_myline; do
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

function set_interleave_message {
	echo ""
	echo "###############################################################################"
	echo ""
}

function set_spacer_message {
	echo ""
	echo ""
}

if [[ -f docker-container.sh ]]
  then	set_message "check" "0" "Loading docker-container.sh"
	. docker-container.sh
fi

Set_terminal_properties
core_functions_loaded="1"
