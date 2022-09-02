# -*- coding: utf-8 -*-
"""
Created on Mon Aug 22 15:33:06 2022

@author: mm
"""

import pandas as pd
import numpy as np

df_sub_1=pd.read_csv('batch_01_cortical_with_id_realigned_into_gyri_cleaned.csv')
df_sub_2=pd.read_csv('batch_02_cortical_with_id_realigned_into_gyri_cleaned.csv')

#df_sub_2_final=df_sub_2.drop([299])
#df_sub_2_final.to_csv('batch_02_subcortical_with_id_realigned_into_wm_cleaned.csv',sep=',',index=False)
#df_sub_2=pd.read_csv('batch_02_subcortical_with_id_realigned_into_wm_cleaned.csv')


df_sub_3=pd.read_csv('batch_03_cortical_with_id_realigned_into_gyri_cleaned.csv')
df_sub_4=pd.read_csv('batch_04_cortical_with_id_realigned_into_gyri_cleaned.csv')

df_sub=pd.concat([df_sub_1,df_sub_2,df_sub_3,df_sub_4],ignore_index=True)
df_sub.groupby('CATEGORY').count()

df=df_sub[(df_sub['CATEGORY'] == 'SENSORIAL') & (df_sub['X_MNI_LIN']>0) ]
df=df.iloc[:,[0,2,3,4]]

df.to_csv('SENSORIAL.txt', header=None, index=None, sep=' ', mode='w')