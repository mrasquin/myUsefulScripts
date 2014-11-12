#!/bin/bash

# Function die called when there is a problem 
function die() {
        echo -e "${1}"
        exit 1
}


dirtoarchive=$1

path=`pwd`
echo $path

subpath=`echo $path | awk -F Models '{print $2}'`
subpath=".$subpath"
echo $subpath
echo "Archiving $dirtoarchive to $subpath on hpss"

lastchar=`echo "$dirtoarchive" | sed -e 's/\(^.*\)\(.$\)/\2/'`
if [ "$lastchar" == "/" ]; then
  die "Remove '/' at the end of your directory to archive"
fi

hsi "mkdir -p $subpath"
tar cf - $dirtoarchive | hsi "put - : $subpath/$dirtoarchive.tar"
mv $dirtoarchive TRASH-$dirtoarchive



