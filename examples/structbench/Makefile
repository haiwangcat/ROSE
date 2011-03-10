BABELPATH=/home/prantl1/work/babel/install/bin
PYTHONPATH=/home/prantl1/work/babel/install/lib/python2.6/site-packages

#NUMBERS=1 #2 4 6 8 12 16 24 32 48 64 96 128 #256 512
NUMBERS=$(shell seq 1 16) 18 20 $(shell seq 24 4 48) 64 96 128
NUMBER_TYPES=$(patsubst %, %_float, $(NUMBERS)) \
             $(patsubst %, %_bool, $(NUMBERS)) \
             $(patsubst %, %_string, $(NUMBERS))
NUMBER_TYPE_EXPRS=$(patsubst %, %_reverse, $(NUMBER_TYPES)) \
                  $(patsubst %, %_nop,  $(NUMBER_TYPES)) \
                  $(patsubst %, %_int_bsort, $(NUMBERS))

#NUMBER_TYPE_EXPRS=2_int_bsort 128_int_bsort #128_string_reverse 128_bool_nop 128_float_reverse
SIDLS=$(patsubst %,out/struct_%.sidl, $(NUMBER_TYPE_EXPRS))
COMPILES=$(patsubst %,out/client_%/token, $(NUMBER_TYPE_EXPRS))
TIMINGS=$(patsubst %,out/client_%/times, $(NUMBER_TYPE_EXPRS))

TYPES=float bool string
RESULTS=$(patsubst %, out/result_%_reverse.txt, $(TYPES)) \
        $(patsubst %, out/result_%_nop.txt, $(TYPES)) 

.PHONY: clean all sidls compile timings

all: graph.pdf

graph.pdf: graph.tex timings
	make $(RESULTS)
	env TEXINPUTS=~/sw/share/texmf//:$(TEXINPUTS) pdflatex -halt-on-error graph

out/result_%.txt:
	echo "n" "C" "CXX" "F77" "F90" "F03" "Java" "Python" >$@
	cat out/client_*_$(patsubst out/result_%.txt,%,$@)/times |sort -g >>$@

sidls: $(SIDLS)

compile: sidls 
	$(MAKE) $(COMPILES)
timings: compile
	$(MAKE) $(TIMINGS) # execute timing measurements serially

clean:
	rm -rf out graph.pdf

# this sed orgy seperates the parameters out of the filename:
#   out/struct_1_bool_nop.sidl -> 1 bool nop
out/struct_%.sidl:
	env PATH=$(BABELPATH):$(PATH) \
	    PYTHONPATH=$(PYTHONPATH) \
	    python benchgen.py \
		$(shell echo $(patsubst out/struct_%.sidl,%,$@) | sed 's/_.*//g') \
		$(shell echo $(patsubst out/struct_%.sidl,%,$@) | sed 's/.*_\(.*\)_.*/\1/') \
		$(shell echo $(patsubst out/struct_%.sidl,%,$@) | sed 's/.*._//g') 

out/client_%/times:
	@cd $(patsubst %/times,%,$@) && \
	 env PATH=$(BABELPATH):$(PATH) \
	    PYTHONPATH=$(PYTHONPATH) \
	    bash runAll.sh

out/C_%/token: out/struct_%.sidl
	env PATH=$(BABELPATH):$(PATH) \
	$(MAKE) -C $(patsubst %/token,%,$@)  all
	touch $@
out/CXX_%/token: out/struct_%.sidl
	env PATH=$(BABELPATH):$(PATH) \
	$(MAKE) -C $(patsubst %/token,%,$@)  all
	touch $@
out/F77_%/token: out/struct_%.sidl
	env PATH=$(BABELPATH):$(PATH) \
	$(MAKE) -C $(patsubst %/token,%,$@)  all
	touch $@
out/F90_%/token: out/struct_%.sidl
	env PATH=$(BABELPATH):$(PATH) \
	$(MAKE) -C $(patsubst %/token,%,$@)  all
	touch $@
out/F03_%/token: out/struct_%.sidl
	env PATH=$(BABELPATH):$(PATH) \
	$(MAKE) -C $(patsubst %/token,%,$@)  all
	touch $@
out/Python_%/token: out/struct_%.sidl
	env PATH=$(BABELPATH):$(PATH) \
	$(MAKE) -C $(patsubst %/token,%,$@)  all
	touch $@
out/Java_%/token: out/struct_%.sidl
	env PATH=$(BABELPATH):$(PATH) \
	$(MAKE) -C $(patsubst %/token,%,$@)  all
	touch $@
out/client_%/token: out/struct_%.sidl out/C_%/token out/CXX_%/token out/F77_%/token out/F90_%/token out/F03_%/token out/Python_%/token out/Java_%/token
	env PATH=$(BABELPATH):$(PATH) \
	$(MAKE) -C $(patsubst %/token,%,$@)  all
	touch $@

run:
	env PYTHONPATH=../install/lib/python2.6/site-packages python benchgen.py \
	  n /home/prantl1/work/babel/install/bin/babel
