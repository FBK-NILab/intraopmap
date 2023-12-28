#!/bin/bash

# Auto segmentation via Freesurfer's mri_synthseg command. You need parallel Freesurfer to be installed on your pc
# According to the doc (https://surfer.nmr.mgh.harvard.edu/fswiki/SynthSeg), it is better to input/output txt file

#### Script starts here #####

export FREESURFER_HOME='/home/ludovicocoletta/Tools/Freesurfer/freesurfer' # EDIT HERE

source $FREESURFER_HOME/SetUpFreeSurfer.sh

study_folder=IntraOpMap_RestingState #EDIT HERE

echo $PWD/${study_folder}/derivatives/CustomPrepro/Pre/sub-*/anat/*masked.nii.gz | tr " " "\n" > path_to_images.txt

for ii in $(cat path_to_images.txt)
do
   sub_name=$(basename $ii _masked.nii.gz)
   fold_name=$(dirname $ii)
   out_file=${fold_name}/${sub_name}_seg.nii.gz
   echo $out_file
   
done > out_file.txt

mri_synthseg --i path_to_images.txt --o out_file.txt --robust --cpu

# resample images

for ii in $(cat out_file.txt)
do
   sub_name=$(basename $ii _seg.nii.gz)
   fold_name=$(dirname $ii)
   echo ${fold_name}/${sub_name}_seg_res.nii.gz
   flirt -in $ii -ref ${fold_name}/${sub_name}_masked.nii.gz -interp nearestneighbour -out ${fold_name}/${sub_name}_seg_res.nii.gz -applyxfm
done
