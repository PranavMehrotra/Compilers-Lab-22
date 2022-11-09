
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

test: a.out
	@echo "Running test 1"
	./a.out < ass5_20CS10085_20CS30065_test1.c > ass5_20CS10085_20CS30065_quads1.out
	@echo "Test 1 complete\n"

	@echo "Running test 2"
	./a.out < ass5_20CS10085_20CS30065_test2.c > ass5_20CS10085_20CS30065_quads2.out
	@echo "Test 2 complete\n"

	@echo "Running test 3"
	./a.out < ass5_20CS10085_20CS30065_test3.c > ass5_20CS10085_20CS30065_quads3.out
	@echo "Test 3 complete\n"

	@echo "Running test 4"
	./a.out < ass5_20CS10085_20CS30065_test4.c > ass5_20CS10085_20CS30065_quads4.out
	@echo "Test 4 complete\n"

	@echo "Running test 5"
	./a.out < ass5_20CS10085_20CS30065_test5.c > ass5_20CS10085_20CS30065_quads5.out
	@echo "Test 5 complete\n"


	
clean:
	rm lex.yy.c y.tab.c y.tab.h lex.yy.o y.tab.o ass5_20CS10085_20CS30065_translator.o y.output a.out 

deepclean:
	rm lex.yy.c y.tab.c y.tab.h lex.yy.o y.tab.o ass5_20CS10085_20CS30065_translator.o y.output a.out *_quads*.out
