#!/bin/bash

function create_track_count_per_seed {

    seed=$1 # must be something like sub-1006_SEMANTIC_19_13_-7_whatever.nii.gz
    func=$2
    
    file_name=$(basename $seed _wm_gm_interface.nii.gz)
    dir_name=$(dirname $seed)
    splits=(${file_name//$func/A})
    splits_2=(${splits//_/ })    
    sub_id=${splits_2[0]}
    coord=${splits_2[2]}_${splits_2[3]}_${splits_2[4]}
    
    
    tckedit ${dir_name}/../../../tracking_linear_reg/${sub_id}_${func}_to_nets.tck \
        ${dir_name}/../../../tracking_linear_reg/${sub_id}_${func}_from_${coord}_to_net_${func}_positive.tck \
        -include ${seed} \
        -include ${dir_name}/../../../tracking_linear_reg/${sub_id}_${func}_positive_gwi.nii.gz
        

    tckedit ${dir_name}/../../../tracking_linear_reg/${sub_id}_${func}_to_nets.tck \
        ${dir_name}/../../../tracking_linear_reg/${sub_id}_${func}_from_${coord}_to_net_${func}_negative.tck \
        -include ${seed} \
        -include ${dir_name}/../../../tracking_linear_reg/${sub_id}_${func}_negative_gwi.nii.gz
        
    tckstats \
        -output count \
        ${dir_name}/../../../tracking_linear_reg/${sub_id}_${func}_from_${coord}_to_net_${func}_negative.tck \
        > ${dir_name}/../../../tracking_linear_reg/${sub_id}_${func}_from_${coord}_to_net_${func}_negative_count.txt

    tckstats \
        -dump ${dir_name}/../../../tracking_linear_reg/${sub_id}_${func}_from_${coord}_to_net_${func}_negative_stream_len.txt \
        ${dir_name}/../../../tracking_linear_reg/${sub_id}_${func}_from_${coord}_to_net_${func}_negative.tck \
        
    tckstats \
        -output count \
        ${dir_name}/../../../tracking_linear_reg/${sub_id}_${func}_from_${coord}_to_net_${func}_positive.tck \
        > ${dir_name}/../../../tracking_linear_reg/${sub_id}_${func}_from_${coord}_to_net_${func}_positive_count.txt
          
    tckstats \
        -dump ${dir_name}/../../../tracking_linear_reg/${sub_id}_${func}_from_${coord}_to_net_${func}_positive_stream_len.txt \
        ${dir_name}/../../../tracking_linear_reg/${sub_id}_${func}_from_${coord}_to_net_${func}_positive.tck
        
    rm ${dir_name}/../../../tracking_linear_reg/${sub_id}_${func}_from_${coord}_to_net_${func}_positive.tck
    rm ${dir_name}/../../../tracking_linear_reg/${sub_id}_${func}_from_${coord}_to_net_${func}_negative.tck
    #rm $seed
    
    }
export -f create_track_count_per_seed


#func=SEMANTIC
numjobs=2

#for func in EYES_MOVEMENT MENTALIZING SEMANTIC
for func in ANOMIA AMODAL_ANOMIA
do

    echo $PWD/derivatives/*/sub-*/anat/to_MNI_flirt/reg_points/sub-????_${func}*wm_only.nii.gz | tr " " "\n" > seed_list_${func}.txt

    parallel \
      -j $numjobs \
      create_track_count_per_seed {} $func \
      < seed_list_${func}.txt
      
done
