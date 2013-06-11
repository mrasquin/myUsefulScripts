# Give the name of the proc case dir
outputfile=$1
append=$2

iline=`grep -n 'complete function migrateMeshEntities' $outputfile | awk -F : '{print $1}'`
tail -n +$iline $outputfile > tmptail
head -n $iline $outputfile > tmphead

#Get the number of parts from ##-procs_case dir
nparts1=`grep 'numnp before Boundary Modification' tmphead | wc -l | sed -e 's/^[ \t]*//' `  
nparts2=`grep 'numnp before Boundary Modification' tmptail | wc -l | sed -e 's/^[ \t]*//' `

echo "$nparts1 parts partitioned in $nparts2 parts"
echo $nparts1
echo $nparts2
echo numNod_$nparts1\_UR\_$nparts2.dat

name=
grep 'numnp before Boundary Modification:' tmphead | awk '{print $6} '  > numNod_$nparts1\_UR\_$nparts2.dat   
grep 'numnp after Boundary Modification:' tmphead | awk '{print $6} '   > numNod_$nparts1\_UR_LB\_$nparts2.dat   
grep 'numRgn before Boundary Modification:' tmphead | awk '{print $6} ' > numElm_$nparts1\_UR\_$nparts2.dat   
grep 'numRgn after Boundary Modification:' tmphead | awk '{print $6} '  > numElm_$nparts1\_UR_LB\_$nparts2.dat   

grep 'numnp before Boundary Modification:' tmptail | awk '{print $6} '  > numNod_$nparts2\_UR_LB_ZoltanLocal.dat   
grep 'numnp after Boundary Modification:' tmptail | awk '{print $6} '   > numNod_$nparts2\_UR_LB_ZoltanLocal_LB.dat   
grep 'numRgn before Boundary Modification:' tmptail | awk '{print $6} ' > numElm_$nparts2\_UR_LB_ZoltanLocal.dat   
grep 'numRgn after Boundary Modification:' tmptail | awk '{print $6} '  > numElm_$nparts2\_UR_LB_ZoltanLocal_LB.dat   


rm tmptail
rm tmphead
