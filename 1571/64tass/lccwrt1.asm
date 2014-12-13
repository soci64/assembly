
;    write out data buffer

jwright .proc
        cmp  #$10       ;  test if write
        beq  +

        jmp  jvrfy

+       jsr  chkblk     ;  get block checksum
        sta  chksum

        lda  dskcnt     ;  test for write protect
        and  #$10
        bne  +          ;  not  protected

        lda  #8         ;  write protect error
        jmp  jerrr

+       jsr  bingcr     ;  convert buffer to write image

        jsr  jsrch      ;  find header

        ldy  #gap1-2    ;  wait out header gap

-       bit  pota1
        bmi  -

        bit  byt_clr

        dey             ;  test if done yet
        bne  -

        lda  #$ff       ;  make output $ff
        sta  ddra2

        lda  pcr2       ;  set write mode
        and  #$ff-$e0   ;  0=wr
        ora  #$c0
        sta  pcr2

        lda  #$ff       ;  write 4 gcr sync
        ldy  #numsyn
        sta  data2

-       bit  pota1
        bmi  -

        bit  byt_clr

        dey
        bne  -

; write out overflow buffer

        ldy  #256-topwrt

m5      lda  ovrbuf,y   ; get a char
-       bit  pota1
        bmi  -

        sta  data2      ;  stuff it

        iny
        bne  m5         ;  do next char

                        ;  write rest of buffer

m7      lda  (bufpnt),y ;  now do buffer
-       bit  pota1      ;  wait until ready
        bmi  -

        sta  data2      ;  stuff it again

        iny             ;  test if done
        bne  m7         ;  do the whole thing

-       bit  pota1      ;  wait for last char to write out
        bmi  -

        lda  pcr2       ;  goto read mode
        ora  #$e0
        sta  pcr2

        lda  #0         ;  make data2 input $00
        sta  ddra2

        jsr  jwtobin    ;  convert write image to binary

        ldy  jobn       ;  make job a verify

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

        jmp  ptch62     ; *** rom ds 01/21/86 ***, chk for verify
;       lda  jobs,y
        eor  #$30
        sta  jobs,y

        jmp  jseak      ;  scan job que
        .pend

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>


;    * jwtobin
;    convert write image back to
;    binary data


jwtobin .proc
        lda  #0
        sta  savpnt
        sta  bufpnt     ;  lsb for overflow area
        sta  nxtpnt

        lda  bufpnt+1
        sta  nxtbf      ;  save for next buffer.

        lda  #>ovrbuf   ;  overflow first
        sta  bufpnt+1   ;  msb for overflow area
        sta  savpnt+1

        lda  #256-topwrt
        sta  gcrpnt     ;  offset
        sta  bytcnt     ;  ditto

        jsr  jget4gb    ;  get first four- id and 3 data

        lda  btab       ;  save bid
        sta  bid

        ldy  bytcnt

        lda  btab+1
        sta  (savpnt),y
        iny

        lda  btab+2
        sta  (savpnt),y
        iny

        lda  btab+3
        sta  (savpnt),y
        iny

        sty  bytcnt

; do overflow first and store back into overflow buffer

-       jsr  jget4gb    ; do rest of overflow buffer

        ldy  bytcnt

        lda  btab
        sta  (savpnt),y
        iny

        lda  btab+1
        sta  (savpnt),y
        iny
        beq  +

        lda  btab+2
        sta  (savpnt),y
        iny

        lda  btab+3
        sta  (savpnt),y
        iny

        sty  bytcnt
        bne  -          ;  jmp till end of overflow buffer

+       lda  btab+2
        sta  (bufpnt),y
        iny

        lda  btab+3
        sta  (bufpnt),y
        iny

        sty  bytcnt

-       jsr  jget4gb

        ldy  bytcnt

        lda  btab
        sta  (bufpnt),y
        iny

        lda  btab+1
        sta  (bufpnt),y
        iny

        lda  btab+2
        sta  (bufpnt),y
        iny

        lda  btab+3
        sta  (bufpnt),y
        iny

        sty  bytcnt
        cpy  #187
        bcc  -

        lda  #69                ;  move buffer up
        sta  savpnt

        lda  bufpnt+1
        sta  savpnt+1

        ldy  #256-topwrt-1

-       lda  (bufpnt),y
        sta  (savpnt),y

        dey
        bne  -

        lda  (bufpnt),y
        sta  (savpnt),y

; load in overflow

        ldx  #256-topwrt

-       lda  ovrbuf,x
        sta  (bufpnt),y

        iny
        inx
        bne  -

        stx  gcrflg     ; clear buffer gcr flag
        rts
        .pend



;    * verify data block
;   convert to gcr verify image
;   test against data block
;   convert back to binary


jvrfy   .proc
        cmp  #$20       ;  test if verify
        beq  +

        bne  m7         ; bra

+       jsr  chkblk     ; get block checksum
        sta  chksum

        jsr  bingcr     ; convert to verify image

        jsr  jdstrt

        ldy  #256-topwrt
m2      lda  ovrbuf,y   ;  get char
-       bit  pota1
        bmi  -

        eor  data2      ;  test if same
        bne  m4         ; verify error

        iny
        bne  m2         ;  next byte


m5      lda  (bufpnt),y ;  now do buffer

-       bit  pota1
        bmi  -

        eor  data2      ;  test if same
        bne  m4         ;  error

        iny
        cpy  #$fd       ;  dont test off bytes
        bne  m5
        beq  m8         ;  bra

m7      jsr  jsrch      ;  sector seek
m8      lda  #1
        .byte  skip2
m4      lda  #7         ;  verify error
        jmp  jerrr
        .pend
