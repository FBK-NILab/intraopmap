#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan 30 10:51:19 2023

@author: ludovicocoletta
"""

import numpy as np
import glob
import os
import pandas as pd

def main():
    
    sub_folders=sorted(glob.glob('derivatives/*/sub-*/tracking_linear_reg'))
    
    #function='SENSORIAL'
    
    functions=['AMODAL_ANOMIA', 'ANOMIA', 'MENTALIZING', 'MOTOR', 'MOVEMENT_ARREST', 'PHONOLOGICAL', 'SEMANTIC', 'SENSORIAL', 'SPATIAL_PERCEPTION', 'SPEECH_ARREST', 'VERBAL_APRAXIA', 'VISUAL']
    
    count_across_subj=[None]*len(sub_folders)
    pos_dist_across_subj=[None]*len(sub_folders)
    neg_dist_across_subj=[None]*len(sub_folders)
    
    points_to_remove=np.loadtxt('REMOVED_SUB_CORTICAL_POINTS.txt',dtype='str').tolist()
    
    funcs=[ii.split('_')[0:-4] for ii in points_to_remove]
    coords=[ii.split('_')[-4:-1] for ii in points_to_remove]
    betw_string=[['from']]*len(points_to_remove)
    
    joint_str=list(zip(funcs,betw_string,coords))
    joint_str=['_'.join(['_'.join(ii[0]),ii[1][0],'_'.join(ii[2][:])]) for ii in joint_str]
    
    for function in functions:
        
        for ind,folder in enumerate(sub_folders):
            
            os.chdir(folder)
            
            pos_count=sorted(glob.glob('*'+function+'*positive_count.txt'))
            
            ind_to_remove=[]
            
            for ii in joint_str:
                for ind_of_int,rois in enumerate(pos_count):
                    if ii in rois:
                        ind_to_remove.append(ind_of_int)
            
            for ii in ind_to_remove:
                pos_count.remove(pos_count[ii])
            
            if function=='ANOMIA':
                pos_count=[ii for ii in pos_count if 'AMODAL_ANOMIA' not in ii ]
                pos_count=[ii for ii in pos_count if 'from_A_' not in ii]
            
            counts=np.zeros((len(pos_count),2))
            pos_dist=[]
            neg_dist=[]
            
            for iii in range(0,len(pos_count)):
                
                if os.stat(pos_count[iii]).st_size != 0:
                    counts[iii,0]=np.genfromtxt(pos_count[iii])
                
                if os.stat(pos_count[iii].replace('positive_count.txt', 'negative_count.txt')).st_size != 0:
                    counts[iii,1]=np.genfromtxt(pos_count[iii].replace('positive_count.txt', 'negative_count.txt'))
                    
                else: 
                        continue # As it appears that the dump file containing the length of the streamlines is not produced if there are no streamlines, we can skip to the next iteration
                    
            rows_to_delete=np.where((counts[:,0]==0)&(counts[:,1]==0))
            counts=np.delete(counts,rows_to_delete,0)
                
                
            count_across_subj[ind]=counts
            os.chdir('../../../..')
            
        
        perc_streams_across_seeds=[None]*len(count_across_subj)
        
        for iii in range(0,len(count_across_subj)):
            sum_across_col=np.sum(count_across_subj[iii],axis=1)
            perc_streams_across_seeds[iii]=[np.mean(np.divide(count_across_subj[iii][:,0],sum_across_col,out=np.zeros_like(count_across_subj[iii][:,0]),where=sum_across_col!=0)),
                                            np.mean(np.divide(count_across_subj[iii][:,1],sum_across_col,out=np.zeros_like(count_across_subj[iii][:,1]),where=sum_across_col!=0)),
                                            ]        
        
        
    
        pd.DataFrame(perc_streams_across_seeds,columns=['netw','anti-netw']).to_csv(function+'_report_by_subj_networks.csv')
    
if __name__ == "__main__":
    main()    
    