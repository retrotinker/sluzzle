*
* Copyright (c) 2013, John W. Linville <linville@tuxdriver.com>
* 
* Permission to use, copy, modify, and/or distribute this software for any
* purpose with or without fee is hereby granted, provided that the above
* copyright notice and this permission notice appear in all copies.
* 
* THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
* WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
* MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
* ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
* WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
* ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
* OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*
	nam	sluzexec
	ttl	Viewer/game binary for Sluzzle

LOAD	equ	$6100

TIMVAL	equ	$0112		Color BASIC's free-running time counter
INTCNV	equ	$b3ed		Color BASIC's routine for taking an integer
GIVABF	equ	$b4f4		Color BASIC's routine for returning a value

PIA0D0	equ	$ff00		Coco hardware definitions
PIA0C0	equ	$ff01
PIA0D1	equ	$ff02
PIA0C1	equ	$ff03

PIA1D0	equ	$ff20
PIA1C0	equ	$ff21
PIA1D1	equ	$ff22
PIA1C1	equ	$ff23

SQWAVE	equ	$02

SCNBASE	equ	$0e00
SG24OFF	equ	$1800
CSSBASE	equ	$6000

RTOTLEN	equ	$16
RSKPLEN	equ	$06

BLKHGHT	equ	$30		If changed, need to adjust block offset math

ACTEXIT	equ	$00		Input action code for exit
ACTMVUP	equ	$01			...for move up
ACTMVDN	equ	$02			...for move down
ACTMVLT	equ	$03			...for move left
ACTMVRT	equ	$04			...for move right
ACTUNSC	equ	$05			...for unscramble
ACTRESC	equ	$06			...for rescramble
ACTHELP	equ	$07			...for show help

	org	LOAD
START	pshs	dp,y		Push partial entry state onto stack

	jsr	INTCNV		Get timeout parameter passed from Color BASIC
	std	>TIMEOUT
	std	>TIMECNT

	lda	#$ff		Setup DP register
	tfr	a,dp
	setdp	$ff
	orcc	#$50		Disable interrupts

	lda	PIA1C1		Enable square wave audio output
	anda	#$fb
	sta	PIA1C1
	ldb	#SQWAVE
	orb	PIA1D1
	stb	PIA1D1
	ora	#$04
	sta	PIA1C1

MODIFY	ldx	#CSSBASE	Load pointer to modification data table
	ldy	#HROW0ST	Load pointer to instructions
	lda	#$c0		Init count of lines to modify
	pshs	a
	lda	#$08		Init count of instructions per line
	pshs	a
	lda	,x+

MODIFY1	lsla			Shift modification data one place to the left
	bcs	MODIFY2		Test if bit set...

	ldb	#$97		CSS not set, use STA
	stb	,y++
	bra	MODIFY3

MODIFY2	ldb	#$d7		CSS set, use STB
	stb	,y++

MODIFY3	dec	,s		Decrement instruction counter
	bne	MODIFY1

	dec	1,s		Decrement line counter
	beq	MODIFY4

	lda	#$08		Reset count of instructions per line
	sta	,s
	lda	,x+
	leay	RSKPLEN,y
	bra	MODIFY1		Next line...

MODIFY4	leas	2,s		Clean-up stack

	ldx	#BLOKMAP	Initialize block map
	lda	#$0f
BMINILP	sta	a,x
	deca
	bne	BMINILP
	sta	,x

	lda	#$0f
	sta	CURBLOK		Set bottom-rightmost block as current block
	lbsr	BLBLOCK		Blank-out bottom-rightmost block

	lda	TIMVAL+1	Initialize LFSR seed
	bne	LFSRINI
	lda	#$01		Can't start w/ zero
LFSRINI	sta	LFSRDAT

GAMSTRT	clr	GAMSTAT		Clear the game state field

	clr	MOVECNT		Clear the count of legal moves
	clr	MOVECNT+1

	lbsr	SHUFFLE		Shuffle the blocks...

	lbsr	BLOKSAV		Save the state of the blocks...
	lbsr	UNSCRAM		Start with unscrambled image...
	dec	GAMSTAT		And wait for initial key press...

