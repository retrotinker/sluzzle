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

	lda	#$1f		Blank-out bottom-rightmost block
	lbsr	BLBLOCK

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
	jmp	[$fffe]         Re-enter monitor
VLOOP	jmp	VSYNC

*
* Blank-out a block
*
*	A input block to blank, clobbered
*	X,B clobbered
*
BLBLOCK	pshs	a
	anda	#$07		Determine data offset for block =
	lsla				screenbase +
	lsla				(block / 8) * 1536 +
	pshs	a			(block % 8) * 4
	lda	1,s
	anda	#$f8
	clrb
	lsra
	rorb
	pshs	d
	lsra
	rorb
	addd	,s
	leas	2,s
	addb	,s
	bcc	BLBLCK1
	inca
BLBLCK1	ldx	#SCNBASE
	leax	d,x

BLRWDAT	lda	#BLKHGHT	Init row counter
	ldb	#$aa		Load blank-out data
BLRWDT1	stb	,x+		Fill rows w/ blank-out data
	stb	,x+
	stb	,x+
	stb	,x+
	leax	$1c,x
	deca
	bne	BLRWDT1

BLRWINS	ldx	#HROW0ST	Determine code offset for block =
	lda	1,s			codebase +
	anda	#$f8			(block / 8) * 48 * len +
	lsla				(block % 8) * 2
	pshs	a
	lsla
	adda	,s
	ldb	#RTOTLEN
	mul
	leax	d,x
	leas	1,s

	lda	1,s
	anda	#$07
	lsla
	leax	a,x

	lda	#BLKHGHT	Init row counter
	ldb	#$97		Load blank-out instruction
BLRWIN1	stb	,x		Fill rows w/ blank-out instruction
	leax	RTOTLEN,x
	deca
	bne	BLRWIN1

BLRWCSS	ldx	#CSSBASE	Determine CSS data offset for block =
	ldb	1,s			CSSbase + (block / 8) * 48
	clra
	andb	#$f8
	lslb
	pshs	b
	lslb
	addb	,s
	leax	d,x
	leas	1,s

	ldb	#$80		Init CSS data mask
	lda	1,s
	anda	#$07		Calculate block bit position
BLRWCS1	beq	BLRWCS2		Shift CSS data mask for block
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

	leas	3,s		Free remaining stack data
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
	anda	#$07		Determine data offset for src block =
	lsla				screenbase +
	lsla				(block / 8) * 1536 +
	pshs	a			(block % 8) * 4
	lda	2,s
	anda	#$f8
	clrb
	lsra
	rorb
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
	anda	#$07		Determine data offset for dest block =
	lsla				screenbase +
	lsla				(block / 8) * 1536 +
	pshs	a			(block % 8) * 4
	lda	1,s
	anda	#$f8
	clrb
	lsra
	rorb
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
CPRWDT1	ldb	,x+		Copy rows from source to dest
	stb	,y+
	ldb	,x+
	stb	,y+
	ldb	,x+
	stb	,y+
	ldb	,x+
	stb	,y+
	leax	$1c,x
	leay	$1c,y
	deca
	bne	CPRWDT1

CPRWINS	ldx	#HROW0ST	Determine code offset for src block =
	lda	1,s			codebase +
	anda	#$f8			(block / 8) * 48 * len +
	lsla				(block % 8) * 2
	pshs	a
	lsla
	adda	,s
	ldb	#RTOTLEN
	mul
	leax	d,x
	leas	1,s

	lda	1,s
	anda	#$07
	lsla
	leax	a,x

	ldy	#HROW0ST	Determine code offset for dest block =
	lda	,s			codebase +
	anda	#$f8			(block / 8) * 48 * len +
	lsla				(block % 8) * 2
	pshs	a
	lsla
	adda	,s
	ldb	#RTOTLEN
	mul
	leay	d,y
	leas	1,s

	lda	,s
	anda	#$07
	lsla
	leay	a,y

	lda	#BLKHGHT	Init row counter
CPRWIN1	ldb	,x		Copy instruction for src row...
	stb	,y		...to destination row
	leax	RTOTLEN,x	Advance src code offset
	leay	RTOTLEN,y	Advance dest code offset
	deca			Decrement row counter
	bne	CPRWIN1

CPRWCSS	ldx	#CSSBASE	Determine src CSS data offset for block =
	ldb	1,s			CSSbase + (block / 8) * 48
	clra
	andb	#$f8
	lslb
	pshs	b
	lslb
	addb	,s
	leax	d,x
	leas	1,s

	ldb	#$80		Init src CSS data mask
	lda	1,s
	anda	#$07		Calculate block bit position
CPRWCS1	beq	CPRWCS2		Shift CSS data mask for block
	lsrb
	deca
	bra	CPRWCS1

CPRWCS2	pshs	b		Save src CSS data mask

	ldy	#CSSBASE	Determine dest CSS data offset for block =
	ldb	1,s			CSSbase + (block / 8) * 48
	clra
	andb	#$f8
	lslb
	pshs	b
	lslb
	addb	,s
	leay	d,y
	leas	1,s

	ldb	#$80		Init dest CSS data mask
	lda	1,s
	anda	#$07		Calculate block bit position
CPRWCS3	beq	CPRWCS4		Shift CSS data mask for block
	lsrb
	deca
	bra	CPRWCS3

CPRWCS4	pshs	b		Save dest CSS data mask

	lda	#BLKHGHT	Setup CSS data row counter
CPRWCS5	ldb	,x+		Load src CSS data, increment offset
	andb	1,s		Mask for relevant bit
	beq	CPRWCS6		If not set, skip setting dest (presumed clear)
	ldb	,y		Load dest CSS data
	orb	,s		Set relevant bit
	stb	,y		Store dest CSS data
CPRWCS6	leay	1,y		Increment dest CSS data offset
	deca			Decrement row counter
	bne	CPRWCS5

	leas	4,s
	rts

	END	START
