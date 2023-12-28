#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Mar  5 11:24:47 2023

@author: ludovicocoletta
"""

import pandas as pd
import numpy as np
import nibabel as nib
import glob
from joblib import load
import matplotlib.pyplot as plt
import time

def main():
    
    path_to_class='/home/ludovicocoletta/Documents/IntraOpMap_2022/04_preprocessed_rsfmri/00_draft/classifier_meta_language/'
    N_sub=32 
    
    outliers_id=[]
    
    list_of_coord=sorted(glob.glob(path_to_class+'*.csv'))
    anomaly_scores=np.zeros((N_sub,len(list_of_coord)))
    
    stim_coord_for_df=[None]*len(list_of_coord)
    subs=[]
    stim_subjs=[]
    
    for ii in range(0,len(list_of_coord)):
        
        dummy_df=pd.read_csv(list_of_coord[ii],header=None)
        coord_of_int=dummy_df.iloc[0,:].tolist()[0]
        
        stim_coord_for_df[ii]=coord_of_int.split('/')[-1].split('_2mm_')[0]

        sampling_points=dummy_df.iloc[:,0].tolist()
        sampling_points.remove(sampling_points[0])
        sampling_points_stripped=[iii.split('/')[-1].split('_2mm_')[0] for iii in sampling_points]
        
        subj_maps=sorted(glob.glob('subject_maps/*'+coord_of_int.split('/')[-1].split('_2mm_')[0]+'*gz'[0]))
        subj_by_seeds=np.zeros((len(subj_maps),len(sampling_points)))
        
        start_time=time.time()
        
        for iii in range(0,len(subj_maps)):
            
            #print(iii)
            sub_map=nib.load(subj_maps[iii])
            sub_map_data=sub_map.get_fdata()
            
            for iiii in range(0,len(sampling_points)):
                sam_point_image=nib.load(sampling_points[iiii])
                sam_point_image_data=sam_point_image.get_fdata()
                subj_by_seeds[iii,iiii]=np.mean(sub_map_data[sam_point_image_data==1])
                
        clf=load(glob.glob(path_to_class+
                           list_of_coord[ii].split('/')[-1].split('_sampling_coord.csv')[0]+
                           '_clf_isolation_forest.joblib')[0])
        
        predictions=clf.predict(subj_by_seeds)
        print(np.where(predictions==-1)[0].shape)
        anomaly_scores[:,ii]=clf.decision_function(subj_by_seeds)
        
        sub_id=[iii.split('/')[-1].split('_pre_rest')[0] for iii in subj_maps]
        subs.append(sub_id)
        print(time.time()-start_time)
        
    pd.DataFrame(anomaly_scores,columns=stim_coord_for_df,index=sub_id).to_csv('meta_language_anomaly_scores_clinical_population_noDES.csv')
        
if __name__ == "__main__":
    main()   