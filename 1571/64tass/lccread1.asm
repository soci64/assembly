
;=============================================================
;=     8    =     8     =     8     =     8     =     8      =
;=============================================================
;   (5) (3  + 2)  (5) (1+  4)   (4  +1) (5)  (2 +  3)   (5)
;    a      b      c    d           e    f      g        h
;=============================================================

;    read in track,sector specified
;    in header

	.align 256	;  even page

jdstrt  jsr  jsrch      ;  find header
        jmp  jsync      ;  and then data block sync

jread   cmp  #0         ;  test if read job
        beq  jread01    ;  go test if write
        jmp  jwright

jread01 .proc
	jsr  jdstrt     ;  find header and start reading data
			; sync routine sets y to 0

-	bit  pota1	;  4
	bmi  -		;  3 + 2

        lda  data2      ;  4
        tax     	;  2   reg x = xxxxx000
        lda  gcrtb1,x   ;  4   nibble a
        sta  btab	;  3
        txa		;  2
        and  #%00000111 ;  2
        sta  btab+1	;  3   extract 3 bits nibble b

-	bit  pota1	;  4
	bmi  -		;  3 + 2

        lda  data2      ;  4
        sta  btab+2	;  3
        and  #%11000000 ;  2   extract 2 bits nibble b
        ora  btab+1	;  3
        tax     	;  2   reg x = xx000xxx
        lda  gcrtba,x   ;  4   nibble b
        ora  btab	;  3
        pha             ;  3
        jmp  m5		;  3

;********************************************************************

m3	bit  pota1	;  4
	bmi  m3		;  3 + 2

        lda  data2      ;  4
        tax     	;  2   reg x = xxxxx000
        lda  gcrtb1,x   ;  4   nibble a
        sta  btab	;  3
	txa		;  2
        and  #%00000111 ;  2
        sta  btab+1	;  3   extract 3 bits nibble b

-	bit  pota1	;  4
	bmi  -		;  3 + 2

	lda  data2      ;  4
        sta  btab+2	;  3
        and  #%11000000 ;  2
        ora  btab+1	;  3
        tax             ;  2   reg x = xx000xxx
        lda  gcrtba,x   ;  4   nibble b
        ora  btab	;  3
        sta  (bufpnt),y ;  6
        iny     	;  2
        beq  m6		;  2

m5	lda  btab+2	;  3
        tax     	;  2   reg x = 00xxxxx0
        lda  gcrtb2,x   ;  4   nibble c
        sta  btab	;  3
	txa		;  2
        and  #%00000001 ;  2
        sta  btab+2	;  3   extract 1 bits nibble d

-	bit  pota1	;  4
	bmi  -		;  3 + 2

        lda  data2      ;  4
        sta  btab+3	;  3
        and  #%11110000 ;  2
        ora  btab+2	;  3
        tax     	;  2   reg x = xxxx000x
        lda  gcrtbd,x   ;  4   nibble d
        ora  btab	;  3
        sta  (bufpnt),y ;  6
        iny     	;  2
        lda  btab+3	;  3
        and  #%00001111 ;  2
        sta  btab+3	;  3   extract 4 bits nibble e

-	bit  pota1	;  4
	bmi  -		;  3 + 2

        lda  data2      ;  4
        sta  chksum	;  3
        and  #%10000000 ;  2
        ora  btab+3	;  3
        tax     	;  2   reg x = x000xxxx
        lda  gcrtbe,x   ;  4   nibble e
        sta  btab	;  3
        lda  chksum	;  3
        tax     	;  2   reg x = 0xxxxx00
        lda  gcrtb3,x   ;  4   nibble f
        ora  btab	;  3
        sta  (bufpnt),y ;  6
        iny     	;  2
	txa		;  2
        and  #%00000011 ;  2
        sta  chksum	;  3   extract 2 bits nibble g

-	bit  pota1	;  4
	bmi  -		;  3 + 2

        lda  data2      ;  4
        sta  btab+1	;  3
        and  #%11100000 ;  2
        ora  chksum	;  3
        tax     	;  2   reg x = xxx000xx
        lda  gcrtbg,x   ;  4   nibble g
        sta  btab	;  3
        lda  btab+1	;  3
        tax     	;  2   reg x = 000xxxxx
        lda  gcrtb4,x   ;  4   nibble h
        ora  btab	;  3
        sta  (bufpnt),y ;  6
        iny     	;  2
        jmp  m3		;  4

;*******************************************************************

m6	lda  btab+2	;  3
        tax     	;  2   reg x = 00xxxxx0
        lda  gcrtb2,x   ;  4   nibble c
        sta  btab	;  3
	txa		;  2
        and  #%00000001 ;  2
        sta  btab+2	;  3

-	bit  pota1	;  4
	bmi  -		;  3 + 2

        lda  data2      ;  4
        and  #%11110000 ;  2
        ora  btab+2	;  3
        tax     	;  2   reg x = xxxx000x
        lda  gcrtbd,x   ;  4   nibble d
        ora  btab	;  3
        sta  btab+1	;  3   store off cs byte

        pla     	; retrieve first byte off of disk
        cmp  dbid       ; see if it is a 7
        bne  m12	; br, nope


	jsr  chkblk     ; calc checksum
        cmp  btab+1
        beq  m11

        lda  #5         ; data block checksum error
        .byte    skip2
m12	lda  #4
        .byte    skip2

m11	lda  #1         ; read data block ok
        jmp  jerrr
        .pend

jsrch   .proc
	lda  dskid      ; get master id for the drive
        sta  header
        lda  dskid+1
        sta  header+1

        ldy  #0         ; get track,sectr
        lda  (hdrpnt),y
        sta  header+2
        iny
        lda  (hdrpnt),y
        sta  header+3

        lda  #0
        eor  header
        eor  header+1
        eor  header+2
        eor  header+3
        sta  header+4   ; store the checksum
        jsr  conhdr     ; convert header to gcr

        lda  #90        ; search 90 sync chars
        sta  tmp
m1	jsr  jsync      ; find sync

m2	lda  stab,y     ; what it should be
-	bit  pota1
	bmi  -

        cmp  data2      ; is it the same .cmp absolute
        bne  m4		; nope

        iny
        cpy  #8
        bne  m2

        rts

m4	dec  tmp        ; try again
        bne  m1

        lda  #2         ; cant find this header
	jmp  jerrr
	.pend

jsync   ldx  #15
	ldy  #0		; s/w timers ok
-	bit  dskcnt	; sync a synch ?
	bpl  +

	dey
	bne  -

	dex
	bne  -

	lda  #3
	jmp  jerrr	; sync error

+	lda  data2	; clear pa latch
	ldy  #0         ; clear pointer
        rts
