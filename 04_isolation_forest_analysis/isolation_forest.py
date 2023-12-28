#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Nov  8 11:34:08 2022

@author: ludovicocoletta
"""

from sklearn.ensemble import IsolationForest
import numpy as np
from joblib import dump
import glob
from sklearn.pipeline import Pipeline
from sklearn.decomposition import KernelPCA
from sklearn.decomposition import PCA

def main():
    
    dataset_files=sorted(glob.glob('*.npy'))
    
    for ii in range(0,len(dataset_files)):
        
        dataset=np.load(dataset_files[ii])

        pipe = Pipeline(steps=[("pca", PCA(n_components=0.8, svd_solver= 'full')), ("IsolationForest", IsolationForest())])
        pipe.fit(dataset)
        dump(pipe,dataset_files[ii].split('_dataset.npy')[0]+'_clf_isolation_forest.joblib')
    
    
if __name__ == "__main__":
    main()   
