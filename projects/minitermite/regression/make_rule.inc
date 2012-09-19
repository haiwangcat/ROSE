# -*- makefile-automake -*-

# parallel make: the first two are big, so run them first
TERMITE_TESTS = \
    regression/mrtc/success/statemate.c \
    regression/mrtc/success/nsichneu.c \
    regression/base/ab.c \
    regression/base/asm.c \
    regression/base/bigger.c \
    regression/base/blocks.c \
    regression/base/bound_t.c \
    regression/base/bsort.c \
    regression/base/cconstants.c \
    regression/base/classes.cxx \
    regression/base/classes_and_returns.cxx \
    regression/base/deepreturn.c \
    regression/base/default_args.cxx \
    regression/base/demo1.cxx \
    regression/base/demo2.cxx \
    regression/base/destructor2.cxx \
    regression/base/for_return1.c \
    regression/base/forinit.c \
    regression/base/hello.c \
    regression/base/initializers/initializer1.cxx \
    regression/base/initializers/initializer2.cxx \
    regression/base/initializers/initializer3.cxx \
    regression/base/initializers/initializer4.cxx \
    regression/base/intval.c \
    regression/base/jump.c \
    regression/base/logical.c \
    regression/base/manyargs.c \
    regression/base/minimal.c \
    regression/base/nested.c \
    regression/base/overload.cxx \
    regression/base/rdtest1.cxx \
    regression/base/rdtest2.cxx \
    regression/base/rdtest3.cxx \
    regression/base/simpleif.c \
    regression/base/small.c \
    regression/base/test1.cxx \
    regression/base/test5.cxx \
    regression/base/test6.cxx \
    regression/base/tests/costa/example1.cxx \
    regression/base/tests/costa/example2.cxx \
    regression/base/tests/costa/example3.cxx \
    regression/base/tests/rdtest0.cxx \
    regression/base/tests/rdtest1.cxx \
    regression/base/tests/rdtest10.cxx \
    regression/base/tests/rdtest10p1.cxx \
    regression/base/tests/rdtest10p2.cxx \
    regression/base/tests/rdtest10p3.cxx \
    regression/base/tests/rdtest11.cxx \
    regression/base/tests/rdtest12.cxx \
    regression/base/tests/rdtest13.cxx \
    regression/base/tests/rdtest14.cxx \
    regression/base/tests/rdtest15.cxx \
    regression/base/tests/rdtest2.cxx \
    regression/base/tests/rdtest3.cxx \
    regression/base/tests/rdtest4.cxx \
    regression/base/tests/rdtest4b.cxx \
    regression/base/tests/rdtest5.cxx \
    regression/base/tests/rdtest6.cxx \
    regression/base/tests/rdtest7.cxx \
    regression/base/tests/rdtest8a.cxx \
    regression/base/tests/rdtest8b.cxx \
    regression/base/tests/rdtest8c.cxx \
    regression/base/tests/rdtest9a.cxx \
    regression/base/tests/rdtest9a_c89.c \
    regression/base/tests/rdtest9b.cxx \
    regression/base/typedefs.cxx \
    regression/base/verysmall.c \
    regression/base/virtual.cxx \
    regression/base/while_call1.c \
    regression/mrtc/success/adpcm.c \
    regression/mrtc/success/bs.c \
    regression/mrtc/success/bsort100.c \
    regression/mrtc/success/cnt.c \
    regression/mrtc/success/compress.c \
    regression/mrtc/success/cover.c \
    regression/mrtc/success/crc.c \
    regression/mrtc/success/duff.c \
    regression/mrtc/success/edn.c \
    regression/mrtc/success/expint.c \
    regression/mrtc/success/fac.c \
    regression/mrtc/success/fdct.c \
    regression/mrtc/success/fft1.c \
    regression/mrtc/success/fibcall.c \
    regression/mrtc/success/fir.c \
    regression/mrtc/success/insertsort.c \
    regression/mrtc/success/janne_complex.c \
    regression/mrtc/success/jfdctint.c \
    regression/mrtc/success/lcdnum.c \
    regression/mrtc/success/lms.c \
    regression/mrtc/success/loop3.c \
    regression/mrtc/success/ludcmp.c \
    regression/mrtc/success/matmult.c \
    regression/mrtc/success/minmax.c \
    regression/mrtc/success/minver.c \
    regression/mrtc/success/ndes.c \
    regression/mrtc/success/ns.c \
    regression/mrtc/success/qsort-exam.c \
    regression/mrtc/success/qurt.c \
    regression/mrtc/success/recursion.c \
    regression/mrtc/success/select.c \
    regression/mrtc/success/sqrt.c \
    regression/shape/success/artificalsum.cxx \
    regression/shape/success/nnh_xnil.cxx \
    regression/shape/success/nnh_xselnil.cxx \
    regression/shape/success/nnh_xsely.cxx \
    regression/shape/success/nnh_xy.cxx \
    regression/shape/success/nnh_xysel2.cxx \
    regression/shape/success/nnh_xysel3.cxx \
    regression/shape/success/nnh_xysel3shared.cxx \
    regression/shape/success/pathjoin.cxx

