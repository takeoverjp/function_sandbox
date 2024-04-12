BIN=std_func_gcc normal_func_gcc

all: $(BIN)
.PHONY: all

clean:
	rm -f $(BIN)
.PHONY: clean

run: $(BIN)
	time ./std_func_gcc
	time ./normal_func_gcc

std_func_gcc: std_func.cc
	g++ -Og -g -o $@ $^

normal_func_gcc: normal_func.cc
	g++ -Og -g -o $@ $^
