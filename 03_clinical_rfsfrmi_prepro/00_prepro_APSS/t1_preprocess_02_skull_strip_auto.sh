#!/bin/bash

# Auto skull stripping via Freesurfer's mri_synthstrip command. You need parallel (sudo apt-install parallel) and Freesurfer to be installed on your pc

function auto_sk {

   image_original=$1
   
   file_name=$(basename $image_original _N4.nii.gz)
   fold_name=$(dirname $image_original)
    
    mri_synthstrip \
       -i $image_original \
       -m ${fold_name}/${file_name}_brain_mask.nii.gz \
       -o ${fold_name}/${file_name}_masked.nii.gz \
       &> ${fold_name}/log_${file_name}_sk.txt
      
    }
    
export -f auto_sk

#### Script starts here #####

export FREESURFER_HOME='/home/ludovicocoletta/Tools/Freesurfer/freesurfer' # EDIT HERE

source $FREESURFER_HOME/SetUpFreeSurfer.sh

study_folder=IntraOpMap_RestingState #EDIT HERE
numjobs=1 #EDIT HERE

echo $PWD/${study_folder}/derivatives/CustomPrepro/Pre/sub-*/anat/*N4.nii.gz | tr " " "\n" > subject_list.txt #EDIT HERE


parallel \
    -j $numjobs \
    auto_sk {} \
    < subject_list.txt
