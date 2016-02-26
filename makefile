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

test_own : c_parser own_test_output.txt
	cat test_own/test$(num).c | ./c_parser > own_test_output.txt

test_deetz : c_parser deetz_test_output.txt
	cat test_deetz/test$(num).c | ./c_parser > deetz_test_output.txt

clean : 
	rm ./c_parser
	rm c_lexer.yy.c
	rm c_lexer.yy.o 
