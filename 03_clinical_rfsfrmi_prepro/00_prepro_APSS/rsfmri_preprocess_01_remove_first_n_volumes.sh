#!bin/bash

# This script removes the first 4 volumes from timeseries.
# 
# Please remember that 3dTcat counts from 0.

# It is possible to specify a TR (-tr option)

# Input: ts in nifti. BIDS like dataset structure is expected

# -----------------------------------------------------------
# Script written by Ludovico Coletta
# NILAB, FBK (2022)
# -----------------------------------------------------------


function chop_ts {

    sub_folder=$1
       
    ts=${sub_folder}_pre_rest_run-01_bold.nii.gz #EDIT _pre_rest_run-01_bold.nii.gz
    
    # REMOVE OR EDIT "CustomPrepro/Pre" from the following command, as it refers to the preoperative session for patients with tumour
    # CHANGE TR
    # CHANGE $ts'[4..$]' depending on many frames you want to remove. As 3dTcat counts from zero, here we are keeping from the 5th volume onwards
    
    3dTcat \
          -session $PWD/derivatives/CustomPrepro/Pre/${sub_folder}/func \
          -tr 2.6 \
          -prefix ${ts%.nii.gz}_chopped.nii.gz \
          $PWD/${sub_folder}/Pre/func/$ts'[4..$]' \
          &> $PWD/derivatives/CustomPrepro/Pre/${sub_folder}/func/log_${ts%.nii.gz}_chopping.txt
    

}
export -f chop_ts

########## main code starts here ##########


study_folder=IntraOpMap_RestingState #EDIT HERE
numjobs=4 #EDIT HERE

cd ${study_folder}

echo sub-* | tr " " "\n" > subject_list.txt
parallel \
    -j $numjobs \
    chop_ts {} \
    < subject_list.txt


