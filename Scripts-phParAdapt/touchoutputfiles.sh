#!/bin/bash


inputpart=$1 
outputpart=$2
timestep=$3
writesms=$4
operation=$5

print_usage()                                                                                  
{
   echo "Usage: $0"                                                                 
   echo "<inputpart>"
   echo "<outputpart>"
   echo "<timestep>"
   echo "<writesms> (0 or 1)"
   echo "<operations> (UR, Part, Tet, URPart)"
}  

# Check the input
nargs=5
if [$# -ne $nargs ]; then
	echo "Number of arguments not equal to $nargs"
	print_usage
	exit 1
fi

if [ "x$operation" != "xUR" ] && [ "x$operation" != "xPart" ] && [ "x$operation" != "xTet" ] && [ "x$operation" != "xURPart" ] ; then
        echo "Operation should be either Part, UR, Tet, or URPart"
        print_usage
        exit 1
fi

### touch the output files

# Determine the number of parts per subdirectory
maxsubdir=2048
if [ "$outputpart" -gt "$maxsubdir" ] ; then
	partpersubdir=$(($outputpart / $maxsubdir))
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
	i

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


