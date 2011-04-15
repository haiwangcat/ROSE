SOURCES    = scanner.l parser.y main.c Annotation.cpp Dynamic.cpp
BIN        = kv

OBJECTS   = main.o scanner.o parser.o Annotation.o Dynamic.o
CC        = g++
CFLAGS    = 
LDFLAGS   = -lm -lfl

all: lemon $(SOURCES) $(BIN)

$(BIN): $(OBJECTS)
	$(CC) $(OBJECTS) -o $@ $(LDFLAGS)

main.o: main.c scanner.h parser.h
	$(CC) -c $<

.cpp.o:
	$(CC) -c $(CFLAGS) $< -o $@

scanner.o: scanner.c scanner.h parser.h
	$(CC) -c $<
	
parser.o: parser.c
	$(CC) -c $<

scanner.c scanner.h: scanner.l
	flex $<

parser.c parser.h : parser.y
	./lemon -q $<

lemon: lemon.c
	gcc lemon.c -o lemon

clean:
	rm -rf $(BIN) $(OBJECTS) parser.c parser.h scanner.c scanner.h lemon
