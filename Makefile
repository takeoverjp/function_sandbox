all: std_func_gcc
.PHONY: all

clean:
	rm -f std_func_gcc
.PHONY: clean

std_func_gcc: std_func.cc
	g++ -Og -g -o $@ $^
