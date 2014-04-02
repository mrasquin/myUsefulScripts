#!/bin/bash -l

dirname=$1
firstdir=$2
lastdir=$3
operation=$4
maxtar=$5

print_usage()                                                                                  
{
   echo "Usage: $0"                                                                 
   echo "<directory (should start with ###-procs_case or ###-sms)> <firstdir (integer)> <lastdir (integer)> <operation (tar or tgz)> <maxtar>" 
}  


### Check the input
if [ "x$dirname" == "x" ]; then
	echo 'Specify the dirname (proc_case or sms) directory'
	print_usage
	exit 1
fi

if [ "x$firstdir" == "x" ]; then
	echo 'Specify the first dir id you want to tar'
	print_usage
	exit 1
fi

if [ "x$lastdir" == "x" ]; then
	echo 'Specify the last dir id you want to tar'
	print_usage
	exit 1
fi

if [ "x$operation" == "x" ]; then
	echo 'Specify the operation applied to the directory (tar or tgz)'
	print_usage
	exit 1
fi

if [ "x$maxtar" == "x" ]; then
	echo 'Specify the maximum numnber of tar operation allowed at the same time'
	print_usage
	exit 1
fi


nparts=`echo $dirname | awk -F \- '{print $1}'`
echo "the number of parts is $nparts"

if [ -d $dirname ] ; then

	# Change directory
	cd $dirname

	# Count the number of directories starting from [0-9] and not including [a-z], nor [A-Z]
	#nsubdir=`find . -maxdepth 1 -type d -name "[0-9]*" ! -name "*[a-z]*" ! -name "*[A-Z]*" | wc -l`
	nsubdir=2048

	topic=`echo $dirname | grep procs_case`
	if [ "x$topic" == "x" ]; then # Not a procs_case directory (sms? smd?) -> 1 file per part
		nfilesindirexpect=$(($nparts/$nsubdir))
	else # This is a procs_case -> 2 files per part (geombc and restart)
		nfilesindirexpect=$(($nparts*2/$nsubdir))
	fi
	#echo $nfilesindirexpect $topic

	for (( i=$firstdir; i<=$(($lastdir)); i++))  ; do

		# Check how many processes are running and sleep if the limit has been reached
		tarprocess=`ps aux | grep mrasquin | grep tar | grep -v tarsubdir | grep -v vim | grep -v 'grep' | wc -l`
		#echo "tarprocess: $tarprocess - i: $i - maxtar: $maxtar"
		while [ "$tarprocess" -ge "$maxtar" ]; do
			#echo "while loop: tarprocess: $tarprocess - i: $i - maxtar: $maxtar"
  			sleep 15
			tarprocess=`ps aux | grep mrasquin | grep tar | grep -v tarsubdir | grep -v vim | grep -v 'grep' | wc -l`
		done  

		nfilesindir=`find $i -name 'restart*' -o -name 'geombc*' -o -name 'geom*.sms' | wc -l`

		if [ "$nfilesindir" -ne "$nfilesindirexpect" ] ; then
  			echo "ERROR: Number of files in subdir does not match in subdir $i: $nfilesindir - $nfilesindirexpect"
		else
			echo "Tarring subdir $i with $nfilesindir files"
			if [ "$operation" == "tar" ] ; then 
				#echo TAR
				tar -cf $i.tar $i &
			elif [ "$operation" == "tgz" ] ; then 
				#echo TGZ
				#(sleep 10 &)
				tar -czf $i.tgz $i &
			else 
				echo "Operation not listed"
			fi
		fi
        done

else
	echo "$dirname not found"
fi


