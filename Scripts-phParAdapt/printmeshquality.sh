#!/bin/bash

inputfile=$1

print_usage()                                                                                  
{
   echo "Usage: $0"                                                                 
   echo "<inputfile> (output file from a phParAdapt run)"
}  


# Check the input
if [ "x$inputfile" == "x" ]; then
	echo "Specify the input file"
	print_usage
	exit 1
fi


echo ""

# This will get search for the lines containing for instance
# MeshInfo: part 3256 - nodes 2358
# MeshInfo: part 3256 - elms 10909
# and compute the avg number of nodes and elms per part, along with the elm and node imbalance

cat $inputfile | grep ' - nodes ' | awk '{sum=sum+$6}{i=i+1}{if($6>max) max=$6} END {print "avg vtx=",sum/i,"- max vtx=",max,"- imbalance vtx=",max/(sum/i)}'

cat $inputfile= | grep ' - elms '  | awk '{sum=sum+$6}{i=i+1}{if($6>max) max=$6} END {print "avg rgn=",sum/i,"- max rgn=",max,"- imbalance rgn=", max/(sum/i)}'
