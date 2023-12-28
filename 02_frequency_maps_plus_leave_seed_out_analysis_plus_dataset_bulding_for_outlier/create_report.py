#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 24 11:09:07 2022

@author: ludovicocoletta
"""
import pandas as pd
import glob
import os

csv_of_int=sorted(glob.glob('*.csv'))

os.makedirs('report', exist_ok=True)

for ii in csv_of_int:
    csv=pd.read_csv(ii,index_col=0)
    dummy_df=csv.quantile([0.1, .25, .5, 0.75, 0.9])
    with open('report/'+ii.split('.csv')[0]+'.txt', 'w') as f:
        
        print(('Report for ' + ii.split('.csv')[0]+'' +
               ('\n') +
              ' % of stim. points where concordance for positive FC > negative FC: ' +
              format((pd.Series.sum(csv.iloc[:,0]>csv.iloc[:,1])/len(csv)*100),'.4f')+
              '% '+ 
              '('+ 
              str(pd.Series.sum(csv.iloc[:,0]>csv.iloc[:,1]))+
              '/'+str(len(csv))+')'+
              ('\n')+
              '10th, 25th, median, 75th, and 90th percentile for positive FC concordance in the left out stim. point: '+
              format(dummy_df.iloc[0,0],'.4f')+
              ', '+
              format(dummy_df.iloc[1,0],'.4f') +
              ', ' +
              format(dummy_df.iloc[2,0],'.4f')+
              ', ' +
              format(dummy_df.iloc[3,0],'.4f')+
              ', ' +
              format(dummy_df.iloc[4,0],'.4f')+
              ('\n')+
              '10th, 25th, median, 75th, and 90th percentile for negative FC concordance in the left out stim. point: '+
              format(dummy_df.iloc[0,1],'.4f')+
              ', '+
              format(dummy_df.iloc[1,1],'.4f') +
              ', ' +
              format(dummy_df.iloc[2,1],'.4f')+
              ', ' +
              format(dummy_df.iloc[3,1],'.4f')+
              ', ' +
              format(dummy_df.iloc[4,1],'.4f')+
              ('\n')
              ),file=f)
        f.close()
        
        with open('report/'+ii.split('.csv')[0]+'_hub_thr.txt', 'w') as f:
            print(dummy_df.iloc[4,0],file=f)
        f.close()
