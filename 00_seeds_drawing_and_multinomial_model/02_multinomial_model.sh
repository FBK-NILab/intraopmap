#!/bin/bash

# EXPECTED INPUT:
# One nifti image per functional category containing the union of all seeds/stimulation points
 
echo $PWD/*.nii.gz | tr " " "\n" > file_list.txt

struct=(`cat "$PWD/file_list.txt"`)
# create strings for fslmaths add commands and add images (Implementation: remove the loop)

for (( i = 0 ; i < ${#struct[@]} ; i++))
do
     printf "%s " "${struct[$i]} -add"
done > file_list_all_images.txt
rm file_list.txt

fslmaths $(cat $PWD/file_list_all_images.txt) 0 multinomial_sum
rm file_list_all_images.txt


for img in ALL*gz
do
    fslmaths $img -div multinomial_sum ${img%%.nii.gz}_norm_image
done

