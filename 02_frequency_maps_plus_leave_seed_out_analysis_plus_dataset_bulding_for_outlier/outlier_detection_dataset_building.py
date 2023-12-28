#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov  2 09:02:27 2022

@author: ludovicocoletta
"""

import glob
import numpy as np
import os
import nibabel as nib
from utils.utils import flag_duplicated_seeds_based_file_name
from utils.utils import remove_outlier_from_seeds_maps
import re
from joblib import dump
import time
import pandas as pd

def main():

    folders_of_int=sorted(glob.glob('01*'))
    thr_dice=0.25
        
    filename_mni='/home/ludovicocoletta/Documents/IntraOpMap_2022/07_rsfmri_APSS/IntraOpMap_RestingState/templates/GM_cort_subcort_mask_2mm.nii.gz'
    img = nib.load(filename_mni) 
    aff = img.affine
    head = img.header
    
    for ii in folders_of_int:
        
        os.chdir(ii)
        os.makedirs('classifiers_outliers_detection',exist_ok=True)
        seed_maps_positive=sorted(glob.glob('group_level_randomise/'+'*bin.nii.gz'))
        
        unique_indices=flag_duplicated_seeds_based_file_name(seed_maps_positive)
        
        seed_maps_no_duplicates=[seed_maps_positive[ii] for ii in unique_indices]
                        
        outliers=remove_outlier_from_seeds_maps(seed_maps_no_duplicates, thr_dice, filename_mni)
        
        if outliers.size !=0:
            seed_maps_no_duplicates_no_out=np.delete(seed_maps_no_duplicates, outliers, axis=0).tolist()
        else:
            seed_maps_no_duplicates_no_out=seed_maps_no_duplicates.copy()
               
        filenames=[iii.split('/')[-1] for iii in seed_maps_no_duplicates_no_out]
        filenames=[iii.split('_2mm')[0] for iii in filenames]
        
        all_coords=[re.findall("-?[0-9]+_-?[0-9]+_-?[0-9]+", iii)[0] for iii in filenames]
        
        filenames_selection=[iii for iii in filenames if int(iii.split('_')[-1].split('-')[-1])>3999]
        all_coords_selection=[re.findall("-?[0-9]+_-?[0-9]+_-?[0-9]+", iii)[0] for iii in filenames_selection]
        
        for iii in range(0,len(filenames_selection)):
            print(filenames_selection[iii])
            start_time = time.time()
            
            filenames_copy=filenames.copy()
            all_coords_copy=all_coords.copy()
            
            filenames_copy.remove(filenames_selection[iii])
            all_coords_copy.remove(all_coords_selection[iii])
            
            filenames_of_int=filenames_selection[iii]
            coords_of_int=all_coords_selection[iii]
            
            # DOUBLE CHECK THIS WHEN WE HAVE DUPLICATES
            seeds=[glob.glob('seeds_2mm/'+iiii+'*gz')[0] for iiii in filenames_copy]
            
            subjects=sorted(glob.glob('subject_maps/'+'*'+filenames_copy[0]+'*gz'))
            subjects=[iiii.split('_bld001')[0].split('/')[-1] for iiii in subjects]
            
            subj_by_seed=np.zeros((len(subjects),len(filenames_copy)))
            
            for iiii in range(0,len(subjects)):
                #print(iiii)
                
                sub_map=nib.load(glob.glob('subject_maps/'+subjects[iiii]+'*'+filenames_of_int+'*gz')[0])
                sub_map_data=sub_map.get_fdata()
                
                for iiiii in range(0,len(seeds)):
                    
                    dummy_image=nib.load(seeds[iiiii])
                    dummy_image_data=dummy_image.get_fdata()
                    subj_by_seed[iiii,iiiii]=np.mean(sub_map_data[dummy_image_data==1])
                    
            print("--- %s seconds ---" % (time.time() - start_time))
    

            np.save('classifiers_outliers_detection/'+'_'.join(ii.split('_')[2:])+'_'+coords_of_int+'_dataset',subj_by_seed)
            dump(clf, 'classifiers_outliers_detection/'+'_'.join(ii.split('_')[2:])+'_'+coords_of_int+'_clf.joblib')
            pd.DataFrame([filenames_of_int]+filenames_copy).to_csv('classifiers_outliers_detection/'+'_'.join(ii.split('_')[2:])+'_'+coords_of_int+'_sampling_coord.csv',
                                                 header=False,
                                                 index=False)
            
if __name__ == "__main__":
    main() 
