#! /bin/bash

# this scripts reads data from a csv file and parses it before generating standard
# SQL statements for inserting the data read rom the file
# through doing this, it is illustrating the use of redirection in Linux
# the input should be a csv file, and is supplied to the command line when running the script

outfile=‘members.sql’
IFS=’,’
while read lname fname address city county telephone
do
	cat >> $outfile << EOF
INSERT INTO members (lname,fname,address,city,county,telephone) VALUES
(‘$lname’, ‘$fname’, ‘$address’, ‘$city’, ‘$county’, ‘$telephone’);
EOF
done < ${1}
