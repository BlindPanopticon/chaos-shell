#!/bin/bash
TITLE=SCRIPT_EDITOR
NOTIFY_TIME=5000
EXIT_THRESHOLD=5
ARG_COUNT=1
REQUIRED_USER=$USER

source ${0%/*}/chaos-shell.sh

FILE=$1

newscreen
LABEL=INPUT_FILE_SIGNATURE
echo $FILE
gpg --verify $FILE.asc $FILE
checkError 4 
statement "GPG_INPUT_SIG_VALID"
pause

vim $FILE
gpg --armor --detach-sign -u 7AEA198A $FILE
