;format routines
format  lda  startrk	; get logical starting track
        sta  track
        lda  #0
        sta  sector
        jsr  seth       ; set up header/jobn=0

	jsr  psetdef	; set defaults

	lda  #restore_dv
	jsr  strobe_controller

	ldy  fillbyte
	lda  #0
	sta  fillbyte

        lda  #formatdk_dv
	jsr  strobe_controller
	sty  fillbyte
        cmp  #2         ; test for errors
        bcc  +		; no error..

        jmp  error      ; x= job number

+	rts
