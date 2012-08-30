include $(top_srcdir)/config/Makefile.for.ROSE.includes.and.libs

if ROSE_WITH_MPI_C

bin_PROGRAMS = goalTranslator

INCLUDES = \
	$(ROSE_INCLUDES)

goalTranslator_SOURCES = \
			main.cpp

goalTranslator_LDADD = \
		 	$(ROSE_LIBS)

endif

clean-local: