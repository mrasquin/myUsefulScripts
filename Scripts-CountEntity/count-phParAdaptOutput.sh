# Give the name of the output file from a phParAdapt runs
outputfile=$1

### Check the input
if [ "x$outputfile" == "x" ]; then
	echo 'Specify the output file'
	exit 1
fi

grep 'MeshInfo' $outputfile > meshInfo.dat
grep nodes meshInfo.dat | awk '{print $3, $6}'| sort -n | awk '{print $2}' > numNod.dat
grep elms meshInfo.dat | awk '{print $3, $6}'| sort -n | awk '{print $2}' > numElm.dat
