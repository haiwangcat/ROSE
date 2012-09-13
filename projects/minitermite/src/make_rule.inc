## meant for inclusion by the toplevel -*- makefile-automake -*-
BUILT_SOURCES =	
INCLUDES = $(ROSE_INCLUDES) \
           -I$(srcdir)/src/minitermite \
           -I$(BUILDDIR)/src/minitermite \
	   -I$(BUILDDIR)/src


nobase_include_HEADERS = \
	src/minitermite/AstJanitor.h \
	src/minitermite/minitermite.h \
	src/minitermite/TermPrinter.h \
	src/minitermite/TermToRose.h \
	src/minitermite/RoseToTerm.h \
	src/minitermite/RoseEnums.h \
	src/minitermite/term.h++ \
	src/minitermite/stl-term.h++ \
	src/minitermite/swipl-term.h++ \
	src/minitermite/stratego-term.h++

nodist_include_HEADERS = src/minitermite/RoseEnumNames.h 

ROSELDFLAGS=$(LIBS_WITH_RPATH) $(ROSE_LIBS)

CLEANFILES = termpretty.c++

bin_PROGRAMS = src/termpretty src/src2term src/term2src
noinst_bindir = $(BUILDDIR)
noinst_PROGRAMS = src/find-enums

if ROSE_HAVE_SWI_PROLOG
bin_SCRIPTS += src/termite_lint src/cime3_signatures src/stratego-signatures

BUILT_SOURCES += $(BUILDDIR)/PP_termite_spec.pl
CLEANFILES += $(BUILDDIR)/PP_termite_spec.pl \
              src/termite_lint src/cime3_signatures src/stratego-signatures

$(BUILDDIR)/PP_termite_spec.pl: src/termite/termite_spec.pl Makefile
if ROSE_HAVE_MINITERMITE_ANALYSIS_RESULTS
	cp $< $@
else
	cat $< | sed 's/analysis_info, //g' > $@
endif

src/termite_lint: $(srcdir)/src/term_lint_main.pl $(BUILDDIR)/PP_termite_spec.pl src/termite/termlint.pl
	$(AM_V_GEN) TERMITE_LIB=$(srcdir)/src/termite \
	$(SWI_PLC) -o $@ -c $<

src/cime3_signatures: $(srcdir)/src/cime3_signatures.pl $(BUILDDIR)/PP_termite_spec.pl
	$(AM_V_GEN) TERMITE_LIB=$(srcdir)/src/termite \
	$(SWI_PLC) -o $@ -c $<

src/stratego-signatures: $(srcdir)/src/stratego-signatures.pl $(BUILDDIR)/PP_termite_spec.pl
	$(AM_V_GEN) TERMITE_LIB=$(srcdir)/src/termite \
	$(SWI_PLC) -o $@ -c $<

endif

AM_YFLAGS = -d

lib_LTLIBRARIES = libtermsupport.la

libtermsupport_la_SOURCES = \
	src/RoseToTerm.cc \
	src/TermToRose.cc \
	src/PrologTerm.cc \
	src/RoseEnums.cc \
	src/minitermite/AstJanitor.h \
	src/minitermite/TermPrinter.h \
	src/minitermite/TermToRose.h \
	src/minitermite/RoseToTerm.h \
	src/minitermite/RoseEnums.h \
	src/minitermite/term.h++ \
	src/minitermite/stl-term.h++ \
	src/minitermite/swipl-term.h++ \
	src/minitermite/stratego-term.h++


if ROSE_HAVE_SWI_PROLOG # ---------------------------------------------------

INCLUDES += -I$(SWI_PROLOG_INCLUDE_DIR)
ROSELDFLAGS += $(SWI_PROLOG_LIBS) $(SWI_PROLOG_LDADD)
nobase_dist_data_DATA = \
  src/termite/astproperties.pl  src/termite/loops.pl \
  src/termite/asttransform.pl   src/termite/utils.pl \
  src/termite/astwalk.pl        src/termite/callgraph.pl \
  src/termite/termlint.pl       src/termite/termite_spec.pl \
  src/termite/markers.pl

