#!/bin/bash

function reg_linear_flirt {

    image_original=$1
    study_folder=$2
    
    sub_name=$(basename $image_original _masked.nii.gz)
    fold_name=$(dirname $image_original)
    
    flirt \
       -in $image_original \
       -ref $PWD/${study_folder}/templates/MNI152_T1_2mm_masked_freesurfer.nii.gz \
       -omat ${fold_name}/${sub_name}_to_MNI.mat
    
    
    flirt \
       -in $image_original \
       -ref $PWD/${study_folder}/templates/MNI152_T1_2mm_masked_freesurfer.nii.gz \
       -applyxfm -init ${fold_name}/${sub_name}_to_MNI.mat \
       -out ${fold_name}/${sub_name}_to_MNI_flirt.nii.gz        
    }
    
export -f reg_linear_flirt

#### Script starts here #####

numjobs=8

study_folder=IntraOpMap_RestingState
echo $PWD/${study_folder}/derivatives/CustomPrepro/Pre/sub-*/anat/*masked.nii.gz | tr " " "\n" > path_to_images.txt

parallel \
         -j $numjobs \
         reg_linear_flirt {} $study_folder \
         < $PWD/path_to_images.txt


