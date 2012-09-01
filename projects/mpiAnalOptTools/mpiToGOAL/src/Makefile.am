include $(top_srcdir)/config/Makefile.for.ROSE.includes.and.libs

if ROSE_WITH_MPI_C

noinst_LTLIBRARIES = libMPItoGOAL.la

bin_PROGRAMS = goalTranslator

INCLUDES = \
	-I .\
	$(ROSE_INCLUDES)

libMPItoGOAL_la_SOURCES = \
			mtgTranslatorCommon.cpp

goalTranslator_SOURCES = \
			main.cpp

goalTranslator_LDADD = \
			libMPItoGOAL.la \
		 	$(ROSE_LIBS)

endif

clean-local: