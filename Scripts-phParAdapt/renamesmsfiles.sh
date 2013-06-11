#!/bin/bash -l

nparts=$1
operation=$2
 
print_usage()                                                                                  
{
   echo "Usage: $0"                                                                 
   echo "<nparts>"
   echo "<operations> (UR, Part, Tet, URPart)"
}  


### Check the input
if [ "x$nparts" == "x" ]; then
	echo 'Specify the number of parts for the sms directory'
	print_usage
	exit 1
fi

if [ "x$operation" == "x" ]; then
        echo 'Specify the Operation'
        print_usage
        exit 1
fi

if [ "x$operation" != "xUR" ] && [ "x$operation" != "xPart" ] && [ "x$operation" != "xTet" ] && [ "x$operation" != "xURPart" ] ; then
        echo "Operation should be either Part, UR, Tet, or URPart"
        print_usage
        exit 1
fi


### Start with the sms directory
dirname=$nparts-sms
if [ -d $dirname ] ; then

	# Change directory
	cd $dirname
			
	# Get the name of the  *($npart-1).sms file
	if [ "x$operation" == "xUR" ] || [ "x$operation" == "xURPart" ] ; then
		name="mesh_out"
	elif [ "x$operation" == "xPart" ] ; then
		name="geom_"
	elif [ "x$operation" == "xTet" ]; then
		name="geom-tet"
	fi

	zero=0
	checkfile=$name$zero.sms
	if [ -e $checkfile ] ; then
		# Start renaming files	
		for (( i=0; i<$(($nparts)); i++))  ; do
			if [ "$(($i % 16384))" -eq "0" -a "$i" -gt "0" ] ; then
				echo "Renaming $name$i.sms in geom$i.sms"
			fi
			mv $name$i.sms geom$i.sms
		done
		echo "sms files renamed successfully"
	else
		echo "No $name$zero.sms in $dirname"
		echo "You probably selected the wrong operation"
	fi

	# Change directory
	cd ..
else
	echo "$dirname not found - Quiting the script now"
fi

