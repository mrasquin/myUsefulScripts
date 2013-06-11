# Give the name of the proc case dir
outputfile=$1

#Get the number of parts from ##-procs_case dir
nparts=`grep 'numnp before Boundary Modification' $outputfile | wc -l | sed -e 's/^[ \t]*//' `

echo "Output files will be appended with $nparts"

grep 'numnp before Boundary Modification:' $outputfile | awk '{print $6} ' > numNod_$nparts-BeforeParma.dat   
grep 'numnp after Boundary Modification:' $outputfile | awk '{print $6} ' > numNod_$nparts-AfterParma.dat   
grep 'numRgn before Boundary Modification:' $outputfile | awk '{print $6} ' >  numElm_$nparts-BeforeParma.dat   
grep 'numRgn after Boundary Modification:' $outputfile | awk '{print $6} ' >  numElm_$nparts-AfterParma.dat   



