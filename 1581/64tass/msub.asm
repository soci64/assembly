;

resetim

	lda  ctltimh
	sta  timb_h     ; set high
	lda  ctltiml
	sta  timb_l     ; set low
	lda  #bit4+bit0 ; start timer b
	sta  crb
	rts

;

moton   lda  pa
	and  #all-mtr_on
	sta  pa
	rts

;

motoff  lda  pa
	ora  #mtr_on
	sta  pa
	rts

;

ledon   lda  pa         ; turn on led
	and  #all-act_led
	sta  pa
	rts

;

ledoff  lda  pa         ; turn led off
	ora  #act_led
	sta  pa
	rts

;

xms     jsr  onems      ; delay 1 ms
	dey
	bne  xms

	rts

;

one_6   ldx  #3         ; 1.6 mS
	.byte skip2
onems   ldx  #2         ; 1.0 mS
	clc
	lda  #$6f
onems1  adc  #1
	bne  onems1

	dex
	bne  onems1

	rts

;


wdunbusy

	lda  #bit0
	#WDTEST
-       bit  WDSTAT
	bne  -

	rts

;

wdbusy
	#WDTEST
	sta  WDCMD      ; send command

	lda  #bit0
	#WDTEST
-       bit  WDSTAT
	beq  -

	jmp  delay16

;

; Read Address Routine

;  0       1      2           3         4    5 + header
;  ^       ^      ^           ^         ^    ^
; track  side#  sector  sector_length  crc  crc

        .align 256

seekhdr .proc
	ldx  #5         ; invalidate header
-       txa
	sta  header,x
	dex
	bpl  -

	jsr  tstfoready ; check drive status
	bcs  m5

	lda  wdreadaddress
	jsr  wdbusy     ; start cmd

	ldx  #0
	ldy  #6
	#WDTEST          ; chk address
-       lda  WDSTAT
	and  #3
	lsr  a
	bcc  +          ; no address mark found
	beq  -

	lda  wddat      ; get data
	sta  header,x   ; put in header
	inx
	dey
	bne  -

+       jsr  getwdstat  ; get status
	beq  +          ; ok

	sec
	.byte skip1
+       clc
	bit  iobyte     ; bit-6 chck crc
	bvc  +

	jmp  crcheader  ; check crc in software

m5      lda  #$03       ; no disk
	sta  controller_stat
	sec
+       rts
        .pend
;

getwdstat

	jsr  wdunbusy   ; wait for unbusy first

;

wdstatus

	php
	#WDTEST
	lda  WDSTAT     ; get status
	lsr  a
	lsr  a
	lsr  a
	bcs  +

	and  #bit3+bit1+bit0
	tax
	plp             ; restore carry
	lda  wdtrans,x
	.byte skip2
+       lda  #9
	sta  controller_stat
	lda  controller_stat
	rts

wdtrans .byte 0,5,2,0,0,0,0,0,8

;

start_mtr .proc

	lda  drvst      ; motor at least running ?
	bmi  m2

	and  #bit5+bit4 ; test running and timeout flags
	bne  m1         ; br, it's alive

	jsr  moton      ; turn it on
	lda  motoracc
	sta  acltim     ; set acceleration time

	lda  #$a0       ; accelerating
	.byte skip2
m1      lda  #$20       ; running now
	sta  drvst
m2      rts
        .pend
;

wait_mtr .proc
	lda  drvst      ; check for acceleration bit
	bpl  +

	lda  acltim     ; timeout?
	bne  m4

+       lda  pa         ; disk changed?
	and  #disk_change
	bne  m3

	lda  wdstepin   ; clear it
	jsr  wdbusy
	jsr  wdunbusy
	lda  wdstepout
	jsr  wdbusy
	jsr  wdunbusy
	ldy  setval
	jsr  xms        ; settle...it
	lda  pa         ; new disk or no disk?
	and  #disk_change
	bne  m3

-       lda  #$03       ; no disk
	jmp  errr

m3      jsr  tstfoready ; check drive status
	bcs  -

	lda  #$20
	sta  drvst
	rts             ; running

m4      pla             ; remove return address
	pla             ; *
	jmp  end_ctl    ; do acceleration stuff
        .pend



tstfoready

	ldy  #30        ; debounce
-       lda  pa         ; is drive ready?
	and  #drv_rdy
	bne  +

	dey
	bne  -

	clc
	.byte skip1
