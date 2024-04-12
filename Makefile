BINS=\
	inline_func_clang \
	inline_func_gcc \
	lambda_clang \
	lambda_gcc \
	macro_func_clang \
	macro_func_gcc \
	normal_func_clang \
	normal_func_gcc \
	std_func_clang \
	std_func_gcc \

all: $(BINS)
.PHONY: all

clean:
	rm -f $(BINS)
.PHONY: clean

run: $(BINS)
	for BIN in $(BINS); do \
		time ./$$BIN; \
	done

CXXFLAGS=-Og -g -W -Wall -Werror -Wno-unused-parameter

inline_func_gcc: inline_func.cc
	g++ $(CXXFLAGS) -o $@ $^

inline_func_clang: inline_func.cc
	clang $(CXXFLAGS) -o $@ $^

lambda_gcc: lambda.cc
	g++ $(CXXFLAGS) -o $@ $^

lambda_clang: lambda.cc
	clang $(CXXFLAGS) -o $@ $^

macro_func_gcc: macro_func.cc
	g++ $(CXXFLAGS) -o $@ $^

macro_func_clang: macro_func.cc
	clang $(CXXFLAGS) -o $@ $^

normal_func_gcc: normal_func.cc
	g++ $(CXXFLAGS) -o $@ $^

normal_func_clang: normal_func.cc
	clang $(CXXFLAGS) -o $@ $^

std_func_gcc: std_func.cc
	g++ $(CXXFLAGS) -o $@ $^

std_func_clang: std_func.cc
	clang $(CXXFLAGS) -o $@ $^

