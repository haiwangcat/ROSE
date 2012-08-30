include $(top_srcdir)/config/Makefile.for.ROSE.includes.and.libs

if ROSE_WITH_MPI_C

../src/goalTranslator:
	$(MAKE) -C ../src goalTranslator

GOAL_TRANSLATOR = ../src/goalTranslator

C_TESTCODES_REQUIRED_TO_PASS = \
				mtgTest1.c

CXX_TESTCODES_REQUIRED_TO_PASS =

TESTCODES = \
	$(C_TESTCODES_REQUIRED_TO_PASS) \
	$(CXX_TESTCODES_REQUIRED_TO_PASS)


check-local:
	@echo "Test for MPI to GOAL translator"
	@cp $(srcdir)/$(TESTCODES:=) $(TESTCODES:=)
	$(GOAL_TRANSLATOR) -c -I. $(ROSE_WITH_MPI_CFLAGS) $(TESTCODES)

endif

clean-local:
	rm -f $(TESTCODES)
