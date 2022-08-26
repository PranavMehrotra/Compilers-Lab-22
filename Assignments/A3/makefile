output.txt: a.out a.txt
	./a.out < a.txt 

a.out: lex.yy.c
	gcc lex.yy.c ass3_20CS10085_20CS30065.c

lex.yy.c: 
	lex ass3_20CS10085_20CS30065.l 

clean:
	rm a.out lex.yy.c output.txt