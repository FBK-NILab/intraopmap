#!/bin/bash

function mul_by_minus_one {

    original_image=$1
         
    im_name=$(basename $original_image .nii.gz)
         
    fslmaths $original_image -mul -1 $PWD/inverted_subject_maps/${im_name}_mul_by_minus_one

}

export -f mul_by_minus_one

mkdir inverted_subject_maps
echo $PWD/subject_maps/*_z.nii.gz | tr " " "\n" > imlist.txt

numjobs=32

parallel \
    -j $numjobs \
    time mul_by_minus_one {} \
    < $PWD/imlist.txt
