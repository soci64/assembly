
gaptbl  .byte $21,$22,$23,$24,$25,$26,$27,$28,$29
gp2cmd=*-gaptbl
gp2tbl  .byte 2,2,4,6,8,8,11,19,22

; clear at least 6522 bytes written (trk1*1.08%)

ouounrlt = spdchk
spdchk  .proc
	ldy  #0         ; 5100/6153  write 82% sync
	ldx  #28
        jsr  jclear     ; clear whole disk & more
	jsr  fil_syn	; fill with sync
        jsr  kill       ; go read mode

	ldy  #mscnt
-	ldx  #mscnt
-	bit  dskcnt	; try to find sync
	bpl  m5		; got sync

        dex
        bne  -
        dey
        bne  --

m4      lda  #2
        jmp  jfmte10    ; error

m5	ldy  #0
        ldx  #0
-	bit  dskcnt     ; wait for sync to go away
	bpl  -		; got sync

-	lda  dskcnt     ; count time till next sync
        iny     	; lsb not used
        bne  +
        inx     	; msb
+	and  #$80
        bne  -		; br, still no sync

        lda  #0
        sta  tsttrk
	txa		; msb

;*********************************************************
;*           ---  lookup gap2 in table ---               *
;*       x :  21 / 22 / 23 / 24 / 25 / 26 / 27 / 28 / 29 *
;*  gap2   :  02 / 02 / 04 / 06 / 08 / 08 / 0b / 13 / 16 *
;*  speed  : fast -------------------------------- slow  *
;*********************************************************
        ldx  #gp2cmd-1
-	cmp  gaptbl,x   ; lookup timing gap
        beq  +
        dex
        bpl  -
        bmi  m4		; none

+	lda  gp2tbl,x   ; look it up
        sta  dtrck
        rts
        .pend

jformt  .proc
	lda  ftnum      ; test if formating done
        bpl  m1		; yes

        lda  #$60       ; status = stepping
        sta  drvst

	lda  fmtsid
	bne  +

        lda  #01
	.byte  skip2
+       lda  #36
        sta  drvtrk     ; track 1/36
        sta  ftnum      ; track count =1/36
	cmp  #36	; set/clr carry flag
	jsr  set_side

        lda  #256-92    ; step back 45 tracks
        sta  steps

        lda  dskcnt	; phase a
        and  #$ff-03
        sta  dskcnt

        lda  #10
        sta  cnt        ; init error count
        jmp  jend       ; go back to controler

m1	ldy  #00
        lda  (hdrpnt),y
        cmp  ftnum
        beq  +

        lda  ftnum
        sta  (hdrpnt),y
        jmp  jend

+	lda  dskcnt	; check wps
	and  #$10
        bne  toptst	; ok

        lda  #8
        jmp  jfmterr    ; wp error
        .pend

fil_syn .proc
	ldx  #20        ; 20*256 bytes of sync
        lda  #$ff       ; write syncs
-	bit  pota1
	bmi  -

        sta  data2
	bit  byt_clr

        dey
        bne  -
        dex
        bne  -
	rts
	.pend

toptst  .proc
	lda  tsttrk
        bpl  +

        jsr  spdchk

+	lda  dtrck
			;  create header images
        clc
        lda  #>bufs
        sta  hdrpnt+1
        lda  #00
        sta  hdrpnt     ; point hdr point to buf0
        sta  sect

        ldy  #0
m2      lda  hbid       ; hbid cs s t id id 0f 0f
        sta  (hdrpnt),y
        iny
        lda  #00        ; check sum is zero for now
        sta  (hdrpnt),y
        iny

        lda  sect       ; store sector #
        sta  (hdrpnt),y
        iny

        lda  ftnum      ; store track #
        sta  (hdrpnt),y
        iny

        lda  dskid+1    ; store id low
        sta  (hdrpnt),y
        iny

        lda  dskid      ; store id hi
        sta  (hdrpnt),y
        iny

        lda  #$0f       ; store gap1 bytes
        sta  (hdrpnt),y
        iny
        sta  (hdrpnt),y
        iny

        tya     	; save this point
        pha
        ldx  #07
        lda  #00
        sta  chksum     ; zero checksum
-	dey
        lda  (hdrpnt),y
        eor  chksum
        sta  chksum
        dex
        bne  -

        sta  (hdrpnt),y ; store checksum
        pla
        tay     	; restore pointer

        inc  sect       ; goto next sector

        lda  sect       ; test if done yet
        cmp  sectr
        bcc  m2		; more to do

	lda  #3
	sta  bufpnt+1	; $03XX

        jsr  fbtog      ; convert to gcr with no bid char
			; move buffer up 79 bytes

        ldy  #$ff-69    ; for i=n-1 to 0:mem+i+69|:=mem+i|:next
-	lda  (hdrpnt),y ; move buf0 up 69 bytes
        ldx  #69
        stx  hdrpnt
        sta  (hdrpnt),y
        ldx  #00
        stx  hdrpnt
        dey
        cpy  #$ff
        bne  -

        ldy  #68        ; #bytes to move
-	lda  ovrbuf+$bb,y
        sta  (hdrpnt),y
        dey
        bpl  -

;   create data block of zero

        clc
        lda  #>bufs
        adc  #02
        sta  bufpnt+1   ; point to buf2
        lda  #00
        tay     	; init offset
-	sta  (bufpnt),y
        iny
        bne  -


;   convert data block to gcr
;   write image
;   leave it in ovrbuf and buffer

        jsr  chkblk     ; get block checksum
	sta  chksum
        jsr  bingcr

;   start the format now
;   write out sync header gap1
;   data block

        lda  #0         ; init counter
        sta  fmhdpt

        ldx  #6         ; clear 8% of disk
        jsr  jclear     ; clear disk

m7	ldy  #numsyn    ; write 4 gcr bytes

-	bit  pota1
	bmi  -

	lda  #$ff       ; write sync
	sta  data2
	bit  byt_clr	; clear pa latch

        dey
        bne  -

        ldx  #10        ; write out header
        ldy  fmhdpt

-       bit  pota1
	bmi  -

        lda  (hdrpnt),y ; get header data
        sta  data2
	bit  byt_clr
	iny

        dex
        bne  -


; * write out gap1

        ldy  #gap1-2    ; write  gcr bytes

-	bit  pota1
	bmi  -

        lda  #$55
        sta  data2
	bit  byt_clr

	dey
        bne  -

; * write out data block

        lda  #$ff       ; write data block sync
        ldy  #numsyn

-	bit  pota1
	bmi  -

        sta  data2
	bit  byt_clr

	dey
        bne  -

        ldy  #$bb       ; write out ovrbuf
-	bit  pota1
	bmi  -

        lda  ovrbuf,y
        sta  data2
	bit  byt_clr

        iny
        bne  -

-	bit  pota1
	bmi  -

        lda  (bufpnt),y
        sta  data2
	bit  byt_clr

        iny
        bne - 

        lda  #$55       ; write gap2(dtrck)
        ldy  dtrck

-	bit  pota1
	bmi  -

        sta  data2
	bit  byt_clr

        dey
        bne  -


        lda  fmhdpt     ; advance header pointer
        clc
        adc  #10
        sta  fmhdpt

;  done writing sector

        dec  sect       ; go to next on
        beq  m15	; br, no more to do

        jmp  m7

m15	bit  pota1	; wait for last one to write
	bmi  m15

	bit  byt_clr

-	bit  pota1	;wait for last one to write
	bmi  -

	bit  byt_clr

        jsr  kill       ; goto read mode
        .pend
