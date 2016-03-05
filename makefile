#!/bin/bash

bin/c_parser : c_lexer.yy.o c_parser.tab.o
	g++ -o bin/c_parser c_parser.tab.o c_lexer.yy.o

c_lexer.yy.o : c_lexer.yy.c c_parser.tab.h
	g++ -c c_lexer.yy.c

c_parser.tab.o : c_parser.tab.h c_parser.tab.c
	g++ -c c_parser.tab.c 

c_parser.tab.h : src/c_parser.y
	bison -d src/c_parser.y

c_parser.tab.c : src/c_parser.y
	bison -d src/c_parser.y

c_lexer.yy.c : src/c_lexer.l
	flex -o c_lexer.yy.c src/c_lexer.l

test_own : bin/c_parser own_test_output.txt
	cat test_own/adi_test_$(num).c | ./bin/c_parser > own_test_output.txt

test_deetz : c_parser deetz_test_output.txt
	cat test_deetz/test$(num).c | ./c_parser > deetz_test_output.txt

test_all : c_parser 
	./test_all.sh

clean : 
	rm bin/c_parser
	rm c_lexer.yy.c
	rm c_lexer.yy.o
	rm c_parser.tab.h
	rm c_parser.tab.c
	rm c_parser.tab.o
