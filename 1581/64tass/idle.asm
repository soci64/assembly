idle    .proc
        sei
        lda  #atna
        sta  pb         ; release serial bus
        cli             ; wait for something to do..
        lda  cmdwat     ; any commands pending ?
        beq  m1         ; no command waiting

        lda  #0
        sta  cmdwat
        jsr  parsxq     ; parse and execute command
        jsr  spinp      ; fast serial input
m1
        cli
        lda  #bit0
        bit  fsflag     ; any attentions pending ?
        beq  +

        jmp  jatnsrv    ; service the attention

+       lda  dirty      ; dirty?
        bne  m5

        ldy  #numjob+1  ; include bams
        ldx  #14        ; max user sa
-       lda  lintab,x   ; active ?
        cmp  #$ff
        bne  m5         ; yes

        dey
        bmi  +

        lda  jobs,y
        bmi  m5         ; it's active

+       dex
        bpl  -

        lda  ledprint
        and  #all-act_led
        sta  ledprint   ; no activity
        jmp  m6

m5      lda  ledprint
        ora  #act_led
        sta  ledprint   ; activity led on

m6      lda  wpsw       ; disk changed ?
        beq  +          ; no

        jsr  cldchn     ; close them..
+       ldx  erword
        beq  +          ; no error flashing

        lda  ledprint
        ora  #pwr_led
        sta  ledprint
        bne  m9         ; bra

+       lda  ledprint
        and  #all-pwr_led
        sta  ledprint

m9      lda  sieeetim   ; serial bus last accessed
        bne  +

; dump the cache track buffer
        jsr  ieeedumptrk
+       jmp  m1
        .pend

ieeedumptrk
        lda  dirty      ; dirty flag set?
        beq  +

        lda  #bit6
        sta  jobrtn     ; no check t&s flag
        lda  jobnum
        pha
        lda  track
        pha
        lda  sector
        pha
        ldx  #>(bam1-buff0)
        jsr  jdumptrk   ; special case no buffer op to set dirty
        pla
        sta  sector
        pla
        sta  track
        pla
        sta  jobnum
+       rts
