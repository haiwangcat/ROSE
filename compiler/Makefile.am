subdirs=Scanner

PYTHONPATH=$(top_srcdir)/contrib

python_PYTHON = parser.py

pyexec_LTLIBRARIES = scanner.la
scanner_la_SOURCES = scanner.l
scanner_la_CPPFLAGS = $(PYTHONINC)
scanner_la_LDFLAGS = -avoid-version -module
scanner_la_LIBADD = -lfl


TESTS=../../shams/example-5/DistrArray.sidl \
      ../../babel.git/runtime/sidl/sidl.sidl \
      $(wildcard ../../babel.git/regression/*/*.sidl)

TESTOUT=$(patsubst %.sidl,%.test, $(TESTS))

run2: ../../babel.git/runtime/sidl/sidl.test

%.test: %.sidl braid 
	./braid $<

run: $(TESTOUT)

clean-local:
	rm -rf scanner.c braid *.pyc *.pyo parsetab.py* lextab.py* parser.log parser.out

test: braid

lint:
	pylint sidl.py
	pylint parser.py

# Generate the parser tables
braid: parser.py
	env PYTHONPATH=$(PYTHONPATH) $(PYTHON) $< --compile
	env PYTHONPATH=$(PYTHONPATH) $(PYTHON) $< --compile
	echo "LD_LIBRARY_PATH=$(PYTHON_SHARED_LIBRARY_DIR):LD_LIBRARY_PATH" >$@
	echo "env PYTHONPATH=$(PYTHONPATH) $(PYTHON) -O $< \$$@" >>$@
	chmod u+x $@
