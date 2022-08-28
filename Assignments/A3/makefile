output: a.out ass3_20CS10085_20CS30065_test.c
	./a.out < ass3_20CS10085_20CS30065_test.c  

a.out: lex.yy.c
	gcc lex.yy.c ass3_20CS10085_20CS30065.c

lex.yy.c: 
	lex ass3_20CS10085_20CS30065.l 

clean:
	rm a.out lex.yy.c 