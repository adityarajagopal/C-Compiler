#!/bin/bash

PUT= 

while [ "$1" != "" ]; do
    case $1 in
        -on )          	PUT=1
                        ;;
        -off )    	PUT=0
                        ;;
    esac
	shift
done

files=("src/c_parser.y")
lineNo=
for i in ${files[@]}; do
	lineNo=$(wc -l < $i)
	echo ${i}
		if [ "$PUT" = "1" ]; then
			for ((j=1; j<=${lineNo}; j++)); do
				echo ${j}
				sed -E -i -e "${j}s/([:|][^:|]*\{)(.*)/\1std\:\:cerr << $j << std\:\:endl; \2/g" ${i}
			done
		else
			sed -E -i -e "s/std\:\:cerr << [0-9]+ << std\:\:endl; //g" ${i}
		fi
	chmod +w ${i}

done
