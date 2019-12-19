# -C = Case sensitive labels
# -B = automatic bxx *+3 jmpo $xxxx


# Library output directory.  Your C program will have to link the vera.lib file created here into your C program.
LIBRARIES = ../../lib
# Header output directory.  Your C program will have to include the vera.h file that is copied here.
INCLUDE = ../../header

FILES=\
	vera.s


vera.lib: $(FILES)
	ca65 -t cx16 vera.s
	ar65 r vera.lib vera.o
	cp *.lib $(LIBRARIES)
	cp *.h $(INCLUDE)
	rm *.o
	rm *.lib