TERMITE_FORTRAN_TESTS = \
    regression/fortran/trivial.f90 \
    regression/fortran/simple_ccsd_t2.f \
    regression/fortran/complex.f03 \
    regression/fortran/icsd.f \
    regression/fortran/icsd_t2.f \
    regression/fortran/funCall.F \
    regression/fortran/precision.f03 \
    regression/fortran/rose_dim.F \
    regression/fortran/hello77.f

BROKEN_TESTS = \
    regression/base/classes2.cxx \
    regression/base/classes3.cxx \
    regression/base/destructor_simple.cxx \
    regression/base/destructor.cxx \
    regression/base/namespaces.cxx \
    regression/base/tests/rdtest10all.cxx \
    regression/mrtc/failure/des.c \
    regression/shape/success/srw98_listreverse.cxx

# Known Failures
EXTRA_DIST += $(TERMITE_TESTS) $(BROKEN_TESTS) \
	regression/shape/success/README \
	regression/README \
	regression/shape/success/srw98_data.h \
	regression/mrtc/success/PolicyControl.txt \
	regression/mrtc/failure/PolicyControl.txt

# gfortran 4.0.x will not be able to pass the F77 tests
if ROSE_BUILD_FORTRAN_LANGUAGE_SUPPORT 
if !ROSE_USING_GFORTRAN_VERSION_4_0
TERMITE_TESTS += $(TERMITE_FORTRAN_TESTS)
else
EXTRA_DIST += $(TERMITE_FORTRAN_TESTS)
endif
else
EXTRA_DIST += $(TERMITE_FORTRAN_TESTS)
endif

TESTS = $(TERMITE_TESTS) # $(BROKEN_TESTS)

bin_SCRIPTS += regression/linewrap.awk regression/abs_path.perl
EXTRA_DIST  += regression/linewrap.awk regression/abs_path.perl

noinst_SCRIPTS = \
  regression/c_driver.sh \
  regression/cxx_driver.sh \
  regression/f90_driver.sh \
  regression/f03_driver.sh \
  regression/f77_driver.sh \
  regression/serial_driver.sh

TEST_EXTENSIONS = .cxx .c .f90 .f03 .f .F
C_LOG_COMPILER = sh $(BUILDDIR)/regression/c_driver.sh
AM_C_LOG_FLAGS = 
CXX_LOG_COMPILER = sh $(BUILDDIR)/regression/cxx_driver.sh
AM_CXX_LOG_FLAGS =
F90_LOG_COMPILER = sh $(BUILDDIR)/regression/f90_driver.sh
AM_F90_LOG_FLAGS = 
F03_LOG_COMPILER = sh $(BUILDDIR)/regression/f03_driver.sh
AM_F03_LOG_FLAGS = 
F_LOG_COMPILER = sh $(BUILDDIR)/regression/f77_driver.sh
AM_F_LOG_FLAGS = 

# ------------------------------------------------------------------------
# BEGIN Backwards-compatible serial-tests
# Please remove this as soon as ROSE is upgraded to automake 1.10b or later!
# ------------------------------------------------------------------------
TESTS_ENVIRONMENT=sh $(BUILDDIR)/regression/serial_driver.sh
regression/serial_driver.sh: Makefile
	$(AM_V_GEN)
	@mkdir -p $(BUILDDIR)/regression
	@echo '#!/bin/sh' > $@
	@echo 'ext=`echo "$$1"|awk -F . '"'"'{print $$NF}'"'"'` # get extension' >> $@
	@echo 'case $$ext in' >> $@
	@echo '    c)	exec sh	$(BUILDDIR)/regression/c_driver.sh $$1 ;;' >> $@
	@echo '	   cxx) exec sh $(BUILDDIR)/regression/cxx_driver.sh $$1 ;;' >> $@
	@echo '	   f90) exec sh $(BUILDDIR)/regression/f90_driver.sh $$1 ;;' >> $@
	@echo '	   f03) exec sh $(BUILDDIR)/regression/f03_driver.sh $$1 ;;' >> $@
	@echo '	   f)	exec sh	$(BUILDDIR)/regression/f77_driver.sh $$1 ;;' >> $@
	@echo '	   F)	exec sh	$(BUILDDIR)/regression/f77_driver.sh $$1 ;;' >> $@
	@echo '    *)    exit 1 ;;' >> $@
	@echo 'esac' >> $@
# ------------------------------------------------------------------------
# END Backwards-compatible serial-tests
# Please remove this as soon as ROSE is upgraded to automake 1.10b or later!
# ------------------------------------------------------------------------


