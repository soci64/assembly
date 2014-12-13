
wrtbm	lda  #$ff
	bit  wbam
	beq  +
	bpl  +
	bvs  +
	lda  #0
	sta  wbam
	jmp  wrt_bam
+	rts

clrbam	jmp  ptch25
rtch25	ldy  #0
	tya
-	sta  (bmpnt),y
	iny
	bne  -
	rts
	
setbam  lda t0
	pha
	lda t1
	pha
	jmp ptch52
	nop
rtch52  beq  +
        lda  #nodriv
        jsr  cmder2
+       jsr  bam2a
	sta  t0
	txa
	asl  a
	sta  t1
	tax
	lda  track
	cmp  bamis,x
	beq  +
	inx
	stx  t1
	cmp  bamis,x
	beq  +
	jsr  xttu
+	lda  t1
	ldx  drvnum
	sta  bamlu,x
	asl  a
	asl  a
	clc
	adc  #<bami
	sta  bmpnt
	lda  #>bami
	adc  #0
	sta  bmpnt+1
	ldy  #0
	pla
	sta  t1
	pla
	sta  t0
	rts

xttu    ldx  t0
        jsr  redbam
        lda  drvnum
        tax
        asl  a
        ora  bamlu,x
        eor  #1
        and  #3
        sta  t1
        jsr  putbam
        lda  jobnum
        asl  a
        tax
        lda  track
        asl  a
        asl  a
        sta  buftab,x
        lda  t1
        asl  a
        asl  a
        tay
-       lda  (buftab,x)
        sta  bami,y
        lda  #0
        sta  (buftab,x)
        inc  buftab,x
        iny
        tya
        and  #3
        bne  -
        ldx  t1
        lda  track
        sta  bamis,x
        lda  wbam
        bne  +
        jmp  wrt_bam
+
        ora  #$80
        sta  wbam
        rts

putbam  tay
        lda  bamis,y
        beq  +
        pha
        lda  #0
        sta  bamis,y
        lda  jobnum
        asl  a
        tax
        pla
        asl  a
        asl  a
        sta  buftab,x
        tya
        asl  a
        asl  a
        tay
-       lda  bami,y
        sta  (buftab,x)
        lda  #0
        sta  bami,y
        inc  buftab,x
        iny
        tya
        and  #3
        bne -
+	rts

clnbam  lda  drvnum
        asl  a
        tax
        lda  #0
        sta  bamis,x
        inx
        sta  bamis,x
        rts

redbam  .proc
	lda  buf0,x
        cmp  #$ff
        bne  m1
        txa
        pha
        jsr  getbuf
        tax
        bpl  +
        lda  #nochnl
        jsr  cmderr
+
        stx  jobnum
        pla
        tay
        txa
        ora  #$80
        sta  buf0,y
        asl
        tax
        lda  dirtrk
        sta  hdrs,x
        lda  #0
        sta  hdrs+1,x
        jmp  ptch23

m1	and  #15
	sta  jobnum
	rts
	.pend

bam2a   lda  #mxchns
	ldx  drvnum
	bne  +
	clc
	adc  #mxchns+1
+	rts

bam2x   jsr bam2a
	tax
	rts
