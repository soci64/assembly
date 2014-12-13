
;  * utility routines

jerrr   ldy  jobn       ; return  job code
        sta  jobs,y

        lda  gcrflg     ; test if buffer left gcr
        beq  +		; no

        jsr  jwtobin    ; convert back to binary

+       jsr  trnoff     ; start timeout on drive

        ldx  savsp
        txs     	; reset stack pointer

        jmp  jtop       ; back to the top

;   motor and stepper control
;   irq into controller every 8ms

jend    .proc
        lda  t1hl2	; set irq timer
	sta  t1hc2

	lda  dskcnt
        and  #$10	; wpsw
        cmp  lwpt       ; same as last
        sta  lwpt       ; update
        bne  m1

        lda  mtrcnt     ; anything to do?
        bne  m7		; dec & finish up

        beq  m2		; nothing to do

m1	lda  #$ff
        sta  mtrcnt     ; 255*8ms motor on time
        jsr  moton

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

	jsr  ptch72	; *** rom ds 05/20/86 ***
	nop
;       lda  #1
;       sta  wpsw

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

        bne  m2		; bra

m7      dec  mtrcnt     ; dec & return
        bne  m2
        lda  drvst
        cmp  #$00       ; motor off & no active drive ?
        bne  m2		; br, do not turn it off something is going on

        jsr  motoff

m2      lda  phase	; test for phase offset
        beq  m5

        cmp  #2
        bne  m3

        lda  #0
        sta  phase
        beq  m5		; bra

m3	sta  steps
        lda  #2
        sta  phase
        jmp  m6

m5	ldx  cdrive     ;  work on active drive only
        bmi  m8		;  no active drive

        lda  drvst      ;  test if motor on
        tay
        cmp  #$20       ;  test if anything to do
        bne  m9		;  something here

m8	jmp  m10	;  motor just running

m9	dec  acltim     ;  dec timer
        bne  m11

        tya     	;  test if acel
        bpl  m12


        and  #$7f       ;  over, clear acel bit
        sta  drvst

m12	and  #$10       ;  test if time out state
        beq  m11

	dec  acltim2	;  decrement second timer
	bne  m11

	jsr  motoff

        lda  #$ff       ;  no active drive now
        sta  cdrive

        lda  #0         ;  drive inactive
        sta  drvst      ;  clear on bit and timout
        beq  m8

m11	tya     	;  test if step needed
        and  #$40
        bne  m13	;  stepping

        jmp  m10

m13	lda  nxtst      ; step or settle
        bne  m18	; go set

	lda  steps
        beq  m17

m6      lda  steps
        bpl  m14

	tya
	pha		; save regs .y
	ldy  #99	; wait for trk_00
m15	lda  pota1	; check for trk_00
	ror  a		; rotate into carry
	php		; save it
	lda  pota1	; debounce it
	ror  a		; => carry
	ror  a		; => bit 7
	plp		; restore carry
	and  #$80	; set/clear sign bit
	bcc  m21

	bpl  m16	; carry set(off) & sign clear(on) exit

	bmi  m20	; bra

m21	bmi  m16	; carry clear(on) & sign set(off) exit

m20	dey
	bne  m15	; wait a while

	bcs  m16	; br, not track 00 ?

	lda  adrsed	; enable/disable track 00 sense
	bne  m16	; br, nope...

	lda  dskcnt	; phase 0
	and  #3
	bne  m16

	pla
	tay		; restore .y

	lda  #0
	sta  steps	; nomore steps
	jmp  m10

m16	pla
	tay		; restore .y

	inc  steps      ; keep stepping
        lda  dskcnt
        sec
        sbc  #1        	; -1 to step out
        jmp  m19

m17	lda  #2         ;  settle time
        sta  acltim
        sta  nxtst      ; show set status
        jmp  m10

m18	dec  acltim
        bne  m10

        lda  drvst
        and  #$ff-$40
        sta  drvst

        lda  #00
        sta  nxtst
        jmp  m10

m14	dec  steps
        lda  dskcnt
        clc
        adc  #01

m19	and  #3
        sta  tmp
        lda  dskcnt
;<><><><><><><><><><><><><><><><><><><><><><><><><><><>
;       and  #$ff-$03   ; mask out old
;       ora  tmp
;	sta  dskcnt
	jmp  ptch0a	; *** rom ds 11/7/86 ***, finish up
	nop		; fill

m10	jmp  ptch0b	; *** rom ds 11/7/86 ***, disable SO

;<><><><><><><><><><><><><><><><><><><><><><><><><><><>

	rts
	.pend
