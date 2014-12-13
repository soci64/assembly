;   SIGNATURE ANALYSIS
;   POLYNOMIAL:   X^16 + X^12 + X^5 + 1
;   INITIALIZED STATE: FFFFh

signature .proc
	php
	sei
	lda  zpvar
	pha
	lda  zpvar+1
	pha
	lda  zpvar+2
	pha
	lda  zpvar+3
	pha
	lda  zpvar+4
	pha
	lda  zpvar+5
	pha
	lda  zpvar+6
	pha
	lda  zpvar+7
	pha
	lda  zpvar+8
	pha

	lda  #$ff
	sta  zpvar+5    ; sig_lo
	sta  zpvar+6    ; sig_hi
	lda  #<signature_lo
	sta  zpvar+7
	lda  #>signature_lo
	sta  zpvar+8

	ldy  #2
m1      lda  (zpvar+7),y
	sta  zpvar+1    ; msb
	tax
	iny
	lda  (zpvar+7),y
	sta  zpvar      ; lsb

	txa
	ldx  #16
m2      sta  zpvar+2
	clc
	rol  zpvar
	rol  zpvar+1
	lda  #0
	sta  zpvar+3
	sta  zpvar+4

	bit  zpvar+2
	bpl  +

	lda  #$21
	sta  zpvar+3
	lda  #$10
	sta  zpvar+4
+       bit  zpvar+6
	bpl  +

	lda  zpvar+3
	eor  #$21
	sta  zpvar+3
	lda  zpvar+4
	eor  #$10
	sta  zpvar+4
+       clc
	rol  zpvar+5
	rol  zpvar+6
	lda  zpvar+5
	eor  zpvar+3
	sta  zpvar+5
	lda  zpvar+6
	eor  zpvar+4
	sta  zpvar+6
	lda  zpvar+1
	dex
	bne  m2

	iny
	bne  m1

	inc  zpvar+8
	bne  m1

	ldy  zpvar+5
	ldx  zpvar+6

	pla
	sta  zpvar+8
	pla
	sta  zpvar+7
	pla
	sta  zpvar+6
	pla
	sta  zpvar+5
	pla
	sta  zpvar+4
	pla
	sta  zpvar+3
	pla
	sta  zpvar+2
	pla
	sta  zpvar+1
	pla
	sta  zpvar

	cpy  signature_lo
	bne  +

	cpx  signature_hi
	bne  +

	plp
	rts


+       ldx  #3         ; error
	stx  temp
	jmp  perr       ; later gator...
	.pend
