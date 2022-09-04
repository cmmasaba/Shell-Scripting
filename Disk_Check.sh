#! /bin/bash

# this scripts helps monitor disk usage by sa=canning specified directories
# and creating a report of the top 10 files/directories occupying most space

# for illustration only tow directories were used, you can add more directories
DIRECTORIES_TO_CHECK="/home /var/log"

DATE=$(date '+%y%m%d')
# create the report name
exec > disk_space_$DATE.rpt
echo
echo "Top 10 disk space usage"
echo "for $DIRECTORIES_TO_CHECK directories."
for DIR in $DIRECTORIES_TO_CHECK
do
	echo ""
	echo "The $DIR Directory:"
	du -S $DIR 2> /dev/null |
	sort -rn |
	sed '{11,$D; =}' |
	sed 'N; s/\n/ /' |
	gawk '{printf $1 ":" "\t" $2 "\t" $3 "\n"}'
done
exit
