#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Feb 21 16:28:43 2023

@author: ludovicocoletta
"""

from sklearn.ensemble import IsolationForest
import numpy as np
from joblib import dump
import glob
from sklearn.pipeline import Pipeline
from sklearn.decomposition import PCA
import os
import glob
import pandas as pd

def main():
    
    functions=['SEMANTIC', 'ANOMIA']
    
    path_to_seedlist_selection='/home/ludovicocoletta/Documents/IntraOpMap_2022/07_rsfmri_APSS_SBA/seedlist_v3.txt'
    
    seedlist_selection=np.loadtxt(path_to_seedlist_selection,dtype='str')
    
    prefix_folders='01_SBA_'
    
    folders_with_classifier_to_change='classifiers_outliers_detection'
    
    for func_index,func in enumerate(functions):
        
        seeds_of_func=[]
        
        for seed in seedlist_selection:
            if func+'_' in seed:
               seeds_of_func.append(seed) 
               
        os.chdir(prefix_folders+func)
        
        os.makedirs('classifiers_outliers_detection_reduced_dataset')
        
        os.chdir(folders_with_classifier_to_change)
        
        #csv_files_original_datasets=sorted(glob.glob('*.csv'))
        csv_files_original_datasets=[glob.glob(ii.split('/')[1].split('sub')[0]+'*.csv')[0] for ii in seeds_of_func]
        
        for csv_file_index,csv_file in enumerate(csv_files_original_datasets):
            
            dummy_csv_file=pd.read_csv(csv_file,header=None)
            
            indices_to_keep=[] 
            
            for n_seeds in range(1,len(dummy_csv_file)):
                
                for seed_of_func in seeds_of_func:
                    if dummy_csv_file.iloc[n_seeds,0] in seed_of_func:
                        indices_to_keep.append(n_seeds)
            
            dataset_original=np.load('_'.join(dummy_csv_file.iloc[0,0].split('_')[0:-1])+'_dataset.npy')
            dataset_reduced=dataset_original[:,indices_to_keep]
            
            #pipe = Pipeline(steps=[("pca", PCA(n_components=0.8, svd_solver= 'full')), ("IsolationForest", IsolationForest())])
            #pipe.fit(dataset_reduced)
            clf=IsolationForest()
            clf.fit(dataset_reduced)
            
            os.chdir('../classifiers_outliers_detection_reduced_dataset')
            
            indices_to_keep.insert(0, 0)
            
            dummy_csv_file.iloc[indices_to_keep].to_csv('_'.join(dummy_csv_file.iloc[0,0].split('_')[0:-1])+'_sampling_coord.csv',header=False,index=False)
            
            dump(clf,
                 '_'.join(dummy_csv_file.iloc[0,0].split('_')[0:-1])+'_clf_isolation_forest.joblib'
                 )
            
            np.save('_'.join(dummy_csv_file.iloc[0,0].split('_')[0:-1])+'_dataset.npy',
                    dataset_reduced)
            
            os.chdir('../'+folders_with_classifier_to_change)
            
        os.chdir('../..')
                
if __name__ == "__main__":
    main()          
        
        
        
        
            
    
    