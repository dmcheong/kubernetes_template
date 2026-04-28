#!/usr/bin/env bash

get_shell="$(ps -p $$ -o ppid=)"

actual_shell="$(ps -p ${get_shell} -o comm=)"

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

function version_lt()
{
  [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" != "$2" ]
}
