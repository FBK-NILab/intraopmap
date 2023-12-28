#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 20 10:21:59 2022

@author: ludovicocoletta

list of functions:
    flag_duplicated_seeds_based_file_name
    compute_look_up_table
    remove_outlier_from_seeds_maps
    compute_overlap_between_freqMap_stimPoints
    leave_one_seed_out
"""

import numpy as np
import nibabel as nib
from scipy.spatial import distance
import re

def flag_duplicated_seeds_based_file_name(seed_maps):
    
    """ 
    The function spots duplicated coordinates in a list of file names
    Inputs: path to seeds maps. Coordinates are expected to be found in the file name. 
    Mandatory filename structure: sub-id_coordX_coordY_coordZ_whatever.nii.gz, i.e. make sure that the coordinates triplet comes before any other solo number
    Outputs: list of unique indices
    
    Needed modules/packages: regex
    
    """
    filenames=[ii.split('/')[-1] for ii in seed_maps]
    all_coords=[re.findall("-?[0-9]+_-?[0-9]+_-?[0-9]+", ii)[0] for ii in filenames]
    
    return list(set([all_coords.index(ii) for ii in all_coords]))


def compute_look_up_table(seed_maps):
    
    """ The function computes a look up table at the voxel level. i.e. given a list of binary maps, it stores - across maps - which voxel of are 1s and which 0s  
    
    Needed modules/packages: nibabel, numpy
    
    """
        
    img = nib.load(seed_maps[0]) 
    data_arr=img.get_fdata()    
    look_up_table=np.zeros(((len(seed_maps),data_arr.shape[0],data_arr.shape[1],data_arr.shape[2])))
    
    for ii in range(0,len(seed_maps)):
        img_seed=nib.load(seed_maps[ii])
        look_up_table[ii,:,:,:]=img_seed.get_fdata()
        
    return look_up_table
    
def remove_outlier_from_seeds_maps(seed_maps, thr, path_to_mask):
    
    """ 
    The function computes the dice coefficient between all pairs of inputs, and based on a user defined threshold, it flags possible outliers
    
    Inputs: 
        1) list of strings containing paths to binary nifti files (.nii.gz is mandatory)
        2) Dissimilarity threshold (1-dice coeff, float). Above this number, inputs are flagged as outliers. Values of 0.25/0.2 (i.e minimum dice coeff of 0.75/0.8) should work fine
        3) String pointin to a mask of interest (.nii.gz is mandatory)
    
    Outputs: 
        1) Dice dissimilarity matrix (the higher the value, the more dissimilar two inputs are)
        2) Index/indices of inputs to be removed (numpy array). If no indices are found, it returns an empty array
    
    Needed modules/packages: numpy, scipy, nibabel
        
    """
    
    img = nib.load(path_to_mask) 
    data_arr=img.get_fdata()
       
    look_up_table=compute_look_up_table(seed_maps)
        

    dice_matrix=np.zeros((len(seed_maps),len(seed_maps)))
    
    for ii in range(0,len(seed_maps)):
        for iii in range(0,len(seed_maps)):
            dummy_a=look_up_table[ii,:,:,:]
            dummy_bb=look_up_table[iii,:,:,:]
            dice_matrix[ii,iii]=distance.dice((dummy_a[data_arr==1]),(dummy_bb[data_arr==1]))
            
    # min max no diagonal
    min_max_across_seeds=np.array([np.where(np.eye(*dice_matrix.shape, dtype=bool), dice_matrix.max(), dice_matrix).min(axis=1),
                                    np.where(np.eye(*dice_matrix.shape, dtype=bool), dice_matrix.min(), dice_matrix).max(axis=1)]).T
    
    if np.where(min_max_across_seeds[:,0]>thr)[0].size==0:
        return np.array([])
    else:
        return np.where(min_max_across_seeds[:,0]>thr)[0]


def compute_overlap_between_freqMap_stimPoints(path_stim_points,freq_map):
    
    """ 
    
    It computes the overlap between the frequency map at varying thresholds and the stimulation points.
    Inputs:
        1) list of strings containing the path to stim points
        2) frequency map as numpy array
    
    Outputs: 
        1) overlap between the frequency map and the stimulation points (% of stim points found in the map) for a given threshold
    
    Needed modules/packages: numpy, nibabel
    
    """
    img = nib.load(path_stim_points[0]) 
    data_arr=img.get_fdata()    
    stim_freq_data=np.zeros_like(data_arr)
    
    for ii in range(0,len(path_stim_points)):
        img = nib.load(path_stim_points[ii]) 
        stim_freq_data=stim_freq_data+img.get_fdata()
                
    unique_val_in_freq=np.unique(freq_map) # sorted already
 
    threshold_and_overlap=np.zeros((unique_val_in_freq.shape[0],2))
    
    for ii in range(0,unique_val_in_freq.shape[0]):
        array_copy=freq_map.copy()
        array_copy[array_copy<=unique_val_in_freq[ii]]=0
        array_copy[array_copy!=0]=1
        threshold_and_overlap[ii,0]=unique_val_in_freq[ii]
        threshold_and_overlap[ii,1]=np.count_nonzero(array_copy*stim_freq_data)/np.count_nonzero(stim_freq_data)
        
        
    return threshold_and_overlap

def leave_one_seed_out(seed_maps_positive,seed_maps_negative,path_to_stim_points):
    
    """ 
    It computes the frequency maps (separately for correlations and anticorrelations) with a leave one seed out approach. The left out seed is used as a test set for computing the average concordance
    value within the positive maps
    
    Inputs:
        
        1) Lists containing paths to binary maps (both positive and negative FC for a given seed) and to stimulation points. 
          Make sure that the i-th entry across lists points to the same seed
          The expected order of the input is seed_maps_positive,seed_maps_negative,path_to_stim_points
    
    Outputs: 
        1) Numpy array containing the average concordance value across left out seeds, with the same ordering as the input files, and for both positive (first column) and negative (secondo column) correlations
    
    Needed modules/packages: numpy, pandas, nibabel
    
    """
    
    
    count_positive_freq=np.zeros((len(seed_maps_positive)))
    count_negative_freq=np.zeros((len(seed_maps_negative)))
    
    
    for ii in range(0,len(seed_maps_positive)):
        
        seed_maps_positive_copy=seed_maps_positive.copy()
        seed_maps_negative_copy=seed_maps_negative.copy()
        path_to_stim_points_copy=path_to_stim_points.copy()
        
        # we use these to build the frequencies maps
        seed_maps_positive_copy.remove(seed_maps_positive_copy[ii])
        seed_maps_negative_copy.remove(seed_maps_negative_copy[ii])
        path_to_stim_points_copy.remove(path_to_stim_points_copy[ii])
        
        # the left out is the one we use for test
        file_of_int=path_to_stim_points[ii]
        
        positive_freq=compute_look_up_table(seed_maps_positive_copy)
        positive_freq=np.mean(positive_freq,axis=0)
        
        negative_freq=compute_look_up_table(seed_maps_negative_copy)
        negative_freq=np.mean(negative_freq,axis=0)
        
        img_seed=nib.load(file_of_int)
        seed_array_img=img_seed.get_fdata()
        
        count_positive_freq[ii]=np.mean(positive_freq[seed_array_img==1])
        count_negative_freq[ii]=np.mean(negative_freq[seed_array_img==1])
        
    return np.array([count_positive_freq,count_negative_freq]).T

