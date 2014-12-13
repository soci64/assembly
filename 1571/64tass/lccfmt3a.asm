
;*   format done, now verify it

otunoteun = vfmt
vfmt
	lda  #200       ;  look at 200 syncs
        sta  trys

m1	lda  #00
        sta  fmhdpt     ; start with first sector again
        lda  sectr      ;  sector counter
        sta  sect
m2	jsr  jsync      ;  find sync
	ldx  #10
        ldy  fmhdpt     ; current header pointer

m3	lda  (hdrpnt),y
-	bit  pota1	;  get header byte
	bmi  -

        cmp  data2
        bne  m5		; error

        iny
        dex
        bne  m3		;  test all bytes

        clc     	; update headr pointer
        lda  fmhdpt
        adc  #10
        sta  fmhdpt

        jmp  m6		;  now test data

m5	dec  trys       ;  test if too many errors
        bne  m1

        lda  #notfnd    ;  too many error
        jmp  jfmterr

m6	jsr  jsync      ;  find data sync

        ldy  #256-topwrt
m7	lda  ovrbuf,y    ; ovr buff offset
-	bit  pota1
	bmi  -

        cmp  data2      ;  compare gcr
        bne  m5		; error

        iny
        bne  m7		;  do all ovrbuf

m9	lda  (bufpnt),y
-	bit  pota1
	bmi  -

        cmp  data2
        bne  m5

        iny
        bne  m9

        dec  sect       ; more sectors to test?
        bne  m2		; yes

;  all sectors done ok

        inc  ftnum      ;  goto next track
        lda  ftnum
	bit  side 	;  what side are we on ?
	bmi  +

        cmp  #36        ;  #tracks max
	.byte skip2
+	cmp  #71
        bcs  +

        jmp  jend       ;  more to do


+	lda  #$ff       ;  clear ftnum
        sta  ftnum

        lda  #$0        ;  clear gcr buffer flag
        sta  gcrflg

        lda  #1         ;  return ok code
        jmp  jerrr
