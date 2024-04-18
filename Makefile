SRCS=\
	inline_func.cc \
	lambda.cc \
	macro_func.cc \
	normal_func.cc \
	std_func.cc \
	func_ptr.cc \
	method.cc \
	virtual_method.cc \
	kj_func.cc \
	functor.cc \
	boost_func.cc \

BINS=\
	$(addsuffix _gcc,$(basename $(SRCS))) \
	$(addsuffix _clang,$(basename $(SRCS)))

all: $(BINS)
.PHONY: all

CXXFLAGS=-Og -g
CXXFLAGS+=-W -Wall -Werror -Wno-unused-parameter -Wno-unused-variable
CXXFLAGS+=-DNDEBUG

define TEMPLATE
$(basename $(1))_gcc: $(1)
	g++ $$(CXXFLAGS) -o $$@ $$^
$(basename $(1))_clang: $(1)
	clang++ $$(CXXFLAGS) -o $$@ $$^
endef
$(foreach src,$(SRCS),$(eval $(call TEMPLATE,$(src))))

clean:
	rm -f $(BINS)
.PHONY: clean

run: all
	for BIN in $(BINS); do \
		echo $$BIN start; \
		chrt -f 99 time ./$$BIN; \
		echo; \
	done
