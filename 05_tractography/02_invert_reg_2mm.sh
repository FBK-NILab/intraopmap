#!/bin/bash

function invert_linear_reg {

    matrix_original=$1
    
    sub_name=$(basename $matrix_original _to_MNI_2mm.mat)
    fold_name=$(dirname $matrix_original)
    
    convert_xfm -omat ${fold_name}/${sub_name}_from_MNI_to_sub_2mm.mat -inverse $matrix_original
       
    }
export -f invert_linear_reg

#### Script starts here #####

numjobs=4

echo $PWD/derivatives/*/sub*/anat/to_MNI_flirt/*to_MNI_2mm.mat | tr " " "\n" > path_to_reg_matrices.txt

parallel \
         -j $numjobs \
         invert_linear_reg {} \
         < $PWD/path_to_reg_matrices.txt
