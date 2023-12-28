#!/bin/bash

# This script realigns the mean image of a motion corrected ts to T1 image image of the same subject
# -----------------------------------------------------------
# Script written by Ludovico Coletta
# Nilab, FBK (2022)
# -----------------------------------------------------------

function register_to_struct {

    mean_image=$1
    subject=$(basename $mean_image _mcf_mean_reg.nii.gz)
    sub_folder=$(dirname $mean_image)
    
    # create wm mask
    t1_seg_image=$(echo $sub_folder/../anat/*_seg_res.nii.gz)
    t1_whole_brain=$(echo $sub_folder/../anat/*T1w_N4.nii.gz)
    t1_masked=$(echo $sub_folder/../anat/*masked.nii.gz)
    
    fslmaths $t1_seg_image -thr 2 -uthr 2 -bin ${sub_folder}/wm_1.nii.gz
    fslmaths $t1_seg_image -thr 41 -uthr 41 -bin ${sub_folder}/wm_2.nii.gz
    
    fslmaths ${sub_folder}/wm_1.nii.gz -add ${sub_folder}/wm_2.nii.gz -bin ${sub_folder}/wm_mask.nii.gz
    
    epi_reg \
      --epi=$mean_image \
      --t1=$t1_whole_brain \
      --t1brain=$t1_masked \
      --wmseg=${sub_folder}/wm_mask.nii.gz \
      --out=${sub_folder}/${subject}_epi_to_t1
      
    rm ${sub_folder}/wm_1.nii.gz ${sub_folder}/wm_2.nii.gz

}
export -f register_to_struct

# main code starts here

study_folder=IntraOpMap_RestingState #EDIT HERE
numjobs=6 #EDIT HERE

echo $PWD/${study_folder}/derivatives/CustomPrepro/Pre/sub-*/func/*_mcf_mean_reg.nii.gz | tr " " "\n" > subject_list.txt #EDIT HERE

parallel \
    -j $numjobs \
    register_to_struct {} \
    < subject_list.txt


