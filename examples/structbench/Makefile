BABELPATH=/home/prantl1/work/babel/install/bin
PYTHONPATH=/home/prantl1/work/babel/install/lib/python2.6/site-packages

#NUMBERS=1 #2 4 6 8 12 16 24 32 48 64 96 128 #256 512
NUMBERS=$(shell seq 1 128)
SIDLS=$(patsubst %,out/struct%.sidl, $(NUMBERS))
COMPILES=$(patsubst %,out/client_%/token, $(NUMBERS))

TIMINGS=$(patsubst %,out/client_%/times, $(NUMBERS))

.PHONY: clean all sidls compile timings

all: graph.pdf

graph.pdf: graph.tex out/result.txt
	env TEXINPUTS=~/sw/share/texmf//:$(TEXINPUTS) pdflatex -halt-on-error graph

out/result.txt: 
	$(MAKE) timings
	echo "n" "C" "CXX" "F77" "F90" "F03" "Java" "Python" >out/result.txt
	for f in $(NUMBERS); do \
	  cat out/client_$$f/times >> out/result.txt; \
	done
	@echo "============================================="
	@cat out/result.txt
	#$(MAKE) graph.pdf
	#@cat out/result.txt
	#xpdf graph.pdf

sidls: $(SIDLS)

compile: sidls 
	$(MAKE) $(COMPILES)
timings: compile
	$(MAKE) $(TIMINGS) # execute timing measurements serially

clean:
	rm -rf out graph.pdf

out/%.sidl:
	@env PATH=$(BABELPATH):$(PATH) \
	    PYTHONPATH=$(PYTHONPATH) \
	    python benchgen.py $(patsubst out/struct%.sidl,%,$@)

out/client_%/times:
	@cd $(patsubst %/times,%,$@) && \
	 env PATH=$(BABELPATH):$(PATH) \
	    PYTHONPATH=$(PYTHONPATH) \
	    bash runAll.sh

out/C_%/token: out/struct%.sidl
	env PATH=$(BABELPATH):$(PATH) \
	$(MAKE) -C $(patsubst %/token,%,$@)  all
	touch $@
out/CXX_%/token: out/struct%.sidl
	env PATH=$(BABELPATH):$(PATH) \
	$(MAKE) -C $(patsubst %/token,%,$@)  all
	touch $@
out/F77_%/token: out/struct%.sidl
	env PATH=$(BABELPATH):$(PATH) \
	$(MAKE) -C $(patsubst %/token,%,$@)  all
	touch $@
out/F90_%/token: out/struct%.sidl
	env PATH=$(BABELPATH):$(PATH) \
	$(MAKE) -C $(patsubst %/token,%,$@)  all
	touch $@
out/F03_%/token: out/struct%.sidl
	env PATH=$(BABELPATH):$(PATH) \
	$(MAKE) -C $(patsubst %/token,%,$@)  all
	touch $@
out/Python_%/token: out/struct%.sidl
	env PATH=$(BABELPATH):$(PATH) \
	$(MAKE) -C $(patsubst %/token,%,$@)  all
	touch $@
out/Java_%/token: out/struct%.sidl
	env PATH=$(BABELPATH):$(PATH) \
	$(MAKE) -C $(patsubst %/token,%,$@)  all
	touch $@
out/client_%/token: out/struct%.sidl out/C_%/token out/CXX_%/token out/F77_%/token out/F90_%/token out/F03_%/token out/Python_%/token out/Java_%/token
	env PATH=$(BABELPATH):$(PATH) \
	$(MAKE) -C $(patsubst %/token,%,$@)  all
	touch $@

run:
	env PYTHONPATH=../install/lib/python2.6/site-packages python benchgen.py \
	  n /home/prantl1/work/babel/install/bin/babel
