SOURCES    = lexer.l parser.y main.c
BIN        = kv

OBJECTS   = main.o lex.yy.o parser.o
CC        = gcc
CFLAGS    = 
LDFLAGS   = -lm -lfl

all: lemon $(SOURCES) $(BIN)

$(BIN): $(OBJECTS)
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@

main.o: main.c parser.h
	$(CC) -c $<

lex.yy.o: lex.yy.c parser.h
	$(CC) -c $<
	
parser.o: parser.c
	$(CC) -c $<

lex.yy.c: lexer.l
	flex lexer.l

parser.c parser.h : parser.y
	./lemon -q $<

lemon: lemon.c
	$(CC) lemon.c -o lemon

clean:
	rm -rf $(BIN) $(OBJECTS) parser.c parser.h lex.yy.c lemon
