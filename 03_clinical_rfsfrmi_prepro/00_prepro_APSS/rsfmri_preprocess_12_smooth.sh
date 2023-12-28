#!/bin/bash

# This script smooths the ts with a gaussian kernel of 4mm
#
# -----------------------------------------------------------
# Script written by Ludovico Coletta, NILAB, FBK (2022)
# -----------------------------------------------------------

function smooth {

    ts=$1
    study_folder=$2
    
    subject_epi=$(basename $ts _to_mni_2mm.nii.gz)
    sub_folder_epi=$(dirname $ts)
    
    kernel=4
    brainmask=$PWD/${study_folder}/templates/GM_cort_subcort_mask_2mm.nii.gz # edit this

    3dBlurInMask \
        -input $ts \
        -prefix ${sub_folder_epi}/${subject_epi}_smoothed.nii.gz \
        -mask $brainmask \
        -FWHM $kernel \
        -preserve \
        &> ${sub_folder_epi}/log_${subject_epi}_smoothing.txt
        
        
    fslmaths \
         ${sub_folder_epi}/${subject_epi}_smoothed.nii.gz \
          -mul $PWD/${study_folder}/templates/GM_cort_subcort_mask_plus_brain_mask_freesurfer.nii.gz \
          ${sub_folder_epi}/${subject_epi}_smoothed.nii.gz
                
    }
export -f smooth

# Main code starts here
numjobs=1

study_folder=IntraOpMap_RestingState #EDIT HERE

echo $PWD/${study_folder}/derivatives/CustomPrepro/Pre/sub-*/func/*_to_mni_2mm.nii.gz | tr " " "\n" > subject_list.txt #EDIT HERE

parallel \
    -j $numjobs \
    smooth {} $study_folder \
    < subject_list.txt
