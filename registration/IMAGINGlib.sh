#! /bin/bash

#########################################################################################################################
#########################################################################################################################
###################                             		            							      ###################
###################	title:	            	  Imaging library                                         ###################
###################	                                                                                  ###################
###################	description:	Library of functions for string manipulations                     ###################
###################                                                                                   ###################
###################	version:	    0.7.9.8.0                                                         ###################
################### notes:	        Install ANTs, FSL to use this library                             ###################
###################			        needs FILESlib.sh, STRlib.sh                                      ###################
###################	bash version:   tested on GNU bash, version 4.2.53                                ###################
###################                                                                                   ###################
###################	autor: gamorosino                                                                 ###################
################### email: g.amorosino@gmail.com                                                      ###################
###################                                                                                   ###################
#########################################################################################################################
#########################################################################################################################
###################                                                                                   ###################
###################	update:	add imm_T2Wsynth                                                          ###################
###################                                                                                   ###################
#########################################################################################################################
#########################################################################################################################


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/"
STRlib=${SCRIPT_DIR}"/STRlib.sh"
FILESlib=${SCRIPT_DIR}"/FILESlib.sh"
CPUlib=${SCRIPT_DIR}"/CPUlib.sh"
ARRAYlib=${SCRIPT_DIR}"/ARRAYlib.sh"
CSVPACK=${SCRIPT_DIR}"/csvpack.py"
IMAGINGPACK=${SCRIPT_DIR}"/imagingpack.py"
IMAGECONVERT=${SCRIPT_DIR}"/imageconvert.py"
source ${STRlib}
source ${FILESlib}
source ${CPUlib}
source ${ARRAYlib}



