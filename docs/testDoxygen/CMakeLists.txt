
include_directories(${KDE4_INCLUDES} ${KDE4_INCLUDE_DIR} ${QT_INCLUDES} )


########### install files ###############




#original Makefile.am contents follow:

## This directory is for experimentation with ideas specific to
## how we can use Doxygen to better document the ROSE project.
#
#if DQ_DEVELOPER_TESTS
#
#logo:
##	Copy the logo file to the this directory
#	mkdir -p ROSE_HTML_Reference
##	Copy to the current directory where doxygen will be run so that doxygen 
##	can copy it to the where it will put the web pages (./ROSE_HTML_Reference)
#	cp @top_srcdir@/docs/Rose/compass_rose.gif .
#
## DQ (8/29/2008):
## Added support to build (in the ROSE/docs/Rose directory) the AvailableDocumentation.docs 
## file from the AvailableDocumentation.docs.in (as required by the generated test.cfg in 
## this directory.
#AvailableDocumentation.docs:
#	cd ../Rose; $(MAKE) AvailableDocumentation.docs
#
#docs: logo copyPublications test.cfg AvailableDocumentation.docs
#	doxygen test.cfg
#
## DQ (5/8/2005): Added custon headers and footers for HTML generated documentation
## See use of HTML_HEADER and HTML_FOOTER in test.cfg.in file
## DIST_EXTRA = htmlHeaderFile.html htmlFooterFile.html test.cfg.in
#EXTRA_DIST = htmlHeaderFile.html htmlFooterFile.html test.cfg.in
#
## DQ (1/25/2006): Renamed clean rule since we don't want "make clean" 
## at the top level directory to always remove this documentation.
#cleandocs:
#	rm -rf ROSE_HTML_Reference ROSE_ResearchPapers test.cfg *.ps *.gif
#
## This allows us to test the development of the 
## documentation specific to the publications page.
#copyPublications:
#	mkdir -p ROSE_ResearchPapers
#	cp -r $(top_srcdir)/ROSE_ResearchPapers/*.pdf ROSE_ResearchPapers
#
## This copies the experimental version of the documentation to the
## location where it will permanently reside in the source tree.
#copyDocumentation:
#	cp $(srcdir)/*.docs $(top_srcdir)/src/frontend/SageIII/docs
#
#else
#
#EXTRA_DIST = 
#
#endif
