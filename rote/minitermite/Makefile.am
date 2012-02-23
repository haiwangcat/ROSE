## Process this file with automake to create Makefile.in.

ACLOCAL_AMFLAGS = -I m4

SUBDIRS= 
DIST_SUBDIRS = 
DISTCHECK_CONFIGURE_FLAGS=--with-rosedir=$(ROSEDIR) --with-boostdir=$(BOOSTDIR) --with-boost-compiler-string=$(BOOST_COMPILER_STRING) CXX=$(CXX)

if !WITH_SWI_PROLOG
DISTCHECK_CONFIGURE_FLAGS += --without-swi-prolog
endif

.PHONY: clang

clang: $(top_srcdir)/src/termite/clang/clang-termite.patch $(top_builddir)/clang/build/Makefile
	$(MAKE) -C $(top_builddir)/clang/build
	$(MAKE) install -C $(top_builddir)/clang/build

$(top_builddir)/clang/build/Makefile:
	cd $(top_builddir)/src/termite/clang && sh BUILD-clang.sh

EXTRA_DIST= README COPYING

include src/Makefile.include
include regression/Makefile.include

# ############################################
# Documentation
# ############################################

.PHONY: doc
doc:
if ENABLE_DOCUMENTATION
	@echo "  GEN [doxygen documentation]"
	@($(DOXYGEN) && $(MAKE) MAKEFLAGS=-j1 -C doc/latex)
else
        @echo "**WARNING: Doxygen was not found by configure; SKIPPING"
endif 

doc/html/index.html:
	$(MAKE) doc

#info_TEXINFOS = doc/src2term.texi doc/term2src.texi
dist_man_MANS = $(srcdir)/doc/src2term.1 $(srcdir)/doc/term2src.1

# We are distributing the compiled manpage so we don't depend on rst2man
# Insert the output of xxx --help into the MAN page.
EXTRA_DIST += doc/man_header.txt
$(dist_man_MANS): $(srcdir)/doc/%.1: $(top_builddir)/src/% doc/man_header.txt README Makefile
	$(AM_V_GEN)
	@cat $(srcdir)/doc/man_header.txt |sed -e 's/@DATE@/$(shell date +%Y-%m-%d)/g' \
                     -e 's/\@VERSION\@/$(PACKAGE_VERSION)/g' >$<.txt
	@$< --help \
	 | sed -e 's|Usage: [^ ]*|Usage: $(patsubst $(srcdir)/doc/%.1, %, $@)|' \
	       -e 's/Usage: *\(.*\)/\nSYNOPSIS\n========\n\n\1\n\nDESCRIPTION\n===========\n\n/' \
               -e 's/pos/OPTIONS\n=======\n\npos/' >>$<.txt
	@echo >>$<.txt
	@tail -n +3 $(srcdir)/README >>$<.txt
	@if test -w $@; then \
             if which rst2man >/dev/null; then \
                true "We need to trick rst2man to recognize long options as options, too"; \
		sed 's/^  --/  -, --/g' $<.txt >$<.tmp; \
		rst2man $<.tmp $@.tmp; \
		sed 's/\\-, \\-/\\-/g' $@.tmp >$@; \
                rm -f $<.tmp $@.tmp; \
             else echo "**WARNING rst2man not installed, did not update $@"; \
             fi \
         else echo "**WARNING $@ is not writable, did not update. (This is OK during distcheck)"; \
         fi
	@rm -f $<.txt

clean-local:
	rm -rf doc/html
	rm -rf doc/latex
	rm -rf doc/man
	rm -f testsuite/*-[13].term testsuite/*-[24].[cf]*

