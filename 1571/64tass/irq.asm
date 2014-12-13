;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

sysirq  jmp  (irqjmp)	;  irq vector ***rom ds 02/01/85***

;	pha		;  save .a
;	txa		;  save .x
;	pha

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

        tya
        pha      	;  save .y

        lda  ifr1       ;  test if atn
        and  #2
        beq  +		;  not atn

        jsr  atnirq     ;  handle atn request

+	lda  ifr2       ;  test if timer
        asl  a
        bpl  +		;  not timer

        jsr  lcc        ;  goto controller

+	pla     	;  restore .y,.x,.a
        tay
        pla
        tax
        pla
        rti
