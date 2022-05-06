#! /bin/bash

#########################################################################################################################
#########################################################################################################################
###################                                                                                   ###################
###################	title:	            	  Array library				      	      ###################
###################		           							      ###################
###################	description:	Library of functions that implements 2D array		      ###################
###################										      ###################
###################	version:	0.3.1        				                      ###################
###################	usage example:      							      ###################
###################		declare -A array       						      ###################
###################		array[0,0]=1							      ###################
###################		array[1,1]=0           						      ###################
###################		value="${array[1,1]}"						      ################### 
###################		maximum=$( array_max ${array[@]} )				      ###################
###################		array key: ${!array[@]} 			                      ###################     
###################	notes:	        needs STRlib.sh						      ###################
###################	bash version:   tested on GNU bash, version 4.2.53			      ###################
###################		           							      ###################
###################	autor: gamorosino     							      ###################
###################     email: g.amorosino@gmail.com						      ###################
###################		           							      ###################
#########################################################################################################################
#########################################################################################################################
#########################################################################################################################
##################										      ###################
##################		update array_min and array_max for floating point			      ###################
##################										      ###################			
#########################################################################################################################
#########################################################################################################################


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/"
STRlib=${SCRIPT_DIR}"/STRlib.sh"
source ${STRlib}

array_max ()	{
			############# ############# ############# ############# ############# ############# #############
		        #############       Restituisce il valore del massimo di un array fai suoi values   ############# 
		        ############# ############# ############# ############# ############# ############# #############  

		        if [ $# -lt 1 ]; then							# usage dello script							
			    echo $0: "usage: array_max <array_values>"
			    echo "    array_values values of the array "
			    echo "    example: array_max \${array[@]} "	 	
			    return 1;		    
			fi 			
			
			
			local array=("$@")					
			local max=${array[0]}
			local val=0
			for (( i=0; i<${#array[@]}; i++ )); do
					val=${array[$i]}
					(( $(echo "$max  <= $val" |bc -l) )) && { max=$val;}
			done
			echo $max

		};

array_min ()	{
			############# ############# ############# ############# ############# ############# #############
		        #############       Restituisce il valore del minimo di un array fai suoi values    ############# 
		        ############# ############# ############# ############# ############# ############# #############  

		        if [ $# -lt 1 ]; then							# usage dello script							
			    echo $0: "usage: array_min <array_values>"
			    echo "    array_values values of the array "
			    echo "    example: array_min \${array[@]} "	 	
			    return 1;		    
			fi 

			local array=("$@")					
			local min=${array[0]}
			local val=0
			for (( i=0; i<${#array[@]}; i++ )); do
					val=${array[$i]}
					
					(( $(echo "$min  >= $val" |bc -l) )) && { min=$val;}
			done
			echo $min

		};

array_mean ()	{
			############# ############# ############# ############# ############# ############# #############
		        #############       Restituisce il valore del minimo di un array fra i suoi values  ############# 
		        ############# ############# ############# ############# ############# ############# #############  

		        if [ $# -lt 1 ]; then							# usage dello script							
			    echo $0: "usage: array_mean <array_values>"
			    echo "    array_values: values of the array "
			    echo "    example: array_mean \${array[@]} "	 	
			    return 1;		    
			fi 

			local array=("$@")					
			local val=0
			local N=${#array[@]}
			local mean=0
			for (( i=0; i<$N; i++ )); do
					val=${array[$i]}
	  				mean=$(echo "scale=4; ${mean}+${val} " | bc | awk '{printf "%f", $0}')
			done
			mean=$(echo "scale=4; ${mean}/${N} " | bc | awk '{printf "%f", $0}')

			echo $mean

		};

array_count ()	{
			############# ############# ############# ############# ############# ############# #############
		        #############       Restituisce il numero di occorrenze di un valore in un vettore  ############# 
		        ############# ############# ############# ############# ############# ############# #############  

		        if [ $# -lt 1 ]; then							# usage dello script							
			    echo $0: "usage: array_count <element> <array_values> "
			    echo "    array_values: values of the array "
			    echo "    example: array_count 0 \${array[@]}  "	 	
			    return 1;		    
			fi 

			local vect=("$@")
			local value=${vect[0]}
			local value=$( sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g' <<<"${value}" )
			unset vect[0]
			array=( "${vect[@]}" )
			local N="${#array[@]}"
			local count=0
			for (( i=0; i<$N; i++ )); do
					val=${array[$i]}
					val=$( sed -E 's/([+-]?[0-9.]+)[eE]\+?(-?)([0-9]+)/(\1*10^\2\3)/g' <<<"${val}" )
					diff=$(echo "scale=4; ${val}-${value} " | bc | awk '{printf "%f", $0}')
					diff=${diff%.*}
					[ ${diff} -eq 0 ] && { count=$(( ${count} + 1)); }	
			done
			echo $count

		};

array_rows () 	{
			############# ############# ############# ############# ############# ############# #############
		        #############   Restituisce il numero di righe di un array 2D a partire dalle keys  ############# 
		        ############# ############# ############# ############# ############# ############# #############  
		
			local arraykeys=("$@")
			local last_idx=$(( ${#arraykeys[@]} - 1 ))
			local max_index=${arraykeys[$last_idx]}
			unset arraykeys[$last_idx]			
			local contr=0
			while [[ $contr -eq 0 && $max_index -ne -1 ]]; do
			
				contr=$( echo "${arraykeys[@]}" | tr " " "\n" | grep -c "${max_index}," )
				nrows=$max_index
				max_index=$(( ${max_index}-1 ))
			done
			echo $nrows
		};



array_rows () 	{
			############# ############# ############# ############# ############# ############# #############
		        #############  Restituisce il numero di righe di un array 2D a partire dalle keys ############# 
		        ############# ############# ############# ############# ############# ############# #############  
		
			local arraykeys="$@"
			local keys="${arraykeys//','/' '}"
			keys=( $keys )
			local max_key=0
			[ -z ${keys} ] && { echo "no input given!";return  -1; }
			for (( i=0; i<${#keys[@]}; i=$i+2 )); do

				[ $max_key -lt ${keys[$i]} ] && { max_key=${keys[$i]}; }

			done
			local n_rows=$(( $max_key + 1 ))
			echo $n_rows 
		};



array_columns_old () 	{
			############# ############# ############# ############# ############# ############# #############
		        #############  Restituisce il numero di colonne di un array 2D a partire dalle keys ############# 
		        ############# ############# ############# ############# ############# ############# #############  
		
			local arraykeys=("$@")
			local last_idx=$(( ${#arraykeys[@]} - 1 ))
			local max_index=${arraykeys[$last_idx]}
			unset arraykeys[$last_idx]
			local contr=0
			while [[ $contc -eq 0 && $max_index -ne -1 ]]; do	
			
				contc=$( echo "${arraykeys[@]}" | tr " " "\n" | grep -c ",${max_index}" )
				ncolumns=$max_index
				max_index=$(( ${max_index}-1 ))	
			done
			echo $ncolumns
		};


array_columns () 	{
			############# ############# ############# ############# ############# ############# #############
		        #############  Restituisce il numero di colonne di un array 2D a partire dalle keys ############# 
		        ############# ############# ############# ############# ############# ############# #############  
		
			local arraykeys="$@"
			local keys="${arraykeys//','/' '}"
			keys=( $keys )
			local max_key=0
			[ -z ${keys} ] && { echo "no input given!";return  -1; }
			for (( i=1; i<${#keys[@]}; i=$i+2 )); do

				[ $max_key -lt ${keys[$i]} ] && { max_key=${keys[$i]}; }

			done
			local n_columns=$(( $max_key + 1 ))
			echo $n_columns 
		};

array_shape () 	{

			############# ############# ############# ############# ############# ############# #############
		        #############     Restituisce le dimensionid di un array 2D a partire dalle keys    ############# 
		        ############# ############# ############# ############# ############# ############# #############
		        
		        if [ $# -lt 1 ]; then							# usage dello script							
			    echo $0: "usage: array_shape <array_keys> [<dim>]"
			    echo "    array_keys key of the array "
			    echo "    dim 1 for rows 2 for column; if empty return both "	 	
			    return 1;		    
			fi 

			local list=("$@")
			local last_idx=$(( ${#list[@]} - 1 ))
			local roc=${list[$last_idx]}
		
			re='^[0-9]+$'
			[[ $roc =~ $re ]] || {  roc=-1; } 
			
			
			if [ $roc -ne -1 ]; then
				
				unset list[$last_idx]
				local max=0
				[ $roc -eq 1 ] && { max=$( array_rows "${list[@]}" ); }
				[ $roc -eq 2 ] && { max=$( array_columns "${list[@]}" );  }	
				result=$max
			else
				echo ${list[@]}
				maxr=$( array_rows ${list[@]}  )
				maxc=$( array_columns ${list[@]} )
				
				result="$maxr,$maxc"
				
			
			fi
			
			echo $result
		};



array_zeros () {

		local dim1=$1
		local dim2=$2
		declare -A zeros
		for (( i=0; i<${dim1}; i++ )); do
			for (( j=0; j<${dim2}; j++ )); do			
						
				zeros[$i,$j]=0					
		
			done	
		done
		
		echo "${zeros[@]}"	
		 
		};


array_neg () {

		if [ $# -lt 1 ]; then							# usage dello script							
		    echo $0: usage: "array_neg <vect>"
		    return 1;		    
		fi
		
		local vect_j=( "$@" ) 
		
		local N="${#vect_j[@]}"
		for (( idx=0; idx<$N; idx++ ));

			do				
			value=${vect_j[$idx]}
			value=$( echo $value | awk -F"E" 'BEGIN{OFMT="%10.10f"} {print $1 * (10 ^ $2)}' )
			
			vect_j[$idx]=$(echo "scale=6; -1*${value} " | bc | awk '{printf "%f", $0}')
			
		done
		
		echo "${vect_j[@]}"
		
			
		};

array_iselement_old () {
			if [ $# -lt 2 ]; then							# usage dello script							
			    echo $0: usage: "array_iselement <value> <vect>"
			    return 1;		    
			fi
			local vect=("$@")
			local value=${vect[0]}
			unset vect[0]
			vect=( "${vect[@]}" )
			local N="${#vect[@]}"
			local result=0
		
			for (( idx=0; idx<$N; idx++ ));

				do	
				[ ${vect[$idx]} -eq ${value} ] && { result=1; break; }

			done
		
			echo $result			

			};

array_iselement () {
			if [ $# -lt 2 ]; then							# usage dello script							
			    echo $0: usage: "array_iselement <value> <vect>"
			    return 1;		    
			fi
			local vect=("$@")
			local value=${vect[0]}
			unset vect[0]
			vect=( "${vect[@]}" )
			local N="${#vect[@]}"
			local result=0
		
			for (( idx=0; idx<$N; idx++ ));

				do	
				[ "${vect[$idx]}" == "${value}" ] && { result=1; break; }

			done
		
			echo $result			

			};


array_stdev () {
    
			if [ $# -lt 1 ]; then							# usage dello script							
			    echo $0: usage: "array_stdev <vect>"
			    return 1;		    
			fi 

			local vect=("$@")
			mean=$( array_mean ${vect[@]} )
			sqdif=0
			for ((i=0; i<${#vect[@]}; i++)); do  
				sqdif=$(echo "scale=6; ${sqdif}+((${vect[i]}-${mean})^2) " | bc )
			done
			result=$(echo "scale=6; sqrt(${sqdif}/${#vect[@]}) " | bc | awk '{printf "%f", $0}' ) 
			echo $result
	
		}

array_stdevs () {
    
			if [ $# -lt 1 ]; then							# usage dello script							
			    echo $0: usage: "array_stdev <vect>"
			    return 1;		    
			fi 

			local vect=("$@")
			mean=$( array_mean ${vect[@]} )
			sqdif=0
			for ((i=0; i<${#vect[@]}; i++)); do  
				sqdif=$(echo "scale=6; ${sqdif}+((${vect[i]}-${mean})^2) " | bc )
			done
			result=$(echo "scale=6; sqrt(${sqdif}/(${#vect[@]}-1)) " | bc | awk '{printf "%f", $0}' ) 
			echo $result
	
		}
