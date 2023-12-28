#!/bin/bash

# One sample t-test with fsl randomise
# seedlist.txt has been already produced with seed_subjects_correlation_maps.sh

function seed_group_level_map {
 
    seed=$1
    seed_name=$(basename $seed .nii.gz)
    echo $seed_name


    fslmerge -t ${seed_name}_4D.nii.gz $PWD/inverted_subject_maps/*${seed_name}_z*gz
    randomise -i ${seed_name}_4D.nii.gz -o OneSampT -1 -T -n 1000 -o $PWD/group_level_randomise_inverted/${seed_name}
    rm ${seed_name}_4D.nii.gz

}
export -f seed_group_level_map

# Main starts here
mkdir group_level_randomise_inverted
numjobs=8
seedlist=seedlist.txt

parallel \
    -j $numjobs \
    time seed_group_level_map {} \
    < $seedlist
    