+       sec
	rts

;

errr

	ldy  nextjob    ; return job code
	sta  jobs,y

	ldy  #bit7
	cmp  #2
	bcc  +

	lda  #0
	sta  dirty      ; clear it
	sty  cachetrk   ; uninit
+       sty  nextjob    ; clear entry

	ldy  #numjob
	.byte skip2
back    ldy  nextjob    ; original
	lda  drvst      ; motor doing anything?
	beq  erret

	and  #$10
	bne  erret      ; already timeout

	lda  drvst
	ora  #$10       ; start motor timeout
	sta  drvst
	lda  #all
	sta  acltim
	lda  #4
	sta  acltim+1   ; timeout

erret   ldx  savsp      ; restore sp
	txs
	jmp  lcc0       ; continue

;

end_ctl .proc
	ldx  savsp      ; get sp
	inx
	inx
	lda  $104,x
	and  #$10
	bne  m9

	lda  sieeetim   ; count to zero
	beq  +

	dec  sieeetim   ; decrement serial bus timer

+       lda  ledprint
	and  #pwr_led   ; blink?
	beq  +

	dec  blink      ; blink yet?
	bpl  +

	lda  #9         ; toggle it & start timer
	sta  blink

	lda  pa
	eor  #pwr_led   ; toggle power led
	sta  pa

+       lda  ledprint   ; activity led on?
	and  #act_led
	and  ledprint
	sta  ctmp
	lda  pa         ; save pa
	and  #all-act_led
	ora  ctmp
	sta  pa         ; restore port

	lda  pa         ; chk msb
	and  #disk_change
	bne  +          ; br, ok

	sta  dirty      ; clear dirty flag
	lda  #bit7
	sta  cachetrk   ; uninit
	lda  #1
	sta  wpsw

+       lda  drvst      ; motor on ?
	beq  m5

	tay             ; save it
	cmp  #$20
	beq  m6

	dec  acltim     ; dec timer
	bne  m6

	tya             ; accelerating ?
	bpl  +

	and  #all-bit7  ; clear acceleration bit
	sta  drvst
+       and  #$10       ; timeout ?
	beq  m6

	dec  acltim+1   ; dec 2nd timer
	bne  m6

	jsr  motoff     ; turn off the motor
	lda  #0
	sta  drvst      ; all dead
m5      ldx  savsp
	txs             ; restore stack
	rts

m9      ldy  drvst
m6      tya
	and  #$40       ; stepping?
	beq  m5

        lda  cmdtrk     ; destination
	cmp  drvtrk
	beq  +          ; we are there

	sta  wddat      ; this is where we want to go...
	lda  drvtrk     ; this is where we are...
	sta  wdtrk

	lda  wdseek
	jsr  wdbusy
	jsr  wdunbusy
	lda  cmdtrk     ; to...
	sta  drvtrk
	sta  wdtrk      ; update all
+       lda  drvst
	and  #all-bit6  ; clear stepping flag
	sta  drvst
	ldy  setval
	jsr  xms        ; settle...it
	jmp  m5
        .pend
;

bufcache

	bit  tmp+1      ; check mark flag
	bvc  +

	lda  #bit7
	.byte skip2
+       lda  #all-all
	sta  dirty

cachebuf
	lda  #bit5      ; check transfer flag
	bit  ctmp+1
	bne  +          ; br, yes transfer

	rts

+       ldy  hdrjob     ; get header address
	lda  hdrs,y     ; get cache pointer
	clc
	adc  cache+1
	sta  ip+5

	ldy  #0
	sty  ip+2       ; buffer index
	sty  ip+4       ; track cache index

	ldx  nextjob
	lda  bufind,x   ; which buffer
	sta  ip+3

	lda  tmp+1      ; get parms
	and  #all-bit7-bit6-bit5
	tax             ; buffer count must be in .x
	bit  tmp+1
	bpl  +          ; direction

	jmp  dma_to     ; ugly fast linear code
+       jmp  dma_from   ; *

;

trans_ts .proc
	asl  info+1     ; translate at all?
	bcs  m10

	ldy  hdrjob     ; index
	asl  info       ; translate log/physical
	bcc  m6

	ldx  nextjob    ; get job #
	lda  cacheoff,x ; already translated ?
	bpl  +          ; br, nope

	rts

