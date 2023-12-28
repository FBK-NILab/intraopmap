#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov  1 17:35:57 2023

@author: ludovicocoletta
"""
from brainsmash.mapgen.base import Base
from brainsmash.mapgen.eval import base_fit
from brainsmash.mapgen.stats import nonparp
import glob
import os
import numpy as np
import time
from sklearn.metrics.pairwise import cosine_similarity
from scipy.spatial.distance import pdist, squareform
from scipy.stats import spearmanr,pearsonr

def main():
    
    path_to_reference_sba='/home/ludovicocoletta/Documents/IntraOpMap_2022/04_preprocessed_rsfmri/00_draft'
    path_to_seeds_of_int=np.loadtxt('seedlist_v2.txt',dtype='str').tolist()
    name_of_seeds_of_int=[ii.split('/')[-1].split('.nii.gz')[0] for ii in path_to_seeds_of_int]
    
    n_shuffle=1000
    rois=sorted(glob.glob('../rois/roi_*txt'))
    
    cog=np.asarray([np.loadtxt(ii) for ii in rois])
    
    dist_matrix=squareform(pdist(cog, metric='euclidean'))
    dist_matrix=dist_matrix[207:414,207:414]
    # extract cortex
    #ixgrid = np.ix_(list(range(0,180))+list(range(207,387)), list(range(0,180))+list(range(207,387)))
    #dist_matrix=dist_matrix[ixgrid]    
    
    sim_across_func=[None]*len(name_of_seeds_of_int)
    null_model_fit_across_func=[None]*len(name_of_seeds_of_int)
    p_val_across_func=[None]*len(name_of_seeds_of_int)
    
    for func_index,func in enumerate(name_of_seeds_of_int):
        
        #print(func)
        path_to_apss_sba=sorted(glob.glob('mean_seed_maps/'+func+'*.npy'))

        sim_in_func=np.zeros((len(path_to_apss_sba),1))
        null_model_fit_within_func=np.zeros((len(path_to_apss_sba),1)) # we take the median
        p_val_within_func=np.zeros((len(path_to_apss_sba),1))
        
        #for index_map,spatial_map in enumerate(path_to_apss_sba):
            
        #print(index_map)
        
        map_data=np.load(path_to_apss_sba[0])
        map_data=map_data[0,:]
        map_data=map_data[207:414]
        
        # extract cortex
        #map_data=np.r_[map_data[0:180],map_data[207:387]]
        
        
        #reference_file=spatial_map.replace('HGG','LGG')
        reference_file=glob.glob(path_to_reference_sba +'/*/'+path_to_apss_sba[0])[0]
        print(path_to_apss_sba[0].split('/')[-1]+'\n'+reference_file.split('/')[-1]+'\n'+'\n')
        reference_file_data=np.load(reference_file)
        reference_file_data=reference_file_data[0,:]
        reference_file_data=reference_file_data[207:414]
        
        # extract cortex
        #reference_file_data=np.r_[reference_file_data[0:180],reference_file_data[207:387]]
        
        #print(list(zip([spatial_map],[reference_file])))
        #sim_in_func[index_map]=cos_similarity(reference_file_data,map_data)
        sim_in_func[0]=pearsonr(reference_file_data,map_data)[0]
        
        # Null data generation with preserved spatial autocorrelation. 
        # Since we are using default params, we also check fit
        
        start_time=time.time()
        
        emp_var,u0,surr_var=base_fit(reference_file_data, dist_matrix, nsurr=100, return_data=True)
        null_model_fit_within_func[0]=np.percentile(([pearsonr(emp_var,surr_var[iii,:])[0] for iii in range(0,surr_var.shape[0])]),[50])[0]
        
        base=Base(x=reference_file_data,D=dist_matrix)                       
        surrogates=base(n=n_shuffle)
        dist=[pearsonr(surrogates[iii,:], map_data)[0] for iii in range(0,n_shuffle)]
        stat=pearsonr(reference_file_data, map_data)[0]
        p_val_within_func[0]=nonparp(stat, dist)
        
        print(time.time()-start_time)
        

        sim_across_func[func_index]=sim_in_func
        null_model_fit_across_func[func_index]=null_model_fit_within_func
        p_val_across_func[func_index]=p_val_within_func
        
if __name__ == "__main__":
    main()   
