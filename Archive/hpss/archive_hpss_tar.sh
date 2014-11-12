#!/bin/bash

### Description
#
# Script to tar one single file or directory and archive it to hpss using hsi.
#
# Usage: 
# 	for one single file or directory:		./archive_hpss_tar.sh file
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

itemtoarchive=$1
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
subpath=".$subpath"

# Get the date and time stamp for the log file
now=$(date +"%F_%H-%M-%S")
logfile=hsi.log_$now

# Print some info
echo "Archiving $itemtoarchive.tar to $subpath on hpss"


# The last character of the string should not be "\". Remove it if present
lastchar=`echo "$itemtoarchive" | sed -e 's/\(^.*\)\(.$\)/\2/'`
if [ "$lastchar" == "/" ]; then
  itemtoarchive=`echo ${itemtoarchive%?}`
fi

# Archive a tarball to hpss and move archived item to a TRASH directory for future removal
hsi "mkdir -p $subpath"
tar cf - $itemtoarchive | hsi "put - : $subpath/$itemtoarchive.tar"
mkdir -p TRASH
mv $itemtoarchive TRASH