imm_spacing() { 
                ############# ############# ############# ############# ############# 
                #############     Stampa spacing dell'immagine		############# 
                ############# ############# ############# ############# #############  

		local stringspacing=$(PrintHeader $1 1)
		local sep="$2"
		[ -z $sep ] && { sep=',';}
		[ $sep == 'space' ] && { sep=' ';}
		local commaspacing=${stringspacing//'x'/$sep}
		echo ${commaspacing}
		
		};

imm_size() { 
                ############# ############# ############# ############# ############# 
                #############     Stampa dimensioni dell'immagine	############# 
                ############# ############# ############# ############# ############# 
                
                local stringsize=$(PrintHeader $1 2)
		local sep="$2"
		[ -z $sep ] && { sep=',';}
		[ $sep == 'space' ] && { sep=' ';}
		local commasize=${stringsize//'x'/$sep}
		echo ${commasize}

		};
		
imm_dim() {	
                ############# ############# ############# ############# ############# 
                #############     Stampa dimensionalità dell'immagine	############# 
                ############# ############# ############# ############# #############
                 	
		sizem=$(PrintHeader $1 2)
		dimm=$( grep -o "x" <<<"$sizem" | wc -l)
		dimm=$(( $dimm+1 ))
		echo $dimm
		
		};
		

maximum() {     
                ############# ############# ############# ############# ############# 
                #############     Calcolo del massimo di un immagine    ############# 
                ############# ############# ############# ############# #############   
                # deprecata
                
		local subs=$1;
		local dim=$( imm_dim $1 )
		local direct=$(dirname "${subs}");
		local nmc=`basename ${subs} | cut -d '.' -f 1`;
		local warplog=${direct}/"warplog"$(date +%s)".txt"
		local header=$(echo  $( MeasureMinMaxMean ${dim} ${subs} $warplog 1 ));
		local b="Max : [";
		local indexh=$( echo $( str_index "$header" "$b"));
		local maxstring=${header:indexh+${#b}:${#header}};
		local max=$( echo $maxstring | cut -d "]" -f1 );
		rm ${warplog} 2> "/dev/null"
		echo $max;
		
		};
		
imm_max() {     
                ############# ############# ############# ############# ############# 
                #############     Calcolo del massimo di un immagine    ############# 
                ############# ############# ############# ############# #############   
                
		local subs=$1;
		local dim=$( imm_dim $1 )
		local stasts=( $(ImageIntensityStatistics ${dim} ${1} ) )
		echo ${stasts[21]}
		};

minimum() {     
                ############# ############# ############# ############# ############# 
                #############      Calcolo del minimo di un immagine    ############# 
                ############# ############# ############# ############# #############   
                # deprecata              
                
		local subs=$1;
		local dim=$( imm_dim $1 )
		local direct=$(dirname "${subs}");
		local nmc=`basename ${subs} | cut -d '.' -f 1`;
		local warplog=${direct}/"warplog"$(date +%s)".txt"
		local header=$(echo  $( MeasureMinMaxMean ${dim} ${subs} $warplog 1 ));
		local b="Min : [";
		local indexh=$( echo $( str_index "$header" "$b"));
		local maxstring=${header:indexh+${#b}:${#header}};
		local max=$( echo $maxstring | cut -d "]" -f1 );
		rm ${warplog} 2> "/dev/null"
		echo $max;
		
		};
imm_min() {     
                ############# ############# ############# ############# ############# 
                #############     Calcolo del massimo di un immagine    ############# 
                ############# ############# ############# ############# #############   
                                
		local subs=$1;
		local dim=$( imm_dim $1 )
		local stasts=( $(ImageIntensityStatistics ${dim} ${1} ) )
		echo ${stasts[20]}
		
		};
		
extract_volume() { 
		        ############# ############# ############# ############# ############# 
		        #############     Estrae un volume 3D da un immagine 4D ############# 
		        ############# ############# ############# ############# #############
		        
			local input=$1
			local output=$2
			local index=$3	
			fslroi $input $output  0 -1  0 -1  0 -1 $index 1
		  };



extract_allvolumes () {

		        ############# ############# ############# ############# ############# 
		        ############# Estrae tutti i volumi 3D da un immagine 4D ############# 
		        ############# ############# ############# ############# #############
		        
		        if [ $# -lt 1 ]; then							# usage of the function							
			    echo $0: "usage: extract_allvolumes <file_in> [ <output_dir> ] [ <basename> ] [ <nthreads> ]"
			    return 1;		    
			fi 

			local input=$1
			local output_dir=$2
			[ -z "${output_dir}" ] && { output_dir=$( dirname ${input} )"/"$( fbasename ${input} ); }
			local fbase=$3
			[ -z "${fbase}" ] && { fbase=$( fbasename $input ); }
			local output_f=${output_dir}"/"${fbase}
			local nthreads=$4
			mkdir -p $output_dir
			local shape=( $( imm_size $input "space") )
			echo "image shape: "${shape[@]}			
			local N="${shape[3]}"
			
			if [ -z $nthreads ]; then

				for ((i=0;i<$N;i++)) do
				
				
					local number=`printf "%04d" ${i}`;
					echo ${output_f}"_"${number} "extracted"				
					extract_volume $input ${output_f}"_"${number} ${i} 
		
				done
			else

				( expr "$nthreads" : '-\?[0-9]\+$' >/dev/null ) || { echo "integer expression expected for nthreads argument"; return -1; }


				for ((i=0;i<$N;i++)) do
				
				
					local number=`printf "%04d" ${i}`;
					echo ${output_f}"_"${number} "extracted"				
					extract_volume $input ${output_f}"_"${number} ${i} &
					waiting4script  fslroi ${nthreads} 0

				done

				while [ $( ls ${output_f}"_"* | wc -l ) -ne ${N} ]; do
					nnow=$( ls ${output_f}"_"* | wc -l )
					wtnumber=$( echo $(echo "scale=4; ${nnow}/${N} * 100  " | bc) );
					echo -ne "${wtnumber:0:-2}"% done " ("${nnow}" vs "${N}")\033[0K\r"
				done
				#waiting4script  fslroi 1 0
				
			fi

			};


remove_volumes	() {


           ############# ############# ############# ############# ############# ############# #############
           #############              Remove a list of volumes froma  4D NifTI                 ############# 
           ############# ############# ############# ############# ############# ############# #############  

			if [ $# -lt 1 ]; then							# usage of the function							
			    echo $0: "usage: remove_volumes <file_in> <file_out> <index_list> <nthreads>"
			    return 1;		    
			fi 

			file_in=$1
			file_out=$2			
			index_comma="${3}"
			nthreads=$4
			index_list=( ${index_comma//','/' '} )
			temp_dir=$( dirname ${file_in})"/temp_"$( date +%s )
			temp_name="vol"
			extract_allvolumes $file_in $temp_dir $temp_name $nthreads
			
			for i in ${index_list[@]};
				do
				
				local number=`printf "%04d" ${i}`;
				to_delete=${temp_dir}"/vol_"${number}".nii.gz"
			
				if [ $( exists ${to_delete} ) -eq 1 ] ; then
					
					rm ${to_delete}

				else

				echo "volume " $i "does not exists"
				return -1

				fi 

	
			done;
			
			echo "Merging of the remaining volumes"

			fslmerge -t $file_out $temp_dir/vol*		
			
			[ $( exists ${temp_dir} ) -eq 1 ] && { rm -rf ${temp_dir} ; }
			
	
			};

			
			
imm_reorient () {
		        ############# ############# ############# ############# ############# ############# ############# 
		        #############   Registrazione Rigida della Immagine su template space (exp: ACPC)   ############# 
		        ############# ############# ############# ############# ############# ############# #############

			if [ $# -lt 3 ]; then							# usage of the function							
			    echo $0: "usage: imm_reorient <file_in.ext> <file_out.ext> <file_target.ext> [<nthreads>] [<do_bet>]"
			    return 1;		    
			fi 

			local T2_file=$1
			local reoriented=$2
			local template=$3
			local nthreads=$4
			local do_bet=$5
			local dim=$( imm_dim $1 )
			local dir_T2=$( dirname $T2_file )"/"
			local T2_basename=$( fbasename $T2_file )				
			local reo_dir=$( dirname ${reoriented} )
			local reo_ext=$( fextension ${reoriented} )
			mkdir -p ${reo_dir}
			local T2_brain=${reo_dir}/${T2_basename}_brain.nii.gz
			local reorient_niigz=${reo_dir}"/"$( fbasename ${reoriented} )".nii.gz"
			local reorient_nii=${reo_dir}"/"$( fbasename ${reoriented} )".nii"
			[ -z ${do_bet} ] && { do_bet=1; }
			[ -n "${nthreads}" ] && {  [ "${nthreads}" ==  "auto" ] && { nthreads=$( CPUs_available ); }; setITKthreads ${nthreads} ; }\
					      || { nthreads=2; setITKthreads ${nthreads} ; }
			echo "number of Threads for ANTs: " ${nthreads}	
			( [ "${reoriented}" == "${reorient_nii}" ]   &&   [ $( exists ${reorient_niigz} ) -eq 1 ] ) &&\
				{ rm ${reorient_niigz}; }
			( [ "${reoriented}" == "${reorient_niigz}" ] &&   [ $( exists ${reorient_nii} ) -eq 1 ]   ) &&\
				{ rm ${reorient_nii}; }
			if [ ${do_bet} -eq 1 ]; then
				[ $( exists ${T2_brain} ) -eq 0 ] && { bet ${T2_file} ${T2_brain} -m -R -v; T2_toreg=${T2_brain};}
			else
				T2_toreg=${T2_file};
			fi
			ANTS 3 \
			     	-m CC[${template},${T2_toreg},1,4] \
			     	-o ${reo_dir}/${T2_basename}_2MNI_\
			     	-i 0 -v  \
			     	-r Gauss[3,0.5] \
			     	--number-of-affine-iterations 10000x1000x1000 \
			     	--do-rigid
			antsApplyTransforms \
			     	-d ${dim} \
			     	-i ${T2_file} \
			     	-o ${reoriented} \
			     	-r ${template} \
			     	-t ${reo_dir}/${T2_basename}_2MNI_Affine.txt \
	 		     	-n BSpline
	 		     	
			max_reo=$( imm_max ${reoriented} )
			reo_thr=${reo_dir}"/"$( fbasename ${reoriented} )"_thr"$(date +%s)".nii.gz"		
			ThresholdImage ${dim} ${reoriented} ${reo_thr} 0 ${max_reo}
			ImageMath ${dim} ${reoriented} m ${reoriented} ${reo_thr}
			rm ${reo_thr}
			fslmaths ${reoriented} -thr 0 ${reoriented}
			echo "Reorientation done"
		};
		

imm_flip_as () {
		
		#########################################################################################################################
		###################	        	Flip (and transpose) a image to match another                 ###################
		#########################################################################################################################


		if [ $# -lt 2 ]; then							# usage of the function							
		    echo $0: usage: "imm_flip_as <file_toflip.ext> <file_fixed.ext> [ <output_file.ext> ]"		
		    return 1
		fi


		input1=$1
		input2=$2
		input3=$3


python << END


import os
import nibabel as nib
import numpy as np
import sys
def filp_as( file_path_toflip, file_path_fixed, *args):


	
				image_toflip = nib.load(file_path_toflip)
				head_toflip = image_toflip.get_header()
				affine_toflip = image_toflip.get_affine()
				ArrayNii_toflip = image_toflip.get_data()

				image_fixed = nib.load(file_path_fixed)
				head_fixed = image_fixed.get_header()
				affine_fixed = image_fixed.get_affine()
				ArrayNii_fixed = image_fixed.get_data()

				try:
					filename_flipped = args[0]
					if not filename_flipped:
						file_nm=file_path_toflip[0:file_path_toflip.rfind('.')]
						if file_path_toflip[file_path_toflip.rfind('.'):] == ".gz":
							file_nm = file_nm[0:file_nm.rfind('.')]    
						filename_flipped = file_nm + '_flipped' + ".nii.gz"
			  			
			    	except IndexError:
					file_nm=file_path_toflip[0:file_path_toflip.rfind('.')]
					if file_path_toflip[file_path_toflip.rfind('.'):] == ".gz":
						file_nm = file_nm[0:file_nm.rfind('.')]    
					filename_flipped = file_nm + '_flipped' + ".nii.gz"

				combinations=[['','','','','','','0','1','2'],['-1','-1','','','','','0','1','2'],['','','-1','-1','','','0','1','2'],['','','','','-1','-1','0','1','2'],['-1','-1','-1','-1','','','0','1','2'],['-1','-1','','','-1','-1','0','1','2'],['','','-1','-1','-1','-1','0','1','2'],['-1','-1','-1','-1','-1','-1','0','1','2'],['','','','','','','0','2','1'],['-1','-1','','','','','0','2','1'],['','','-1','-1','','','0','2','1'],['','','','','-1','-1','0','2','1'],['-1','-1','-1','-1','','','0','2','1'],['-1','-1','','','-1','-1','0','2','1'],['','','-1','-1','-1','-1','0','2','1'],['-1','-1','-1','-1','-1','-1','0','2','1'],['','','','','','','1','0','2'],['-1','-1','','','','','1','0','2'],['','','-1','-1','','','1','0','2'],['','','','','-1','-1','1','0','2'],['-1','-1','-1','-1','','','1','0','2'],['-1','-1','','','-1','-1','1','0','2'],['','','-1','-1','-1','-1','1','0','2'],['-1','-1','-1','-1','-1','-1','1','0','2'],['','','','','','','1','2','0'],['-1','-1','','','','','1','2','0'],['','','-1','-1','','','1','2','0'],['','','','','-1','-1','1','2','0'],['-1','-1','-1','-1','','','1','2','0'],['-1','-1','','','-1','-1','1','2','0'],['','','-1','-1','-1','-1','1','2','0'],['-1','-1','-1','-1','-1','-1','1','2','0'],['','','','','','','2','0','1'],['-1','-1','','','','','2','0','1'],['','','-1','-1','','','2','0','1'],['','','','','-1','-1','2','0','1'],['-1','-1','-1','-1','','','2','0','1'],['-1','-1','','','-1','-1','2','0','1'],['','','-1','-1','-1','-1','2','0','1'],['-1','-1','-1','-1','-1','-1','2','0','1'],['','','','','','','2','1','0'],['-1','-1','','','','','2','1','0'],['','','-1','-1','','','2','1','0'],['','','','','-1','-1','2','1','0'],['-1','-1','-1','-1','','','2','1','0'],['-1','-1','','','-1','-1','2','1','0'],['','','-1','-1','-1','-1','2','1','0'],['-1','-1','-1','-1','-1','-1','2','1','0'] ];


				ArrayNii_toflip=np.nan_to_num(ArrayNii_toflip)
				ArrayNii_fixed=np.nan_to_num(ArrayNii_fixed)
				ArrayNii_fixed_flatten=ArrayNii_fixed.flatten()	

				norm=np.zeros([len(combinations)])

				for idx,comb in enumerate(combinations):
					exec("ArrayNii_flipped=ArrayNii_toflip["+comb[0]+"::"+comb[1]+","+comb[2]+"::"+comb[3]+","+comb[4]+"::"+comb[5]+"].transpose("+comb[6]+", "+comb[7]+", "+comb[8]+")")
					diff = ArrayNii_flipped.flatten() - ArrayNii_fixed_flatten	
					norm[idx]=np.dot(diff, diff)
					print norm[idx]

				norm_min=norm.min()
				comb_=np.where(norm == norm_min)
				idxx=comb_[0][0]

				comb=combinations[idxx]
				exec("ArrayNii_flipped=ArrayNii_toflip["+comb[0]+"::"+comb[1]+","+comb[2]+"::"+comb[3]+","+comb[4]+"::"+comb[5]+"].transpose("+comb[6]+", "+comb[7]+", "+comb[8]+")")

				nii_flipped = nib.Nifti1Image(ArrayNii_flipped, affine=affine_fixed, header=head_fixed)
				nii_flipped.to_filename(filename_flipped)

				print "Flipped file save as: "+filename_flipped	

				norm_new=norm.copy()
				norm_new[idxx]=max_value = np.finfo(norm_new.dtype).max
				norm_min_new=norm_new.min()
				if norm_min_new > 0.5*norm_min:
					print "Warning: find two similarity metrics values very close."
			 
					comb_=np.where(norm_new == norm_min_new)
					idxx=comb_[0][0]
					comb=combinations[idxx]
					exec("ArrayNii_flipped_second=ArrayNii_toflip["+comb[0]+"::"+comb[1]+","+comb[2]+"::"+comb[3]+","+comb[4]+"::"+comb[5]+"].transpose("+comb[6]+", "+comb[7]+", "+comb[8]+")")

					nii_flipped_second = nib.Nifti1Image(ArrayNii_flipped_second, affine=affine_fixed, header=head_fixed)
					file_nm=filename_flipped[0:filename_flipped.rfind('.')]
					if filename_flipped[filename_flipped.rfind('.'):] == ".gz":
						file_nm = file_nm[0:file_nm.rfind('.')]    
					filename_flipped_second = file_nm + '_2nd' + ".nii.gz"
					nii_flipped_second.to_filename(filename_flipped_second)
					print "Flipped second file save as: "+filename_flipped_second


	
filp_as( '$input1', '$input2', '${input3}')

END
};


imm_flip () {
		
		#########################################################################################################################
		###################	        	Flip (and transpose) a image to match another                 ###################
		#########################################################################################################################


		if [ $# -lt 2 ]; then							# usage of the function							
		    echo $0: usage: "imm_flip <file_toflip.ext> <axis> [<output_file.ext>] [<reference.ext>]"
		    echo            "axis: X or Y or Z"		
		    return 1
		fi


		input1=$1
		input2=$2
		input3=$3
		input4=$4


python << END


import os
import nibabel as nib
import numpy as np
import sys
def imm_flip( file_path_toflip, axis, *args,**kwargs):
      


				
				image_toflip = nib.load(file_path_toflip)
				head_toflip = image_toflip.get_header()
				affine_toflip = image_toflip.get_affine()
				ArrayNii_toflip = image_toflip.get_data()
				
				reference = kwargs.get('reference', None)

				if reference == '':
					reference=None

				try:
					filename_flipped = args[0]
					if not filename_flipped:
						file_nm=file_path_toflip[0:file_path_toflip.rfind('.')]
						if file_path_toflip[file_path_toflip.rfind('.'):] == ".gz":
							file_nm = file_nm[0:file_nm.rfind('.')]    
						filename_flipped = file_nm + '_flipped'+ axis + ".nii.gz"
			  			
			    	except IndexError:
					file_nm=file_path_toflip[0:file_path_toflip.rfind('.')]
					if file_path_toflip[file_path_toflip.rfind('.'):] == ".gz":
						file_nm = file_nm[0:file_nm.rfind('.')]    
					filename_flipped = file_nm + '_flipped' + axis + ".nii.gz"
				
				
				if len(ArrayNii_toflip.shape) == 3:
					if  axis=="X":
					      ArrayNii_flipped=ArrayNii_toflip[::-1, :,:]
					    
					elif  axis=="Y":
					      ArrayNii_flipped=ArrayNii_toflip[:, ::-1,:]
					   
					elif axis=="Z":
					      ArrayNii_flipped=ArrayNii_toflip[:,:, ::-1]
					    
				elif len(ArrayNii_toflip.shape) == 4:

					if  axis=="X":
					      ArrayNii_flipped=ArrayNii_toflip[::-1, :,:,:]
					    
					elif  axis=="Y":
					      ArrayNii_flipped=ArrayNii_toflip[:, ::-1,:,:]
					   
					elif axis=="Z":
					      ArrayNii_flipped=ArrayNii_toflip[:,:, ::-1,:]


				if reference is not None:
					reference_nii = nib.load(reference)
					head_toflip = reference_nii.get_header()
					affine_toflip = reference_nii.get_affine()

				nii_flipped = nib.Nifti1Image(ArrayNii_flipped, affine=affine_toflip, header=head_toflip)
				nii_flipped.to_filename(filename_flipped)

			
  


	
imm_flip( '$input1', '$input2', '${input3}', reference='${input4}')

END
};



imm_header_as () {
		
		#########################################################################################################################
		###################	        	Put the header of an image to other                 ###################
		#########################################################################################################################


		if [ $# -lt 2 ]; then							# usage of the function							
		    echo $0: usage: "imm_header_as <input.ext> <reference.ext> <output>"	
		    return 1
		fi


		input1=$1
		input2=$2
		input3=$3


python << END


import os
import nibabel as nib
import numpy as np
import sys
def imm_header_as( file_path_toflip, reference, filename_flipped):
      


				
				image_toflip = nib.load(file_path_toflip)
				ArrayNii_toflip = image_toflip.get_data()


				reference_nii = nib.load(reference)
				head_toflip = reference_nii.get_header()
				affine_toflip = reference_nii.get_affine()

				nii_flipped = nib.Nifti1Image(ArrayNii_toflip, affine=affine_toflip, header=head_toflip)
				nii_flipped.to_filename(filename_flipped)

			
  


	
imm_header_as( '$input1', '$input2', '${input3}')

END
};


imm_normalize () {
		
		if [ $# -lt 2 ]; then							# usage of the function							
		    echo $0: usage: "imm_normalize <imm_input.ext> <imm_output.ext>"		
		    return 1
		fi
		
		local input_=$1
		local output_=$2			
		local max_imm=$( imm_max "${input_}" )
		local min_imm=$( imm_min "${input_}" )
		local range_imm=$( echo "${max_imm} - ${min_imm}" | bc )
		fslmaths ${input_} -sub  ${min_imm} ${output_}
		fslmaths ${output_} -div ${range_imm} ${output_}
}
imm_setAverage () {

		if [ $# -lt 2 ]; then							# usage of the function							
		    echo $0: usage: "imm_setAverage <imm_input.ext> <imm_output.ext> [<value>]"		
		    return 1
		fi

		local input_=$1
		local output_=$2
		local MEAN_INTENSITY=$3
		[ -z ${MEAN_INTENSITY} ] && { MEAN_INTENSITY=100; }
		AVERAGE=$(fslstats ${input_} -M)
		fslmaths ${input_} \
			 -div ${AVERAGE} \
			 -mul ${MEAN_INTENSITY} \
			 ${output_}
 }	

imm_T1basicProc () {

		if [ $# -lt 1 ]; then							# usage of the function							
		    echo $0: usage: "imm_T1basicProc <imm_input.ext> [<nthreads>]"		
		    return 1
		fi

		local fsl_dir=$( dirname $( dirname $( which fsl ) ) )
		local template_dir=${fsl_dir}"/data/standard/"
		local template=${template_dir}"MNI152_T1_1mm.nii.gz"
		local input_=$1
		local nthreads=$2

		[ -z $nthreads ] && { nthreads=2; }
		[ "$nthreads" == "auto" ] && { nthreads=$( CPUs_available ); }

		setITKthreads ${nthreads}
		
		local input_N4=$( remove_ext $input_	)"_N4.nii.gz"
		[ $( exists $input_N4 ) -eq 0 ] && { N4BiasFieldCorrection -d 3 -i $input_ -o $input_N4 -v  ; }
		local input_N4_reo=$( remove_ext $input_N4	)"_reoriented.nii.gz"
		imm_reorient $input_N4 $input_N4_reo $template $nthreads 0
 }


imm_unpackSeg() {

		if [ $# -lt 1 ]; then							# usage of the function							
		    echo $0: usage: "imm_unpackSeg <segmentation.ext> [<output_folder>]"		
		    return 1
		fi	

		local seg=$1
		local ofolder=$2
		local dim=$( imm_dim $seg )
		[ -z ${ofolder} ] && { ofolder=$( dirname $seg )'/'$( fbasename $seg )'_unpackSeg/' ; }
		mkdir -p $ofolder
		local N_labels=$( imm_max $seg )
		local first_label=$( imm_min $seg )
		[ ${first_label} -eq 0 ] && { first_label=1; }
		for (( i=$first_label; i<=N_labels; i++ )); do

			local label=${ofolder}'/'$( fbasename $seg )'_'${i}'.nii.gz'
			ThresholdImage ${dim} $seg $label ${i} ${i}

			local V_stats=( $( fslstats  ${label} -V ) )
			
			[ ${V_stats[0]} -eq 0 ] && { rm ${label} ; }

		done

		}

imm_seg25tt () {

		if [ $# -lt 1 ]; then							# usage of the function							
		    echo $0: usage: "imm_SegTo5tt <segmentation.ext> [<output.ext>] [<labels_order>] [<add_zeros>]"		
		    return 1
		fi	
	
		local seg=$1
		local output=$2
		local label_order=$3
		local add_zeros=$4
		
		[ -z ${output} ] && { output=$( dirname $seg )'/'$( fbasename $seg )'_5tt.nii.gz' ; }
		[ -z ${label_order} ] && { label_order="None"; }
		[ -z ${add_zeros} ] && { add_zeros=0 ; }

		local temp_dir=$( dirname $seg )'/imm_SegTo5tt_temp'$( date +%s )		
		
		imm_unpackSeg $seg $temp_dir

		if [ ${label_order} == "None" ]; then

			fslmerge -t ${output} ${temp_dir}'/'*


		else

			local label_order=( ${label_order//','/' '} )

			local merg_list=''

			for i in  ${label_order[@]}; do
				
				merg_list=${merg_list}' '${temp_dir}'/'$( fbasename $seg )'_'${i}'.nii.gz'

			done

			fslmerge -t ${output} ${merg_list}
			

		fi
		
		if [  ${add_zeros} -eq 1 ]; then
				zeros=${temp_dir}'/zeros'$( date +%s )'.nii.gz'
				fslmaths ${seg} -sub ${seg} ${zeros}
				fslmerge -t ${output} ${output} ${zeros}
		fi

		
		rm -rf ${temp_dir}


		}





imm_assign_aseglabel () {




			local i=$1
			local label=$2
			local seg=${3}			
			local seg_type=${4}
			local csf_seg=${5}
			local gm_seg=${6}
			local wm_seg=${7}
			local dgm_seg=${8}
			local trunk_seg=${9}
			local crbllm_seg=${10}
			

							


				# PTBP Segmentation style

				# CSF aseg components
		
				# 24  CSF                                     60  60  60  0
				# 14  3rd-Ventricle                           204 182 142 0
				# 15  4th-Ventricle                           42  204 164 0
				# 43  Right-Lateral-Ventricle                 120 18  134 0
				# 44  Right-Inf-Lat-Vent                      196 58  250 0
				# 5   Left-Inf-Lat-Vent                       196 58  250 0
				# 4   Left-Lateral-Ventricle                  120 18  134 0
				
			

				csf_components=( 24 14 15 43 44 4 5) 

				# Gray Matter aseg components

				# 3   Left-Cerebral-Cortex                    205 62  78  0
				# 42  Right-Cerebral-Cortex                   205 62  78  0
				# 220 Cerebral_Cortex                         205 63  78  0

				gm_components=( 3 42 20 )

				#White Matter aseg components

				# 2   Left-Cerebral-White-Matter              245 245 245 0
				# 41  Right-Cerebral-White-Matter             0   225 0   0
				# 219 Cerebral_White_Matter                   0   226 0   0
				# 223 Cerebral_White_Matter_Edge              226 0   0   0
				# 250 Fornix                                  255 0   0   0
				# 251 CC_Posterior                            0   0   64  0
				# 252 CC_Mid_Posterior                        0   0   112 0
				# 253 CC_Central                              0   0   160 0
				# 254 CC_Mid_Anterior                         0   0   208 0
				# 255 CC_Anterior                             0   0   255 0
				# 77  WM-hypointensities                      200 70  255 0
				
				wm_components=( 2  41 219 223 250 251 252 253 254 255 77)
		
				# Deep Gray Matter

				# 11  Left-Caudate                            122 186 220 0
				# 50  Right-Caudate                           122 186 220 0
				# 12  Left-Putamen                            236 13  176 0
				# 51  Right-Putamen                           236 13  176 0
				# 136 Left-Caudate/Putamen                    21  39  132 0
				# 137 Right-Caudate/Putamen                   21  39  132 0
				# 9   Left-Thalamus                           0   118 14  0
				# 10  Left-Thalamus-Proper                    0   118 14  0
				# 48  Right-Thalamus                          0   118 14  0
				# 49  Right-Thalamus-Proper                   0   118 14  0
				# 13  Left-Pallidum                           12  48  255 0
				# 52  Right-Pallidum                          13  48  255 0
				# 53  Right-Hippocampus                       220 216 20  0
				# 17  Left-Hippocampus                        220 216 20  0
				# 19  Left-Insula                             80  196 98  0
				# 55  Right-Insula                            80  196 98  0
		 		# 20  Left-Operculum                          60  58  210 0
				# 56  Right-Operculum                         60  58  210 0
				# 18  Left-Amygdala                           103 255 255 0
				# 54  Right-Amygdala                          103 255 255 0
				# 96  Left-Amygdala-Anterior                  205 10  125 0
				# 97  Right-Amygdala-Anterior                 205 10  125 0
				# 218 Amygdala                                104 255 255 0
				# 26  Left-Accumbens-area                     255 165 0   0
				# 58  Right-Accumbens-area                    255 165 0   0
				# 27  Left-Substancia-Nigra                   0   255 127 0
				# 59  Right-Substancia-Nigra                  0   255 127 0
				# 60  Right-VentralDC                         165 42  42  0
				# 28  Left-VentralDC                          165 42  42  0

				dgm_components=( 11 50 12 51 136 137 9 10 48 49 13 52 53 17 19 55 \
						 20 56 18 54 96 97 218 26 58 27 59 60 28)
	
				# Cerebellum aseg components

				# 6   Left-Cerebellum-Exterior                0   148 0   0
				# 7   Left-Cerebellum-White-Matter            220 248 164 0
				# 8   Left-Cerebellum-Cortex                  230 148 34  0
				# 45  Right-Cerebellum-Exterior               0   148 0   0
				# 46  Right-Cerebellum-White-Matter           220 248 164 0
				# 47  Right-Cerebellum-Cortex                 230 148 34  0
		
				crbllm_components=( 6 7 8 45 46 47 )

		
				# Trunk aseg components 

				# 16  Brain-Stem                              119 159 176 0

				trunk_components=( 16 )

				# Other Structures

				# 85  Optic-Chiasm                            234 169 30  0
				# 31  Left-choroid-plexus                     0   200 200 0
				# 63  Right-choroid-plexus                    0   200 221 0
				# 62  Right-vessel                            160 32  240 0
				# 31  Left-choroid-plexus                     0   200 200 0

				other_components=( 31 62 63 85 )

			
				# GM,DGM,WM,CSF 

  				dgm_components_all=( ${dgm_components[@]} )
				gm_components_all=( ${gm_components[@]}  ${crbllm_components[2]} ${crbllm_components[5]} )
				wm_components_all=( ${wm_components[@]} ${crbllm_components[1]} ${crbllm_components[4]} ${trunk_components[@]} )
				csf_components_all=( ${csf_components[@]} ${crbllm_components[6]} ${csf_components[45]}  )

				# GM,WM,CSF 
				
				gm_dgm_components_all=( ${gm_components_all[@]} ${dgm_components_all[@]}  )


			local dim=$( imm_dim $seg	 )

			ThresholdImage ${dim} $seg $label ${i} ${i}

			local V_stats=( $( fslstats  ${label} -V ) )
			
			if [ ${V_stats[0]} -eq 0 ]; then
				rm ${label} ; 


			else

				case $seg_type in
		     





		  			1|3tissue)

					if [ $( array_iselement $i ${csf_components_all[@]} ) -eq 1 ]; then
						
						csf_dir=$( dirname $csf_seg )"/"$( fbasename  $csf_seg )"/"
						mkdir -p $csf_dir
						mv  $label ${csf_dir}"/"$( fbasename  $csf_seg )"_"${i}".nii.gz"

		
					elif [ $( array_iselement $i ${wm_components_all[@]} ) -eq 1 ]; then
		
						wm_dir=$( dirname $wm_seg )"/"$( fbasename  $wm_seg )
						mkdir -p $wm_dir
						mv  $label ${wm_dir}"/"$( fbasename  $wm_seg )"_"${i}".nii.gz"
							

					elif [ $( array_iselement $i ${gm_dgm_components_all[@]} ) -eq 1 ]; then
						
						gm_dir=$( dirname $gm_seg )"/"$( fbasename  $gm_seg )
						mkdir -p $gm_dir
						mv  $label ${gm_dir}"/"$( fbasename  $gm_seg )"_"${i}".nii.gz"


					fi
					;;


		  			2|4tissue)

					if [ $( array_iselement $i ${csf_components_all[@]} ) -eq 1 ]; then
						
						csf_dir=$( dirname $csf_seg )"/"$( fbasename  $csf_seg )"/"
						mkdir -p $csf_dir
						mv  $label ${csf_dir}"/"$( fbasename  $csf_seg )"_"${i}".nii.gz"

		
					elif [ $( array_iselement $i ${wm_components_all[@]} ) -eq 1 ]; then
		
						wm_dir=$( dirname $wm_seg )"/"$( fbasename  $wm_seg )
						mkdir -p $wm_dir
						mv  $label ${wm_dir}"/"$( fbasename  $wm_seg )"_"${i}".nii.gz"
							

					elif [ $( array_iselement $i ${gm_components_all[@]} ) -eq 1 ]; then
						
						gm_dir=$( dirname $gm_seg )"/"$( fbasename  $gm_seg )
						mkdir -p $gm_dir
						mv  $label ${gm_dir}"/"$( fbasename  $gm_seg )"_"${i}".nii.gz"

					


					elif [ $( array_iselement $i ${dgm_components_all[@]} ) -eq 1 ]; then
						
						gm_dir=$( dirname $gm_seg )"/"$( fbasename  $gm_seg )
						mkdir -p $gm_dir
						mv  $label ${gm_dir}"/"$( fbasename  $gm_seg )"_"${i}".nii.gz"

						

					fi
					;;


		  			3|PTBP)


					if [ $( array_iselement $i ${csf_components[@]} ) -eq 1 ]; then
						
						csf_dir=$( dirname $csf_seg )"/"$( fbasename  $csf_seg )"/"
						mkdir -p $csf_dir
						mv  $label ${csf_dir}"/"$( fbasename  $csf_seg )"_"${i}".nii.gz"

		
					elif [ $( array_iselement $i ${wm_components[@]} ) -eq 1 ]; then
		
						wm_dir=$( dirname $wm_seg )"/"$( fbasename  $wm_seg )
						mkdir -p $wm_dir
						mv  $label ${wm_dir}"/"$( fbasename  $wm_seg )"_"${i}".nii.gz"
							

					elif [ $( array_iselement $i ${gm_components[@]} ) -eq 1 ]; then
						
						gm_dir=$( dirname $gm_seg )"/"$( fbasename  $gm_seg )
						mkdir -p $gm_dir
						mv  $label ${gm_dir}"/"$( fbasename  $gm_seg )"_"${i}".nii.gz"

					elif [ $( array_iselement $i ${dgm_components[@]} ) -eq 1 ]; then
						dgm_dir=$( dirname $dgm_seg )"/"$( fbasename  $dgm_seg )
						mkdir -p $dgm_dir
						mv  $label ${dgm_dir}"/"$( fbasename  $dgm_seg )"_"${i}".nii.gz"

					elif [ $( array_iselement $i ${trunk_components[@]} ) -eq 1 ]; then
						trunk_dir=$( dirname $trunk_seg )"/"$( fbasename  $trunk_seg )
						mkdir -p $trunk_dir
						mv  $label ${trunk_dir}"/"$( fbasename  $trunk_seg )"_"${i}".nii.gz"


					elif [ $( array_iselement $i ${crbllm_components[@]} ) -eq 1 ]; then

						crbllm_dir=$( dirname $crbllm_seg )"/"$( fbasename  $crbllm_seg )
						mkdir -p $crbllm_dir
						mv  $label ${crbllm_dir}"/"$( fbasename  $crbllm_seg )"_"${i}".nii.gz"

					fi

					;;

					
				esac

					if [ $( array_iselement $i ${other_components[@]} ) -eq 1 ]; then

						other_dir=$( dirname $csf_seg )"/Other_structures/"
						mkdir -p $other_dir
						case $i in
							 31 )
								mv  $label ${other_dir}"/Left_choroid_plexus.nii.gz"
								;;
							 63 )
								mv  $label ${other_dir}"/Right_choroid_plexus.nii.gz"
								;;
							 62 )
								mv  $label ${other_dir}"/Right_vessel.nii.gz"
								;;
							 85 )
								mv  $label ${other_dir}"/Left_choroid_plexus.nii.gz"
								;;
						
						esac
						

					else 
						echo "label "$i": other"

							 
					fi

			fi
}


imm_addlabels ()  {


		local list=("$@")
		local last_idx=$(( ${#list[@]} - 1 ))
		local seg_=${list[$last_idx]}
		local val=${list[$last_idx-1]}

		unset list[$last_idx]
		unset list[$last_idx-1]

		local fsl_command=${list[@]}
		local fsl_command=${fsl_command//' '/' -add '}

		echo $fsl_command

		fslmaths $fsl_command -mul ${val} ${seg_} 
}

imm_aseg2seg () {

		if [ $# -lt 1 ]; then							# usage of the function							
		    echo $0: usage: "imm_aseg2seg <aseg.ext> [<type>] [<output.ext>] [<nthreads>] [<keep>]"
		    echo "type: "
		    echo "      	1|3tissue: CSF, GM, WM	   "
		    echo "      	2|4tissue: CSF,GM, WM, DGM "
		    echo "      	3|PTBP: CSF,GM, WM, DGM, Trunk, Cerebellum"
		    echo "nthreads: 	number of threads"
		    echo "keep: 	if set (1) keep intermediate file"
				
		    return 1
		fi	

		local seg=$1
		local seg_type=$2
		local output=$3
		local nthreads=$4
		local keep=$5

		[ -z $nthreads ] && { nthreads=1; }
		[ -z $keep ] && { keep=0; }

		local f_seg=$( dirname $seg )'/'$( fbasename $seg )
		local seg_ext=$( fextension  $seg ) 	
		[ "${seg_ext}" == "mgz" ] && { local seg_nii=${f_seg}".nii.gz" ;\
							mri_convert ${seg}  ${seg_nii} ; local seg=${seg_nii}; }		

		if [ -z ${output} ]; then

			( [ ${seg_type} -eq 3 ] || [ "${seg_type}" == 'PTBP' ] ) && \
				{ local output=$( dirname $seg )'/'$( fbasename $seg )'_PTBP.nii.gz' ; }
			( [ ${seg_type} -eq 1 ] || [ "${seg_type}" == '3tissue' ] ) && \
				{ local output=$( dirname $seg )'/'$( fbasename $seg )'_3tissue.nii.gz' ;}
			( [ ${seg_type} -eq 2 ] || [ "${seg_type}" == '4tissue' ] ) && \
				{ local output=$( dirname $seg )'/'$( fbasename $seg )'_4tissue.nii.gz' ;}

		fi


		[ -z ${label_order} ] && { label_order="None"; }
		
		local N_labels=$( imm_max $seg )
		local first_label=$( imm_min $seg )
		[ ${first_label} -eq 0 ] && { first_label=1; }
		local temp_dir=$( dirname $seg )'/imm_aseg2seg_temp'$( date +%s )
		mkdir -p $temp_dir




		local csf_seg=${temp_dir}'/csf_seg.nii.gz'
		local gm_seg=${temp_dir}'/gm_seg.nii.gz'
		local wm_seg=${temp_dir}'/wm_seg.nii.gz'
		
		local final_add="${csf_seg} -add ${gm_seg} -add ${wm_seg} "

		( [ ${seg_type} -eq 2   ] || [ ${seg_type} -eq 3 ] || [ "${seg_type}" == 'PTBP'  ] || [ "${seg_type}" == '4tissue'  ]  )  \
				&& { local dgm_seg=${temp_dir}'/dgm_seg.nii.gz'; local final_add="${final_add} -add ${dgm_seg} ";  }

		( [ ${seg_type} -eq 3 ] || [ "${seg_type}" == 'PTBP' ] ) && \
		{ local crbllm_seg=${temp_dir}'/cerebellum_seg.nii.gz'; local trunk_seg=${temp_dir}'/trunk_seg.nii.gz';\
			local final_add="${final_add} -add ${trunk_seg} -add  ${crbllm_seg}" ; }

		for (( i=$first_label; i<=N_labels; i++ )); do

			local label=${temp_dir}'/'$( fbasename $seg )'_'${i}'.nii.gz'
			
			if [ ${nthreads} -ne 1 ]; then 
				imm_assign_aseglabel  $i ${label} $seg $seg_type ${csf_seg} ${gm_seg}  ${wm_seg}  ${dgm_seg}  ${trunk_seg}   ${crbllm_seg}   &
				waiting4script  ThresholdImage ${nthreads} 0	
			else
				imm_assign_aseglabel  $i ${label} $seg $seg_type ${csf_seg} ${gm_seg}  ${wm_seg}  ${dgm_seg}  ${trunk_seg}   ${crbllm_seg}   
			
			fi		

		done


		[ ${nthreads} -ne 1 ] && { waiting4script  ThresholdImage 1 0; 	waiting4script  fslmaths 1 0 ; 	wait ; }

		echo "assignment complete"

		segmentations=( ${csf_seg}  ${gm_seg}  ${wm_seg}  ${dgm_seg} ${trunk_seg}   ${crbllm_seg}  )
		count=0
		for seg in ${segmentations[@]}; do

			local count=$(( count+1))
			local segs=( $( ls $( dirname $seg )"/"$( fbasename  $seg )"/"$( fbasename  $seg )'_'* ) )
			if [ ${nthreads} -ne 1 ]; then 
				imm_addlabels ${segs[@]}  $count $seg &
				waiting4script  fslmaths ${nthreads} 0 
			else
				imm_addlabels ${segs[@]}  $count $seg 
			fi
		done					
	

		echo "single tissues masks composed"


		[ ${nthreads} -ne 1 ] && { waiting4script  fslmaths 1 0 ; wait ; }


		echo "create output segmentation:" $output
		fslmaths  $final_add  $output
			 

		[ $keep -eq 0 ] && { rm -rf ${temp_dir} ; }

		echo "complete"

		}

imm_sumExclusive () {
				
			local imm1=$1	
			local imm2=$2 
			local imm3=$3
			local temp_dir=$( dirname $imm1 )'/$imm_sumExclusive'$( date +%s )'/'
			mkdir -p $temp_dir
			imm1_binv=${temp_dir}'/'$( fbasename ${imm1} )'_binv.nii.gz'
			imm2_mul=${temp_dir}'/'$( fbasename ${imm1} )'_mul.nii.gz'
			fslmaths $imm1 -binv $imm1_binv
			fslmaths $imm2 -mul $imm1_binv $imm2_mul
			fslmaths $imm1 -add $imm2_mul $imm3
			rm -rf $temp_dir
}

imm_ConfMat() {

			if [ $# -lt 2 ]; then							# usage of the function							
			    echo $0: usage: "imm_ConfMat <image1.ext> <image2.ext> [<label>]"		
			    return 1
			fi

			local result=${1}
			local label=${2}
			local k=${3}
			[ -z ${k} ] && { local k=1;}
			local temp_dir=$( dirname ${result} )"/ConfMat"$( date +%s  )"/"
			mkdir -p ${temp_dir}
			local result_k=${temp_dir}"/image1.nii.gz"
			local label_k=${temp_dir}"/image2.nii.gz"
			fslmaths ${result} -thr ${k} -uthr ${k} -bin ${result_k}
			fslmaths ${label} -thr ${k} -uthr ${k} -bin ${label_k}
			
			local sum_img=${temp_dir}"/sum_img.nii.gz"
			fslmaths ${result_k} -add ${label_k} ${sum_img}
			local TPimg=${temp_dir}"/TPimg.nii.gz"		
			fslmaths ${sum_img} -thr 2 -uthr 2 -bin ${TPimg}			
			local TP_v=( $( fslstats ${TPimg} -V  ) )
			local TP=${TP_v[0]}			
			local TNimg=${temp_dir}"/TNimg.nii.gz"
			fslmaths ${sum_img} -binv ${TNimg}
			local TN_v=( $( fslstats ${TNimg} -V  ) )
			local TN=${TN_v[0]}

			local diff_img=${temp_dir}"/diff_img.nii.gz"
			fslmaths ${result_k} -sub ${label_k} ${diff_img}
			local FNimg=${temp_dir}"/FNimg.nii.gz"
			fslmaths ${diff_img} -thr -1 -uthr -1 -mul -1 ${FNimg}
			local FN_v=( $( fslstats ${FNimg} -V  ) )
			local FN=${FN_v[0]}
			local FPimg=${temp_dir}"/FPimg.nii.gz"
			fslmaths ${diff_img} -thr 1 -uthr 1 -bin ${FPimg}
			local FP_v=( $( fslstats ${FPimg} -V  ) )
			local FP=${FP_v[0]}

			local ALLimg=${temp_dir}"/ALLimg.nii.gz"
			fslmaths ${TPimg} -add ${TNimg} -add ${FNimg} -add ${FPimg} ${ALLimg}
			local ALL_v=( $( fslstats ${ALLimg} -V  ) )
			local ALL=${ALL_v[0]}
		
			#local Matrix[0, 0] = local TP
			#local Matrix[0, 1] = local FP
			#local Matrix[1, 0] = local FN
			#local Matrix[1, 1] = local TN
		
			# Derivations from the Confusion Matrix
		
			# Accuracy (ACC)
			local accuracy=$( echo "scale=5; ( ${TP} + ${TN} ) / ${ALL}" | bc ) 
			[ $( echo "${accuracy} < 1; "   | bc )  ] && { local accuracy="0"${accuracy};  }
			# Sensitivity, recall, hit rate, or true positive rate(TPR)
			local sensitivity=$( echo "scale=5; ${TP}  / (${TP} + ${FN} )" | bc )
			[ $( echo "${sensitivity} < 1; "   | bc )  ] && { local sensitivity="0"${sensitivity};  }
			# Specificity, selectivity or true negative rate (TNR)
			local specificity=$( echo "scale=5;${TN} /  ( ${TN} + ${FP}  ) " | bc )
			[ $( echo "${specificity} < 1; "   | bc )  ] && { local specificity="0"${specificity};  }
			# Precision or positive predictive value (PPV)
			local precision=$( echo "scale=5;${TP}  /   ( ${TP} + ${FP} )" | bc )
			[ $( echo "${precision} < 1; "   | bc )  ] && { local precision="0"${precision};  }
			# Negative predictive value (NPV)
			local NPV=$( echo "scale=5;${TN} /  ( ${TN} + ${FN} )" | bc )
			[ $( echo "${NPV} < 1; "   | bc )  ] && { local NPV="0"${NPV};  }
			# Miss rate or false negative rate (FNR)
			local miss_rate=$( echo "scale=5;1 - ${sensitivity}" | bc )
			[ $( echo "${miss_rate} < 1; "   | bc )  ] && { local miss_rate="0"${miss_rate};  }
			# Fall-Out or false positive rate (FPR)
			local fall_out=$( echo "scale=5; 1 - ${specificity}" | bc )
			[ $( echo "${fall_out} < 1; "   | bc )  ] && { local fall_out="0"${fall_out};  }
			# False discovery rate (FDR)
			local FDR=$( echo "scale=5; 1 - ${precision}" | bc )
			[ $( echo "${FDR} < 1; "   | bc )  ] && { local FDR="0"${FDR};  }
			# False omission rate(FOR)   
			local FOR=$( echo "scale=5; 1 - ${NPV} " | bc )
			[ $( echo "${FOR} < 1; "   | bc )  ] && { local FOR="0"${FOR};  }
			# F1 score is the harmonic mean of precision and sensitivity
			local F1_score=$( echo "scale=5;  ( ( 2 * ${sensitivity} * ${specificity} ) / ( ${sensitivity} + ${specificity} )) " | bc )
			[ $( echo "${F1_score} < 1; "   | bc )  ] && { local F1_score="0"${F1_score};  }			
			# Youden J index or Bookmaker Informedness
			local Youden_index=$( echo "scale=5; ${sensitivity} + ${specificity} -1 " | bc )
			[ $( echo "${Youden_index} < 1; "   | bc )  ] && { local Youden_index="0"${Youden_index};  }
			# Matthews correlation coefficient (MCC)
			local MCC=$( echo "scale=5;(( ${TP} * ${TN} - ${FP} * ${FN}) / sqrt((${TP}+ ${FP} )*( ${TP}+${FN})*(${TN}+${FP})*(${TN}+${FN})))" | bc )
			[ $( echo "${MCC} < 1; "   | bc )  ] && { local MCC="0"${MCC};  }
			# Markedness (MK)
			local MK=$( echo "scale=5;${precision} + ${NPV} -1" | bc )
			[ $( echo "${MK} < 1; "   | bc )  ] && { local MK="0"${MK};  }
			# Dice Score 
			local Dice_score=$( echo "scale=5;( 2 * $TP) / ( 2 * $TP + $FP +  $FN )" | bc )
			[ $( echo "${Dice_score} < 1; "   | bc )  ] && { local Dice_score="0"${Dice_score};  }		
			echo $accuracy $sensitivity $specificity $Dice_score
			rm -rf $temp_dir

}

imm_getMaxCluster(){ 

			if [ $# -lt 2 ]; then							# usage of the function							
			    echo $0: usage: "imm_getMaxCluster <input.ext> <output.ext> [<threshold>]"		
			    return 1
			fi


		local input=${1}
		local output=${2}
		local threshold=${3}
		[ -z ${threshold} ] && { threshold=1;} 
		local cluster=$( dirname ${input}  )"/clusters_"$( date +%s )".nii.gz"
		cluster -i ${input}  -t ${threshold} -o ${cluster} > /dev/null
		local max_c=$( imm_max ${cluster} )
		fslmaths ${cluster}  -thr ${max_c} -uthr ${max_c} -bin ${output}
		rm ${cluster}
}


imm_createSphere(){

			if [ $# -lt 3 ]; then							# usage of the function							
			    echo $0: usage: "imm_createSphere <input.ext> <coordinates> <radius> [<output.ext>]"		
			    return 1
			fi
	
			local input=${1}
			local coordinate=${2}
			local coordinate=( ${coordinate//','/' '} )
			local radius=${3}
			local ouput=${4}
			local rx=${coordinate[0]}
			local rz=${coordinate[1]}
			local ry=${coordinate[2]}
			[ -z ${ouput} ] && { ouput=$( remove_ext $input )"_roi${rx}x${ry}x${rz}"; }
			fslmaths ${input} -mul 0 -add 1 \
			-roi ${rx} 1 ${ry} 1 ${rz} 1 0 1 ${ouput}
			fslmaths ${ouput} -kernel sphere $radius -fmean   ${ouput}
			fslmaths ${ouput} -thr $( imm_max ${ouput} )   ${ouput} -odt float
			fslmaths ${ouput} -bin ${ouput}

}

imm_createSphereX() {

			if [ $# -lt 3 ]; then							# usage of the function							
			    echo $0: usage: "imm_createSphereX <input.ext> <coordinates> <radius> [<output.ext>] [<flip>]"		
			    return 1
			fi

			local input=${1}
			local coordinate=${2}
			local radius=${3}
			local output=${4}
			local flip=${5}
			coordinate_x=${coordinate//','/'x'}
			[ -z ${output} ] && { output=$( dirname $input )"/ROI${coordinate_x}.nii.gz"; }
			fslmaths ${input} -mul 0 ${output} 
			mredit  -sphere ${coordinate} ${radius} 1 ${output}
			output_edit=$( remove_ext ${output})"_edit.nii.gz"
			[ -z ${flip} ] || \
				{ imm_flip ${output} ${flip} ${output_edit} > /dev/null ; mv ${output_edit} ${output}; }
			
			}
imm_orient_as() {

			if [ $# -lt 2 ]; then							# usage of the function							
			    echo $0: "usage: imm_orient_as <file_in.ext> <file_target.ext> [<file_out.ext>]"
			    return 1;		    
			fi 
			
			local imm1=$1
			local imm2=$2
			local immo=$3
			
			[ -z ${immo} ] || { cp ${imm1} ${immo}; local imm1=$immo; }

			fslorient -deleteorient $imm1			
			fslorient -setsform  $( fslorient -getsform ${imm2} ) $imm1
			fslorient -setqform  $( fslorient -getqform ${imm2} ) $imm1

}

imm_minDist() {

		#########################################################################################################################
		###################	        						                      ###################
		#########################################################################################################################


		if [ $# -lt 2 ]; then							# usage of the function							
		    echo $0: usage: "imm_minDist <imm1.ext> <imm2.ext>"		
		    return 1
		fi


		input1=$1
		input2=$2

python << END

import nibabel as nib
import scipy.spatial as scip
import numpy as np
NiiStructure1 = nib.load("$input1")
NiiStructure2 = nib.load("$input2")

Array1=NiiStructure1.get_data()
Array2=NiiStructure2.get_data()
Array1_np=np.where(Array1==1)
Array2_np=np.where(Array2==1)
dimm=NiiStructure1.header.get_zooms()
min_dist=np.min(scip.distance.cdist(np.array(Array1_np).transpose()[:]*np.array(dimm).transpose(),np.array(Array2_np).transpose()[:]*np.array(dimm).transpose()))
print(min_dist)





END
		}


imm_maxDist() {

		#########################################################################################################################
		###################	        						                      ###################
		#########################################################################################################################


		if [ $# -lt 2 ]; then							# usage of the function							
		    echo $0: usage: "imm_minDist <imm1.ext> <imm2.ext>"		
		    return 1
		fi


		input1=$1
		input2=$2

python << END

import nibabel as nib
import scipy.spatial as scip
import numpy as np
NiiStructure1 = nib.load("$input1")
NiiStructure2 = nib.load("$input2")

Array1=NiiStructure1.get_data()
Array2=NiiStructure2.get_data()
Array1_np=np.where(Array1==1)
Array2_np=np.where(Array2==1)
dimm=NiiStructure1.header.get_zooms()
min_dist=np.max(scip.distance.cdist(np.array(Array1_np).transpose()[:]*np.array(dimm).transpose(),np.array(Array2_np).transpose()[:]*np.array(dimm).transpose()))
print(min_dist)





END
		}

imm_reshapeConn () { 

		if [ $# -lt 1 ]; then							# usage of the function							
		    echo $0: usage: "imm_reshapeConn <connectome_in.csv> [<connectome_out.csv>] [<LUT_in>] [<LUT_out>] "		
		    return 1
		fi

	local connectome_csv=$1
	local connectome_csv_new=$2
	local LUT=$3
	local LUT_new=$4

	local modulepy=$( fbasename ${CSVPACK} )
	local scriptpydir=$( dirname ${CSVPACK} )

	[ -z ${connectome_csv_new} ] && { local connectome_csv_new=$( dirname ${connectome_csv} )"/"$( fbasename ${connectome_csv} )"_rsp.csv";}
	local output_file=$( dirname $connectome_csv_new )"/"$( fbasename $connectome_csv_new )".npy"

	python -c "import sys;sys.path.append('$SCRIPT_DIR');	from ${modulepy} import csv2array, array2csv;import numpy as np;connectome_array=csv2array('$connectome_csv');	IntraMatrixDX=connectome_array[1::2,1::2];InterMatrixDX=connectome_array[1::2,0::2];MatrixDX=np.concatenate([ IntraMatrixDX, InterMatrixDX], axis=1);IntraMatrixSX=connectome_array[0::2,0::2];InterMatrixSX=connectome_array[0::2,1::2];matrixSX=np.concatenate([ InterMatrixSX,IntraMatrixSX], axis=1);Matrix=np.concatenate([MatrixDX,matrixSX]);np.save('${output_file}',Matrix);array2csv( Matrix,output='${connectome_csv_new}',separator=' ') ;"; 

rm ${output_file}

if [ -n "${LUT}" ]; then
	readarray -t array_LUT < ${LUT}

	[ -z ${LUT_new} ] && { connectome_csv_new=$( dirname ${LUT} )"/"$( fbasename ${LUT} )"_rsp."$( fextension ${LUT} ) ;}

	N="${#array_LUT[@]}"

	labels_L=''
	labels_R=''

	for (( j=0; j<$N-1; j++ ));
		do
		line_1=( $(  echo "${array_LUT[j]}" ) )
		
		keep_list="${keep_list} ${line_1[0]}"

		[ $((${j} % 2)) -eq 0 ] && { labels_L="${labels_L},'${line_1[1]}'"; continue; }

		labels_R="${labels_R},'${line_1[1]}'"
			
	done;

	labels_R=${labels_R:1:${#labels_R}-1}
	labels=${labels_R}${labels_L}

	echo $labels_R
	echo $labels_L

fi

}

imm_dcm2jpg () {


		if [ $# -lt 1 ]; then							# usage of the function							
		    echo $0: usage: "imm_dcm2jpg <dcm_path> [<outputdir] [adjust_contrast]"		
		    return 1
		fi

		local dcm_path=$1
		local outputdir=$2
		local adjust_contrast=$3
		local modulepy=$( fbasename ${IMAGECONVERT} )
		local scriptpydir=$( dirname ${IMAGECONVERT} )
		
		[ -z ${outputdir} ] &&  { outputdir=None;}
		
		if [ "${outputdir}" == "None" ]; then
			python -c "import sys;sys.path.append('$SCRIPT_DIR');\
			from ${modulepy} import dcm2jpg; dcm2jpg('${dcm_path}');"; 
		else
			python -c "import sys;sys.path.append('$SCRIPT_DIR');	\
			from ${modulepy} import dcm2jpg; dcm2jpg('$dcm_path','${outputdir}',${adjust_contrast});";
		fi


}

imm_nii2dcm () {


		if [ $# -lt 1 ]; then							# usage of the function							
		    echo $0: usage: "imm_nii2dcm <dcm_path> [<outputdir] [fields_dict]"		
		    return 1
		fi

		local dcm_path=$1
		local outputdir=$2
		local fields_dict=$3
		local modulepy=$( fbasename ${IMAGECONVERT} )
		local scriptpydir=$( dirname ${IMAGECONVERT} )
		
		[ -z ${outputdir} ] &&  { outputdir=None;}
		
		if [ "${outputdir}" == "None" ]; then
			python -c "import sys;sys.path.append('$SCRIPT_DIR');\
			from ${modulepy} import nii2dcm; nii2dcm('${dcm_path}');"; 
		elif [ -n "${fields_dict}" ] && [ -n "${outputdir}" ]; then
			python -c "import sys;sys.path.append('$SCRIPT_DIR');	\
			from ${modulepy} import nii2dcm; nii2dcm('$dcm_path','${outputdir}',fileds=${fields_dict});";
		elif [ -n "${outputdir}" ]; then
			python -c "import sys;sys.path.append('$SCRIPT_DIR');	\
			from ${modulepy} import nii2dcm; nii2dcm('$dcm_path','${outputdir});";

		fi


}

imm_unique() {

		if [ $# -lt 1 ]; then							# usage of the function							
		    echo $0: usage: "imm_unique <image.nii>"		
		    return 1
		fi
	

		local result=$( python3 -c "import nibabel as nib;  import numpy as np; print(np.unique(nib.load('${1}').get_data()))" )
		local result=${result//']'/''}
		echo ${result//'['/''}
		}

imm_4D2RGB ()	{

			if [ $# -lt 1 ]; then							# usage of the function							
			    echo $0: usage: "imm_4D2RGB <input.ext> [<output.ext>]"		
			    return 1
			fi

			local input=$1
			local output=$2
			[ -z ${output} ] &&  { output=$( remove_ext ${1} )"_RGB.nii.gz";}

python << END
import nibabel as nib
import numpy as np
input_nii = nib.load("${input}")
head = input_nii.get_header()
affine = input_nii.get_affine()
input_data=input_nii.get_data()
input_tosave=np.zeros_like(input_data[:,:,:,0])
rgb_dtype = np.dtype([('R', 'u1'), ('G', 'u1'), ('B', 'u1')])
input_tosave=input_tosave.astype(rgb_dtype)
input_data[np.isnan(input_data)]=0
for i in xrange(input_tosave.shape[0]):
	for j in xrange(input_tosave.shape[1]):
		for k in xrange(input_tosave.shape[2]):
			input_tosave[i,j,k]=(input_data[i,j,k,0],input_data[i,j,k,1],input_data[i,j,k,2])
nii_tosave = nib.Nifti1Image(input_tosave, affine=affine, header=head)
nii_tosave.to_filename("${output}")


#ras_pos=input_nii.get_data()
#shape_3d = ras_pos.shape[0:3]
#rgb_dtype = np.dtype([('R', 'u1'), ('G', 'u1'), ('B', 'u1')])
#ras_pos = ras_pos.copy().view(dtype=rgb_dtype).reshape(shape_3d) 
#ni_img = nib.Nifti1Image(ras_pos, np.eye(4))
#nib.save(ni_img, "${output}")

		
END




		}

imm_hardcrop () {

			if [ $# -lt 1 ]; then							# usage of the function							
			    echo $0: usage: "imm_hardcrop <input.ext> [<output.ext>]"		
			    return 1
			fi
			
			local input=$1
			local output=$2
			[ -z ${output} ] &&  { local output=$( remove_ext ${input} )"_cropped.nii.gz";}
python << END

import numpy as np
import nibabel as nib

NIB=nib.load("${input}")
Array=NIB.get_data()
INDEX=np.nonzero(Array)

x1=np.min(INDEX[0])
if not x1==0:
	x1=x1-1

x2=np.max(INDEX[0])
if not x2==(Array.shape[0]-1):
	x2=x2+1
y1=np.min(INDEX[1])
if not y1==0:
	y1=y1-1
y2=np.max(INDEX[1])
if not y2==(Array.shape[1]-1):
	y2=y2+1
z1=np.min(INDEX[2])
if not z1==0:
	z1=z1-1
z2=np.max(INDEX[2])
if not z2==(Array.shape[2]-1):
	z2=z2+1


NIB_c=nib.Nifti1Image(Array[x1:x2,y1:y2,z1:z2 ], 
				header=NIB.get_header(), 
				affine=NIB.get_affine() )
NIB_c.to_filename("${output}")

END



	}

imm_compare() {
		

					if [ $# -lt 2 ]; then							# usage of the function							
		    			echo $0: usage: "imm_compare 	<file1.ext> <file2.ext> "		
		    			return 1
					fi

					local imm1=$1
					local imm2=$2				
					local temp_img1=/tmp/temp_img1$( date +%s )".nii.gz"
					local temp_img2=/tmp/temp_img2$( date +%s )".nii.gz"


					imm1_size=$( imm_size $imm1 )
					imm2_size=$( imm_size $imm2 )
					
					if ! [ "${imm1_size}" == "${imm2_size}" ]; then
						
						echo 0
						return 0
					
					fi
					

					echo "Normalization..." # > "/dev/stderr"
					
					local max_1=$( echo $( imm_max "${imm1}")  )
					local max_2=$( echo $( imm_max "${imm2}")  )
					fslmaths ${imm1} -div ${max_1} ${temp_img1}
					fslmaths ${imm2} -div ${max_2} ${temp_img2}
				
					echo "Comparison of the images" # > "/dev/stderr"
				
					fslmaths ${temp_img1} -sub ${temp_img2} -abs $temp_img1
				

					local max_tmp1=$( echo $( imm_max "${temp_img1}")  )
					#echo $max_j > "/dev/stderr"
					local indi=$( echo $( str_index "${max_tmp1}" "e"))
					[ $indi -ne "-1" ] && { max_tmp1=$( echo ""|awk '{printf "%.7f", $max_j}'); }
					echo "max : "$max_tmp1 #> "/dev/stderr"
					max_tmp1=$(echo "scale=6; ${max_tmp1}*1000000 " | bc)        # errore del 0.1%
					#echo $max_j > "/dev/stderr"
					max_tmp1=${max_tmp1%.*}
					echo "max (intX1000000): "$max_tmp1 #> "/dev/stderr"

					[ $max_tmp1 -eq 0 ] && {  1; } || { 0; }

					[ $( exists ${temp_img1} ) -eq 1 ] && { rm $temp_img1 ; }
					[ $( exists ${temp_img2} ) -eq 1 ] && { rm $temp_img2 ; }
			


}

imm_GaussSmooth() {

					if [ $# -lt 2 ]; then							# usage of the function							
		    			echo $0: usage: "imm_GaussSmooth <input.ext> <output.ext> <FWHM>"		
		    			return 1
					fi
					tosmooth=$1
					smoothed=$2
					FWHM=$3			
			

					std=$(echo "scale=5; $FWHM/2.355 " | bc)                                    # dev standard gauss smoothing					

					fslmaths $tosmooth -kernel gauss $std -fmean $smoothed      
					
					}


imm_coord2int ()  {

					if [ $# -lt 1 ]; then							# usage of the function							
		    			echo $0: usage: "imm_coord2int <list.ext> <output.ext>"		
		    			return 1
					fi

				local st_list=$1
				local output=$2

				if ! [ -z ${st_list} ]; then
						
				   	local format_=$( file --mime-type -b  "${st_list}" 2> /dev/null );
					local type_=$( echo $format_ |  cut -d"/" -f1   )
					if [ "${type_}" == "text" ]; then

						local st_list_file=${st_list}
						local array_1=''
						readarray -t array_1 < $st_list_file;
						local N="${#array_1[@]}"
						for (( j=0; j<$N; j++ )); do
							
							line_1="${array_1[j]}"
							local st_list_v=( ${line_1//','/' '} )
							echo ${st_list_v[@]}

							
							local st_list_v0=${st_list_v[0]}
							local st_list_v1=${st_list_v[1]}
							local st_list_v2=${st_list_v[2]}

							st_list_v0=$( echo ${st_list_v0} | awk '{printf("%d\n",$1 + 0.5)}' )
							st_list_v1=$( echo ${st_list_v1} | awk '{printf("%d\n",$1 + 0.5)}' )
							st_list_v2=$( echo ${st_list_v2} | awk '{printf("%d\n",$1 + 0.5)}' )
							
						
							
							st_list="${st_list_v0},${st_list_v1},${st_list_v2}"
							
							echo ${st_list}

							if ! [ -z ${output} ]; then			
								echo ${st_list} >> ${output}
							fi
						done
						
					else
						local st_list_v=( ${st_list//','/' '} )
						
				

						local st_list_v0=${st_list_v[0]}
						local st_list_v1=${st_list_v[1]}
						local st_list_v2=${st_list_v[2]}
						
						st_list_v0=$( echo ${st_list_v0} | awk '{printf("%d\n",$1 + 0.5)}' )
						st_list_v1=$( echo ${st_list_v1} | awk '{printf("%d\n",$1 + 0.5)}' )
						st_list_v2=$( echo ${st_list_v2} | awk '{printf("%d\n",$1 + 0.5)}' )
						
						#st_list_v0=$( awk 'BEGIN { printf("%.0f\n", $st_list_v0 ); }' )
						#st_list_v1=$( awk 'BEGIN { printf("%.0f\n", $st_list_v1 ); }' )
						#st_list_v2=$( awk 'BEGIN { printf("%.0f\n", $st_list_v2 ); }' )
						
						st_list=${st_list_v0},${st_list_v1},${st_list_v2}
						echo ${st_list}
						if ! [ -z ${output} ]; then			
								echo ${st_list} >> ${output}
						fi

					fi
				fi		
						
					}


imm_mni2cor() {

					if [ $# -lt 1 ]; then							# usage of the function							
		    			echo $0: usage: "imm_mni2cor <list.ext> <output.ext> [<spacing>] [inv] [neg] "		
		    			return 1
					fi
				# coordinate list


				local st_list="$1"
				local output="${2}"
				
				if ! [ -z ${output} ]; then			
					printf "" > ${output}
				fi
				
				local spacing="${3}"
				if [ -z "${spacing}" ]; then

					local x1=1;
					local x2=1;
					local x3=1;

				else
					spacing="${spacing//'x'/' '}"
					spacing="${spacing//','/' '}"
					spacing_v=( $( echo "${spacing}" ) )
					local x1=${spacing_v[0]};
					local x2=${spacing_v[1]};
					local x3=${spacing_v[2]};		

				fi
				
				local invert="${4}"
				
				if ! [ -z ${invert} ]; then
					if  [ ${invert} -eq 1 ]; then				
							
							tx=61
							ty=85
							tz=49
							
							x1=$( echo "$x1" | awk '{ print ((1/$1)); }' )
							x2=$( echo "$x2" | awk '{ print ((1/$1)); }' )
							x3=$( echo "$x3" | awk '{ print ((1/$1)); }' )

							
					else
							tx=90
							ty=126
							tz=72
						
					fi
					
				else	
				
					tx=90
					ty=126
					tz=72
				
				fi
				
				local neg="${5}"
				if ! [ -z ${neg} ]; then
					if  [ ${neg} -eq 1 ]; then
					
						inv=" +"
					
					else
						inv=" -"
					
					fi
				else
				
					inv=" -"
					
				
				
				fi
				
				if ! [ -z ${st_list} ]; then
						
				   	local format_=$( file --mime-type -b  "${st_list}" 2> /dev/null );
					local type_=$( echo $format_ |  cut -d"/" -f1   )
					if [ "${type_}" == "text" ]; then

						local st_list_file=${st_list}
						local array_1=''
						readarray -t array_1 < $st_list_file;
						local N="${#array_1[@]}"
						for (( j=0; j<$N; j++ )); do
							
							line_1="${array_1[j]}"
							local st_list_v=( ${line_1//','/' '} )
							echo ${st_list_v[@]}

							
							st_list_v[0]=`echo "${st_list_v[0]} * -1 * ${x1} + ${tx}" | bc`
							st_list_v[1]=`echo "${st_list_v[1]} * ${x2} ${inv}   ${ty} " | bc`
							st_list_v[2]=`echo "${st_list_v[2]} * ${x3} ${inv}  ${tz}  " | bc`
							
							local st_list_v0=${st_list_v[0]}
							local st_list_v1=${st_list_v[1]}
							local st_list_v2=${st_list_v[2]}

							st_list_v0=$( echo ${st_list_v0} | awk '{printf("%d\n",$1 + 0.5)}' )
							st_list_v1=$( echo ${st_list_v1} | awk '{printf("%d\n",$1 + 0.5)}' )
							st_list_v2=$( echo ${st_list_v2} | awk '{printf("%d\n",$1 + 0.5)}' )
							
							#st_list_v0=$( awk 'BEGIN { printf("%.0f\n", $st_list_v0 ); }' )
							#st_list_v1=$( awk 'BEGIN { printf("%.0f\n", $st_list_v1 ); }' )
							#st_list_v2=$( awk 'BEGIN { printf("%.0f\n", $st_list_v2 ); }' )
							
							
							st_list="${st_list_v0},${st_list_v1},${st_list_v2}"
							
							echo ${st_list}

							if ! [ -z ${output} ]; then			
								echo ${st_list} >> ${output}
							fi
						done

					else
						local st_list_v=( ${st_list//','/' '} )
						
						st_list_v[0]=`echo "${st_list_v[0]} * -1 * ${x1} + ${tx}" | bc`
						st_list_v[1]=`echo "${st_list_v[1]} * ${x2} ${inv}  ${ty} " | bc`
						st_list_v[2]=`echo "${st_list_v[2]} * ${x3} ${inv}  ${tz} " | bc`

						local st_list_v0=${st_list_v[0]}
						local st_list_v1=${st_list_v[1]}
						local st_list_v2=${st_list_v[2]}
						
						st_list_v0=$( echo ${st_list_v0} | awk '{printf("%d\n",$1 + 0.5)}' )
						st_list_v1=$( echo ${st_list_v1} | awk '{printf("%d\n",$1 + 0.5)}' )
						st_list_v2=$( echo ${st_list_v2} | awk '{printf("%d\n",$1 + 0.5)}' )
						
						#st_list_v0=$( awk 'BEGIN { printf("%.0f\n", $st_list_v0 ); }' )
						#st_list_v1=$( awk 'BEGIN { printf("%.0f\n", $st_list_v1 ); }' )
						#st_list_v2=$( awk 'BEGIN { printf("%.0f\n", $st_list_v2 ); }' )
						
						st_list=${st_list_v0},${st_list_v1},${st_list_v2}
						echo ${st_list}
						if ! [ -z ${output} ]; then			
								echo ${st_list} >> ${output}
						fi

					fi

				fi

			}

imm_points2roi() {


					if [ $# -lt 3 ]; then							# usage of the function							
		    			echo $0: usage: "imm_points2roi <list.ext> <template.ext> [<output.ext>]"		
		    			return 1
					fi

						local st_list="$1"
						local input="${2}"
						local output="${3}"
						
						fslmaths ${input} -mul 0 ${output}

						local st_list_file=${st_list}
						local array_1=''
						readarray -t array_1 < $st_list_file;
						local N="${#array_1[@]}"
						for (( j=0; j<$N; j++ )); do
							
							line_1="${array_1[j]}"
							local st_list_v=( ${line_1//','/' '} )

							echo "add point ${line_1}"

							fslmaths ${output} -add 1 \
												-roi ${st_list_v[0]} 1 ${st_list_v[1]} \
												 1 ${st_list_v[2]} \
												1 0 1 \
												-add ${output} ${output}

						done

				}


imm_points2roi_filled () { 
	
					if [ $# -lt 3 ]; then							# usage of the function							
		    			echo $0: usage: "imm_points2roi_filled <list.ext> <template.ext> [<output.ext>]"		
		    			return 1
					fi	

		input1=$1
		input2=$2
		input3=$3


python << END	

import nibabel as nib
import sys
import pandas as pd        
from scipy.spatial import ConvexHull
import numpy as np
import scipy 


def flood_fill_hull(image):   
    points = np.transpose(np.where(image)) 
    hull = scipy.spatial.ConvexHull(points)
    deln = scipy.spatial.Delaunay(points[hull.vertices]) 
    idx = np.stack(np.indices(image.shape), axis = -1)
    out_idx = np.nonzero(deln.find_simplex(idx) + 1)
    out_img = np.zeros(image.shape)
    out_img[out_idx] = 1
    return out_img, hull

def points2roi_filled( points_file, template_file, output_file):

	csv_read = pd.read_csv(points_file)

	template_NIB=nib.load(template_file)
	template_head=template_NIB.get_header()
	template_affine = template_NIB.get_affine()
	template_array=template_NIB.get_data()

	points_list = np.array(csv_read)

	ROI_array = np.zeros_like(template_array)

	for points in  points_list:
		ROI_array[points[0],points[1],points[2]] = 1

	ROI_array_filled, hull = flood_fill_hull(ROI_array)

	filename_=output_file; 
	nii_ = nib.Nifti1Image(ROI_array_filled, affine=template_affine, header=template_head);
	nii_.to_filename(filename_)

points2roi_filled( '$input1', '$input2', '${input3}')	

END


}

imm_castType() {


					if [ $# -lt 2 ]; then							# usage of the function							
		    			echo $0: usage: "imm_castType <input.ext> <output_type> [<output.ext>]"
						echo "           if output.ext is not provided, the function cast image in place"		
		    			return 1
					fi

						local input="${1}"
						local type="${2}"
						local output="${3}"
						
						[ -z ${output} ] && { output=${input} ; }

						fslmaths ${input} ${output} -odt ${type}

				}

imm_sortLabels() {


					if [ $# -lt 1 ]; then							# usage of the function							
		    			echo $0: usage: "imm_sortLabels <input.ext> [<output.ext>]"		
		    			return 1
					fi

						local input="${1}"
						local output="${2}"
						
						[ -z ${output} ] && { output=$( remove_ext ${input} )'_sorted.nii.gz'; }

						local input_temp='/tmp/img'$( date +%s )'.nii.gz'
						imm_castType ${input}	int  ${input_temp}

						local values=( $( imm_unique ${input_temp} ) )
						echo "values found: "${values[@]}
						local cont=0
						local label='/tmp/label'$( date +%s )'.nii.gz'

						fslmaths ${input_temp} -sub ${input_temp} ${output}
						for i in ${values[@]}; do

							cont=$(( $cont + 1 ))					

							ThresholdImage 3 ${input_temp} ${label} "${i}" "${i}" 

							fslmaths $label -bin -mul ${cont} $label 

							fslmaths ${output} -add $label ${output}

						done 
					
						

				}

imm_createInclusionSphere () {
	
	
		if [ $# -lt 1 ]; then							# usage of the function							
		    			echo $0: usage: "imm_createInclusionSphere <input.ext> [<output.ext>]"		
		    			return 1
		fi
	
		local coord_Peak_L=$1
		local coord_PEAK_L_sphere=$2

		[ -z $coord_PEAK_L_sphere ] && { coord_PEAK_L_sphere=$( remove_ext ${coord_Peak_L} )"_inclusionSphere.nii.gz" ; }

		coord_Peak_L_COG=$( remove_ext ${coord_Peak_L} )'_COG.nii.gz'
		cog_peak=( $( fslstats ${coord_Peak_L}  -C  ) )
		imm_createSphereX ${coord_Peak_L} ${cog_peak[0]},${cog_peak[1]},${cog_peak[2]} 1 ${coord_Peak_L_COG} X

		peak_maxDist=$( imm_maxDist ${coord_Peak_L_COG} ${coord_Peak_L} )
		[ -z ${coord_PEAK_L_sphere} ] && { coord_PEAK_L_sphere=$( remove_ext ${coord_Peak_L} )'_sphere.nii.gz' ; }
		imm_createSphereX ${coord_Peak_L} ${cog_peak[0]},${cog_peak[1]},${cog_peak[2]} ${peak_maxDist} ${coord_PEAK_L_sphere} X
}


imm_T2Wsynth() {
	
	
		if [ $# -lt 2 ]; then							# usage of the function							
		    			echo $0: usage: "imm_T2Wsynth <T1.ext> <basename> [<T1_mask.ext>]"		
		    			return 1
		fi	
		local T1=$1
		local T2_basename=$2
		local T1_mask=$3
		
		local T2_idx=$( str_index ${T2_basename} '/' )

		if [ ${T2_idx} -ne -1 ]; then
		
			local T2_dir=$( dirname $T2_basename )
			
			mkdir -p ${T2_dir}
			
		fi
		
		
		

		[ -z ${T1_mask} ] && \
			{ local T1_mask=${T2_basename}_brain_mask.nii.gz; bet ${T1}  ${T2_basename}_brain -m ; }
		
		local T1_maskbin=${T2_basename}'_maskbin.nii.gz'
		fslmaths ${T1} -thrp 5 -bin -add ${T1_mask} ${T1_maskbin}; 
		
		local T1_inv=${T2_basename}'_inv.nii.gz'
		fslmaths ${T1} -mul -1  -add $( imm_max ${T1} ) ${T1_inv}
		
		local T1_inv_pthr001=${T2_basename}'_inv_pthr001.nii.gz'
		fslmaths ${T1_inv}  -thr $( fslstats ${T1_inv}  -p 0.01  ) ${T1_inv_pthr001}

		local T1_inv_pthr001_sub=${T2_basename}'_inv_pthr001_sub.nii.gz'
		fslmaths ${T1_inv_pthr001} -sub $( imm_min ${T1_inv_pthr001} ) ${T1_inv_pthr001_sub}

		local T1_inv_pthr001_sub_avg=${T2_basename}'_inv_pthr001_sub_avg.nii.gz'
		imm_setAverage ${T1_inv_pthr001_sub} ${T1_inv_pthr001_sub_avg} 100

		T1_inv_pthr001_sub_avg_bg=${T2_basename}'_inv_pthr001_sub_avg_bg.nii.gz'
		fslmaths ${T1_maskbin} -mul ${T1_inv_pthr001_sub_avg} ${T1_inv_pthr001_sub_avg_bg}
		
		T2=${T2_basename}'.nii.gz'
		cp ${T1_inv_pthr001_sub_avg_bg} ${T2}
}
