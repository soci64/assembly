
jfmterr dec  cnt        ;  test for retry
        beq  jfmte10

        jmp  jend

jfmte10 ldy  #$ff
        sty  ftnum      ;  clear format

        iny
        sty  gcrflg

        jmp  jerrr

; this subroutine will be called with x*255 for amount of chars written

jclear  lda  pcr2	;  enable write
	and  #$ff-$e0   ;  wr mode=0
	ora  #$c0
	sta  pcr2

        lda  #$ff       ;  make port an output
        sta  ddra2      ;  clear pending

        lda  #$55       ;  write a 1f pattern
        ldy  #00
-	bit  pota1
	bmi  -

	bit  byt_clr
        sta  data2

        dey
        bne  -

        dex     	;  dex amount * 255
        bne  -

        rts
