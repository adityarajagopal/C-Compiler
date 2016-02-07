all:
	flex -o initial.c c_lexer.l
	g++ initial.c -o initial
	cat test.c | ./initial > output.txt
