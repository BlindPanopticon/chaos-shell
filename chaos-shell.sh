: <<'COMMENT'
#!/bin/bash
TITLE=_TITLE_
NOTIFY_TIME=5000
EXIT_THRESHOLD=5
ARG_COUNT=_COUNT_
REQUIRED_USER=_USER_
FORCE_USER=_BOOLEAN_

source ${0%/*}/chaos-shell.sh
COMMENT

LABEL=BEGIN

####################
#NOTIFICATION & ECHO
#Ben Jarnagin
#Runs on call
####################
function notify {
        echo -e "\033[38;5;3mNOTIFICATION:$TITLE::$1\033[0;00m"
	notify-send -u normal -t $NOTIFY_TIME "NOTIFICATION:$TITLE" "$1"
}

####################
#ERROR & ECHO
#Ben Jarnagin
#Runs on call
####################
function error {
    echo -e "\033[38;5;1mERROR:$TITLE::$1\033[0;00m"
    notify-send -u critical -t $NOTIFY_TIME "ERROR:$TITLE" "$1"
    if [ $2 -gt $EXIT_THRESHOLD ]
    then
		exit
	fi

}

####################
#STATEMENT ECHO
#Ben Jarnagin
#Runs on call
####################
function statement {
        echo -e "\033[38;5;10mSTATEMENT:$TITLE::$1\033[0;00m"
}

####################
#NEW SCREEN
#Ben Jarnagin
#Runs on call
####################
function newscreen {
        clear
        echo "################$TITLE################"
        echo
}

####################
#PAUSE AND CHECK FOR ERRORS
#Ben Jarnagin
#Runs on call
####################
function pause {
        echo
        echo -e "\033[38;5;5m################PAUSE################\033[0;00m"
        checkError 1
        echo -e "\033[38;5;5m#######PRESS ENTER TO CONTINUE#######\033[0;00m"
        read
}

####################
#CHECK FOR ERROR
#Ben Jarnagin
#Runs on call
####################
function checkError {
	if [ $? -ne 0 ]
    then
        error "$LABEL" $1
    fi
}

####################
#CONFIRM SCRIPT SIGNATURE
#Ben Jarnagin
#Runs on call
####################
function confirmScriptSignature {
	LABEL=GPG_SCRIPT_SIG_VERIFY

	FILE=${0%/*}/$(basename $0)
	
	#gpg --verify $FILE.asc $FILE
	gpg --verify ${0%/*}/$(basename $0).asc $FILE
	checkError 100
	
	statement "GPG_SCRIPT_SIG_VALID"
	pause
}

####################
#TEST NUMBER OF ARGUMENTS
#Ben Jarnagin
#Runs Always
####################
if [ $# -ne $ARG_COUNT ]
then
        error "Invalid Number of Arguments" 10
fi

####################
#CHECK USER
#Ben Jarnagin
#Runs Always
####################
if [ $USER != $REQUIRED_USER ]
then
	error "Incorrect Running User" 5 

	if [ $FORCE_USER = TRUE ]
	then
		confirmScriptSignature
		statement 'Forcing run "'${0%/*}'/'$(basename $0)' '$@'" as '$REQUIRED_USER
		sudo -u $REQUIRED_USER ${0%/*}'/'$(basename $0) $@
		exit
	fi
fi
