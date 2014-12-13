irq     pha     	;  save .a,.x,.y
        txa
        pha
        tya
        pha

	lda  icr	; get status
	tay		; save
	and  fsflag	; lock bit
	and  #bit3	; fast serial byte ?
	beq  +		; br, nope

	lda  fsflag
	ora  #bit5	; set it
	sta  fsflag
+	tya
	and  #bit4	; flag (atn)
	beq  +

	lda  fsflag
	ora  #bit0	; atnpnd
	sta  fsflag
+	tya
	and  #bit1	; timer b (controller timer)
	beq  +

	jsr  jlcc	; controller

+	tsx
	lda  $104,x	; check brk flag
	and  #$10
	beq  +

	jsr  jlcc	; controller

+	pla     	; restore .y,.x,.a
        tay
        pla
        tax
        pla
        rti