VSTART	clr	$ffc3		Setup G6C video mode at address $0e00
	clr	$ffc5
	clr	$ffc7
	clr	$ffc9
	clr	$ffcb

	ldb     PIA0C0		Disable hsync interrupt generation
	andb	#$fc
	stb     PIA0C0
	tst	PIA0D0
	lda     PIA0C1		Enable vsync interrupt generation
	ora     #$01
	sta     PIA0C1
	tst	PIA0D1
	sync			Wait for vsync interrupt
	anda	#$fc		Disable vsync interrupt generation
	sta     PIA0C1
	tst	PIA0D1
	orb     #$01		Enable hsync interrupt generation
	stb     PIA0C0
	tst	PIA0D0

VINIT	clr	$ffce
	clr	$ffcb

*
* After the program starts, vsync interrupts aren't used...
*
VSYNC	ldd	TIMECNT		Decrement inactivity timeout counter
	subd	#$0001
	lbeq	TIMEX
	std	TIMECNT

	ldb	#$44		Count lines during vblank and vertical borders
HCOUNT	tst	$ff00
	sync
	decb
	bne	HCOUNT
	lda	#$e0		Setup CSS options for raster effects
	ldb	#$e8
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
HROW0ST	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
HROW0EN	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
HROW1ST	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	tst	$ff00		Wait for next hsync interrupt
	sync
	nop			Extra delay for beginning of visible line
	nop
	nop
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22
	sta	$ff22

*
* SG24 display code starts here...
*
SGSTART	clr	$ffca		Point the VDG at the SG24 data
	clr	$ffcf
	lda	#$e0
	sta	$ff22

SGVSYNC	ldd	TIMECNT		Decrement inactivity timeout counter
	subd	#$0001
	lbeq	TIMEX
	std	TIMECNT

	ldb	#$45		Count lines during vblank and vertical borders
SHCOUNT	tst	$ff00
	sync
	decb
	bne	SHCOUNT
	ldb	#$c0
	tst	$ff00
	sync
SGVACTV	nop
	andcc	#$ff
	lda	#$00		Need CSS preset for background color!
	sta	$ff22
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	andcc	#$ff
	lda	#$e0		Set for G6C mode to get chosen background!
	sta	$ff22
	nop
	nop
	nop
	nop
	decb
	bne	SGVACTV

CHKKYBD	clr	PIA0D1		Check for any key input
	lda	PIA0D0
	anda	#$7f		Check for any active columns
	cmpa	#$7f
	bne	CHKKBD0		If active columns, look for legal keys
	dec	PIA0D1		Reset keyboard col selects
	lbra	VINIT		No active columns, so continue

CHKKBD0	clr	$ff22		Switch to SG24 mode for keyboard handling

	ldd	TIMEOUT		Reset inactivity timeout counter
	std	TIMECNT

	lda	#$fb		Check for 'BREAK' first...
	sta	PIA0D1
	lda	PIA0D0
	bita	#$40
	bne	CHKKBD1

	lda	#ACTEXIT
	lbra	CHKKBDX

CHKKBD1	tst	GAMSTAT		Check for non-zero game status next...
	beq	CHKKBD2		...to pair unscramble w/ rescramble...

	clr	GAMSTAT

	lda	#ACTRESC
	lbra	CHKKBDX

CHKKBD2	lda	#$fd		Check for 'i'
	sta	PIA0D1
	lda	PIA0D0
	bita	#$02
	bne	CHKKBD3

	lda	#ACTMVUP
	lbra	CHKKBDX

CHKKBD3	lda	#$fb		Check for 'j'
	sta	PIA0D1
	lda	PIA0D0
	bita	#$02
	bne	CHKKBD4

	lda	#ACTMVLT
	lbra	CHKKBDX

CHKKBD4	lda	#$f7		Check for 'k'
	sta	PIA0D1
	lda	PIA0D0
	bita	#$02
	bne	CHKKBD5

	lda	#ACTMVDN
	bra	CHKKBDX

CHKKBD5	lda	#$ef		Check for 'l'
	sta	PIA0D1
	lda	PIA0D0
	bita	#$02
	bne	CHKKBD6

	lda	#ACTMVRT
	bra	CHKKBDX

CHKKBD6	lda	#$f7		Check for 'UP ARROW'
	sta	PIA0D1
	lda	PIA0D0
	bita	#$08
	bne	CHKKBD7

	lda	#ACTMVUP
	bra	CHKKBDX

