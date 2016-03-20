#!/bin/bash

#Saves the output assembly of the compiler for each test in test/ with the appropriate name 
#in the form (name of person running this script)_(name of test maker)_test_(test_number).s

#TO RUN:
	#Save your name in NAME_EXE before runnning
	#If want to save a single test made by X change NAME_TEST to X 
	#	and calll program with name of test eg (./save_test.sh 1)


NAME_EXE=adi
NAME_TEST=jesus
NUM=
TESTS="$(ls test/ | sed -E -e '/([a-z]+_test_[0-9]+\.c)/!d' | sed -E -e 's%([a-z]+_test_[0-9]+).c%\1%')"

while [ "$1" != "" ]; do
   NUM=$1;
	shift
done

if [ "$NUM" != "" ]; then
	cat test/${NAME_TEST}_test_${NUM}.c | bin/c_codegen > ${NAME_EXE}_${NAME_TEST}_test_${NUM}.txt
else
	for t in $TESTS;
	do
		echo saving ${t}
		cat test/${t}.c | bin/c_codegen > test/${NAME_EXE}_${t}.s
	done
fi
