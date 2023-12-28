#!/bin/bash

function tracking_in_subj_space {
    
    path_to_sub=$1
    func=$2
    reg_of_int=$3
    
    sub_id=$(basename $path_to_sub)
    
    mkdir -p ${path_to_sub}/tracking_${reg_of_int}_reg

    fslmerge -t \
         ${path_to_sub}/tracking_${reg_of_int}_reg/${sub_id}__5tt_${func}.nii.gz \
         ${path_to_sub}/mask/${sub_id}__mask_gm.nii.gz \
         ${path_to_sub}/mask/${sub_id}__mask_gm.nii.gz \
         ${path_to_sub}/mask/${sub_id}__mask_gm.nii.gz \
         ${path_to_sub}/mask/${sub_id}__mask_gm.nii.gz \
         ${path_to_sub}/mask/${sub_id}__mask_gm.nii.gz
         
    5ttedit \
         -cgm ${path_to_sub}/mask/${sub_id}__mask_gm.nii.gz \
         -wm ${path_to_sub}/mask/${sub_id}__mask_wm.nii.gz \
         -csf ${path_to_sub}/mask/${sub_id}__mask_csf.nii.gz \
         ${path_to_sub}/tracking_${reg_of_int}_reg/${sub_id}__5tt_${func}.nii.gz ${path_to_sub}/tracking_${reg_of_int}_reg/${sub_id}__5tt_${func}.nii.gz -force
         
    # Networks union
    echo ${path_to_sub}/anat/to_MNI_flirt/reg_networks/${sub_id}_${func}_positive.nii.gz | tr " " "\n" > ${sub_id}_${func}_files_list.txt
    echo ${path_to_sub}/anat/to_MNI_flirt/reg_networks/${sub_id}_${func}_negative.nii.gz | tr " " "\n" >> ${sub_id}_${func}_files_list.txt
    
    struct=(`cat "$PWD/${sub_id}_${func}_files_list.txt"`)    
    for (( i = 0 ; i < ${#struct[@]} ; i++)) 
    do 
       printf "%s " "${struct[$i]} -add"
         
    done > ${sub_id}_${func}_categories_all_images.txt
     
    fslmaths $(cat $PWD/${sub_id}_${func}_categories_all_images.txt) 0 -bin ${path_to_sub}/anat/to_MNI_flirt/reg_networks/${sub_id}_${func}_networks_union    
    
    # GM-WM interface  
    for iii in ${path_to_sub}/anat/to_MNI_flirt/reg_networks/${sub_id}_${func}_*gz
    do
        echo $iii
        file_name=$(basename $iii .nii.gz)
        dir_name=$(dirname $iii)
        5tt2gmwmi \
           -mask_in $iii \
           ${path_to_sub}/tracking_${reg_of_int}_reg/${sub_id}__5tt_${func}.nii.gz \
           ${path_to_sub}/tracking_${reg_of_int}_reg/${file_name}_gwi.nii.gz
    done
    
    mv ${path_to_sub}/anat/to_MNI_flirt/reg_networks/${sub_id}_${func}_networks_union.nii.gz ${path_to_sub}/tracking_${reg_of_int}_reg
        
    # merge all subcortical seeds in one image and multiply by subj WM
    echo ${path_to_sub}/anat/to_MNI_flirt/reg_points/${sub_id}_${func}_*gz | tr " " "\n" > ${sub_id}_${func}_file_list.txt
    
    struct=(`cat "$PWD/${sub_id}_${func}_file_list.txt"`)    
    for (( i = 0 ; i < ${#struct[@]} ; i++)) 
    do
       file_name=$(basename ${struct[$i]} .nii.gz)
       dir_name=$(dirname ${struct[$i]})
       fslmaths ${struct[$i]} -mul ${path_to_sub}/mask/${sub_id}__mask_wm.nii.gz ${dir_name}/${file_name}_wm_only
       printf "%s " "${struct[$i]} -add"
         
    done > ${sub_id}_${func}_categories_all_images.txt
     
    fslmaths $(cat $PWD/${sub_id}_${func}_categories_all_images.txt) 0 -bin -mul \
        ${path_to_sub}/mask/${sub_id}__mask_wm.nii.gz \
        ${path_to_sub}/tracking_${reg_of_int}_reg/${sub_id}_${func}_all_spheres_in_one_image
         
    echo "tckgen -algorithm SD_STREAM -cutoff 0.05 -step 0.1 -angle 30 -maxlength 250 \
        -include ${path_to_sub}/tracking_${reg_of_int}_reg/${sub_id}_${func}_networks_union_gwi.nii.gz -stop \
        -seed_unidirectional -select 1000k \
        -max_attempts_per_seed 1000 -seed_image ${path_to_sub}/tracking_${reg_of_int}_reg/${sub_id}_${func}_all_spheres_in_one_image.nii.gz -output_seeds \
        ${path_to_sub}/tracking_${reg_of_int}_reg/${sub_id}_${func}_SEEDS ${path_to_sub}/fodf/${sub_id}__fodf.nii.gz \
        ${path_to_sub}/tracking_${reg_of_int}_reg/${sub_id}_${func}_to_nets.tck" > $PWD/txt_for_tracking/${sub_id}_${func}_tracking.txt
    
    #rm ${sub_id}_${func}_file_list.txt
    #rm ${sub_id}_${func}_files_list.txt
    #rm ${sub_id}_${func}_categories_all_images.txt
            
    }
export -f tracking_in_subj_space

#function_of_int=SEMANTIC
reg_of_int=linear

echo $PWD/derivatives/*/sub-* | tr " " "\n" > subject_list.txt
numjobs=4

mkdir txt_for_tracking

#for function_of_int in EYES_MOVEMENT MENTALIZING SEMANTIC
for function_of_int in ANOMIA AMODAL_ANOMIA
do

    parallel \
        -j $numjobs \
        tracking_in_subj_space {} $function_of_int $reg_of_int \
        < subject_list.txt
done

cat txt_for_tracking/*_tracking.txt > aaa.txt  
#time parallel -j2 -a aaa.txt  
