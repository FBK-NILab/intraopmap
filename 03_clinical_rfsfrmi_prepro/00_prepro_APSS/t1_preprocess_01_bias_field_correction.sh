#!/bin/bash

# Bias field correction of the T1 image using the N4 alg. provided by ANTs
# Input: t1 raw image. BIDS like dataset structure is expected
# -----------------------------------------------------------
# Script written by Ludovico Coletta
# NILAB, FBK (2022)
# -----------------------------------------------------------

function bias_field_correction {

    sub_folder=$1
    t1_img=${sub_folder}/Pre/anat/${sub_folder}_pre_T1w.nii.gz
    
    subject=$(basename $t1_img .nii.gz)

    N4BiasFieldCorrection \
      -d 3 \
      -i $t1_img \
      -o $PWD/derivatives/CustomPrepro/Pre/${sub_folder}/anat/${subject}_N4.nii.gz \
      -v \
      &> $PWD/derivatives/CustomPrepro/Pre/${sub_folder}/anat/log_${subject}_N4.txt
     
}
export -f bias_field_correction

########## main code starts here ##########


study_folder=IntraOpMap_RestingState #EDIT HERE
numjobs=2 #EDIT HERE

cd ${study_folder}

echo sub-* | tr " " "\n" > subject_list.txt
parallel \
    -j $numjobs \
    bias_field_correction {} \
    < subject_list.txt
