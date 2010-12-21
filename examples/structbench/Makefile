BABELPATH=/home/prantl1/work/babel/install/bin
PYTHONPATH=/home/prantl1/work/babel/install/lib/python2.6/site-packages

NUMBERS=1 2 3 4 5 6 7 8
SIDLS=$(patsubst %,out/struct%.sidl, $(NUMBERS))
ALL=$(patsubst %,out/C_%/token, $(NUMBERS)) \
    $(patsubst %,out/CXX_%/token, $(NUMBERS)) \
    $(patsubst %,out/F77_%/token, $(NUMBERS)) \
    $(patsubst %,out/F90_%/token, $(NUMBERS)) \
    $(patsubst %,out/F03_%/token, $(NUMBERS)) \
    $(patsubst %,out/Python_%/token, $(NUMBERS)) \
    $(patsubst %,out/Java_%/token, $(NUMBERS)) \
    $(patsubst %,out/client_%/token, $(NUMBERS)) \

all:
	make -j8 sidls # alas babel chokes otherwise
	make -j1 compile

compile: $(ALL)
sidls: $(SIDLS) 

clean:
	rm -rf out

out/%.sidl:
	env PATH=$(BABELPATH):$(PATH) \
	    PYTHONPATH=$(PYTHONPATH) \
	    python benchgen.py $(patsubst out/struct%.sidl,%,$@)

out/C_%/token: out/struct%.sidl
	env PATH=$(BABELPATH):$(PATH) \
	make -C $(patsubst %/token,%,$@) -j8 all
	touch $@
out/CXX_%/token: out/struct%.sidl
	env PATH=$(BABELPATH):$(PATH) \
	make -C $(patsubst %/token,%,$@) -j8 all
	touch $@
out/F77_%/token: out/struct%.sidl
	env PATH=$(BABELPATH):$(PATH) \
	make -C $(patsubst %/token,%,$@) -j8 all
	touch $@
out/F90_%/token: out/struct%.sidl
	env PATH=$(BABELPATH):$(PATH) \
	make -C $(patsubst %/token,%,$@) -j8 all
	touch $@
out/F03_%/token: out/struct%.sidl
	env PATH=$(BABELPATH):$(PATH) \
	make -C $(patsubst %/token,%,$@) -j8 all
	touch $@
out/Python_%/token: out/struct%.sidl
	env PATH=$(BABELPATH):$(PATH) \
	make -C $(patsubst %/token,%,$@) -j8 all
	touch $@
out/Java_%/token: out/struct%.sidl
	env PATH=$(BABELPATH):$(PATH) \
	make -C $(patsubst %/token,%,$@) -j8 all
	touch $@
out/client_%/token: out/struct%.sidl
	env PATH=$(BABELPATH):$(PATH) \
	make -C $(patsubst %/token,%,$@) -j8 all
	touch $@

run:
	env PYTHONPATH=../install/lib/python2.6/site-packages python benchgen.py \
	  n /home/prantl1/work/babel/install/bin/babel
