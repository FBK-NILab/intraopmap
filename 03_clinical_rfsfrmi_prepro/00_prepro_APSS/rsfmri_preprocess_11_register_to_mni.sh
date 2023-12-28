#!/bin/bash

# This script performs nuisance regression and bandpass filtering as implemented by AFI's 3dTproject (i.e simultaneous regression and bp).
# Volumes flagged for high motion are interpolated before the regression
# time series are normalized to have sum of squares = 1
# -----------------------------------------------------------
# Script written by Ludovico Coletta, NILAB, FBK (2022)
# -----------------------------------------------------------

function register_to_mni {

    ts=$1
    study_folder=$2
    
    subject_epi=$(basename $ts _regressed_bp.nii.gz)
    sub_folder_epi=$(dirname $ts)
    
    reg_t1_mni_matrix=$(echo ${sub_folder_epi}/../anat/*to_MNI.mat)
    subject_t1=$(basename $reg_t1_mni_matrix _to_MNI.mat)
    sub_folder_t1=$(dirname $reg_t1_mni_matrix)


    convert_xfm -omat ${sub_folder_epi}/${subject_epi}_epi_to_mni.mat -concat $reg_t1_mni_matrix ${sub_folder_epi}/${subject_epi}_epi_to_t1.mat
    
    #applyxfm4D \
    #     $ts \
    #     $PWD/${study_folder}/templates/MNI152_T1_2mm_masked.nii.gz \
    #     ${sub_folder_epi}/${subject_epi}_to_mni_2mm.nii.gz \
    #     ${sub_folder_epi}/${subject_epi}_epi_to_mni.mat \
    
    flirt \
    -in $ts \
    -ref $PWD/${study_folder}/templates/MNI152_T1_2mm_masked_freesurfer.nii.gz \
    -applyxfm -init ${sub_folder_epi}/${subject_epi}_epi_to_mni.mat \
    -interp spline \
    -out ${sub_folder_epi}/${subject_epi}_to_mni_2mm.nii.gz \
    &> ${sub_folder_epi}/log_${subject_epi}_to_mni.txt
         
                         
    }
export -f register_to_mni

# main code starts here
numjobs=2

study_folder=IntraOpMap_RestingState #EDIT HERE

echo $PWD/${study_folder}/derivatives/CustomPrepro/Pre/sub-*/func/*_regressed_bp.nii.gz | tr " " "\n" > subject_list.txt #EDIT HERE

parallel \
    -j $numjobs \
    register_to_mni {} $study_folder \
    < subject_list.txt


