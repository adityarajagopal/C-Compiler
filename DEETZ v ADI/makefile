#!/bin/bash

c_parser : c_lexer.yy.o c_parser.tab.o
	g++ -o c_parser c_parser.tab.o c_lexer.yy.o

c_lexer.yy.o : c_lexer.yy.c c_parser.tab.h
	g++ -c c_lexer.yy.c

c_parser.tab.o : c_parser.tab.h c_parser.tab.c
	g++ -c c_parser.tab.c 

c_parser.tab.h : c_parser.y
	bison -d c_parser.y

c_parser.tab.c : c_parser.y
	bison -d c_parser.y

c_lexer.yy.c : c_lexer.l
	flex -o c_lexer.yy.c c_lexer.l

test_adi : c_parser aid_test_output.txt
	cat test_own/test$(num).c | ./c_parser > adi_test_output_$(num).txt

test_deetz : c_parser deetz_test_output.txt
	cat test_deetz/test$(num).c | ./c_parser > deetz_test_output_$(num).txt

full_test :
	./tests.sh

clean : 
	rm ./c_parser
