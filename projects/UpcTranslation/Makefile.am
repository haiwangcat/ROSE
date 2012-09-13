include $(top_srcdir)/config/Makefile.for.ROSE.includes.and.libs

# . is necessary to ensure building the translator before building the tests
SUBDIRS = . tests

INCLUDES = $(ROSE_INCLUDES) 

bin_PROGRAMS = roseupcc
roseupcc_SOURCES = upc_translation.C roseupcc.C

LDADD = $(LIBS_WITH_RPATH) $(ROSE_LIBS) 

EXTRA_DIST = \
	README \
	upc_translation.h \
	include/upc_collective.h \
	include/upc.h \
	include/upc_relaxed.h \
	include/upcr.h \
	include/upcr_proxy.h \
	include/upc_strict.h

clean-local:
	rm -rf upcTranslator a.out *.o rose_* *.dot *.tld