CHKKBD7	lda	#$df		Check for 'LEFT ARROW'
	sta	PIA0D1
	lda	PIA0D0
	bita	#$08
	bne	CHKKBD8

	lda	#ACTMVLT
	bra	CHKKBDX

CHKKBD8	lda	#$ef		Check for 'DOWN ARROW'
	sta	PIA0D1
	lda	PIA0D0
	bita	#$08
	bne	CHKKBD9

	lda	#ACTMVDN
	bra	CHKKBDX

CHKKBD9	lda	#$bf		Check for 'RIGHT ARROW'
	sta	PIA0D1
	lda	PIA0D0
	bita	#$08
	bne	CHKKBDA

	lda	#ACTMVRT
	bra	CHKKBDX

CHKKBDA	lda	#$fe		Check for 'h'
	sta	PIA0D1
	lda	PIA0D0
	bita	#$02
	bne	CHKKBDB

	dec	GAMSTAT		Indicate screen is unscrambled...

	lda	#ACTUNSC
	bra	CHKKBDX

CHKKBDB	lda	#$7f		Check for 'SHIFT'
	sta	PIA0D1
	lda	PIA0D0
	bita	#$40
	bne	CHKKBDC

	lda	#$7f		Also check for '/' (? is Shift-/)
	sta	PIA0D1
	lda	PIA0D0
	bita	#$20
	bne	CHKKBDC

	lda	#ACTHELP
	bra	CHKKBDX

CHKKBDC	clr	PIA0D1		Enable all keyboard col selects
	ldb	PIA0D0		Wait for key release
	andb	#$7f
	cmpb	#$7f
	bne	CHKKBDC

	dec	PIA0D1		Reset keyboard col selects
	jmp	VSTART

CHKKBDX	ldb	PIA0D0		Wait for key release
	andb	#$7f
	cmpb	#$7f
	bne	CHKKBDX

	ldb	#$ff		Reset keyboard col selects
	stb	PIA0D1

CHKACTN	lsla			Shift offset for jump table entry width
	ldx	#CKACTJT
	jmp	a,x

CKACTJT	bra	CKACTEX		Jump table (2 bytes per entry)
	bra	CKACTUP
	bra	CKACTDN
	bra	CKACTLT
	bra	CKACTRT
	bra	CKACTUN
	bra	CKACTRE
	bra	CKACTHP

CKACTUN	lbsr	BLOKSAV		Save the state of the blocks...
	lbsr	UNSCRAM
	bra	CKACTLP

CKACTRE	lbsr	RESCRAM
	bra	CKACTLP

CKACTUP	lbsr	MOVEUP
	bcs	CKACTLP
	bra	CKACTSN

CKACTDN	lbsr	MOVEDN
	bcs	CKACTLP
	bra	CKACTSN

CKACTLT	lbsr	MOVELT
	bcs	CKACTLP
	bra	CKACTSN

CKACTRT	lbsr	MOVERT
	bcs	CKACTLP
;	bra	CKACTSN

CKACTSN	ldb	#$20

CKACTS1	tst	PIA0D0		Play tone for successful move
	sync

	lda	PIA1D1		Toggle square wave output...
	eora	#SQWAVE
	sta	PIA1D1

	decb
	bne	CKACTS1

	ldd	MOVECNT		Increment the legal move counter
	addd	#$0001
	std	MOVECNT

CKACTGW	ldx	#BLOKMAP	Point at block map
	lda	#$0f		Initialize offset

CKACTG1	cmpa	a,x		Compare offset to value at offset
	bne	CKACTLP		If no match, then loop

	deca			Decrement offset
	bne	CKACTG1		If not zero, keep checking

	cmpa	a,x		Still have to check offset zero
	beq	GAMEWON		Match?  Winner!

CKACTLP	jmp	VSTART

CKACTHP	jmp	SHOWHLP		Show help screen

CKACTEX	lbsr	UNSCRAM		Unscramble the screen

	ldd	MOVECNT		Negate the number of legal moves
	coma
	comb
	addd	#$0001

	jmp	EXIT

