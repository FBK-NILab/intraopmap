#!/bin/bash

cd group_level

for ii in *Tmean.nii.gz
do
    fslmerge -t ${ii%%.nii.gz}_as_ts.nii.gz $ii $ii    
done

cd ..



