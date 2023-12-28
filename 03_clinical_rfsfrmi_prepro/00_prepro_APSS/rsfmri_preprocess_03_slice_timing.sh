#!/bin/bash

# This script carries out slice timing correction using AFNI's 3dTshift command

# Required inputs: despiked ts ad the json file coming from the dicom to nifti conversion and containing the "SliceTiming" field. 
                  


# EDIT the TR (in seconds)

# The tools jq is needed. For Ubuntu: sudo apt-get install jq
# -----------------------------------------------------------
# Script written by Ludovico Coletta @NILAB (FBK)
# (2022)
# -----------------------------------------------------------

function slt {
    
    sub_folder=$1
       
    ts=$PWD/derivatives/CustomPrepro/Pre/${sub_folder}/func/${sub_folder}_pre_rest_run-01_bold_despike.nii.gz #EDIT _pre_rest_run-01_bold_despike.nii.gz

    cat ${sub_folder}/Pre/func/${sub_folder}_pre_rest_run-01_bold.json | jq '."SliceTiming"' | tr -d '[]' > $PWD/derivatives/CustomPrepro/Pre/${sub_folder}/func/${sub_folder}_SliceTiming.txt
    
    # EDIT the TR
    3dTshift \
        -TR 2.6 \
        -prefix $PWD/derivatives/CustomPrepro/Pre/${sub_folder}/func/${sub_folder}_pre_rest_run-01_bold_slt.nii.gz \
        -wsinc9 \
        -tpattern @$PWD/derivatives/CustomPrepro/Pre/${sub_folder}/func/${sub_folder}_SliceTiming.txt \
        -verbose \
        $ts \
        &> $PWD/derivatives/CustomPrepro/Pre/${sub_folder}/func/log_${sub_folder}_pre_rest_run-01_bold_slt.txt

    }
export -f slt

# main code starts here

study_folder=IntraOpMap_RestingState #EDIT HERE
numjobs=7 #EDIT HERE

cd ${study_folder}

echo sub-* | tr " " "\n" > subject_list.txt

parallel \
    -j $numjobs \
    slt \
    < subject_list.txt 


