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
	nam	viewsg24
	ttl	Viewer for SG24 mode

	org $2600
START	lda	#$ff	; Setup DP register
	tfr	a,dp
	setdp	$ff
	orcc	#$50	; Disable interrupts
VINIT	clr	$ffc3	; Setup SG24 video mode at address $0e00
	clr	$ffc5
	clr	$ffc7
	clr	$ffc9
	clr	$ffcb
	clr	$ff22
* Check for user break (development only)
CHKUART	lda	$ff69		Check for serial port activity
	bita	#$08
	beq	VLOOP
	lda	$ff68
	jmp	[$fffe]         Re-enter monitor
VLOOP	jmp	CHKUART
	END	START
