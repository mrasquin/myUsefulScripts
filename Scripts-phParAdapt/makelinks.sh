#!/bin/bash

inputpart=$1
operation=$2
timestep=$3

print_usage()                                                                                  
{
   echo "Usage: $0"                                                                 
   echo "<inputpart>"
   echo "<operation> ('sms', 'both' for both sms and restart files) "
   echo "<timestep> (compulsary only if operation='both')"
}  


# Check the input
if [ "x$inputpart" == "x" ]; then
	echo 'Specify the number of input parts'
	print_usage
	exit 1
fi

if [ "x$operation" == "x" ]; then
        echo 'Specify the Operation'
        print_usage
        exit 1
fi

if [ "x$operation" != "xsms" ] && [ "x$operation" != "xboth" ] ; then
	echo "Operation should be ether 'sms' or 'both'"
	print_usage
	exit 1
fi
	
if [ "x$operation" == "xboth" ] && [ "x$timestep" == "x" ] ; then
	echo "timestep must be provided if operation=both"
	print_usage
	exit 1
fi

### Create the links

# sms files - always
checkfile=geom0.sms
dir=../$inputpart-sms
if [ -e $dir/$checkfile ]; then
	for (( i=0; i<$(($inputpart)); i++))  ; do
		ln -s $dir/geom$i.sms .
	done
	echo "The links to the geom#.sms files have been created"
else
	echo "The target directory $dir or file $checkfile does not exist"
fi

# restart files for solution migration
if [ "x$operation" == "xboth" ] ; then # We need also the restart files
	dir=../$inputpart-procs_case

        checkfile=restart.$timestep.1
        if [ -e $dir/$checkfile ]; then
		for (( i=1; i<=$(($inputpart)); i++))  ; do
                        ln -s $dir/restart.$timestep.$i .
                done
                echo "The links to the restart.$timespte.# files have been created"
        else
                echo "The target directory $dir or file $checkfile does not exist"
        fi
fi

