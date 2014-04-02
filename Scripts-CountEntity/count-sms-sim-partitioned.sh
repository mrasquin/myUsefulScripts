#!/bin/bash

# Give the name of the proc case dir
dir_sms=$1
nparts=$2
nargs=2

echo 'This script counts elements without disctinction of topology'

function die() {
echo -e "${1}"
exit 1
}

# check that user entered proper number of args
if [[ "${#}" -ne "$nargs" ]] ; then 
	die "\n Check usage: \n  $0\n <sms directory>\n <nsms files in the sms directory>\n"
fi

#Get the number of parts from ##-procs_case dir
#nparts=`echo $dir | awk -F - '{print $1}' `

echo "Output files will be appended with $nparts"

nsmsfile=$nparts
echo  "We suppose there are $nsmsfile sms files in this directory" 

# Output files

fileElm=numElm_$nparts.dat
fileNod=numNod_$nparts.dat

dir_current=`pwd`

# Clean potential existing output files (Very important since we append the results)
if [ -e $dir_current/$fileElm ] ; then
	rm $dir_current/$fileElm
fi

if [ -e $dir_current/$fileNod ] ; then
	rm $dir_current/$fileNod
fi

# We go to the sms directory now
cd $dir_sms

for i in `seq 0 1 $(($nsmsfile-1))`;
do
	if [ "$i" -eq "0" ] ; then 
		smsfile=sms
	else
		smsfile=sms.$i
	fi

	echo "Considering $smsfile"

	fileid=$((($i-1)/1024+1))

	sed -n 4p $smsfile | awk '{print $1}' >> numElm_$fileid.dat
	sed -n 4p $smsfile | awk '{print $4}' >> numNod_$fileid.dat

done

nfiles=$((nparts/1024))
if [ $nfiles -ge "1" ]; then
	for i in `seq 1 1 $nfiles`; do cat numElm_$i.dat  >> $dir_current/numElm_$nparts.dat ; done
	for i in `seq 1 1 $nfiles`; do cat numNod_$i.dat  >> $dir_current/numNod_$nparts.dat ; done
	rm numElm*
	rm numNod*
else
	mv numElm_1.dat $dir_current/numElm_$nparts.dat
	mv numNod_1.dat $dir_current/numNod_$nparts.dat
fi

