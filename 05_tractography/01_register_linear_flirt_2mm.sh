#!/bin/bash

function reg_linear_flirt {

    image_original=$1
    
    sub_name=$(basename $image_original __T1w.nii.gz)
    fold_name=$(dirname $image_original)
    
    if [[ ! -e ${fold_name}/to_MNI_flirt ]]; then
       mkdir ${fold_name}/to_MNI_flirt
    fi
        
    flirt \
       -in $image_original \
       -ref $PWD/templates/MNI152_T1_manually_masked_2mm.nii.gz \
       -omat ${fold_name}/to_MNI_flirt/${sub_name}_to_MNI_2mm.mat
       
    }
export -f reg_linear_flirt

#### Script starts here #####

numjobs=4

echo $PWD/derivatives/*/sub*/anat/*__T1w.nii.gz | tr " " "\n" > path_to_images.txt

parallel \
         -j $numjobs \
         reg_linear_flirt {} \
         < $PWD/path_to_images.txt
