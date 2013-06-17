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
	nsubdir=`find . -maxdepth 1 -type d -name "[0-9]*" ! -name "*[a-z]*" ! -name "*[A-Z]*" | wc -l`
	echo "$nsubdir subdirectories in $dirname"

	if [ "$nsubdir" -gt "0" ] ; then

		# Count the number of geombc files in the directory nsubdir-1
		ngeombcperdir=`ls -f $(($nsubdir-1))/geombc.dat.* | wc -l`
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
				if [ "$(($i % 256))" -eq "0" -a "$i" -gt "0" ] ; then
					echo "Moving files from $i"
				fi
				mv $i/geombc.dat.* .
				mv $i/restart.* .
			done

			# Check the number of phasta files moved before removing directories $i
			mvfiles=`find . -maxdepth 1 -type f -name 'restart*' -o -name 'geombc*' | wc -l`
			if [ "$mvfiles" -eq "$ngeombcrestart" ] ; then
				echo "$mvfiles phasta files moved successfully to $dirname"
				for (( i=0; i<$(($nsubdir)); i++))  ; do
					if [ "$(($i % 256))" -eq "0" -a "$i" -gt "0" ] ; then
						echo "Removing $i"
					fi
					rm -rf $i
				done
				echo "[0 - $nsubdir] directories removed in $dirname"
			else
				echo "WARNING!"
				echo "$mvfiles phasta files moved to $dirname"
				echo "$ngeombcrestart phasta files were expected in $dirname"
				echo "Check it!"
			fi
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
	nsubdir=`find . -maxdepth 1 -type d -name "[0-9]*" ! -name "*[a-z]*" ! -name "*[A-Z]*" | wc -l`
	echo "$nsubdir subdirectories in $dirname"

	if [ "$nsubdir" -gt "0" ] ; then

		# Count the number of sms files in the directory nsubdir-1
		nsmsperdir=`ls -f $(($nsubdir-1))/*.sms | wc -l`
		echo "$nsmsperdir sms files in each directory"

		# We assume there is the same number of sms files in each directory
		nsms=$(($nsmsperdir*$nsubdir))

		if [ "$nsms" -ne "$nparts" ] ; then
  			echo "nparts from command line and nsms do not match: $nsms - $nparts"
			exit 1	
		fi

		echo "$nsms sms files in total to move"

		#read -p "Ready to move $nsms sms files from $nsubdir subdirectories to $dirname ? (y/n): " resp
		resp="y"
		if [ $resp == "y" ] ; then
	
			# Start moving files	
			for (( i=0; i<$(($nsubdir)); i++))  ; do
				if [ "$(($i % 256))" -eq "0" -a "$i" -gt "0" ] ; then
					echo "Moving files from $i"
				fi
				mv $i/*.sms .
			done

			# Check the number of phasta files moved before removing directories $i
			mvfiles=`find . -maxdepth 1 -type f -name '*.sms' | wc -l`
			if [ "$mvfiles" -eq "$nsms" ] ; then
				echo "$mvfiles sms files moved successfully to $dirname"
				for (( i=0; i<$(($nsubdir)); i++))  ; do
					if [ "$(($i % 256))" -eq "0" -a "$i" -gt "0" ] ; then
						echo "Removing $i"
					fi
					rm -rf $i
				done
				echo "[0 - $nsubdir] directories removed in $dirname"
			else
				echo "WARNING!"
				echo "$mvfiles phasta files moved to $dirname"
				echo "$nsms sms files were expected in $dirname"
				echo "Check it!"
			fi
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


