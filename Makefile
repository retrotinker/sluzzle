.PHONY: all clean

CFLAGS=-Wall

RUN?=mon09

TARGBASE=ppmtog6c8 ppmtosg24 ppmtoflip44

TARGDECB=testg6c8.pic \
	testsg24.pic \
	testflip44.pic \
	sluzexec.bin \
	sluzzle.dsk

TARGMON09=testg6c8.s19 \
	testsg24.s19 \
	testflip44.s19 \
	sluzexec.s19

TARGETS=$(TARGBASE)
ifeq ($(RUN),decb)
	TARGETS+=$(TARGDECB)
else ifeq ($(RUN),mon09)
	TARGETS+=$(TARGMON09)
else
$(error Invalid RUN definition!)
endif

OBJECTS=testg6c8.asm testsg24.asm testflip44.asm

EXTRA=gencolors colors.h

LOADER_PARTS=init.bas intro.bas select.bas dir.bas load.bas options.bas

all: $(TARGETS)

%.bin: %.asm
	mamou -mb -tb -l -y -o$@ $<

%.pic: %.asm
	mamou -mb -tb -l -y -o$@ $<

%.s19: %.asm
	mamou -mr -ts -l -y -o$@ $<

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<

gencolors.o: palette.h

gencolors: gencolors.o
	$(CC) $(CFLAGS) -o $@ $<

colors.h: gencolors
	./gencolors > $@

ppmtog6c8.o: colors.h

ppmtog6c8: ppmtog6c8.o palette.h
	$(CC) $(CFLAGS) -o $@ $<

ppmtosg24: ppmtosg24.o palette.h
	$(CC) $(CFLAGS) -o $@ $<

ppmtoflip44: ppmtoflip44.o palette.h
	$(CC) $(CFLAGS) -o $@ $<

test.ppm: test.jpg
	convert -resize 125x200%! -resize 128x192 -quantize YIQ +dither \
		-background blue -gravity center -extent 128x192 \
		test.jpg test.ppm

testg6c8.asm: test.ppm ppmtog6c8
	./ppmtog6c8 $< $@

testsg24.asm: test.ppm ppmtosg24
	./ppmtosg24 $< $@

testflip44.asm: test.ppm ppmtoflip44
	./ppmtoflip44 $< $@

sluzzle.bas: $(LOADER_PARTS)
	cat $(LOADER_PARTS) > $@

sluzzle.dsk: sluzzle.bas testg6c8.pic sluzexec.bin COPYING README 
	decb dskini $@
	decb copy -0 -b -l -t sluzzle.bas $@,SLUZZLE.BAS
	decb copy -2 -b sluzexec.bin $@,SLUZEXEC.BIN
	decb copy -2 -b testg6c8.pic $@,TESTG6C8.PIC
	decb copy -3 -a -l COPYING $@,COPYING
	decb copy -3 -a -l README $@,README

clean:
	rm -f *.o $(TARGBASE) $(TARGDECB) $(TARGMON09) $(EXTRA) $(OBJECTS)
