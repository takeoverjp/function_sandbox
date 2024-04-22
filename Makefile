SRCS=\
	constexpr_func.cc \
	inline_func.cc \
	macro_func.cc \
	normal_func.cc \
	func_ptr.cc \
	method.cc \
	functor.cc \
	lambda.cc \
	std_func.cc \
	kj_func.cc \
	boost_func.cc \
	virtual_method.cc \

BINS=\
	$(addsuffix _gcc,$(basename $(SRCS))) \
	$(addsuffix _clang,$(basename $(SRCS)))

ASMS=\
	$(addsuffix .asm,$(basename $(BINS)))

all: $(BINS) $(ASMS)
.PHONY: all

CXXFLAGS=-Og -g
CXXFLAGS+=-W -Wall -Werror -Wno-unused-parameter -Wno-unused-variable
# CXXFLAGS+=-DNDEBUG

define TEMPLATE_SRC2BIN
$(basename $(1))_gcc: $(1)
	g++ $$(CXXFLAGS) -o $$@ $$^
$(basename $(1))_clang: $(1)
	clang++ $$(CXXFLAGS) -o $$@ $$^
endef
$(foreach src,$(SRCS),$(eval $(call TEMPLATE_SRC2BIN,$(src))))

define TEMPLATE_BIN2ASM
$(1).asm: $(1)
	objdump -SwC $$^ > $$@
endef
$(foreach bin,$(BINS),$(eval $(call TEMPLATE_BIN2ASM,$(bin))))

clean:
	rm -f $(BINS) $(ASMS)
.PHONY: clean

result.csv: all
	rm -f $@
	for BIN in $(BINS); do \
		chrt -f 99 time -f %C,%e,%S,%U ./$$BIN 2>&1 > /dev/null | tee -a $@; \
	done
	sed -i -r -e 's|^./||' -e 's/_(gcc|clang),/,\1,/' result.csv