CLEANFILES += $(noinst_SCRIPTS)

testdir=check-tests

# The tests are split into separate targets to facilitate a
# parallelized run of the regression (make -j #N installcheck)
ABS_PATH=$(PERL) $(srcdir)/regression/abs_path.perl
SRC2TERM=../$(BUILDDIR)/src/src2term
TERM2SRC=../$(BUILDDIR)/src/term2src
TERMLINT=../$(BUILDDIR)/src/termite_lint

regression/c_driver.sh: Makefile
	$(AM_V_GEN)
	@mkdir -p $(BUILDDIR)/regression
	@echo '#!/bin/sh' > $@
	@echo 'arg=`$(ABS_PATH) $$1` # get absolute filename' >> $@
	@echo 'include=`dirname $$arg`' >> $@
	@echo 'cd $(BUILDDIR)/regression' >> $@
	@echo 'echo "TERMITE: performing a translation circle of" $$arg' >> $@
	@echo 'set -x' >> $@
	@echo 'NAME=`basename $$1 .c`' >> $@
	@echo '$(SRC2TERM) -I$$include $$arg -o $${NAME}-1.term || exit 1' >> $@
	@echo '$(TERM2SRC) $${NAME}-1.term -o $${NAME}-2.c || exit 2' >> $@
	@echo '$(SRC2TERM) --stl-engine -I$$include $${NAME}-2.c -o $${NAME}-3.term || exit 3' >> $@
	@echo '$(TERM2SRC) --stl-engine  $${NAME}-3.term -o $${NAME}-4.c || exit 4' >>$@
	@echo '$(SRC2TERM) --stratego -I$$include $${NAME}-4.c -o $${NAME}-5.term || exit 5' >> $@
	@echo '$(TERM2SRC) --stratego  $${NAME}-5.term -o $${NAME}-6.c || exit 6' >>$@
if ROSE_HAVE_SWI_PROLOG
	@echo '$(TERMLINT) $${NAME}-1.term || exit 7' >> $@
	@echo '$(TERMLINT) $${NAME}-3.term || exit 8' >> $@
endif

regression/cxx_driver.sh: Makefile
	$(AM_V_GEN)
	@mkdir -p $(BUILDDIR)/regression
	@echo '#!/bin/sh' > $@
	@echo 'arg=`$(ABS_PATH) $$1` # get absolute filename' >> $@
	@echo 'include=`dirname $$arg`' >> $@
	@echo 'cd $(BUILDDIR)/regression' >> $@
	@echo 'echo "TERMITE: performing a translation circle of" $$arg' >> $@
	@echo 'set -x' >> $@
	@echo 'NAME=`basename $$arg .cxx`' >> $@
	@echo '$(SRC2TERM) -I$$include $$arg -o $${NAME}-1.term || exit 1' >> $@
	@echo '$(TERM2SRC) $${NAME}-1.term -o $${NAME}-2.cxx || exit 2' >> $@
	@echo '$(SRC2TERM) --stl-engine -I$$include $${NAME}-2.cxx -o $${NAME}-3.term || exit 3' >> $@
	@echo '$(TERM2SRC) --stl-engine  $${NAME}-3.term -o $${NAME}-4.cxx || exit 4' >>$@
	@echo '$(SRC2TERM) --stratego -I$$include $${NAME}-4.cxx -o $${NAME}-5.term || exit 5' >> $@
	@echo '$(TERM2SRC) --stratego  $${NAME}-5.term -o $${NAME}-6.cxx || exit 6' >>$@
if ROSE_HAVE_SWI_PROLOG
	@echo '$(TERMLINT) $${NAME}-1.term || exit 7' >> $@
	@echo '$(TERMLINT) $${NAME}-3.term || exit 8' >> $@
endif

regression/f90_driver.sh: Makefile
	$(AM_V_GEN)
	@mkdir -p $(BUILDDIR)/regression
	@echo '#!/bin/sh' > $@
	@echo 'arg=`$(ABS_PATH) $$1` # get absolute filename' >> $@
	@echo 'include=`dirname $$arg`' >> $@
	@echo 'cd $(BUILDDIR)/regression' >> $@
	@echo 'echo "TERMITE: performing a translation circle of" $$arg' >> $@
	@echo 'set -x' >> $@
	@echo 'NAME=`basename $$arg .f90`' >> $@
	@echo '$(SRC2TERM) -I$$include $$arg -o $${NAME}-1.term || exit 1' >> $@
	@echo '$(TERM2SRC) $${NAME}-1.term -o $${NAME}-2.f90 || exit 2' >> $@
	@echo '$(SRC2TERM) --stl-engine -I$$include $${NAME}-2.f90 -o $${NAME}-3.term || exit 3' >> $@
	@echo '$(TERM2SRC) --stl-engine  $${NAME}-3.term -o $${NAME}-4.f90 || exit 4' >>$@
	@echo '$(SRC2TERM) --stratego -I$$include $${NAME}-4.f90 -o $${NAME}-5.term || exit 5' >> $@
	@echo '$(TERM2SRC) --stratego  $${NAME}-5.term -o $${NAME}-6.f90 || exit 6' >>$@
