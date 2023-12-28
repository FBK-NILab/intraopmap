#!/bin/bash

txt_of_int=seedlist_v2.txt
mkdir -p $PWD/HGG_LGG/group_level

for func_map in $(cat $txt_of_int)
do 
 
 
   splits=(${func_map//"seeds_2mm/"/ })
   seed_name=${splits[0]}
   seed_name_2=$(basename $seed_name .nii.gz)
   #echo $seed_name_2
   cp subject_maps/*_${seed_name_2}*gz /home/ludovicocoletta/Documents/IntraOpMap_2022/07_rsfmri_APSS_SBA/HGG_LGG/group_level
   
done

cd $PWD/HGG_LGG


for group in HGG LGG
do
   for func_map in $(cat $txt_of_int)
   do
      splits=(${func_map//"seeds_2mm/"/ })
      seed_name=${splits[0]}
      seed_name_2=$(basename $seed_name .nii.gz)
      echo $seed_name_2
   
      for sub in $(cat ${group}.txt)
      do
          echo group_level/${sub}*${seed_name_2}*gz
          
      done > ${seed_name_2}_${group}.txt
      
      fslmerge -t group_level/${seed_name_2}_${group}_as_ts.nii.gz $(cat ${seed_name_2}_${group}.txt)
      fslmaths group_level/${seed_name_2}_${group}_as_ts.nii.gz -Tmean group_level/${seed_name_2}_${group}_Tmean.nii.gz
      rm ${seed_name_2}_${group}.txt
   
   done
   
done
    

