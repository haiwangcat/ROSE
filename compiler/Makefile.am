PYTHONPATH=$(top_srcdir)/contrib

# list all Python source files that also vontain unit tests
PYTHON_SOURCES = patmat.py sidl.py codegen.py ir.py
python_PYTHON = $(PYTHON_SOURCES) parser.py
noinst_PYTHON=sidl_token.py

bin_PROGRAMS = braid
braid_SOURCES =

pyexec_LTLIBRARIES = scanner.la
scanner_la_SOURCES = scanner.l
scanner_la_CPPFLAGS = $(PYTHONINC)
scanner_la_LDFLAGS = -avoid-version -module
scanner_la_LIBADD = -lfl

SIDL_TESTS= \
	../regression/parser/args.sidl \
	../regression/parser/ArrayTest.sidl \
	../regression/parser/cca-0.6.3.sidl \
	../regression/parser/cca-0.8.2.sidl \
	../regression/parser/cca.sidl \
	../regression/parser/clife.sidl \
	../regression/parser/construct.sidl \
	../regression/parser/cxxlife.sidl \
	../regression/parser/decaf.sidl \
	../regression/parser/enums.sidl \
	../regression/parser/ExceptionTest.sidl \
	../regression/parser/f90life.sidl \
	../regression/parser/hello-client.sidl \
	../regression/parser/hello-server.sidl \
	../regression/parser/hello.sidl \
	../regression/parser/Hello.sidl \
	../regression/parser/hooks.sidl \
	../regression/parser/inherit.sidl \
	../regression/parser/life.sidl \
	../regression/parser/objarg.sidl \
	../regression/parser/ordering.sidl \
	../regression/parser/output.sidl \
	../regression/parser/Overload.sidl \
	../regression/parser/pythonlife.sidl \
	../regression/parser/sidl.sidl \
	../regression/parser/sidlx.sidl \
	../regression/parser/sort.sidl \
	../regression/parser/strings.sidl \
	../regression/parser/strop.sidl \
	../regression/parser/struct.sidl \
	../regression/parser/vect.sidl \
	../regression/parser/wave2d_cxx_internal.sidl \
	../regression/parser/wave2d_cxx.sidl \
	../regression/parser/wave2d_f90.sidl \
	../regression/parser/wave2d.sidl \
	../regression/parser/wrapper.sidl

## SIDL_TESTS=$(patsubst %.sidl,../regression/parser/%.sidl, $(SIDL_NAMES))

#UNIT_TOKENS = $(patsubst %.py,%.unit, $(python_PYTHON))
# Most of the Python files contain doctest tests
# see
# http://www.gnu.org/software/automake/manual/automake.html#Simple-Tests-using-parallel_002dtests
TESTS = $(PYTHON_SOURCES) $(SIDL_TESTS)
TEST_EXTENSIONS = .py .sidl
PY_LOG_COMPILER = env PYTHONPATH=$(PYTHONPATH) $(PYTHON)
AM_PY_LOG_FLAGS = -m doctest
SIDL_LOG_COMPILER = ./braid
AM_SIDL_LOG_FLAGS =


$(builddir)/%.unit: $(srcdir)/%.py scanner.la
	env PYTHONPATH=$(PYTHONPATH) $(PYTHON) -m doctest $<

$(builddir)/%.success: $(srcdir)/%.sidl braid
	./braid $<

clean-local:
	rm -rf scanner.c braid *.pyc *.pyo parsetab.py* lextab.py* parser.log parser.out
	rm -rf $(SIDL_TOKENS) $(UNIT_TOKENS)

# Generate the parser tables
braid: parser.py scanner.la
	env PYTHONPATH=$(PYTHONPATH) $(PYTHON) $< --compile
	env PYTHONPATH=$(PYTHONPATH) $(PYTHON) $< --compile
	echo "LD_LIBRARY_PATH=$(PYTHON_SHARED_LIBRARY_DIR):LD_LIBRARY_PATH" >$@
	echo "env PYTHONPATH=$(PYTHONPATH) $(PYTHON) -O $< \$$@" >>$@
	chmod u+x $@
