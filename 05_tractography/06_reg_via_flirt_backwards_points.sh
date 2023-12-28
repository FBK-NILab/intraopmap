#!/bin/bash

function reg_points_to_subj {

    point=$1
    path_to_sub=$2
    
    sub_id=$(basename $path_to_sub)
    point_name=$(basename $point .nii.gz)   
    
    flirt \
       -in $point \
       -ref ${path_to_sub}/anat/${sub_id}__T1w.nii.gz \
       -interp nearestneighbour \
       -applyxfm -init ${path_to_sub}/anat/to_MNI_flirt/${sub_id}_from_MNI_to_sub.mat \
       -out ${path_to_sub}/anat/to_MNI_flirt/reg_points/${sub_id}_${point_name}.nii.gz \

    }
export -f reg_points_to_subj

#########################################################

echo $PWD/derivatives/*/sub* | tr " " "\n" > sublist.txt

echo $PWD/points_in_mni/*gz | tr " " "\n" > pointlist.txt

for ii in $(cat sublist.txt)
do
    mkdir ${ii}/anat/to_MNI_flirt/reg_points
done

numjobs=8

while read -r sub;
do
    parallel \
        -j $numjobs \
        reg_points_to_subj {} $sub \
        < pointlist.txt
        
done < sublist.txt


