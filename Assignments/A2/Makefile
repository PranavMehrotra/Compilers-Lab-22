asgn2: main.o libass2_20CS10085.a
	cc main.o -L. -lass2_20CS10085 -o asgn2
main.o: main.c myl.h
	cc -Wall -c main.c
libass2_20CS10085.a: ass2_20CS10085.o
	ar -rcs libass2_20CS10085.a ass2_20CS10085.o
ass2_20CS10085.o: ass2_20CS10085.c myl.h
	cc -Wall -c ass2_20CS10085.c
clean:
	rm asgn2 main.o libass2_20CS10085.a ass2_20CS10085.o