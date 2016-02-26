#!/bin/bash

for i in $(ls)
do 
	NAME=$(echo $i | sed -E -e 's/output_([0-9]+.txt)/adi_expect_\1/')
	mv $i $NAME
done

