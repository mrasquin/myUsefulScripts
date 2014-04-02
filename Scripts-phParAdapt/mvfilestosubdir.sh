#!/bin/bash -l

nparts=$1
 
print_usage()                                                                                  
{
   echo "Usage: $0"                                                                 
   echo "<nparts>"
}  


### Check the input
if [ "x$nparts" == "x" ]; then
	echo 'Specify the number of parts for the proc_case and sms directories'
	print_usage
	exit 1
fi



### Start with the procs_case directory
dirname=$nparts-procs_case

if [ -d $dirname ] ; then

	# Change directory
	cd $dirname

	# Count the number of directories starting from [0-9] and not including [a-z], nor [A-Z]
	#nsubdir=`find . -maxdepth 1 -type d -name "[0-9]*" ! -name "*[a-z]*" ! -name "*[A-Z]*" | wc -l`
	nsubdir=2048
	for (( i=0; i<$(($nsubdir)); i++))  ; do
		mkdir -p $i
        done
	echo "$nsubdir subdirectories created in $dirname"

	if [ "$nsubdir" -gt "0" ] ; then

		# Count the number of geombc files in the directory nsubdir-1
		#ngeombcperdir=`ls -f $(($nsubdir-1))/geombc.dat.* | wc -l`
		ngeombcperdir=$(($nparts/$nsubdir))
		echo "$ngeombcperdir gemobc and $ngeombcperdir restart files in each directory"

		# We assume there is the same number of phasta files in each directory
		ngeombc=$(($ngeombcperdir*$nsubdir))

		if [ "$ngeombc" -ne "$nparts" ] ; then
  			echo "nparts from command line and ngeombc do not match: $ngeombc - $nparts"
			exit 1	
		fi

		ngeombcrestart=$(($ngeombc*2))
		echo "$ngeombcrestart phasta files in total to move"

		#read -p "Ready to move $ngeombcrestart phasta files from $nsubdir subdirectories to $dirname ? (y/n): " resp
		resp="y"
		if [ $resp == "y" ] ; then
	
			# Start moving files	
			for (( i=0; i<$(($nsubdir)); i++))  ; do
				firstid=$(($i*$ngeombcperdir+1))
				lastid=$((($i+1)*$ngeombcperdir))
				echo "Moving files "$firstid - $lastid" to directory $i"
				if [ -d $i ] ; then
					for (( j=$firstid; j<=$(($lastid)); j++))  ; do
						mv geombc.dat.$j restart.12000.$j $i
					done
				else
					echo "Directory $i does not exist. Abord!"
				fi

			done

		else
			echo "Quiting the script now"
		fi
	else
		echo "No subdirectory found in $dirname - Quiting the script now"
	fi
	cd ..
else
	echo "$dirname not found"
fi


### Then check the sms directory
dirname=$nparts-sms
if [ -d $dirname ] ; then

	# Change directory
	cd $dirname

	# Count the number of directories starting from [0-9] and not including [a-z], nor [A-Z]
	#nsubdir=`find . -maxdepth 1 -type d -name "[0-9]*" ! -name "*[a-z]*" ! -name "*[A-Z]*" | wc -l`
	nsubdir=2048
	for (( i=0; i<$(($nsubdir)); i++))  ; do
		mkdir -p $i
        done
	echo "$nsubdir subdirectories created in $dirname"

	if [ "$nsubdir" -gt "0" ] ; then

		# Count the number of geombc files in the directory nsubdir-1
		#nmeshfileperdir=`ls -f $(($nsubdir-1))/geombc.dat.* | wc -l`
		nmeshfileperdir=$(($nparts/$nsubdir))
		echo "$nmeshfileperdir mesh files in each directory"

		# We assume there is the same number of phasta files in each directory
		nmesh=$(($nmeshfileperdir*$nsubdir))

		if [ "$nmesh" -ne "$nparts" ] ; then
  			echo "nparts from command line and nmesh do not match: $nmesh - $nparts"
			exit 1	
		fi

		echo "$nmesh files in total to move"

		#read -p "Ready to move $mesh mesh files from $nsubdir subdirectories to $dirname ? (y/n): " resp
		resp="y"
		if [ $resp == "y" ] ; then
	
			# Start moving files	
			for (( i=0; i<$(($nsubdir)); i++))  ; do
				firstid=$(($i*$nmeshfileperdir))
				lastid=$((($i+1)*$nmeshfileperdir-1))
				echo "Moving files "$firstid - $lastid" to directory $i"
				if [ -d $i ] ; then
					for (( j=$firstid; j<=$(($lastid)); j++))  ; do
						mv geom$j.sms $i
					done
				else
					echo "Directory $i does not exist. Abord!"
				fi

			done

		else
			echo "Quiting the script now"
		fi
	else
		echo "No subdirectory found in $dirname - Quiting the script now"
	fi
	cd ..
else
	echo "$dirname not found"
fi

