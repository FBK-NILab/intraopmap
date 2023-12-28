#!/bin/bash

function mean_seed_map {
 
    seed=$1
    seed_name=$(basename $seed .nii.gz)
    echo $seed_name


    fslmerge -t ${seed_name}_4D.nii.gz $PWD/subject_maps/*${seed_name}_z.nii.gz

    fslmaths ${seed_name}_4D.nii.gz -Tmean $PWD/mean_seed_maps/${seed_name}_mean
    
    rm ${seed_name}_4D.nii.gz

}
export -f mean_seed_map

# Main starts here
mkdir mean_seed_maps
numjobs=10
seedlist=seedlist_v2_try.txt

parallel \
    -j $numjobs \
    time mean_seed_map {} \
    < $seedlist
    




