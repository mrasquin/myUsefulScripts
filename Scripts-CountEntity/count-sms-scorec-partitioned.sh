# NOTE: SCRIPT NEEDS TO BE UPDATED 

# Give the name of the proc case dir
nparts=$1
nargs=1

echo 'This script counts elements without disctinction of topology'

function die() {
echo -e "${1}"
exit 1
}

# check that user entered proper number of args
if [[ "${#}" -ne "$nargs" ]]
then
die "\n Check usage: \n  $0\n  < nsms files in the current directory >\n"
fi


#Get the number of parts from ##-procs_case dir
#nparts=`echo $dir | awk -F - '{print $1}' `

echo "Output files will be appended with $nparts"

nsmsfile=$nparts
echo  "We suppose there are $nsmsfile geombc files in this directory" 

rm ~/numElm_sms_$nparts.dat
rm ~/numNod_sms_$nparts.dat

for i in `seq 0 1 $(($nsmsfile-1))`;
do
	echo "Considering geomi_$i.sms"

	fileid=$((($i-1)/1024+1))

	linesread=`awk 'NR==2{print;exit}' geom$i.sms | awk '{print $3}'`
	linestoskip=$(($linesread+3))
	#echo $linestoskip
	awk 'NR=='$linestoskip'{print;exit}' geom$i.sms | awk '{print $1}' >> numElm_$fileid.dat
	awk 'NR=='$linestoskip'{print;exit}' geom$i.sms | awk '{print $5}' >> numNod_$fileid.dat

	#grep -a 'number of interior elements :' geombc.dat.$i | awk '{print $9}' | head -1 >> numElm_$fileid.dat
	#grep -a 'number of nodes :' geombc.dat.$i | awk '{print $8}' | head -1 >> numNod_$fileid.dat


done

nfiles=$((nparts/1024))
for i in `seq 1 1 $nfiles`; do cat numElm_$i.dat  >> ~/numElm_sms2_$nparts.dat ; done
for i in `seq 1 1 $nfiles`; do cat numNod_$i.dat  >> ~/numNod_sms2_$nparts.dat ; done

