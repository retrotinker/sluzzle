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
	nam	viewg6c8
	ttl	Viewer for 8-color CG6 mode

SCNBASE	equ	$0e00
CSSBASE	equ	$2600

RTOTLEN	equ	$16
RSKPLEN	equ	$06

BLKHGHT	equ	$30		If changed, need to adjust block offset math

	org $2700
START	lda	#$ff		Setup DP register
	tfr	a,dp
	setdp	$ff
	orcc	#$50		Disable interrupts

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

	lbsr	SHUFFLE		Shuffle the blocks...

VINIT	clr	$ffc3		Setup G6C video mode at address $0e00
	clr	$ffc5
	clr	$ffc7
	clr	$ffc9
	clr	$ffcb
	lda	#$e8
	sta	$ff22

VSTART	ldb     $ff01		Disable hsync interrupt generation
	andb	#$fa
	stb     $ff01
	tst	$ff00
	lda     $ff03		Enable vsync interrupt generation
	ora     #$05
	sta     $ff03
	tst	$ff02
	sync			Wait for vsync interrupt
	anda	#$fa		Disable vsync interrupt generation
	sta     $ff03
	tst	$ff02
	orb     #$05		Enable hsync interrupt generation
	stb     $ff01
	tst	$ff00

*
* After the program starts, vsync interrupts aren't used...
*
VSYNC	ldb	#$45		Count lines during vblank and vertical borders
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
* Check for user break (development only)
CHKUART	lda	$ff69		Check for serial port activity
	bita	#$08
	beq	VLOOP
	lda	$ff68
	jmp	CHKINPT
VLOOP	jmp	VSYNC

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

SHUFFJT	bra	SHUFFUP		Jump table, (2 bytes per entry)
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

SHUFFRT	lbsr	MOVERT		Try to move right...
	bcs	SHUFFL1		Failed?  Then try again...
	bra	SHUFFLP

SHUFFLP	dec	1,s
	bne	SHUFFL1

	leas	2,s
	rts

*
* Check control input
*
*	A input value, clobbered
*	B clobbered
*
* NOTE: After control processing, jumps to VSTART instead of VSYNC.
*	Otherwise, would have to track Hsync properly...
*
CHKINPT	cmpa	#$6b
	beq	CKINPUP
	cmpa	#$6a
	beq	CKINPDN
	cmpa	#$68
	beq	CKINPLT
	cmpa	#$6c
	beq	CKINPRT

	cmpa	#$75
	beq	CKUNSCR

	bra	CKINPEX

CKUNSCR	lbsr	UNSCRAM
	bra	CKINPLP

CKINPUP	bsr	MOVEUP
	bra	CKINPGW

CKINPDN	bsr	MOVEDN
	bra	CKINPGW

CKINPLT	bsr	MOVELT
	bra	CKINPGW

CKINPRT	bsr	MOVERT
;	bra	CKINPGW

CKINPGW	ldx	#BLOKMAP	Point at block map
	lda	#$0f		Initialize offset

CKINGW1	cmpa	a,x		Compare offset to value at offset
	bne	CKINPLP		If no match, then loop

	deca			Decrement offset
	bne	CKINGW1		If not zero, keep checking

	cmpa	a,x		Still have to check offset zero
	beq	GAMEWON		Match?  Winner!

CKINPLP	jmp	VSTART

CKINPEX	bsr	UNSCRAM		Unscramble the screen
	jmp	[$fffe]         Re-enter monitor

GAMEWON	lda	$ff69		Check for serial port activity
	bita	#$08
	beq	GAMEWON
	lda	$ff68
	jmp	[$fffe]

*
* Move a block -- multiple entry points
*
*	A,B clobbered
*	X clobbered
*
MOVEUP	lda	#$0c		Verify not on top row
	anda	CURBLOK
	beq	MOVFAIL

	lda	CURBLOK		Subtract 4 from block number
	suba	#$04

	bra	MOVEFIN		Move the block

MOVEDN	lda	#$0c		Verify not on bottom row
	anda	CURBLOK
	cmpa	#$0c
	beq	MOVFAIL

	lda	CURBLOK		Add 4 to block number
	adda	#$04

	bra	MOVEFIN		Move the block

MOVELT	lda	#$03		Verify not on left column
	anda	CURBLOK
	beq	MOVFAIL

	lda	CURBLOK		Subtract 1 from block number
	deca

	bra	MOVEFIN		Move the block

MOVERT	lda	#$03		Verify not on right column
	anda	CURBLOK
	cmpa	#$03
	beq	MOVFAIL

	lda	CURBLOK		Add 1 to block number
	inca

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
	bsr	BLBLOCK

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
	bsr	BLBLOCK

	ldb	,s		Copy contents from block occupying original position
	ldx	#BLOKMAP
	lda	b,x
	lbsr	CPBLOCK

	ldb	,s		Blank the copied block (needed to keep CSS data correct)
	ldx	#BLOKMAP
	lda	b,x
	bsr	BLBLOCK

	lda	,s		Copy contents from block 15 out to original position
	ldx	#BLOKMAP
	ldb	a,x
	lda	#$0f
	lbsr	CPBLOCK

	lda	#$0f		Blank the scratch block
	bsr	BLBLOCK

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
	eora	#$08		Capture x4 of LFSR polynomial
	lsla
	eora	LFSRDAT		Capture X5 of LFSR polynomial
	lsla
	eora	LFSRDAT		Capture X6 of LFSR polynomial
	lsla
	lsla
	eora	LFSRDAT		Capture X8 of LFSR polynomial
	lsla			Move result to Carry bit of CC
	lda	LFSRDAT		Get all of LFSR data
	rola			Shift result into 8-bit LFSR
	sta	LFSRDAT		Store the result
	rts

CURBLOK	rmb	1
LFSRDAT	rmb	1

BLOKMAP	rmb	16

	END	START
