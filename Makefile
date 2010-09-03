all: test

TESTS=../shams/example-5/DistrArray.sidl \
      ../babel.git/runtime/sidl/sidl.sidl \
      $(wildcard ../babel.git/regression/*/*.sidl)

TESTOUT=$(patsubst %.sidl,%.test, $(TESTS))

run2: ../babel.git/runtime/sidl/sidl.test

%.test: %.sidl babel2 
	./babel2 $<

run: $(TESTOUT)

clean:
	rm -rf babel2 *.pyc *.pyo parsetab.py* lextab.py* parser.log parser.out

test: babel2

lint:
	pylint sidl.py
	pylint parser.py

# Generate the parser tables
babel2: parser.py
	python $< --compile
	python $< --compile
	echo "/usr/bin/env python -O $< \$$@" >$@
	chmod u+x $@

# Run the program through M4
#%.preprocessed.py: %.py
#	m4 -P <$< >$@
