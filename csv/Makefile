CSV_OBJ = \
              csvgen.o testgen.o \
              csvparser.o testparser.o
%.o : %.cbl
	cobc -free -O3 -c $< -o $@
%.o : %.c
	gcc -std=c11 -O3 -fPIC -c $< -o $@

all: CSV.so

CSV.so: $(CSV_OBJ)
	cobc -b -O3 -o CSV $(CSV_OBJ)

realclean: clean
	-rm -rf CSV.so

clean:
	-rm -rf *.o