if ROSE_HAVE_SWI_PROLOG
	@echo '$(TERMLINT) $${NAME}-1.term || exit 7' >> $@
	@echo '$(TERMLINT) $${NAME}-3.term || exit 8' >> $@
endif

# disable gfortran-based syntax checking until ROSE can compile with gfortran >= 4.7
# a configure test would be cleaner, though
F03FLAGS=-rose:skip_syntax_check

regression/f03_driver.sh: Makefile
	$(AM_V_GEN)
	@mkdir -p $(BUILDDIR)/regression
	@echo '#!/bin/sh' > $@
	@echo 'arg=`$(ABS_PATH) $$1` # get absolute filename' >> $@
	@echo 'include=`dirname $$arg`' >> $@
	@echo 'cd $(BUILDDIR)/regression' >> $@
	@echo 'echo "TERMITE: performing a translation circle of" $$arg' >> $@
	@echo 'set -x' >> $@
	@echo 'NAME=`basename $$arg .f03`' >> $@
	@echo '$(SRC2TERM) $(F03FLAGS) -I$$include $$arg -o $${NAME}-1.term || exit 1' >> $@
	@echo '$(TERM2SRC) $${NAME}-1.term -o $${NAME}-2.f03 || exit 2' >> $@
	@echo '$(SRC2TERM) --stl-engine $(F03FLAGS) -I$$include $${NAME}-2.f03 -o $${NAME}-3.term || exit 3' >> $@
	@echo '$(TERM2SRC) --stl-engine  $${NAME}-3.term -o $${NAME}-4.f03 || exit 4' >>$@
	@echo '$(SRC2TERM) --stratego $(F03FLAGS) -I$$include $${NAME}-4.f03 -o $${NAME}-5.term || exit 5' >> $@
	@echo '$(TERM2SRC) --stratego  $${NAME}-5.term -o $${NAME}-6.f03 || exit 6' >>$@
if ROSE_HAVE_SWI_PROLOG
	@echo '$(TERMLINT) $${NAME}-1.term || exit 7' >> $@
	@echo '$(TERMLINT) $${NAME}-3.term || exit 8' >> $@
endif

regression/f77_driver.sh: Makefile
	$(AM_V_GEN)
	@mkdir -p $(BUILDDIR)/regression
	@echo '#!/bin/sh' > $@
	@echo 'arg=`$(ABS_PATH) $$1` # get absolute filename' >> $@
	@echo 'linewrap=`$(ABS_PATH) $(srcdir)/regression/linewrap.awk`' >> $@
	@echo 'include=`dirname $$arg`' >> $@
	@echo 'cd $(BUILDDIR)/regression' >> $@
	@echo 'echo "TERMITE: performing a translation circle of" $$arg' >> $@
	@echo 'set -x' >> $@
	@echo 'NAME=`basename $$arg .f`' >> $@
	@echo >> $@
	@echo '$(SRC2TERM) -I$$include $$arg -o $${NAME}-1.term || exit 1' >> $@
	@echo '$(TERM2SRC) $${NAME}-1.term -o $${NAME}-2.f || exit 2' >> $@
	@echo 'awk -f $$linewrap $${NAME}-2.f >wrap_$${NAME}-2.f && mv wrap_$${NAME}-2.f $${NAME}-2.f' >> $@
	@echo '$(SRC2TERM) --stl-engine -I$$include $${NAME}-2.f -o $${NAME}-3.term || exit 3' >> $@
	@echo '$(TERM2SRC) --stl-engine  $${NAME}-3.term -o $${NAME}-4.f || exit 4' >>$@
	@echo 'awk -f $$linewrap $${NAME}-4.f >wrap_$${NAME}-4.f && mv wrap_$${NAME}-4.f $${NAME}-4.f' >> $@
	@echo '$(SRC2TERM) --stratego -I$$include $${NAME}-4.f -o $${NAME}-5.term || exit 5' >> $@
	@echo '$(TERM2SRC) --stratego  $${NAME}-5.term -o $${NAME}-6.f || exit 6' >>$@
	@echo 'awk -f $$linewrap $${NAME}-6.f >wrap_$${NAME}-6.f && mv wrap_$${NAME}-6.f $${NAME}-6.f' >> $@
if ROSE_HAVE_SWI_PROLOG
	@echo '$(TERMLINT) $${NAME}-1.term || exit 7' >> $@
	@echo '$(TERMLINT) $${NAME}-3.term || exit 8' >> $@
endif