endif # -----------------------------------------------------------------

BUILT_SOURCES += src/minitermite/RoseEnumNames.h
src/minitermite/RoseEnumNames.h : enum-stamp
# cf. http://www.gnu.org/software/automake/manual/automake.html#Multiple-Outputs
# Recover from the removal of $@
	@if test -f $@; then :; else \
	  trap 'rm -rf enum-lock enum-stamp' 1 2 13 15; \
true      "mkdir is a portable test-and-set"; \
	  if mkdir enum-lock 2>/dev/null; then \
true        "This code is being executed by the first process."; \
	    rm -f enum-stamp; \
	    $(MAKE) $(AM_MAKEFLAGS) enum-stamp; \
	    result=$$?; rm -rf enum-lock; exit $$result; \
	  else \
true        "This code is being executed by the follower processes."; \
true        "Wait until the first process is done."; \
	    while test -d enum-lock; do sleep 1; done; \
true        "Succeed if and only if the first process succeeded." ; \
	    test -f enum-stamp; \
	  fi; \
	fi

enum-stamp: src/find-enums
	@rm -f enum-temp
	@touch enum-temp
	@echo "#include <rosePublicConfig.h>" >RoseEnumNames.cc
if ROSE_BUILD_OS_IS_OSX
	@echo "#define ROSE_PROCESSSUPPORT_H" >>RoseEnumNames.cc
	@echo "#define ROSE_ASSERT(X) "       >>RoseEnumNames.cc
endif
	@echo "#include <sage3basic.h>"       >>RoseEnumNames.cc
	$(AM_V_GEN) $< --edg:no_warnings  -O0 -DROSE_SKIP_COMPILATION_OF_WAVE \
	   -I$(top_builddir) $(ROSE_INCLUDES) \
           -c RoseEnumNames.cc > __RoseEnumNames.h
	@mkdir -p src/minitermite
	@mv __RoseEnumNames.h src/minitermite/RoseEnumNames.h
	@mv -f enum-temp $@

CLEANFILES += RoseEnumNames.cc src/minitermite/RoseEnumNames.h enum-stamp


BUILT_SOURCES += src/termparser.tab.h++

nodist_libtermsupport_la_SOURCES = $(BUILT_SOURCES)
CLEANFILES += termparser.c++ termparser.h termlexer.c++ \
              src/termparser.tab.h++

libtermsupport_la_SOURCES += src/termparser.y++ src/termlexer.l++

src/termparser.tab.h++: $(srcdir)/src/termparser.y++ Makefile
	$(YACC) -d $(srcdir)/src/termparser.y++ && \
	rm y.tab.c && \
	mv y.tab.h $@

src_termpretty_SOURCES = src/termpretty.l++
src_termpretty_LDFLAGS = $(ROSELDFLAGS)
src_termpretty_LDADD = -lboost_program_options

src_find_enums_SOURCES = src/find-enums.cc 
src_find_enums_LDADD = $(LIBS_WITH_RPATH) $(ROSE_LIBS)

src_src2term_SOURCES = src/src2term.cc 
src_term2src_SOURCES = src/term2src.cc
nodist_src_src2term_SOURCES = src/minitermite/RoseEnumNames.h
nodist_src_term2src_SOURCES = src/minitermite/RoseEnumNames.h

src_term2src_LDADD = libtermsupport.la -lrose 
src_src2term_LDADD = libtermsupport.la -lrose

src_term2src_LDFLAGS = $(ROSELDFLAGS)
src_src2term_LDFLAGS = $(ROSELDFLAGS)

EXTRA_DIST += \
  src/term_lint_main.pl \
  src/cime3_signatures.pl \
  src/stratego-signatures.pl \
  src/clang/README src/clang/INSTALL src/clang/clang-termite.patch

