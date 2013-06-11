#!/bin/bash

list=`find *-PartLocal-* -maxdepth 1 -name '*.output'`

outputfile=result.dat
if [ -e $outputfile ] ; then
	rm $outputfile
fi


imbalance16k='16 1.053118 1.045440 1.047330  1.049031'

for file in $list ; do
	case=`echo $file | awk -F \/ '{print $1}'`
	echo "$case ($file)" >> $outputfile

        parts=`echo $file | awk -F \- '{print $1}' | sed 's/k//g'`
	#imbalance=`grep 'Max im' $file | awk '{print $parts $10, $15, $20, $25}'`
	echo "parts vtx edge face elm" >> $outputfile 
	echo $imbalance16k >> $outputfile
	grep 'Max im' $file | awk -v VAR=$parts '{print VAR, $10, $15, $20, $25}' >> $outputfile 

	echo "" >> $outputfile
done
