include $(top_srcdir)/config/Makefile.for.ROSE.includes.and.libs

C_TESTCODES_REQUIRED_TO_PASS = \
				mtgTest1.c \
				mtgTest2.c

CXX_TESTCODES_REQUIRED_TO_PASS =

ALL_TESTCODES = \
		$(C_TESTCODES_REQUIRED_TO_PASS) \
		$(CXX_TESTCODES_REQUIRED_TO_PASS)

if ROSE_WITH_MPI_C

C_FILES = ${C_TESTCODES_REQUIRED_TO_PASS:.c=.c-o}

../src/goalTranslator:
	$(MAKE) -C ../src goalTranslator

GOAL_TRANSLATOR = ../src/goalTranslator

$(C_FILES): $(GOAL_TRANSLATOR) $(srcdir)/$(@:.c-o:.c)
	cp $(srcdir)/$(@:.c-o=.c) $(@:.c-o=.temp.c)
	$(GOAL_TRANSLATOR) -c -I. $(ROSE_WITH_MPI_CFLAGS) $(@:.c-o=.temp.c) && touch $@

check-c: $(C_FILES)

check-local: check-c

endif

EXTRA_DIST = $(ALL_TESTCODES)

clean-local:
	rm -f $(C_FILES)
	rm -f $(C_FILES:.c-o=.temp.c)
