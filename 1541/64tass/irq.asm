
sysirq  
        pha             ;  save .a
        txa             ;  save .x
        pha

        tya
        pha             ;  save .y

        lda  ifr1       ;  test if atn
        and  #2
        beq  +          ;  not atn

        jsr  atnirq     ;  handle atn request

+       lda  ifr2       ;  test if timer
        asl  a
        bpl  +          ;  not timer

        jsr  lcc        ;  goto controller

+       pla             ;  restore .y,.x,.a
        tay
        pla
        tax
        pla
        rti
