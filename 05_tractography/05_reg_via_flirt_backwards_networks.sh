#!/bin/bash

function reg_network_to_subj {

    path_to_sub=$1
    netw=$2
   
    sub_id=$(basename $path_to_sub)
    net_name=$(basename $netw _1mm_flirt.nii.gz)

    
    mkdir -p ${path_to_sub}/anat/to_MNI_flirt/reg_networks

    
    flirt \
       -in $netw \
       -ref ${path_to_sub}/anat/${sub_id}__T1w.nii.gz \
       -interp nearestneighbour \
       -applyxfm -init ${path_to_sub}/anat/to_MNI_flirt/${sub_id}_from_MNI_to_sub.mat \
       -out ${path_to_sub}/anat/to_MNI_flirt/reg_networks/${sub_id}_${net_name}.nii.gz \

    }
export -f reg_network_to_subj


#### Script starts here #####

for iii in $PWD/network_bin/*gz
do

    file_name=$(basename $iii .nii.gz)
    dir_name=$(dirname $iii)
    fslmaths $iii -bin ${dir_name}/${file_name}_bin
    flirt -in ${dir_name}/${file_name}_bin.nii.gz \
          -ref ${FSLDIR}/data/standard/MNI152_T1_1mm.nii.gz \
          -interp nearestneighbour \
          -out ${dir_name}/${file_name}_1mm_flirt -applyxfm

done

echo $PWD/derivatives/*/sub* | tr " " "\n" > sublist.txt

echo $PWD/network_bin/*1mm_flirt*gz | tr " " "\n" > netwlist.txt

reg=linear

numjobs=4

while read -r net;
do
    parallel \
        -j $numjobs \
        reg_network_to_subj {} $net \
        < sublist.txt
        
done < netwlist.txt

       
