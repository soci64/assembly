
jseak   .proc
	lda  #90        ; search 90 headers
        sta  tmp

m1	jsr  jsync      ; find sync char

m2	bit  pota1	; wait for block id
	bmi  m2

        lda  data2      ; clear pa1 in the gate array
        cmp  #$52       ; test if header block
        bne  m3		; not header

        sta  stab,y   	; store 1st byte
        iny

m4	bit  pota1
	bmi  m4

        lda  data2
        sta  stab,y     ; store gcr header off

        iny
        cpy  #8         ; 8 gcr bytes in header
        bne  m4

        jsr  jcnvbin    ; convert header in stabof to binary in header

        ldy  #4         ; compute checksum
        lda  #0

m5	eor  header,y
        dey
        bpl  m5

        cmp  #0         ; test if ok
        bne  m9		; nope, checksum error in header

        lda  header+2
        sta  drvtrk

        lda  job        ; test if a seek job
        cmp  #$30
        beq  m6

        lda  dskid
        cmp  header
        bne  m8

        lda  dskid+1
        cmp  header+1
        bne  m8

	jmp  m7		; find best sector to service

m3	dec  tmp        ; search more?
        bne  m1		; yes

        lda  #2         ; cant find a sector
        jsr  jerrr

m6	lda  header     ; sta disk id's
        sta  dskid      ; *
        lda  header+1
        sta  dskid+1

	lda  #1         ; return ok code
        .byte    skip2

m8	lda  #11        ; disk id mismatch
        .byte    skip2

m9	lda  #9         ; checksum error in header
        jmp  jerrr

m7	lda  #$7f       ; find best job
        sta  csect

        lda  header+3   ; get upcoming sector #
        clc
        adc  #2
        cmp  sectr
        bcc  m10

        sbc  sectr      ; wrap around

m10	sta  nexts      ; next sector

        ldx  #numjob-1
        stx  jobn

        ldx  #$ff

m12	jsr  jsetjb
        bpl  m11

        and  #drvmsk
        cmp  cdrive     ; test if same drive
        bne  m11	; nope

        ldy  #0         ; test if same track
        lda  (hdrpnt),y
        cmp  tracc
        bne  m11

	lda  job
	cmp  #execd
	beq  m13

        ldy  #1
        sec
        lda  (hdrpnt),y
        sbc  nexts
        bpl  m13

        clc
        adc  sectr

m13	cmp  csect
        bcs  m11

        pha     	; save it
        lda  job
        beq  m16	; must be a read

        pla
        cmp  #wrtmin    ; +if(csect<4)return;
        bcc  m11	; +if(csect>8)return;

        cmp  #wrtmax
        bcs  m11

m15	sta  csect      ; its better
        lda  jobn
        tax
        clc
        adc  #>bufs
        sta  bufpnt+1

        bne  m11

m16	pla
        cmp  #rdmax     ; if(csect>6)return;
        bcc  m15

m11	dec  jobn
        bpl  m12

        txa     	; test if a job to do
        bpl  m14

        jmp  jend       ; no job found

m14	stx  jobn
        jsr  jsetjb
        lda  job
        jmp  jread
        .pend

jcnvbin lda  bufpnt
        pha
        lda  bufpnt+1
        pha     	; save buffer pntr

        lda  #<stab	; stab offset
        sta  bufpnt     ; point at gcr code
        lda  #>stab
        sta  bufpnt+1

        lda  #0
        sta  gcrpnt

        jsr  jget4gb    ; convert 4 bytes

        lda  btab+3
        sta  header+2

        lda  btab+2
        sta  header+3

        lda  btab+1
        sta  header+4


        jsr  jget4gb    ; get 2 more

        lda  btab       ; get id
        sta  header+1
        lda  btab+1
        sta  header

        pla
        sta  bufpnt+1   ; restore pointer
        pla
        sta  bufpnt
        rts
