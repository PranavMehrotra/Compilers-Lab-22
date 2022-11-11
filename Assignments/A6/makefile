tiny_parser.out: lex.yy.o ass6_20CS10085_20CS30065.tab.o ass6_20CS10085_20CS30065_translator.o ass6_20CS10085_20CS30065_target_translator.o
	g++ -std=c++14 lex.yy.o ass6_20CS10085_20CS30065.tab.o ass6_20CS10085_20CS30065_translator.o ass6_20CS10085_20CS30065_target_translator.o -lfl -o tiny_parser.out
	
ass6_20CS10085_20CS30065_target_translator.o: ass6_20CS10085_20CS30065_target_translator.cxx
	g++ -std=c++14 -c ass6_20CS10085_20CS30065_target_translator.cxx

ass6_20CS10085_20CS30065_translator.o: ass6_20CS10085_20CS30065_translator.h ass6_20CS10085_20CS30065_translator.cxx
	g++ -std=c++14 -c ass6_20CS10085_20CS30065_translator.h
	g++ -std=c++14 -c ass6_20CS10085_20CS30065_translator.cxx

lex.yy.o: lex.yy.c
	g++ -std=c++14 -c lex.yy.c

ass6_20CS10085_20CS30065.tab.o: ass6_20CS10085_20CS30065.tab.c
	g++ -std=c++14 -c ass6_20CS10085_20CS30065.tab.c

lex.yy.c: ass6_20CS10085_20CS30065.l ass6_20CS10085_20CS30065.tab.h ass6_20CS10085_20CS30065_translator.h
	flex ass6_20CS10085_20CS30065.l

ass6_20CS10085_20CS30065.tab.c: ass6_20CS10085_20CS30065.y
	bison -dtv ass6_20CS10085_20CS30065.y

ass6_20CS10085_20CS30065.tab.h: ass6_20CS10085_20CS30065.y
	bison -dtv ass6_20CS10085_20CS30065.y

libass6_20CS10085_20CS30065.a: ass6_20CS10085_20CS30065.o
	ar -rcs libass6_20CS10085_20CS30065.a ass6_20CS10085_20CS30065.o

ass6_20CS10085_20CS30065.o: ass6_20CS10085_20CS30065.c myl.h
	gcc -c ass6_20CS10085_20CS30065.c

ass6_20CS10085_20CS30065.c:
	touch ass6_20CS10085_20CS30065.c

test: tiny_parser.out libass6_20CS10085_20CS30065.a
	@mkdir -p outputs
	@mkdir -p binary_target
	
	./tiny_parser.out 1 < inputs/ass6_20CS10085_20CS30065_test1.c > outputs/ass6_20CS10085_20CS30065_TAC_1.out
	mv ass6_20CS10085_20CS30065_1.s outputs/ass6_20CS10085_20CS30065_1.s
	gcc -c outputs/ass6_20CS10085_20CS30065_1.s -o outputs/ass6_20CS10085_20CS30065_1.o
	gcc outputs/ass6_20CS10085_20CS30065_1.o -o binary_target/test1 -L. -lass6_20CS10085_20CS30065 -no-pie

	./tiny_parser.out 2 < inputs/ass6_20CS10085_20CS30065_test2.c > outputs/ass6_20CS10085_20CS30065_TAC_2.out
	mv ass6_20CS10085_20CS30065_2.s outputs/ass6_20CS10085_20CS30065_2.s
	gcc -c outputs/ass6_20CS10085_20CS30065_2.s -o outputs/ass6_20CS10085_20CS30065_2.o
	gcc outputs/ass6_20CS10085_20CS30065_2.o -o binary_target/test2 -L. -lass6_20CS10085_20CS30065 -no-pie

	./tiny_parser.out 3 < inputs/ass6_20CS10085_20CS30065_test3.c > outputs/ass6_20CS10085_20CS30065_TAC_3.out
	mv ass6_20CS10085_20CS30065_3.s outputs/ass6_20CS10085_20CS30065_3.s
	gcc -c outputs/ass6_20CS10085_20CS30065_3.s -o outputs/ass6_20CS10085_20CS30065_3.o
	gcc outputs/ass6_20CS10085_20CS30065_3.o -o binary_target/test3 -L. -lass6_20CS10085_20CS30065 -no-pie

	./tiny_parser.out 4 < inputs/ass6_20CS10085_20CS30065_test4.c > outputs/ass6_20CS10085_20CS30065_TAC_4.out
	mv ass6_20CS10085_20CS30065_4.s outputs/ass6_20CS10085_20CS30065_4.s
	gcc -c outputs/ass6_20CS10085_20CS30065_4.s -o outputs/ass6_20CS10085_20CS30065_4.o
	gcc outputs/ass6_20CS10085_20CS30065_4.o -o binary_target/test4 -L. -lass6_20CS10085_20CS30065 -no-pie

	./tiny_parser.out 5 < inputs/ass6_20CS10085_20CS30065_test5.c > outputs/ass6_20CS10085_20CS30065_TAC_5.out
	mv ass6_20CS10085_20CS30065_5.s outputs/ass6_20CS10085_20CS30065_5.s
	gcc -c outputs/ass6_20CS10085_20CS30065_5.s -o outputs/ass6_20CS10085_20CS30065_5.o
	gcc outputs/ass6_20CS10085_20CS30065_5.o -o binary_target/test5 -L. -lass6_20CS10085_20CS30065 -no-pie
	
clean:
	rm -f lex.yy.c *.tab.c *.tab.h *.output *.o *.s *.a *.out *.gch tiny_parser.out outputs/* binary_target/*
