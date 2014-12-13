
; test 256k-bit of rom
; using signature generation test bits 15,  11,  8,  6
; exit if ok

signature .proc
        php
        sei             ; no irqs
        ldx  #0
        stx  $00        ; sig_lo
        stx  $01        ; sig_hi
        lda  #3         ; skip checksum & signature bytes
        sta  ip         ; even page
        tay
        lda  #$80       ; start at $8000
        sta  ip+1       ; high order
m2      lda  (ip),y     ; get a byte
        sta  $02
        ldx  #8         ; 8 bits in a byte right?
m3      lda  $02
        and  #1         ; bit 0
        sta  $03
        lda  $01        ; get sig_hi
        bpl  +          ; test bit 15

        inc  $03
+       ror  a
        bcc  +          ; test bit 8

        inc  $03
+       ror  a
        ror  a
        ror  a
        bcc  +

        inc  $03
+       lda  $00        ; sig_lo
        rol  a
        rol  a
        bcc  +          ; test bit 6

        inc  $03
+       ror  $03        ; sum into carry
        rol  $00        ; carry into bit 0 low byte
        rol  $01        ; carry into bit 0 high byte

        ror  $02        ; ready for next bit
        dex
        bne  m3

        inc  ip
        bne  m2

        inc  ip+1       ; next page
        bne  m2

        dey
        dey
        dey             ; .y = 0

        lda  $00
        cmp  signature_lo
        bne  sig_err

        lda  $01
        cmp  signature_hi
        bne  sig_err

        sty  $00        ; clear
        sty  $01
        sty  $02
        sty  $03

        plp
        rts


sig_err ldx  #3         ; 4 blinks
        stx  temp
        jmp  perr       ; bye bye ....
        .pend
