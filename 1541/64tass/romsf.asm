
        *=rom           ; +$100 rom patch area
        .byte    $97
cchksum .byte    $e0
        .text 'COPYRIGHT (C)1982,1985,1987 COMMODORE ELECTRONICS, LTD.',13
        .text 'ALL RIGHTS RESERVED',13

clearp  lda  pcr2       ;  enable write
        and  #$ff-$e0
        ora  #$c0
        sta  pcr2
;
        lda  #$ff       ;  make port an output
        sta  ddra2
;
        lda  #$55       ;  write a 1f pattern
        sta  data2
;
        ldx  #3         ;  $3*256 chars
        ldy  #00
-       bvc  *
        clv
        dey
        bne  -
;
        dex
        bne  -
;
        rts

ptch15  ldy  lindx
        jmp  rnget2

ptch41  sta  nbkl,x
        sta  nbkh,x
        lda  #0
        sta  lstchr,x
        rts

ptch67
        php
        sei
        lda  #0
        sed
-       cpx  #0
        beq  +

        clc
        adc  #1
        dex
        jmp  -
+       plp
        jmp  hex5

ptch66
        cmp  #3
        bcs  +

        lda  #dskful
        jsr  errmsg

+       lda  #1
        rts

*=rom+256               ; c0 patch space
