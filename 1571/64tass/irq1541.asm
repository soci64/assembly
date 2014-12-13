irq     pha
        txa
        pha
        tya
        pha

        lda  icr
        and  #8
        beq  +          ; fast serial request

        bit  lock       ; locked ?
        bmi  +

        lda  pota1      ; change to 2 Mhz
        ora  #$20
        sta  pota1
        lda  #<jirq
        sta  irqjmp
        lda  #>jirq
        sta  irqjmp+1   ; re-vector irq

        lda  #tim2      ; 8 ms irq's at 2 Mhz - controller irq's
        sta  t1hl2
        sta  t1hc2      ; adjust timers for 2 Mhz
        lda  #0
        sta  nxtst      ; not a vector
        jmp  irq_0

+       lda  ifr1
        and  #2
        beq  +          ;  not atn

        jsr  atnirq     ;  handle atn request

+       lda  ifr2       ;  test if timer
        asl  a
        bpl  +          ;  not timer

        jsr  lcc        ;  goto controller

+       tsx
        lda  $0104,x    ; check processor break flag
        and  #$10
        beq  +

        jsr  lcc

+       pla             ; restore .y, .x, .a
        tay
        pla
        tax
        pla
        rti