*
* Entry point to show help screen (i.e. reenable text screen)
*
* NOTE: called from highest level (not from a function)
*
SHOWHLP	clr	$ffc4		Set SAM for A/S mode
	clr	$ffc2

	clr	$ffca		Restore text screen
	clr	$ffc6

	clr	$ff22		Set VDG for A/S mode

	clr	PIA0D1		Check for any key input
SHWHLP1	lda	PIA0D0
	anda	#$7f		Check for any active columns
	cmpa	#$7f
	beq	SHWHLP1		Wait for next key press
	dec	PIA0D1		Reset keyboard col selects

	jmp	VSTART

*
* Entry point for when the game is won
*
* NOTE: called from highest level (not from a function)
*
GAMEWON	ldd	MOVECNT		Return the number of moves

	jmp	EXIT

*
* Entry point for timeout counter expiring
*
* NOTE: called from highest level (not from a function)
*
TIMEX	ldd	TIMEOUT		Check for non-zero timeout value
	beq	TIMEX1

	clr	$ff22		Switch to SG24 mode

	lbsr	UNSCRAM		Unscramble the screen

	ldd	MOVECNT		Negate the number of legal moves
	coma
	comb
	addd	#$0001

	jmp	EXIT

TIMEX1	std	TIMECNT		Reset time counter
	jmp	VSTART

*
* Entry point to exit the game
*
* NOTE: called from highest level (not from a function)
*
EXIT	pshs	b		Save B for return value
	ldb     PIA0C0		Disable hsync interrupt generation
	andb	#$fc
	stb     PIA0C0
	tst	PIA0D0
	ldb     PIA0C1		Enable vsync interrupt generation
	orb	#$01
	stb     PIA0C1
	puls	dp,b,y		Pull partial entry state from stack
	jmp	GIVABF		Return a value to Color BASIC

*
* Save the state of the blocks
*
*	A,B clobbered
*	X,Y clobbered
*
BLOKSAV	ldx	#BLOKMAP	Save the block state
	ldy	#SAVEMAP

	lda	#$0f

BLKSAV1	ldb	a,x
	stb	a,y
	deca
	bne	BLKSAV1
	ldb	,x
	stb	,y

	lda	CURBLOK
	sta	SAVBLOK

	rts

*
* Shuffle the blocks!
*
*	A,B get clobbered
*	X gets clobbered
*
SHUFFLE	lda	#$30		Setup counter for shuffling moves
	pshs	a
	ldb	#$06		Dummy-up forbidden direction for first move
	pshs	b

SHUFFL1	lbsr	LFSRGET		Pick a "random" number
	anda	#$06		Mask to four directional values (shifted left)

	cmpa	,s		Compare to forbidden direction
	beq	SHUFFL1		If matches, try again
	tfr	a,b		Compute next forbidden direction...
	eorb	#$02		...which is really just the opposite direction
	stb	,s		Store the new forbidden direction

	ldx	#SHUFFJT	Setup jump table
	jmp	a,x		Jump to offset for directional choice

SHUFFJT	bra	SHUFFUP		Jump table (2 bytes per entry)
	bra	SHUFFDN
	bra	SHUFFLT
	bra	SHUFFRT

SHUFFUP	bsr	MOVEUP		Try to move up...
	bcs	SHUFFL1		Failed?  Then try again...
	bra	SHUFFLP

SHUFFDN	bsr	MOVEDN		Try to move down...
	bcs	SHUFFL1		Failed?  Then try again...
	bra	SHUFFLP

SHUFFLT	bsr	MOVELT		Try to move left...
	bcs	SHUFFL1		Failed?  Then try again...
	bra	SHUFFLP

SHUFFRT	bsr	MOVERT		Try to move right...
	bcs	SHUFFL1		Failed?  Then try again...
	bra	SHUFFLP

SHUFFLP	dec	1,s
	bne	SHUFFL1

	leas	2,s
	rts

*
* Move a block -- multiple entry points
*
*	A,B clobbered
*	X clobbered
*
MOVEUP	lda	#$0c		Verify not on bottom row
	anda	CURBLOK
	cmpa	#$0c
	beq	MOVFAIL

	lda	CURBLOK		Add 4 to block number
	adda	#$04

	bra	MOVEFIN		Move the block

