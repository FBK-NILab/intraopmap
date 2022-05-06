#! /bin/bash

#########################################################################################################################
#########################################################################################################################
###################		            							      ###################
###################	title:	            	  Files library					      ###################
###################		           							      ###################
###################	description:	Library of functions for files management		      ###################
###################										      ###################
###################	version:	0.7.1        				                      ###################
###################	notes:	        .							      ###################
###################	bash version:   tested on GNU bash, version 4.2.53			      ###################
###################		           							      ###################
###################	autor: gamorosino     							      ###################
###################     email: g.amorosino@gmail.com						      ###################
###################		           							      ###################
#########################################################################################################################
#########################################################################################################################
###################										      ###################
###################	update: added gdrive_getID					      	      ###################
###################		            							      ###################
#########################################################################################################################
#########################################################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/"
STRlib=${SCRIPT_DIR}"/STRlib.sh"
source ${STRlib}

exists () {
                ############# ############# ############# ############# ############# ############# #############
                #############  		      Controlla l'esistenza di un file o directory	    ############# 
                ############# ############# ############# ############# ############# ############# #############  		                      			
		if [ $# -lt 1 ]; then
		    echo $0: "usage: exists <filename> "
		    echo "    echo 1 if the file (or folder) exists, 0 otherwise"
		    return 1;		    
		fi 
		
		if [ -d "${1}" ]; then 

			echo 1;
		else
			([ -e "${1}" ] && [ -f "${1}" ]) && { echo 1; } || { echo 0; }	
		fi		
		};


exists_old () {
                ############# ############# ############# ############# ############# ############# #############
                #############  		      Controlla l'esistenza di un file o directory	    ############# 
                ############# ############# ############# ############# ############# ############# #############  		
		                      			
		if [ $# -lt 1 ]; then
		    echo $0: "usage: exists file [ type ]"
		    echo "    type is 0 for file, 1 for directory (default 0)"
		    return 1;		    
		fi 
		
		ftype=${2}
		[ -z $ftype ] && { ftype=0; } 
		
		if [ ${ftype} -eq 0 ]; then 

			([ -e "${1}" ] && [ -f "${1}" ]) && { echo 1; } || { echo 0; }
		else
			
			[ -d "${1}" ] && { echo 1; } || { echo 0; }
		
		fi
		
		};
		
fbasename () {
                ############# ############# ############# ############# ############# ############# 
                #############   Rimuone directory ed estenzione dal nome di un file   ############# 
                ############# ############# ############# ############# ############# #############
                  
                echo ` basename $1 | cut -d '.' -f 1 `
		
		};
		
fextension () {
                ############# ############# ############# ############# ############# ############# 
                #############   	Estrae l'estenzione dal nome di un file       ############# 
                ############# ############# ############# ############# ############# #############  
                
                local filename=$( basename $1 )
                local extension="${filename##*.}"
		echo $extension
		
		};

hnumb2tnumb () {

                ############# ############# ############# ############# ############# ############# 
                #############      Converte Human readeable size number to number     ############# 
                ############# ############# ############# ############# ############# ############# 

		hnumber=${1}
		TT=$( grep -o "T" <<<"$hnumber" | wc -l)
		GG=$( grep -o "G" <<<"$hnumber" | wc -l)
		MM=$( grep -o "M" <<<"$hnumber" | wc -l)
    		KK=$( grep -o "K" <<<"$hnumber" | wc -l)
    		[ $TT -eq 1 ] && { hnumber=$(echo "scale=6; ${hnumber//[^0-9]/}*1000000000000  " | bc);}
		[ $GG -eq 1 ] && { hnumber=$(echo "scale=6; ${hnumber//[^0-9]/}*1000000000  " | bc);}
		[ $MM -eq 1 ] && { hnumber=$(echo "scale=6; ${hnumber//[^0-9]/}*1000000  " | bc);}
		[ $KK -eq 1 ] && { hnumber=$(echo "scale=6; ${hnumber//[^0-9]/}*1000  " | bc);}
    		echo ${hnumber}
		};

tnumb2hnumb () {

                ############# ############# ############# ############# ############# ############# 
                #############      Converte number to Human readeable size number     ############# 
                ############# ############# ############# ############# ############# ############# 

		local tnumber=$1
		local order=${#tnumber};
		if ( [ $order -gt 3 ] && [ $order -lt 7 ]); then
			local numba=$(echo "scale=3; ${tnumber}/1000  " | bc); 
			local intg=${numba%.*}; 
			local deci=${numba:${#intg}+1:${#numba}}
			[ ${#deci} -eq $( grep -o "0" <<<"$deci" | wc -l) ] && { numba=$intg; }
			hnumber=$numba"K";
		elif ( [ $order -gt 6 ] && [ $order -lt 10 ]); then
			local numba=$(echo "scale=3; ${tnumber}/1000000  " | bc); 
			local intg=${numba%.*};
			local deci=${numba:${#intg}+1:${#numba}} 
			[ ${#deci} -eq $( grep -o "0" <<<"$deci" | wc -l) ] && { numba=$intg; }
			hnumber=$numba"M";
		elif ( [ $order -gt 9 ] && [ $order -lt 13 ]); then
			local numba=$(echo "scale=3; ${tnumber}/1000000000  " | bc); 
			local intg=${numba%.*};
			local deci=${numba:${#intg}+1:${#numba}}			 
			[ ${#deci} -eq $( grep -o "0" <<<"$deci" | wc -l) ] && { numba=$intg; }
			hnumber=$numba"G";
		elif   [ $order -gt 12 ];  then
			local numba=$(echo "scale=3; ${tnumber}/1000000000000  " | bc); 
			local intg=${numba%.*};
			local deci=${numba:${#intg}+1:${#numba}}			 
			[ ${#deci} -eq $( grep -o "0" <<<"$deci" | wc -l) ] && { numba=$intg; }
			hnumber=$numba"T";	
		else
			hnumber=$tnumber;
		fi;
		echo ${hnumber}
		};		
		


transfperc () { 
                ############# ############# ############# ############# ############# ############# ############# 
                #############      Stima avanzamento della copia / cancellazione / download file     ############# 
                ############# ############# ############# ############# ############# #############  ############# 
		
		
		
		local target=${1}
		local filename=${2}
		
		if [ $# -lt 1 ]; then
		    echo $0: "usage: transfperc <target_size> [ <filename> ]"
		    return 1;		    
		fi 

		[ -d ${filename} ] && { local type=0; } || \
			{ [ $( exists ${filename} ) -eq 1 ] && { local type=1; } || \
				{ echo "file or directory does not exists!"; }; } 	

		
                
		if [ -n "${filename}" ];then
		
			[ -d ${filename} ] && { local type=0; } || \
			{ [ $( exists ${filename} ) -eq 1 ] && { local type=1; } || \
				{ echo "file or directory does not exists!"; }; } 	

		else

			local type=2;

		fi
		
		while [ -z $( sync) ]; do 
			
			case $type in
				  0)	  
					local tnumber=( $( du "${filename}" -h --total | grep total) );		
				  ;;
				  1)
					local tnumber=( $( ls -sh "${filename}" ) );		
				  ;;
			    	  2)
					local tnumber=( $( du -h --total | grep total) );
					;;       
			     	  *)
				  echo "error"
						
						return -1
				  ;;
			esac
			
			local target=${1}  
			tnumber="${tnumber[0]}";
			local wtnumber=$( hnumb2tnumb $tnumber ) 
    			local wtarget=$( hnumb2tnumb $target )
    			wtnumber=$( str_strip "$wtnumber" )
    			wtarget=$(  str_strip "$wtarget"  )
    			tnumber=$(  tnumb2hnumb $wtnumber  ) 
    			target=$(   tnumb2hnumb $wtarget   )
    			wtnumber=$(echo "scale=4; ${wtnumber} / ${wtarget}  " | bc) ;
			local diff_tnumber=$(echo "scale=4; ${wtarget} - ${wtnumber}  " | bc) ;
			wtnumber=$( echo $(echo "scale=4; ${wtnumber} * 100  " | bc) );
			local  diff_tnumber=${diff_tnumber%.*}		
			[ $diff_tnumber -le 0 ] && { echo "done"; break ;}
			echo -ne "${wtnumber:0:-2}"% done " ("${tnumber}" su "${target}")\033[0K\r"
			
		done
		};


cmpfolders () {     

	        ############# ############# ############# ############# ############# ############# #############
                #############  		      Controlla se due cartelle sono uguali		    ############# 
                ############# ############# ############# ############# ############# ############# #############  		                      			
		if [ $# -lt 1 ]; then
		    echo $0: "usage: exists <filename> "
		    echo "    echo 1 if the folders are equal (same files inside), 0 otherwise"
		    return 1;		    
		fi
				tree_out=( $( tree ${1}  ) )
				tree_out[0]=""
				out_string=$( echo ${tree_out[@]} )
				tree_in=(  $( tree ${2}   ) )
				tree_in[0]=""
				in_string=$( echo ${tree_in[@]} )

				if [ "${out_string}" == "${in_string}" ]; then
					echo 1
				else
					echo 0			
				fi	
	};

dispLog_old () {		
	        ############# ############# ############# ############# ############# ############# #############
                #############  		    Output a video dell'ultima linea di un log file	    ############# 
                ############# ############# ############# ############# ############# ############# ############# 

		file_in_1=$1;
		last_falg=$2
		sleep_time=$3
		last_line="" 
		[ -z $last_falg ] && { last_flag=0; }
		while [ "true" == "true" ]; 
		do 
			readarray -t array_1 < $file_in_1;

			if [ $last_flag -eq 1 ]; then
				echo -ne ${array_1[-1]}"\033[0K\r"; 
			else
				this_line="${array_1[-1]}"
				this_line=${this_line//" "/""}
				[ "${this_line}" == "${last_line}" ] || { echo ${array_1[-1]}; }
				last_line="${this_line}"
			fi		
			[ -z $sleep_time ] || { sleep $sleep_time; };  
		done
	};

checkAbsPath () {

		local data=$1;
		local data_dir=$( dirname ${data} );
		
		if [ "${data_dir}" == "." ]; then
			data=${PWD}"/"$( basename ${data} );
		elif [ "${data_dir:0:2}" == ".."  ]; then						
			data=$( dirname ${PWD})"${data:2:${#data}}"
		elif [ "${data_dir:0:1}" == "."  ]; then
			data=${PWD}"${data:1:${#data}}"

		else
 
			case $data in   /*) printf "" ;;   *) data=${PWD}"/"${data} ;; esac
		fi	
		
		echo ${data};
	
		};

dispLog () {		
	        ############# ############# ############# ############# ############# ############# #############
                #############  		Output dinamico a video del log file e/o error file	    ############# 
                ############# ############# ############# ############# ############# ############# ############# 

		if [ $# -lt 1 ]; then							# usage dello script							
			    echo $0: usage: "dispLog <file_log> [<file_err>] [ sleep_time ]"
			    return 1;		    
			fi
		file_in_1=$1
		file_in_2=$2				
		sleep_time=$3
		last_line_1="" 
		last_line_2="" 

		while [ "true" == "true" ]; 
		do 		


			readarray -t array_1 < $file_in_1;
			this_line_1="${array_1[-1]}"
			this_line_1=${this_line_1//" "/""}
			[ "${this_line_1}" == "${last_line_1}" ] || { echo  "${array_1[-1]}"; }
			last_line_1="${this_line_1}"
			if ! [ -z $file_in_2 ]; then
				readarray -t array_2 < $file_in_2;
				this_line_2="${array_2[-1]}"
				this_line_2=${this_line_2//" "/""}
				[ "${this_line_2}" == "${last_line_2}" ] || { echo "${array_2[-1]}"; }
				last_line_2="${this_line_2}"
			fi
			[ -z $sleep_time ] || { sleep $sleep_time; };  
		done
	};	

merge_txtRows ()  {

			
		    	############# ############# ############# ############# ############# ############# #############
		    	############# 	    		Concatena le righe di più file di testo		    ############# 
		    	############# ############# ############# ############# ############# ############# #############

			if [ $# -lt 2 ]; then							# usage dello script							
			    echo $0: usage: "merge_txtRows <file_list> <file_out.ext> [ sep ]"
			    return 1;		    
			fi

			local file_list="$1"
			local file_out="$2"
			local sep="$3"
			
			if [ -z "${sep}" ]; then			
				sep="    ";
			elif [ "${sep}" == "null" ]; then
				sep="";
			fi

			file_vect=( ${file_list//','/' '} )
			file_in_1="${file_vect[0]}"
			file_final="/tmp/filetemp_"$( date +%s)".txt"
			printf "" > ${file_final}
			cp $file_in_1 $file_out
			local M="${#file_vect[@]}"
			for (( i=1;i<$M; i++));
				do
				readarray -t array_1 < "${file_out}";
				readarray -t array_2 < "${file_vect[$i]}";
				local N="${#array_1[@]}"
				for (( j=0; j<$N; j++ ));
					do
					line_1="${array_1[j]}"
					line_2="${array_2[j]}"
					new_line="${line_1}${sep}${line_2}"
					ary=($new_line)
					new_line=$( echo "${ary[@]}" )
					echo "$new_line" >>  ${file_final}
		
				done;
				cp $file_final $file_out
				printf "" > ${file_final}
			done;

			};	


gdrive_getID () {
		    	############# ############# ############# ############# ############# ############# #############
		    	############# 	   		Google drive direct download			    ############# 
		    	############# ############# ############# ############# ############# ############# #############

			if [ $# -lt 1 ]; then												
			    echo $0: usage: "gdrive_getID <url>  "
			    return 1;		    
			fi
			local url=$1
			fileid=""
			declare -a patterns=("s/.*\/file\/d\/\(.*\)\/.*/\1/p" "s/.*id\=\(.*\)/\1/p" "s/\(.*\)/\1/p")
			for i in "${patterns[@]}"
			do
   				fileid=$(echo $url | sed -n $i)
   				[ ! -z "$fileid" ] && break
			done

			[ -z "${fileid}" ] && { echo "None" ; }	

			echo "${fileid}"

		}

gdrive_download () {


		    	############# ############# ############# ############# ############# ############# #############
		    	############# 	   		Google drive direct download			    ############# 
		    	############# ############# ############# ############# ############# ############# #############

			if [ $# -lt 2 ]; then							# usage dello script							
			    echo $0: usage: "gdrive_download <url> <filename.ext> "
			    return 1;		    
			fi

			local url=$1
			local filename=$2

			fileid=$( gdrive_getID ${url}  )


			[ "${fileid}" == "None" ] && { echo "Could not find Google ID"; exit 1 ; }	

			echo "File ID: "$fileid 
			
			temp_folder=$( dirname ${filename} )"/gdrive_download_"$( date +%s)"/"
			cookies_txt=${temp_folder}"/cookies.txt"			
			header_txt=${temp_folder}"/header.txt"
			confirm_txt=${temp_folder}"/confirm.txt"

			mkdir -p $temp_folder
			
			wget --save-cookies ${cookies_txt} 'https://docs.google.com/uc?export=download&id='$fileid -O- \
     			| sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p' > ${confirm_txt}

			wget --load-cookies ${cookies_txt} -O $filename \
     			'https://docs.google.com/uc?export=download&id='$fileid'&confirm='$(<${confirm_txt})

			rm -rf ${temp_folder}

			};	
