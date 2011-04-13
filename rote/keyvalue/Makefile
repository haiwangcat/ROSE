SOURCES    = lexer.l parser.y main.c Annotation.cpp Dynamic.cpp
BIN        = kv

OBJECTS   = main.o lex.yy.o parser.o Annotation.o Dynamic.o
CC        = g++
CFLAGS    = 
LDFLAGS   = -lm -lfl

all: lemon $(SOURCES) $(BIN)

$(BIN): $(OBJECTS)
	$(CC) $(OBJECTS) -o $@ $(LDFLAGS)

main.o: main.c parser.h
	$(CC) -c $<

.cpp.o:
	$(CC) -c $(CFLAGS) $< -o $@

lex.yy.o: lex.yy.c parser.h
	$(CC) -c $<
	
parser.o: parser.c
	$(CC) -c $<

lex.yy.c: lexer.l
	flex lexer.l

parser.c parser.h : parser.y
	./lemon -q $<

lemon: lemon.c
	gcc lemon.c -o lemon

clean:
	rm -rf $(BIN) $(OBJECTS) parser.c parser.h lex.yy.c lemon