MOVEDN	lda	#$0c		Verify not on top row
	anda	CURBLOK
	beq	MOVFAIL

	lda	CURBLOK		Subtract 4 from block number
	suba	#$04

	bra	MOVEFIN		Move the block

MOVELT	lda	#$03		Verify not on right column
	anda	CURBLOK
	cmpa	#$03
	beq	MOVFAIL

	lda	CURBLOK		Add 1 to block number
	inca

	bra	MOVEFIN		Move the block

MOVERT	lda	#$03		Verify not on left column
	anda	CURBLOK
	beq	MOVFAIL

	lda	CURBLOK		Subtract 1 from block number
	deca

	bra	MOVEFIN		Move the block

MOVFAIL	orcc	#$01		Indicate move failure
	bra	MOVEXIT

MOVEFIN	pshs	a		Save new block number for later

	ldx	#BLOKMAP	Point at block map for update
	ldb	a,x		Get old map value for new block
	pshs	b		Save old map value for new block

	lda	CURBLOK		Load current block number for update
	ldb	a,x		Get old map value for old block
	lda	1,s		Restore new block number for update
	stb	a,x		Store new map value for new block
	lda	CURBLOK		Load current block number
	puls	b		Restore old map value for new block
	stb	a,x		Store new map value for old block

	lda	,s		Restore new block number for copying
	ldb	CURBLOK		Load current block number for copying
	sta	CURBLOK		Save new block as new current block
	lbsr	CPBLOCK		Copy new block to old block

	puls	a		Restore new block and blank it
	lbsr	BLBLOCK

	andcc	#$fe		Indicate move success

MOVEXIT	rts

*
* Unscramble the screen
*
*	A,B clobbered
*	X clobbered
*
UNSCRAM	lda	#$0f		Copy current block 15 to CURBLOK
	ldb	CURBLOK
	lbsr	CPBLOCK

	lda	#$0f		Blank the scratch block
	lbsr	BLBLOCK

	ldx	#BLOKMAP	Swap block 15 and CURBLOK in the block map
	lda	$0f,x
	ldb	CURBLOK
	sta	b,x
	lda	#$0f
	sta	$0f,x
	sta	CURBLOK

	clrb			Initialize "dirty" flag
	pshs	b
	deca			Initialize count for remainging locks (14 to 0)
	pshs	a

UNSCRLP	cmpa	a,x		If current block already correct, skip
	beq	UNSLEND
	ldb	#$ff		Set "dirty" flag
	stb	1,s

	pshs	a		Copy current contents to block 15 (now 'empty')
	ldb	#$0f
	lbsr	CPBLOCK

	lda	,s		Blank the copied block (needed to keep CSS data correct)
	lbsr	BLBLOCK

	ldb	,s		Copy contents from block occupying original position
	ldx	#BLOKMAP
	lda	b,x
	lbsr	CPBLOCK

	ldb	,s		Blank the copied block (needed to keep CSS data correct)
	ldx	#BLOKMAP
	lda	b,x
	lbsr	BLBLOCK

	lda	,s		Copy contents from block 15 out to original position
	ldx	#BLOKMAP
	ldb	a,x
	lda	#$0f
	lbsr	CPBLOCK

	lda	#$0f		Blank the scratch block
	lbsr	BLBLOCK

	ldx	#BLOKMAP	Swap values in block map
	lda	,s
	ldb	a,x
	lda	b,x
	stb	b,x
	puls	b
	sta	b,x

UNSLEND	lda	,s		If end of count, check for "dirty" flag
	beq	UNSCRCK
	deca			Otherwise, decrement count and loop
	sta	,s
	bra	UNSCRLP

UNSCRCK	tst	1,s		If "dirty" flag set, clear flag and restart the loop
	beq	UNSCREX
	clr	1,s
	lda	#$0e
	sta	,s
	bra	UNSCRLP

UNSCREX	leas	2,s		Clean-up stack and exit
	rts

*
* Rescramble the screen (only use w/ unscrambled screen and saved block map)
*
*	A,B clobbered
*	X,Y clobbered
*
RESCRAM	lda	SAVBLOK		Swap current blank box w/ saved blank box
	cmpa	#$0f		If already matches, then skip
	beq	RESCRA1

	ldb	#$0f		Copy data from new blank box to current blank box
	lbsr	CPBLOCK

	lda	SAVBLOK		Blank the new box
	bsr	BLBLOCK

	ldx	#BLOKMAP	Swap the map data for the blank boxes
	lda	SAVBLOK
	sta	$0f,x
	ldb	#$0f
	stb	a,x

