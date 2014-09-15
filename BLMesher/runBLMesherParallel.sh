#!/bin/bash

nargs=3

print_usage()                                                                                  
{
   echo "Usage: $0 <X> <Y> <Z>"
   echo " <X>: geometric model"
   echo " <Y>: attribute file"
   echo " <Z>: number of processors"
   echo " Note: soft add +simmodsuite-9.0-140630 if not already done"
   echo " Note: soft add +openmpi-gnu482-1.6.5-thread if not already done"
}  

if [ "$#" -ne "$nargs" ] ; then
	print_usage
        exit 1
fi

modelfile=$1
attribfile=$2
nprocs=$3

echo
echo "Running parallel BL mesher (make sure to check BLMesher.log)..."

if [[ $modelfile == *.x_t ]] || [[ $modelfile == *.xmt_txt ]] || [[ $modelfile == *.X_T ]] || [[ $modelfile == *XMT_TXT ]] ; then
	executable=BLMesher-openmpi-O-parasolid-9.0-140724
elif [[ $modelfile == *.sat ]] || [[ $modelfile == *.SAT ]] ; then
	executable=missing
elif [[ $modelfile == *.smd ]] || [[ $modelfile == *.SMD ]] ; then
	executable=BLMesher-openmpi-O-geomsim-9.0-140724
else
	echo File extension unknown for $modelfile
	exit 1
fi

mpirun -np $nprocs /users/mrasquin/develop/Meshing/BLMesherParallel/bin/x86_64_linux/$executable $modelfile mesh.sms 2 1.0 $attribfile > BLMesher.log 2>&1

