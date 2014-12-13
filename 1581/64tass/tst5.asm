; init to default parms
intdsk
        lda  #bit0      ; set?
        bit  wpsw
        beq  +

        eor  #bit0
        sta  wpsw
        jsr  psetdef    ; set physical parms
        jmp  setdef     ; reg parms
+       rts
