#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar  1 15:59:19 2023

@author: ludovicocoletta
"""

import nibabel as nib
import numpy as np
import glob
import itertools
from scipy.spatial.distance import cdist, squareform,pdist

def main():
    
    path_to_maps='/home/ludovicocoletta/Documents/IntraOpMap_2022/04_preprocessed_rsfmri/00_draft/maps_2mm_cleaned_and_thr/netw_no_thr'
    path_hub_thr='/home/ludovicocoletta/Documents/IntraOpMap_2022/04_preprocessed_rsfmri/00_draft/maps_2mm_cleaned_and_thr/leave_one_seed_out_results/report'    
    path_func_folder='/home/ludovicocoletta/Documents/IntraOpMap_2022/04_preprocessed_rsfmri/00_draft'
    out_folder='/home/ludovicocoletta/Documents/IntraOpMap_2022/04_preprocessed_rsfmri/00_draft'
    
    functions=['ANOMIA', 'SEMANTIC','PHONOLOGICAL']
    
    cart_prod_func=list(itertools.product(*[functions,functions]))
    cart_prod_ind=list(itertools.product(*[list(range(0,len(functions))),list(range(0,len(functions)))]))
    
    hub_point_per_func=np.zeros((len(functions),len(functions)))
    hub_points_across_func=[]
    
    # How many DES points in hub regions (within and between netw comparison)
    
    for ii in range(0,len(cart_prod_func)):
        
        func_a,func_b=cart_prod_func[ii]
        ind_a,ind_b=cart_prod_ind[ii]
        
        func_a_map=nib.load(glob.glob(path_to_maps+'/'+func_a+'*POSITIVE*gz')[0]).get_fdata()
        func_a_thr=np.loadtxt(glob.glob(path_hub_thr+'/'+func_a+'_hub_thr.txt')[0])
        func_a_map[func_a_map<=func_a_thr]=0
        func_a_map[func_a_map!=0]=1
        
        path_to_func_a_seeds=sorted(glob.glob(path_func_folder+'/'+'01_SBA_'+func_a+'/'+'seeds_2mm'+'/'+'*sub*gz'))
        complete_seed_list_for_features_space=[]
        
        if func_a==func_b:
                       
            count=0
        
            for iiiii in range(0,len(path_to_func_a_seeds)):
                 seed=nib.load(path_to_func_a_seeds[iiiii]).get_fdata()
                
                 if np.sum(func_a_map*seed) != 0:
                    count=count+1
                    complete_seed_list_for_features_space.append(path_to_func_a_seeds[iiiii])
                    
            hub_point_per_func[ind_a,ind_b]=count
            hub_points_across_func.append(complete_seed_list_for_features_space)
        
            
        else:
            
            count=0
            
            func_b_map=nib.load(glob.glob(path_to_maps+'/'+func_b+'*POSITIVE*gz')[0]).get_fdata()
            func_b_thr=np.loadtxt(glob.glob(path_hub_thr+'/'+func_b+'_hub_thr.txt')[0])
            func_b_map[func_b_map<=func_b_thr]=0
            func_b_map[func_b_map!=0]=1
            
            #path_to_func_b_seeds=sorted(glob.glob(path_func_folder+'/'+'01_SBA_'+func_b+'/'+'seeds_2mm'+'/'+'*sub*gz'))
            
            # here we have to check whether the seeds of func a (e.g ANOMIA) fall within the b (e.g. SEMANTIC) hubs                                    
            for iiiii in range(0,len(path_to_func_a_seeds)):
                 seed=nib.load(path_to_func_a_seeds[iiiii]).get_fdata()
                
                 if np.sum(func_b_map*seed) != 0:
                    count=count+1
                    
            hub_point_per_func[ind_a,ind_b]=count
      
    all_seeds=np.hstack([np.asarray(ii,dtype='str')for ii in hub_points_across_func])
    np.savetxt(out_folder+'/'+'seeds_language_hubs.txt',all_seeds,fmt='%s')
                        
if __name__ == "__main__":
    main()  
