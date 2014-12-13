;***************************
;**                       **
;**     1573  UTILITY     **
;**                       **
;** * * * * * * * * * * * **
;** U0 n B  = slow/fast   **
;**           serial      **
;** U0 n S  = int. dos    **
;** U0 n R  = retries     **
;** U0 n T  = signature   **
;** U0 n V  = verify      **
;** U0 n #  = device      **
;** U0 n I  = IEEE SET    **
;** U0 n M  = memory r/w  **
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

ieees   lda  cmdbuf+4
        sta  sieeeset
        rts

sign    jmp  signature  ; finish up there

chgutl  sei
        ldx  cmdsiz     ; chk cmd size
        cpx  #4
        bcc  utlbad     ; br, error no parameters

        lda  cmdbuf+3
        cmp  #'I'       ; IEEE SET?
        beq  ieees

        lda  cmdbuf+3
        cmp  #'B'       ; bus slow fast change?
        beq  buss

        cmp  #'S'       ; sector interleave ?
        beq  cmdsec

        cmp  #'R'       ; retry
        beq  cmdret

        cmp  #'T'       ; test ROM
        beq  sign

        cmp  #'M'       ; m-r/w
        beq  memb

        cmp  #'V'       ; chk for verify
        beq  verif

        tay
        cpy  #4
        bcc  utlbad

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

buss    lda  fsflag
        and  #all-bit3
        sta  fsflag     ; clear it
        jsr  bitit      ; get bit
        lsr  a
        lsr  a
        lsr  a
        lsr  a          ; shift to appropiate place
        ora  fsflag
        sta  fsflag
        rts

verif   lda  iobyte
        and  #all-bit7
        sta  iobyte     ; clear it
        jsr  bitit      ; get bit
        ora  iobyte
        sta  iobyte
        rts

memb    .proc
; +3      +4      +5            +6
; cmd     r/w   high-address   pages
        sei
        lda  fsflag
        and  #all-clkin ; set clk
        sta  fsflag

        ldy  #0
        sty  ip
        lda  cmdbuf+5
        sta  ip+1

        lda  cmdbuf+4   ; what is it?
        cmp  #'W'       ; write?
        beq  m2

        cmp  #'R'       ; read?
        bne  m5

        jsr  spout      ; output
-       lda  (ip),y
        jsr  hskrd      ; handshake it
        iny
        bne  -

        inc  ip+1

        dec  cmdbuf+6   ; dec pages
        bne  -

        beq  m4         ; bra

m2      lda  pb
        eor  #clkout    ; toggle state of clk
        bit  icr        ; clear pending
        sta  pb
        lda  #8
m3      bit  pb
        bmi  m6         ; attn?

        bit  icr        ; fast byte?
        beq  m3

        lda  sdr        ; get data
        sta  (ip),y
        iny
        bne  m2

        inc  ip+1

        dec  cmdbuf+6
        bne  m2

m4      jmp  endcmd

m5      jmp  utlbad     ; bad

m6      jsr  tstatn
        jmp  m3
        .pend

bitit   lda  cmdbuf+4   ; which ?
        cmp  #'1'
        beq  +

        cmp  #'0'
        beq  +

        jmp  utlbad     ; bad

+       and  #bit0      ; leave bit 0
        clc
        ror  a          ; rotate bit 0 to bit 7
        ror  a
        rts