+       lda  hdrs,y     ; get logical track
	sec
	sbc  #1         ; -1
	sta  hdrs2,y    ; put physical track

	lda  numsec     ; get logical # of sectors
	lsr  a          ; /2
	tax             ; save it
	cmp  hdrs+1,y   ; cmp to logical sector
	beq  +
	bcc  +

	lda  #0         ; side zero
	.byte skip2
+       lda  #1         ; side one
	sta  tcacheside ; translated track cache side

	beq  +          ; 0

	txa             ; numsec/2
+       sta  tmp+1      ; save start sector

	ldx  nextjob
	lda  hdrs+1,y   ; get logical sector number
	sec
	sbc  tmp+1
	ora  #bit7      ; set flag
	sta  cacheoff,x
	and  #all-bit7

	ldx  psectorsiz ; get physical sector size
-       dex
	beq  +

	lsr  a          ; /2
	jmp  -

+       clc
	adc  pstartsec
	jmp  m9

m6      ldx  nextjob    ; current
	lda  sids,x     ; get side
	sta  tcacheside ; translated track cache side
	lda  hdrs,y     ; get logical track
	sta  hdrs2,y    ; store physical
	lda  hdrs+1,y   ; get logical sector
	pha             ; save
	sec
	sbc  pstartsec  ; get offset
	ldx  psectorsiz
-       dex
	beq  +

	asl  a          ; *2
	jmp  -

+       sta  cacheoff,x ; save offset
	pla
m9      sta  hdrs2+1,y  ; store sector logical/physical
	.byte skip2
m10     asl  info
	rts
        .pend

;

trk_in_mem

	ldy  hdrjob     ; get index
	lda  hdrs2,y    ; get converted track address
	cmp  cachetrk   ; same
	bne  +          ; br, nope

	lda  tcacheside ; translated side
	cmp  cacheside  ; same as what is in memory ?
	bne  +

	jmp  buffer_op  ; do buffer operation

+       rts

;

buffer_op .proc

	ldx  nextjob    ; get buffer #
	lda  bufind,x
	sta  ip+3       ; high address for buffer
	lda  cacheoff,x ; get offset for track cache buffer
	and  #all-bit7  ; clear flag
	clc
	adc  cache+1    ; get high address
	sta  ip+5       ; save it

	ldy  #0
	sty  ip+2       ; clear it
	sty  ip+4       ; *

	ldx  #1
	asl  info+1     ; buffer transfer?
	bcs  m4

	asl  info+1     ; read/wrt?
	bcs  +

	jsr  dma_from   ; readit
-       jmp  okfin
+       lda  wpstat     ; check write protect status
	bne  m5

	jsr  dma_to     ; writeit

m3      lda  #bit7
	sta  dirty      ; set dirty flag
	bne  -          ; bra

m4      asl  info+1     ; read/wrt?
	bcc  -          ; bra, finish up

	lda  wpstat     ; check write protect status
	bne  m5

	bcs  m3         ; wrt, set dirty

m5      jmp  fin        ; write protected
        .pend
;

seek
	jsr  seekhdr    ; seek any header
	bcs  +

	lda  header     ; get track
	sta  drvtrk
	lda  header+3   ; & physical sector size
	sta  psectorsiz
	rts

+       jmp  errr       ; drive not ready

;

cacheip
	lda  cache      ; get track cache address
	sta  ip+4       ; lo
	lda  cache+1
	sta  ip+5       ; hi
	rts


;

sid_select

	beq  +          ; side zero?

	lda  #side_sel
+       sta  ctmp       ; set mask
	lda  pa
	and  #all-side_sel
	ora  ctmp       ; doit
	sta  pa
	rts


;

wdabort

	lda  wdforceirq
	sta  wdcmd      ; send command
	jsr  delay40    ; wait 40uS
	jsr  delay40    ; wait 40uS
	jsr  delay40    ; wait 40uS
	jmp  wdunbusy

;

precmp  .proc
	sec             ; wdtrk in .a
	sbc  pstartsec
	cmp  #precmptrk
	bcc  m1

	lda  wdwritesector
	ora  #bit1
	sta  wdwritesector
	lda  wdwritetrack
	ora  #bit1
	sta  wdwritetrack
	bcs  m2         ; bra

m1      lda  wdwritesector
	and  #all-bit1
	sta  wdwritesector
	lda  wdwritetrack
	and  #all-bit1
	sta  wdwritetrack
m2      rts
        .pend
;
