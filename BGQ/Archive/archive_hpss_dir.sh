#!/bin/bash

### Description
#
# Script to archive to hpss a directory or a set of directories using hsi
# Favor large files in the directories if possible to hpss, like tarball or heavy phasta files
#
# Usage: 
# 	for one single directory			./archive_hpss_file.sh dir
#	for a set of directories (note the quotes!):	./archive_hpss_file.sh "dir*"
#
# Note that a directory tree similar to what pwd returns in the current dir 
# will be created on hpss. Concretely, the path beyond your username will be 
# preserved on hpss for the dir(s) you are archiving.
#
# The hsi log are saved in a file named hsi.log_date
#
# The directories archived to hpss are then moved to a TRASH directory. 
# For safety, always check the log file and the archived filee on hpss before deleting 
#

# Function die called when there is a problem 
function die() {
        echo -e "${1}"
        exit 1
}


dirtoarchive=$1

# check if the  user entered proper number of args
nargs=1
if [[ "${#}" -ne "$nargs" ]] ; then
	die "\n Check usage: \n \tFor one single dir:\t\t\t $0  dir \n \tFor a set of dirs (note the quotes!):\t $0 \"file*\""
fi

# Get the current path
path=`pwd`

# Get the username for the keyword in the path
username=`whoami`

# Get the subpth from /Models (assumed on BGQ)
subpath=`echo $path | awk -F $username '{print $2}'`
subpath=".$subpath"

# Get the date and time stamp for the log file
now=$(date +"%F_%H-%M-%S")
logfile=hsi.log_$now

# Print some info
echo "Archiving $dirtoarchive to $subpath on hpss"
echo "If archiving a set of directories with *, encapsulate the argument with \" \""
echo "See $logfile for log info"
echo "Archived dirs are then moved to TRASH"

# The last character of the string should not be "\". Remove it if present
lastchar=`echo "$dirtoarchive" | sed -e 's/\(^.*\)\(.$\)/\2/'`
if [ "$lastchar" == "/" ]; then
  dirtoarchive=`echo ${dirtoarchive%?}`
fi

# Archive a directory to hpss and move archived dir to a TRASH directory for future removal
time hsi -O $logfile "mkdir -p $subpath ; cd $subpath ; pwd ; ls ; put -R $dirtoarchive"
mkdir -p TRASH
mv $dirtoarchive TRASH

