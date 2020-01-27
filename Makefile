CFLAGS = -g -O3 -ansi -pedantic -Wall -Wextra -Wno-unused-parameter -ISources/Hoedown
PREFIX = /usr/local

ifneq ($(OS),Windows_NT)
	CFLAGS += -fPIC
endif

HOEDOWN_SRC=\
	Sources/Hoedown/autolink.o \
	Sources/Hoedown/buffer.o \
	Sources/Hoedown/document.o \
	Sources/Hoedown/escape.o \
	Sources/Hoedown/html.o \
	Sources/Hoedown/html_blocks.o \
	Sources/Hoedown/html_smartypants.o \
	Sources/Hoedown/stack.o \
	Sources/Hoedown/version.o

.PHONY:		all test test-pl clean

all:		libhoedown.so bin/hoedown bin/smartypants

# Libraries

libhoedown.so: libhoedown.so.3
	ln -f -s $^ $@

libhoedown.so.3: $(HOEDOWN_SRC)
	$(CC) -shared $^ $(LDFLAGS) -o $@

libhoedown.a: $(HOEDOWN_SRC)
	$(AR) rcs libhoedown.a $^

# Executables

bin/hoedown: bin/hoedown.o $(HOEDOWN_SRC)
	$(CC) $^ $(LDFLAGS) -o $@

bin/smartypants: bin/smartypants.o $(HOEDOWN_SRC)
	$(CC) $^ $(LDFLAGS) -o $@

# Perfect hashing

Sources/Hoedown/html_blocks.c: html_block_names.gperf
	gperf -L ANSI-C -N hoedown_find_block_tag -c -C -E -S 1 --ignore-case -m100 $^ > $@

# Testing

test: bin/hoedown
	python test/runner.py

test-pl: hoedown
	perl test/MarkdownTest_1.0.3/MarkdownTest.pl \
		--script=./hoedown --testdir=test/MarkdownTest_1.0.3/Tests --tidy

# Housekeeping

clean:
	$(RM) Sources/Hoedown/*.o bin/*.o
	$(RM) libhoedown.so libhoedown.so.1 libhoedown.a
	$(RM) bin/hoedown bin/smartypants

# Installing

install:
	install -m755 -d $(DESTDIR)$(PREFIX)/lib
	install -m755 -d $(DESTDIR)$(PREFIX)/bin
	install -m755 -d $(DESTDIR)$(PREFIX)/include

	install -m644 libhoedown.* $(DESTDIR)$(PREFIX)/lib
	install -m755 bin/hoedown $(DESTDIR)$(PREFIX)/bin
	install -m755 bin/smartypants $(DESTDIR)$(PREFIX)/bin

	install -m755 -d $(DESTDIR)$(PREFIX)/include/hoedown
	install -m644 Sources/Hoedown/*.h $(DESTDIR)$(PREFIX)/include/hoedown

# Generic object compilations

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

Sources/Hoedown/html_blocks.o: Sources/Hoedown/html_blocks.c
	$(CC) $(CFLAGS) -Wno-static-in-inline -c -o $@ $<
