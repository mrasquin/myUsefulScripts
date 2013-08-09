#!/bin/bash

nargs=2

print_usage()                                                                                  
{
   echo "Usage: $0 <X> <Y>"
   echo " <X>: geometric model"
   echo " <Y>: attribute file"
   echo " Note: soft add +simmodsuite-9.0-130715 if not already done to build the face property files"
}  

if [ "$#" -ne "$nargs" ] ; then
	print_usage
        exit 1
fi

modelfile=$1
attribfile=$2

echo
echo "Running BL mesher (make sure to check $logfile)..."

if [[ $modelfile == *.x_t ]] || [[ $modelfile == *.xmt_txt ]] || [[ $modelfile == *.X_T ]] || [[ $modelfile == *XMT_TXT ]] ; then
	#executable=BLMesher-O-parasolid-9.0-130715
	executable=BLMesher-O-parasolid-9.0-130805beta
elif [[ $modelfile == *.sat ]] || [[ $modelfile == *.SAT ]] ; then
	#executable=BLMesher-O-acis-9.0-130715
	executable=BLMesher-O-acis-9.0-130805beta
else
	echo File extension unknown for $modelfile
	exit 1
fi
/users/mrasquin/develop/Meshing/BLMesher/bin/x86_64_linux/$executable $modelfile geom_ver63.sms 2 1.0 $attribfile > BLMesher.log 2>&1


