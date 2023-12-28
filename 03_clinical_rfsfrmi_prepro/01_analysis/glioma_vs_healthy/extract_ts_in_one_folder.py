from nilearn import image
from nilearn import regions
import numpy as np
import os
import glob
import time
from multiprocessing import Pool
#import scipy.io as sio

def extract_ts(subject_name):

   ts,labels=regions.img_to_signals_labels(image.load_img(subject_name,dtype='float64'), image.load_img(path_to_atlas), mask_img=None, background_label=0)

   sub_name_no_ending=('.').join(subject_name.split('/')[-1].split('.')[:-2])

   #adict = {}

   #adict[sub_name_no_ending] = ts

   #sio.savemat((sub_name_no_ending + '.mat'), adict)
   
   np.save(out_dir+'/'+sub_name_no_ending,ts)


def main():


   global path_to_atlas

   path_to_atlas='atlas_glasser_tian_sub_gm_only_N_414.nii.gz' #EDIT THIS, path to atlas
   
   global out_dir
   #out_dir=os.getcwd()
   out_dir='group_level'

   subjects=sorted(glob.glob('group_level/*as_ts.nii.gz'))

   pool = Pool(processes=8)

   pool.map(extract_ts, subjects)

# If called from the command line, run main()
if __name__ == '__main__':
   main()

