.PHONY: all clean

CFLAGS=-Wall

RUN?=decb

TARGBASE=ppmtoflip44

TARGDECB=testflip44.slz \
	sluzexec.bin \
	sluzzle.dsk

TARGMON09=testflip44.s19 \
	sluzexec.s19

TARGETS=$(TARGBASE)
ifeq ($(RUN),decb)
	TARGETS+=$(TARGDECB)
else ifeq ($(RUN),mon09)
	TARGETS+=$(TARGMON09)
else
$(error Invalid RUN definition!)
endif

OBJECTS=testflip44.asm

EXTRA=gencolors colors.h

LOADER_PARTS=init.bas intro.bas select.bas dir.bas load.bas options.bas

all: $(TARGETS)

%.bin: %.asm
	mamou -mb -tb -l -y -o$@ $<

%.slz: %.asm
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

ppmtoflip44.o: colors.h palette.h

ppmtoflip44: ppmtoflip44.o
	$(CC) $(CFLAGS) -o $@ $<

test.ppm: test.jpg
	convert -resize 125x200%! -resize 128x192 -quantize YIQ +dither \
		-background blue -gravity center -extent 128x192 \
		test.jpg test.ppm

testflip44.asm: test.ppm ppmtoflip44
	./ppmtoflip44 $< $@

sluzzle.bas: $(LOADER_PARTS)
	cat $(LOADER_PARTS) > $@

sluzzle.dsk: sluzzle.bas testflip44.slz sluzexec.bin COPYING README 
	decb dskini $@
	decb copy -0 -b -l -t autoexec.bas $@,AUTOEXEC.BAS
	decb copy -0 -b -l -t sluzzle.bas $@,SLUZZLE.BAS
	decb copy -2 -b sluzexec.bin $@,SLUZEXEC.BIN
	decb copy -2 -b testflip44.slz $@,TESTFLIP.SLZ
	decb copy -3 -a -l COPYING $@,COPYING
	decb copy -3 -a -l README $@,README

clean:
	rm -f *.o $(TARGBASE) $(TARGDECB) $(TARGMON09) $(EXTRA) $(OBJECTS)