RESCRA1	sta	CURBLOK		Save new blank box as current blank box

	lda	#$0f		Walk the block list, starting with block 15
	pshs	a		Save as count

RESCRLP	cmpa	CURBLOK		If block matches CURBLOK, skip it
	beq	RESLPEN

	ldb	CURBLOK		Copy block data to scratch area
	lbsr	CPBLOCK

	lda	,s		Blank the current block data
	bsr	BLBLOCK

	ldx	#SAVEMAP	Retrieve saved block number for this location
	lda	,s
	ldb	a,x

	ldx	#BLOKMAP
	lda	#$0f
RESCFLP	cmpb	a,x		Search for saved block number in current map
	beq	RESCFLX
	deca
	bra	RESCFLP		Something should be a match, so no bounds check

RESCFLX	pshs	a		Save the source block location number
	ldb	1,s		Reload destination block location number
	lbsr	CPBLOCK		Copy new block data to current block

	lda	,s		Blank the new block data
	bsr	BLBLOCK

	lda	CURBLOK		Copy block data from scratch area
	ldb	,s
	lbsr	CPBLOCK	

	lda	CURBLOK		Blank the scratch area block data
	bsr	BLBLOCK

	ldx	#BLOKMAP	Swap the blocks in the map
	lda	,s		Retrieve old source block map location
	ldb	a,x		Retrieve old source block number from map
	pshs	b		Save old source block number
	lda	2,s		Retrieve old dest block map location
	ldb	a,x		Retrieve old dest block number from map
	lda	1,s		Retrieve old source block map location
	stb	a,x		Store old dest block number at old source location
	lda	2,s		Retrieve old dest block map location
	puls	b		Retrive old source block number
	stb	a,x		Store old source block number at old dest location

	leas	1,s		Clean-up stack

RESLPEN	lda	,s		Repeat for all blocks
	beq	RESCREX
	deca
	sta	,s
	bra	RESCRLP

RESCREX	leas	1,s
	rts

*
* Blank-out a block
*
*	A input block to blank, clobbered
*	X,B clobbered
*
BLBLOCK	pshs	a
	anda	#$03		Determine data offset for block =
	lsla				screenbase +
	lsla				(block / 4) * 1536 +
	lsla				(block % 4) * 8
	pshs	a
	lda	1,s
	anda	#$fc
	clrb
	pshs	d
	lsra
	rorb
	addd	,s
	addb	2,s
	bcc	BLBLCK1
	inca
BLBLCK1	ldx	#SCNBASE
	leax	d,x
	leas	3,s
	pshs	x

BLRWDAT	lda	#BLKHGHT	Init row counter
	ldb	#$aa		Load blank-out data
BLRWDT1	stb	,x		Fill rows w/ blank-out data
	stb	1,x
	stb	2,x
	stb	3,x
	stb	4,x
	stb	5,x
	stb	6,x
	stb	7,x
	leax	$20,x
	deca
	bne	BLRWDT1

	puls	x		Repeat for SG24 data
	ldd	#SG24OFF
	leax	d,x
BLSGDAT	lda	#BLKHGHT	Init row counter
	ldb	#$80		Load blank-out data
BLSGDT1	stb	,x		Fill rows w/ blank-out data
	stb	1,x
	stb	2,x
	stb	3,x
	stb	4,x
	stb	5,x
	stb	6,x
	stb	7,x
	leax	$20,x
	deca
	bne	BLSGDT1

BLRWINS	ldx	#HROW0ST	Determine code offset for block =
	lda	,s			codebase +
	anda	#$fc			(block / 4) * 48 * len +
	lsla				(block % 4) * 4
	lsla
	pshs	a
	lsla
	adda	,s
	ldb	#RTOTLEN
	mul
	leax	d,x
	leas	1,s

	lda	,s
	anda	#$03
	lsla
	lsla
	leax	a,x

	lda	#BLKHGHT	Init row counter
	ldb	#$97		Load blank-out instruction
