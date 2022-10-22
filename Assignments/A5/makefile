
a.out: lex.yy.o y.tab.o ass5_20CS10085_20CS30065_translator.o
	g++ lex.yy.o y.tab.o ass5_20CS10085_20CS30065_translator.o -lfl

ass5_20CS10085_20CS30065_translator.o: ass5_20CS10085_20CS30065_translator.cxx ass5_20CS10085_20CS30065_translator.h
	g++ -c -std=c++14 ass5_20CS10085_20CS30065_translator.cxx

lex.yy.o: lex.yy.c
	g++ -std=c++14 -c lex.yy.c

y.tab.o: y.tab.c
	g++ -std=c++14 -c y.tab.c

lex.yy.c: ass5_20CS10085_20CS30065.l y.tab.h ass5_20CS10085_20CS30065_translator.h
	flex ass5_20CS10085_20CS30065.l

y.tab.c y.tab.h: ass5_20CS10085_20CS30065.y
	yacc -dtv ass5_20CS10085_20CS30065.y

clean:
	rm lex.yy.c y.tab.c y.tab.h lex.yy.o y.tab.o ass5_20CS10085_20CS30065_translator.o y.output a.out 
