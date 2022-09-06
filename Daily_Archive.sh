#! /bin/bash

# a script to archive designated files and directories on a daily basis
# the files to be archived are named in the Files_To_Backup file
# create a central repository for archiving which is a directory called archive
# the archive filename consists of an extension of the date it was created

DATE=$(date +%y%m%d)
FILE=archive$DATE.tar.gz
CONFIG_FILE=/archive/Files_To_Backup
DESTINATION=/archive/$FILE

if [ -f $CONFIG_FILE ]
then
	echo
else
	echo "$CONFIG_FILE missing. Cannot complete backup due to missing configuration file."
	exit
fi

FILE_NO=1
exec < $CONFIG_FILE
read FILE_NAME
while [ $? -eq 0 ]
do
	if [ -f FILE_NAME -o -d FILE_NAME ]
	then
		FILE_LIST="$FILE_LIST $FILE_NAME"
	else
		echo "$FILE_NAME doesn't exist and will not be included in the archive."
		echo "It is listed on line number $FILE_NO of the config file."
		echo "Continuing to build archive..."
	fi
	FILE_NO=$[ $FILE_NO + 1 ]
	read FILE_NAME
done

echo "Starting archive..."
tar -czf $DESTINATION $FILE_LIST 2> /dev/null
echo "Archive completed."
echo "Resulting archive file is: $DESTINATION."
exit
