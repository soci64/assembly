
echksum .byte    $79

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
        sta  pb

        lda  #$1a
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
        jmp  format

ptch11  sta  nodrv
        jmp  setlds

ptch54  cmp  #2         ; error ?
        bcc  +

        cmp  #15        ; no drv condition ?
        beq  +

        jmp  rtch54     ; bad, try another
+       jmp  stl50      ; ok

ptch31  sei
        ldx  #topwrt    ; set stack pointer
        txs
        jmp  rtch31

ptch30
        bit  pa1
        jmp  atnsrv

ptch50  #NODRRD         ; read nodrv,x absolute
        rts

ptch52  ldx  drvnum     ; get offset
        #NODRRD         ; read nodrv,x absolute
        jmp  rtch52

ptch43  lda  #0         ; clr nodrv
        #NODRWR         ; write nodrv,x absolute
        jmp  rtch43

ptch44  tya             ; set/clr nodrv
        #NODRWR         ; write nodrv,x absolute
        jmp  rtch44

ptch51  sta  wpsw,x     ; clr wp switch
        #NODRWR         ; write nodrv,x absolute
        jmp  rtch51
