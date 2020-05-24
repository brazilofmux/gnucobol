DATES_OBJ = \
              dateutil.o \
              fielded_to_linear.o floor-div.o floor-divmod.o isleapyear.o isvaliddate.o linear_to_fielded.o \
              today.o holidays.o \
              main.o main2.o clinkages.o
%.o : %.cbl
	cobc -free -O3 -c $< -o $@
%.o : %.c
	gcc -std=c11 -O3 -fPIC -c $< -o $@

all: DATES.so

DATES.so: $(DATES_OBJ)
	cobc -b -O3 -o DATES $(DATES_OBJ)

realclean: clean
	-rm -rf DATES.so

clean:
	-rm -rf *.o
