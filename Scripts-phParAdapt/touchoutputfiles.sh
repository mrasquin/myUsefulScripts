#!/bin/bash

outputpart=$1
operation=$2
timestep=$3
writesms=$4

print_usage()                                                                                  
{
   echo "Usage: $0"                                                                 
   echo "<outputpart>"
   echo "<operations> (UR, Part, Tet, URPart)"
   echo "<timestep>"
   echo "<writesms> (0 or 1)"
}  


# Check the input
if [ "x$outputpart" == "x" ]; then
	echo 'Specify the number of output parts'
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

if [ "x$writesms" == "x" ] ; then
	echo "writesms must be provided"
	print_usage
	exit 1
fi

### touch the output files

# Determine the number of parts per subdirectory
maxsubdir=2048
if [ "$outputpart" -gt "$maxsubdir" ] ; then
	partpersubdir=$(($outputpart / $maxsubdir))
fi

# sms files
if [ "x$writesms" == "x1" ] ; then
	dir=$outputpart-sms
	mkdir $dir

	if [ "$outputpart" -gt "$maxsubdir" ] ; then
		for (( i=0; i<$(($maxsubdir)); i++))  ; do
			mkdir $dir/$i
		done
	fi

	# Get the name of the  sms files
	if [ "x$operation" == "xUR" ] || [ "x$operation" == "xURPart" ] ; then
		name="mesh_out"
	elif [ "x$operation" == "xPart" ] ; then
		name="geom_"
	elif [ "x$operation" == "xTet" ]; then
		name="geom-tet"
	fi

	for (( i=1; i<=$(($outputpart)); i++))  ; do
		if [ "$(($i % 16384))" -eq "0" -a "$i" -gt "0" ] ; then
			echo "Touching $i th sms file"
		fi

		if [ "$outputpart" -ge "$maxsubdir" ] ; then
        	        subdir=$(( ( $i-1 - ($i-1)%$partpersubdir)/$partpersubdir ))
		else
			# if the # of parts <= maxsubdir, then parpersubdir is left empty
			subdir=
		fi

		#echo "$i - $subdir"
		touch $dir/$subdir/$name$(($i-1)).sms
	done

	echo "The geom#.sms files have been touched"
fi


# touch the restart files - always
dir=$outputpart-procs_case
mkdir $dir

if [ "$outputpart" -gt "$maxsubdir" ] ; then
	for (( i=0; i<$(($maxsubdir)); i++))  ; do
		mkdir $dir/$i
	done
fi

for (( i=1; i<=$(($outputpart)); i++))  ; do
	if [ "$(($i % 16384))" -eq "0" -a "$i" -gt "0" ] ; then
		echo "Touching $i th phasta files"
	fi

	if [ "$outputpart" -ge "$maxsubdir" ] ; then
                subdir=$(( ( $i-1 - ($i-1)%$partpersubdir)/$partpersubdir ))
	else
		# if the # of parts <= maxsubdir, then parpersubdir is left empty
		subdir=
	fi

	#echo "$i - $subdir"
	touch $dir/$subdir/restart.$timestep.$i &
	touch $dir/$subdir/geombc.dat.$i
done
echo "The restart.$timestep.# and geombc.dat.# files have been touched"


