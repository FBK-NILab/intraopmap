#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Oct 26 19:39:38 2022

@author: ludovicocoletta

 POSITIVE AND NEGATIVE NEST ARE EXPECTED to be found in a folder called no_thr
"""

import glob
import numpy as np
import nibabel as nib
import os

def main():
    
    images_positive=sorted(glob.glob('no_thr/*POSITIVE*gz')) # path to unthr positive nets
    
    os.makedirs('bipartite_netw',exist_ok=True)
    
    for ii in range(0,len(images_positive)):
        
        cat=images_positive[ii].split('/')[-1].split('_POSITIVE_')[0]
        negative_image=glob.glob('no_thr/'+cat + '*NEGATIVE*gz')[0] # path to unthr negative nets
        
        negative_image=nib.load(negative_image)
        negative_image_data=negative_image.get_fdata()
        
        positive_img=nib.load(images_positive[ii])
        positive_img_data=positive_img.get_fdata()
        
        
        dummy_img=np.zeros_like(positive_img_data)
        dummy_array=np.where(positive_img_data>negative_image_data)
        dummy_img[dummy_array[0],dummy_array[1],dummy_array[2]]=1
        
        dummy_img_to_write=positive_img_data*dummy_img
        nii_=nib.Nifti1Image(dummy_img_to_write, affine=positive_img.affine, header=positive_img.header)
        nii_.to_filename('bipartite_netw/'+cat+'_positive.nii.gz')  

        
        dummy_img=np.zeros_like(positive_img_data)
        dummy_array=np.where(negative_image_data>positive_img_data)
        dummy_img[dummy_array[0],dummy_array[1],dummy_array[2]]=1
        
        dummy_img_to_write_b=negative_image_data*dummy_img
        
        dummy_img_to_write_final=dummy_img_to_write+dummy_img_to_write_b
        
        nii_=nib.Nifti1Image(dummy_img_to_write_b, affine=negative_image.affine, header=negative_image.header)
        nii_.to_filename('bipartite_netw/'+cat+'_negative.nii.gz')    
        
        
if __name__ == "__main__":
    main()                   
        
        
