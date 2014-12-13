
atnirq  lda  pa1
        lda  #1
        sta  atnpnd
        rts

atnsrv  sei
	lda  #0
	sta  atnpnd
	sta  lsnact
	sta  tlkact

	ldx  #topwrt    ; reset stack
	txs

	lda  #$80       ; set atn mode flag for acpt routine
	sta  eoiflg     ; reset eoi flag to non-eoi state
	sta  atnact

	jsr  clkhi
	jsr  datlow     ; set data line low as response

	lda  pb         ; set atn ack to release data line
	ora  #atna
	sta  pb

-       lda  pb         ; test atn still here
	bpl  atns20     ; gone !

	and  #clkin     ; clock still low
	bne  -

atns3   jsr  acptr      ; get a command byte

	cmp  #unlsn
	bne  atns4

	lda  #0
	sta  lsnact
	beq  atns9      ; bra

atns4   cmp  #untlk
	bne  atns5

	lda  #0
	sta  tlkact

        beq  atns9      ; jmp

atns5   cmp  tlkadr     ; our talk address?
	bne  atns7      ; nope

	lda  #1
	sta  tlkact     ; set talk flag
	lda  #0
	sta  lsnact     ; clear listen flag
	beq  atns8      ; bra

atns7   cmp  lsnadr     ; our listen address?
	bne  atns10     ; nope

	lda  #1
	sta  lsnact     ; set listen flag
	lda  #0
	sta  tlkact     ; clear talk flag
	beq  atns8      ; bra

atns10  tax             ; test if sa
	and  #$60
	cmp  #$60       ; sa = $60 + n
	bne  atns11     ; did not get a valid command

	txa             ; a sa for me
	sta  orgsa
	and  #$0f       ; strip junk
	sta  sa

	lda  orgsa      ; test if close
	and  #$f0
	cmp  #$e0
	bne  atns9      ; no

	cli
	jsr  close      ; close the file
	sei

;warning:::close doesn't return in time for a9

atns8   bit  pb         ; test atn still here
	bmi  atns3

;atn gone , do what we where told to do

atns20  lda  #0
	sta  atnact     ; clear atn mode

	lda  pb         ; atn gone, release atn ack
	and  #all-atna
	sta  pb

	lda  lsnact     ; listen ?
	beq  atns12

	jsr  listen
	jmp  xidle

atns12  lda  tlkact     ; talk?
	beq  atns13

	jsr  dathi      ; release data line
	jsr  clklo

	jsr  talk

atns13  jmp  ilerr      ; release all lines and go to idle

;fix so (device not present) errors reported

atns11
	lda  #atna
	sta  pb         ; kill all

atns9   bit  pb
	bpl  atns20     ; exit out same way after atn done

	bmi  atns9      ; bra

talk    .proc
	sei             ; find if open channel
	jsr  fndrch
	bcs  m1         ; no one home

m2      ldx  lindx
	lda  chnrdy,x
	bmi  m3

m1      rts

;  code added to correct verify error

m3      jsr  tstatn     ; test for atn
	jsr  debnc      ; debounce
	and  #datin
	php
	jsr  clkhi      ; set clk hi
	plp             ; see if verify error...
	beq  m4         ; br,  yes...data line hi, eoi !!!!

-       jsr  tstatn     ; test for atn
	jsr  debnc
	and  #datin
	bne  -          ; wait for data high

	ldx  lindx      ; prepare to send eoi if needed
	lda  chnrdy,x
	and  #eoi
	bne  m7         ; no eoi

m4      jsr  tstatn     ; test for atn
	jsr  debnc      ; debounce
	and  #datin     ; test if data line is low
	bne  m4         ; yes, wait till hi

-       jsr  tstatn     ; test for atn
	jsr  debnc      ; debounce
	and  #datin
	beq  -

