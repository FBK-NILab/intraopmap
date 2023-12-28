#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov 28 10:38:44 2022

@author: ludovicocoletta
"""
import pandas as pd
import numpy as np
import nibabel as nib
import glob
import re
from joblib import load
import matplotlib.pyplot as plt
import os


def plot_scatter(data, labels,colors):
    
    # https://stackoverflow.com/questions/44982574/how-to-plot-vertical-scatter-using-only-matplotlib
    width=0.05
    fig, ax = plt.subplots()
    
    for i, l in enumerate(labels):
        x = np.ones(data.shape[0])*i + (np.random.rand(data.shape[0])*width-width/2.)
        ax.scatter(x, data[:,i], color=colors[i], s=25, alpha=0.5)
        mean = data[:,i].mean()
        ax.plot([i-width/2., i+width/2.],[mean,mean], color="k")
    
    #ax.set_xticks(range(len(labels)))
    ax.set_xticks(range(len(labels)))
    ax.set_xticklabels(labels)
    ax.set_ylim([-0.1, 0.15])
    ax.set_ylabel('Anomaly Score')
    
    plt.show()
    
    
def adjacent_values(vals, q1, q3):
    upper_adjacent_value = q3 + (q3 - q1) * 1.5
    upper_adjacent_value = np.clip(upper_adjacent_value, q3, vals[-1])

    lower_adjacent_value = q1 - (q3 - q1) * 1.5
    lower_adjacent_value = np.clip(lower_adjacent_value, vals[0], q1)
    return lower_adjacent_value, upper_adjacent_value


def set_axis_style(ax, labels):
    ax.xaxis.set_tick_params(direction='out')
    ax.xaxis.set_ticks_position('bottom')
    ax.set_xticks(np.arange(1, len(labels) + 1), labels=labels)
    ax.set_xlim(0.25, len(labels) + 0.75)
    #ax.set_xlabel('Sample name')
    
def violin_plot(data,labels,title):
    
    fig, ax = plt.subplots()
    ax.set_title(title)
    
    parts = ax.violinplot(
            data, showmeans=False, showmedians=False,
            showextrema=False)
    
    for pc in parts['bodies']:
        pc.set_facecolor('gold')
        pc.set_edgecolor('black')
        pc.set_alpha(0.8)
    
    quartile1, medians, quartile3 = np.percentile(data, [25, 50, 75], axis=0)
    
    #whiskers = np.array([
    #    adjacent_values(sorted_array, q1, q3)
    #    for sorted_array, q1, q3 in ([np.sort(data,axis=0)], quartile1, quartile3)])
    
    whiskers=adjacent_values(np.sort(data,axis=0), quartile1, quartile3)
    whiskers_min, whiskers_max = whiskers[0], whiskers[1]
    
    inds = np.arange(1, len(medians) + 1)
    ax.scatter(inds, medians, marker='o', color='white', s=30, zorder=3)
    ax.vlines(inds, quartile1, quartile3, color='k', linestyle='-', lw=5)
    ax.vlines(inds, whiskers_min, whiskers_max, color='k', linestyle='-', lw=1)
    
    # set style for the axes

    set_axis_style(ax, labels)
    
    plt.subplots_adjust(bottom=0.15, wspace=0.05)
    plt.show()


def main():
    
    path_to_sba_population='/home/ludovicocoletta/Documents/IntraOpMap_2022/04_preprocessed_rsfmri/00_draft/'
    N_sub=34 
    
    functions_of_interest=['ANOMIA','SEMANTIC','SENSORIAL','MOTOR', 'SPEECH_ARREST']
    #functions_of_interest=['SEMANTIC','ANOMIA']
    outliers_id=[]
    
    for indices, func_of_int in enumerate(functions_of_interest):
        
        list_of_coord=sorted(glob.glob(path_to_sba_population+'*'+func_of_int+'*'+'/classifiers_outliers_detection/'+'*.csv'))
        anomaly_scores=np.zeros((N_sub,len(list_of_coord)))
        
        stim_coord_for_df=[None]*len(list_of_coord)
        subs=[]
        stim_subjs=[]
        
        for ii in range(0,len(list_of_coord)):
            
            dummy_df=pd.read_csv(list_of_coord[ii],header=None)
            #dummy_df=pd.read_csv(list_of_coord[ii])
            coord_of_int=dummy_df.iloc[0,:].tolist()[0]
            #coord_of_int=dummy_df.iloc[:,1].tolist()[0]
            
            stim_coord_for_df[ii]='_'.join(coord_of_int.split('_')[-4:-1])
    
            sampling_points=dummy_df.iloc[:,0].tolist()
            sampling_points.remove(sampling_points[0])
            
            subj_maps=sorted(glob.glob('subject_maps/*'+coord_of_int+'*gz'[0]))
            
            subj_by_seeds=np.zeros((len(subj_maps),len(sampling_points)))
            
            for iii in range(0,len(subj_maps)):
                
                print(iii)
                #sub_id=subj_maps[iii].split('/')[-1].split('_pre_rest')[0]
                sub_map=nib.load(subj_maps[iii])
                sub_map_data=sub_map.get_fdata()
                
                for iiii in range(0,len(sampling_points)):
                    sam_point_image=nib.load(glob.glob('seeds_2mm/'+'*'+sampling_points[iiii]+'*gz')[0])
                    sam_point_image_data=sam_point_image.get_fdata()
                    subj_by_seeds[iii,iiii]=np.mean(sub_map_data[sam_point_image_data==1])
                
            clf=load(glob.glob(path_to_sba_population+'*'+
                               func_of_int+'*'+'/classifiers_outliers_detection/'+
                               list_of_coord[ii].split('/')[-1].split('_sampling_coord.csv')[0]+
                               '_clf_isolation_forest.joblib')[0])
            
            predictions=clf.predict(subj_by_seeds)
            print(np.where(predictions==-1)[0].shape)
            anomaly_scores[:,ii]=clf.decision_function(subj_by_seeds)
            
            sub_id=[iii.split('/')[-1].split('_pre_rest')[0] for iii in subj_maps]
            subs.append(sub_id)
            
            stim_sub=subj_maps[0].split('/')[-1].split('_2mm')[0].split('_')[-1]
            stim_subjs.append(stim_sub)
            
        
        outliers_id.append(np.unique(np.array(sub_id)[np.where(anomaly_scores<=0)[0]]).tolist())
        pd.DataFrame(anomaly_scores,columns=stim_coord_for_df,index=sub_id).to_csv(func_of_int+'_anomaly_scores.csv')

    outliers_per_func=list(zip([[iiii] for iiii in functions_of_interest],[iiii for iiii in outliers_id]))
        
if __name__ == "__main__":
    main()     
