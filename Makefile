BINS=std_func_gcc normal_func_gcc

all: $(BINS)
.PHONY: all

clean:
	rm -f $(BINS)
.PHONY: clean

run: $(BINS)
	for BIN in $(BINS); do \
		time ./$$BIN; \
	done

std_func_gcc: std_func.cc
	g++ -Og -g -o $@ $^

normal_func_gcc: normal_func.cc
	g++ -Og -g -o $@ $^
