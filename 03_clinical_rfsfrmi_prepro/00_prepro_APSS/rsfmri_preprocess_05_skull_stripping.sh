#!/bin/bash

# This script performs skull-stripping i.e. removes extra-brain tissues
#
# -----------------------------------------------------------
# Script written by Ludovico Coletta
# NILAB, FBK (2022)
# -----------------------------------------------------------

function brain_mask_subject {
    
   $ts=$1
   file_name=$(basename $ts _mcf.nii.gz)
   fold_name=$(dirname $ts)
   
   fslmaths $ts -Tmean ${fold_name}/${file_name}_Tmean.nii.gz
    
   mri_synthstrip \
       -i ${fold_name}/${file_name}_Tmean.nii.gz \
       -m ${fold_name}/${file_name}_brain_mask.nii.gz \
       -o ${fold_name}/${file_name}_tmean_masked.nii.gz \
       &> ${fold_name}/log_${file_name}_sk.txt
    
   fslmaths $ts -mul ${fold_name}/${file_name}_brain_mask.nii.gz ${fold_name}/${file_name}_masked.nii.gz
   
   rm ${fold_name}/${file_name}_tmean_masked.nii.gz
   rm ${fold_name}/${file_name}_Tmean.nii.gz
     
    }
export -f brain_mask_subject

# main code starts here

export FREESURFER_HOME='/home/ludovicocoletta/Tools/Freesurfer/freesurfer' # EDIT HERE

source $FREESURFER_HOME/SetUpFreeSurfer.sh

study_folder=IntraOpMap_RestingState #EDIT HERE

numjobs=1 #EDIT HERE

echo $PWD/${study_folder}/derivatives/CustomPrepro/Pre/sub-*/func/*_mcf.nii.gz | tr " " "\n" > subject_list.txt #EDIT HERE

parallel \
    -j $numjobs \
    brain_mask_subject {} \
    < subject_list.txt
