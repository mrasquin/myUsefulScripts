#!/bin/bash

### Description
#
# Script to archive to hpss a file or a set of files using hsi
# Favor large files if possible to hpss, like tarball or heavy phasta files
#
# Usage: 
# 	for one single file:			./archive_hpss_file.sh file
#	for a set of files (note the quotes!):	./archive_hpss_file.sh "file*"
#
# Note that a directory tree similar to what pwd returns in the current dir 
# will be created on hpss. Concretely, the path beyond your username will be 
# preserved on hpss for the file(s) you are archiving.
#
# The hsi log are saved in a file named hsi.log_date
#
# The files archived to hpss are then moved to a TRASH directory. 
# For safety, always check the log file and the archived filee on hpss before deleting 
#

# Function die called when there is a problem 
function die() {
        echo -e "${1}"
        exit 1
}


filetoarchive=$1

# check if the  user entered proper number of args
nargs=1
if [[ "${#}" -ne "$nargs" ]] ; then
	die "\n Check usage: \n \tFor one single file:\t\t\t $0  file \n \tFor a set of files (note the quotes!):\t $0 \"file*\""
fi

# Get the current path
path=`pwd`

# Get the username for the keyword in the path
username=`whoami`

# Get the subpth from /Models (assumed on BGQ)
subpath=`echo $path | awk -F $username '{print $2}'`
subpath=".$subpath" # add a . to the path

# Get the date and time stamp for the log file
now=$(date +"%F_%H-%M-%S")
logfile=hsi.log_$now

# Print some info
echo "Archiving $filetoarchive to $subpath on hpss"
echo "If archiving a set of files with *, encapsulate the argument with \" \""
echo "See $logfile for log info"
echo "Archived files are then moved to TRASH"

# Archive files to hpss and move archived files to a TRASH directory for future removal
time hsi -O $logfile "mkdir -p $subpath ; cd $subpath ; pwd ; ls ; put $filetoarchive"
mkdir -p TRASH
mv $filetoarchive TRASH

