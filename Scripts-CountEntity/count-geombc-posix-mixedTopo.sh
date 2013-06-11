# Give the name of the proc case dir
dir_proccase=$1
nargs=1

echo 'This scripts counts elements with disctinction of topology'

function die() {
echo -e "${1}"
exit 1
}

# check that user entered proper number of args
if [[ "${#}" -ne "$nargs" ]]
then
die "\n Check usage: \n  $0\n  < ##-procs_case >\n"
fi

#Get the number of parts from ##-procs_case dir
nparts=`echo $dir_proccase | awk -F - '{print $1}' `

echo "Output files will be appended with $nparts"


# Output files

fileElm=numElm_$nparts.dat
fileElmTet=numElmTet_$nparts.dat
fileElmWedge=numElmWedge_$nparts.dat
fileElmPyr=numElmPyr_$nparts.dat
fileNod=numNod_$nparts.dat

dir_current=`pwd`

# Clean potential existing output files (Very important since we append the results)
if [ -e $dir_current/$fileElm ] ; then
	rm $dir_current/$fileElm
fi

if [ -e $dir_current/$fileNod ] ; then
	rm $dir_current/$fileNod
fi

if [ -e $dir_current/$fileElmTet ] ; then
	rm $dir_current/$fileElmTet
fi

if [ -e $dir_current/$fileElmWedge ] ; then
	rm $dir_current/$fileElmWedge
fi

if [ -e $dir_current/$fileElmPyr ] ; then
	rm $dir_current/$fileElmPyr
fi

# We go to the proc_case directory now
cd $dir_proccase

ngeombcfile=$nparts
echo  "We suppose there are $ngeombcfile geombc files in this directory" 

rm numElm*.dat
rm numNod*.dat

#for i in `seq 1 1 $ngeombcfile`i ; do
for (( i=1; i<=$(($ngeombcfile)); i++)); do
	echo "Considering geombc-dat.$i"

	fileid=$((($i-1)/1024+1))


	grep -a ' : < ' geombc.dat.$i > grep.dat

	grep -m 1 'number of interior elements :' grep.dat | awk '{print $9}' | head -1 >> numElm_$fileid.dat

	numElmTet=`grep -m 1 'connectivity interior linear tetrahedron' grep.dat | awk '{print $9}' | head -1`
	#echo $numElmTet
	echo $numElmTet >> numElmTet_$fileid.dat

	numElmWedge=`grep -m 1 'connectivity interior linear wedge' grep.dat | awk '{print $9}' | head -1` 
	if [ -z $numElmWedge ] ; then
		numElmWedge=0
	fi
	#echo $numElmWedge
	echo $numElmWedge >> numElmWedge_$fileid.dat

	numElmPyr=`grep -m 1 'connectivity interior linear pyramid' grep.dat | awk '{print $9}' | head -1 `
	if [ -z $numElmPyr ] ; then
		numElmPyr=0
	fi
	#echo $numElmPyr
	echo $numElmPyr >> numElmPyr_$fileid.dat

	grep -m 1 'number of nodes :' grep.dat | awk '{print $8}' | head -1 >> numNod_$fileid.dat

done

nfiles=$((nparts/1024))
if [ $nfiles -ge "1" ]; then
	for i in `seq 1 1 $nfiles`; do cat numElm_$i.dat  >> $dir_current/numElm_$nparts.dat ; done
	for i in `seq 1 1 $nfiles`; do cat numElmTet_$i.dat  >> $dir_current/numElmTet_$nparts.dat ; done
	for i in `seq 1 1 $nfiles`; do cat numElmWedge_$i.dat  >> $dir_current/numElmWedge_$nparts.dat ; done
	for i in `seq 1 1 $nfiles`; do cat numElmPyr_$i.dat  >> $dir_current/numElmPyr_$nparts.dat ; done
	for i in `seq 1 1 $nfiles`; do cat numNod_$i.dat  >> $dir_current/numNod_$nparts.dat ; done
	rm numElm*
	rm numNod*
else
	mv numElm_1.dat $dir_current/numElm_$nparts.dat
	mv numElmTet_1.dat $dir_current/numElmTet_$nparts.dat
	mv numElmWedge_1.dat $dir_current/numElmWedge_$nparts.dat
	mv numElmPyr_1.dat $dir_current/numElmPyr_$nparts.dat
	mv numNod_1.dat $dir_current/numNod_$nparts.dat
fi

rm grep.dat
