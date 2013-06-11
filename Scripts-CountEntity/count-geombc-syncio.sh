# Give the name of the proc case dir
dir=$1
nargs=1

echo 'This script counts elements without disctinction of topology'

function die() {
echo -e "${1}"
exit 1
}

# check that user entered proper number of args
if [[ "${#}" -ne "$nargs" ]]
then
die "\n Check usage: \n  $0\n  < ##procs_case >\n"
fi

#Get the number of parts from ##-procs_case dir
nparts=`echo $dir | awk -F - '{print $1}' `

echo "Output files will be appended with $nparts"

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

cd $dir

ngeombcfile=`ls geombc* | wc -l`
echo  "There are $ngeombcfile geombc files in this directory" 

numpartperfile=$((nparts/$ngeombcfile))
echo "There are $numpartperfile parts per file"


#for i in `seq 1 1 $ngeombcfile`; do
for (( i=1; i<=$(($ngeombcfile)); i++)); do
	echo "Considering geombc-dat.$i"
	
	if [ -e grep_elm_geombc$i.dat ]; then

		echo "File grep_elm_geombc$i.dat already exist"

	else
		grep -a 'number of interior elements@' geombc-dat.$i > grep_elm_geombc$i.dat
		grep -a 'number of nodes@' geombc-dat.$i > grep_nod_geombc$i.dat

	fi	


	startpart=$((($i-1)*$numpartperfile+1))
	endpart=$(($i*$numpartperfile))
	echo "  geombc-dat.$i contains parts $startpart - $endpart"

	#for j in `seq $startpart 1 $endpart`;
	#do
	#	grep -m 1 "number of interior elements@$j : " grep_elm_geombc$i.dat | awk '{print $9}' >> ~/numElm_$nparts_$i.dat
	#	grep -m 1 "number of nodes@$j : <" grep_nod_geombc$i.dat | awk '{print $8}' >> ~/numNod_$nparts_$i.dat
	#done

	cat grep_elm_geombc$i.dat | sed 's/number of interior elements@//g' | sort -n | awk '{print $6}' > numElm_$nparts-$i.dat
	cat grep_nod_geombc$i.dat | sed 's/number of nodes@//g' | sort -n | awk '{print $6}' > numNod_$nparts-$i.dat

done

for i in `seq 1 1 $ngeombcfile`; do cat numElm_$nparts-$i.dat  >> $dir_current/numElm_$nparts.dat  ; done
for i in `seq 1 1 $ngeombcfile`; do cat numNod_$nparts-$i.dat  >> $dir_current/numNod_$nparts.dat ; done

rm grep_elm_geombc*.dat
rm grep_nod_geombc*.dat
rm numElm_$nparts*.dat
rm numNod_$nparts*.dat



