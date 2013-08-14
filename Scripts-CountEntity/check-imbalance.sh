# Give the name of the proc case dir
nparts=$1
nargs=1

echo 'This script evaluates the mesh imbalance in terms of elements and nodes'
echo 'Notes: this script reads numElm*.dat and numNod*.dat produced by one of the count-* scripts'

function die() {
echo -e "${1}"
exit 1
}

# check that user entered proper number of args
if [[ "${#}" -ne "$nargs" ]]
then
die "\n Check usage: \n  $0\n  <numpart>\n"
fi

#Get the number of parts from ##-procs_case dir

fileElm=numElm_$nparts.dat
fileNod=numNod_$nparts.dat

cat $fileElm | awk '{if($1>max) max=$1 ; sum+=$1} END {print "Number of parts:",NR, " - Tot elm:", sum, "- Max elm:", max, "- Avg elm:", sum/NR, "Elm imb=", max/sum*NR}'
cat $fileNod | awk '{if($1>max) max=$1 ; sum+=$1} END {print "Number of parts:",NR, " - Tot Nod:", sum, "- Max nod:", max, "- Avg nod:", sum/NR, "Nod imb=", max/sum*NR}'