BLRWIN1	stb	,x		Fill rows w/ blank-out instruction
	stb	2,x
	leax	RTOTLEN,x
	deca
	bne	BLRWIN1

BLRWCSS	ldx	#CSSBASE	Determine CSS data offset for block =
	ldb	,s			CSSbase + (block / 4) * 48
	clra
	andb	#$fc
	lslb
	lslb
	pshs	b
	lslb
	addb	,s
	leax	d,x
	leas	1,s

	ldb	#$c0		Init CSS data mask
	lda	,s
	anda	#$03		Calculate block bit position
BLRWCS1	beq	BLRWCS2		Shift CSS data mask for block
	lsrb
	lsrb
	deca
	bra	BLRWCS1

BLRWCS2	lda	#BLKHGHT	Setup CSS data row counter
	comb			Complement CSS data mask for AND operation
	pshs	b		Save for later

BLRWCS3	andb	,x		Apply mask to CSS data
	stb	,x		Save modified CSS data
	leax	1,x		Advance to next row
	ldb	,s		Restore CSS data mask
	deca			Decrement row counter
	bne	BLRWCS3

	leas	2,s		Free remaining stack data
	rts

*
* Copy from one block to another
*
*	A input block copy source, clobbered
*	B input block copy dest, clobbered
*	X,Y clobbered
*
CPBLOCK	pshs	a
	pshs	b
	anda	#$03		Determine data offset for src block =
	lsla				screenbase +
	lsla				(block / 4) * 1536 +
	lsla				(block % 4) * 8
	pshs	a
	lda	2,s
	anda	#$fc
	clrb
	pshs	d
	lsra
	rorb
	addd	,s
	addb	2,s
	bcc	CPBLCK1
	inca
CPBLCK1	ldx	#SCNBASE
	leax	d,x
	leas	3,s

	lda	,s
	anda	#$03		Determine data offset for dest block =
	lsla				screenbase +
	lsla				(block / 4) * 1536 +
	lsla				(block % 4) * 8
	pshs	a
	lda	1,s
	anda	#$fc
	clrb
	pshs	d
	lsra
	rorb
	addd	,s
	addb	2,s
	bcc	CPBLCK2
	inca
CPBLCK2	ldy	#SCNBASE
	leay	d,y
	leas	3,s
	pshs	x,y

CPRWDAT	lda	#BLKHGHT	Init row counter
CPRWDT1	ldb	,x		Copy rows from source to dest
	stb	,y
	ldb	1,x
	stb	1,y
	ldb	2,x
	stb	2,y
	ldb	3,x
	stb	3,y
	ldb	4,x
	stb	4,y
	ldb	5,x
	stb	5,y
	ldb	6,x
	stb	6,y
	ldb	7,x
	stb	7,y
	leax	$20,x
	leay	$20,y
	deca
	bne	CPRWDT1

	puls	x,y		Repeat for SG24 data
	ldd	#SG24OFF
	leax	d,x
	leay	d,y
CPSGDAT	lda	#BLKHGHT	Init row counter
CPSGDT1	ldb	,x		Copy rows from source to dest
	stb	,y
	ldb	1,x
	stb	1,y
	ldb	2,x
	stb	2,y
	ldb	3,x
	stb	3,y
	ldb	4,x
	stb	4,y
	ldb	5,x
	stb	5,y
	ldb	6,x
	stb	6,y
	ldb	7,x
	stb	7,y
	leax	$20,x
	leay	$20,y
	deca
	bne	CPSGDT1

CPRWINS	ldx	#HROW0ST	Determine code offset for src block =
	lda	1,s			codebase +
	anda	#$fc			(block / 4) * 48 * len +
	lsla				(block % 4) * 4
	lsla
	pshs	a
	lsla
	adda	,s
	ldb	#RTOTLEN
	mul
	leax	d,x
	leas	1,s

	lda	1,s
	anda	#$03
	lsla
	lsla
	leax	a,x

	ldy	#HROW0ST	Determine code offset for dest block =
	lda	,s			codebase +
	anda	#$fc			(block / 4) * 48 * len +
	lsla				(block % 4) * 4
	lsla
	pshs	a
	lsla
	adda	,s
	ldb	#RTOTLEN
	mul
	leay	d,y
	leas	1,s

	lda	,s
	anda	#$03
	lsla
	lsla
	leay	a,y

	lda	#BLKHGHT	Init row counter
