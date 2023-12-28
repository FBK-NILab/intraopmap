#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Oct 21 10:05:34 2022

@author: ludovicocoletta
"""

import glob
import numpy as np
import os
from utils.utils import flag_duplicated_seeds_based_file_name
from utils.utils import compute_look_up_table
from utils.utils import remove_outlier_from_seeds_maps
import re
import nibabel as nib

def main():
    
    #folders_of_int=sorted(glob.glob('01*'))
    folders_of_int=['01_SBA_AMODAL_ANOMIA','01_SBA_SPEECH_ARREST','01_SBA_SENSORIAL']
    
    os.makedirs('maps_2mm_cleaned_and_thr',exist_ok=True)
    thr_dice=0.25
    
    filename_mni='/home/ludovicocoletta/Documents/IntraOpMap_2022/07_rsfmri_APSS/IntraOpMap_RestingState/templates/GM_cort_subcort_mask_2mm.nii.gz'
    img = nib.load(filename_mni) 
    aff = img.affine
    head = img.header

    for ii in folders_of_int:
        
        os.chdir(ii)
        
        seed_maps=sorted(glob.glob('group_level_randomise/'+'*bin.nii.gz'))
        
        unique_indices=flag_duplicated_seeds_based_file_name(seed_maps)
        
        seed_maps_no_duplicates=[seed_maps[iii] for iii in unique_indices]
                        
        outliers=remove_outlier_from_seeds_maps(seed_maps_no_duplicates, thr_dice, filename_mni)
        
        if outliers.size !=0:
            seed_maps_no_duplicates_no_out=np.delete(seed_maps_no_duplicates, outliers, axis=0).tolist()
        else:
            seed_maps_no_duplicates_no_out=seed_maps_no_duplicates.copy()
               
        filenames=[iii.split('/')[-1] for iii in seed_maps_no_duplicates_no_out]
        all_coords=[re.findall("-?[0-9]+_-?[0-9]+_-?[0-9]+", iii)[0] for iii in filenames]
        
        path_to_negative_maps=[glob.glob('group_level_randomise_inverted/'+'*'+iii+'*bin*gz')[0] for iii in all_coords]
        
        look_up_table=compute_look_up_table(path_to_negative_maps)
        
        freq_map=np.mean(look_up_table,axis=0)
        
        os.chdir('..')
        
        nii_=nib.Nifti1Image(freq_map, affine=aff, header=head)
        
        file_out_name=('maps_2mm_cleaned_and_thr/' 
                       + '_'.join(ii.split('_')[2:])+'_NEGATIVE_no_thr_N_seeds_'
                       +str(len(path_to_negative_maps))
                       +'.nii.gz'
                       )
        nii_.to_filename(file_out_name)

if __name__ == "__main__":
    main()  
