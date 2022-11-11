tinyC: lex.yy.o ass6_20CS10085_20CS30065.tab.o ass6_20CS10085_20CS30065_translator.o ass6_20CS10085_20CS30065_target_translator.o
	g++ -std=c++14 lex.yy.o ass6_20CS10085_20CS30065.tab.o ass6_20CS10085_20CS30065_translator.o ass6_20CS10085_20CS30065_target_translator.o -lfl -o tinyC
	@echo "\nMake process successful. The binary generated is tinyC\n"

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

test: tinyC libass6_20CS10085_20CS30065.a
	@mkdir -p test-outputs
	@mkdir -p bin
	
	@echo "\nRunning Test 2\n"
	./tinyC 2 < test-inputs/ass6_20CS10085_20CS30065_test2.c > test-outputs/ass6_20CS10085_20CS30065_quads2.out
	mv ass6_20CS10085_20CS30065_2.s test-outputs/ass6_20CS10085_20CS30065_2.s
	gcc -c test-outputs/ass6_20CS10085_20CS30065_2.s -o test-outputs/ass6_20CS10085_20CS30065_2.o
	gcc test-outputs/ass6_20CS10085_20CS30065_2.o -o bin/test2 -L. -lass6_20CS10085_20CS30065 -no-pie

	@echo "\nRunning Test 3\n"
	./tinyC 3 < test-inputs/ass6_20CS10085_20CS30065_test3.c > test-outputs/ass6_20CS10085_20CS30065_quads3.out
	mv ass6_20CS10085_20CS30065_3.s test-outputs/ass6_20CS10085_20CS30065_3.s
	gcc -c test-outputs/ass6_20CS10085_20CS30065_3.s -o test-outputs/ass6_20CS10085_20CS30065_3.o
	gcc test-outputs/ass6_20CS10085_20CS30065_3.o -o bin/test3 -L. -lass6_20CS10085_20CS30065 -no-pie

	@echo "\nRunning Test 4\n"
	./tinyC 4 < test-inputs/ass6_20CS10085_20CS30065_test4.c > test-outputs/ass6_20CS10085_20CS30065_quads4.out
	mv ass6_20CS10085_20CS30065_4.s test-outputs/ass6_20CS10085_20CS30065_4.s
	gcc -c test-outputs/ass6_20CS10085_20CS30065_4.s -o test-outputs/ass6_20CS10085_20CS30065_4.o
	gcc test-outputs/ass6_20CS10085_20CS30065_4.o -o bin/test4 -L. -lass6_20CS10085_20CS30065 -no-pie

	@echo "\nRunning Test 5\n"
	./tinyC 5 < test-inputs/ass6_20CS10085_20CS30065_test5.c > test-outputs/ass6_20CS10085_20CS30065_quads5.out
	mv ass6_20CS10085_20CS30065_5.s test-outputs/ass6_20CS10085_20CS30065_5.s
	gcc -c test-outputs/ass6_20CS10085_20CS30065_5.s -o test-outputs/ass6_20CS10085_20CS30065_5.o
	gcc test-outputs/ass6_20CS10085_20CS30065_5.o -o bin/test5 -L. -lass6_20CS10085_20CS30065 -no-pie

	@echo "\nRunning Test 6\n"
	./tinyC 6 < test-inputs/ass6_20CS10085_20CS30065_test6.c > test-outputs/ass6_20CS10085_20CS30065_quads6.out
	mv ass6_20CS10085_20CS30065_6.s test-outputs/ass6_20CS10085_20CS30065_6.s
	gcc -c test-outputs/ass6_20CS10085_20CS30065_6.s -o test-outputs/ass6_20CS10085_20CS30065_6.o
	gcc test-outputs/ass6_20CS10085_20CS30065_6.o -o bin/test6 -L. -lass6_20CS10085_20CS30065 -no-pie

	@echo "\nThe three address quads, assembly files and object files are in test-outputs/\n"
	@echo "The binaries for the test files are in bin/\n"

clean:
	rm -f lex.yy.c *.tab.c *.tab.h *.output *.o *.s *.a *.out *.gch tinyC test-outputs/* bin/*
