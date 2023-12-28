#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar  3 10:20:17 2023

@author: ludovicocoletta
"""
import glob
import numpy as np
import os
import nibabel as nib
import re
from joblib import dump
import time
import pandas as pd
import multiprocessing as mp
from sklearn.ensemble import IsolationForest
from sklearn.pipeline import Pipeline
from sklearn.decomposition import PCA

def sample_subject(path_to_subj_seed_image_to_be_sampled,sampling_points):
    
    subj_image=nib.load(path_to_subj_seed_image_to_be_sampled).get_fdata()
    subj_samp=np.zeros((1,len(sampling_points)))
    
        
    for ind,iii in enumerate(sampling_points):
        seed_of_int=nib.load(iii).get_fdata()
        subj_samp[0,ind]=np.mean(subj_image[seed_of_int==1])
                
    return subj_samp
    
def main():
    
    os.makedirs('/home/ludovicocoletta/Documents/IntraOpMap_2022/04_preprocessed_rsfmri/00_draft/classifier_meta_language',exist_ok=True)
    
    language_seeds=np.loadtxt('seeds_language_hubs.txt',dtype='str').tolist()
    
    path_to_subjs_seed_maps='/home/ludovicocoletta/Documents/IntraOpMap_2022/04_preprocessed_rsfmri/00_draft'
           
    filenames=[iii.split('/')[-1].split('_2mm')[0] for iii in language_seeds]
    all_coords=[re.findall("-?[0-9]+_-?[0-9]+_-?[0-9]+", iii)[0] for iii in filenames]
    unique_indices=list(set([all_coords.index(ii) for ii in all_coords]))
    
    language_seeds_no_duplicates=[language_seeds[ii] for ii in unique_indices]
    
    for seed_ind,seed in enumerate(language_seeds_no_duplicates):
        
        language_seeds_copy=[ii for ii in language_seeds_no_duplicates]
        seed_to_be_sampled=language_seeds_copy[seed_ind]
        language_seeds_copy.remove(language_seeds_copy[seed_ind])
        filename=seed_to_be_sampled.split('/')[-1].split('_2mm')[0]
        
        path_to_subj_seed_images_to_be_sampled=sorted(glob.glob(path_to_subjs_seed_maps+'/'+'*'+'/'+'subject_maps/'+'*'+filename+'*gz'))
        
        start_time=time.time()
        pool=mp.Pool(mp.cpu_count())
        results=pool.starmap(sample_subject, [(subj, language_seeds_copy) for subj in path_to_subj_seed_images_to_be_sampled])
        pool.close()
        print(time.time()-start_time)
        
        dataset=np.vstack(results)
        pipe = Pipeline(steps=[("pca", PCA(n_components=0.8, svd_solver= 'full')), ("IsolationForest", IsolationForest())])
        pipe.fit(dataset)
        print('PCA found '+str(pipe['pca'].components_.shape[0])+' components')
        
        dump(pipe,'classifier_meta_language'+'/'+'_'.join(filename.split('_')[0:-1])+'_clf_isolation_forest.joblib')
        np.save('classifier_meta_language'+'/'+'_'.join(filename.split('_')[0:-1])+'_dataset.npy',dataset)
        pd.DataFrame(np.hstack((seed_to_be_sampled,language_seeds_copy))).to_csv('classifier_meta_language'+'/'+'_'.join(filename.split('_')[0:-1])+'_sampling_coord.csv',
                                                                                 header=False,index=False)
if __name__ == "__main__":
    main() 
            
        