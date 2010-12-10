PYTHONPATH=$(top_srcdir)/contrib

python_PYTHON = parser.py patmat.py sidl.py codegen.py ir.py
bin_PROGRAMS = braid

pyexec_LTLIBRARIES = scanner.la
scanner_la_SOURCES = scanner.l
scanner_la_CPPFLAGS = $(PYTHONINC)
scanner_la_LDFLAGS = -avoid-version -module
scanner_la_LIBADD = -lfl


SIDL_TESTS=args.sidl ArrayTest.sidl cca-0.6.3.sidl cca-0.8.2.sidl \
           cca.sidl clife.sidl construct.sidl cxxlife.sidl decaf.sidl \
           enums.sidl ExceptionTest.sidl f90life.sidl hello-client.sidl \
           hello-server.sidl hello.sidl Hello.sidl hooks.sidl inherit.sidl \
           life.sidl objarg.sidl ordering.sidl output.sidl Overload.sidl \
           pythonlife.sidl sidl.sidl sidlx.sidl sort.sidl strings.sidl \
           strop.sidl struct.sidl vect.sidl wave2d_cxx_internal.sidl \
           wave2d_cxx.sidl wave2d_f90.sidl wave2d.sidl wrapper.sidl

SIDL_TOKENS=$(patsubst %.sidl,$(top_srcdir)/regression/parser/%.success, $(SIDL_TESTS))

# Most of the Python files contain doctest tests
UNIT_TOKENS = $(patsubst %.py,%.unit, $(python_PYTHON))

TESTS = $(UNIT_TOKENS) \
	$(SIDL_TOKENS)

%.unit: %.py
	$(PYTHON) $<
	touch $@

%.success: %.sidl braid
	./braid $<
	touch $@

run: $(TESTS)

clean-local:
	rm -rf scanner.c braid *.pyc *.pyo parsetab.py* lextab.py* parser.log parser.out
	rm -rf $(SIDL_TOKENS) $(UNIT_TOKENS)

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
