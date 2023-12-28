#!/bin/bash

# Draw spheres as per Sarubbo et al., 2020 (NeuroImage).

# Expected inputs: a txt file with 4 columns for each of the categories of interest: sub_id (integers only), x, y, and z coords of stimulation points in MNI space. NO HEADERS

# Parameters to be edited, see SCRIPT STARTS HERE section :
   # 1) Path to MNI mask as per FSL (2006AsymmNonLin)
   # 2) Electrode diameter
   # 3) number of cores for parallel computing 
   

# Output: a nifti file for each stimulation point. 
# Please keep in mind that spheres are drawn without taking into accout the distinction between brain/no brain, GM/WM, and so on

 

function draw_sphere {

    mni_coord=$1
    path_to_mni_image=$2
    func_tested=$3
    out_dir=$4
    electrode_radius=$5 # in voxels
    
    sub_id=$(echo $mni_coord | awk '{print $1}')    
    x_coord=$(echo $mni_coord | awk '{print $2}')
    y_coord=$(echo $mni_coord | awk '{print $3}')
    z_coord=$(echo $mni_coord | awk '{print $4}')
    
    # We need everything in voxel coordinates. We do the following: x=x_mm * -1 + 90, y=y_mm * 1 + 126, z=z_mm * 1 + 72

    x_trans_matrix=$(fslval $path_to_mni_image sto_xyz:1 | awk '{print $4}') # We read from the header
    x_trans_matrix=${x_trans_matrix%%.*} # Float to int

    
    y_trans_matrix=$(fslval $path_to_mni_image sto_xyz:2 | awk '{print $4}') # We read from the header
    y_trans_matrix=${y_trans_matrix%%.*} # Float to int
    y_trans_matrix=$((${y_trans_matrix} * -1 ))
  
    z_trans_matrix=$(fslval $path_to_mni_image sto_xyz:3 | awk '{print $4}') # We read from the header
    z_trans_matrix=${z_trans_matrix%%.*} # Float to int
    z_trans_matrix=$((${z_trans_matrix} * -1 ))

    
    # Starting point of the sphere
    
    x_coord_sphere=$((${x_coord} * -1))
    
    y_coord_sphere=$((${y_coord} * 1))
    
    z_coord_sphere=$((${z_coord} * 1))
    
    echo "STIM point in mm, x already multiplied: $x_coord_sphere, $y_coord_sphere, $z_coord_sphere"
    
    # Starting point of the sphere in voxels 

    x_coord_sphere_in_vox=$((${x_coord_sphere}+${x_trans_matrix}))
    #echo $x_coord_sphere_in_vox
    
    y_coord_sphere_in_vox=$((${y_coord_sphere}+${y_trans_matrix}))
    #echo $y_coord_sphere_in_vox
    
    z_coord_sphere_in_vox=$((${z_coord_sphere}+${z_trans_matrix})) 
    
    #echo $z_coord_sphere_in_vox
    
    echo "STIM point in voxels: $x_coord_sphere_in_vox, $y_coord_sphere_in_vox, $z_coord_sphere_in_vox"
    
    fslmaths \
       ${path_to_mni_image} -mul 0 -add 1 \
       -roi $x_coord_sphere_in_vox 1 $y_coord_sphere_in_vox 1 $z_coord_sphere_in_vox 1 0 1 \
       $out_dir/${func_tested}_${x_coord}_${y_coord}_${z_coord}_${sub_id}.nii.gz -odt float
       
    fslmaths \
       $out_dir/${func_tested}_${x_coord}_${y_coord}_${z_coord}_${sub_id}.nii.gz \
       -kernel sphere $electrode_radius \
       -fmean \
       -bin \
       $out_dir/${func_tested}_${x_coord}_${y_coord}_${z_coord}_${sub_id}.nii.gz
      
}

export -f draw_sphere

########### SCRIPT STARTS HERE ###########

numjobs=8
path_to_mni_image=$PWD/00_MNI/*mask*gz # EDIT HERE. ENDING .NII.GZ is mandatory
electrode_radius=5 # EDIT HERE. In voxels
path_of_int=01_points_by_function
# We draw the spheres at the stimulations points

for func in $PWD/${path_of_int}/*.txt
do
     func_tested=$(basename $func .txt) # ENDING .txt is mandatory
     echo $func_tested
     mkdir $PWD/${path_of_int}/02_${func_tested}
     out_dir=$PWD/${path_of_int}/02_${func_tested}
     
     parallel \
         -j $numjobs \
         draw_sphere {} $path_to_mni_image $func_tested $out_dir $electrode_radius \
         < $PWD/${path_of_int}/${func_tested}.txt
done

