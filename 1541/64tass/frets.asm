
        jsr  wrtbm
frets   jsr  freuse
        sec
        bne  fre10      ; free already

        lda  (bmpnt),y  ; not free, free it
        ora  bmask,x
        sta  (bmpnt),y
        jsr  dtybam
        ldy  t0         ; point to blks free
        clc
        lda  (bmpnt),y
        adc  #1         ; add one
        sta  (bmpnt),y
        lda  track
        cmp  dirtrk
        beq  use10

fre20   inc  ndbl,x
        bne  fre10

        inc  ndbh,x
fre10   rts

dtybam  ldx  drvnum
        lda  #1
        sta  mdirty,x
        rts

wused   jsr  wrtbm      ; get bam index
usedts  jsr  freuse
        beq  +          ; used, no action

        lda  (bmpnt),y  ; get bits
        eor  bmask,x    ; mark sec used
        sta  (bmpnt),y
        jsr  dtybam     ; set it dirty
        ldy  t0
        lda  (bmpnt),y  ; count -1
        sec
        sbc  #1
        sta  (bmpnt),y  ; save it
        lda  track
        cmp  dirtrk
        beq  use20

use30   lda  ndbl,x
        bne  use10

        dec  ndbh,x
use10   dec  ndbl,x
use20   lda  ndbh,x
        bne  +

        lda  ndbl,x
        jmp  ptch66
        nop

        lda  #dskful
        jsr  errmsg
+       rts

freuse  jsr  setbam
        tya
        sta  temp

bambit  lda  sector     ; get sector bit in bam
        lsr  a          ; sectr/8
        lsr  a
        lsr  a
        sec             ; adjust it
        adc  temp
        tay
        lda  sector     ; get remainder
        and  #$07
        tax             ; bit mask index
        lda  (bmpnt),y
        and  bmask,x
        rts

bmask    .byte  1,2,4,8,16,32,64,128
