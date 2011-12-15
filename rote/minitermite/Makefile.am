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
include testsuite/Makefile.include

.PHONY: doc
doc:
	@echo "  GEN [doxygen documentation]"
	@($(DOXYGEN) >/dev/null && $(MAKE) MAKEFLAGS=-j1 -C doc/latex >/dev/null) \
        || echo "Doxygen not found; SKIPPING"
