;***************************
;**                       **
;**     1571  UTILITY     **
;**                       **
;** * * * * * * * * * * * **
;** U0 n S  = int. dos    **
;** U0 n R  = retries     **
;** U0 n T  = signature   **
;** U0 n H  = side        **
;** U0 n #  = device      **
;**                       **
;**     n = ">" ascii     **
;**                       **
;***************************
cmdsec  lda  cmdbuf+4
        sta  secinc
        rts

cmdret  lda  cmdbuf+4
        sta  revcnt
        rts

sign    jmp  signature  ; finish up there

sside   .proc
        sei
        lda  pota1
        and  #$20     ;**TODO**
        bne  utlbad
        lda  cmdbuf+4
        cmp  #'1'
        beq  fst
        cmp  #'0'
        bne  utlbad
        lda  pota1
        and  #$fb     ;**TODO**
        sta  pota1
        cli
        bit  switch
        bpl  ht
        rts

fst     lda  pota1
        ora  #4       ;**TODO**
        sta  pota1
        cli
        bit  switch
        bmi  +
ht      jmp  initdr
+       rts
        .pend

chgutl  ldx  cmdsiz     ; chk cmd size
        cpx  #4
        bcc  utlbad     ; br, error no parameters

        lda  cmdbuf+3
        cmp  #'S'       ; sector interleave ?
        beq  cmdsec

        cmp  #'R'       ; retry
        beq  cmdret

        cmp  #'T'       ; test ROM
        beq  sign

        cmp  #'M'       ; mode
        beq  smode

        cmp  #'H'
        beq  sside
        jmp  ptch61
rtch61  bcc  utlbad

        cpy  #31
        bcs  utlbad

        lda  #$40       ; change device #
        sta  tlkadr     ; clear old

        lda  #$20
        sta  lsnadr     ; *

        tya
        clc
        adc  tlkadr
        sta  tlkadr     ; new
        tya
        clc
        adc  lsnadr
        sta  lsnadr     ; new
        rts

utlbad  lda  #badcmd
        jmp  cmderr

smode   sei
        lda  cmdbuf+4
        cmp  #'1'
        beq  +
        cmp  #'0'
        bne  utlbad
        lda  pota1
        and  #$df     ;**TODO**
        sta  pota1
        jsr  jslowd
        jsr  ptch10
        lda  lock
        ora  #$80
        sta  lock
        cli
        bit  switch
        bpl  chn
        rts

+       lda  pota1
        ora  #$20     ;**TODO**
        sta  pota1
        jsr  jslowd
        lda  #<jirq
        sta  irqjmp
        lda  #>jirq
        sta  irqjmp+1
        lda  #$40
        sta  t1hl2
        sta  t1hc2
        lda  lock
        and  #$7f
        sta  lock
        lda  #0
        sta  nxtst
        cli
        bit  switch
        bmi  +
chn     jmp  initdr
+       rts

