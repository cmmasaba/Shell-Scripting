#! /bin/bash

# this scripts automates the process of deleting a user account on a system.
# it performs the following tasks: first, it gets the name of the user account
# and confirms if it is the correct user account to be deleted.
# second, it finds any processes running on the system that belong to the user
# and if you would wan to kill them. third, it find all files in the system
# that belong to the user and creates a report of those files before deleting them.
# fourth, if goes ahead to remove the account from the system.
clear
# Define functions that will be used
function get_answer {
unset ANSWER
COUNT=0
while [ -z "$ANSWER" ]
do
	COUNT=$[ $COUNT + 1 ]
	case $COUNT in
	2)
		echo
		echo "Please answer the question."
		echo
	;;
	3)
		echo
		echo "Last try...please answer the question."
		echo
	;;
	4)
		echo
		echo "No answer was provided."
		echo "Exiting the script."
		echo
		exit
	;;
	esac
	echo
	if [ -n "LINE2" ]
	then
		echo $LINE1
		echo -e $LINE2" \c"
	else
		echo $LINE1
	fi
	read -t 60 ANSWER
done
unset LINE1
unset LINE2
}

function process_answer {
case $ANSWER in
y|Y|YES|Yes|yes|yEs|yeS|YEs|yES )
;;
*)
	echo
	echo $EXIT_LINE1
	echo $EXIT_LINE2
	echo
	exit
;;
esac
unset EXIT_LINE1
unset EXIT_LINE2
}
### Main Script ###
echo "#Step 1 - Determining the user account to delete"
echo
LINE1="Please enter the username of the user"
LINE2="account you wish to delete from the system:"
get_answer
USER_ACCOUNT=$ANSWER
LINE1="Is $USER_ACCOUNT the user account"
LINE2="you wish to delete from the system? [y/n]"
get_answer
EXIT_LINE1="Because $USER_ACCOUNT is not the user account"
EXIT_LINE2="you wish to remove from the system, the script is exiting..."
process_answer
USER_ACCOUNT_RECORD=$(cat /etc/passwd | grep -w $USER_ACCOUNT)
if [ $? -eq 1 ]
then
	echo
	echo "$USER_ACCOUNT not found on the system."
	echo "Exiting script..."
	echo
fi
echo "I have found this record:"
echo $USER_ACCOUNT_RECORD
LINE1="Is this the correct account? [y/n]"
get_answer
EXIT_LINE1="Because $USER_ACCOUNT is not the user account"
EXIT_LINE2="you wish to remove from the system, the script is exiting..."
process_answer
echo
echo "#STEP 2 - find any processes running belonging to this account"
echo
ps -u $USER_ACCOUNT > /dev/null
case $? in
1)
	echo
	echo "No processes running belonging to this user."
	echo
;;
0)
	echo "$USER_ACCOUNT has the following processes running:"
	echo
	ps -u $USER_ACCOUNT
	LINE1="Would you like to kill these processes? [y/n]"
	get_answer
	case $ANSWER in
	y|Y|Yes|YES|yES|yEs|yeS|yes|YEs )
		echo
		echo "Killing off process(es)."
		# list all user processes in a variable
		COMMAND1="ps -u $USER_ACCOUNT --no-heading"
		# command to kill all these processes
		COMMAND2="xargs -d \\n /usr/bin/sudo /bin/kill -9"
		$COMMAND1 | gawk '{print $1}' | $COMMAND2
		echo
		echo "Process(es) killed..."
	;;
	*)
		echo
		echo "Will not kill the process(es)"
		echo
	;;
	esac
;;
esac
echo "#Step 3 - find all files in the sytem belonging to the user"
echo
echo "Creating a report of all files in the system owned by this user."
echo "It is recommended that you backup/archive this files,"
echo "and then do one of these two things:"
echo "	1) Delete the files"
echo "	2) Change the files' ownership to a current user account."
echo
echo "This may take a while..."
REPORT_DATE=$(date +%y%m%d)
REPORT_FILE=$USER_ACCOUNT"_Files_"$REPORT_DATE".rpt"
find / -user $USER_ACCOUNT > $REPORT_FILE 2> /dev/null
echo "Report is complete."
echo "Name of report: $REPORT_FILE"
echo "Location of report: $(pwd)"
echo
echo "#Step 4 - Removing the user account."
LINE1="Remove the $USER_ACCOUNT from the system? [y/n]"
get_answer
EXIT_LINE1="Since you do not wish to remove $USER_ACCOUNT"
EXIT_LINE2="user account from the system, the script is exiting."
process_answer
userdel $USER_ACCOUNT
echo
echo "User account, $USER_ACCOUNT, has been removed."
echo
exit
