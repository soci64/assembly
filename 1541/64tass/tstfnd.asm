; returns next available trk & sec
; given current t & s
;  allocation is from trk 40
;  towards 1 & 80, by full tracks

nxtts   jsr  gethdr
        lda  #3
        sta  temp       ; set pass count
	lda  #1         ; find next
        ora  wbam
        sta  wbam
nxtds   lda  temp
	pha
        jsr  setbam
        pla
        sta  temp
        lda  (bmpnt),y
rtch36a bne  fndnxt

        lda  track
        cmp  dirtrk
        beq  nxterr

        bcc  nxt2

        inc  track
        lda  track
        cmp  trknum
        bne  nxtds

        ldx  dirtrk
        dex
        stx  track

        lda  #0
        sta  sector
        dec  temp
        bne  nxtds

nxterr  lda  #dskful
        jsr  cmderr

nxt2    dec  track
        bne  nxtds

nxt3	ldx  dirtrk
        inx
        stx  track
        lda  #0
        sta  sector
        dec  temp
        bne  nxtds

        beq  nxterr

fndnxt  lda  sector     ; get current sec
        clc     	; add in the incr
        adc  secinc
        sta  sector
        lda  track
        jsr  maxsec
        sta  lstsec
        sta  cmd
        cmp  sector	; is it over?
        bcs  fndn0      ; no..it's ok

	sec
	lda  sector
	sbc  lstsec
	sta  sector
	beq  fndn0

	dec  sector	; -1

fndn0   jsr  getsec
        beq  fndn2	; nothing here...

fndn1
	jmp  wused

fndn2
        lda  #0
        sta  sector     ; start again
	jsr  getsec
        bne  fndn1	; sumtin here...

	jmp  derr

intts   lda  #1         ; find init opt t&s
        ora  wbam
        sta  wbam
        lda  r0
        pha     	; save temp var
        lda  #1         ; clr r0
        sta  r0
its1    lda  dirtrk     ; track:= dirtrk-r0
        sec
        sbc  r0
        sta  track
        bcc  its2       ; if t>0

        beq  its2       ; then begin

	jsr  setbam     ; set the bam pntr
        lda  (bmpnt),y
        bne  fndsec

its2    lda  dirtrk     ; trk= dirtrk+r0
        clc
        adc  r0
        sta  track
        inc  r0         ; next trk
        cmp  trknum
        bcc  its3       ; next icf cmnd err

        lda  #systs
        jsr  cmder2

its3    jsr  setbam     ; set ptr
        lda  (bmpnt),y
        beq  its1

fndsec  pla
        sta  r0         ; restore r0
        lda  #0
        sta  sector
        jsr  getsec
        beq  derr

        jmp  wused

derr    lda  #direrr
        jsr  cmder2
getsec  jsr  setbam
	tya
	pha
        jsr  avck       ; chk bits & count
        lda  track
        jsr  maxsec
        sta  lstsec
        pla
        sta  temp
gs10    lda  sector
        cmp  lstsec
        bcs  gs20

        jsr  bambit     ; get sector offset
        bne  gs30

        inc  sector
        bne  gs10       ; bra

gs20    lda  #0         ; nothing free
gs30    rts     	; (z=1): free

avck    lda  temp
	pha
	lda  #0
        sta  temp       ; blk counter
        ldy  bamsiz
        dey     	; adjust it
ac10    ldx  #7
ac20    lda  (bmpnt),y
        and  bmask,x    ; used ?
        beq  ac30       ; no

        inc  temp       ; count it
ac30    dex
        bpl  ac20       ; do next bit

        dey     	; do next byte
        bne  ac10

        lda  (bmpnt),y
        cmp  temp
        bne  ac40       ; counts don't match

	pla
	sta  temp
        rts

ac40    lda  #direrr
        jsr  cmder2

maxsec  ldx  nzones
-	cmp  trknum-1,x
	dex
	bcs  -
	lda  numsec,x
	rts
