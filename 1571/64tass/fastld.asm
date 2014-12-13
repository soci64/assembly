
fstload .proc
	jsr  spout	; output
	jsr  set_fil	; setup filename for parser
	bcs  m9

        jsr  autoi	; init mechanism
	lda  nodrv	; chk status
	bne  m9		; no drive status

	lda  fastsr	; set error recovery flag on
	ora  #$81	; & eoi flag
	sta  fastsr
	jsr  findbuf	; check for buffer availabilty

	lda  cmdbuf
	cmp  #'*'	; load last ?
	bne  m7

	lda  prgtrk	; any file ?
	beq  m7

	pha		; save track
	lda  prgsec
	sta  filsec	; update
	pla
	jmp  m1

m7	lda  #0
	tay
	tax		; clear .a, .x, .y
        sta  lstdrv     ; init drive number
	sta  filtbl	; set up for file name parser
        jsr  onedrv     ; select drive
	lda  f2cnt
	pha
	lda  #1
	sta  f2cnt
	lda  #$ff
	sta  r0		; set flag
	jsr  lookup	; locate file
	pla
	sta  f2cnt	; restore var
	lda  fastsr
	and  #$7f	; clr error recovery flag
	sta  fastsr
	bit  switch	; seq flag set ?
	bmi  m8

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

; 	lda  pattyp	; is it a program file ?
;	cmp  #2
	jsr  ptch56	; *** rom ds 07/15/85 ***
	nop		; fill

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

	bne  m6		; not prg

m8      lda  filtrk     ; check if found. err if not
        bne  m1		; br, file found

m6    	ldx  #%00000010	; file not found
	.byte skip2
m9	ldx  #%00001111	; no drive
        jmp  sys_err

m1      sta  prgtrk	; save for next
	pha		; save track
	jsr  set_buf	; setup buffer allocation
	pla		; get track
	ldx  channel	; get channel offset
	sta  hdrs,x	; setup track
        lda  filsec     ; & sector
	sta  prgsec	; for next time
        sta  hdrs+1,x

	lda  #read	; read job
	sta  cmdbuf+2	; save read cmd
	sta  ctl_cmd

m2	cli		; let controller run
	ldx  jobnum	; get job #
	lda  ctl_cmd	; get cmd
	sta  jobs,x	; send cmd
	jsr  stbctr	; whack the controller in the head
	cpx  #2		; error ?
	bcc  m5

	jmp  ctr_err

m5	sei
	ldy  #0
	lda  (dirbuf),y	; check status
	beq  end_of_file

	lda  fastsr	; clear flag
	and  #$fe
	sta  fastsr

	jsr  handsk	; handshake error to the host

	ldy  #2
m3	lda  (dirbuf),y
	tax		; save data in .x
	jsr  handsk	; handshake it to the host
	iny
	bne  m3

	ldx  channel	; jobnum * 2
	lda  (dirbuf),y ; .y = 0
	cmp  hdrs,x	; same as previous track ?
	beq  m4

	ldy  #read
	.byte skip2
m4	ldy  #fread	; fast read
	sty  ctl_cmd	; command to seek then read
	sta  hdrs,x	; next track
	ldy  #1		; sector entry
	lda  (dirbuf),y
	sta  hdrs+1,x	; next sector
	jmp  m2
	.pend

end_of_file .proc
	ldx  #$1f	; eof
	jsr  handsk	; handshake it to the host

	lda  #1
	bit  fastsr	; first time through ?
	beq  m1	        ; br, nope

	tay		; .y = 1
	lda  (dirbuf),y	; number of bytes
	sec
	sbc  #3
	sta  ctl_dat	; save it
	tax		; send it
	jsr  handsk	; handshake it to the host

	iny		; next
	lda  (dirbuf),y	; address low
	tax
	jsr  handsk	; handshake it to the host

	iny
	lda  (dirbuf),y	; address high
	tax
	jsr  handsk	; handshake it to the host
	ldy  #4		; skip addresses
	bne  m3		; bra

m1      ldy  #1
	lda  (dirbuf),y	; number of bytes
	tax
	dex
	stx  ctl_dat	; save here
	jsr  handsk	; handshake it to the host

	ldy  #2		; start at data
m3	lda  (dirbuf),y
	tax
	jsr  handsk	; handshake it to the host
	iny
	dec  ctl_dat	; use it as a temp
	bne  m3

	lda  #0
	sta  sa
	jsr  close	; close channel	(faux)
	jmp  endcmd
	.pend
;
;
;
; *************************
; ***** ERROR HANDLER *****
; *************************

ctr_err sei		; no irq's
	stx  ctl_dat	; save status here
	jsr  handsk	; handshake it to the host
	lda  #0
	sta  sa
	jsr  close	; close channel (faux)
	ldx  jobnum
	lda  ctl_dat	; get error
	jmp  error	; error out.....

sys_err sei
	stx  ctl_dat	; save error
	ldx  #2		; file not found
	jsr  handsk	; give it to him
	lda  #0
	sta  sa
	jsr  close	; close channel (faux)
	lda  ctl_dat	; get error back
	cmp  #2
	beq  +

	lda  #nodriv	; no active drive
	.byte skip2
+	lda  #flntfd	; file not found
	jmp  cmderr	; never more...
;
;
;
; *************************************
; ***** FIND INTERNAL READ BUFFER *****
; *************************************

findbuf lda  #0
	sta  sa		; psydo-load
	lda  #1		; 1 buffer
	jsr  getrch	; find a read channel
	tax
	lda  bufind,x	; get buffer
	sta  dirbuf+1	; set it up indirect
	rts
;
;
;
; **************************************
; ***** SETUP INTERNAL READ BUFFER *****
; **************************************

set_buf lda  dirbuf+1	; index to determine job
	sec
	sbc  #3
	sta  jobnum	; save in jobnum
	asl  a
	sta  channel	; save channel off
	lda  #0
	sta  dirbuf	; even page boundary
	rts
;
;
;
; *************************************
; ***** FAST LOAD FILENAME PARSER *****
; *************************************

set_fil .proc
	ldy  #3		; default .y
	lda  cmdsiz	; delete burst load command
	sec
	sbc  #3
	sta  cmdsiz	; new command size

	lda  cmdbuf+4   ; drv # given ?
	cmp  #':'
	bne  +

	lda  cmdbuf+3
	tax		; save
	and  #'0'
	cmp  #'0'        ; 0:file ?
	bne  +

	cpx  #'1'	; chk for error
	beq  m4

+	lda  cmdbuf+3   ; drv # given ?
	cmp  #':'
	bne  +

	dec  cmdsiz
	iny

+	ldx  #0		; start at cmdbuf+0
-       lda  cmdbuf,y	; extract file-name
	sta  cmdbuf,x
	iny
	inx
	cpx  cmdsiz	; done ?
	bne  -		; delete cmd from buffer

	clc
	.byte skip1
m4	sec		; error
	rts
	.pend


handsk			; .x contains data
-	lda  pb		; debounce
        cmp  pb
        bne  -

	and  #$ff	; set/clr neg flag
        bmi  +		; br, attn low

        eor  fastsr     ; wait for state chg
        and  #4
        beq  -

        stx  sdr	; send it
        lda  fastsr
        eor  #4         ; change state of clk
        sta  fastsr

        lda  #8
-	bit  icr	; wait transmission time
        beq  -

        rts

+	jmp  ptch30	; bye-bye the host wants us
