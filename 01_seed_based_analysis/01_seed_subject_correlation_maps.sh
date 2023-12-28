#!/bin/bash

function seed_subject_correlation_map {
    ts=$1
    seed=$2
    brainmask=/home/ludovico/Projects/NeuSurPlan/REMAP_subcortical/templates_and_masks/MNI152_T1_2mm_brain_mask.nii.gz
    
    # Calculate seed time course for subject/session
    subj_name=$(basename $ts .nii.gz)
    seed_name=$(basename $seed .nii.gz)

    fslmeants -i $ts -m $seed \
        | 1dnorm -demean - subject_maps/${subj_name}_${seed_name}.txt

    # Calculate correlation map & convert to z
    3dTcorr1D \
        -prefix subject_maps/${subj_name}_${seed_name}_r.nii.gz \
        -mask $brainmask \
        $ts \
        subject_maps/${subj_name}_${seed_name}.txt

    3dcalc \
        -a subject_maps/${subj_name}_${seed_name}_r.nii.gz \
        -expr 'atanh(a)' \
        -prefix subject_maps/${subj_name}_${seed_name}_z.nii.gz
        
    rm subject_maps/${subj_name}_${seed_name}.txt
    rm subject_maps/${subj_name}_${seed_name}_r.nii.gz
}
export -f seed_subject_correlation_map

# Main starts here

path_seeds=$PWD/seeds_2mm #edit this

path_ts=/home/ludovico/datasets/GSP1000 #edit this

numjobs=32

echo $path_ts/sub*/func/*bld001*.nii.gz | tr " " "\n" > tslist.txt

echo $path_seeds/*2mm*WM.nii.gz | tr " " "\n" > seedlist.txt

mkdir subject_maps

while read -r seed;
do
    parallel \
        -j $numjobs \
        seed_subject_correlation_map {} $seed \
        < tslist.txt
done < seedlist.txt
