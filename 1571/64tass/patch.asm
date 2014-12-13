
dchksum .byte $ff

jnmi    jmp (vnmi)

pea7a   sta  ledprt
        sta  ddrb2
        jmp  rea7d

slowd   txa             ; only affect .a
        ldx  #5         ; insert 20us of delay with this routine
-       dex
        bne  -

        tax
        rts

patch4  jsr  clklo
        jmp  dathi

nnmi    .proc
        lda  cmdbuf+2   ; new nmi routine check for
        cmp  #'-'
        beq  m1         ; if ui- then no delay

        sec
        sbc  #'+'
        bne  jnmi       ; if not ui+ then must be a real ui command

m1      sta  slflag     ; set/clr slow flag
        rts
        .pend

patch5  stx  ddra1
        lda  #2
        jmp  ptch22

ptch22r lda  #$1a
        sta  ddrb1
        jmp  dkit10

patch6
-       lda  pb
        and  #1
        bne  -
        lda  #1
        sta  timer1
        jmp  acptr.rptch6

patch7  lda  #255
        sta  ftnum
        lda  pota1
        and  #$20
        bne  +
        lda  #36
        .byte skip2
+       lda  #71
        sta  maxtrk
        jmp  ptch28

patch9  .proc
        tya
        pha
        ldy  #100
-       lda  pota1
        ror  a
        php
        lda  pota1
        ror  a
        ror  a
        plp
        and  #$80
        bcc  +
        bpl  m2
        bmi  m1
+       bmi  m2
m1      dey
        bne  -
        bcs  m2
        lda  dskcnt
        and  #3
        bne  m2
        lda  adrsed
        bne  m2
        pla
        tay
        lda  #0
        sta  steps
        jmp  end33
m2      pla
        tay
        inc  steps
        ldx  dskcnt
        dex
        jmp  pppppp
        .pend

ptch10  jsr  cntint
        lda  #5
        sta  cpmit
        lda  #<irq
        sta  irqjmp
        lda  #>irq
        sta  irqjmp+1
        lda  #36
        sta  maxtrk
        clc
        jmp  set_side

ptch11  sta  nodrv
        jmp  setlds

ptch12  sta  adrsed
        jmp  hedoff

ptch13  jsr  hedoff
        lda  #0
        sta  adrsed
        rts

ptch15  ldy  lindx
        jmp  rndget
