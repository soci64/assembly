
;  controller format disk

jformat .proc
        lda  #71
        sta  maxtrk     ; double sided
        lda  #3
        jsr  seth
        ldx  #3         ; job #3
        lda  #0
        sta  fmtsid     ; side zero first
        lda  #$f0       ; format cmd
        sta  tsttrk     ; init speed var
        sta  jobs,x     ; give job to controller
        jsr  stbctl     ; wake him up
        cmp  #2         ; error?
        bcs  m1         ; br, error

;read track one sector zero

        ldy  #3         ; retries
m4      lda  #1         ; track 1
        sta  hdrs+6     ; *
        lda  #0         ; sector 0
        sta  hdrs+7     ; *
        lda  #$80       ; read
        sta  jobs,x     ; give job to controller
        jsr  stbctl     ; wake him up
        cmp  #2         ; error?
        bcc  m5         ; br, ok...

        dey
        bpl  m4         ; try 3 times
        bcs  m1         ; bra

m5      lda  #1
        sta  fmtsid     ; side one second
        lda  #$f0       ; format cmd
        sta  tsttrk     ; init speed var
        sta  jobs,x     ; give job to controller
        jsr  stbctl     ; wake him up
        cmp  #2         ; error?
        bcs  m1         ; br, error

;read track thirty-six sector zero

        ldy  #3         ; retries
m6      lda  #36        ; track 36
        sta  hdrs+6     ; *
        lda  #0         ; sector 0
        sta  hdrs+7     ; *
        lda  #$80       ; read
        sta  jobs,x     ; give job to controller
        jsr  stbctl     ; wake him up
        cmp  #2         ; error?
        bcs  m3         ; br, bad

        rts             ; ok

m3      dey
        bpl  m6         ; keep trying

m1      ldx  #0         ; set for offset for buffer to det. trk & sect.
        bit  jobrtn     ; return on error ?
        stx  jobrtn     ; clr
        bpl  m7

        rts             ; back to caller
m7      jmp  error
        .pend