m7      jsr  clklo      ; set clock low
	jsr  tstatn     ; chk atn line
	jsr  debnc      ; debounce
	and  #datin
	bne  m7

	lda  #8         ; set up bit counter
	sta  cont

m11
	jsr  debnc      ; let port settle
	and  #datin     ; test that data line is now high before we send
	bne  m16

m12     ldx  lindx      ; get byte to send
	lda  chndat,x
	ror  a
	sta  chndat,x

	bcs  m13        ; send a 1

	jsr  datlow     ; send a 0
	bne  m14        ; and clock it

m13     jsr  dathi
m14     jsr  clkhi

	lda  slflag     ; slow down?
	bne  m17

	jsr  slowd      ; delay 40 us ( host dma )
m17     jsr  patch4     ; rising edge clock

	dec  cont       ; more bits?
	bne  m11        ; yes

m9      jsr  tstatn     ; test for atn
	jsr  debnc      ; debounce
	and  #datin
	beq  m9         ; wait for data low

	cli             ; let the controller run
	jsr  get        ; get the next byte
	sei             ; sorry sync protocol

	jmp  m2         ; keep on talkin

m16     jmp  ilerr
	.pend


dathi   lda  pb         ; set data out hi
	and  #all-datout
	sta  pb
	rts



datlow  lda  pb         ; set data out low
	ora  #datout
	sta  pb
	rts



clklo   lda  pb         ; set clk out low
	ora  #clkout
	sta  pb
	rts



clkhi   lda  pb         ; set clk out high
	and  #$ff-clkout
	sta  pb
	rts

debnc   lda  pb         ; debounce port
	cmp  pb
	bne  debnc

	rts

acptr   .proc
	lda  #8         ; set byte bit count
	sta  cont

-       jsr  tstatn
	jsr  debnc
	and  #clkin
	bne  -

	jsr  dathi      ; make data line hi

	lda  #datin
	jmp  patch6
rptch6
m3	jsr  tstatn
	lda  ifr1
	and  #$40
	bne  m4

	jsr  debnc      ; test clock low
	and  #clkin
	beq  m3         ; no
	bne  m5         ; yes

m4      jsr  datlow     ; set data line low as response

	ldx  #10        ; delay for talker turnaround
-       dex
	bne  -

	jsr  dathi      ; set data line hi

-       jsr  tstatn
	jsr  debnc      ; wait for low clock
	and  #clkin
	beq  -

	lda  #0         ; set eoi received
	sta  eoiflg

m5      lda  pb         ; wait for clock high
	eor  #01        ; complement datain

	lsr  a          ; shift into carry
	and  #$02       ; clkin/2
	bne  m5

	nop
	nop
	nop

	ror  data

-       jsr  tstatn
	jsr  debnc
	and  #clkin     ; wait for clock low
	beq  -

	dec  cont       ; more to do?
	bne  m5

m10     jsr  datlow     ; set data line low
	lda  data
	rts
	.pend

listen  .proc
	sei
	jsr  fndwch     ; test if active write channel
	bcs  m1

	lda  chnrdy,x
	ror  a
	bcs  m2

m1      lda  orgsa      ; test if open
	and  #$f0
	cmp  #$f0
	beq  m2         ; its an open

	jmp  ilerr      ; not active channel

m2      jsr  acptr      ; get a byte

	cli
	jsr  put        ; put(data,eoiflg,sa)
	jmp  listen     ; and keep on listen
	.pend

ilerr   lda  #0
	sta  pb         ; in atnmod, release all bus lines
	jmp  xidle      ; go idle it

        jmp  atnsrv

tstatn  .proc
	lda  atnact
	beq  m1         ; no

	lda  pb         ; in atnmod
	bpl  m2         ; atn gone,do what we are told to do

m3      rts             ; still in atn  mode

m1      lda  pb         ; not atnmode
	bpl  m3         ; no atn present

	jmp  ptch30     ; do atn command

m2      jmp  ptch45
        .pend
