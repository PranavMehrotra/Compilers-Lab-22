asgn4_20CS10085_20CS30065_output.txt: a.out asgn4_20CS10085_20CS30065_test.c 
	./a.out < asgn4_20CS10085_20CS30065_test.c > asgn4_20CS10085_20CS30065_output.txt

a.out: lex.yy.c y.tab.c asgn4_20CS10085_20CS30065_main.c
	gcc lex.yy.c y.tab.c asgn4_20CS10085_20CS30065_main.c -lfl

lex.yy.c: asgn4_20CS10085_20CS30065.l
	flex asgn4_20CS10085_20CS30065.l

y.tab.c: asgn4_20CS10085_20CS30065.y
	yacc -dtv asgn4_20CS10085_20CS30065.y

clean:
	rm lex.yy.c y.tab.c y.tab.h y.output a.out asgn4_20CS10085_20CS30065_output.txt