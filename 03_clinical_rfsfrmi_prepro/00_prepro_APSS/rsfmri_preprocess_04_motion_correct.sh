#!/bin/bash

# This script carries out motion correction by using mcflirt. 
# Here we use the mean volume as reference
#
# The main outputs of this script are the realligned ts and 
# the 6 motion traces (3 rotations + 3 traslations). You will use these
# motion traces to carry out nuisance regression and for the carpet plot.
#
# -----------------------------------------------------------
# Script written by Ludovico Coletta
# NILAB, FBK (2022)
# -----------------------------------------------------------


function motion_correction {
    
    ts=$1
    subject=$(basename $ts _slt.nii.gz)
    sub_folder=$(dirname $ts)

    mcflirt \
        -in ${ts} \
        -spline_final \
        -stages 4 \
        -meanvol \
	-plots \
	-report \
	-mats \
	-report \
	-out ${sub_folder}/${subject}_mcf \
	&> ${sub_folder}/log_${subject}_mcf.txt

    }
export -f motion_correction

# main code starts here

study_folder=IntraOpMap_RestingState #EDIT HERE
numjobs=6 #EDIT HERE

echo $PWD/${study_folder}/derivatives/CustomPrepro/Pre/sub-*/func/*_slt.nii.gz | tr " " "\n" > subject_list.txt #EDIT HERE


parallel \
    -j $numjobs \
    motion_correction {} \
    < subject_list.txt 


