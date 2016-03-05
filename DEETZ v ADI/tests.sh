#!/bin/bash

clear
clear
clear

echo "Adi"

a=1;
while [ $a -le 15 ]
do
    INPUT="test/adi_test$a.c"
    OUTPUT="test/adi_adi_output$a.txt"
    ORIGINAL="test/adi_deetz_output$a.txt"
	echo ${INPUT}
	cat ${INPUT} | ./adi_c_parser > ${OUTPUT}
	cat ${INPUT} | ./deetz_c_parser > ${ORIGINAL}
	# Look at the differences (this assumes no comments)
	diff ${OUTPUT} ${ORIGINAL}

	# Display the input, output and achieved results next to each other in terminal
	#pr -m -t  ${INPUT} ${OUTPUT}.difftest ${GOT}.difftest

	(( a++ ))
done

echo "Deetz"

a=1;
while [ $a -le 8 ]
do
    INPUT="test/deetz_test$a.c"
    OUTPUT="test/deetz_adi_output$a.txt"
    ORIGINAL="test/deetz_deetz_output$a.txt"
	cat ${INPUT} | ./adi_c_parser > ${OUTPUT}
	cat ${INPUT} | ./deetz_c_parser > ${ORIGINAL}
	# Look at the differences (this assumes no comments)
	echo ${INPUT}
	diff ${OUTPUT} ${ORIGINAL}

	# Display the input, output and achieved results next to each other in terminal
	#pr -m -t  ${INPUT} ${OUTPUT}.difftest ${GOT}.difftest

	(( a++ ))
done

