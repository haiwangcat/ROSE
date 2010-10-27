subdirs=Scanner
dnl babel2_PYTHON = tree.py leave.py

# Run the program through M4
#%.preprocessed.py: %.py
#	m4 -P <$< >$@

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

%.test: %.sidl babel2 
	./babel2 $<

run: $(TESTOUT)

clean-local:
	rm -rf scanner.c babel2 *.pyc *.pyo parsetab.py* lextab.py* parser.log parser.out

test: babel2

lint:
	pylint sidl.py
	pylint parser.py

# Generate the parser tables
babel2: parser.py
	python $< --compile
	python $< --compile
	echo "LD_LIBRARY_PATH=$(PYTHON_SHARED_LIBRARY_DIR):LD_LIBRARY_PATH" >$@
	echo "$(PYTHON) -O $< \$$@" >>$@
	chmod u+x $@
