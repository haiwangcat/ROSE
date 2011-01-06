SUBDIRS = compiler

info_TEXINFOS = doc/braid.texi
.PHONY: doc
doc:
	doxygen || echo "Doxygen not found; SKIPPING"
	$(MAKE) -j1 -C doc/latex

dist-local: doc

distclean-local:
	rm -f toolcheck.log

clean-local:
	rm -rf doc/html
	rm -rf doc/latex
	rm -rf doc/man

EXTRA_DIST= \
	COPYRIGHT README \
	contrib/README \
	contrib/argparse-1.1/setup.py      \
	contrib/argparse-1.1/README.txt    \
	contrib/argparse-1.1/PKG-INFO      \
	contrib/argparse-1.1/NEWS.txt      \
	contrib/argparse-1.1/argparse.py   \
	contrib/doxypy-0.4.2/PKG-INFO  \
	contrib/doxypy-0.4.2/setup.py  \
        contrib/doxypy-0.4.2/doxypy.py \
	contrib/ply/README             \
	contrib/ply/__init__.py        \
	contrib/ply/cpp.py	       \
	contrib/ply/ctokens.py	       \
	contrib/ply/lex.py	       \
	contrib/ply/yacc.py  	       \
	doc/latex/*.pdf \
	doc/html/*.* \
	doc/html/search/*.*

if PYTHON_VERSION_2_6
# add Backports
  python_PYTHON = contrib/argparse-1.1/argparse.py
endif
