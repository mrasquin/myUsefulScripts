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


### Check the input
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

	
### Clean the links

# Check geom0.sms
checkfile=geom0.sms
if [ -e $checkfile ]; then
	if [ -h $checkfile ]; then
		for (( i=0; i<=$(($inputpart-1)); i++)); do
			rm geom$i.sms 
		done
		echo "Links to input sms files removed"
	else
		echo "You are trying to remove regular files and not links! Operation cancelled"
	fi
else
	echo "No link to geom0.sms found"
fi

# Specific operation for UR or Solution Migration
if [ "x$operation" == "xboth" ] ; then 

       	checkfile=restart.$timestep.1
	if [ -e $checkfile ] ; then
		if [ -h $checkfile ]; then 
		        for (( i=1; i<=$(($inputpart)); i++)); do
        		        rm restart.$timestep.$i
		        done
		        echo "Links to the restart.*.# files removed"
		else
        		echo "You are trying to remove regular files and not links! Operation cancelled"
		fi
	else
		echo "No restart.*.1 file found"
	fi
fi