CPRWIN1	ldb	,x		Copy instruction for src row...
	stb	,y		...to destination row
	ldb	2,x		Ditto...
	stb	2,y		...ditto
	leax	RTOTLEN,x	Advance src code offset
	leay	RTOTLEN,y	Advance dest code offset
	deca			Decrement row counter
	bne	CPRWIN1

CPRWCSS	ldx	#CSSBASE	Determine src CSS data offset for block =
	ldb	1,s			CSSbase + (block / 4) * 48
	clra
	andb	#$fc
	lslb
	lslb
	pshs	b
	lslb
	addb	,s
	leax	d,x
	leas	1,s

	ldb	#$80		Init src CSS data mask
	lda	1,s
	anda	#$03		Calculate block bit position
CPRWCS1	beq	CPRWCS2		Shift CSS data mask for block
	lsrb
	lsrb
	deca
	bra	CPRWCS1

CPRWCS2	pshs	b		Save src even CSS data mask
	lsrb
	pshs	b		Save src odd CSS data mask

	ldy	#CSSBASE	Determine dest CSS data offset for block =
	ldb	2,s			CSSbase + (block / 4) * 48
	clra
	andb	#$fc
	lslb
	lslb
	pshs	b
	lslb
	addb	,s
	leay	d,y
	leas	1,s

	ldb	#$80		Init dest CSS data mask
	lda	2,s
	anda	#$03		Calculate block bit position
CPRWCS3	beq	CPRWCS4		Shift CSS data mask for block
	lsrb
	lsrb
	deca
	bra	CPRWCS3

CPRWCS4	pshs	b		Save dest even CSS data mask
	lsrb
	pshs	b		Save dest odd CSS data mask

	lda	#BLKHGHT	Setup CSS data row counter
CPRWCS5	ldb	,x		Load src CSS data
	andb	3,s		Mask for relevant bit (even)
	beq	CPRWCS6		If not set, skip setting dest (presumed clear)
	ldb	,y		Load dest CSS data
	orb	1,s		Set relevant bit (even)
	stb	,y		Store dest CSS data
CPRWCS6	ldb	,x+		Load src CSS data, increment offset
	andb	2,s		Mask for relevant bit (odd)
	beq	CPRWCS7		If not set, skip setting dest (presumed clear)
	ldb	,y		Load dest CSS data
	orb	,s		Set relevant bit (odd)
	stb	,y		Store dest CSS data
CPRWCS7	leay	1,y		Increment dest CSS data offset
	deca			Decrement row counter
	bne	CPRWCS5

	leas	6,s
	rts

*
* Advance the LFSR value and return pseudo-random value
*
*	A returns pseudo-random value
*	B gets clobbered
*
* 	Wikipedia article on LFSR cites this polynomial for a maximal 8-bit LFSR:
*
*		x8 + x6 + x5 + x4 + 1
*
*	http://en.wikipedia.org/wiki/Linear_feedback_shift_register
*
LFSRGET	lda	LFSRDAT		Get MSB of LFSR data
	anda	#$80		Capture x8 of LFSR polynomial
	lsra
	lsra
	eora	LFSRDAT		Capture X6 of LFSR polynomial
	lsra
	eora	LFSRDAT		Capture X5 of LFSR polynomial
	lsra
	eora	LFSRDAT		Capture X4 of LFSR polynomial
	lsra			Move result to Carry bit of CC
	lsra
	lsra
	lsra
	lda	LFSRDAT		Get all of LFSR data
	rola			Shift result into 8-bit LFSR
	sta	LFSRDAT		Store the result
	rts

CURBLOK	rmb	1		Current "empty" block
LFSRDAT	rmb	1		Current seed for LFSR

BLOKMAP	rmb	16		Map of block positions
SAVEMAP	rmb	16		Save area for block map (during "hint")
SAVBLOK	rmb	1		Save area for current "empty" (during "hint")

GAMSTAT	rmb	1		Current game state

MOVECNT	rmb	2		Count of total legal moves

TIMECNT	rmb	2		Timeout counter for inactivity
TIMEOUT	rmb	2		Reset value for timeout counter

	END	START
