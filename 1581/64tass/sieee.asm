atnsrv  sei
        lda  sieeeset
        sta  sieeetim   ; init counter
        lda  fsflag
        and  #all-bit7-bit6-bit0
        sta  fsflag     ; clear serial flags (bit7=talk,bit6=listen,
                        ;                     bit0=atn pending)

        ldx  tos        ; reset stack
        txs
        jsr  spinp      ; serial input

        lda  #$80       ; set atn mode flag for acpt routine
        sta  eoiflg     ; reset eoi flag to non-eoi state

        lda  fsflag
        ora  #bit1
        sta  fsflag     ; atnmod

        jsr  clkhi
        jsr  datlow     ; set data line low as response

        lda  pb         ; set atn ack to release data line
        and  #all-atna
        sta  pb

-       lda  pb         ; test atn still here
        bpl  a2         ; gone !

        and  #clkin     ; clock still low
        bne  -

a3      jsr  acptr      ; get a command byte

        cmp  #unlsn
        bne  a4

        lda  fsflag     ; clr fast host flag & listen flag
        and  #all-bit5-bit6
        sta  fsflag
        jmp  a6

a4      cmp  #untlk
        bne  a5

        lda  fsflag     ; clr fast host flag & talk flag
        and  #all-bit5-bit7
        sta  fsflag

a6      jmp  a9         ; jmp

a5      cmp  tlkadr     ; our talk address?
        bne  a7         ; nope

        lda  fsflag
        ora  #bit7      ; set talk flag
        and  #all-bit6  ; clear listen flag
        sta  fsflag
        bne  a8         ; bra

a7      cmp  lsnadr     ; our listen address?
        bne  a10        ; nope

        lda  fsflag
        ora  #bit6      ; set talk flag
        and  #all-bit7  ; clear talk flag
        sta  fsflag
        bne  a8         ; bra

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

a2      lda  fsflag
        and  #all-bit1
        sta  fsflag     ; clear atn mode

        lda  pb         ; atn gone, release atn ack
        ora  #atna
        sta  pb

        bit  fsflag     ; listen ?
        bvc  a12

        lda  #bit5
        bit  fsflag     ; fast ?
        beq  a14

        jsr  drq        ; device request fast

a14     jsr  jlisten
        jmp  xidle

a12     bit  fsflag     ; talk?
        bpl  a13

        jsr  dathi      ; release data line
        jsr  clklo

        jsr  delay40    ; slow down for plus4 series
        jsr  jtalk
        jsr  delay40    ; slow down for plus4 series

a13     jmp  ilerr      ; release all lines and go to idle

;fix so (device not present) errors reported

a11
        lda  #0
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

        .byte $ea, $ea, $ea, $ea, $ea   ; placeholder

spinp   php             ; save uP status
        sei
        lda  cra        ; turn 8520 in
        and  #%10111111 ; serial port input
        jsr  spin_patch ; sta cra
        lda  pb         ; turn drvr in
        and  #all-fsdir
        sta  pb
        plp
        rts

        .byte $ea, $ea, $ea, $ea, $ea   ; placeholder

spout   php             ; save uP status
        sei
        lda  pb
        ora  #fsdir
        sta  pb         ; turn drvr out
        lda  cra        ; turn 6526 out
        ora  #%01000000
        jsr  spout_patch ; sta cra
        plp
        rts



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



tstatn  .proc
        lda  #bit1
        bit  fsflag     ; test if in atn mode
        beq  m1         ; no

        lda  pb         ; in atnmod
        bpl  m2         ; atn gone,do what we are told to do

m3      rts             ; still in atn  mode

m1      lda  pb         ; not atnmode
        bpl  m3         ; no atn present

        bit  icr        ; clear atn
        jmp  jatnsrv    ; do atn command

m2      jmp  a2
        .pend


delay40 txa             ; only affect .a
        ldx  #$0c       ; insert 40us of delay with this routine
        bne  delay16+3

delay16 txa             ; only affect .a
        ldx  #3         ; insert 16us of delay with this routine
-       dex
        bne  -

        tax
        rts



nnmi    .proc
        lda  cmdbuf+2   ; new nmi routine check for
        cmp  #'-'
        beq  m1         ; if ui- then no delay

        sec
        sbc  #'+'
        bne  m2         ; if not ui+ then must be a real ui command

m1      and  #bit1
        asl  a
        asl  a
        asl  a
        sta  tmp
        sei
        lda  fsflag
        and  #all-bit4
        ora  tmp
        sta  fsflag     ; set/clr slow flag
        rts

m2      jmp  jnmi       ; doit
        .pend

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

;**********  fast serial routines  **********

        lda  #bit5
        bit  fsflag     ; fast or slow ?
        beq  m10

        lda  pb         ; fast serial output
        ora  #fsdir
        sta  pb         ; turn drvr out
        lda  cra        ; turn 6526 out
        ora  #%01000000
        sta  cra
        bit  icr
        ldx  lindx
        lda  chndat,x   ; get data
        sta  sdr        ; send it

        lda  #8
-       bit  icr        ; wait for byte ready
        beq  -

        lda  cra
        and  #%10111111 ; release the data bus
        sta  cra        ; must go input
        lda  pb
        and  #all-fsdir ; turn drvr in
        sta  pb
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
m14     jsr  delay16    ; wait a bit for t-s ( 2 mhz )

        lda  #bit4
        bit  fsflag     ; slow down?
        bne  m17

        jsr  delay40    ; delay 40 us ( host dma )
m17     jsr  clkhi      ; rising edge clock
        jsr  delay16    ; increase t-v ( 2 mhz )

        lda  #bit4
        bit  fsflag     ; slow down?
        bne  m15

        jsr  delay40    ; delay 40 us ( host dma )
m15     jsr  clklo      ; pull clock low and ...
        jsr  dathi      ; release data

        dec  cont       ; more bits?
        bne  m11        ; yes

m9      jsr  tstatn     ; test for atn
        jsr  debnc      ; debounce
        and  #datin
        beq  m9         ; wait for data low

        cli             ; let the controller run
        jsr  get        ; get the next byte
        sei             ; sorry sync protocol

        jsr  tstatn     ; test for atn
        jmp  m2         ; keep on talkin

m16     jmp  frmerr
        .pend

acptr   .proc
        bit  icr        ; clear pending
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

        ldx  #$0a       ; > 256uS is EOI
m3      jsr  tstatn
        dex
        beq  m4         ; times up?

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

frmerr  lda  fsflag
        and  #all-bit5  ; leave ...
        sta  fsflag     ; clear serial flags


ilerr   lda  #atna
        sta  pb         ; in atnmod, release all bus lines


xidle   jsr  spinp
        jmp  jidle      ; go idle it


spinout                 ; carry set spout
        bcs  +

        jmp  spinp      ; carry clear spin
+       jmp  spout
