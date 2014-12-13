;
;
;
;    *contrl
;
;    main controller loop
;
;    scans job que for jobs
;
;   finds job on current track
;   if it exists
;
jlcc
;
        tsx     	;  save current stack pointer
        stx  savsp
;
        bit  t1lc2      ; reset irq flag
;
        lda  pcr2       ;  enable s.o. to 6502
        ora  #$0e       ;  hi output
        sta  pcr2
;
;
;
jtop    ldy  #numjob-1  ;  pointer into job que
;

-       lda  jobs,y     ;  find a job (msb set)
        bmi  +
        dey
        bpl  -
        jmp  jend
+
        cmp  #fread     ;  test if its a jump command
        bne  +
        jmp  jread01

+       cmp  #jumpc     ;  test if its a jump command
        bne  +
        jmp  jex2

+       and  #1         ;  get drive #
        beq  +
;
        sty  jobn
        lda  #$0f       ; bad drive # error
        jmp  jerrr
;
+       tax
        cmp  cdrive     ;  test if current drive
        beq  +
        sta  cdrive
;
        jsr  turnon     ;  turn on drive
        jmp  jend       ;  go clean up
;
;
+       lda  drvst      ;  test if motor up to speed
        bmi  +
;
        asl  a          ;  test if stepping
        bpl  ++         ;  not stepping
;
+       jmp  jend
;
+       lda  #$20       ;  status=running
        sta  drvst
;
        ldy  #numjob-1
        sty  jobn
;
-       jsr  jsetjb
        bmi  jque20
;
jque05  dec  jobn
        bpl  -
;
;
        ldy  nxtjob
        jsr  jsetjb1
;
        lda  nxtrk
        sta  steps
        asl  steps      ;  steps*2
;
        lda  #$60       ;  set status=stepping
        sta  drvst
;
;
        lda  (hdrpnt),y         ;  get dest track #
        sta  drvtrk
jfin    jmp  jend
;
;
jque20  and  #1         ;  test if same drive
        cmp  cdrive
        bne  jque05
;
        lda  drvtrk
        beq  jgotu       ;  uninit. track #
	lda  drvtrk
	cmp  #36
	php
	lda  (hdrpnt),y
	cmp  #36
	ror  a
	plp
	and  #$80
	bcc  +
	bmi  jto
	
        lda  drvtrk
        sbc  #35
        sta  drvtrk
        jmp  jto
        
+       bpl  jto
        lda  drvtrk
        adc  #35
        sta  drvtrk
jto
        sec     	;  calc distance to track
        lda  (hdrpnt),y
        sbc  drvtrk
        beq  jgotu       ;  on track
;
        sta  nxtrk
        lda  jobn       ;  save job# and dist to track
        sta  nxtjob
;
        jmp  jque05
;
jgotu   ldx  #4         ;  set track and sectr
        lda  (hdrpnt),y
        sta  tracc
        
        cmp  #36
        tay
        jsr  set_side
        tya
        bcc  +
        sbc  #35
+	tax
	lda  worktable-1,x
        sta  sectr
;
        lda  dskcnt
        and  #$9f       ;  clear density bits
        ora  sectr
        sta  dskcnt
        lda  num_sec-1,x
        sta  sectr
;
        lda  job        ;  yes, go do the job
        cmp  #bumpc     ;  test for bump
        beq  jbmp
        cmp  #execd
        beq  jex2
        cmp  #frmtt
        beq  +
        jmp  jseak
+       jmp  jformt
;
jex2    lda  jobn       ;  jump to buffer
        clc
        adc  #>bufs
        sta  bufpnt+1
        lda  #0
        sta  bufpnt
        jmp  (bufpnt)
;
;
jbmp
        lda  #$60       ;  set status=stepping
        sta  drvst
;
        lda  dskcnt
        and  #$ff-$03   ;  set phase a
        sta  dskcnt
;
;
        lda  #256-92    ;  step back 45 traks
        sta  steps
;
	lda  side
	bmi  +
        lda  #1         ;  drvtrk now 1
        .byte skip2
+       lda  #36
        sta  drvtrk
;
	lda  #1
        jmp  jerrr      ;  job done return 1
;
;
jsetjb  ldy  jobn
jsetjb1 lda  jobs,y
        pha
        bpl  +         ;  no job here
;
        and  #$78
        sta  job
        tya
        asl  a
        adc  #<hdrs
        sta  hdrpnt
        lda  #>hdrs
        sta  hdrpnt+1
        tya     	;  point at buffer
        clc
        adc  #>bufs
        sta  bufpnt+1
;
;
+       ldy  #0
        sty  bufpnt
;
        pla
        rts
;
;
;
;.end
set_side
	bcs  +
	lda  #0
	.byte skip2
+	lda  #$84
        sta  side
        lda  pota1
        and  #$ff-$04
        ora  side
        sta  pota1
        rts

        .byte $60, $60, $60, $60, $60, $60, $60, $60, $60
        .byte $60, $60, $60, $60, $60, $60, $60, $60
        .byte $40, $40, $40, $40, $40, $40, $40
        .byte $20, $20, $20, $20, $20, $20
        .byte $00, $00, $00, $00, $00

num_sec	.byte $15, $15, $15, $15, $15, $15, $15, $15, $15
	.byte $15, $15, $15, $15, $15, $15, $15, $15
	.byte $13, $13, $13, $13, $13, $13, $13
	.byte $12, $12, $12, $12, $12, $12
	.byte $11, $11, $11, $11, $11
