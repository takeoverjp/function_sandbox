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
	$(addsuffix _gcc_Og,$(basename $(SRCS))) \
	$(addsuffix _clang_Og,$(basename $(SRCS))) \
	$(addsuffix _gcc_O2,$(basename $(SRCS))) \
	$(addsuffix _clang_O2,$(basename $(SRCS)))

ASMS=\
	$(addsuffix .asm,$(basename $(BINS)))

all: $(BINS) $(ASMS)
.PHONY: all

CXXFLAGS=-g
CXXFLAGS+=-W -Wall -Werror -Wno-unused-parameter -Wno-unused-variable
# CXXFLAGS+=-DNDEBUG

define TEMPLATE_SRC2BIN
$(basename $(1))_gcc_Og: $(1)
	g++ $$(CXXFLAGS) -Og -o $$@ $$^
$(basename $(1))_clang_Og: $(1)
	clang++ $$(CXXFLAGS) -Og -o $$@ $$^
$(basename $(1))_gcc_O2: $(1)
	g++ $$(CXXFLAGS) -O2 -o $$@ $$^
$(basename $(1))_clang_O2: $(1)
	clang++ $$(CXXFLAGS) -O2 -o $$@ $$^
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
	sed -i -r -e 's|^./||' -e 's/_(gcc|clang)_/,\1_/' -e 's/_(Og|O2),/,\1,/' result.csv
