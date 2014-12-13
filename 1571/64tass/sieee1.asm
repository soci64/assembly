
jatnsrv sei
        lda  #0
        sta  atnpnd
        sta  lsnact
        sta  tlkact

        ldx  #topwrt    ; reset stack
        txs
        jsr  spinp      ; serial input

        lda  #$80       ; set atn mode flag for acpt routine
        sta  eoiflg     ; reset eoi flag to non-eoi state
        sta  atnact

        jsr  clkhi
        jsr  datlow     ; set data line low as response

        lda  pb         ; set atn ack to release data line
        ora  #atna
        sta  pb

-       lda  pb         ; test atn still here
        bpl  a2         ; gone !

        and  #clkin     ; clock still low
        bne  -

a3      jsr  jacptr     ; get a command byte

        cmp  #unlsn
        bne  a4

        lda  fastsr     ; clr fast host flag & listen flag
        and  #all-bit6
        sta  fastsr
        lda  #0
        sta  lsnact
        beq  a6         ; bra

a4      cmp  #untlk
        bne  a5

        lda  fastsr     ; clr fast host flag & talk flag
        and  #all-bit6
        sta  fastsr
        lda  #0
        sta  tlkact

a6      jmp  a9         ; jmp

a5      cmp  tlkadr     ; our talk address?
        bne  a7         ; nope

        lda  #1
        sta  tlkact     ; set talk flag
        lda  #0
        sta  lsnact     ; clear listen flag
        beq  a8         ; bra

a7      cmp  lsnadr     ; our listen address?
        bne  a10        ; nope

        lda  #1
        sta  lsnact     ; set listen flag
        lda  #0
        sta  tlkact     ; clear talk flag
        beq  a8         ; bra

a10     tax             ; test if sa
        and  #$60
        cmp  #$60       ; sa = $60 + n
        bne  a11        ; did not get a valid command

        txa             ; a sa for me
        sta  orgsa
        and  #$0f       ; strip junk
        sta  sa

        lda  orgsa      ; test if close
        and  #$f0
        cmp  #$e0
        bne  a9         ; no

        cli
        jsr  close      ; close the file
        sei

;warning:::close doesn't return in time for a9

a8      bit  pb         ; test atn still here
        bmi  a3

;atn gone , do what we where told to do

a2      lda  #0
        sta  atnact     ; clear atn mode

        lda  pb         ; atn gone, release atn ack
        and  #all-atna
        sta  pb

        lda  lsnact     ; listen ?
        beq  a12

        bit  fastsr     ; fast ?
        bvc  a14

        jsr  drq        ; device request fast

a14     jsr  jlisten
        jmp  xidle

a12     lda  tlkact     ; talk?
        beq  a13

        jsr  dathi      ; release data line
        jsr  clklo

        jsr  jslowd     ; slow down for plus4 series
        jsr  jtalk
        jsr  jslowd     ; slow down for plus4 series

a13     jmp  jilerr     ; release all lines and go to idle

;fix so (device not present) errors reported

a11
        lda  #atna
        sta  pb         ; kill all

a9      bit  pb
        bpl  a2         ; exit out same way after atn done

        bmi  a9         ; bra


drq     jsr  tstatn     ; does the host want us ?
        jsr  debnc
        and  #clkin
        bne  drq        ; wait for clk hi

        jsr  spout      ; output

        lda  #0
        sta  sdr        ; send zero

fs_wait lda  #8
-       bit  icr        ; wait for byte to shift out
        beq  -

spinp   php             ; save uP status
        sei
        lda  cra        ; turn 8520 in
        and  #%10111111 ; serial port input
        sta  cra
        lda  pota1       ; turn drvr in
        and  #all-2      ;**TODO**
        sta  pota1
        lda  #$88 ;**TODO**
        sta  icr
        bit  icr
        plp
        rts

spout   php             ; save uP status
        sei
        lda  pota1
        ora  #fsdir
        sta  pota1      ; turn drvr out
        lda  cra        ; turn 6526 out
        ora  #%01000000
        sta  cra
        lda  #8 ;**TODO**
        sta  icr
        bit  icr
        plp
        rts

jtalk   .proc
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

;**********  fast serial routines  **********

        bit  fastsr     ; fast or slow ?
        bvc  m10

        lda  pota1      ; fast serial output
        ora  #fsdir
        sta  pota1      ; turn drvr out
        lda  cra        ; turn 6526 out
        ora  #%01000000
        sta  cra
        bit  icr
        ldx  lindx
        lda  chndat,x   ; get data
        sta  sdr        ; send it

-       lda  icr        ; wait for byte ready
        and  #8
        beq  -

        lda  cra
        and  #%10111111 ; release the data bus
        sta  cra        ; must go input
        lda  pota1
        and  #all-fsdir ; turn drvr in
        sta  pota1
        lda  #$88
        sta  icr
        bne  m9         ; wait for data accepted

;**********  end fast serial routines  **********

m10
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
m14     jsr  jslower    ; wait a bit for t-s ( 2 mhz )

        lda  slflag     ; slow down?
        bne  m17

        jsr  jslowd     ; delay 40 us ( host dma )
m17     jsr  clkhi      ; rising edge clock
        jsr  jslower    ; increase t-v ( 2 mhz )

        lda  slflag     ; slow down?
        bne  m15

        jsr  jslowd     ; delay 40 us ( host dma )
m15     jsr  patch4     ; pull clock low and ...

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

m16     jmp  frmerr
        .pend

jacptr2
        bit  icr        ; clear pending

jacptr  .proc
        lda  #8         ; set byte bit count
        sta  cont

-       jsr  tstatn
        jsr  debnc
        and  #clkin
        bne  -

        jsr  dathi      ; make data line hi

        lda  #datin
-       bit  pb         ; wait for data high
        bne  -
        jsr  ptch59
m3      jsr  tstatn
        lda  ifr1
        and  #$40
        bne  m4

        jsr  debnc      ; test clock low
        and  #clkin
        beq  m3         ; no
        bne  m5         ; yes

m4      jsr  datlow     ; set data line low as response

        ldx  #24        ; delay for talker turnaround
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

;**********  fast serial routines  **********

        tax             ; save .a
        lda  icr
        and  #8         ; fast byte ?
        beq  m11

        lda  sdr        ; get data
        sta  data       ; keep
        jmp  m10        ; finish up

;**********  end fast serial routines **********

m11     txa             ; restore .a
        lsr  a          ; shift into carry
        and  #$02       ; clkin/2
        bne  m5

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

jlisten .proc
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

        jmp  jilerr     ; not active channel

m2      jsr  jacptr2    ; get a byte

        cli
        jsr  put        ; put(data,eoiflg,sa)
        jmp  jlisten    ; and keep on listen
        .pend

frmerr  lda #0
        sta  fastsr

jilerr  lda  #0
        sta  pb         ; in atnmod, release all bus lines

xidle   jsr  spinp
        jmp  idle      ; go idle it
