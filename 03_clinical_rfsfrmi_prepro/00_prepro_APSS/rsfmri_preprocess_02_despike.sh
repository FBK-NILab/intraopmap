#!/bin/bash

# This script despikes the ts. 
#
# https://www.sciencedirect.com/science/article/pii/S1053811914001578#f0090
#
# -----------------------------------------------------------
# Script written by Ludovico Coletta @NILAB (FBK)
# (2022)
# -----------------------------------------------------------

function despike_subject {

    ts=$1
    subject=$(basename $ts _chopped.nii.gz)
    sub_folder=$(dirname $ts)
    
    3dDespike \
        -nomask \
        -prefix ${sub_folder}/${subject}_despike.nii.gz \
        -NEW \
        -localedit \
        $ts \
        &> ${sub_folder}/log_${subject}_despiking.txt	
	
}
export -f despike_subject

# main code starts here
study_folder=IntraOpMap_RestingState #EDIT HERE
numjobs=8 #EDIT HERE

echo $PWD/${study_folder}/derivatives/CustomPrepro/Pre/sub-*/func/*_chopped.nii.gz | tr " " "\n" > subject_list.txt #EDIT HERE

parallel \
    -j $numjobs \
    despike_subject {} \
    < subject_list.txt
