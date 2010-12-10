SUBDIRS = compiler


.PHONY: doc

doc:
	doxygen

distclean-local:
	rm -f toolcheck.log

EXTRA_DIST= \
	COPYRIGHT README \
	contrib/doxypy-0.4.2/PKG-INFO \
	contrib/doxypy-0.4.2/setup.py \
        contrib/doxypy-0.4.2/doxypy.py \
	contrib/ply/__init__.py        \
	contrib/ply/cpp.py	       \
	contrib/ply/ctokens.py	       \
	contrib/ply/lex.py	       \
	contrib/ply/yacc.py  	       \
	regression/parser/args.sidl                \
	regression/parser/ArrayTest.sidl	   \
	regression/parser/cca-0.6.3.sidl	   \
	regression/parser/cca-0.8.2.sidl	   \
	regression/parser/cca.sidl		   \
	regression/parser/clife.sidl		   \
	regression/parser/construct.sidl	   \
	regression/parser/cxxlife.sidl		   \
	regression/parser/decaf.sidl		   \
	regression/parser/enums.sidl		   \
	regression/parser/ExceptionTest.sidl	   \
	regression/parser/f90life.sidl		   \
	regression/parser/hello-client.sidl	   \
	regression/parser/hello-server.sidl	   \
	regression/parser/hello.sidl		   \
	regression/parser/Hello.sidl		   \
	regression/parser/hooks.sidl		   \
	regression/parser/inherit.sidl		   \
	regression/parser/life.sidl		   \
	regression/parser/objarg.sidl		   \
	regression/parser/ordering.sidl		   \
	regression/parser/output.sidl		   \
	regression/parser/Overload.sidl		   \
	regression/parser/pythonlife.sidl	   \
	regression/parser/sidl.sidl		   \
	regression/parser/sidlx.sidl		   \
	regression/parser/sort.sidl		   \
	regression/parser/strings.sidl		   \
	regression/parser/strop.sidl		   \
	regression/parser/struct.sidl		   \
	regression/parser/vect.sidl		   \
	regression/parser/wave2d_cxx_internal.sidl \
	regression/parser/wave2d_cxx.sidl	   \
	regression/parser/wave2d_f90.sidl	   \
	regression/parser/wave2d.sidl		   \
	regression/parser/wrapper.sidl
