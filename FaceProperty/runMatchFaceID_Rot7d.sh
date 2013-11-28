#!/bin/bash 

nargs=3
print_usage()                                                                                  
{
   echo "Usage: $0 <X> <Y> <Z>"
   echo " <X>: Old geometric model"
   echo " <Y>: New geometric model"
   echo " <Z>: Old BLattr.inp file to recycle"
   echo " Note: soft add +simmodsuite-9.0-130715 if not already done to build the face property files"
}  

if [ "$#" -ne "$nargs" ] ; then
	print_usage
        exit 1
fi

oldModelFile=$1
newModelFile=$2
attribfile=$3

# parasolid and acis kernel, along with the license file (this should really be added through soft if it not already done)
#export LD_LIBRARY_PATH = ${LD_LIBRARY_PATH}:/usr/local/simmetrix/simmodsuite/9.0-130715/lib/x64_rhel5_gcc41/acisKrnl:/usr/local/simmetrix/simmodsuite/9.0-130715/lib/x64_rhel5_gcc41/psKrnl
#export SIM_LICENSE_FILE = /usr/local/meshSim/UCBoulder

# Build the face property list for the old model
fnameFacePropertyOld='facePropFileOld.dat' #Do not change this name, or modify MathFaceID.m accordingly
if [ -e $fnameFacePropertyOld ] ; then
	echo "file $fnameFacePropertyOld already exists. Skypping the construction of the face property list"
else
	if [[ $oldModelFile == *.x_t ]] || [[ $oldModelFile == *.xmt_txt ]] || [[ $oldModelFile == *.X_T ]] || [[ $oldModelFile == *XMT_TXT ]] ; then
		executable=FaceProperty-O-parasolid
	elif [[ $oldModelFile == *.sat ]] || [[ $oldModelFile == *.SAT ]] ; then
		executable=FaceProperty-O-acis
	else
		echo File extension unknown for $oldModelFile
		exit 1
	fi
	/users/mrasquin/develop/Meshing/FacePropertyRot7d/bin/x86_64_linux/$executable $oldModelFile $fnameFacePropertyOld
fi
cp $fnameFacePropertyOld $fnameFacePropertyOld-ORIG
sed -i '1d' $fnameFacePropertyOld


# Build the face property list for the new model
fnameFacePropertyNew='facePropFileNew.dat' #Do not change this name, or modify MathFaceID.m accordingly
if [ -e $fnameFacePropertyNew ] ; then
	echo "file $fnameFacePropertyNew already exists. Skypping the construction of the face property list"
else
	if [[ $newModelFile == *.x_t ]] || [[ $newModelFile == *.xmt_txt ]] || [[ $newModelFile == *.X_T ]] || [[ $newModelFile == *XMT_TXT ]] ; then
		executable=FaceProperty-O-parasolid
	elif [[ $newModelFile == *.sat ]] || [[ $newModelFile == *.SAT ]] ; then
		executable=FaceProperty-O-acis
	else
		echo File extension unknown for $newModelFile
		exit 1
	fi
	/users/mrasquin/develop/Meshing/FaceProperty/bin/x86_64_linux/$executable $newModelFile $fnameFacePropertyNew
fi
cp $fnameFacePropertyNew $fnameFacePropertyNew-ORIG
sed -i '1d' $fnameFacePropertyNew

# Get the mapping between old and new faces
#export MATLABPATH=$PWD 
export MATLABPATH='/users/mrasquin/myUsefulScripts/FaceProperty' #Path to the official version of the matlab script MatchFaceID
#export MATLABPATH='/users/mrasquin/Models/DLRF11/Baseline14_7d/facematching' #Path to the official version of the matlab script MatchFaceID
/opt/matlab/R2013a/bin/matlab -nodesktop -nosplash -nodisplay -r "MatchFaceID('$PWD','$fnameFacePropertyOld','$fnameFacePropertyNew'); quit;"

# Build the output file that recycles BLattr.inp
/users/mrasquin/myUsefulScripts/FaceProperty/SwitchAttribFileFaces.rb MatchFaceID.dat $attribfile

# Some cleaning
mv $fnameFacePropertyOld-ORIG $fnameFacePropertyOld
mv $fnameFacePropertyNew-ORIG $fnameFacePropertyNew

exit 0


