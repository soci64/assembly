

;******************************************************************************
;******************************************************************************
;
; The almost completely commented C64 ROM disassembly. V1.01 Lee Davison 2012
;

;******************************************************************************
;
; start of the kernal ROM
;
.if Version=3
; version 901227-03
.else
.if Version=2
; version 901227-02
.else
; version 901227-01
.fi
.fi
;

*=      $E000

; EXP() continued

bcEXP2                                  ;                               [E000]
        sta     Jump0054+2              ; save FAC2 rounding byte

        jsr     CpFAC1toFAC22           ; copy FAC1 to FAC2             [BC0F]

        lda     FACEXP                  ; get FAC1 exponent
        cmp     #$88                    ; less than EXP limit?
        bcc     A_E00E                  ; yes, -> 
A_E00B                                  ;                               [E00B]
        jsr     HndlOvUnFlErr           ; handle overflow and underflow [BAD4]
A_E00E                                  ;                               [E00E]
        jsr     bcINT                   ; perform INT()                 [BCCC]
        lda     CHARAC                  ; get mantissa 4 from INT()
        clc                             ; clear carry for add
        adc     #$81                    ; normalise +1, result $00?
        beq     A_E00B                  ; yes, -> go handle it

        sec                             ; set carry for subtract
        sbc     #$01                    ; exponent now correct
        pha                             ; save FAC2 exponent
                                        ; swap FAC1 and FAC2
        ldx     #$05                    ; 4 bytes to do
A_E01E                                  ;                               [E01E]
        lda     ARGEXP,X                ; get FAC2,X
        ldy     FACEXP,X                ; get FAC1,X
        sta     FACEXP,X                ; save FAC1,X
        sty     ARGEXP,X                ; save FAC2,X
        dex                             ; decrement count/index
        bpl     A_E01E                  ; loop if not all done

        lda     Jump0054+2              ; get FAC2 rounding byte
        sta     FACOV                   ; save as FAC1 rounding byte

        jsr     bcMINUS                 ; perform subtraction, FAC2 from FAC1
                                        ;                               [B853]
        jsr     bcGREATER               ; do - FAC1                     [BFB4]

        lda     #<TblEXPseries          ; set counter pointer LB
        ldy     #>TblEXPseries          ; set counter pointer HB
        jsr     CalcPolynome            ; go do series evaluation       [E059]

        lda     #$00                    ; clear A
        sta     ARISGN                  ; clear sign compare (FAC1 EOR FAC2)

        pla                             ;.get saved FAC2 exponent
        jsr     TestAdjFACs2            ; test and adjust accumulators  [BAB9]

        rts


;******************************************************************************
;
; ^2 then series evaluation

Power2                                  ;                               [E043]
        sta     FBUFPT                  ; save count pointer LB
        sty     FBUFPT+1                ; save count pointer HB

        jsr     FAC1toTemp              ; pack FAC1 into FacTempStor    [BBCA]

        lda     #<FacTempStor           ; set pointer LB (Y already $00)
        jsr     FAC1xAY                 ; do convert AY, FCA1*(AY)      [BA28]

        jsr     CalcPolynome2           ; go do series evaluation       [E05D]

        lda     #<FacTempStor           ; pointer to original # LB
        ldy     #>FacTempStor           ; pointer to original # HB
        jmp     FAC1xAY                 ; do convert AY, FCA1*(AY)      [BA28]


;******************************************************************************
;
; do series evaluation

CalcPolynome                            ;                               [E059]
        sta     FBUFPT                  ; save count pointer LB
        sty     FBUFPT+1                ; save count pointer HB

; do series evaluation

CalcPolynome2                           ;                               [E05D]
        jsr     FAC1toTemp5             ; pack FAC1 into FacTempStor+5  [BBC7]

        lda     (FBUFPT),Y              ; get constants count
        sta     SGNFLG                  ; save constants count

        ldy     FBUFPT                  ; get count pointer LB
        iny                             ; increment it (now constants pointer)
        tya                             ; copy it, result = 0?
        bne     A_E06C                  ; no, -> skip next INC

        inc     FBUFPT+1                ; else increment HB
A_E06C                                  ;                               [E06C]
        sta     FBUFPT                  ; save LB

        ldy     FBUFPT+1                ; get HB
A_E070                                  ;                               [E070]
        jsr     FAC1xAY                 ; do convert AY, FCA1*(AY)      [BA28]

        lda     FBUFPT                  ; get constants pointer LB
        ldy     FBUFPT+1                ; get constants pointer HB
        clc                             ; clear carry for add
        adc     #$05                    ; add 5 to low pointer (5 bytes per
                                        ; constant)
        bcc     A_E07D                  ; skip next if no overflow

        iny                             ; increment HB
A_E07D                                  ;                               [E07D]
        sta     FBUFPT                  ; save pointer LB
        sty     FBUFPT+1                ; save pointer HB

        jsr     AddFORvar2FAC1          ; add (AY) to FAC1              [B867]

        lda     #<FacTempStor+5         ; set pointer LB to partial
        ldy     #>FacTempStor+5         ; set pointer HB to partial

        dec     SGNFLG                  ; decrement constants count, done all?
        bne     A_E070                  ; no, -> more...

        rts


;******************************************************************************
;
; RND values

ConstRNDmult                            ;                               [E08D]
.byte   $98,$35,$44,$7A,$00             ; 11879546              multiplier

ConstRNDoffs                            ;                               [E092]
.byte   $68,$28,$B1,$46,$00             ; 3.927677739E-8        offset


;******************************************************************************
;
; perform RND()

bcRND                                   ;                               [E097]
        jsr     GetFacSign              ; get FAC1 sign                 [BC2B]
                                        ; return A = $FF -ve, A = $01 +ve
        bmi     A_E0D3                  ; if (n < 0) copy byte swapped FAC1 into
                                        ; RND() seed
        bne     A_E0BE                  ; if (n > 0) get next number in RND()
                                        ; sequence
; else n=0 so get the RND() number from CIA 1 timers
        jsr     GetAddrIoDevs           ; return base address of I/O devices
                                        ;                               [FFF3]
        stx     INDEX                   ; save pointer LB
        sty     INDEX+1                 ; save pointer HB

        ldy     #$04                    ; set index to T1 LB
        lda     (INDEX),Y               ; get T1 LB
        sta     FacMantissa             ; save FAC1 mantissa 1

        iny                             ; increment index
        lda     (INDEX),Y               ; get T1 HB
        sta     FacMantissa+2           ; save FAC1 mantissa 3

        ldy     #$08                    ; set index to T2 LB
        lda     (INDEX),Y               ; get T2 LB
        sta     FacMantissa+1           ; save FAC1 mantissa 2

        iny                             ; increment index
        lda     (INDEX),Y               ; get T2 HB
        sta     FacMantissa+3           ; save FAC1 mantissa 4

        jmp     J_E0E3                  ; set exponent and exit         [E0E3]


A_E0BE                                  ;                               [E0BE]
        lda     #<RND_seed              ; set seed pointer low address
        ldy     #>RND_seed              ; set seed pointer high address
        jsr     UnpackAY2FAC1           ; unpack memory (AY) into FAC1  [BBA2]

        lda     #<ConstRNDmult          ; set 11879546 pointer LB
        ldy     #>ConstRNDmult          ; set 11879546 pointer HB
        jsr     FAC1xAY                 ; do convert AY, FCA1*(AY)      [BA28]

        lda     #<ConstRNDoffs          ; set 3.927677739E-8 pointer LB
        ldy     #>ConstRNDoffs          ; set 3.927677739E-8 pointer HB
        jsr     AddFORvar2FAC1          ; add (AY) to FAC1              [B867]
A_E0D3                                  ;                               [E0D3]
        ldx     FacMantissa+3           ; get FAC1 mantissa 4
        lda     FacMantissa             ; get FAC1 mantissa 1
        sta     FacMantissa+3           ; save FAC1 mantissa 4
        stx     FacMantissa             ; save FAC1 mantissa 1

        ldx     FacMantissa+1           ; get FAC1 mantissa 2
        lda     FacMantissa+2           ; get FAC1 mantissa 3
        sta     FacMantissa+1           ; save FAC1 mantissa 2
        stx     FacMantissa+2           ; save FAC1 mantissa 3
J_E0E3                                  ;                               [E0E3]
        lda     #$00                    ; clear byte
        sta     FACSGN                  ; clear FAC1 sign (always +ve)

        lda     FACEXP                  ; get FAC1 exponent
        sta     FACOV                   ; save FAC1 rounding byte

        lda     #$80                    ; set exponent = $80
        sta     FACEXP                  ; save FAC1 exponent

        jsr     NormaliseFAC1           ; normalise FAC1                [B8D7]

        ldx     #<RND_seed              ; set seed pointer low address
        ldy     #>RND_seed              ; set seed pointer high address


;******************************************************************************
;
; pack FAC1 into (XY)

PackFAC1intoXY0                         ;                               [E0F6]
        jmp     PackFAC1intoXY          ; pack FAC1 into (XY)           [BBD4]


;******************************************************************************
;
; handle BASIC I/O error

HndlBasIoErr                            ;                               [E0F9]
        cmp     #$F0                    ; error = $F0?
        bne     A_E104                  ; no, -> 

        sty     MEMSIZ+1                ; set end of memory HB
        stx     MEMSIZ                  ; set end of memory LB

        jmp     bcCLR3                  ; clear from start to end and return
                                        ;                               [A663]
; error was not $F0
A_E104                                  ;                               [E104]
        tax                             ; copy error #, zero?
        bne     A_E109                  ; no, -> 

        ldx     #$1E                    ; else error $1E, break error
A_E109                                  ;                               [E109]
        jmp     OutputErrMsg            ; do error #X then warm start   [A437]


;******************************************************************************
;
; output character to channel with error check

OutCharErrChan                          ;                               [E10C]
        jsr     OutByteChan             ; output character to channel   [FFD2]
        bcs     HndlBasIoErr            ; if error go handle BASIC I/O error

        rts


;******************************************************************************
;
; input character from channel with error check

InpCharErrChan                          ;                               [E112]
        jsr     ByteFromChan            ; input character from channel  [FFCF]
        bcs     HndlBasIoErr            ; if error go handle BASIC I/O error

        rts


;******************************************************************************
;
; open channel for output with error check

OpenChan4OutpA                          ;                               [E118]
.if Version=1
        jsr     OpenChan4Outp           ; open channel for output       [FFC9]
.else
        jsr     OpenChan4OutpB          ; open channel for output       [E4AD]
.fi     
        bcs     HndlBasIoErr            ; if error go handle BASIC I/O error

        rts


;******************************************************************************
;
; open channel for input with error check

OpenChan4Inp0                           ;                               [E11E]
        jsr     OpenChan4Inp            ; open channel for input        [FFC6]
        bcs     HndlBasIoErr            ; if error go handle BASIC I/O error

        rts


;******************************************************************************
;
; get character from input device with error check

GetCharFromIO                           ;                               [E124]
        jsr     GetCharInpDev           ; get character from input device [FFE4]
        bcs     HndlBasIoErr            ; if error go handle BASIC I/O error

        rts


;******************************************************************************
;
; perform SYS

bcSYS                                   ;                               [E12A]
        jsr     EvalExpression          ; evaluate expression and check is
                                        ; numeric, else do type mismatch [AD8A]
        jsr     FAC1toTmpInt            ; convert FAC_1 to integer in temporary
                                        ; integer                       [B7F7]
        lda     #>(bcSYS2-1)            ; get return address HB
        pha                             ; push as return address

        lda     #<(bcSYS2-1)            ; get return address LB
        pha                             ; push as return address

        lda     SPREG                   ; get saved status register
        pha                             ; put on stack

        lda     SAREG                   ; get saved A
        ldx     SXREG                   ; get saved X
        ldy     SYREG                   ; get saved Y

        plp                             ; pull processor status

        jmp     (LINNUM)                ; call SYS address

; tail end of SYS code
bcSYS2                                  ;                               [E147]
        php                             ; save status

        sta     SAREG                   ; save returned A
        stx     SXREG                   ; save returned X
        sty     SYREG                   ; save returned Y

        pla                             ; restore saved status
        sta     SPREG                   ; save status

        rts


;******************************************************************************
;
; perform SAVE

bcSAVE                                  ;                               [E156]
        jsr     GetParmLoadSav          ; get parameters for LOAD/SAVE  [E1D4]
S_E159 
        ldx     VARTAB                  ; get start of variables LB
        ldy     VARTAB+1                ; get start of variables HB
        lda     #TXTTAB                 ; index to start of program memory
        jsr     SaveRamToDev            ; save RAM to device, A = index to start
                                        ; address low/high address, XY = end
                                        ;                               [FFD8]
        bcs     HndlBasIoErr            ; if error go handle BASIC I/O error

        rts


;******************************************************************************
;
; perform VERIFY

bcVERIFY                                ;                               [E165]
        lda     #$01                    ; flag verify
.byte   $2C                             ; makes next line BIT $00A9


;******************************************************************************
;
; perform LOAD

bcLOAD                                  ;                               [E168]
        lda     #$00                    ; flag load
        sta     LoadVerify              ; set load/verify flag

        jsr     GetParmLoadSav          ; get parameters for LOAD/SAVE  [E1D4]
S_E16F 
        lda     LoadVerify              ; get load/verify flag
        ldx     TXTTAB                  ; get start of memory LB
        ldy     TXTTAB+1                ; get start of memory HB
        jsr     LoadRamFrmDev           ; load RAM from a device        [FFD5]
        bcs     A_E1D1                  ; if error go handle BASIC I/O error

        lda     LoadVerify              ; get load/verify flag
        beq     A_E195                  ; branch if load

        ldx     #$1C                    ; error $1C, verify error
        jsr     ReadIoStatus            ; read I/O status word          [FFB7]
        and     #$10                    ; mask for tape read error
        bne     A_E19E                  ; branch if read error

        lda     TXTPTR                  ; get the BASIC execute pointer LB
        cmp     #$02                    ; ??? how is TXTPTR used here?
        beq     A_E194                  ; if ??, -> skip "OK" prompt

        lda     #<TxtOK                 ; set "OK" pointer LB
        ldy     #>TxtOK                 ; set "OK" pointer HB
        jmp     OutputString            ; print null terminated string  [AB1E]

A_E194                                  ;                               [E194]
        rts


;******************************************************************************
;
; do READY return to BASIC

A_E195                                  ;                               [E195]
        jsr     ReadIoStatus            ; read I/O status word          [FFB7]
        and     #$BF                    ; clear read error, error found?
        beq     A_E1A1                  ; no, -> 
S_E19C 
        ldx     #$1D                    ; error $1D, load error
A_E19E                                  ;                               [E19E]
        jmp     OutputErrMsg            ; do error #X then warm start   [A437]

A_E1A1                                  ;                               [E1A1]
        lda     TXTPTR+1                ; get BASIC execute pointer HB
        cmp     #$02                    ; immediate mode?
        bne     A_E1B5                  ; no, -> 

        stx     VARTAB                  ; set start of variables LB
        sty     VARTAB+1                ; set start of variables HB

        lda     #<TxtREADY              ; set "READY." pointer LB
        ldy     #>TxtREADY              ; set "READY." pointer HB
        jsr     OutputString            ; print null terminated string  [AB1E]

        jmp     J_A52A                  ; reset execution, clear variables,
                                        ; flush stack, rebuild BASIC chain and
                                        ; do warm start                 [A52A]
A_E1B5                                  ;                               [E1B5]
        jsr     SetBasExecPtr           ; set BASIC execute pointer to start of
                                        ; memory-1                      [A68E]
        jsr     BindLine                ; rebuild BASIC line chaining   [A533]
        jmp     bcCLR4                  ; rebuild BASIC line chaining, do
                                        ; RESTORE and return            [A677]


;******************************************************************************
;
; perform OPEN

bcOPEN                                  ;                               [E1BE]
        jsr     GetParmOpenClo          ; get parameters for OPEN/CLOSE [E219]

        jsr     OpenLogFile             ; open a logical file           [FFC0]
        bcs     A_E1D1                  ; branch if error

        rts


;******************************************************************************
;
; perform CLOSE

bcCLOSE                                 ;                               [E1C7]
        jsr     GetParmOpenClo          ; get parameters for OPEN/CLOSE [E219]

        lda     FORPNT                  ; get logical file number
        jsr     CloseLogFile            ; close a specified logical file [FFC3]
        bcc     A_E194                  ; exit if no error

A_E1D1                                  ;                               [E1D1]
        jmp     HndlBasIoErr            ; go handle BASIC I/O error     [E0F9]


;******************************************************************************
;
; get parameters for LOAD/SAVE

GetParmLoadSav                          ;                               [E1D4]
        lda     #$00                    ; clear filename length
        jsr     SetFileName             ; clear the filename            [FFBD]

        ldx     #$01                    ; set default device number, cassette
        ldy     #$00                    ; set default command
        jsr     SetAddresses            ; set logical, first and second
                                        ; addresses                     [FFBA]
        jsr     ExitIfEotColl           ; exit function if [EOT] or ":" [E206]
        jsr     GetFileName             ; get filename                  [E257]
        jsr     ExitIfEotColl           ; exit function if [EOT] or ":" [E206]
        jsr     GetByte                 ; scan and get byte, else do syntax
                                        ; error then warm start         [E200]
        ldy     #$00                    ; clear command

        stx     FORPNT                  ; save device number

        jsr     SetAddresses            ; set logical, first and second
                                        ; addresses                     [FFBA]
        jsr     ExitIfEotColl           ; exit function if [EOT] or ":" [E206]

        jsr     GetByte                 ; scan and get byte, else do syntax
                                        ; error then warm start         [E200]
        txa                             ; copy command to A
        tay                             ; copy command to Y

        ldx     FORPNT                  ; get device number back
        jmp     SetAddresses            ; set logical, first and second
                                        ; addresses and return          [FFBA]


;******************************************************************************
;
; scan and get byte, else do syntax error then warm start

GetByte                                 ;                               [E200]
        jsr     Chk4ValidByte           ; scan for ",byte", else do syntax error
                                        ; then warm start               [E20E]
        jmp     GetByteParm2            ; get byte parameter and return [B79E]


;******************************************************************************
;
; exit function if [EOT] or ":"

ExitIfEotColl                           ;                               [E206]
        jsr     CHRGOT                  ; scan memory, [EOL] or ":"?    [0079]
        bne     A_E20D                  ; no, -> 

        pla                             ; dump return address LB
        pla                             ; dump return address HB
A_E20D                                  ;                               [E20D]
        rts


;******************************************************************************
;
; scan for ",valid byte", else do syntax error then warm start

Chk4ValidByte                           ;                               [E20E]
        jsr     Chk4Comma               ; scan for ",", else do syntax error
                                        ; then warm start               [AEFD]


;******************************************************************************
;
; scan for valid byte, not [EOL] or ":", else do syntax error then warm start

Chk4ValidByte2                          ;                               [E211]
        jsr     CHRGOT                  ; scan memory, another char?    [0079]
        bne     A_E20D                  ; yes, -> OK

        jmp     SyntaxError             ; syntax error and warm start   [AF08]


;******************************************************************************
;
; get parameters for OPEN/CLOSE

GetParmOpenClo                          ;                               [E219]
        lda     #$00                    ; clear the filename length
        jsr     SetFileName             ; clear the filename            [FFBD]
        jsr     Chk4ValidByte2          ; scan for valid byte, else do syntax
                                        ; error then warm start         [E211]

        jsr     GetByteParm2            ; get byte parameter, logical file
                                        ; number                        [B79E]
        stx     FORPNT                  ; save logical file number
        txa                             ; copy logical file number to A

        ldx     #$01                    ; set default device number, cassette
        ldy     #$00                    ; set default command
        jsr     SetAddresses            ; set logical, first and second
                                        ; addresses                     [FFBA]
        jsr     ExitIfEotColl           ; exit function if [EOT] or ":" [E206]

        jsr     GetByte                 ; scan and get byte, else do syntax
                                        ; error then warm start         [E200]
        stx     FORPNT+1                ; save device number

        ldy     #$00                    ; clear command
        lda     FORPNT                  ; get logical file number

        cpx     #$03                    ; compare device number with screen
        bcc     A_E23F                  ; branch if less than screen

        dey                             ; else decrement command
A_E23F                                  ;                               [E23F]
        jsr     SetAddresses            ; set logical, first and second
                                        ; addresses                     [FFBA]
        jsr     ExitIfEotColl           ; exit function if [EOT] or ":" [E206]
        jsr     GetByte                 ; scan and get byte, else do syntax
                                        ; error then warm start         [E200]
        txa                             ; copy command to A
        tay                             ; copy command to Y

        ldx     FORPNT+1                ; get device number
        lda     FORPNT                  ; get logical file number
        jsr     SetAddresses            ; set logical, first and second
                                        ; addresses                     [FFBA]

        jsr     ExitIfEotColl           ; exit function if [EOT] or ":" [E206]
        jsr     Chk4ValidByte           ; scan for ",byte", else do syntax
                                        ; error then warm start         [E20E]


;******************************************************************************
;
; set filename

GetFileName                             ;                               [E257]
        jsr     EvaluateValue           ; evaluate expression           [AD9E]
        jsr     EvalString              ; evaluate string               [B6A3]

        ldx     INDEX                   ; get string pointer LB
        ldy     INDEX+1                 ; get string pointer HB
        jmp     SetFileName             ; set the filename and return   [FFBD]


;******************************************************************************
;
; perform COS()

bcCOS                                   ;                               [E264]
        lda     #<ConstPIdiv2           ; set pi/2 pointer LB
        ldy     #>ConstPIdiv2           ; set pi/2 pointer HB
        jsr     AddFORvar2FAC1          ; add (AY) to FAC1              [B867]


;******************************************************************************
;
; perform SIN()

bcSIN                                   ;                               [E26B]
        jsr     CopyFAC1toFAC2          ; round and copy FAC1 to FAC2   [BC0C]

        lda     #<ConstPIx2             ; set 2*pi pointer LB
        ldy     #>ConstPIx2             ; set 2*pi pointer HB
        ldx     ARGSGN                  ; get FAC2 sign (b7)
        jsr     FAC1divAY               ; divide by (AY) (X=sign)       [BB07]

        jsr     CopyFAC1toFAC2          ; round and copy FAC1 to FAC2   [BC0C]
        jsr     bcINT                   ; perform INT()                 [BCCC]

        lda     #$00                    ; clear byte
        sta     ARISGN                  ; clear sign compare (FAC1 EOR FAC2)

        jsr     bcMINUS                 ; perform subtraction, FAC2 from FAC1
                                        ;                               [B853]
        lda     #<Const025              ; set 0.25 pointer LB
        ldy     #>Const025              ; set 0.25 pointer HB
        jsr     AYminusFAC1             ; perform subtraction, FAC1 from (AY)
                                        ;                               [B850]
        lda     FACSGN                  ; get FAC1 sign (b7)
        pha                             ; save FAC1 sign
        bpl     bcSIN2                  ; branch if +ve

; FAC1 sign was -ve
        jsr     FAC1plus05              ; add 0.5 to FAC1 (round FAC1)  [B849]

        lda     FACSGN                  ; get FAC1 sign (b7), negative?
        bmi     A_E2A0                  ; yes, -> 

        lda     TANSGN                  ; get the comparison evaluation flag
        eor     #$FF                    ; toggle flag
        sta     TANSGN                  ; save the comparison evaluation flag
bcSIN2                                  ;                               [E29D]
        jsr     bcGREATER               ; do - FAC1                     [BFB4]
A_E2A0                                  ;                               [E2A0]
        lda     #<Const025              ; set 0.25 pointer LB
        ldy     #>Const025              ; set 0.25 pointer HB
        jsr     AddFORvar2FAC1          ; add (AY) to FAC1              [B867]

        pla                             ; restore FAC1 sign, positive
        bpl     A_E2AD                  ; yes, -> 

; else correct FAC1
        jsr     bcGREATER               ; do - FAC1                     [BFB4]
A_E2AD                                  ;                               [E2AD]
        lda     #<ConstVCosSin          ; set pointer LB to counter
        ldy     #>ConstVCosSin          ; set pointer HB to counter
        jmp     Power2                  ; ^2 then series evaluation and return
                                        ;                               [E043]


;******************************************************************************
;
; perform TAN()

bcTAN                                   ;                               [E2B4]
        jsr     FAC1toTemp              ; pack FAC1 into FacTempStor    [BBCA]

        lda     #$00                    ; clear A
        sta     TANSGN                  ; clear the comparison evaluation flag

        jsr     bcSIN                   ; perform SIN()                 [E26B]

        ldx     #<GarbagePtr            ; set sin(n) pointer LB
        ldy     #>GarbagePtr            ; set sin(n) pointer HB
        jsr     PackFAC1intoXY0         ; pack FAC1 into (XY)           [E0F6]

        lda     #<FacTempStor           ; set n pointer LB
        ldy     #>FacTempStor           ; set n pointer HB
        jsr     UnpackAY2FAC1           ; unpack memory (AY) into FAC1  [BBA2]

        lda     #$00                    ; clear byte
        sta     FACSGN                  ; clear FAC1 sign (b7)

        lda     TANSGN                  ; get the comparison evaluation flag
        jsr     bcTAN2                  ; save flag and go do series evaluation
                                        ;                               [E2DC]
        lda     #<GarbagePtr            ; set sin(n) pointer LB
        ldy     #>GarbagePtr            ; set sin(n) pointer HB
        jmp     AYdivFAC1               ; convert AY and do (AY)/FAC1   [BB0F]


;******************************************************************************
;
; save comparison flag and do series evaluation

bcTAN2                                  ;                               [E2DC]
        pha                             ; save comparison flag
        jmp     bcSIN2                  ; add 0.25, ^2 then series evaluation
                                        ;                               [E29D]


;******************************************************************************
;
; constants and series for SIN/COS(n)

ConstPIdiv2                             ;                               [E2E0]
.byte   $81,$49,$0F,$DA,$A2             ; 1.570796371, pi/2, as floating number
ConstPIx2                               ;                               [E2E5]
.byte   $83,$49,$0F,$DA,$A2             ; 6.28319, 2*pi, as floating number
Const025                                ;                               [E2EA]
.byte   $7F,$00,$00,$00,$00             ; 0.25

ConstVCosSin                            ;                               [E2EF]
.byte   $05                             ; series counter
.byte   $84,$E6,$1A,$2D,$1B             ; -14.3813907
.byte   $86,$28,$07,$FB,$F8             ;  42.0077971
.byte   $87,$99,$68,$89,$01             ; -76.7041703
.byte   $87,$23,$35,$DF,$E1             ;  81.6052237
.byte   $86,$A5,$5D,$E7,$28             ; -41.3417021
.byte   $83,$49,$0F,$DA,$A2             ;  6.28318531


;******************************************************************************
;
; perform ATN()

bcATN                                   ;                               [E30E]
        lda     FACSGN                  ; get FAC1 sign (b7)
        pha                             ; save sign, positive?
        bpl     A_E316                  ; yes, -> 

        jsr     bcGREATER               ; else do - FAC1                [BFB4]
A_E316                                  ;                               [E316]
        lda     FACEXP                  ; get FAC1 exponent
        pha                             ; push exponent
        cmp     #$81                    ; smaller than 1 ?
        bcc     A_E324                  ; yes, -> 

        lda     #<Constant1             ; pointer to 1 LB
        ldy     #>Constant1             ; pointer to 1 HB
        jsr     AYdivFAC1               ; convert AY and do (AY)/FAC1   [BB0F]
A_E324                                  ;                               [E324]
        lda     #<ConstATN              ; pointer to series LB
        ldy     #>ConstATN              ; pointer to series HB
        jsr     Power2                  ; ^2 then series evaluation     [E043]

        pla                             ; restore old FAC1 exponent
        cmp     #$81                    ; smaller than 1 ?
        bcc     A_E337                  ; yes, -> 

        lda     #<ConstPIdiv2           ; pointer to (pi/2) LB
        ldy     #>ConstPIdiv2           ; pointer to (pi/2) LB
        jsr     AYminusFAC1             ; perform subtraction, FAC1 from (AY)
                                        ;                               [B850]
A_E337                                  ;                               [E337]
        pla                             ; restore FAC1 sign, positive
        bpl     A_E33D                  ; yes, -> 

        jmp     bcGREATER               ; else do - FAC1 and return     [BFB4]

A_E33D                                  ;                               [E33D]
        rts


;******************************************************************************
;
; series for ATN(n)

ConstATN                                ;                               [E33E]
.byte   $0B                             ; series counter
.byte   $76,$B3,$83,$BD,$D3             ;-6.84793912e-04
.byte   $79,$1E,$F4,$A6,$F5             ; 4.85094216e-03
.byte   $7B,$83,$FC,$B0,$10             ;-0.0161117015
.byte   $7C,$0C,$1F,$67,$CA             ; 0.034209638
.byte   $7C,$DE,$53,$CB,$C1             ;-0.054279133
.byte   $7D,$14,$64,$70,$4C             ; 0.0724571965
.byte   $7D,$B7,$EA,$51,$7A             ;-0.0898019185
.byte   $7D,$63,$30,$88,$7E             ; 0.110932413
.byte   $7E,$92,$44,$99,$3A             ;-0.142839808
.byte   $7E,$4C,$CC,$91,$C7             ; 0.19999912
.byte   $7F,$AA,$AA,$AA,$13             ;-0.333333316
.byte   $81,$00,$00,$00,$00             ; 1.000000000


;******************************************************************************
;
; BASIC warm start entry point

BasicWarmStart                          ;                               [E37B]
        jsr     CloseIoChannls          ; close input and output channels [FFCC]

        lda     #$00                    ; clear A
        sta     CurIoChan               ; set current I/O channel, flag default

        jsr     ClrBasicStack           ; flush BASIC stack and clear continue
                                        ; pointer                       [A67A]
        cli                             ; enable the interrupts
BasWarmStart2                           ;                               [E386]
        ldx     #$80                    ; set -ve error, just do warm start
        jmp     (IERROR)                ; go handle error message, normally
                                        ; BasWarmStart3 = $E38b, here below
BasWarmStart3                           ;                               [E38B]
        txa                             ; copy the error number, negative?
        bmi     A_E391                  ; yes, -> do warm start

        jmp     OutputErrMsg2           ; else do error #X then warm start
                                        ;                               [A43A]

A_E391                                  ;                               [E391]
        jmp     OutputREADY             ; do warm start                 [A474]


;******************************************************************************
;
; BASIC cold start entry point

BasicColdStart                          ;                               [E394]
        jsr     InitBasicVec            ; initialise the BASIC vector table
                                        ;                               [E453]
        jsr     InitBasicRAM            ; initialise the BASIC RAM locations
                                        ;                               [E3BF]
        jsr     InitMemory              ; print the start up message and
                                        ; initialise the memory pointers [E422]
S_E39D 
        ldx     #$FB                    ; value for start stack
        txs                             ; set stack pointer
        bne     BasWarmStart2           ; do "READY." warm start, branch always


;******************************************************************************
;
; character get subroutine for zero page

; the target address for the LDA $EA60 becomes the BASIC execute pointer once
; the block is copied to its destination, any non zero page address will do at
; assembly time, to assemble a three byte instruction. $EA60 is RTS, NOP.

; page 0 initialisation table from CHRGET
; increment and scan memory

DataCHRGET                              ;                               [E3A2]
        inc     TXTPTR                  ; increment BASIC execute pointer low
                                        ; byte, became zero?
        bne     A_E3A8                  ; no, -> 

        inc     TXTPTR+1                ; inc. BASIC execute pointer HB

; page 0 initialisation table from CHRGOT
; scan memory

A_E3A8                                  ;                               [E3A8]
        lda     $EA60                   ; get byte to scan, address set by call
                                        ; routine
        cmp     #':'                    ; above ":"?
        bcs     A_E3B9                  ; yes, -> exit

; page 0 initialisation table from P_0080
; clear Cb if numeric

        cmp     #' '                    ; space?
        beq     DataCHRGET              ; yes, -> 

        sec                             ; set carry for SBC
        sbc     #'0'                    ; subtract "0"

        sec                             ; set carry for SBC
        sbc     #$D0                    ; subtract -"0"
; If the character was between "0" and "9", then the Xarry is cleared now.

A_E3B9                                  ;                               [E3B9]
        rts


;******************************************************************************
;
; spare bytes, not referenced

;S_E3BA
.byte   $80,$4F,$C7,$52,$58             ; 0.811635157


;******************************************************************************
;
; initialise BASIC RAM locations

InitBasicRAM                            ;                               [E3BF]
        lda     #$4C                    ; opcode for JMP
        sta     Jump0054                ; save for functions vector jump
        sta     UserJump                ; save for USR() vector jump, set USR()
                                        ; vector to illegal quantity error
        lda     #<IllegalQuant          ; set USR() vector LB
        ldy     #>IllegalQuant          ; set USR() vector HB
        sta     USRADD                  ; save USR() vector LB
        sty     USRADD+1                ; save USR() vector HB

        lda     #<ConvertAY2FAC1        ; set fixed to float vector LB
        ldy     #>ConvertAY2FAC1        ; set fixed to float vector HB
        sta     ADRAY2                  ; save fixed to float vector LB
        sty     ADRAY2+1                ; save fixed to float vector HB

        lda     #<Float2Fixed           ; set float to fixed vector LB
        ldy     #>Float2Fixed           ; set float to fixed vector HB
        sta     ADRAY1                  ; save float to fixed vector LB
        sty     ADRAY1+1                ; save float to fixed vector HB

; copy the character get subroutine from DataCHRGET to CHRGET (= $0073)

        ldx     #$1C                    ; set the byte count
A_E3E2                                  ;                               [E3E2]
        lda     DataCHRGET,X            ; get a byte from the table
        sta     CHRGET,X                ; save the byte in page zero

        dex                             ; decrement the count
        bpl     A_E3E2                  ; loop if not all done

; clear descriptors, strings, program area and mamory pointers

        lda     #$03                    ; set step size, collecting descriptors
        sta     GarbColStep             ; save the garbage collection step size

        lda     #$00                    ; clear A
        sta     BITS                    ; clear FAC1 overfLB
        sta     CurIoChan               ; clear current I/O chan, flag default
        sta     LASTPT+1                ; clear current descriptor stack item
                                        ; pointer HB

        ldx     #$01                    ; set X
        stx     STACK+$FD               ; set the chain link pointer LB
        stx     STACK+$FC               ; set the chain link pointer HB

        ldx     #LASTPT+2               ; initial the value for descriptor stack
        stx     TEMPPT                  ; set descriptor stack pointer

        sec                             ; Carry = 1 to read the bottom of memory
        jsr     BottomOfMem             ; read/set the bottom of memory [FF9C]
        stx     TXTTAB                  ; save the start of memory LB
        sty     TXTTAB+1                ; save the start of memory HB

        sec                             ; set Cb = 1 to read the top of memory
        jsr     TopOfMem                ; read/set the top of memory    [FF99]
        stx     MEMSIZ                  ; save the end of memory LB
        sty     MEMSIZ+1                ; save the end of memory HB
        stx     FRETOP                  ; set bottom of string space LB
        sty     FRETOP+1                ; set bottom of string space HB

        ldy     #$00                    ; clear the index
        tya                             ; clear the A
        sta     (TXTTAB),Y              ; clear the the first byte of memory

        inc     TXTTAB                  ; increment the start of memory LB
        bne     A_E421                  ; if no rollover, skip next INC

        inc     TXTTAB+1                ; increment start of memory HB
A_E421                                  ;                               [E421]
        rts


;******************************************************************************
;
; print the start up message and initialise the memory pointers

InitMemory                              ;                               [E422]
        lda     TXTTAB                  ; get the start of memory LB
        ldy     TXTTAB+1                ; get the start of memory HB
        jsr     CheckAvailMem           ; check available memory, do out of
                                        ; memory error if no room       [A408]

        lda     #<TxtCommodore64        ; set text pointer LB
        ldy     #>TxtCommodore64        ; set text pointer HB
S_E42D 
        jsr     OutputString            ; print a null terminated string [AB1E]

        lda     MEMSIZ                  ; get the end of memory LB
        sec                             ; set carry for subtract
        sbc     TXTTAB                  ; subtract the start of memory LB
        tax                             ; copy the result to X

        lda     MEMSIZ+1                ; get the end of memory HB
        sbc     TXTTAB+1                ; subtract the start of memory HB
        jsr     PrintXAasInt            ; print XA as unsigned integer  [BDCD]

        lda     #<BasicBytesFree        ; set " BYTES FREE" pointer LB
        ldy     #>BasicBytesFree        ; set " BYTES FREE" pointer HB
        jsr     OutputString            ; print a null terminated string [AB1E]

        jmp     bcNEW2                  ; do NEW, CLEAR, RESTORE and return
                                        ;                               [A644]


;******************************************************************************
;
; BASIC vectors, these are copied to RAM from IERROR onwards

TblBasVectors                           ;                               [E447]
.word   BasWarmStart3                   ; error message                 IERROR
.word   MainWaitLoop2                   ; BASIC warm start              IMAIN
.word   Text2TokenCod2                  ; crunch BASIC tokens           ICRNCH
.word   TokCode2Text2                   ; uncrunch BASIC tokens         IQPLOP
.word   InterpretLoop3                  ; start new BASIC code          IGONE
.word   GetNextParm2                    ; get arithmetic element        IEVAL


;******************************************************************************
;
; initialise the BASIC vectors

InitBasicVec                            ;                               [E453]
        ldx     #$0B                    ; set byte count
A_E455                                  ;                               [E455]
        lda     TblBasVectors,X         ; get byte from table
        sta     IERROR,X                ; save byte to RAM

        dex                             ; decrement index
        bpl     A_E455                  ; loop if more to do

        rts


;******************************************************************************
;
;S_E45F
.byte   $00                             ; unused byte ??


;******************************************************************************
;
; BASIC startup messages

BasicBytesFree                          ;                               [E460]
.text   " BASIC BYTES FREE",$0D,$00

TxtCommodore64                          ;                               [E473]
.byte   $93,$0D
.text   "    **** COMMODORE 64 BASIC V2 ****"
.byte   $0D, $0D
.text   " 64K RAM SYSTEM  "
.byte   $00


.if Version=3
E4AC    .byte   $81                     ; unused byte ??
.else
.if Version=2
E4AC    .byte   $5C                     ; unused byte ??
.else
E4AC    .byte   $2B                     ; unused byte ??
.fi
.fi


.if Version=1
.fill 83,$AA
.else
;******************************************************************************
;
; open channel for output

OpenChan4OutpB                          ;                               [E4AD]
        pha                             ; save the flag byte

        jsr     OpenChan4Outp           ; open channel for output       [FFC9]
        tax                             ; copy the returned flag byte

        pla                             ; restore the alling flag byte
        bcc     A_E4B6                  ; if no error, skip copying error flag

        txa                             ; else copy the error flag
A_E4B6                                  ;                               [E4B6]
        rts


E4B7 
.fill 28,$AA                            ; unused


.if Version=3
;******************************************************************************
;
; flag the RS232 start bit and set the parity

RS232_SaveSet                           ;                               [E4D3]
        sta     RINONE                  ; save the start bit check flag, set
                                        ; start bit received
        lda     #$01                    ; set the initial parity state
        sta     RIPRTY                  ; save the receiver parity bit

        rts


;******************************************************************************
;
; save the current colour to the colour RAM

SaveCurColour                           ;                               [E4DA]
        lda     COLOR                   ; get the current colour code
.else
.fill 7,$AA                             ; unused


SaveCurColour                           ;                               [E4DA]
        lda     VICBAC0                 ; backgroundcolor 0
.fi
        sta     (ColorRamPtr),Y         ; save it to the colour RAM

        rts


;******************************************************************************
;
; wait ~8.5 seconds for any key from the STOP key column

Wait8Seconds                            ;                               [E4E0]
        adc     #$02                    ; set the number of jiffies to wait
A_E4E2                                  ;                               [E4E2]
        ldy     StopKey                 ; read the stop key column
        iny                             ; test for $FF, no keys pressed
        bne     A_E4EB                  ; if any keys were pressed just exit

        cmp     TimeBytes+1             ; compare the wait time with the jiffy
                                        ; clock mid byte
        bne     A_E4E2                  ; if not there yet go wait some more

A_E4EB                                  ;                               [E4EB]
        rts


;******************************************************************************
;
; baud rate word is calculated from ..
;
; (system clock / baud rate) / 2 - 100
;
;               system clock
;               ------------
; PAL             985248 Hz
; NTSC           1022727 Hz

; baud rate tables for PAL C64

TblBaudRates                            ;                               [E4EC]
.word   $2619                           ;   50   baud   985300
.word   $1944                           ;   75   baud   985200
.word   $111A                           ;  110   baud   985160
.word   $0DE8                           ;  134.5 baud   984540
.word   $0C70                           ;  150   baud   985200
.word   $0606                           ;  300   baud   985200
.word   $02D1                           ;  600   baud   985200
.word   $0137                           ; 1200   baud   986400
.word   $00AE                           ; 1800   baud   986400
.word   $0069                           ; 2400   baud   984000

.fi


;******************************************************************************
;
; return the base address of the I/O devices

GetAddrIoDevs2                          ;                               [E500]
        ldx     #<CIA1DRA               ; get the I/O base address LB
        ldy     #>CIA1DRA               ; get the I/O base address HB
        rts


;******************************************************************************
;
; return the x,y organization of the screen

GetSizeScreen2                          ;                               [E505]
        ldx     #$28                    ; get the x size
        ldy     #$19                    ; get the y size
        rts


;******************************************************************************
;
; read/set the x,y cursor position

CursorPosXY2                            ;                               [E50A]
        bcs     A_E513                  ; if Carry set -> do read

; Set the cursor position
        stx     PhysCurRow              ; save the cursor row
        sty     LineCurCol              ; save the cursor column
        jsr     CalcCursorPos           ; set the screen pointers for the
                                        ; cursor row, column            [E56C]
A_E513                                  ;                               [E513]
        ldx     PhysCurRow              ; get the cursor row
        ldy     LineCurCol              ; get the cursor column
        rts


;******************************************************************************
;
; initialise the screen and keyboard

InitScreenKeyb                          ;                               [E518]
        jsr     InitVideoIC             ; initialise the vic chip       [E5A0]

        lda     #$00                    ; clear A
        sta     MODE                    ; clear the shift mode switch
        sta     BLNON                   ; clear the cursor blink phase

        lda     #<ShftCtrlCbmKey        ; get the keyboard decode logic pointer
                                        ; LB
        sta     KEYLOG                  ; save the keyboard decode logic pointer
                                        ; LB

        lda     #>ShftCtrlCbmKey        ; get the keyboard decode logic pointer
                                        ; HB
        sta     KEYLOG+1                ; save the keyboard decode logic pointer
                                        ; HB
        lda     #$0A                    ; set maximum size of keyboard buffer
        sta     XMAX                    ; save maximum size of keyboard buffer
        sta     DELAY                   ; save the repeat delay counter

        lda     #$0E                    ; set light blue
        sta     COLOR                   ; save the current colour code

        lda     #$04                    ; speed 4
        sta     KOUNT                   ; save the repeat speed counter

        lda     #$0C                    ; set the cursor flash timing
        sta     BLNCT                   ; save the cursor timing countdown
        sta     BLNSW                   ; save cursor enable, $00 = flash cursor


;******************************************************************************
;
; clear the screen

ClearScreen                             ;                               [E544]
        lda     HIBASE                  ; get the screen memory page
        ora     #$80                    ; set the high bit, flag every line is
                                        ; a logical line start
        tay                             ; copy to Y

        lda     #$00                    ; clear the line start LB
        tax                             ; clear the index
A_E54D                                  ;                               [E54D]
        sty     LDTB1,X                 ; save start of line X pointer HB

        clc                             ; clear carry for add
        adc     #$28                    ; add the line length to the LB
        bcc     A_E555                  ; if no rollover skip the HB
                                        ; increment
        iny                             ; else increment the HB
A_E555                                  ;                               [E555]
        inx                             ; increment the line index
        cpx     #$1A                    ; compare it with number of lines + 1
        bne     A_E54D                  ; loop if not all done

        lda     #$FF                    ; set the end of table marker
        sta     LDTB1,X                 ; mark the end of the table

        ldx     #$18                    ; set the line count, 25 lines to do,
                                        ; 0 to 24
A_E560                                  ;                               [E560]
        jsr     ClearLineX              ; clear screen line X           [E9FF]

        dex                             ; decrement the count
        bpl     A_E560                  ; loop if more to do


;******************************************************************************
;
; home the cursor

CursorHome                              ;                               [E566]
        ldy     #$00                    ; clear Y
        sty     LineCurCol              ; clear the cursor column
        sty     PhysCurRow              ; clear the cursor row


;******************************************************************************
;
; set screen pointers for cursor row, column

CalcCursorPos                           ;                               [E56C]
        ldx     PhysCurRow              ; get the cursor row
        lda     LineCurCol              ; get the cursor column
A_E570                                  ;                               [E570]
        ldy     LDTB1,X                 ; get start of line X pointer HB
        bmi     A_E57C                  ; if it is logical line start, continue

        clc                             ; else clear carry for add
        adc     #$28                    ; add one line length
        sta     LineCurCol              ; save the cursor column

        dex                             ; decrement the cursor row
        bpl     A_E570                  ; loop, branch always

A_E57C                                  ;                               [E57C]
.if Version=3
        jsr     FetchScreenAddr         ; fetch a screen address        [E9F0]

        lda     #$27                    ; set the line length

        inx                             ; increment the cursor row
A_E582                                  ;                               [E582]
        ldy     LDTB1,X                 ; get the start of line X pointer HB
        bmi     A_E58C                  ; if logical line start exit

        clc                             ; else clear carry for add
        adc     #$28                    ; add one line length to the current
                                        ; line length
        inx                             ; increment the cursor row
        bpl     A_E582                  ; loop, branch always

A_E58C                                  ;                               [E58C]
        sta     CurLineLeng             ; save current screen line length

        jmp     PtrCurLineColRAM        ; calculate the pointer to colour RAM
                                        ; and return                    [EA24]

SetPtrLogLine                           ;                               [E591]
        cpx     CursorRow               ; compare it with the input cursor row
        beq     A_E598                  ; if there just exit

        jmp     GoStartOfLine           ; else go ??                    [E6ED]

A_E598                                  ;                               [E598]
        rts

        nop
.else
        lda     LDTB1,X                 ; get the start of line X pointer HB
        and     #$03
        ora     HIBASE
        sta     CurScrLine+1

        lda     TblScrLinesLB,X
        sta     CurScrLine

        lda     #$27                    ; set the line length

        inx
A_E58D                                  ;                               [E58D]
        ldy     LDTB1,X                 ; get the start of line X pointer HB
        bmi     A_E597                  ; if logical line start exit

        clc                             ; else clear carry for add
        adc     #$28                    ; add one line length to the current
                                        ; line length
        inx                             ; increment the cursor row
        bpl     A_E58D                  ; loop, branch always

A_E597                                  ;                               [E597]
        sta     CurLineLeng

        rts
.fi

; Left overs from what ???
        jsr     InitVideoIC             ; initialise the vic chip       [E5A0]
        jmp     CursorHome              ; home the cursor and return    [E566]


;******************************************************************************
;
; initialise the vic chip

InitVideoIC                             ;                               [E5A0]
        lda     #$03                    ; set the screen as the output device
        sta     DFLTO                   ; save the output device number

        lda     #$00                    ; set the keyboard as the input device
        sta     DFLTN                   ; save the input device number

        ldx     #$2F                    ; set the count/index
A_E5AA                                  ;                               [E5AA]
        lda     TblValuesVIC-1,X        ; get a vic ii chip initialisation value
        sta     VIC_chip-1,X            ; save it to the vic ii chip

        dex                             ; decrement the count/index
        bne     A_E5AA                  ; loop if more to do

        rts


;******************************************************************************
;
; input from the keyboard buffer

GetCharKeybBuf                          ;                               [E5B4]
        ldy     KeyboardBuf             ; get the current character from buffer
        ldx     #$00                    ; clear the index
A_E5B9                                  ;                               [E5B9]
        lda     KeyboardBuf+1,X         ; get next character from the buffer
        sta     KeyboardBuf,X           ; save it as current character in buffer

        inx                             ; increment the index
        cpx     NDX                     ; compare it with keyboard buffer index
        bne     A_E5B9                  ; loop if more to do

        dec     NDX                     ; decrement keyboard buffer index

        tya                             ; copy the key to A

        cli                             ; enable the interrupts
        clc                             ; flag got byte

        rts


;******************************************************************************
;
; write character and wait for key

OutCharWaitKey                          ;                               [E5CA]
        jsr     OutputChar              ; output character              [E716]


;******************************************************************************
;
; wait for a key from the keyboard

WaitForKey                              ;                               [E5CD]
        lda     NDX                     ; get the keyboard buffer index
        sta     BLNSW                   ; cursor enable, $00 = flash cursor,
                                        ; $xx = no flash
        sta     AUTODN                  ; screen scrolling flag, $00 = scroll,
                                        ; $xx = no scroll. This disables both
                                        ; the cursor flash and the screen scroll
                                        ; while there are characters in the
                                        ; keyboard buffer
        beq     WaitForKey              ; loop if the buffer is empty

        sei                             ; disable the interrupts

        lda     BLNON                   ; get the cursor blink phase
        beq     A_E5E7                  ; if cursor phase skip the overwrite

; else it is the character phase
        lda     GDBLN                   ; get the character under the cursor
        ldx     GDCOL                   ; get the colour under the cursor

        ldy     #$00                    ; clear Y
        sty     BLNON                   ; clear the cursor blink phase

        jsr     PrntCharA_ColX          ; print character A and colour X [EA13]
A_E5E7                                  ;                               [E5E7]
        jsr     GetCharKeybBuf          ; input from the keyboard buffer [E5B4]
        cmp     #$83                    ; compare with [SHIFT][RUN]
        bne     A_E5FE                  ; if not [SHIFT][RUN] skip buffer fill

; keys are [SHIFT][RUN] so put "LOAD",$0D,"RUN",$0D into
; the buffer
        ldx     #$09                    ; set the byte count
        sei                             ; disable the interrupts
        stx     NDX                     ; set the keyboard buffer index
A_E5F3                                  ;                               [E5F3]
        lda     TblAutoLoadRun-1,X      ; get byte from the auto load/run table
        sta     KeyboardBuf-1,X         ; save it to the keyboard buffer

        dex                             ; decrement the count/index
        bne     A_E5F3                  ; loop while more to do

        beq     WaitForKey              ; always -> loop for the next key

; was not [SHIFT][RUN]
A_E5FE                                  ;                               [E5FE]
        cmp     #$0D                    ; compare the key with [CR]
        bne     OutCharWaitKey          ; if not [CR] print the character and
                                        ; get the next key
; else it was [CR]
        ldy     CurLineLeng             ; get the current screen line length
        sty     CRSW                    ; input from keyboard or screen,
                                        ; $xx = screen, $00 = keyboard
A_E606                                  ;                               [E606]
        lda     (CurScrLine),Y          ; get the character from the current
                                        ; screen line
        cmp     #' '                    ; compare it with [SPACE]
        bne     A_E60F                  ; if not [SPACE] continue

        dey                             ; else eliminate the space, decrement
                                        ; end of input line
        bne     A_E606                  ; loop, branch always

A_E60F                                  ;                               [E60F]
        iny                             ; increment past the last non space
                                        ; character on line
        sty     INDX                    ; save the input [EOL] pointer

        ldy     #$00                    ; clear A
        sty     AUTODN                  ; clear the screen scrolling flag,
                                        ; $00 = scroll
        sty     LineCurCol              ; clear the cursor column
        sty     QTSW                    ; clear the cursor quote flag,
                                        ; $xx = quote, $00 = no quote
        lda     CursorRow               ; get the input cursor row
        bmi     A_E63A                  ;.

        ldx     PhysCurRow              ; get the cursor row
.if Version=3
        jsr     SetPtrLogLine           ; find and set the pointers for the
.else
        jsr     GoStartOfLine           ; start of logical line         [E591]
.fi
        cpx     CursorRow               ; compare with input cursor row
        bne     A_E63A                  ;.

        lda     CursorCol               ; get the input cursor column
        sta     LineCurCol              ; save the cursor column

        cmp     INDX                    ; compare the cursor column with input
                                        ; [EOL] pointer
        bcc     A_E63A                  ; if less, cursor is in line, go ??
        bcs     A_E65D                  ; alway ->


;******************************************************************************
;
; input from screen or keyboard

InputScrKeyb                            ;                               [E632]
        tya                             ; copy Y
        pha                             ; save Y

        txa                             ; copy X
        pha                             ; save X

        lda     CRSW                    ; input from keyboard or screen,
                                        ; $xx = screen, $00 = keyboard
        beq     WaitForKey              ; if keyboard go wait for key
A_E63A                                  ;                               [E63A]
        ldy     LineCurCol              ; get the cursor column
        lda     (CurScrLine),Y          ; get character from current screen line
        sta     TEMPD7                  ; save temporary last character

        and     #$3F                    ; mask key bits
        asl     TEMPD7                  ; << temporary last character
        bit     TEMPD7                  ; test it
        bpl     A_E64A                  ; branch if not [NO KEY]

        ora     #$80                    ;.
A_E64A                                  ;                               [E64A]
        bcc     A_E650                  ;.

        ldx     QTSW                    ; get the cursor quote flag,
                                        ; $xx = quote, $00 = no quote
        bne     A_E654                  ; if in quote mode go ??

A_E650                                  ;                               [E650]
        bvs     A_E654                  ;.

        ora     #$40                    ;.
A_E654                                  ;                               [E654]
        inc     LineCurCol              ; increment the cursor column

        jsr     ToggleCursorFlg         ; if open quote toggle cursor quote
                                        ; flag                          [E684]
        cpy     INDX                    ; compare ?? with input [EOL] pointer
        bne     A_E674                  ; if not at line end go ??

A_E65D                                  ;                               [E65D]
        lda     #$00                    ; clear A
        sta     CRSW                    ; clear input from keyboard or screen,
                                        ; $xx = screen, $00 = keyboard
        lda     #$0D                    ; set character [CR]

        ldx     DFLTN                   ; get the input device number
        cpx     #$03                    ; compare the input device with screen
        beq     A_E66F                  ; if screen go ??

        ldx     DFLTO                   ; get the output device number
        cpx     #$03                    ; compare the output device with screen
        beq     A_E672                  ; if screen go ??

A_E66F                                  ;                               [E66F]
        jsr     OutputChar              ; output the character          [E716]
A_E672                                  ;                               [E672]
        lda     #$0D                    ; set character [CR]
A_E674                                  ;                               [E674]
        sta     TEMPD7                  ; save character

        pla                             ; pull X
        tax                             ; restore X

        pla                             ; pull Y
        tay                             ; restore Y

        lda     TEMPD7                  ; restore character
        cmp     #$DE                    ;.
        bne     A_E682                  ;.

        lda     #$FF                    ;.
A_E682                                  ;                               [E682]
        clc                             ; flag ok
        rts


;******************************************************************************
;
; if open quote toggle cursor quote flag

ToggleCursorFlg                         ;                               [E684]
        cmp     #'"'                    ; compare byte with "
        bne     A_E690                  ; exit if not "

        lda     QTSW                    ; get cursor quote flag, $xx = quote,
                                        ; $00 = no quote
        eor     #$01                    ; toggle it
        sta     QTSW                    ; save cursor quote flag

        lda     #'"'                    ; restore the "
A_E690                                  ;                               [E690]
        rts


;******************************************************************************
;
; insert uppercase/graphic character

UpcChar2Screen                          ;                               [E691]
        ora     #$40                    ; change to uppercase/graphic
Char2Screen                             ;                               [E693]
        ldx     RVS                     ; get the reverse flag
        beq     A_E699                  ; branch if not reverse

; else ..
; insert reversed character

ReverseChar                             ;                               [E697]
        ora     #$80                    ; reverse character
A_E699                                  ;                               [E699]
        ldx     InsertCount             ; get the insert count
        beq     A_E69F                  ; branch if none

        dec     InsertCount             ; else decrement the insert count
A_E69F                                  ;                               [E69F]
        ldx     COLOR                   ; get the current colour code
        jsr     PrntCharA_ColX          ; print character A and colour X [EA13]
        jsr     AdvanceCursor           ; advance the cursor            [E6B6]

; restore the registers, set the quote flag and exit
RestorRegsQuot                          ;                               [E6A8]
        pla                             ; pull Y
        tay                             ; restore Y

        lda     InsertCount             ; get the insert count, inserts to do?
        beq     A_E6B0                  ; no, -> 

        lsr     QTSW                    ; clear cursor quote flag, $xx = quote,
                                        ; $00 = no quote
A_E6B0                                  ;                               [E6B0]
        pla                             ; pull X
        tax                             ; restore X

        pla                             ; restore A

        clc                             ;.
        cli                             ; enable the interrupts

        rts


;******************************************************************************
;
; advance the cursor

AdvanceCursor                           ;                               [E6B6]
        jsr     Test4LineIncr           ; test for line increment       [E8B3]

        inc     LineCurCol              ; increment the cursor column

        lda     CurLineLeng             ; get current screen line length
        cmp     LineCurCol              ; compare ?? with the cursor column
        bcs     A_E700                  ; exit if line length >= cursor column

        cmp     #$4F                    ; compare with max length
        beq     A_E6F7                  ; if at max clear column, back cursor
                                        ; up and do newline
        lda     AUTODN                  ; get the autoscroll flag
        beq     A_E6CD                  ; branch if autoscroll on

        jmp     InsertLine2             ;.else open space on screen     [E967]

A_E6CD                                  ;                               [E6CD]
        ldx     PhysCurRow              ; get the cursor row
        cpx     #$19                    ; compare with max + 1
        bcc     AddRow2CurLine          ; if less than max + 1 go add this row
                                        ; to the current logical line

        jsr     ScrollScreen            ; else scroll the screen        [E8EA]

        dec     PhysCurRow              ; decrement the cursor row
        ldx     PhysCurRow              ; get the cursor row

; add this row to the current logical line

AddRow2CurLine                          ;                               [E6DA]
        asl     LDTB1,X                 ; clear bit 7 of start of line X ...
        lsr     LDTB1,X                 ;    ... HB back

; make next screen line start of logical line, increment line length and set
; pointers, set b7, start of logical line
        inx                             ; increment screen row

        lda     LDTB1,X                 ; get start of line X pointer HB
        ora     #$80                    ; mark as start of logical line
        sta     LDTB1,X                 ; set start of line X pointer HB

        dex                             ; restore screen row

        lda     CurLineLeng             ; get current screen line length

; add one line length and set the pointers for the start of the line

        clc                             ; clear carry for add
        adc     #$28                    ; add one line length
        sta     CurLineLeng             ; save current screen line length
GoStartOfLine                           ;                               [E6ED]
        lda     LDTB1,X                 ; get start of line X pointer HB
        bmi     A_E6F4                  ; exit loop if start of logical line

        dex                             ; else back up one line
        bne     GoStartOfLine           ; loop if not on first line
A_E6F4                                  ;                               [E6F4]
        jmp     FetchScreenAddr         ; fetch a screen address        [E9F0]

A_E6F7                                  ;                               [E6F7]
        dec     PhysCurRow              ; decrement the cursor row
        jsr     NewScreenLine           ; do newline                    [E87C]
        lda     #$00                    ; clear A
        sta     LineCurCol              ; clear the cursor column
A_E700                                  ;                               [E700]
        rts


;******************************************************************************
;
; back onto the previous line if possible

BackToPrevLine                          ;                               [E701]
        ldx     PhysCurRow              ; get the cursor row
        bne     A_E70B                  ; branch if not top row

        stx     LineCurCol              ; clear cursor column

        pla                             ; dump return address LB

        pla                             ; dump return address HB
        bne     RestorRegsQuot          ; restore registers, set quote flag
                                        ; and exit, branch always
A_E70B                                  ;                               [E70B]
        dex                             ; decrement the cursor row
        stx     PhysCurRow              ; save the cursor row

        jsr     CalcCursorPos           ; set the screen pointers for cursor
                                        ; row, column                   [E56C]
        ldy     CurLineLeng             ; get current screen line length
        sty     LineCurCol              ; save the cursor column

        rts


;******************************************************************************
;
; output a character to the screen

OutputChar                              ;                               [E716]
        pha                             ; save character
        sta     TEMPD7                  ; save temporary last character

        txa                             ; copy X
        pha                             ; save X

        tya                             ; copy Y
        pha                             ; save Y

        lda     #$00                    ; clear A
        sta     CRSW                    ; clear input from keyboard or screen,
                                        ; $xx = screen, $00 = keyboard
        ldy     LineCurCol              ; get cursor column

        lda     TEMPD7                  ; restore last character
        bpl     A_E72A                  ; branch if unshifted

        jmp     ShiftedChars            ; do shifted characters and return 
                                        ;                               [E7D4]
A_E72A                                  ;                               [E72A]
        cmp     #$0D                    ; compare with [CR]
        bne     A_E731                  ; branch if not [CR]

        jmp     OutputCR                ; else output [CR] and return   [E891]

A_E731                                  ;                               [E731]
        cmp     #' '                    ; compare with [SPACE]
        bcc     A_E745                  ; branch if < [SPACE]

        cmp     #$60                    ;.
        bcc     A_E73D                  ; branch if $20 to $5F

; character is $60 or greater
        and     #$DF                    ;.
        bne     A_E73F                  ;.

A_E73D                                  ;                               [E73D]
        and     #$3F                    ;.
A_E73F                                  ;                               [E73F]
        jsr     ToggleCursorFlg         ; if open quote toggle cursor
                                        ; direct/programmed flag        [E684]
        jmp     Char2Screen             ;.                              [E693]

; character was < [SPACE] so is a control character of some sort
A_E745                                  ;                               [E745]
        ldx     InsertCount             ; get the insert count
        beq     A_E74C                  ; if no characters to insert continue

        jmp     ReverseChar             ; insert reversed character     [E697]

A_E74C                                  ;                               [E74C]
        cmp     #$14                    ; compare char with [INSERT]/[DELETE]
        bne     A_E77E                  ; if not [INSERT]/[DELETE] go ??

        tya                             ;.
        bne     A_E759                  ;.

        jsr     BackToPrevLine          ; back onto previous line if possible
                                        ;                               [E701]
        jmp     J_E773                  ;.                              [E773]

A_E759                                  ;                               [E759]
        jsr     Test4LineDecr           ; test for line decrement       [E8A1]

; now close up the line
        dey                             ; decrement index to previous character
        sty     LineCurCol              ; save the cursor column

        jsr     PtrCurLineColRAM        ; calculate pointer to colour RAM [EA24]
A_E762                                  ;                               [E762]
        iny                             ; increment index to next character
        lda     (CurScrLine),Y          ; get character from current screen line
        dey                             ; decrement index to previous character
        sta     (CurScrLine),Y          ; save character to current screen line

        iny                             ; increment index to next character
        lda     (ColorRamPtr),Y         ; get colour RAM byte
        dey                             ; decrement index to previous character
        sta     (ColorRamPtr),Y         ; save colour RAM byte

        iny                             ; increment index to next character
        cpy     CurLineLeng             ; comp with current screen line length
        bne     A_E762                  ; loop if not there yet

J_E773                                  ;                               [E773]
        lda     #' '                    ; set [SPACE]
        sta     (CurScrLine),Y          ; clear last char on current screen line

        lda     COLOR                   ; get the current colour code
        sta     (ColorRamPtr),Y         ; save to colour RAM
        bpl     A_E7CB                  ; branch always

A_E77E                                  ;                               [E77E]
        ldx     QTSW                    ; get cursor quote flag, $xx = quote,
                                        ; $00 = no quote
        beq     A_E785                  ; branch if not quote mode

        jmp     ReverseChar             ; insert reversed character     [E697]

A_E785                                  ;                               [E785]
        cmp     #$12                    ; compare with [RVS ON]
        bne     A_E78B                  ; if not [RVS ON] skip setting the
                                        ; reverse flag
        sta     RVS                     ; else set the reverse flag
A_E78B                                  ;                               [E78B]
        cmp     #$13                    ; compare with [CLR HOME]
        bne     A_E792                  ; if not [CLR HOME] continue

        jsr     CursorHome              ; home the cursor               [E566]
A_E792                                  ;                               [E792]
        cmp     #$1D                    ; compare with [CURSOR RIGHT]
        bne     A_E7AD                  ; if not [CURSOR RIGHT] go ??

        iny                             ; increment the cursor column

        jsr     Test4LineIncr           ; test for line increment       [E8B3]
        sty     LineCurCol              ; save the cursor column

        dey                             ; decrement the cursor column
        cpy     CurLineLeng             ; compare cursor column with current
                                        ; screen line length
        bcc     A_E7AA                  ; exit if less

; else the cursor column is >= the current screen line length so back onto the
; current line and do a newline
        dec     PhysCurRow              ; decrement the cursor row

        jsr     NewScreenLine           ; do newline                    [E87C]

        ldy     #$00                    ; clear cursor column
A_E7A8                                  ;                               [E7A8]
        sty     LineCurCol              ; save the cursor column
A_E7AA                                  ;                               [E7AA]
        jmp     RestorRegsQuot          ; restore the registers, set the quote
                                        ; flag and exit                 [E6A8]
A_E7AD                                  ;                               [E7AD]
        cmp     #$11                    ; compare with [CURSOR DOWN]
        bne     A_E7CE                  ; if not [CURSOR DOWN] go ??

        clc                             ; clear carry for add
        tya                             ; copy the cursor column
        adc     #$28                    ; add one line
        tay                             ; copy back to Y

        inc     PhysCurRow              ; increment the cursor row

        cmp     CurLineLeng             ; compare cursor column with current
                                        ; screen line length
        bcc     A_E7A8                  ; if less, save cursor column and exit

        beq     A_E7A8                  ; if equal, save cursor column and exit

; else the cursor has moved beyond the end of this line so back it up until
; it's on the start of the logical line
        dec     PhysCurRow              ; decrement the cursor row
A_E7C0                                  ;                               [E7C0]
        sbc     #$28                    ; subtract one line
        bcc     A_E7C8                  ; if on previous line exit the loop

        sta     LineCurCol              ; else save the cursor column
        bne     A_E7C0                  ; loop if not at the start of the line

A_E7C8                                  ;                               [E7C8]
        jsr     NewScreenLine           ; do newline                    [E87C]
A_E7CB                                  ;                               [E7CB]
        jmp     RestorRegsQuot          ; restore the registers, set the quote
                                        ; flag and exit                 [E6A8]
A_E7CE                                  ;                               [E7CE]
        jsr     SetColourCode           ; set the colour code           [E8CB]
        jmp     ChkSpecCodes            ; go check for special character codes
                                        ;                               [EC44]
ShiftedChars                            ;                               [E7D4]
        and     #$7F                    ; mask 0xxx, clear b7
        cmp     #$7F                    ; was it $FF before the mask
        bne     A_E7DC                  ; branch if not

        lda     #$5E                    ; else make it $5E
A_E7DC                                  ;                               [E7DC]
        cmp     #' '                    ; compare the character with [SPACE]
        bcc     A_E7E3                  ; if < [SPACE] go ??

        jmp     UpcChar2Screen          ; insert uppercase/graphic character
                                        ; and return                    [E691]

; character was $80 to $9F and is now $00 to $1F
A_E7E3                                  ;                               [E7E3]
        cmp     #$0D                    ; compare with [CR]
        bne     A_E7EA                  ; if not [CR] continue

        jmp     OutputCR                ; else output [CR] and return   [E891]

; was not [CR]
A_E7EA                                  ;                               [E7EA]
        ldx     QTSW                    ; get the cursor quote flag,
                                        ; $xx = quote, $00 = no quote
        bne     A_E82D                  ; branch if quote mode

        cmp     #$14                    ; compare with [INSERT DELETE]
        bne     A_E829                  ; if not [INSERT DELETE] go ??

        ldy     CurLineLeng             ; get current screen line length
        lda     (CurScrLine),Y          ; get character from current screen line
        cmp     #' '                    ; compare the character with [SPACE]
        bne     A_E7FE                  ; if not [SPACE] continue

        cpy     LineCurCol              ; compare the current column with the
                                        ; cursor column
        bne     A_E805                  ; if not cursor column go open up space
                                        ; on line
A_E7FE                                  ;                               [E7FE]
        cpy     #$4F                    ; compare current column with max line
                                        ; length
        beq     A_E826                  ; if at line end just exit

        jsr     InsertLine              ; else open up a space on the screen
                                        ; now open up space on the line to
                                        ; insert a character            [E965]
A_E805                                  ;                               [E805]
        ldy     CurLineLeng             ; get current screen line length
        jsr     PtrCurLineColRAM        ; calc the pointer to colour RAM [EA24]
A_E80A                                  ;                               [E80A]
        dey                             ; decrement index to previous character
        lda     (CurScrLine),Y          ; get the character from the current
                                        ; screen line
        iny                             ; increment the index to next character
        sta     (CurScrLine),Y          ; save the character to the current
                                        ; screen line
        dey                             ; decrement index to previous character
        lda     (ColorRamPtr),Y         ; get the current screen line colour
                                        ; RAM byte
        iny                             ; increment the index to next character
        sta     (ColorRamPtr),Y         ; save the current screen line colour
                                        ; RAM byte
        dey                             ; decrement index to the previous char
        cpy     LineCurCol              ; compare index with the cursor column
        bne     A_E80A                  ; loop if not there yet

        lda     #' '                    ; set [SPACE]
        sta     (CurScrLine),Y          ; clear character at cursor position on
                                        ; current screen line
        lda     COLOR                   ; get current colour code
        sta     (ColorRamPtr),Y         ; save to cursor position on current
                                        ; screen line colour RAM
        inc     InsertCount             ; increment insert count
A_E826                                  ;                               [E826]
        jmp     RestorRegsQuot          ; restore the registers, set the quote
                                        ; flag and exit                 [E6A8]
A_E829                                  ;                               [E829]
        ldx     InsertCount             ; get the insert count
        beq     A_E832                  ; branch if no insert space

A_E82D                                  ;                               [E82D]
        ora     #$40                    ; change to uppercase/graphic
        jmp     ReverseChar             ; insert reversed character     [E697]

A_E832                                  ;                               [E832]
        cmp     #$11                    ; compare with [CURSOR UP]
        bne     A_E84C                  ; branch if not [CURSOR UP]

        ldx     PhysCurRow              ; get the cursor row
        beq     A_E871                  ; if on the top line go restore the
                                        ; registers, set quote flag and exit
        dec     PhysCurRow              ; decrement the cursor row

        lda     LineCurCol              ; get the cursor column
        sec                             ; set carry for subtract
        sbc     #$28                    ; subtract one line length
        bcc     A_E847                  ; branch if stepped back to prev line

        sta     LineCurCol              ; else save the cursor column ..
        bpl     A_E871                  ; .. and exit, branch always

A_E847                                  ;                               [E847]
        jsr     CalcCursorPos           ; set the screen pointers for cursor
                                        ; row, column ..                [E56C]
        bne     A_E871                  ; .. and exit, branch always

A_E84C                                  ;                               [E84C]
        cmp     #$12                    ; compare with [RVS OFF]
        bne     A_E854                  ; if not [RVS OFF] continue

        lda     #$00                    ; else clear A
        sta     RVS                     ; clear the reverse flag
A_E854                                  ;                               [E854]
        cmp     #$1D                    ; compare with [CURSOR LEFT]
        bne     A_E86A                  ; if not [CURSOR LEFT] go ??

        tya                             ; copy the cursor column
        beq     A_E864                  ; if at start of line go back onto the
                                        ; previous line
        jsr     Test4LineDecr           ; test for line decrement       [E8A1]

        dey                             ; decrement the cursor column
        sty     LineCurCol              ; save the cursor column

        jmp     RestorRegsQuot          ; restore the registers, set the quote
                                        ; flag and exit                 [E6A8]
A_E864                                  ;                               [E864]
        jsr     BackToPrevLine          ; back to the previous line if possible
                                        ;                               [E701]
        jmp     RestorRegsQuot          ; restore the registers, set the quote
                                        ; flag and exit                 [E6A8]
A_E86A                                  ;                               [E86A]
        cmp     #$13                    ; compare with [CLR]
        bne     A_E874                  ; if not [CLR] continue

        jsr     ClearScreen             ; clear the screen              [E544]
A_E871                                  ;                               [E871]
        jmp     RestorRegsQuot          ; restore the registers, set the quote
                                        ; flag and exit                 [E6A8]
A_E874                                  ;                               [E874]
        ora     #$80                    ; restore b7, colour can only be black,
                                        ; cyan, magenta or yellow
        jsr     SetColourCode           ; set the colour code           [E8CB]
        jmp     Chk4SpecChar            ; go check for special character codes
                                        ; except for switch to lower case [EC4F]

;******************************************************************************
;
; do newline

NewScreenLine                           ;                               [E87C]
        lsr     CursorRow               ; shift >> input cursor row
        ldx     PhysCurRow              ; get the cursor row
A_E880                                  ;                               [E880]
        inx                             ; increment the row
        cpx     #$19                    ; compare it with last row + 1
        bne     A_E888                  ; if not last row+1 skip screen scroll

        jsr     ScrollScreen            ; else scroll the screen        [E8EA]
A_E888                                  ;                               [E888]
        lda     LDTB1,X                 ; get start of line X pointer HB
        bpl     A_E880                  ; loop if not start of logical line

        stx     PhysCurRow              ; save the cursor row

        jmp     CalcCursorPos           ; set the screen pointers for cursor
                                        ; row, column and return        [E56C]


;******************************************************************************
;
; output [CR]

OutputCR                                ;                               [E891]
        ldx     #$00                    ; clear X
        stx     InsertCount             ; clear the insert count
        stx     RVS                     ; clear the reverse flag
        stx     QTSW                    ; clear the cursor quote flag,
                                        ; $xx = quote, $00 = no quote
        stx     LineCurCol              ; save the cursor column

        jsr     NewScreenLine           ; do newline                    [E87C]
        jmp     RestorRegsQuot          ; restore the registers, set the quote
                                        ; flag and exit                 [E6A8]


;******************************************************************************
;
; test for line decrement

Test4LineDecr                           ;                               [E8A1]
        ldx     #$02                    ; set the count
        lda     #$00                    ; set the column
A_E8A5                                  ;                               [E8A5]
        cmp     LineCurCol              ; compare column with the cursor column
        beq     A_E8B0                  ; if at the start of the line, go
                                        ; decrement the cursor row and exit
        clc                             ; else clear carry for add
        adc     #$28                    ; increment to next line

        dex                             ; decrement loop count
        bne     A_E8A5                  ; loop if more to test

        rts

A_E8B0                                  ;                               [E8B0]
        dec     PhysCurRow              ; else decrement the cursor row

        rts


;******************************************************************************
;
; test for line increment. if at end of the line, but not at end of the last
; line, increment the cursor row

Test4LineIncr                           ;                               [E8B3]
        ldx     #$02                    ; set the count
        lda     #$27                    ; set the column
A_E8B7                                  ;                               [E8B7]
        cmp     LineCurCol              ; compare column with the cursor column
        beq     A_E8C2                  ; if at end of line test and possibly
                                        ; increment cursor row
        clc                             ; else clear carry for add
        adc     #$28                    ; increment to the next line
        dex                             ; decrement the loop count
        bne     A_E8B7                  ; loop if more to test

        rts

; cursor is at end of line
A_E8C2                                  ;                               [E8C2]
        ldx     PhysCurRow              ; get the cursor row
        cpx     #$19                    ; compare it with the end of the screen
        beq     A_E8CA                  ; if at the end of screen just exit

        inc     PhysCurRow              ; else increment the cursor row
A_E8CA                                  ;                               [E8CA]
        rts


;******************************************************************************
;
; set the colour code. enter with the colour character in A. if A does not
; contain a colour character this routine exits without changing the colour

SetColourCode                           ;                               [E8CB]
        ldx     #D_E8E9-AscColourCodes  ; set the colour code count
A_E8CD                                  ;                               [E8CD]
        cmp     AscColourCodes,X        ; compare character with a table code
        beq     A_E8D6                  ; if a match go save colour and exit

        dex                             ; else decrement the index
        bpl     A_E8CD                  ; loop if more to do

        rts

A_E8D6                                  ;                               [E8D6]
        stx     COLOR                   ; save the current colour code

        rts


;******************************************************************************
;
; ASCII colour code table
                                        ; CHR$()        colour
AscColourCodes                          ; ------        ------
.byte   $90                             ;  144          black
.byte   $05                             ;    5          white
.byte   $1C                             ;   28          red
.byte   $9F                             ;  159          cyan
.byte   $9C                             ;  156          purple
.byte   $1E                             ;   30          green
.byte   $1F                             ;   31          Blue
.byte   $9E                             ;  158          yellow
.byte   $81                             ;  129          orange
.byte   $95                             ;  149          brown
.byte   $96                             ;  150          light red
.byte   $97                             ;  151          dark grey
.byte   $98                             ;  152          medium grey
.byte   $99                             ;  153          light green
.byte   $9A                             ;  154          light blue
D_E8E9                                  ;                               [E8E9]
.byte   $9B                             ;  155          light grey


;******************************************************************************
;
; scroll the screen

ScrollScreen                            ;                               [E8EA]
        lda     SAL                     ; copy the tape buffer start pointer
        pha                             ; save it

        lda     SAL+1                   ; copy the tape buffer start pointer
        pha                             ; save it

        lda     EAL                     ; copy the tape buffer end pointer
        pha                             ; save it

        lda     EAL+1                   ; copy the tape buffer end pointer
        pha                             ; save it
A_E8F6                                  ;                               [E8F6]
        ldx     #$FF                    ; set to -1 for pre increment loop

        dec     PhysCurRow              ; decrement the cursor row
        dec     CursorRow               ; decrement the input cursor row
        dec     TmpLineScrl             ; decrement the screen row marker
A_E8FF                                  ;                               [E8FF]
        inx                             ; increment the line number

        jsr     FetchScreenAddr         ; fetch a screen address, set the start
                                        ; of line X                     [E9F0]
        cpx     #$18                    ; compare with last line
        bcs     A_E913                  ; branch if >= $16

        lda     TblScrLinesLB+1,X       ; get the start of the next line
                                        ; pointer LB
        sta     SAL                     ; save the next line pointer LB

        lda     LDTB1+1,X               ; get the start of the next line
                                        ; pointer HB
        jsr     ShiftLineUpDwn          ; shift the screen line up      [E9C8]
        bmi     A_E8FF                  ; loop, branch always

A_E913                                  ;                               [E913]
        jsr     ClearLineX              ; clear screen line X           [E9FF]

; now shift up the start of logical line bits
        ldx     #$00                    ; clear index
A_E918                                  ;                               [E918]
        lda     LDTB1,X                 ; get start of line X pointer HB
        and     #$7F                    ; clear line X start of logical line bit

        ldy     LDTB1+1,X               ; get the start of the next line
                                        ; pointer HB
        bpl     A_E922                  ; if next line is not a start of line
                                        ; skip the start set
        ora     #$80                    ; set line X start of logical line bit
A_E922                                  ;                               [E922]
        sta     LDTB1,X                 ; set start of line X pointer HB

        inx                             ; increment line number
        cpx     #$18                    ; compare with last line
        bne     A_E918                  ; loop if not last line

        lda     LDTB1+$18               ; start of last line pointer HB
        ora     #$80                    ; mark as start of logical line
        sta     LDTB1+$18

        lda     LDTB1                   ; start of first line pointer HB
        bpl     A_E8F6                  ; if not start of logical line loop back
                                        ; and scroll the screen up another line

        inc     PhysCurRow              ; increment the cursor row
        inc     TmpLineScrl             ; increment screen row marker

        lda     #$7F                    ; set keyboard column c7
        sta     CIA1DRA                 ; save CIA 1 DRA, keyboard column drive

        lda     CIA1DRB                 ; read CIA 1 DRB, keyboard row port
        cmp     #$FB                    ; compare with row r2 active, [CTL]

        php                             ; save status

        lda     #$7F                    ; set keyboard column c7
        sta     CIA1DRA                 ; save CIA 1 DRA, keyboard column drive

        plp                             ; restore status
        bne     A_E956                  ; skip delay if ??

; first time round the inner loop X will be $16
        ldy     #$00                    ; clear delay outer loop count, do this
                                        ; 256 times
A_E94D                                  ;                               [E94D]
        nop                             ; waste cycles

        dex                             ; decrement inner loop count
        bne     A_E94D                  ; loop if not all done

        dey                             ; decrement outer loop count
        bne     A_E94D                  ; loop if not all done

        sty     NDX                     ; clear the keyboard buffer index
A_E956                                  ;                               [E956]
        ldx     PhysCurRow              ; get the cursor row

; restore the tape buffer pointers and exit

RestrTapBufPtr                          ;                               [E958]
        pla                             ; pull tape buffer end pointer
        sta     EAL+1                   ; restore it

        pla                             ; pull tape buffer end pointer
        sta     EAL                     ; restore it

        pla                             ; pull tape buffer pointer
        sta     SAL+1                   ; restore it

        pla                             ; pull tape buffer pointer
        sta     SAL                     ; restore it

        rts


;******************************************************************************
;
; open up a space on the screen

InsertLine                              ;                               [E965]
        ldx     PhysCurRow              ; get the cursor row
InsertLine2                             ;                               [E967]
        inx                             ; increment the row
        lda     LDTB1,X                 ; get start of line X pointer HB
        bpl     InsertLine2             ; loop if not start of logical line

        stx     TmpLineScrl             ; save the screen row marker

        cpx     #$18                    ; compare it with the last line
        beq     A_E981                  ; if = last line go ??

        bcc     A_E981                  ; if < last line go ??

; else it was > last line
        jsr     ScrollScreen            ; scroll the screen             [E8EA]

        ldx     TmpLineScrl             ; get the screen row marker
        dex                             ; decrement the screen row marker

        dec     PhysCurRow              ; decrement the cursor row

        jmp     AddRow2CurLine          ; add this row to the current logical
                                        ; line and return               [E6DA]
A_E981                                  ;                               [E981]
        lda     SAL                     ; copy tape buffer pointer
        pha                             ; save it

        lda     SAL+1                   ; copy tape buffer pointer
        pha                             ; save it

        lda     EAL                     ; copy tape buffer end pointer
        pha                             ; save it

        lda     EAL+1                   ; copy tape buffer end pointer
        pha                             ; save it

        ldx     #$19                    ; set to end line + 1 for predecrement
                                        ; loop
A_E98F                                  ;                               [E98F]
        dex                             ; decrement the line number

        jsr     FetchScreenAddr         ; fetch a screen address        [E9F0]
        cpx     TmpLineScrl             ; compare it with the screen row marker
        bcc     A_E9A6                  ; if < screen row marker go ??

        beq     A_E9A6                  ; if = screen row marker go ??

        lda     TblScrLinesLB-1,X       ; else get the start of the previous
                                        ; line LB from the ROM table
        sta     SAL                     ; save previous line pointer LB

        lda     LDTB1-1,X               ; get the start of the previous line
                                        ; pointer HB
        jsr     ShiftLineUpDwn          ; shift the screen line down    [E9C8]
        bmi     A_E98F                  ; loop, branch always

A_E9A6                                  ;                               [E9A6]
        jsr     ClearLineX              ; clear screen line X           [E9FF]

        ldx     #$17                    ;.
A_E9AB                                  ;                               [E9AB]
        cpx     TmpLineScrl             ; compare it with the screen row marker
        bcc     A_E9BF                  ;.

        lda     LDTB1+1,X               ;.
        and     #$7F                    ;.

        ldy     LDTB1,X                 ; get start of line X pointer HB
        bpl     A_E9BA                  ;.

        ora     #$80                    ;.
A_E9BA                                  ;                               [E9BA]
        sta     LDTB1+1,X               ;.

        dex                             ;.
        bne     A_E9AB                  ;.

A_E9BF                                  ;                               [E9BF]
        ldx     TmpLineScrl             ; get the screen row marker
        jsr     AddRow2CurLine          ; add this row to current logical line
                                        ;                               [E6DA]
        jmp     RestrTapBufPtr          ; restore tape buffer pointers and exit
                                        ;                               [E958]

;******************************************************************************
;
; shift screen line up/down

ShiftLineUpDwn                          ;                               [E9C8]
        and     #$03                    ; mask 0000 00xx, line memory page
        ora     HIBASE                  ; OR with screen memory page
        sta     SAL+1                   ; save next/previous line pointer HB

        jsr     PtrLineColRAM           ; calculate pointers to screen lines
                                        ; colour RAM                    [E9E0]
        ldy     #$27                    ; set the column count
A_E9D4                                  ;                               [E9D4]
        lda     (SAL),Y                 ; get character from next/previous
                                        ; screen line
        sta     (CurScrLine),Y          ; save character to current screen line

        lda     (EAL),Y                 ; get colour from next/previous screen
                                        ; line colour RAM
        sta     (ColorRamPtr),Y         ; save colour to current screen line
                                        ; colour RAM
        dey                             ; decrement column index/count
        bpl     A_E9D4                  ; loop if more to do

        rts


;******************************************************************************
;
; calculate pointers to screen lines colour RAM

PtrLineColRAM                           ;                               [E9E0]
        jsr     PtrCurLineColRAM        ; calculate the pointer to the current
                                        ; screen line colour RAM        [EA24]
        lda     SAL                     ; get the next screen line pointer LB
        sta     EAL                     ; save the next screen line colour RAM
                                        ; pointer LB
        lda     SAL+1                   ; get the next screen line pointer HB
        and     #$03                    ; mask 0000 00xx, line memory page
        ora     #>ColourRAM             ; set  1101 01xx, colour memory page
        sta     EAL+1                   ; save the next screen line colour RAM
                                        ; pointer HB
        rts


;******************************************************************************
;
; fetch a screen address

FetchScreenAddr                         ;                               [E9F0]
        lda     TblScrLinesLB,X         ; get the start of line LB from
                                        ; the ROM table
        sta     CurScrLine              ; set current screen line pointer LB

        lda     LDTB1,X                 ; get the start of line HB from
                                        ; the RAM table
        and     #$03                    ; mask 0000 00xx, line memory page
        ora     HIBASE                  ; OR with the screen memory page
        sta     CurScrLine+1            ; save current screen line pointer HB

        rts


;******************************************************************************
;
; clear screen line X

ClearLineX                              ;                               [E9FF]
        ldy     #$27                    ; set number of columns to clear
        jsr     FetchScreenAddr         ; fetch a screen address        [E9F0]

        jsr     PtrCurLineColRAM        ; calculate pointer to colour RAM [EA24]
A_EA07                                  ;                               [EA07]
.if Version=3
        jsr     SaveCurColour           ; save current colour to colour RAM
                                        ;                               [E4DA]
        lda     #' '                    ; set [SPACE]
        sta     (CurScrLine),Y          ; clear character in current screen line

        dey                             ; decrement index
        bpl     A_EA07                  ; loop if more to do

        rts

        nop                             ; unused
.else
        lda     #' '
        sta     (CurScrLine),Y          ; clear character in current screen line

.if Version=1
        lda     #$01
        sta     (ColorRamPtr),Y

.else                                   ; version 2
        jsr     SaveCurColour           ; save current colour to colour RAM
                                        ;                               [E4DA]
        nop

.fi
        dey                             ; decrement index
        bpl     A_EA07                  ; loop if more to do

        rts
.fi


;******************************************************************************
;
; print character A and colour X

PrntCharA_ColX                          ;                               [EA13]
        tay                             ; copy the character

        lda     #$02                    ; set the count to $02, usually $14 ??
        sta     BLNCT                   ; save the cursor countdown

        jsr     PtrCurLineColRAM        ; calculate pointer to colour RAM [EA24]
        tya                             ; get the character back


;******************************************************************************
;
; save the character and colour to the screen @ the cursor

OutCharCol2Scr                          ;                               [EA1C]
        ldy     LineCurCol              ; get the cursor column
        sta     (CurScrLine),Y          ; save char from current screen line

        txa                             ; copy the colour to A
        sta     (ColorRamPtr),Y         ; save to colour RAM

        rts


;******************************************************************************
;
; calculate the pointer to colour RAM

PtrCurLineColRAM                        ;                               [EA24]
        lda     CurScrLine              ; get current screen line pointer LB
        sta     ColorRamPtr             ; save pointer to colour RAM LB

        lda     CurScrLine+1            ; get current screen line pointer HB
        and     #$03                    ; mask 0000 00xx, line memory page
        ora     #>ColourRAM             ; set  1101 01xx, colour memory page
        sta     ColorRamPtr+1           ; save pointer to colour RAM HB

        rts


;******************************************************************************
;
; update the clock, flash the cursor, control the cassette and scan the
; keyboard

; IRQ vector

IRQ_vector                              ;                               [EA31]
        jsr     IncrClock               ; increment the real time clock [FFEA]

        lda     BLNSW                   ; get cursor enable, $00 = flash cursor
        bne     A_EA61                  ; if flash not enabled skip the flash

        dec     BLNCT                   ; decrement the cursor timing countdown
        bne     A_EA61                  ; if not counted out skip the flash

        lda     #$14                    ; set the flash count
        sta     BLNCT                   ; save the cursor timing countdown

        ldy     LineCurCol              ; get the cursor column

        lsr     BLNON                   ; shift b0 cursor blink phase into carry

        ldx     GDCOL                   ; get the colour under the cursor

        lda     (CurScrLine),Y          ; get character from current screen line
        bcs     A_EA5C                  ; branch if cursor phase b0 was 1

        inc     BLNON                   ; set the cursor blink phase to 1

        sta     GDBLN                   ; save the character under the cursor

        jsr     PtrCurLineColRAM        ; calculate the pointer to colour RAM
                                        ;                               [EA24]

        lda     (ColorRamPtr),Y         ; get the colour RAM byte
        sta     GDCOL                   ; save the colour under the cursor

        ldx     COLOR                   ; get the current colour code
        lda     GDBLN                   ; get the character under the cursor
A_EA5C                                  ;                               [EA5C]
        eor     #$80                    ; toggle b7 of character under cursor
        jsr     OutCharCol2Scr          ; save the character and colour to the
                                        ; screen @ the cursor           [EA1C]
A_EA61                                  ;                               [EA61]
        lda     P6510                   ; read the 6510 I/O port
        and     #$10                    ; mask 000x 0000, cassette switch sense
        beq     A_EA71                  ; if the cassette sense is low skip the
                                        ; motor stop
; the cassette sense was high, the switch was open, so turn off the motor and
; clear the interlock
        ldy     #$00                    ; clear Y
        sty     CAS1                    ; clear the tape motor interlock

        lda     P6510                   ; read the 6510 I/O port
        ora     #$20                    ; mask xx1x, turn off
                                        ; the motor
        bne     A_EA79                  ; go save the port value, branch always

; the cassette sense was low so turn the motor on, perhaps
A_EA71                                  ;                               [EA71]
        lda     CAS1                    ; get the tape motor interlock
        bne     A_EA7B                  ; if the cassette interlock <> 0 don't
                                        ; turn on motor

        lda     P6510                   ; read the 6510 I/O port
        and     #$1F                    ; mask xx0x, turn on
                                        ; the motor
A_EA79                                  ;                               [EA79]
        sta     P6510                   ; save the 6510 I/O port
A_EA7B                                  ;                               [EA7B]
        jsr     ScanKeyboard2           ; scan the keyboard             [EA87]

        lda     CIA1IRQ                 ; read CIA 1 ICR, clear the timer
                                        ; interrupt flag

        pla                             ; pull Y
        tay                             ; restore Y

        pla                             ; pull X
        tax                             ; restore X

        pla                             ; restore A

        rti


;******************************************************************************
;
; scan keyboard performs the following ..
;
; 1)    check if key pressed, if not then exit the routine
;
; 2)    init I/O ports of CIA ?? for keyboard scan and set pointers to decode
;       table 1. clear the character counter
;
; 3)    set one line of port B low and test for a closed key on port A by
;       shifting the byte read from the port. if the carry is clear then a key
;       is closed so save the   count which is incremented on each shift. check
;       for shift/stop/cbm keys and flag if closed
;
; 4)    repeat step 3 for the whole matrix
;
; 5)    evaluate the SHIFT/CTRL/C= keys, this may change the decode table
;       selected
;
; 6)    use the key count saved in step 3 as an index into the table selected
;       in step 5
; 7)    check for key repeat operation
;
; 8)    save the decoded key to the buffer if first press or repeat

; scan the keyboard

ScanKeyboard2                           ;                               [EA87]
        lda     #$00                    ; clear A
        sta     SHFLAG                  ; clear keyboard shift/control/c= flag

        ldy     #$40                    ; set no key
        sty     SFDX                    ; save which key

        sta     CIA1DRA                 ; clear CIA 1 DRA, keyboard column drive

        ldx     CIA1DRB                 ; read CIA 1 DRB, keyboard row port
        cpx     #$FF                    ; compare with all bits set
        beq     A_EAFB                  ; if no key pressed clear current key
                                        ; and exit (does further BEQ to A_EBBA)
        tay                             ; clear the key count

        lda     #<TblStandardKeys       ; get the decode table LB
        sta     KEYTAB                  ; save the keyboard pointer LB

        lda     #>TblStandardKeys       ; get the decode table HB
        sta     KEYTAB+1                ; save the keyboard pointer HB

        lda     #$FE                    ; set column 0 low
        sta     CIA1DRA                 ; save CIA 1 DRA, keyboard column drive
A_EAA8                                  ;                               [EAA8]
        ldx     #$08                    ; set the row count

        pha                             ; save the column
A_EAAB                                  ;                               [EAAB]
        lda     CIA1DRB                 ; read CIA 1 DRB, keyboard row port
        cmp     CIA1DRB                 ; compare it with itself
        bne     A_EAAB                  ; loop if changing

A_EAB3                                  ;                               [EAB3]
        lsr                             ; shift row to Cb
        bcs     A_EACC                  ; if no key closed on this row go do
                                        ; next row
        pha                             ; save row

        lda     (KEYTAB),Y              ; get character from decode table
        cmp     #$05                    ; there is no $05 key but the control
                                        ; keys are all less than $05
        bcs     A_EAC9                  ; if not shift/control/c=/stop go save
                                        ; key count
; else was shift/control/c=/stop key
        cmp     #$03                    ; compare with $03, stop
        beq     A_EAC9                  ; if stop go save key count and continue

; character is $01 - shift, $02 - c= or $04 - control
        ora     SHFLAG                  ; OR it with the keyboard
                                        ; shift/control/c= flag
        sta     SHFLAG                  ; save keyboard shift/control/c= flag
        bpl     A_EACB                  ; skip save key, branch always

A_EAC9                                  ;                               [EAC9]
        sty     SFDX                    ; save key count
A_EACB                                  ;                               [EACB]
        pla                             ; restore row
A_EACC                                  ;                               [EACC]
        iny                             ; increment key count
        cpy     #$41                    ; compare with max+1
        bcs     A_EADC                  ; exit loop if >= max+1

; else still in matrix
        dex                             ; decrement row count
        bne     A_EAB3                  ; loop if more rows to do

        sec                             ; set carry for keyboard column shift
        pla                             ; restore the column
        rol                             ; shift the keyboard column
        sta     CIA1DRA                 ; save CIA 1 DRA, keyboard column drive
        bne     A_EAA8                  ; loop for next column, branch always

A_EADC                                  ;                               [EADC]
        pla                             ; dump the saved column
        jmp     (KEYLOG)                ; evaluate the SHIFT/CTRL/C= keys

; key decoding continues here after the SHIFT/CTRL/C= keys are evaluated

DecodeKeys                              ;                               [EAE0]
        ldy     SFDX                    ; get saved key count
        lda     (KEYTAB),Y              ; get character from decode table
        tax                             ; copy character to X

        cpy     LSTX                    ; compare key count with last key count
        beq     A_EAF0                  ; if this key = current key, key held,
                                        ; go test repeat
        ldy     #$10                    ; set the repeat delay count
        sty     DELAY                   ; save the repeat delay count
        bne     A_EB26                  ; branch always

A_EAF0                                  ;                               [EAF0]
        and     #$7F                    ; clear b7
        bit     RPTFLG                  ; test key repeat
        bmi     A_EB0D                  ; if repeat all go ??

        bvs     A_EB42                  ; if repeat none go ??

        cmp     #$7F                    ; compare with end marker
A_EAFB                                  ;                               [EAFB]
        beq     A_EB26                  ; if $00/end marker go save key to
                                        ; buffer and exit
        cmp     #$14                    ; compare with [INSERT]/[DELETE]
        beq     A_EB0D                  ; if equal, go test for repeat

        cmp     #' '                    ; compare with [SPACE]
        beq     A_EB0D                  ; if [SPACE] go test for repeat

        cmp     #$1D                    ; compare with [CURSOR RIGHT]
        beq     A_EB0D                  ; if [CURSOR RIGHT] go test for repeat

        cmp     #$11                    ; compare with [CURSOR DOWN]
        bne     A_EB42                  ; if not [CURSOR DOWN] just exit

; was one of the cursor movement keys, insert/delete key or the space bar so
; always do repeat tests
A_EB0D                                  ;                               [EB0D]
        ldy     DELAY                   ; get the repeat delay counter
        beq     A_EB17                  ; if delay expired go ??

        dec     DELAY                   ; else decrement repeat delay counter
        bne     A_EB42                  ; if delay not expired go ??

; repeat delay counter has expired
A_EB17                                  ;                               [EB17]
        dec     KOUNT                   ; decrement the repeat speed counter
        bne     A_EB42                  ; branch if not expired

        ldy     #$04                    ; set for 4/60ths of a second
        sty     KOUNT                   ; save the repeat speed counter

        ldy     NDX                     ; get the keyboard buffer index
        dey                             ; decrement it
        bpl     A_EB42                  ; if the buffer isn't empty just exit

; else repeat the key immediately

; possibly save the key to the keyboard buffer. if there was no key pressed or
; the key was not found during the scan (possibly due to key bounce) then X
; will be $FF here

A_EB26                                  ;                               [EB26]
        ldy     SFDX                    ; get the key count
        sty     LSTX                    ; save it as the current key count

        ldy     SHFLAG                  ; get the keyboard shift/control/c= flag
        sty     LSTSHF                  ; save it as last keyboard shift pattern

        cpx     #$FF                    ; compare the character with the table
                                        ; end marker or no key
        beq     A_EB42                  ; if it was the table end marker or no
                                        ; key, just exit
        txa                             ; copy the character to A

        ldx     NDX                     ; get the keyboard buffer index
        cpx     XMAX                    ; compare it with keyboard buffer size
        bcs     A_EB42                  ; if the buffer is full just exit

        sta     KeyboardBuf,X           ; save character to keyboard buffer

        inx                             ; increment the index
        stx     NDX                     ; save the keyboard buffer index
A_EB42                                  ;                               [EB42]
        lda     #$7F                    ; enable column 7 for the stop key
        sta     CIA1DRA                 ; save CIA 1 DRA, keyboard column drive

        rts


;******************************************************************************
;
; evaluate the SHIFT/CTRL/C= keys

ShftCtrlCbmKey                          ;                               [EB48]
        lda     SHFLAG                  ; get the keyboard shift/control/c= flag
        cmp     #$03                    ; compare with [SHIFT][C=]
        bne     A_EB64                  ; if not [SHIFT][C=] go ??

        cmp     LSTSHF                  ; compare with last
        beq     A_EB42                  ; exit if still the same

        lda     MODE                    ; get the shift mode switch,
                                        ; $00 = enabled, $80 = locked
        bmi     A_EB76                  ; if locked continue keyboard decode

; toggle text mode
        lda     VICRAM                  ; get start of character memory address
        eor     #$02                    ; toggle address b1
        sta     VICRAM                  ; save start of character memory address

        jmp     A_EB76                  ; continue the keyboard decode  [EB76]

; select keyboard table
A_EB64                                  ;                               [EB64]
        asl                             ; << 1
        cmp     #$08                    ; compare with [CTRL]
        bcc     A_EB6B                  ; if [CTRL] is not pressed skip the
                                        ; index change
        lda     #$06                    ; else [CTRL] was pressed so make the
                                        ; index = $06
A_EB6B                                  ;                               [EB6B]
        tax                             ; copy the index to X

        lda     KeyTables,X             ; get decode table pointer LB
        sta     KEYTAB                  ; save decode table pointer LB

        lda     KeyTables+1,X           ; get decode table pointer HB
        sta     KEYTAB+1                ; save decode table pointer HB
A_EB76                                  ;                               [EB76]
        jmp     DecodeKeys              ; continue the keyboard decode  [EAE0]


;******************************************************************************
;
; table addresses

KeyTables                                       ;                               [EB79]
.word   TblStandardKeys                 ; standard
.word   TblShiftKeys                    ; shift
.word   TblCbmKeys                      ; commodore
.word   TblControlKeys                  ; control


;******************************************************************************
;
; standard keyboard table

TblStandardKeys                         ;                               [EB81]
.byte   $14,$0D,$1D,$88,$85,$86,$87,$11
.byte   $33,$57,$41,$34,$5A,$53,$45,$01
.byte   $35,$52,$44,$36,$43,$46,$54,$58
.byte   $37,$59,$47,$38,$42,$48,$55,$56
.byte   $39,$49,$4A,$30,$4D,$4B,$4F,$4E
.byte   $2B,$50,$4C,$2D,$2E,$3A,$40,$2C
.byte   $5C,$2A,$3B,$13,$01,$3D,$5E,$2F
.byte   $31,$5F,$04,$32,$20,$02,$51,$03
.byte   $FF

;       DEL     RETURN  CRSR RI F7      F1      F3      F5      CRSR DO
;       3       w       a       4       z       s       e       L SHIFT 
;       5       r       d       6       c       f       t       x
;       6       y       g       8       b       h       u       v
;       9       i       j       0       m       k       o       n
;       +       p       l       -       .       :       @       ,
;       £      *       ;       HOME    R SHIFT =       ^|      /
;       1       <-      CTRL    2       SPACE   CBM     q       STOP


; shifted keyboard table

TblShiftKeys                            ;                               [EBC2]
.byte   $94,$8D,$9D,$8C,$89,$8A,$8B,$91
.byte   $23,$D7,$C1,$24,$DA,$D3,$C5,$01
.byte   $25,$D2,$C4,$26,$C3,$C6,$D4,$D8
.byte   $27,$D9,$C7,$28,$C2,$C8,$D5,$D6
.byte   $29,$C9,$CA,$30,$CD,$CB,$CF,$CE
.byte   $DB,$D0,$CC,$DD,$3E,$5B,$BA,$3C
.byte   $A9,$C0,$5D,$93,$01,$3D,$DE,$3F
.byte   $21,$5F,$04,$22,$A0,$02,$D1,$83
.byte   $FF

;       INST    RRETURN CRSR LE F8      F2      F4      F6      CRSR UP
;       #       W       A       $       Z       S       E       LE SHIFT
;       %       R       D       &       C       F       T       X
;       '       Y       G       (       B       H       U       V
;       )       I       J       0       M       K       O       N
;       cbm gr  P       L       cbm gr  >       [       cbm gr  <
;       cbm gr  cbm gr  [       CLR     R SHIFT =       pi      ?
;       !       <-      CTRL    "       SPACE   CBM     Q       RUN


; CBM key keyboard table

TblCbmKeys                              ;                               [EC03]
.byte   $94,$8D,$9D,$8C,$89,$8A,$8B,$91
.byte   $96,$B3,$B0,$97,$AD,$AE,$B1,$01
.byte   $98,$B2,$AC,$99,$BC,$BB,$A3,$BD
.byte   $9A,$B7,$A5,$9B,$BF,$B4,$B8,$BE
.byte   $29,$A2,$B5,$30,$A7,$A1,$B9,$AA
.byte   $A6,$AF,$B6,$DC,$3E,$5B,$A4,$3C
.byte   $A8,$DF,$5D,$93,$01,$3D,$DE,$3F
.byte   $81,$5F,$04,$95,$A0,$02,$AB,$83
.byte   $FF

;       INST    RETURN  CRSR LE F8      F2      F4      F6      CRSR UP
;       pink    cbm gr  cbm gr  grey 1  cbm gr  cbm gr  cbm gr  LE SHIFT
;       grey 2  cbm gr  cbm gr  ligreen cbm gr  cbm gr  cbm gr  cbm gr
;       li blue cbm gr  cbm gr  grey 3  cbm gr  cbm gr  cbm gr  cbm gr
;       )       cbm gr  cbm gr  0       cbm gr  cbm gr  cbm gr  cbm gr
;       cbm gr  cbm gr  cbm gr  cbm gr  >       [       cbm gr  <
;       cbm gr  cbm gr  ]       CLR     R SHIFT =       pi      ?
;       orange  <-      CTRL    brown   SPACE   CBM     cbm gr  RUN


;******************************************************************************
;
; check for special character codes

ChkSpecCodes                            ;                               [EC44]
        cmp     #$0E                    ; compare with [SWITCH TO LOWER CASE]
        bne     Chk4SpecChar            ; if not equal, skip the switch

        lda     VICRAM                  ; get start of character memory address
        ora     #$02                    ; mask xx1x, set lower case characters
        bne     A_EC58                  ; go save the new value, branch always

; check for special character codes except fro switch to lower case

Chk4SpecChar                            ;                               [EC4F]
        cmp     #$8E                    ; compare with [SWITCH TO UPPER CASE]
        bne     CheckShiftCbm           ; if not [SWITCH TO UPPER CASE] go do
                                        ; the [SHIFT]+[C=] key check
        lda     VICRAM                  ; get start of character memory address
        and     #$FD                    ; mask xx0x, set upper case characters
A_EC58                                  ;                               [EC58]
        sta     VICRAM                  ; save start of character memory address
A_EC5B                                  ;                               [EC5B]
        jmp     RestorRegsQuot          ; restore the registers, set the quote
                                        ; flag and exit [E6A8]
; do the [SHIFT]+[C=] key check

CheckShiftCbm                           ;                               [EC5E]
        cmp     #$08                    ; compare with disable [SHIFT][C=]
        bne     A_EC69                  ; if not disable [SHIFT][C=], skip set

        lda     #$80                    ; set to lock shift mode switch
        ora     MODE                    ; OR it with the shift mode switch
        bmi     A_EC72                  ; go save the value, branch always
A_EC69                                  ;                               [EC69]
        cmp     #$09                    ; compare with enable [SHIFT][C=]
        bne     A_EC5B                  ; exit if not enable [SHIFT][C=]

        lda     #$7F                    ; set to unlock shift mode switch
        and     MODE                    ; AND it with the shift mode switch
A_EC72                                  ;                               [EC72]
        sta     MODE                    ; save the shift mode switch
                                        ; $00 = enabled, $80 = locked
        jmp     RestorRegsQuot          ; restore the registers, set the quote
                                        ; flag and exit [E6A8]

;******************************************************************************
;
; control keyboard table

TblControlKeys                          ;                               [EC78]
.byte   $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
.byte   $1C,$17,$01,$9F,$1A,$13,$05,$FF
.byte   $9C,$12,$04,$1E,$03,$06,$14,$18
.byte   $1F,$19,$07,$9E,$02,$08,$15,$16
.byte   $12,$09,$0A,$92,$0D,$0B,$0F,$0E
.byte   $FF,$10,$0C,$FF,$FF,$1B,$00,$FF
.byte   $1C,$FF,$1D,$FF,$FF,$1F,$1E,$FF
.byte   $90,$06,$FF,$05,$FF,$FF,$11,$FF
.byte   $FF


;******************************************************************************
;
; vic ii chip initialisation values

TblValuesVIC                            ;                               [ECB9]
.byte   $00,$00                         ; sprite 0 x,y
.byte   $00,$00                         ; sprite 1 x,y
.byte   $00,$00                         ; sprite 2 x,y
.byte   $00,$00                         ; sprite 3 x,y
.byte   $00,$00                         ; sprite 4 x,y
.byte   $00,$00                         ; sprite 5 x,y
.byte   $00,$00                         ; sprite 6 x,y
.byte   $00,$00                         ; sprite 7 x,y
;+$10
.byte   $00                             ; sprites 0 to 7 x bit 8
.if Version=1
.byte   $1B
.else
.byte   $9B                             ; enable screen, enable 25 rows
.fi
                                        ; vertical fine scroll and control
                                        ; bit   function
                                        ; ---   -------
                                        ;  7    raster compare bit 8
                                        ;  6    1 = enable extended color text
                                        ;        mode
                                        ;  5    1 = enable bitmap graphics mode
                                        ;  4    1 = enable screen, 0 = blank
                                        ;        screen
                                        ;  3    1 = 25 row display, 0 = 24 row
                                        ;        display
                                        ; 2-0   vertical scroll count
.if Version=1
.byte   $00                             ; raster compare
.else
.byte   $37                             ; raster compare
.fi
.byte   $00                             ; light pen x
.byte   $00                             ; light pen y
.byte   $00                             ; sprite 0 to 7 enable
.byte   $08                             ; enable 40 column display
                                        ; horizontal fine scroll and control
                                        ; bit   function
                                        ; ---   -------
                                        ; 7-6   unused
                                        ;  5    1 = vic reset, 0 = vic on
                                        ;  4    1 = enable multicolor mode
                                        ;  3    1 = 40 column display, 0 = 38
                                        ;        column display
                                        ; 2-0   horizontal scroll count
.byte   $00                             ; sprite 0 to 7 y expand
.byte   $14                             ; memory control
                                        ; bit   function
                                        ; ---   -------
                                        ; 7-4   video matrix base address
                                        ; 3-1   character data base address
                                        ;  0    unused
.if Version=1
.byte   $00
.else
.byte   $0F                             ; clear all interrupts
.fi
                                        ; interrupt flags
                                        ;  7    1 = interrupt
                                        ; 6-4   unused
                                        ;  3    1 = light pen interrupt
                                        ;  2    1 = sprite to sprite collision
                                        ;        interrupt
                                        ;  1    1 = sprite to foreground
                                        ;        collision interrupt
                                        ;  0    1 = raster compare interrupt
.byte   $00                             ; all vic IRQs disabeld
                                        ; IRQ enable
                                        ; bit   function
                                        ; ---   -------
                                        ; 7-4   unused
                                        ;  3    1 = enable light pen
                                        ;  2    1 = enable sprite to sprite
                                        ;        collision
                                        ;  1    1 = enable sprite to foreground
                                        ;        collision
                                        ;  0    1 = enable raster compare
.byte   $00                             ; sprite 0 to 7 foreground priority
.byte   $00                             ; sprite 0 to 7 multicolour
.byte   $00                             ; sprite 0 to 7 x expand
.byte   $00                             ; sprite 0 to 7 sprite collision
.byte   $00                             ; sprite 0 to 7 foreground collision
;+$20
.byte   $0E                             ; border colour
.byte   $06                             ; background colour 0
.byte   $01                             ; background colour 1
.byte   $02                             ; background colour 2
.byte   $03                             ; background colour 3
.byte   $04                             ; sprite multicolour 0
.byte   $00                             ; sprite multicolour 1
.byte   $01                             ; sprite 0 colour
.byte   $02                             ; sprite 1 colour
.byte   $03                             ; sprite 2 colour
.byte   $04                             ; sprite 3 colour
.byte   $05                             ; sprite 4 colour
.byte   $06                             ; sprite 5 colour
.byte   $07                             ; sprite 6 colour
;       .byte   $4C                     ; sprite 7 colour, actually the first
                                        ; character of "LOAD"


;******************************************************************************
;
; keyboard buffer for auto load/run

TblAutoLoadRun                          ;                               [ECE7]
.text   "LOAD",$0D,"RUN",$0D


;******************************************************************************
;
; LBs of screen line addresses

TblScrLinesLB                           ;                               [ECF0]
.byte   $00,$28,$50,$78,$A0
.byte   $C8,$F0,$18,$40,$68
.byte   $90,$B8,$E0,$08,$30
.byte   $58,$80,$A8,$D0,$F8
.byte   $20,$48,$70,$98,$C0


;******************************************************************************
;
; command serial bus device to TALK

CmdTALK2                                ;                               [ED09]
        ora     #$40                    ; OR with the TALK command
.byte   $2C                             ; makes next line BIT $xx20


;******************************************************************************
;
; command devices on the serial bus to LISTEN

CmdLISTEN2                              ;                               [ED0C]
        ora     #$20                    ; OR with the LISTEN command
        jsr     IsRS232Idle             ; check RS232 bus idle          [F0A4]


;******************************************************************************
;
; send a control character

SendCtrlChar                            ;                               [ED11]
        pha                             ; save device address

        bit     C3PO                    ; test deferred character flag
        bpl     A_ED20                  ; if no defered character continue

        sec                             ; else flag EOI
        ror     TEMPA3                  ; rotate into EOI flag byte

        jsr     IecByteOut22            ; Tx byte on serial bus         [ED40]

        lsr     C3PO                    ; clear deferred character flag
        lsr     TEMPA3                  ; clear EOI flag
A_ED20                                  ;                               [ED20]
        pla                             ; restore the device address
        sta     BSOUR                   ; save as serial defered character

        sei                             ; disable the interrupts

        jsr     IecDataH                ; set the serial data out high  [EE97]
        cmp     #$3F                    ; compare read byte with $3F
        bne     A_ED2E                  ; branch if not $3F, this branch will
                                        ; always be taken as after CIA 2's PCR
                                        ; is read it is ANDed with $DF, so the
                                        ; result can never be $3F ??

        jsr     IecClockH               ; set the serial clock out high [EE85]
A_ED2E                                  ;                               [ED2E]
        lda     CIA2DRA                 ; read CIA 2 DRA, serial port and video
                                        ; address
        ora     #$08                    ; mask 1xxx, set serial ATN low
        sta     CIA2DRA                 ; save CIA 2 DRA, serial port and video
                                        ; address

; if the code drops through to here the serial clock is low and the serial data
; has been released so the following code will have no effect apart from
; delaying the first byte by 1ms

; set the serial clk/data, wait and Tx byte on the serial bus

PrepareIEC                              ;                               [ED36]
        sei                             ; disable the interrupts

        jsr     IecClockL               ; set the serial clock out low  [EE8E]
        jsr     IecDataH                ; set the serial data out high  [EE97]
        jsr     Wait1ms                 ; 1ms delay                     [EEB3]


;******************************************************************************
;
; Tx byte on serial bus

IecByteOut22                            ;                               [ED40]
        sei                             ; disable the interrupts

        jsr     IecDataH                ; set the serial data out high  [EE97]

        jsr     IecData2Carry           ; get serial data status in Cb  [EEA9]
        bcs     A_EDAD                  ; if the serial data is high go do 
                                        ;'device not present'
        jsr     IecClockH               ; set the serial clock out high [EE85]

        bit     TEMPA3                  ; test the EOI flag
        bpl     A_ED5A                  ; if not EOI go ??

; I think this is the EOI sequence so the serial clock has been released and
; the serial data is being held low by the peripheral. first up wait for the
; serial data to rise

A_ED50                                  ;                               [ED50]
        jsr     IecData2Carry           ; get serial data status in Cb  [EEA9]
        bcc     A_ED50                  ; loop if the data is low

; now the data is high, EOI is signalled by waiting for at least 200us without
; pulling the serial clock line low again. the listener should respond by
; pulling the serial data line low

A_ED55                                  ;                               [ED55]
        jsr     IecData2Carry           ; get serial data status in Cb  [EEA9]
        bcs     A_ED55                  ; loop if the data is high

; the serial data has gone low ending the EOI sequence, now just wait for the
; serial data line to go high again or, if this isn't an EOI sequence, just
; wait for the serial data to go high the first time

A_ED5A                                  ;                               [ED5A]
        jsr     IecData2Carry           ; get serial data status in Cb  [EEA9]
        bcc     A_ED5A                  ; loop if the data is low

; serial data is high now pull the clock low, preferably within 60us

        jsr     IecClockL               ; set the serial clock out low  [EE8E]

; now the C64 has to send the eight bits, LSB first. first it sets the serial
; data line to reflect the bit in the byte, then it sets the serial clock to
; high. The serial clock is left high for 26 cycles, 23us on a PAL Vic, before
; it is again pulled low and the serial data is allowed high again

        lda     #$08                    ; eight bits to do
        sta     CNTDN                   ; set serial bus bit count
A_ED66                                  ;                               [ED66]
        lda     CIA2DRA                 ; read CIA 2 DRA, serial port and video
                                        ; address
        cmp     CIA2DRA                 ; compare it with itself
        bne     A_ED66                  ; if changed go try again

        asl                             ; shift the serial data into Cb
        bcc     A_EDB0                  ; if serial data is low, do serial bus
                                        ; timeout
        ror     BSOUR                   ; rotate the transmit byte
        bcs     A_ED7A                  ; if the bit = 1 go set the serial data
                                        ; out high
        jsr     IecDataL                ; else set serial data out low  [EEA0]
        bne     A_ED7D                  ; continue, branch always
A_ED7A                                  ;                               [ED7A]
        jsr     IecDataH                ; set the serial data out high  [EE97]
A_ED7D                                  ;                               [ED7D]
        jsr     IecClockH               ; set the serial clock out high [EE85]

        nop                             ; waste ..
        nop                             ; .. a ..
        nop                             ; .. cycle ..
        nop                             ; .. or two

        lda     CIA2DRA                 ; read CIA 2 DRA, serial port and video
                                        ; address
        and     #$DF                    ; mask xx0x, set serial data out high
        ora     #$10                    ; mask xxx1, set serial clock out low
        sta     CIA2DRA                 ; save CIA 2 DRA, serial port and video
                                        ; address
        dec     CNTDN                   ; decrement the serial bus bit count
        bne     A_ED66                  ; loop if not all done

; now all eight bits have been sent it's up to the peripheral to signal the
; byte was received by pulling the serial data low. this should be done within
; one milisecond

        lda     #$04                    ; wait for up to about 1ms
        sta     CIA1TI2H                ; save CIA 1 timer B HB

        lda     #$19                    ; load timer B, timer B single shot,
                                        ; start timer B
        sta     CIA1CTR2                ; save CIA 1 CRB

        lda     CIA1IRQ                 ; read CIA 1 ICR
A_ED9F                                  ;                               [ED9F]
        lda     CIA1IRQ                 ; read CIA 1 ICR
        and     #$02                    ; mask 0000 00x0, timer A interrupt
        bne     A_EDB0                  ; if timer A interrupt, do serial bus
                                        ; timeout
        jsr     IecData2Carry           ; get serial data status in Cb  [EEA9]
        bcs     A_ED9F                  ; if the serial data is high go wait
                                        ; some more
        cli                             ; enable the interrupts
        rts

; device not present

A_EDAD                                  ;                               [EDAD]
        lda     #$80                    ; error $80, device not present
.byte   $2C                             ; makes next line BIT $03A9

; timeout on serial bus

A_EDB0                                  ;                               [EDB0]
        lda     #$03                    ; error $03, read timeout, write timeout
SetIecStatus                            ;                               [EDB2]
        jsr     AorIecStatus            ; OR into serial status byte    [FE1C]

        cli                             ; enable the interrupts

        clc                             ; clear for branch
        bcc     A_EE03                  ; branch always


;******************************************************************************
;
; send secondary address after LISTEN

; this routine is used to send a secondary address to an I/O device after a
; call to the LISTEN routine is made and the device commanded to LISTEN. The
; routine cannot be used to send a secondary address after a call to the TALK
; routine.

; A secondary address is usually used to give set-up information to a device
; before I/O operations begin.

; When a secondary address is to be sent to a device on the serial bus the
; address must first be ORed with $60.

SAafterLISTEN2                          ;                               [EDB9]
        sta     BSOUR                   ; save the defered Tx byte

        jsr     PrepareIEC              ; set the serial clk/data, wait and Tx
                                        ; the byte                      [ED36]


;******************************************************************************
;
; set serial ATN high

IecAtnH                                 ;                               [EDBE]
        lda     CIA2DRA                 ; read CIA 2 DRA, serial port and video
                                        ; address
        and     #$F7                    ; mask 0xxx, set serial ATN high
        sta     CIA2DRA                 ; save CIA 2 DRA, serial port and video
                                        ; address

        rts


;******************************************************************************
;
; send secondary address after TALK

; this routine transmits a secondary address on the serial bus for a TALK
; device. This routine must be called with a number between 4 and 31 in the
; accumulator. The routine will send this number as a secondary address command
; over the serial bus. This routine can only be called after a call to the TALK
; routine. It will not work after a LISTEN.

SAafterTALK2                            ;                               [EDC7]
        sta     BSOUR                   ; save the defered Tx byte

        jsr     PrepareIEC              ; set the serial clk/data, wait and Tx
                                        ; the byte                      [ED36]


;******************************************************************************
;
; wait for the serial bus end after send

Wait4IEC                                ; return address from patch 6:
        sei                             ; disable the interrupts

        jsr     IecDataL                ; set the serial data out low   [EEA0]
        jsr     IecAtnH                 ; set serial ATN high           [EDBE]
        jsr     IecClockH               ; set the serial clock out high [EE85]
A_EDD6                                  ;                               [EDD6]
        jsr     IecData2Carry           ; get serial data status in Cb  [EEA9]
        bmi     A_EDD6                  ; loop if the clock is high

        cli                             ; enable the interrupts
        rts


;******************************************************************************
;
; output a byte to the serial bus

; this routine is used to send information to devices on the serial bus. A call
; to this routine will put a data byte onto the serial bus using full
; handshaking. Before this routine is called the LISTEN routine, F_FFB1, must
; be used to command a device on the serial bus to get ready to receive data.

; the accumulator is loaded with a byte to output as data on the serial bus. A
; device must be listening or the status word will return a timeout. This
; routine always buffers one character. So when a call to the UNLISTEN routine,
; F_FFAE, is made to end the data transmission, the buffered character is
; sent with EOI set. Then the UNLISTEN command is sent to the device.

IecByteOut2                             ;                               [EDDD]
        bit     C3PO                    ; test the deferred character flag
        bmi     A_EDE6                  ; if there is a defered character go
                                        ; send it
        sec                             ; set carry
        ror     C3PO                    ; shift into the deferred character flag
        bne     A_EDEB                  ; save the byte and exit, branch always

A_EDE6                                  ;                               [EDE6]
        pha                             ; save the byte

        jsr     IecByteOut22            ; Tx byte on serial bus         [ED40]

        pla                             ; restore the byte
A_EDEB                                  ;                               [EDEB]
        sta     BSOUR                   ; save the defered Tx byte

        clc                             ; flag ok

        rts


;******************************************************************************
;
; command serial bus to UNTALK

; this routine will transmit an UNTALK command on the serial bus. All devices
; previously set to TALK will stop sending data when this command is received.

IecUNTALK2                              ;                               [EDEF]
        sei                             ; disable the interrupts

        jsr     IecClockL               ; set the serial clock out low  [EE8E]

        lda     CIA2DRA                 ; read CIA 2 DRA, serial port and video
                                        ; address
        ora     #$08                    ; mask 1xxx, set the serial ATN low
        sta     CIA2DRA                 ; save CIA 2 DRA, serial port and video
                                        ; address
        lda     #$5F                    ; set the UNTALK command
.byte   $2C                             ; makes next line BIT $3FA9


;******************************************************************************
;
; command serial bus to UNLISTEN

; this routine commands all devices on the serial bus to stop receiving data
; from the computer. Calling this routine results in an UNLISTEN command being
; transmitted on the serial bus. Only devices previously commanded to listen
; will be affected.

; This routine is normally used after the computer is finished sending data to
; external devices. Sending the UNLISTEN will command the listening devices to
; get off the serial bus so it can be used for other purposes.

IecUNLISTEN2                            ;                               [EDFE]
        lda     #$3F                    ; set the UNLISTEN command
        jsr     SendCtrlChar            ; send a control character      [ED11]

; ATN high, delay, clock high then data high

A_EE03                                  ;                               [EE03]
        jsr     IecAtnH                 ; set serial ATN high           [EDBE]

; 1ms delay, clock high then data high

ResetIEC                                ;                               [EE06]
        txa                             ; save the device number
        ldx     #$0A                    ; short delay
A_EE09                                  ;                               [EE09]
        dex                             ; decrement the count
        bne     A_EE09                  ; loop if not all done

        tax                             ; restore the device number

        jsr     IecClockH               ; set the serial clock out high [EE85]
        jmp     IecDataH                ; set serial data out high and return
                                        ;                               [EE97]

;******************************************************************************
;
; input a byte from the serial bus

; this routine reads a byte of data from the serial bus using full handshaking.
; the data is returned in the accumulator. before using this routine the TALK
; routine, CmdTALK/$FFB4, must have been called first to command the device on
; the serial bus to send data on the bus. if the input device needs a secondary
; command it must be sent by using the TKSA routine, $FF96, before calling
; this routine.

; errors are returned in the status word which can be read by calling the
; READST routine, ReadIoStatus.

IecByteIn2                              ;                               [EE13]
        sei                             ; disable the interrupts

        lda     #$00                    ; set 0 bits to do, will flag EOI on
                                        ; timeout
        sta     CNTDN                   ; save the serial bus bit count

        jsr     IecClockH               ; set the serial clock out high [EE85]
A_EE1B                                  ;                               [EE1B]
        jsr     IecData2Carry           ; get serial data status in Cb  [EEA9]
        bpl     A_EE1B                  ; loop if the serial clock is low

A_EE20                                  ;                               [EE20]
        lda     #$01                    ; set the timeout count HB
        sta     CIA1TI2H                ; save CIA 1 timer B HB

        lda     #$19                    ; load timer B, timer B single shot,
                                        ; start timer B
        sta     CIA1CTR2                ; save CIA 1 CRB

        jsr     IecDataH                ; set the serial data out high  [EE97]

        lda     CIA1IRQ                 ; read CIA 1 ICR
A_EE30                                  ;                               [EE30]
        lda     CIA1IRQ                 ; read CIA 1 ICR
        and     #$02                    ; mask 0000 00x0, timer A interrupt
        bne     A_EE3E                  ; if timer A interrupt go ??

        jsr     IecData2Carry           ; get serial data status in Cb  [EEA9]
        bmi     A_EE30                  ; loop if the serial clock is low

        bpl     A_EE56                  ; else go set 8 bits to do, branch
                                        ; always
; timer A timed out
A_EE3E                                  ;                               [EE3E]
        lda     CNTDN                   ; get the serial bus bit count
        beq     A_EE47                  ; if not already EOI then go flag EOI

        lda     #$02                    ; else error $02, read timeour
        jmp     SetIecStatus            ; set the serial status and exit [EDB2]

A_EE47                                  ;                               [EE47]
        jsr     IecDataL                ; set the serial data out low   [EEA0]
        jsr     IecClockH               ; set the serial clock out high [EE85]

        lda     #$40                    ; set EOI
        jsr     AorIecStatus            ; OR into the serial status byte [FE1C]

        inc     CNTDN                   ; increment the serial bus bit count,
                                        ; do error on the next timeout
        bne     A_EE20                  ; go try again, branch always

A_EE56                                  ;                               [EE56]
        lda     #$08                    ; set 8 bits to do
        sta     CNTDN                   ; save the serial bus bit count
A_EE5A                                  ;                               [EE5A]
        lda     CIA2DRA                 ; read CIA 2 DRA, serial port and video
                                        ; address
        cmp     CIA2DRA                 ; compare it with itself
        bne     A_EE5A                  ; if changing go try again

        asl                             ; shift the serial data into the carry
        bpl     A_EE5A                  ; loop while the serial clock is low

        ror     TEMPA4                  ; shift data bit into receive byte
A_EE67                                  ;                               [EE67]
        lda     CIA2DRA                 ; read CIA 2 DRA, serial port and video
                                        ; address
        cmp     CIA2DRA                 ; compare it with itself
        bne     A_EE67                  ; if changing go try again

        asl                             ; shift the serial data into the carry
        bmi     A_EE67                  ; loop while the serial clock is high

        dec     CNTDN                   ; decrement the serial bus bit count
        bne     A_EE5A                  ; loop if not all done

        jsr     IecDataL                ; set the serial data out low   [EEA0]

        bit     STATUS                  ; test the serial status byte
        bvc     A_EE80                  ; if EOI not set, skip bus end sequence

        jsr     ResetIEC                ; 1ms delay, clock high then data high
                                        ;                               [EE06]
A_EE80                                  ;                               [EE80]
        lda     TEMPA4                  ; get the receive byte

        cli                             ; enable the interrupts
        clc                             ; flag ok

        rts


;******************************************************************************
;
; set the serial clock out high

IecClockH                               ;                               [EE85]
        lda     CIA2DRA                 ; read CIA 2 DRA, serial port and video
                                        ; address
        and     #$EF                    ; mask xxx0, set serial clock out high
        sta     CIA2DRA                 ; save CIA 2 DRA, serial port and video
                                        ; address

        rts


;******************************************************************************
;
; set the serial clock out low

IecClockL                               ;                               [EE8E]
        lda     CIA2DRA                 ; read CIA 2 DRA, serial port and video
                                        ; address
        ora     #$10                    ; mask xxx1, set serial clock out low
        sta     CIA2DRA                 ; save CIA 2 DRA, serial port and video
                                        ; address
        rts


;******************************************************************************
;
; set the serial data out high

IecDataH                                ;                               [EE97]
        lda     CIA2DRA                 ; read CIA 2 DRA, serial port and video
                                        ; address
        and     #$DF                    ; mask xx0x, set serial data out high
        sta     CIA2DRA                 ; save CIA 2 DRA, serial port and video
                                        ; address
        rts


;******************************************************************************
;
; set the serial data out low

IecDataL                                ;                               [EEA0]
        lda     CIA2DRA                 ; read CIA 2 DRA, serial port and video
                                        ; address
        ora     #$20                    ; mask xx1x, set serial data out low
        sta     CIA2DRA                 ; save CIA 2 DRA, serial port and video
                                        ; address
        rts


;******************************************************************************
;
; get serial data status in Cb

IecData2Carry                           ;                               [EEA9]
        lda     CIA2DRA                 ; read CIA 2 DRA, serial port and video
                                        ; address
        cmp     CIA2DRA                 ; compare it with itself
        bne     IecData2Carry           ; if changing got try again

        asl                             ; shift the serial data into Cb

        rts


;******************************************************************************
;
; 1ms delay

Wait1ms                                 ;                               [EEB3]
        txa                             ; save X
        ldx     #$B8                    ; set the loop count
A_EEB6                                  ;                               [EEB6]
        dex                             ; decrement the loop count
        bne     A_EEB6                  ; loop if more to do

        tax                             ; restore X

        rts


;******************************************************************************
;
; RS232 Tx NMI routine

RS232_TX_NMI                            ;                               [EEBB]
        lda     BITTS                   ; get RS232 bit count
        beq     RS232_NextTx            ; if zero go setup next RS232 Tx byte
                                        ; and return
        bmi     A_EF00                  ; if -ve go do stop bit(s)

; else bit count is non zero and +ve
        lsr     RODATA                  ; shift RS232 output byte buffer

        ldx     #$00                    ; set $00 for bit = 0
        bcc     A_EEC8                  ; branch if bit was 0

        dex                             ; set $FF for bit = 1
A_EEC8                                  ;                               [EEC8]
        txa                             ; copy bit to A
        eor     ROPRTY                  ; EOR with RS232 parity byte
        sta     ROPRTY                  ; save RS232 parity byte

        dec     BITTS                   ; decrement RS232 bit count
        beq     A_EED7                  ; if RS232 bit count now zero go do
                                        ; parity bit
; save bit and exit
A_EED1                                  ;                               [EED1]
        txa                             ; copy bit to A
        and     #$04                    ; mask 0000 0x00, RS232 Tx DATA bit
        sta     NXTBIT                  ; save the next RS232 data bit to send

        rts

; do RS232 parity bit, enters with RS232 bit count = 0

A_EED7                                  ;                               [EED7]
        lda     #$20                    ; mask 00x0 0000, parity enable bit
        bit     M51CDR                  ; test the pseudo 6551 command register
        beq     A_EEF2                  ; if parity disabled go ??

        bmi     A_EEFC                  ; if fixed mark or space parity go ??

        bvs     A_EEF6                  ; if even parity go ??

; else odd parity
        lda     ROPRTY                  ; get RS232 parity byte
        bne     A_EEE7                  ; if not zero leave parity bit = 0

A_EEE6                                  ;                               [EEE6]
        dex                             ; make parity bit = 1
A_EEE7                                  ;                               [EEE7]
        dec     BITTS                   ; decrement RS232 bit count, 1 stop bit

        lda     M51CTR                  ; get pseudo 6551 control register
        bpl     A_EED1                  ; if 1 stop bit save parity bit and exit

; else two stop bits ..
        dec     BITTS                   ; decrement RS232 bit count, 2 stop bits
        bne     A_EED1                  ; save bit and exit, branch always

; parity is disabled so the parity bit becomes the first, and possibly only,
; stop bit. to do this increment the bit count which effectively decrements the
; stop bit count.
A_EEF2                                  ;                               [EEF2]
        inc     BITTS                   ; increment RS232 bit count, = -1 stop
                                        ; bit
        bne     A_EEE6                  ; set stop bit = 1 and exit

; do even parity
A_EEF6                                  ;                               [EEF6]
        lda     ROPRTY                  ; get RS232 parity byte
        beq     A_EEE7                  ; if parity zero leave parity bit = 0

        bne     A_EEE6                  ; else branch always

; fixed mark or space parity
A_EEFC                                  ;                               [EEFC]
        bvs     A_EEE7                  ; if fixed space parity leave parity
                                        ; bit = 0
        bvc     A_EEE6                  ; else fixed mark parity make parity
                                        ; bit = 1, branch always

; decrement stop bit count, set stop bit = 1 and exit. $FF is one stop bit, $FE
; is two stop bits

A_EF00                                  ;                               [EF00]
        inc     BITTS                   ; decrement RS232 bit count

        ldx     #$FF                    ; set stop bit = 1
        bne     A_EED1                  ; save stop bit and exit, branch always


;******************************************************************************
;
; setup next RS232 Tx byte

RS232_NextTx                            ;                               [EF06]
        lda     M51CDR                  ; read the 6551 pseudo command register
        lsr                             ; handshake bit inot Cb
        bcc     A_EF13                  ; if 3 line interface go ??

        bit     CIA2DRB                 ; test CIA 2 DRB, RS232 port

        bpl     A_EF2E                  ; if DSR = 0 set DSR signal not present
                                        ; and exit
        bvc     A_EF31                  ; if CTS = 0 set CTS signal not present
                                        ; and exit
; was 3 line interface
A_EF13                                  ;                               [EF13]
        lda     #$00                    ; clear A
        sta     ROPRTY                  ; clear the RS232 parity byte
        sta     NXTBIT                  ; clear the RS232 next bit to send

        ldx     BITNUM                  ; get the number of bits to be
                                        ; sent/received
        stx     BITTS                   ; set the RS232 bit count

        ldy     RODBE                   ; get the index to the Tx buffer start
        cpy     RODBS                   ; compare it with index of Tx buffer end
        beq     A_EF39                  ; if all done go disable T?? interrupt
                                        ; and return
        lda     (ROBUF),Y               ; else get a byte from the buffer
        sta     RODATA                  ; save it to RS232 output byte buffer

        inc     RODBE                   ; increment index of the Tx buffer start

        rts


;******************************************************************************
;
; set DSR signal not present

A_EF2E                                  ;                               [EF2E]
        lda     #$40                    ; set DSR signal not present
.byte   $2C                             ; makes next line BIT $10A9


;******************************************************************************
;
; set CTS signal not present

A_EF31                                  ;                               [EF31]
        lda     #$10                    ; set CTS signal not present
        ora     RSSTAT                  ; OR it with the RS232 status register
        sta     RSSTAT                  ; save the RS232 status register


;******************************************************************************
;
; disable timer A interrupt

A_EF39                                  ;                               [EF39]
        lda     #$01                    ; disable timer A interrupt


;******************************************************************************
;
; set CIA 2 ICR from A

Set_VIA2_ICR                            ;                               [EF3B]
        sta     CIA2IRQ                 ; save CIA 2 ICR

        eor     ENABL                   ; EOR with RS-232 interrupt enable byte
        ora     #$80                    ; set the interrupts enable bit
        sta     ENABL                   ; save RS-232 interrupt enable byte
        sta     CIA2IRQ                 ; save CIA 2 ICR

        rts


;******************************************************************************
;
; compute bit count

CalcBitCounts                           ;                               [EF4A]
        ldx     #$09                    ; set bit count to 8 data + 1 stop bit

        lda     #$20                    ; mask for 8/7 data bits
        bit     M51CTR                  ; test pseudo 6551 control register
        beq     A_EF54                  ; branch if 8 bits

        dex                             ; else decrement count for 7 data bits
A_EF54                                  ;                               [EF54]
        bvc     A_EF58                  ; branch if 7 bits

        dex                             ; else decrement count ..
        dex                             ; .. for 5 data bits
A_EF58                                  ;                               [EF58]
        rts


;******************************************************************************
;
; RS232 Rx NMI

RS232_RX_NMI                            ;                               [EF59]
        ldx     RINONE                  ; get start bit check flag
        bne     A_EF90                  ; if no start bit received go ??

        dec     BITCI                   ; decrement receiver bit count in
        beq     A_EF97                  ; if the byte is complete go add it to
                                        ; the buffer
        bmi     A_EF70                  ;.

        lda     INBIT                   ; get the RS232 received data bit
        eor     RIPRTY                  ; EOR with the receiver parity bit
        sta     RIPRTY                  ; save the receiver parity bit

        lsr     INBIT                   ; shift the RS232 received data bit
        ror     RIDATA                  ;.
A_EF6D                                  ;                               [EF6D]
        rts

A_EF6E                                  ;                               [EF6E]
        dec     BITCI                   ; decrement receiver bit count in
A_EF70                                  ;                               [EF70]
        lda     INBIT                   ; get the RS232 received data bit
        beq     A_EFDB                  ;.

        lda     M51CTR                  ; get pseudo 6551 control register
        asl                             ; shift the stop bit flag to Cb

        lda     #$01                    ; + 1
        adc     BITCI                   ; add receiver bit count in
        bne     A_EF6D                  ; exit, branch always


;******************************************************************************
;
; setup to receive an RS232 bit

SetupRS232_RX                           ;                               [EF7E]
        lda     #$90                    ; enable FLAG interrupt
        sta     CIA2IRQ                 ; save CIA 2 ICR

        ora     ENABL                   ; OR with RS-232 interrupt enable byte
        sta     ENABL                   ; save RS-232 interrupt enable byte
        sta     RINONE                  ; set start bit check flag, set no start
                                        ; bit received
        lda     #$02                    ; disable timer B interrupt
        jmp     Set_VIA2_ICR            ; set CIA 2 ICR from A and return [EF3B]


;******************************************************************************
;
; no RS232 start bit received

A_EF90                                  ;                               [EF90]
        lda     INBIT                   ; get the RS232 received data bit
        bne     SetupRS232_RX           ; if ?? go setup to receive an RS232
                                        ; bit and return
.if Version=3
        jmp     RS232_SaveSet           ; flag RS232 start bit and set parity
                                        ;                               [E4D3]
.else
        sta     RINONE

        rts
.fi


;******************************************************************************
;
; received a whole byte, add it to the buffer

A_EF97                                  ;                               [EF97]
        ldy     RIDBE                   ; get index to Rx buffer end
        iny                             ; increment index
        cpy     RIDBS                   ; compare with index to Rx buffer start
        beq     A_EFCA                  ; if buffer full go do Rx overrun error

        sty     RIDBE                   ; save index to Rx buffer end

        dey                             ; decrement index

        lda     RIDATA                  ; get assembled byte

        ldx     BITNUM                  ; get bit count
A_EFA9                                  ;                               [EFA9]
        cpx     #$09                    ; compare with byte + stop
        beq     A_EFB1                  ; branch if all nine bits received

        lsr                             ; else shift byte

        inx                             ; increment bit count
        bne     A_EFA9                  ; loop, branch always

A_EFB1                                  ;                               [EFB1]
        sta     (RIBUF),Y               ; save received byte to Rx buffer

        lda     #$20                    ; mask 00x0 0000, parity enable bit
        bit     M51CDR                  ; test the pseudo 6551 command register
        beq     A_EF6E                  ; branch if parity disabled

        bmi     A_EF6D                  ; branch if mark or space parity

        lda     INBIT                   ; get the RS232 received data bit
        eor     RIPRTY                  ; EOR with the receiver parity bit
        beq     A_EFC5                  ;.

        bvs     A_EF6D                  ; if ?? just exit

.byte   $2C                             ; makes next line BIT $xxxx
A_EFC5                                  ;                               [EFC5]
        bvc     A_EF6D                  ; if ?? just exit

        lda     #$01                    ; set Rx parity error
.byte   $2C                             ; makes next line BIT $04A9
A_EFCA                                  ;                               [EFCA]
        lda     #$04                    ; set Rx overrun error
.byte   $2C                             ; makes next line BIT NumericTestA9
A_EFCD                                  ;                               [EFCD]
        lda     #$80                    ; set Rx break error
.byte   $2C                             ; makes next line BIT $02A9
A_EFD0                                  ;                               [EFD0]
        lda     #$02                    ; set Rx frame error
        ora     RSSTAT                  ; OR it with the RS232 status byte
        sta     RSSTAT                  ; save the RS232 status byte

        jmp     SetupRS232_RX           ; setup to receive an RS232 bit and
                                        ; return                        [EF7E]

A_EFDB                                  ;                               [EFDB]
        lda     RIDATA                  ;.
        bne     A_EFD0                  ; if ?? do frame error

        beq     A_EFCD                  ; else do break error, branch always


;******************************************************************************
;
; open RS232 channel for output

OpenRsChan4Out                          ;                               [EFE1]
        sta     DFLTO                   ; save the output device number

        lda     M51CDR                  ; read the pseudo 6551 command register
        lsr                             ; shift handshake bit to carry
        bcc     A_F012                  ; if 3 line interface go ??

        lda     #$02                    ; mask 0000 00x0, RTS out
        bit     CIA2DRB                 ; test CIA 2 DRB, RS232 port
        bpl     DeactivateDSR           ; if DSR=0 set DSR not present and exit

        bne     A_F012                  ; if RTS = 1 just exit

A_EFF2                                  ;                               [EFF2]
        lda     ENABL                   ; get RS-232 interrupt enable byte
        and     #$02                    ; mask 0000 00x0, timer B interrupt
        bne     A_EFF2                  ; loop while timer B interrupt is
                                        ; enebled
A_EFF9                                  ;                               [EFF9]
        bit     CIA2DRB                 ; test CIA 2 DRB, RS232 port
        bvs     A_EFF9                  ; loop while CTS high

        lda     CIA2DRB                 ; read CIA 2 DRB, RS232 port
        ora     #$02                    ; mask xx1x, set RTS high
        sta     CIA2DRB                 ; save CIA 2 DRB, RS232 port
A_F006                                  ;                               [F006]
        bit     CIA2DRB                 ; test CIA 2 DRB, RS232 port
        bvs     A_F012                  ; exit if CTS high

        bmi     A_F006                  ; loop while DSR high

; set no DSR and exit

DeactivateDSR                           ;                               [F00D]
        lda     #$40                    ; set DSR signal not present
        sta     RSSTAT                  ; save the RS232 status register
A_F012                                  ;                               [F012]
        clc                             ; flag ok

        rts


;******************************************************************************
;
; send byte to the RS232 buffer

A_F014                                  ;                               [F014]
        jsr     SetupRS232_TX           ; setup for RS232 transmit      [F028]

; send byte to the RS232 buffer, no setup

Byte2RS232Buf                           ;                               [F017]
        ldy     RODBS                   ; get index to Tx buffer end
        iny                             ; + 1
        cpy     RODBE                   ; compare with index to Tx buffer start
        beq     A_F014                  ; loop while buffer full

        sty     RODBS                   ; set index to Tx buffer end

        dey                             ; index to available buffer byte
        lda     PTR1                    ; read the RS232 character buffer
        sta     (ROBUF),Y               ; save the byte to the buffer


;******************************************************************************
;
; setup for RS232 transmit

SetupRS232_TX                           ;                               [F028]
        lda     ENABL                   ; get RS-232 interrupt enable byte
        lsr                             ; shift the enable bit to Cb
        bcs     A_F04C                  ; if interrupts are enabled just exit

        lda     #$10                    ; start timer A
        sta     CIA2CTR1                ; save CIA 2 CRA

        lda     BAUDOF                  ; get the baud rate bit time LB
        sta     CIA2TI1L                ; save CIA 2 timer A LB

        lda     BAUDOF+1                ; get the baud rate bit time HB
        sta     CIA2TI1H                ; save CIA 2 timer A HB

        lda     #$81                    ; enable timer A interrupt
        jsr     Set_VIA2_ICR            ; set CIA 2 ICR from A          [EF3B]

        jsr     RS232_NextTx            ; setup next RS232 Tx byte      [EF06]

        lda     #$11                    ; load timer A, start timer A
        sta     CIA2CTR1                ; save CIA 2 CRA
A_F04C                                  ;                               [F04C]
        rts


;******************************************************************************
;
; input from RS232 buffer

InputRS232Buf                           ;                               [F04D]
        sta     DFLTN                   ; save the input device number

        lda     M51CDR                  ; get pseudo 6551 command register
        lsr                             ; shift the handshake bit to Cb
        bcc     A_F07D                  ; if 3 line interface go ??

        and     #$08                    ; mask the duplex bit, pseudo 6551
                                        ; command is >> 1
        beq     A_F07D                  ; if full duplex go ??

        lda     #$02                    ; mask 0000 00x0, RTS out
        bit     CIA2DRB                 ; test CIA 2 DRB, RS232 port
        bpl     DeactivateDSR           ; if DSR = 0 set no DSR and exit

        beq     A_F084                  ; if RTS = 0 just exit

A_F062                                  ;                               [F062]
        lda     ENABL                   ; get RS-232 interrupt enable byte
        lsr                             ; shift the timer A interrupt enable
                                        ; bit to Cb
        bcs     A_F062                  ; loop while the timer A interrupt is
                                        ; enabled

        lda     CIA2DRB                 ; read CIA 2 DRB, RS232 port
        and     #$FD                    ; mask xx0x, clear RTS out
        sta     CIA2DRB                 ; save CIA 2 DRB, RS232 port
A_F070                                  ;                               [F070]
        lda     CIA2DRB                 ; read CIA 2 DRB, RS232 port
        and     #$04                    ; mask x1xx, DTR in
        beq     A_F070                  ; loop while DTR low

A_F077                                  ;                               [F077]
        lda     #$90                    ; enable the FLAG interrupt
        clc                             ; flag ok
        jmp     Set_VIA2_ICR            ; set CIA 2 ICR from A and return [EF3B]

A_F07D                                  ;                               [F07D]
        lda     ENABL                   ; get RS-232 interrupt enable byte
        and     #$12                    ; mask 000x 00x0
        beq     A_F077                  ; if FLAG or timer B bits set go enable
                                        ; the FLAG inetrrupt
A_F084                                  ;                               [F084]
        clc                             ; flag ok

        rts


;******************************************************************************
;
; get byte from RS232 buffer

GetBytRS232Buf                          ;                               [F086]
        lda     RSSTAT                  ; get the RS232 status register

        ldy     RIDBS                   ; get index to Rx buffer start
        cpy     RIDBE                   ; compare with index to Rx buffer end
        beq     A_F09C                  ; return null if buffer empty

        and     #$F7                    ; clear the Rx buffer empty bit
        sta     RSSTAT                  ; save the RS232 status register

        lda     (RIBUF),Y               ; get byte from Rx buffer

        inc     RIDBS                   ; increment index to Rx buffer start

        rts


A_F09C                                  ;                               [F09C]
        ora     #$08                    ; set the Rx buffer empty bit
        sta     RSSTAT                  ; save the RS232 status register

        lda     #$00                    ; return null
        rts


;******************************************************************************
;
; check RS232 bus idle

IsRS232Idle                             ;                               [F0A4]
        pha                             ; save A
        lda     ENABL                   ; get RS-232 interrupt enable byte
        beq     A_F0BB                  ; if no interrupts enabled just exit

A_F0AA                                  ;                               [F0AA]
        lda     ENABL                   ; get RS-232 interrupt enable byte
        and     #$03                    ; mask 0000 00xx, the error bits
        bne     A_F0AA                  ; if there are errors loop

        lda     #$10                    ; disable FLAG interrupt
        sta     CIA2IRQ                 ; save CIA 2 ICR

        lda     #$00                    ; clear A
        sta     ENABL                   ; clear RS-232 interrupt enable byte
A_F0BB                                  ;                               [F0BB]
        pla                             ; restore A
        rts


;******************************************************************************
;
; kernel I/O messages

TxtIO_ERROR                             ;                               [F0BD]
.byte   $0D
.shift  'I/O ERROR #'

TxtSEARCHING                            ;                               [F0C9]
.byte   $0D
.shift  'SEARCHING '

TxtFOR                                  ;                               [F0D4]
.shift  'FOR '

TxtPRESS_PLAY                           ;                               [F0D8]
.byte   $0D
.shift  'PRESS PLAY ON TAPE'

TxtPRESS_RECO                           ;                               [F0EB]
.shift  'PRESS RECORD & PLAY ON TAPE'

TxtLOADING                              ;                               [F106]
.byte   $0D
.shift  'LOADING'

TxtSAVING                               ;                               [F10E]
.byte   $0D
.shift  'SAVING '

TxtVERIFYING                            ;                               [F116]
.byte   $0D
.shift  'VERIFYING'

TxtFOUND                                ;                               [F120]
.byte   $0D
.shift  'FOUND '

TxtOK2                                  ;                               [F127]
.shift  $0D, 'OK', $0D


;******************************************************************************
;
; display control I/O message if in direct mode

DisplayIoMsg                            ;                               [F12B]
        bit     MSGFLG                  ; test message mode flag
        bpl     A_F13C                  ; exit if control messages off

; display kernel I/O message

DisplayIoMsg2                           ;                               [F12F]
        lda     TxtIO_ERROR,Y           ; get byte from message table
        php                             ; save status
        and     #$7F                    ; clear b7
        jsr     OutByteChan             ; output character to channel   [FFD2]

        iny                             ; increment index

        plp                             ; restore status
        bpl     DisplayIoMsg2           ; loop if not end of message

A_F13C                                  ;                               [F13C]
        clc                             ;.

        rts


;******************************************************************************
;
; get character from the input device

; in practice this routine operates identically to the CHRIN routine,
; ByteFromChan, for all devices except for the keyboard. If the keyboard is the
; current input device this routine will get one character from the keyboard
; buffer. It depends on the IRQ routine to read the keyboard and put characters
; into the buffer.

; If the keyboard buffer is empty the value returned in the accumulator will be
; zero

GetByteInpDev                           ;                               [F13E]
        lda     DFLTN                   ; get the input device number
        bne     A_F14A                  ; if not the keyboard go handle other
                                        ; devices
; the input device was the keyboard
        lda     NDX                     ; get the keyboard buffer index
        beq     A_F155                  ; if the buffer is empty go flag no
                                        ; byte and return
        sei                             ; disable the interrupts

        jmp     GetCharKeybBuf          ; get input from the keyboard buffer
                                        ; and return                    [E5B4]

; the input device was not the keyboard
A_F14A                                  ;                               [F14A]
        cmp     #$02                    ; compare device with the RS232 device
        bne     A_F166                  ; if not the RS232 device, ->

; the input device is the RS232 device
GetByteInpDev2                          ;                               [F14E]
        sty     TEMP97                  ; save Y

        jsr     GetBytRS232Buf          ; get a byte from RS232 buffer  [F086]

        ldy     TEMP97                  ; restore Y
A_F155                                  ;                               [F155]
        clc                             ; flag no error

        rts


;******************************************************************************
;
; input a character from channel

; this routine will get a byte of data from the channel already set up as the
; input channel by the CHKIN routine, OpenChan4Inp.

; If CHKIN, OpenChan4Inp, has not been used to define another input channel
; the data is expected to be from the keyboard. the data byte is returned in
; the accumulator. the channel remains open after the call.

; input from the keyboard is handled in a special way. first, the cursor is
; turned on and it will blink until a carriage return is typed on the keyboard.
; all characters on the logical line, up to 88 characters, will be stored in
; the BASIC input buffer. then the characters can be returned one at a time by
; calling this routine once for each character. when the carriage return is
; returned the entire line has been processed. the next time this routine is
; called the whole process begins again.

ByteFromChan2                           ;                               [F157]
        lda     DFLTN                   ; get the input device number
        bne     A_F166                  ; if not the keyboard continue

; the input device was the keyboard
        lda     LineCurCol              ; get the cursor column
        sta     CursorCol               ; set the input cursor column

        lda     PhysCurRow              ; get the cursor row
        sta     CursorRow               ; set the input cursor row

        jmp     InputScrKeyb            ; input from screen or keyboard [E632]

; the input device was not the keyboard
A_F166                                  ;                               [F166]
        cmp     #$03                    ; compare device number with screen
        bne     A_F173                  ; if not screen continue

; the input device was the screen
        sta     CRSW                    ; input from keyboard or screen, 
                                        ;$xx = screen,
                                        ; $00 = keyboard
        lda     CurLineLeng             ; get current screen line length
        sta     INDX                    ; save input [EOL] pointer

        jmp     InputScrKeyb            ; input from screen or keyboard [E632]

; the input device was not the screen
A_F173                                  ;                               [F173]
        bcs     A_F1AD                  ; if input device > screen, do IEC
                                        ; devices
; the input device was < screen
        cmp     #$02                    ; compare device with the RS232 device
        beq     A_F1B8                  ; if RS232 device, go get a byte from
                                        ; the RS232 device
; only the tape device left ..
        stx     TEMP97                  ; save X

        jsr     GetByteTape             ; get a byte from tape          [F199]
        bcs     A_F196                  ; if error just exit

        pha                             ; save the byte

        jsr     GetByteTape             ; get the next byte from tape   [F199]
        bcs     A_F193                  ; if error just exit

        bne     A_F18D                  ; if end reached ??

        lda     #$40                    ; set EOI
        jsr     AorIecStatus            ; OR into the serial status byte [FE1C]
A_F18D                                  ;                               [F18D]
        dec     BUFPNT                  ; decrement tape buffer index

        ldx     TEMP97                  ; restore X

        pla                             ; restore the saved byte
        rts

; error exit from input character

A_F193                                  ;                               [F193]
        tax                             ; copy the error byte

        pla                             ; dump the saved byte
        txa                             ; restore error byte
A_F196                                  ;                               [F196]
        ldx     TEMP97                  ; restore X
        rts


;******************************************************************************
;
; get byte from tape

GetByteTape                             ;                               [F199]
        jsr     BumpTapePtr             ; bump tape pointer             [F80D]
        bne     A_F1A9                  ; if not end get next byte and exit

        jsr     InitTapeRead            ; initiate tape read            [F841]
        bcs     A_F1B4                  ; exit if error flagged

        lda     #$00                    ; clear A
        sta     BUFPNT                  ; clear tape buffer index
        beq     GetByteTape             ; loop, branch always

A_F1A9                                  ;                               [F1A9]
        lda     (TapeBufPtr),Y          ; get next byte from buffer

        clc                             ; flag no error

        rts

; input device was serial bus
A_F1AD                                  ;                               [F1AD]
        lda     STATUS                  ; get the serial status byte
        beq     A_F1B5                  ; if no errors flagged go input byte
                                        ; and return
A_F1B1                                  ;                               [F1B1]
        lda     #$0D                    ; else return [EOL]
A_F1B3                                  ;                               [F1B3]
        clc                             ; flag no error
A_F1B4                                  ;                               [F1B4]
        rts

A_F1B5                                  ;                               [F1B5]
        jmp     IecByteIn2              ; input byte from serial bus and return
                                        ;                               [EE13]
; input device was RS232 device
A_F1B8                                  ;                               [F1B8]
        jsr     GetByteInpDev2          ; get byte from RS232 device    [F14E]
        bcs     A_F1B4                  ; branch if error, this doesn't get
                                        ; taken as the last instruction in the
                                        ; get byte from RS232 device routine
                                        ; is CLC ??
        cmp     #$00                    ; compare with null
        bne     A_F1B3                  ; exit if not null

        lda     RSSTAT                  ; get the RS232 status register
        and     #$60                    ; mask 0xx0 0000, DSR detected and ??
        bne     A_F1B1                  ; if ?? return null

        beq     A_F1B8                  ; else loop, branch always


;******************************************************************************
;
; output character to channel

; this routine will output a character to an already opened channel. Use the
; OPEN routine, OpenLogFile, and the CHKOUT routine, OpenChan4OutpB, to set up
; the output channel before calling this routine. If these calls are omitted,
; data will be sent to the default output device, device 3, the screen. The
; data byte to be output is loaded into the accumulator, and this routine is
; called. The data is then sent to the specified output device. The channel is
; left open after the call.

; NOTE: Care must be taken when using routine to send data to a serial device
; since data will be sent to all open output channels on the bus. Unless this
; is desired, all open output channels on the serial bus other than the
; actually intended destination channel must be closed by a call to the KERNAL
; close channel routine.

OutByteChan2                            ;                               [F1CA]
        pha                             ; save the character to output

        lda     DFLTO                   ; get the output device number
S_F1CD 
        cmp     #$03                    ; compare the output device with screen
        bne     A_F1D5                  ; if not the screen go ??

; the output device is the screen
        pla                             ; else restore the output character
        jmp     OutputChar              ; go output the character to the screen
                                        ;                               [E716]

; the output device was not the screen
A_F1D5                                  ;                               [F1D5]
        bcc     OutByteChan2b           ; if < screen go ??

; the output device was > screen so it is a serial bus device
        pla                             ; else restore the output character
        jmp     IecByteOut2             ; go output the character to the serial
                                        ; bus                           [EDDD]

; the output device is < screen
OutByteChan2b                           ;                               [F1DB]
        lsr                             ; shift b0 of the device into Cb

        pla                             ; restore the output character


;******************************************************************************
;
; output the character to the cassette or RS232 device

OutByteCasRS                            ;                               [F1DD]
        sta     PTR1                    ; save character to character buffer

        txa                             ; copy X
        pha                             ; save X

        tya                             ; copy Y
        pha                             ; save Y

        bcc     A_F208                  ; if Cb is clear it must be RS232 device

; output the character to the cassette
        jsr     BumpTapePtr             ; bump the tape pointer         [F80D]
        bne     A_F1F8                  ; if not end save next byte and exit

        jsr     InitTapeWrite           ; initiate tape write           [F864]
        bcs     A_F1FD                  ; exit if error

        lda     #$02                    ; set data block type ??
        ldy     #$00                    ; clear index
        sta     (TapeBufPtr),Y          ; save type to buffer ??

        iny                             ; increment index
        sty     BUFPNT                  ; save tape buffer index
A_F1F8                                  ;                               [F1F8]
        lda     PTR1                    ; restore char from character buffer
        sta     (TapeBufPtr),Y          ; save to buffer
J_F1FC                                  ;                               [F1FC]
        clc                             ; flag no error
A_F1FD                                  ;                               [F1FD]
        pla                             ; pull Y
        tay                             ; restore Y

        pla                             ; pull X
        tax                             ; restore X

        lda     PTR1                    ; get character from character buffer
        bcc     A_F207                  ; exit if no error

        lda     #$00                    ; else clear A
A_F207                                  ;                               [F207]
        rts

; output the character to the RS232 device
A_F208                                  ;                               [F208]
        jsr     Byte2RS232Buf           ; send byte to RS232 buffer, no setup
                                        ;                               [F017]
        jmp     J_F1FC                  ; do no error exit              [F1FC]


;******************************************************************************
;
; open channel for input

; any logical file that has already been opened by the OPEN routine,
; OpenLogFile, can be defined as an input channel by this routine. the device
; on the channel must be an input device or an error will occur and the routine
; will abort.

; if you are getting data from anywhere other than the keyboard, this routine
; must be called before using either the CHRIN routine, ByteFromChan, or the
; GETIN routine, GetCharFromIO12. if you are getting data from the keyboard and
; no other input channels are open then the calls to this routine and to the
; OPEN routine, OpenLogFile, are not needed.

; when used with a device on the serial bus this routine will automatically
; send the listen address specified by the OPEN routine, OpenLogFile, and any
; secondary address.

; possible errors are:
;
;       3 : file not open
;       5 : device not present
;       6 : file is not an input file

OpenChanInput                           ;                               [F20E]
        jsr     FindFile                ; find a file                   [F30F]
        beq     A_F216                  ; if the file is open continue

        jmp     FileNotOpenErr          ; else do 'file not open' error and
                                        ; return                        [F701]
A_F216                                  ;                               [F216]
        jsr     SetFileDetails          ; set file details from table,X [F31F]
S_F219 
        lda     FA                      ; get the device number
        beq     A_F233                  ; if the device was the keyboard save
                                        ; the device #, flag ok and exit
        cmp     #$03                    ; compare device number with screen
        beq     A_F233                  ; if the device was the screen save the
                                        ; device #, flag ok and exit
        bcs     A_F237                  ; if device was a serial bus device, ->

        cmp     #$02                    ; RS232?
        bne     A_F22A                  ; no, -> tape

        jmp     InputRS232Buf           ; else go get input from the RS232
                                        ; buffer and return             [F04D]
; Handle tape
A_F22A                                  ;                               [F22A]
        ldx     SA                      ; get the secondary address
        cpx     #$60                    ;.
        beq     A_F233                  ;.

        jmp     NoInputFileErr          ; go do 'not input file' error and
                                        ; return                        [F70A]

A_F233                                  ;                               [F233]
        sta     DFLTN                   ; save the input device number

        clc                             ; flag ok

        rts

; the device was a serial bus device
A_F237                                  ;                               [F237]
        tax                             ; copy device number to X
        jsr     CmdTALK2                ; command serial device to TALK [ED09]

        lda     SA                      ; get the secondary address
        bpl     A_F245                  ;.

        jsr     Wait4IEC                ; wait for the serial bus end after
                                        ; send                          [EDCC]
        jmp     A_F248                  ;                               [F248]

A_F245                                  ;                               [F245]
        jsr     SAafterTALK2            ; send secondary address after TALK
                                        ;                               [EDC7]
A_F248                                  ;                               [F248]
        txa                             ; copy device back to A
        bit     STATUS                  ; test the serial status byte
        bpl     A_F233                  ; if device present save device number
                                        ; and exit
        jmp     DevNotPresent           ; do 'device not present' error and
                                        ; return                        [F707]

;******************************************************************************
;
; open channel for output

; any logical file that has already been opened by the OPEN routine,
; OpenLogFile, can be defined as an output channel by this routine the device
; on the channel must be an output device or an error will occur and the
; routine will abort.

; if you are sending data to anywhere other than the screen this routine must
; be called before using the CHROUT routine, OutByteChan. if you are sending
; data to the screen and no other output channels are open then the calls to
; this routine and to the OPEN routine, OpenLogFile, are not needed.

; when used with a device on the serial bus this routine will automatically
; send the listen address specified by the OPEN routine, OpenLogFile, and any
; secondary address.

; possible errors are:
;
;       3 : file not open
;       5 : device not present
;       7 : file is not an output file

OpenChanOutput                          ;                               [F250]
        jsr     FindFile                ; find a file                   [F30F]
        beq     A_F258                  ; if file found continue

        jmp     FileNotOpenErr          ; else do 'file not open' error and
                                        ; return                        [F701]

A_F258                                  ;                               [F258]
        jsr     SetFileDetails          ; set file details from table,X [F31F]
S_F25B 
        lda     FA                      ; get the device number
        bne     A_F262                  ; if not the keyboard, ->
A_F25F                                  ;                               [F25F]
        jmp     NoOutpFileErr           ; go do 'not output file' error and
                                        ; return                        [F70D]
A_F262                                  ;                               [F262]
        cmp     #$03                    ; compare the device with the screen
        beq     A_F275                  ; if device is screen go save output
                                        ; device number and exit
        bcs     A_F279                  ; if > screen then go handle a serial
                                        ; bus device
        cmp     #$02                    ; RS232?
        bne     A_F26F                  ; no, -> tape

        jmp     OpenRsChan4Out          ; else go open RS232 channel for output
                                        ;                               [EFE1]
; open a tape channel for output
A_F26F                                  ;                               [F26F]
        ldx     SA                      ; get the secondary address
        cpx     #$60                    ;.
        beq     A_F25F                  ; if ?? do not output file error and
                                        ; return
A_F275                                  ;                               [F275]
        sta     DFLTO                   ; save the output device number

        clc                             ; flag ok

        rts

; open an IEC channel for output
A_F279                                  ;                               [F279]
        tax                             ; copy the device number
        jsr     CmdLISTEN2              ; command devices on the serial bus to
                                        ; LISTEN                        [ED0C]

        lda     SA                      ; get the secondary address
        bpl     A_F286                  ; if address to send go ??

        jsr     IecAtnH                 ; else set serial ATN high      [EDBE]
        bne     A_F289                  ; go ??, branch always
A_F286                                  ;                               [F286]
        jsr     SAafterLISTEN2          ; send secondary address after LISTEN
                                        ;                               [EDB9]
A_F289                                  ;                               [F289]
        txa                             ; copy device number back to A
        bit     STATUS                  ; test the serial status byte
        bpl     A_F275                  ; if device is present go save output
                                        ; device number and exit
        jmp     DevNotPresent           ; else do 'device not present error'
                                        ; and return                    [F707]

;******************************************************************************
;
; close a specified logical file

; this routine is used to close a logical file after all I/O operations have
; been completed on that file. This routine is called after the accumulator is
; loaded with the logical file number to be closed, the same number used when
; the file was opened using the OPEN routine.

CloseLogFile2                           ;                               [F291]
        jsr     FindFileA               ; find file A                   [F314]
        beq     A_F298                  ; if file found go close it

        clc                             ; else file was closed so just flag ok
        rts

; file found so close it
A_F298                                  ;                               [F298]
        jsr     SetFileDetails          ; set file details from table,X [F31F]
        txa                             ; copy file index to A
        pha                             ; save file index
S_F29D 
        lda     FA                      ; get the device number
        beq     J_F2F1                  ; if it is keyboard go restore index
                                        ; and close the file
        cmp     #$03                    ; compare device number with screen
        beq     J_F2F1                  ; if it is the screen go restore the
                                        ; index and close the file
        bcs     A_F2EE                  ; if > screen, do serial device close

        cmp     #$02                    ; compare device with RS232 device
        bne     A_F2C8                  ; if not the RS232 device go to tape

; else close RS232 device
        pla                             ; restore file index
        jsr     ClosFileIndxX           ; close file index X            [F2F2]

        jsr     InitRS232_TX            ; initialise RS232 output       [F483]
        jsr     ReadTopOfMem            ; read the top of memory        [FE27]

        lda     RIBUF+1                 ; get RS232 input buffer pointer HB
        beq     A_F2BA                  ; if no RS232 input buffer go ??

        iny                             ; else reclaim RS232 input buffer memory
A_F2BA                                  ;                               [F2BA]
        lda     ROBUF+1                 ; get RS232 output buffer pointer HB
        beq     A_F2BF                  ; if no RS232 output buffer skip reclaim

        iny                             ; else reclaim RS232 output buf memory
A_F2BF                                  ;                               [F2BF]
        lda     #$00                    ; clear A
        sta     RIBUF+1                 ; clear RS232 input buffer pointer HB
        sta     ROBUF+1                 ; clear RS232 output buffer pointer HB

        jmp     SetTopOfMem             ; go set top of memory to F0xx  [F47D]

; is not the RS232 device
A_F2C8                                  ;                               [F2C8]
        lda     SA                      ; get the secondary address
        and     #$0F                    ; mask the device #
        beq     J_F2F1                  ; if ?? restore index and close file

        jsr     TapeBufPtr2XY           ; get tape buffer start pointer in XY
                                        ;                               [F7D0]
        lda     #$00                    ; character $00
        sec                             ; flag the tape device
        jsr     OutByteCasRS            ; output the character to the cassette
                                        ; or RS232 device               [F1DD]
        jsr     InitTapeWrite           ; initiate tape write           [F864]
        bcc     A_F2E0                  ;.

        pla                             ;.

        lda     #$00                    ;.
        rts

A_F2E0                                  ;                               [F2E0]
        lda     SA                      ; get the secondary address
        cmp     #$62                    ;.
        bne     J_F2F1                  ; if not ?? restore index and close file

        lda     #$05                    ; set logical end of the tape
        jsr     WriteTapeHdr            ; write tape header             [F76A]

        jmp     J_F2F1                  ; restore index and close file  [F2F1]


;******************************************************************************
;
; serial bus device close

A_F2EE                                  ;                               [F2EE]
        jsr     CloseIecDevice          ; close serial bus device       [F642]
J_F2F1                                  ;                               [F2F1]
        pla                             ; restore file index


;******************************************************************************
;
; close file index X

ClosFileIndxX                           ;                               [F2F2]
        tax                             ; copy index to file to close
S_F2F3                                  ;                               [F2F3]
        dec     LDTND                   ; decrement the open file count

        cpx     LDTND                   ; compare index with open file count
        beq     A_F30D                  ; exit if equal, last entry was closing
                                        ; file
; else entry was not last in list so copy last table entry file details over
; the details of the closing one
        ldy     LDTND                   ; get the open file count as index
        lda     LogFileTbl,Y            ; get last+1 logical file number from
                                        ; logical file table
        sta     LogFileTbl,X            ; save logical file number over closed
                                        ; file
        lda     DevNumTbl,Y             ; get last+1 device number from device
                                        ; number table
        sta     DevNumTbl,X             ; save device number over closed file

        lda     SecAddrTbl,Y            ; get last+1 secondary address from
                                        ; secondary address table
        sta     SecAddrTbl,X            ; save secondary address over closed
                                        ; file
A_F30D                                  ;                               [F30D]
        clc                             ; flag ok

        rts


;******************************************************************************
;
; find a file

FindFile                                ;                               [F30F]
        lda     #$00                    ; clear A
        sta     STATUS                  ; clear the serial status byte

        txa                             ; copy the logical file number to A


;******************************************************************************
;
; find file A

FindFileA                               ;                               [F314]
        ldx     LDTND                   ; get the open file count
A_F316                                  ;                               [F316]
        dex                             ; decrememnt the count to give the index
        bmi     A_F32E                  ; if no files just exit

        cmp     LogFileTbl,X            ; compare the logical file number with
                                        ; the table logical file number
        bne     A_F316                  ; if no match go try again

        rts


;******************************************************************************
;
; set file details from table,X

SetFileDetails                          ;                               [F31F]
        lda     LogFileTbl,X            ; get logical file from logical file
                                        ; table
        sta     LA                      ; save the logical file

        lda     DevNumTbl,X             ; get device number from device number
                                        ; table
        sta     FA                      ; save the device number

        lda     SecAddrTbl,X            ; get secondary address from secondary
                                        ; address table
        sta     SA                      ; save the secondary address
A_F32E                                  ;                               [F32E]
        rts


;******************************************************************************
;
; close all channels and files

; this routine closes all open files. When this routine is called, the pointers
; into the open file table are reset, closing all files. Also the routine
; automatically resets the I/O channels.

ClsAllChnFil                            ;                               [F32F]
        lda     #$00                    ; clear A
        sta     LDTND                   ; clear the open file count


;******************************************************************************
;
; close input and output channels

; this routine is called to clear all open channels and restore the I/O
; channels to their original default values. It is usually called after opening
; other I/O channels and using them for input/output operations. The default
; input device is 0, the keyboard. The default output device is 3, the screen.

; If one of the channels to be closed is to the serial port, an UNTALK signal
; is sent first to clear the input channel or an UNLISTEN is sent to clear the
; output channel. By not calling this routine and leaving listener(s) active on
; the serial bus, several devices can receive the same data from the VIC at the
; same time. One way to take advantage of this would be to command the printer
; to TALK and the disk to LISTEN. This would allow direct printing of a disk
; file.

CloseIoChans                            ;                               [F333]
        ldx     #$03                    ; set the screen device
        cpx     DFLTO                   ; compare the screen with the output
                                        ; device number
        bcs     A_F33C                  ; if <= screen skip serial bus unlisten

        jsr     IecUNLISTEN2            ; else command the serial bus to
                                        ; UNLISTEN                      [EDFE]
A_F33C                                  ;                               [F33C]
        cpx     DFLTN                   ; compare the screen with the input
                                        ; device number
        bcs     A_F343                  ; if <= screen skip serial bus untalk

        jsr     IecUNTALK2              ; else command the serial bus to
                                        ; UNTALK                        [EDEF]
A_F343                                  ;                               [F343]
        stx     DFLTO                   ; save the screen as the output
                                        ; device number
        lda     #$00                    ; set the keyboard as the input device
        sta     DFLTN                   ; save the input device number

        rts


;******************************************************************************
;
; open a logical file

; this routine is used to open a logical file. Once the logical file is set up
; it can be used for input/output operations. Most of the I/O KERNAL routines
; call on this routine to create the logical files to operate on. No arguments
; need to be set up to use this routine, but both the SETLFS, SetAddresses, and
; SETNAM, SetFileName, KERNAL routines must be called before using this
; routine.

OpenLogFile2                            ;                               [F34A]
        ldx     LA                      ; get the logical file
        bne     A_F351                  ; if there is a file continue

        jmp     NoInputFileErr          ; else do 'not input file error' and
                                        ; return                        [F70A]
A_F351                                  ;                               [F351]
        jsr     FindFile                ; find a file                   [F30F]
        bne     A_F359                  ; if file not found continue

        jmp     FileAlreadyOpen         ; else do 'file already open' error and
                                        ; return                        [F6FE]
A_F359                                  ;                               [F359]
        ldx     LDTND                   ; get the open file count
        cpx     #10                     ; < maximum + 1 ?
        bcc     A_F362                  ; if less than maximum + 1 go open file

        jmp     TooManyFilesErr         ; else do 'too many files error' and
                                        ; return                        [F6FB]
A_F362                                  ;                               [F362]
        inc     LDTND                   ; increment the open file count

        lda     LA                      ; get the logical file
        sta     LogFileTbl,X            ; save it to the logical file table

        lda     SA                      ; get the secondary address
        ora     #$60                    ; OR with the OPEN CHANNEL command
        sta     SA                      ; save the secondary address
        sta     SecAddrTbl,X            ; save it to the secondary address table

        lda     FA                      ; get the device number
        sta     DevNumTbl,X             ; save it to the device number table
        beq     A_F3D3                  ; if it is the keyboard, do ok exit
S_F379 
        cmp     #$03                    ; compare device number with screen
        beq     A_F3D3                  ; if it is the screen go do the ok exit
        bcc     OpenLogFile3            ; if tape or RS232 device go ??
                                        ; else it is a serial bus device
; else is serial bus device
        jsr     SndSecAdrFilNm          ; send secondary address and filename
                                        ;                               [F3D5]
        bcc     A_F3D3                  ; go do ok exit, branch always

OpenLogFile3                            ;                               [F384]
        cmp     #$02                    ; RS-232?
        bne     A_F38B                  ; no, -> 

        jmp     OpenRS232Dev            ; go open RS232 device and return [F409]

A_F38B                                  ;                               [F38B]
        jsr     TapeBufPtr2XY           ; get tape buffer start pointer in XY
                                        ;                               [F7D0]
        bcs     A_F393                  ; if >= $0200 go ??

        jmp     IllegalDevNum           ; else do 'illegal device number' and
                                        ; return                        [F713]
A_F393                                  ;                               [F393]
        lda     SA                      ; get the secondary address
        and     #$0F                    ;.
        bne     A_F3B8                  ;.

        jsr     WaitForPlayKey          ; wait for PLAY                 [F817]
        bcs     A_F3D4                  ; exit if STOP was pressed

        jsr     PrtSEARCHING            ; print "Searching..."          [F5AF]

        lda     FNLEN                   ; get filename length
        beq     A_F3AF                  ; if null filename just go find header

        jsr     FindTapeHeader          ; find specific tape header     [F7EA]
        bcc     A_F3C2                  ; branch if no error

        beq     A_F3D4                  ; exit if ??

A_F3AC                                  ;                               [F3AC]
        jmp     FileNotFound            ; do file not found error and return
                                        ;       [F704]
A_F3AF                                  ;                               [F3AF]
        jsr     FindTapeHdr2            ; find tape header, exit with header in
                                        ; buffer                        [F72C]
        beq     A_F3D4                  ; exit if end of tape found

        bcc     A_F3C2                  ;.

        bcs     A_F3AC                  ; always ->

A_F3B8                                  ;                               [F3B8]
        jsr     WaitForPlayRec          ; wait for PLAY/RECORD          [F838]
        bcs     A_F3D4                  ; exit if STOP was pressed

        lda     #$04                    ; set data file header
        jsr     WriteTapeHdr            ; write tape header             [F76A]
A_F3C2                                  ;                               [F3C2]
        lda     #$BF                    ;.

        ldy     SA                      ; get the secondary address
        cpy     #$60                    ;.
        beq     A_F3D1                  ;.

        ldy     #$00                    ; clear index
        lda     #$02                    ;.
        sta     (TapeBufPtr),Y          ;.save to tape buffer

        tya                             ;.clear A
A_F3D1                                  ;                               [F3D1]
        sta     BUFPNT                  ;.save tape buffer index
A_F3D3                                  ;                               [F3D3]
        clc                             ; flag ok
A_F3D4                                  ;                               [F3D4]
        rts


;******************************************************************************
;
; send secondary address and filename

SndSecAdrFilNm                          ;                               [F3D5]
        lda     SA                      ; get the secondary address
        bmi     A_F3D3                  ; ok exit if -ve

        ldy     FNLEN                   ; get filename length
        beq     A_F3D3                  ; ok exit if null

        lda     #$00                    ; clear A
        sta     STATUS                  ; clear the serial status byte

        lda     FA                      ; get the device number
        jsr     CmdLISTEN2              ; command devices on the serial bus to
                                        ; LISTEN                        [ED0C]
        lda     SA                      ; get the secondary address
        ora     #$F0                    ; OR with the OPEN command
        jsr     SAafterLISTEN2          ; send secondary address after LISTEN
                                        ;                               [EDB9]
        lda     STATUS                  ; get the serial status byte
        bpl     A_F3F6                  ; if device present skip the 'device
                                        ; not present' error
S_F3F1 
        pla                             ; else dump calling address LB
        pla                             ; dump calling address HB

        jmp     DevNotPresent           ; do 'device not present' error and
                                        ; return                        [F707]
A_F3F6                                  ;                               [F3F6]
        lda     FNLEN                   ; get filename length
        beq     A_F406                  ; branch if null name

        ldy     #$00                    ; clear index
A_F3FC                                  ;                               [F3FC]
        lda     (FNADR),Y               ; get filename byte
        jsr     IecByteOut2             ; output byte to serial bus     [EDDD]

        iny                             ; increment index
        cpy     FNLEN                   ; compare with filename length
        bne     A_F3FC                  ; loop if not all done
A_F406                                  ;                               [F406]
        jmp     DoUNLISTEN              ; command serial bus to UNLISTEN and
                                        ; return                        [F654]

;******************************************************************************
;
; open RS232 device

OpenRS232Dev                            ;                               [F409]
        jsr     InitRS232_TX            ; initialise RS232 output       [F483]
        sty     RSSTAT                  ; save the RS232 status register
A_F40F                                  ;                               [F40F]
        cpy     FNLEN                   ; compare with filename length
        beq     A_F41D                  ; exit loop if done

        lda     (FNADR),Y               ; get filename byte
        sta     M51CTR,Y                ; copy to 6551 register set

        iny                             ; increment index
        cpy     #$04                    ; compare with $04
        bne     A_F40F                  ; loop if not to 4 yet

A_F41D                                  ;                               [F41D]
        jsr     CalcBitCounts           ; compute bit count             [EF4A]
        stx     BITNUM                  ; save bit count

        lda     M51CTR                  ; get pseudo 6551 control register
        and     #$0F                    ; mask 0000, baud rate
.if Version=1
        bne     A_F435

        lda     M51AJB
        asl     A
        tay
        lda     M51AJB+1
        jmp     J_F43F                  ;                               [F43F]

A_F435                                  ;                               [F435]
        asl     A
        tax
        lda     TblBaudNTSC-2,X
        asl     A
        tay
        lda     TblBaudNTSC-1,X
J_F43F                                  ;                               [F43F]
        rol     A
        pha

        tya
        adc     #$C8
        sta     BAUDOF

        pla
        adc     #$00
        sta     BAUDOF+1

        lda     M51CDR                  ; read the pseudo 6551 command register
        lsr                             ; shift the X line/3 line bit into Cb
        bcc     A_F45C                  ; if 3 line skip the DRS test

        lda     CIA2DRB                 ; read CIA 2 DRB, RS232 port
        asl                             ; shift DSR in into Cb
        bcs     A_F45C                  ; if DSR present skip the error set

        jmp     DeactivateDSR           ; set no DSR                    [F00D]

.else
        beq     A_F446                  ; if zero skip the baud rate setup

        asl                             ; * 2 bytes per entry
        tax                             ; copy to the index

        lda     PALNTSC                 ; get the PAL/NTSC flag
        bne     A_F43A                  ; if PAL go set PAL timing

        ldy     TblBaudNTSC-1,X         ; get the NTSC baud rate value HB
        lda     TblBaudNTSC-2,X         ; get the NTSC baud rate value LB
        jmp     SaveBaudRate            ; go save the baud rate values  [F440]

A_F43A                                  ;                               [F43A]
        ldy     TblBaudRates-1,X        ; get the PAL baud rate value HB
        lda     TblBaudRates-2,X        ; get the PAL baud rate value LB
SaveBaudRate                            ;                               [F440]
        sty     M51AJB+1                ; save the nonstandard bit timing HB
        sta     M51AJB                  ; save the nonstandard bit timing LB
A_F446                                  ;                               [F446]
        lda     M51AJB                  ; get the nonstandard bit timing LB
        asl                             ; * 2
        jsr     SetTimerBaudR           ;.                              [FF2E]

        lda     M51CDR                  ; read the pseudo 6551 command register
        lsr                             ; shift the X line/3 line bit into Cb
        bcc     A_F45C                  ; if 3 line skip the DRS test

        lda     CIA2DRB                 ; read CIA 2 DRB, RS232 port
        asl                             ; shift DSR in into Cb
        bcs     A_F45C                  ; if DSR present skip the error set

        jsr     DeactivateDSR           ; set no DSR                    [F00D]
.fi
A_F45C                                  ;                               [F45C]
        lda     RIDBE                   ; get index to Rx buffer end
        sta     RIDBS                   ; set index to Rx buffer start, clear
                                        ; Rx buffer
        lda     RODBS                   ; get index to Tx buffer end
        sta     RODBE                   ; set index to Tx buffer start, clear
                                        ; Tx buffer
        jsr     ReadTopOfMem            ; read the top of memory        [FE27]

        lda     RIBUF+1                 ; get RS232 input buffer pointer HB
        bne     A_F474                  ; if buffer already set skip the save

        dey                             ; decrement top of memory HB, 256 byte
                                        ; buffer
        sty     RIBUF+1                 ; save RS232 input buffer pointer HB
        stx     RIBUF                   ; save RS232 input buffer pointer LB
A_F474                                  ;                               [F474]
        lda     ROBUF+1                 ; get RS232 output buffer pointer HB
        bne     SetTopOfMem             ; if > 0 go set the top of memory to
                                        ; $F0xx

        dey                             ;.
        sty     ROBUF+1                 ; save RS232 output buffer pointer HB
        stx     ROBUF                   ; save RS232 output buffer pointer LB


;******************************************************************************
;
; set the top of memory to F0xx

SetTopOfMem                             ;                               [F47D]
        sec                             ; read the top of memory
        lda     #$F0                    ; set $F000
        jmp     SetTopOfMem2            ; set the top of memory and return
                                        ;                               [FE2D]

;******************************************************************************
;
; initialise RS232 output

InitRS232_TX                            ;                               [F483]
        lda     #$7F                    ; disable all interrupts
        sta     CIA2IRQ                 ; save CIA 2 ICR

        lda     #$06                    ; set RS232 DTR output, RS232 RTS output
        sta     CIA2DDRB                ; save CIA 2 DDRB, RS232 port
        sta     CIA2DRB                 ; save CIA 2 DRB, RS232 port

        lda     #$04                    ; mask x1xx, set RS232 Tx DATA high
        ora     CIA2DRA                 ; OR it with CIA 2 DRA, serial port and
                                        ; video address
        sta     CIA2DRA                 ; save CIA 2 DRA, serial port and video
                                        ; address
        ldy     #$00                    ; clear Y
        sty     ENABL                   ; clear RS-232 interrupt enable byte

        rts


;******************************************************************************
;
; load RAM from a device

; this routine will load data bytes from any input device directly into the
; memory of the computer. It can also be used for a verify operation comparing
; data from a device with the data already in memory, leaving the data stored
; in RAM unchanged.

; The accumulator must be set to 0 for a load operation or 1 for a verify. If
; the input device was OPENed with a secondary address of 0 the header
; information from device will be ignored. In this case XY must contain the
; starting address for the load. If the device was addressed with a secondary
; address of 1 or 2 the data will load into memory starting at the location
; specified by the header. This routine returns the address of the highest RAM
; location which was loaded.

; Before this routine can be called, the SETLFS, SetAddresses, and SETNAM,
; SetFileName, routines must be called.

LoadRamFrmDev2                          ;                               [F49E]
        stx     MEMUSS                  ; set kernal setup pointer LB
        sty     MEMUSS+1                ; set kernal setup pointer HB

        jmp     (ILOAD)                 ; do LOAD vector, usually points to
                                        ; LoadRamFrmDev22

;******************************************************************************
;
; load

LoadRamFrmDev22                         ;                               [F4A5]
        sta     LoadVerify2             ; save load/verify flag

        lda     #$00                    ; clear A
        sta     STATUS                  ; clear the serial status byte
S_F4AB 
        lda     FA                      ; get the device number
        bne     A_F4B2                  ; if not the keyboard continue

; can't load form keyboard so ..
A_F4AF                                  ;                               [F4AF]
        jmp     IllegalDevNum           ; else do 'illegal device number' and
                                        ; return                        [F713]
A_F4B2                                  ;                               [F4B2]
        cmp     #$03                    ; screen?
        beq     A_F4AF                  ; yes, ->

        bcc     LoadFromTape            ; smaller, -> load from tape

; else is serial bus device
        ldy     FNLEN                   ; get filename length
        bne     A_F4BF                  ; if not null name go ??

        jmp     MissingFileNam          ; else do 'missing filename' error and
                                        ; return                        [F710]
A_F4BF                                  ;                               [F4BF]
        ldx     SA                      ; get the secondary address
        jsr     PrtSEARCHING            ; print "Searching..."          [F5AF]

        lda     #$60                    ;.
        sta     SA                      ; save the secondary address

        jsr     SndSecAdrFilNm          ; send secondary address and filename
                                        ;                               [F3D5]
        lda     FA                      ; get the device number
        jsr     CmdTALK2                ; command serial bus device to TALK
                                        ;                               [ED09]
        lda     SA                      ; get the secondary address
        jsr     SAafterTALK2            ; send secondary address after TALK
                                        ;                               [EDC7]
LoadRamFrmDev22b                        ;                               [F4D5]
        jsr     IecByteIn2              ; input byte from serial bus    [EE13]
        sta     EAL                     ; save program start address LB

        lda     STATUS                  ; get the serial status byte
        lsr                             ; shift time out read ..
        lsr                             ; .. into carry bit
        bcs     A_F530                  ; if timed out go do file not found
                                        ; error and return
        jsr     IecByteIn2              ; input byte from serial bus    [EE13]
        sta     EAL+1                   ; save program start address HB

        txa                             ; copy secondary address
        bne     A_F4F0                  ; load location not set in LOAD call,
                                        ; so continue with the load
        lda     MEMUSS                  ; get the load address LB
        sta     EAL                     ; save the program start address LB

        lda     MEMUSS+1                ; get the load address HB
        sta     EAL+1                   ; save the program start address HB
A_F4F0                                  ;                               [F4F0]
        jsr     LoadVerifying           ;.                              [F5D2]
A_F4F3                                  ;                               [F4F3]
        lda     #$FD                    ; mask xx0x, clear time out read bit
        and     STATUS                  ; mask the serial status byte
        sta     STATUS                  ; set the serial status byte

        jsr     ScanStopKey             ; scan stop key, return Zb = 1 = [STOP]
                                        ;                               [FFE1]
        bne     A_F501                  ; if not [STOP] go ??

        jmp     CloseIecBus             ; else close the serial bus device and
                                        ; flag stop                     [F633]
A_F501                                  ;                               [F501]
        jsr     IecByteIn2              ; input byte from serial bus    [EE13]
        tax                             ; copy byte

        lda     STATUS                  ; get the serial status byte
        lsr                             ; shift time out read ..
        lsr                             ; .. into carry bit
        bcs     A_F4F3                  ; if timed out go try again

        txa                             ; copy received byte back

        ldy     LoadVerify2             ; get load/verify flag
        beq     A_F51C                  ; if load go load

; else is verify
        ldy     #$00                    ; clear index
        cmp     (EAL),Y                 ; compare byte with previously loaded
                                        ; byte
        beq     A_F51E                  ; if match go ??

        lda     #$10                    ; flag read error
        jsr     AorIecStatus            ; OR into the serial status byte [FE1C]
.byte   $2C                             ; makes next line BIT $AE91
A_F51C                                  ;                               [F51C]
        sta     (EAL),Y                 ; save byte to memory
A_F51E                                  ;                               [F51E]
        inc     EAL                     ; increment save pointer LB
        bne     A_F524                  ; if no rollover go ??

        inc     EAL+1                   ; else increment save pointer HB
A_F524                                  ;                               [F524]
        bit     STATUS                  ; test the serial status byte
        bvc     A_F4F3                  ; loop if not end of file

; close file and exit
        jsr     IecUNTALK2              ; command serial bus to UNTALK  [EDEF]

        jsr     CloseIecDevice          ; close serial device, error?   [F642]
        bcc     A_F5A9                  ; no, -> exit
A_F530                                  ;                               [F530]
        jmp     FileNotFound            ; do file not found error and return
                                        ;                               [F704]

;******************************************************************************
;
; Load from tape

LoadFromTape                            ;                               [F533]
        lsr                             ; tape?
        bcs     A_F539                  ; yes, ->

        jmp     IllegalDevNum           ; else do 'illegal device number' and
                                        ; return                        [F713]
A_F539                                  ;                               [F539]
        jsr     TapeBufPtr2XY           ; get tape buffer start pointer in XY
                                        ;                               [F7D0]
        bcs     A_F541                  ; if ??

        jmp     IllegalDevNum           ; else do 'illegal device number' and
                                        ; return                        [F713]

A_F541                                  ;                               [F541]
        jsr     WaitForPlayKey          ; wait for PLAY                 [F817]
        bcs     A_F5AE                  ; exit if STOP was pressed

        jsr     PrtSEARCHING            ; print "Searching..."          [F5AF]
A_F549                                  ;                               [F549]
        lda     FNLEN                   ; get filename length
        beq     A_F556                  ;.

        jsr     FindTapeHeader          ; find specific tape header     [F7EA]
        bcc     A_F55D                  ; if no error continue

        beq     A_F5AE                  ; exit if ??

        bcs     A_F530                  ; file not found, branch always

A_F556                                  ;                               [F556]
        jsr     FindTapeHdr2            ; find tape header, exit with header in
                                        ; buffer                        [F72C]
        beq     A_F5AE                  ; exit if ??

        bcs     A_F530                  ;.
A_F55D                                  ;                               [F55D]
        lda     STATUS                  ; get the serial status byte
        and     #$10                    ; mask 000x 0000, read error
        sec                             ; flag fail
        bne     A_F5AE                  ; if read error just exit

        cpx     #$01                    ;.
        beq     A_F579                  ;.

        cpx     #$03                    ;.
        bne     A_F549                  ;.

A_F56C                                  ;                               [F56C]
        ldy     #$01                    ;.
        lda     (TapeBufPtr),Y          ;.
        sta     MEMUSS                  ;.

        iny                             ;.
        lda     (TapeBufPtr),Y          ;.
        sta     MEMUSS+1                ;.
        bcs     A_F57D                  ;.

A_F579                                  ;                               [F579]
        lda     SA                      ; get the secondary address
        bne     A_F56C                  ;.

A_F57D                                  ;                               [F57D]
        ldy     #$03                    ;.
        lda     (TapeBufPtr),Y          ;.
        ldy     #$01                    ;.
        sbc     (TapeBufPtr),Y          ;.
        tax                             ;.

        ldy     #$04                    ;.
        lda     (TapeBufPtr),Y          ;.
        ldy     #$02                    ;.
        sbc     (TapeBufPtr),Y          ;.
        tay                             ;.

        clc                             ;.
        txa                             ;.
        adc     MEMUSS                  ;.
        sta     EAL                     ;.

        tya                             ;.
        adc     MEMUSS+1                ;.
        sta     EAL+1                   ;.

        lda     MEMUSS                  ;.
        sta     STAL                    ; set I/O start addresses LB

        lda     MEMUSS+1                ;.
        sta     STAL+1                  ; set I/O start addresses HB

        jsr     LoadVerifying           ; display "LOADING" or "VERIFYING"
                                        ;                               [F5D2]
        jsr     ReadTape                ; do the tape read              [F84A]

.byte   $24                             ; keep the error flag in Carry
A_F5A9                                  ;                               [F5A9]
        clc                             ; flag ok

        ldx     EAL                     ; get the LOAD end pointer LB
        ldy     EAL+1                   ; get the LOAD end pointer HB
A_F5AE                                  ;                               [F5AE]
        rts


;******************************************************************************
;
; print "Searching..."

PrtSEARCHING                            ;                               [F5AF]
        lda     MSGFLG                  ; get message mode flag
        bpl     A_F5D1                  ; exit if control messages off

        ldy     #TxtSEARCHING-TxtIO_ERROR ; index to "SEARCHING "
        jsr     DisplayIoMsg2           ; display kernel I/O message    [F12F]

        lda     FNLEN                   ; get filename length
        beq     A_F5D1                  ; exit if null name

        ldy     #TxtFOR-TxtIO_ERROR     ; else index to "FOR "
        jsr     DisplayIoMsg2           ; display kernel I/O message    [F12F]


;******************************************************************************
;
; print filename

PrintFileName                           ;                               [F5C1]
        ldy     FNLEN                   ; get filename length
        beq     A_F5D1                  ; exit if null filename

        ldy     #$00                    ; clear index
A_F5C7                                  ;                               [F5C7]
        lda     (FNADR),Y               ; get filename byte
        jsr     OutByteChan             ; output character to channel   [FFD2]
        iny                             ; increment index
        cpy     FNLEN                   ; compare with filename length
        bne     A_F5C7                  ; loop if more to do

A_F5D1                                  ;                               [F5D1]
        rts


;******************************************************************************
;
; display "LOADING" or "VERIFYING"

LoadVerifying                           ;                               [F5D2]
        ldy     #TxtLOADING-TxtIO_ERROR ; point to "LOADING"

        lda     LoadVerify2             ; get load/verify flag
        beq     A_F5DA                  ; branch if load

        ldy     #TxtVERIFYING-TxtIO_ERROR ; point to "VERIFYING"
A_F5DA                                  ;                               [F5DA]
        jmp     DisplayIoMsg            ; display kernel I/O message if in
                                        ; direct mode and return        [F12B]

;******************************************************************************
;
; save RAM to device, A = index to start address, XY = end address low/high

; this routine saves a section of memory. Memory is saved from an indirect
; address on page 0 specified by A, to the address stored in XY, to a logical
; file. The SETLFS, SetAddresses, and SETNAM, SetFileName, routines must be
; used before calling this routine. However, a filename is not required to
; SAVE to device 1, the cassette. Any attempt to save to other devices without
; using a filename results in an error.

; NOTE: device 0, the keyboard, and device 3, the screen, cannot be SAVEd to.
; If the attempt is made, an error will occur, and the SAVE stopped.

SaveRamToDev2                           ;                               [F5DD]
        stx     EAL                     ; save end address LB
        sty     EAL+1                   ; save end address HB

        tax                             ; copy index to start pointer

        lda     D6510+0,X               ; get start address LB
        sta     STAL                    ; set I/O start addresses LB

        lda     D6510+1,X               ; get start address HB
        sta     STAL+1                  ; set I/O start addresses HB

        jmp     (ISAVE)                 ; go save, usually points to $F5ED


;******************************************************************************
;
; save

SaveRamToDev22                          ;                               [F5ED]
        lda     FA                      ; get the device number, keyboard?
        bne     A_F5F4                  ; no, -> 

; else ..
A_F5F1                                  ;                               [F5F1]
        jmp     IllegalDevNum           ; else do 'illegal device number' and
                                        ; return                        [F713]
A_F5F4                                  ;                               [F5F4]
        cmp     #$03                    ; compare device number with screen
        beq     A_F5F1                  ; if screen do illegal device number
                                        ; and return
        bcc     SaveRamToTape           ; branch if < screen

; is greater than screen so is serial bus
        lda     #$61                    ; set secondary address to $01 when a
                                        ; secondary address is to be sent to a
                                        ; device on the serial bus the address
                                        ; must first be ORed with $60
        sta     SA                      ; save the secondary address

        ldy     FNLEN                   ; get the filename length
        bne     A_F605                  ; if filename not null continue

        jmp     MissingFileNam          ; else do 'missing filename' error and
                                        ; return                        [F710]
A_F605                                  ;                               [F605]
        jsr     SndSecAdrFilNm          ; send secondary address and filename
                                        ;                               [F3D5]
        jsr     PrtSAVING               ; print saving <filename>       [F68F]
SaveRamToDev22b 
        lda     FA                      ; get the device number
        jsr     CmdLISTEN2              ; command devices on the serial bus to
                                        ; LISTEN                        [ED0C]

        lda     SA                      ; get the secondary address
        jsr     SAafterLISTEN2          ; send secondary address after LISTEN
                                        ;                               [EDB9]
        ldy     #$00                    ; clear index
        jsr     CopyIoAdr2Buf           ; copy I/O start address to buffer
                                        ; address                       [FB8E]
        lda     SAL                     ; get buffer address LB
        jsr     IecByteOut2             ; output byte to serial bus     [EDDD]

        lda     SAL+1                   ; get buffer address HB
        jsr     IecByteOut2             ; output byte to serial bus     [EDDD]
A_F624                                  ;                               [F624]
        jsr     ChkRdWrPtr              ; check read/write pointer, return
                                        ; Cb = 1 if pointer >= end      [FCD1]
        bcs     A_F63F                  ; go do UNLISTEN if at end

        lda     (SAL),Y                 ; get byte from buffer
        jsr     IecByteOut2             ; output byte to serial bus     [EDDD]

        jsr     ScanStopKey             ; scan stop key                 [FFE1]
        bne     A_F63A                  ; if stop not pressed go increment
                                        ; pointer and loop for next
; else ..

; close the serial bus device and flag stop

CloseIecBus                             ;                               [F633]
        jsr     CloseIecDevice          ; close serial bus device       [F642]

        lda     #$00                    ;.
        sec                             ; flag stop
        rts


A_F63A                                  ;                               [F63A]
        jsr     IncRdWrPtr              ; increment read/write pointer  [FCDB]
        bne     A_F624                  ; loop, branch always
A_F63F                                  ;                               [F63F]
        jsr     IecUNLISTEN2            ; command serial bus to UNLISTEN [EDFE]

; close serial bus device

CloseIecDevice                          ;                               [F642]
        bit     SA                      ; test the secondary address
        bmi     A_F657                  ; if already closed just exit

        lda     FA                      ; get the device number
        jsr     CmdLISTEN2              ; command devices on the serial bus to
                                        ; LISTEN                        [ED0C]

        lda     SA                      ; get the secondary address
        and     #$EF                    ; mask the channel number
        ora     #$E0                    ; OR with the CLOSE command
        jsr     SAafterLISTEN2          ; send secondary address after LISTEN
                                        ;                               [EDB9]
DoUNLISTEN                              ;                               [F654]
        jsr     IecUNLISTEN2            ; command serial bus to UNLISTEN [EDFE]
A_F657                                  ;                               [F657]
        clc                             ; flag ok
        rts

SaveRamToTape                           ;                               [F659]
        lsr                             ; bit 0 is set, = tape?
        bcs     A_F65F                  ; yes, -> OK

        jmp     IllegalDevNum           ; else do 'illegal device number' and
                                        ; return                        [F713]
A_F65F                                  ;                               [F65F]
        jsr     TapeBufPtr2XY           ; get tape buffer start pointer in XY
                                        ;                               [F7D0]
        bcc     A_F5F1                  ; if < $0200 do illegal device number
                                        ; and return
        jsr     WaitForPlayRec          ; wait for PLAY/RECORD          [F838]
        bcs     A_F68E                  ; exit if STOP was pressed

        jsr     PrtSAVING               ; print saving <filename>       [F68F]

        ldx     #$03                    ; set header for a non relocatable
                                        ; program file
        lda     SA                      ; get the secondary address
        and     #$01                    ; mask non relocatable bit
        bne     A_F676                  ; if non relocatable program go ??

        ldx     #$01                    ; else set header for a relocatable
                                        ; program file
A_F676                                  ;                               [F676]
        txa                             ; copy header type to A
        jsr     WriteTapeHdr            ; write tape header             [F76A]
        bcs     A_F68E                  ; exit if error

        jsr     WriteTape20Cyc          ; do tape write, 20 cycle count [F867]
        bcs     A_F68E                  ; exit if error

        lda     SA                      ; get the secondary address
        and     #$02                    ; mask end of tape flag
        beq     A_F68D                  ; if not end of tape go ??

        lda     #$05                    ; else set logical end of the tape
        jsr     WriteTapeHdr            ; write tape header             [F76A]
.byte   $24                             ; makes next line BIT LASTPT+1 so Cb is
                                        ; not changed
A_F68D                                  ;                               [F68D]
        clc                             ; flag ok
A_F68E                                  ;                               [F68E]
        rts


;******************************************************************************
;
; print saving <filename>

PrtSAVING                               ;                               [F68F]
        lda     MSGFLG                  ; get message mode flag
        bpl     A_F68E                  ; exit if control messages off

        ldy     #TxtSAVING-TxtIO_ERROR  ; index to "SAVING "
        jsr     DisplayIoMsg2           ; display kernel I/O message    [F12F]

        jmp     PrintFileName           ; print filename and return     [F5C1]


;******************************************************************************
;
; increment the real time clock

; this routine updates the system clock. Normally this routine is called by the
; normal KERNAL interrupt routine every 1/60th of a second. If the user program
; processes its own interrupts this routine must be called to update the time.
; Also, the STOP key routine must be called if the stop key is to remain
; functional.

IncrClock2                              ;                               [F69B]
        ldx     #$00                    ; clear X

        inc     TimeBytes+2             ; increment the jiffy clock LB
        bne     A_F6A7                  ; if no rollover ??

        inc     TimeBytes+1             ; increment the jiffy clock mid byte
        bne     A_F6A7                  ; branch if no rollover

        inc     TimeBytes               ; increment the jiffy clock HB

; now subtract a days worth of jiffies from current count and remember only the
; Cb result
A_F6A7                                  ;                               [F6A7]
        sec                             ; set carry for subtract
        lda     TimeBytes+2             ; get the jiffy clock LB
        sbc     #$01                    ; subtract $4F1A01 LB

        lda     TimeBytes+1             ; get the jiffy clock mid byte
        sbc     #$1A                    ; subtract $4F1A01 mid byte

        lda     TimeBytes               ; get the jiffy clock HB
        sbc     #$4F                    ; subtract $4F1A01 HB
        bcc     IncrClock22             ; if less than $4F1A01 jiffies skip the
                                        ; clock reset
; else ..
        stx     TimeBytes               ; clear the jiffy clock HB
        stx     TimeBytes+1             ; clear the jiffy clock mid byte
        stx     TimeBytes+2             ; clear the jiffy clock LB
                                        ; this is wrong, there are $4F1A00
                                        ; jiffies in a day so the reset to zero
                                        ; should occur when the value reaches
                                        ; $4F1A00 and not $4F1A01. This would
                                        ; give an extra jiffy every day and a
                                        ; possible TI value of 24:00:00
IncrClock22                             ;                               [F6BC]
        lda     CIA1DRB                 ; read CIA 1 DRB, keyboard row port
        cmp     CIA1DRB                 ; compare it with itself
        bne     IncrClock22             ; loop if changing

        tax                             ; <STOP> key pressed?
        bmi     A_F6DA                  ; no, -> skip rest

        ldx     #$BD                    ; set c6
        stx     CIA1DRA                 ; save CIA 1 DRA, keyboard column drive

A_F6CC                                  ;                               [F6CC]
        ldx     CIA1DRB                 ; read CIA 1 DRB, keyboard row port
        cpx     CIA1DRB                 ; compare it with itself
        bne     A_F6CC                  ; loop if changing

        sta     CIA1DRA                 ; save CIA 1 DRA, keyboard column drive

        inx                             ;.
        bne     A_F6DC                  ;.

A_F6DA                                  ;                               [F6DA]
        sta     StopKey                 ; save the stop key column
A_F6DC                                  ;                               [F6DC]
        rts


;******************************************************************************
;
; read the real time clock

; this routine returns the time, in jiffies, in AXY. The accumulator contains
; the most significant byte.

ReadClock2                              ;                               [F6DD]
        sei                             ; disable the interrupts

        lda     TimeBytes+2             ; get the jiffy clock LB
        ldx     TimeBytes+1             ; get the jiffy clock mid byte
        ldy     TimeBytes               ; get the jiffy clock HB


;******************************************************************************
;
; set the real time clock

; the system clock is maintained by an interrupt routine that updates the clock
; every 1/60th of a second. The clock is three bytes long which gives the
; capability to count from zero up to 5,184,000 jiffies - 24 hours plus one
; jiffy. At that point the clock resets to zero. Before calling this routine to
; set the clock the new time, in jiffies, should be in YXA, the accumulator
; containing the most significant byte.

SetClock2                               ;                               [F6E4]
        sei                             ; disable the interrupts

        sta     TimeBytes+2             ; save the jiffy clock LB
        stx     TimeBytes+1             ; save the jiffy clock mid byte
        sty     TimeBytes               ; save the jiffy clock HB

        cli                             ; enable the interrupts

        rts


;******************************************************************************
;
; scan the stop key, return Zb = 1 = [STOP]

; if the STOP key on the keyboard is pressed when this routine is called the Z
; flag will be set. All other flags remain unchanged. If the STOP key is not
; pressed then the accumulator will contain a byte representing the last row of
; the keyboard scan.

; The user can also check for certain other keys this way.

Scan4StopKey                            ;                               [F6ED]
        lda     StopKey                 ; read the stop key column
        cmp     #$7F                    ; compare with [STP] down
        bne     A_F6FA                  ; if not [STOP] or not just [STOP] exit

; just [STOP] was pressed
        php                             ; save status

        jsr     CloseIoChannls          ; close input and output channels [FFCC]
        sta     NDX                     ; save the keyboard buffer index

        plp                             ; restore status

A_F6FA                                  ;                               [F6FA]
        rts


;******************************************************************************
;
; file error messages

TooManyFilesErr                         ;                               [F6FB]
        lda     #$01                    ; 'too many files' error
.byte   $2C                             ; makes next line BIT $02A9

FileAlreadyOpen                         ;                               [F6FE]
        lda     #$02                    ; 'file already open' error
.byte   $2C                             ; makes next line BIT $03A9

FileNotOpenErr                          ;                               [F701]
        lda     #$03                    ; 'file not open' error
.byte   $2C                             ; makes next line BIT $04A9

FileNotFound                            ;                               [F704]
        lda     #$04                    ; 'file not found' error
.byte   $2C                             ; makes next line BIT $05A9

DevNotPresent                           ;                               [F707]
        lda     #$05                    ; 'device not present' error
.byte   $2C                             ; makes next line BIT $06A9

NoInputFileErr                          ;                               [F70A]
        lda     #$06                    ; 'not input file' error
.byte   $2C                             ; makes next line BIT $07A9

NoOutpFileErr                           ;                               [F70D]
        lda     #$07                    ; 'not output file' error
.byte   $2C                             ; makes next line BIT $08A9

MissingFileNam                          ;                               [F710]
        lda     #$08                    ; 'missing filename' error
.byte   $2C                             ; makes next line BIT $09A9

IllegalDevNum                           ;                               [F713]
        lda     #$09                    ; do 'illegal device number'
        pha                             ; save the error #

        jsr     CloseIoChannls          ; close input and output channels [FFCC]

        ldy     #TxtIO_ERROR-TxtIO_ERROR        ; index to "I/O ERROR #"

        bit     MSGFLG                  ; test message mode flag
        bvc     A_F729                  ; exit if kernal messages off

        jsr     DisplayIoMsg2           ; display kernel I/O message    [F12F]

        pla                             ; restore error #
        pha                             ; copy error #

        ora     #'0'                    ; convert to ASCII
        jsr     OutByteChan             ; output character to channel   [FFD2]
A_F729                                  ;                               [F729]
        pla                             ; pull error number
        sec                             ; flag error

        rts


;******************************************************************************
;
; find the tape header, exit with header in buffer

FindTapeHdr2                            ;                               [F72C]
        lda     LoadVerify2             ; get load/verify flag
        pha                             ; save load/verify flag

        jsr     InitTapeRead            ; initiate tape read            [F841]

        pla                             ; restore load/verify flag
        sta     LoadVerify2             ; save load/verify flag
        bcs     A_F769                  ; exit if error

        ldy     #$00                    ; clear the index
        lda     (TapeBufPtr),Y          ; read first byte from tape buffer
        cmp     #$05                    ; compare with logical end of the tape
        beq     A_F769                  ; if end of the tape exit

        cmp     #$01                    ; compare with header for a relocatable
                                        ; program file
        beq     A_F74B                  ; if program file header go ??

        cmp     #$03                    ; compare with header for a non
                                        ; relocatable program file
        beq     A_F74B                  ; if program file header go  ??

        cmp     #$04                    ; compare with data file header
        bne     FindTapeHdr2            ; if data file loop to find tape header

; was a program file header
A_F74B                                  ;                               [F74B]
        tax                             ; copy header type
        bit     MSGFLG                  ; get message mode flag
        bpl     A_F767                  ; exit if control messages off

        ldy     #TxtFOUND-TxtIO_ERROR   ; index to "FOUND "
        jsr     DisplayIoMsg2           ; display kernel I/O message    [F12F]

        ldy     #$05                    ; index to the tape filename
A_F757                                  ;                               [F757]
        lda     (TapeBufPtr),Y          ; get byte from tape buffer
        jsr     OutByteChan             ; output character to channel   [FFD2]

        iny                             ; increment the index
        cpy     #$15                    ; compare it with end+1
        bne     A_F757                  ; loop if more to do
.if Version=1
A_F761                                  ;                               [F761]
        lda     StopKey
        cmp     #$FF
        beq     A_F761

.else
        lda     TimeBytes+1             ; get the jiffy clock mid byte
        jsr     Wait8Seconds            ; wait ~8.5 seconds for any key from
                                        ; the STOP key column           [E4E0]
        nop                             ; waste cycles
.fi
A_F767                                  ;                               [F767]
        clc                             ; flag no error

        dey                             ; decrement the index
A_F769                                  ;                               [F769]
        rts


;******************************************************************************
;
; write the tape header

WriteTapeHdr                            ;                               [F76A]
        sta     PTR1                    ; save header type

        jsr     TapeBufPtr2XY           ; get tape buffer start pointer in XY
                                        ;                               [F7D0]
        bcc     A_F7CF                  ; if < $0200 just exit ??

        lda     STAL+1                  ; get I/O start address HB
        pha                             ; save it

        lda     STAL                    ; get I/O start address LB
        pha                             ; save it

        lda     EAL+1                   ; get tape end address HB
        pha                             ; save it

        lda     EAL                     ; get tape end address LB
        pha                             ; save it

        ldy     #$BF                    ; index to header end
        lda     #' '                    ; clear byte, [SPACE]
A_F781                                  ;                               [F781]
        sta     (TapeBufPtr),Y          ; clear header byte

        dey                             ; decrement index
        bne     A_F781                  ; loop if more to do

        lda     PTR1                    ; get the header type back
        sta     (TapeBufPtr),Y          ; write it to header

        iny                             ; increment the index
        lda     STAL                    ; get the I/O start address LB
        sta     (TapeBufPtr),Y          ; write it to header

        iny                             ; increment the index
        lda     STAL+1                  ; get the I/O start address HB
        sta     (TapeBufPtr),Y          ; write it to header

        iny                             ; increment the index
        lda     EAL                     ; get the tape end address LB
        sta     (TapeBufPtr),Y          ; write it to header

        iny                             ; increment the index
        lda     EAL+1                   ; get the tape end address HB
        sta     (TapeBufPtr),Y          ; write it to header

        iny                             ; increment the index
        sty     PTR2                    ; save the index

        ldy     #$00                    ; clear Y
        sty     PTR1                    ; clear the name index
A_F7A5                                  ;                               [F7A5]
        ldy     PTR1                    ; get name index
        cpy     FNLEN                   ; compare with filename length
        beq     A_F7B7                  ; if all done exit the loop

        lda     (FNADR),Y               ; get filename byte
        ldy     PTR2                    ; get buffer index
        sta     (TapeBufPtr),Y          ; save filename byte to buffer

        inc     PTR1                    ; increment filename index
        inc     PTR2                    ; increment tape buffer index
        bne     A_F7A5                  ; loop, branch always

A_F7B7                                  ;                               [F7B7]
        jsr     SetTapeBufStart         ; set tape buffer start and end
                                        ; pointers                      [F7D7]
        lda     #$69                    ; set write lead cycle count
        sta     RIPRTY                  ; save write lead cycle count

        jsr     WriteTape20             ; do tape write, no cycle count set
                                        ;                               [F86B]
        tay                             ;.

        pla                             ; pull tape end address LB
        sta     EAL                     ; restore it

        pla                             ; pull tape end address HB
        sta     EAL+1                   ; restore it

        pla                             ; pull I/O start addresses LB
        sta     STAL                    ; restore it

        pla                             ; pull I/O start addresses HB
        sta     STAL+1                  ; restore it

        tya                             ;.
A_F7CF                                  ;                               [F7CF]
        rts


;******************************************************************************
;
; get the tape buffer start pointer

TapeBufPtr2XY                           ;                               [F7D0]
        ldx     TapeBufPtr              ; get tape buffer start pointer LB

        ldy     TapeBufPtr+1            ; get tape buffer start pointer HB
        cpy     #$02                    ; compare HB with $02xx
        rts


;******************************************************************************
;
; set the tape buffer start and end pointers

SetTapeBufStart                         ;                               [F7D7]
        jsr     TapeBufPtr2XY           ; get tape buffer start pointer in XY
                                        ;                               [F7D0]
        txa                             ; copy tape buffer start pointer LB
        sta     STAL                    ; save as I/O address pointer LB

        clc                             ; clear carry for add
        adc     #$C0                    ; add buffer length LB
        sta     EAL                     ; save tape buffer end pointer LB

        tya                             ; copy tape buffer start pointer HB
        sta     STAL+1                  ; save as I/O address pointer HB

        adc     #$00                    ; add buffer length HB
        sta     EAL+1                   ; save tape buffer end pointer HB

        rts


;******************************************************************************
;
; find specific tape header

FindTapeHeader                          ;                               [F7EA]
        jsr     FindTapeHdr2            ; find tape header, exit with header in
                                        ; buffer                        [F72C]
        bcs     A_F80C                  ; just exit if error

        ldy     #$05                    ; index to name
        sty     PTR2                    ; save as tape buffer index

        ldy     #$00                    ; clear Y
        sty     PTR1                    ; save as name buffer index
A_F7F7                                  ;                               [F7F7]
        cpy     FNLEN                   ; compare with filename length
        beq     A_F80B                  ; ok exit if match

        lda     (FNADR),Y               ; get filename byte
        ldy     PTR2                    ; get index to tape buffer
        cmp     (TapeBufPtr),Y          ; compare with tape header name byte
        bne     FindTapeHeader          ; if no match go get next header

        inc     PTR1                    ; else increment name buffer index
        inc     PTR2                    ; increment tape buffer index

        ldy     PTR1                    ; get name buffer index
        bne     A_F7F7                  ; loop, branch always

A_F80B                                  ;                               [F80B]
        clc                             ; flag ok
A_F80C                                  ;                               [F80C]
        rts


;******************************************************************************
;
; bump tape pointer

BumpTapePtr                             ;                               [F80D]
        jsr     TapeBufPtr2XY           ; get tape buffer start pointer in XY
                                        ;                               [F7D0]
        inc     BUFPNT                  ; increment tape buffer index

        ldy     BUFPNT                  ; get tape buffer index
        cpy     #$C0                    ; compare with buffer length
        rts


;******************************************************************************
;
; wait for PLAY

WaitForPlayKey                          ;                               [F817]
        jsr     ReadTapeSense           ; return cassette sense in Zb   [F82E]
        beq     A_F836                  ; if switch closed just exit

; cassette switch was open
        ldy     #TxtPRESS_PLAY-TxtIO_ERROR;     index to "PRESS PLAY ON TAPE"
A_F81E                                  ;                               [F81E]
        jsr     DisplayIoMsg2           ; display kernel I/O message    [F12F]
A_F821                                  ;                               [F821]
        jsr     ScanStopKey0            ; scan stop key and flag abort if
                                        ; pressed                       [F8D0]
                                        ; note if STOP was pressed the return
                                        ; is to the routine that called this
                                        ; one and not here
        jsr     ReadTapeSense           ; return cassette sense in Zb   [F82E]
        bne     A_F821                  ; loop if the cassette switch is open

        ldy     #TxtOK2-TxtIO_ERROR     ; index to "OK"
        jmp     DisplayIoMsg2           ; display kernel I/O message and return
                                        ;                               [F12F]


;******************************************************************************
;
; return cassette sense in Zb

ReadTapeSense                           ;                               [F82E]
        lda     #$10                    ; set the mask for the cassette switch
        bit     P6510                   ; test the 6510 I/O port
        bne     A_F836                  ; branch if cassette sense high

        bit     P6510                   ; test the 6510 I/O port
A_F836                                  ;                               [F836]
        clc                             ;.
        rts


;******************************************************************************
;
; wait for PLAY/RECORD

WaitForPlayRec                          ;                               [F838]
        jsr     ReadTapeSense           ; return the cassette sense in Zb [F82E]
        beq     A_F836                  ; exit if switch closed

; cassette switch was open
        ldy     #TxtPRESS_RECO-TxtIO_ERROR  ; index to "PRESS RECORD & PLAY ON
                                        ; TAPE"
        bne     A_F81E                  ; display message and wait for switch,
                                        ; branch always

;******************************************************************************
;
; initiate a tape read

InitTapeRead                            ;                               [F841]
        lda     #$00                    ; clear A
        sta     STATUS                  ; clear serial status byte
        sta     LoadVerify2             ; clear the load/verify flag

        jsr     SetTapeBufStart         ; set the tape buffer start and end
                                        ; pointers                      [F7D7]
ReadTape                                ;                               [F84A]
        jsr     WaitForPlayKey          ; wait for PLAY                 [F817]
        bcs     A_F86E                  ; exit if STOP was pressed, uses a
                                        ; further BCS at the target address to
                                        ; reach final target at ClrSavIrqAddr
        sei                             ; disable interrupts

        lda     #$00                    ; clear A
        sta     RIDATA                  ;.
        sta     BITTS                   ;.
        sta     CMPO                    ; clear tape timing constant min byte
        sta     PTR1                    ; clear tape pass 1 error log/char buf
        sta     PTR2                    ; clear tape pass 2 error log corrected
        sta     DPSW                    ; clear byte received flag

        lda     #$90                    ; enable CA1 interrupt ??

        ldx     #$0E                    ; set index for tape read vector
        bne     A_F875                  ; go do tape read/write, branch always


;******************************************************************************
;
; initiate a tape write

InitTapeWrite                           ;                               [F864]
        jsr     SetTapeBufStart         ; set tape buffer start and end 
                                        ; pointers                      [F7D7]

; do tape write, 20 cycle count

WriteTape20Cyc                          ;                               [F867]
        lda     #$14                    ; set write lead cycle count
        sta     RIPRTY                  ; save write lead cycle count

; do tape write, no cycle count set

WriteTape20                             ;                               [F86B]
        jsr     WaitForPlayRec          ; wait for PLAY/RECORD          [F838]
A_F86E                                  ;                               [F86E]
        bcs     ClrSavIrqAddr           ; if STOPped clear save IRQ address and
                                        ; exit
        sei                             ; disable interrupts

        lda     #$82                    ; enable ?? interrupt
        ldx     #$08                    ; set index for tape write tape leader
                                        ; vector

;******************************************************************************
;
; tape read/write

A_F875                                  ;                               [F875]
        ldy     #$7F                    ; disable all interrupts
        sty     CIA1IRQ                 ; save CIA 1 ICR, disable all interrupts

        sta     CIA1IRQ                 ; save CIA 1 ICR, enable interrupts
                                        ; according to A
; check RS232 bus idle

        lda     CIA1CTR1                ; read CIA 1 CRA
        ora     #$19                    ; load timer B, timer B single shot,
                                        ; start timer B
        sta     CIA1CTR2                ; save CIA 1 CRB

        and     #$91                    ; mask x00x 000x, TOD clock, load timer
                                        ; A, start timer A
        sta     Copy6522CRB             ; save CIA 1 CRB shadow copy

        jsr     IsRS232Idle             ;.                              [F0A4]

        lda     VICCTR1                 ; read the vertical fine scroll and
                                        ; control register
        and     #$EF                    ; blank the screen
        sta     VICCTR1                 ; save the vertical fine scroll and
                                        ; control register
        lda     CINV                    ; get IRQ vector LB
        sta     IRQTMP                  ; save IRQ vector LB

        lda     CINV+1                  ; get IRQ vector HB
        sta     IRQTMP+1                ; save IRQ vector HB

        jsr     SetTapeVector           ; set the tape vector           [FCBD]

        lda     #$02                    ; set copies count. First copy is load
                                        ; copy, the second copy is verify copy
        sta     FSBLK                   ; save copies count

        jsr     SetCounter              ; new tape byte setup           [FB97]

        lda     P6510                   ; read the 6510 I/O port
        and     #$1F                    ; mask 000x, cassette motor on ??
        sta     P6510                   ; save the 6510 I/O port
        sta     CAS1                    ; set the tape motor interlock

; 326656 cycle delay, allow tape motor speed to stabilise
        ldx     #$FF                    ; outer loop count
A_F8B5                                  ;                               [F8B5]
        ldy     #$FF                    ; inner loop count
A_F8B7                                  ;                               [F8B7]
        dey                             ; decrement inner loop count
        bne     A_F8B7                  ; loop if more to do

        dex                             ; decrement outer loop count
        bne     A_F8B5                  ; loop if more to do

        cli                             ; enable tape interrupts
J_F8BE                                  ;                               [F8BE]
        lda     IRQTMP+1                ; get saved IRQ HB
        cmp     CINV+1                  ; compare with the current IRQ HB
        clc                             ; flag ok
        beq     ClrSavIrqAddr           ; if tape write done go clear saved IRQ
                                        ; address and exit
        jsr     ScanStopKey0            ; scan stop key and flag abort if
                                        ; pressed                       [F8D0]
                                        ; note if STOP was pressed the return
                                        ; is to the routine that called this
                                        ; one and not here
        jsr     IncrClock22             ; increment real time clock     [F6BC]
        jmp     J_F8BE                  ; loop                          [F8BE]


;******************************************************************************
;
; scan stop key and flag abort if pressed

ScanStopKey0                            ;                               [F8D0]
        jsr     ScanStopKey             ; scan stop key                 [FFE1]
        clc                             ; flag no stop
        bne     A_F8E1                  ; exit if no stop

        jsr     StopUsingTape           ; restore everything for STOP   [FC93]

        sec                             ; flag stopped

        pla                             ; dump return address LB
        pla                             ; dump return address HB


;******************************************************************************
;
; clear saved IRQ address

ClrSavIrqAddr                           ;                               [F8DC]
        lda     #$00                    ; clear A
        sta     IRQTMP+1                ; clear saved IRQ address HB
A_F8E1                                  ;                               [F8E1]
        rts


;******************************************************************************
;
;## set timing

InitReadTape                            ;                               [F8E2]
        stx     CMPO+1                  ; save tape timing constant max byte

        lda     CMPO                    ; get tape timing constant min byte
        asl                             ; *2
        asl                             ; *4
        clc                             ; clear carry for add
        adc     CMPO                    ; add tape timing constant min byte *5
        clc                             ; clear carry for add
        adc     CMPO+1                  ; add tape timing constant max byte
        sta     CMPO+1                  ; save tape timing constant max byte

        lda     #$00                    ;.
        bit     CMPO                    ; test tape timing constant min byte
        bmi     A_F8F7                  ; branch if b7 set

        rol                             ; else shift carry into ??
A_F8F7                                  ;                               [F8F7]
        asl     CMPO+1                  ; shift tape timing constant max byte
        rol                             ;.
        asl     CMPO+1                  ; shift tape timing constant max byte
        rol                             ;.
        tax                             ;.
A_F8FE                                  ;                               [F8FE]
        lda     CIA1TI2L                ; get CIA 1 timer B LB
        cmp     #$16                    ;.compare with ??
        bcc     A_F8FE                  ; loop if less

        adc     CMPO+1                  ; add tape timing constant max byte
        sta     CIA1TI1L                ; save CIA 1 timer A LB

        txa                             ;.
        adc     CIA1TI2H                ; add CIA 1 timer B HB
        sta     CIA1TI1H                ; save CIA 1 timer A HB

        lda     Copy6522CRB             ; read CIA 1 CRB shadow copy
        sta     CIA1CTR1                ; save CIA 1 CRA
        sta     Copy6522CRA             ; save CIA 1 CRA shadow copy

        lda     CIA1IRQ                 ; read CIA 1 ICR
        and     #$10                    ; mask 000x 0000, FLAG interrupt
        beq     A_F92A                  ; if no FLAG interrupt just exit

; else first call the IRQ routine
        lda     #>A_F92A                ; set the return address HB
        pha                             ; push the return address HB

        lda     #<A_F92A                ; set the return address LB
        pha                             ; push the return address LB

        jmp     SaveStatGoIRQ           ; save the status and do the IRQ
                                        ; routine                       [FF43]

A_F92A                                  ;                               [F92A]
        cli                             ; enable interrupts
        rts


;******************************************************************************
;
;       On Commodore computers, the streams consist of four kinds of symbols
;       that denote different kinds of low-to-high-to-low transitions on the
;       read or write signals of the Commodore cassette interface.
;
;       A       A break in the communications, or a pulse with very long cycle
;               time.
;
;       B       A short pulse, whose cycle time typically ranges from 296 to 424
;               microseconds, depending on the computer model.
;
;       C       A medium-length pulse, whose cycle time typically ranges from
;               440 to 576 microseconds, depending on the computer model.
;
;       D       A long pulse, whose cycle time typically ranges from 600 to 744
;               microseconds, depending on the computer model.
;
;  The actual interpretation of the serial data takes a little more work to
; explain. The typical ROM tape loader (and the turbo loaders) will initialize
; a timer with a specified value and start it counting down. If either the tape
; data changes or the timer runs out, an IRQ will occur. The loader will
; determine which condition caused the IRQ. If the tape data changed before the
; timer ran out, we have a short pulse, or a "0" bit. If the timer ran out
; first, we have a long pulse, or a "1" bit. Doing this continuously and we
; decode the entire file.

; read tape bits, IRQ routine

; read T2C which has been counting down from $FFFF. subtract this from $FFFF

TapeRead_IRQ                            ;                               [F92C]
        ldx     CIA1TI2H                ; read CIA 1 timer B HB

        ldy     #$FF                    ;.set $FF
        tya                             ;.A = $FF

        sbc     CIA1TI2L                ; subtract CIA 1 timer B LB

        cpx     CIA1TI2H                ; compare it with CIA 1 timer B HB
        bne     TapeRead_IRQ            ; if timer LB rolled over loop

        stx     CMPO+1                  ; save tape timing constant max byte

        tax                             ;.copy $FF - T2C_l

        sty     CIA1TI2L                ; save CIA 1 timer B LB
        sty     CIA1TI2H                ; save CIA 1 timer B HB

        lda     #$19                    ; load timer B, timer B single shot,
                                        ; start timer B
        sta     CIA1CTR2                ; save CIA 1 CRB

        lda     CIA1IRQ                 ; read CIA 1 ICR
        sta     Copy6522ICR             ; save CIA 1 ICR shadow copy

        tya                             ; y = $FF
        sbc     CMPO+1                  ; subtract tape timing constant max byte
                                        ; A = $FF - T2C_h
        stx     CMPO+1                  ; save tape timing constant max byte
                                        ; CMPO+1 = $FF - T2C_l
        lsr                             ;.A = $FF - T2C_h >> 1
        ror     CMPO+1                  ; shift tape timing constant max byte
                                        ; CMPO+1 = $FF - T2C_l >> 1
        lsr                             ;.A = $FF - T2C_h >> 1
        ror     CMPO+1                  ; shift tape timing constant max byte
                                        ; CMPO+1 = $FF - T2C_l >> 1
        lda     CMPO                    ; get tape timing constant min byte
        clc                             ; clear carry for add
        adc     #$3C                    ;.
        cmp     CMPO+1                  ; compare with tape timing constant max
                                        ; byte compare with ($FFFF - T2C) >> 2
        bcs     A_F9AC                  ; branch if min+$3C >= ($FFFF-T2C) >> 2

;.min + $3C < ($FFFF - T2C) >> 2
        ldx     DPSW                    ;.get byte received flag
        beq     A_F969                  ;. if not byte received ??

        jmp     StoreTapeChar           ;.store the tape character      [FA60]

A_F969                                  ;                               [F969]
        ldx     TEMPA3                  ;.get EOI flag byte
        bmi     A_F988                  ;.

        ldx     #$00                    ;.

        adc     #$30                    ;.
        adc     CMPO                    ; add tape timing constant min byte
        cmp     CMPO+1                  ; compare with tape timing constant max
                                        ; byte
        bcs     A_F993                  ;.

        inx                             ;.

        adc     #$26                    ;.
        adc     CMPO                    ; add tape timing constant min byte
        cmp     CMPO+1                  ; compare with tape timing constant max
                                        ; byte
        bcs     J_F997                  ;.

        adc     #$2C                    ;.
        adc     CMPO                    ; add tape timing constant min byte
        cmp     CMPO+1                  ; compare with tape timing constant max
                                        ; byte
        bcc     A_F98B                  ;.

A_F988                                  ;                               [F988]
        jmp     J_FA10                  ;.                              [FA10]

A_F98B                                  ;                               [F98B]
        lda     BITTS                   ; get the bit count
        beq     A_F9AC                  ; if all done go ??

        sta     BITCI                   ; save receiver bit count in
        bne     A_F9AC                  ; branch always

A_F993                                  ;                               [F993]
        inc     RINONE                  ; increment ?? start bit check flag
        bcs     A_F999                  ;.

J_F997                                  ;                               [F997]
        dec     RINONE                  ; decrement ?? start bit check flag
A_F999                                  ;                               [F999]
        sec                             ;.
        sbc     #$13                    ;.
        sbc     CMPO+1                  ; subtract tape timing constant max byte
        adc     SVXT                    ; add timing constant for tape
        sta     SVXT                    ; save timing constant for tape

        lda     TEMPA4                  ;.get tape bit cycle phase
        eor     #$01                    ;.
        sta     TEMPA4                  ;.save tape bit cycle phase
        beq     A_F9D5                  ;.

        stx     TEMPD7                  ;.
A_F9AC                                  ;                               [F9AC]
        lda     BITTS                   ; get the bit count
        beq     A_F9D2                  ; if all done go ??

        lda     Copy6522ICR             ; read CIA 1 ICR shadow copy
        and     #$01                    ; mask 0000 000x, timer A interrupt
                                        ; enabled
        bne     A_F9BC                  ; if timer A is enabled go ??

        lda     Copy6522CRA             ; read CIA 1 CRA shadow copy
        bne     A_F9D2                  ; if ?? just exit

A_F9BC                                  ;                               [F9BC]
        lda     #$00                    ; clear A
        sta     TEMPA4                  ; clear the tape bit cycle phase
        sta     Copy6522CRA             ; save CIA 1 CRA shadow copy

        lda     TEMPA3                  ;.get EOI flag byte
        bpl     A_F9F7                  ;.

        bmi     A_F988                  ; always ->

A_F9C9                                  ;                               [F9C9]
        ldx     #$A6                    ; set timimg max byte
        jsr     InitReadTape            ; set timing                    [F8E2]

        lda     PRTY                    ;.
        bne     A_F98B                  ;.
A_F9D2                                  ;                               [F9D2]
        jmp     End_RS232_NMI           ; restore registers and exit interrupt
                                        ;                               [FEBC]
A_F9D5                                  ;                               [F9D5]
        lda     SVXT                    ; get timing constant for tape
        beq     A_F9E0                  ;.

        bmi     A_F9DE                  ;.

        dec     CMPO                    ; decrement tape timing constant min
                                        ; byte
.byte   $2C
A_F9DE                                  ;                               [F9DE]
        inc     CMPO                    ; increment tape timing constant min
                                        ; byte
A_F9E0                                  ;                               [F9E0]
        lda     #$00                    ;.
        sta     SVXT                    ; clear timing constant for tape

        cpx     TEMPD7                  ;.
        bne     A_F9F7                  ;.

        txa                             ;.
        bne     A_F98B                  ;.

        lda     RINONE                  ; get start bit check flag
        bmi     A_F9AC                  ;.

        cmp     #$10                    ;.
        bcc     A_F9AC                  ;.

        sta     SYNO                    ;.save cassette block synchronization
                                        ; number
        bcs     A_F9AC                  ;.
A_F9F7                                  ;                               [F9F7]
        txa                             ;.
        eor     PRTY                    ;.
        sta     PRTY                    ;.

        lda     BITTS                   ;.
        beq     A_F9D2                  ;.

        dec     TEMPA3                  ;.decrement EOI flag byte
        bmi     A_F9C9                  ;.

        lsr     TEMPD7                  ;.
        ror     MYCH                    ;.parity count

        ldx     #$DA                    ; set timimg max byte
        jsr     InitReadTape            ; set timing                    [F8E2]

        jmp     End_RS232_NMI           ; restore registers and exit interrupt
                                        ;                               [FEBC]
J_FA10                                  ;                               [FA10]
        lda     SYNO                    ; get cassette block synchron. number
        beq     A_FA18                  ;.

        lda     BITTS                   ;.
        beq     A_FA1F                  ;.

A_FA18                                  ;                               [FA18]
        lda     TEMPA3                  ;.get EOI flag byte
        bmi     A_FA1F                  ;.

        jmp     J_F997                  ;.                              [F997]

A_FA1F                                  ;                               [FA1F]
        lsr     CMPO+1                  ; shift tape timing constant max byte

        lda     #$93                    ;.
        sec                             ;.
        sbc     CMPO+1                  ; subtract tape timing constant max byte
        adc     CMPO                    ; add tape timing constant min byte
        asl                             ;.
        tax                             ; copy timimg HB

        jsr     InitReadTape            ; set timing                    [F8E2]

        inc     DPSW                    ;.

        lda     BITTS                   ;.
        bne     A_FA44                  ;.

        lda     SYNO                    ; get cassette block synchron. number
        beq     A_FA5D                  ;.

        sta     BITCI                   ; save receiver bit count in

        lda     #$00                    ; clear A
        sta     SYNO                    ; clear cassette block synchron. number

        lda     #$81                    ; enable timer A interrupt
        sta     CIA1IRQ                 ; save CIA 1 ICR
        sta     BITTS                   ;.
A_FA44                                  ;                               [FA44]
        lda     SYNO                    ; get cassette block synchron. number
        sta     NXTBIT                  ;.
        beq     A_FA53                  ;.

        lda     #$00                    ;.
        sta     BITTS                   ;.

        lda     #$01                    ; disable timer A interrupt
        sta     CIA1IRQ                 ; save CIA 1 ICR
A_FA53                                  ;                               [FA53]
        lda     MYCH                    ;.parity count
        sta     ROPRTY                  ;.save RS232 parity byte

        lda     BITCI                   ; get receiver bit count in
        ora     RINONE                  ; OR with start bit check flag
        sta     RODATA                  ;.
A_FA5D                                  ;                               [FA5D]
        jmp     End_RS232_NMI           ; restore registers and exit interrupt
                                        ;                               [FEBC]

;******************************************************************************
;
;## store character

StoreTapeChar                           ;                               [FA60]
        jsr     SetCounter              ; new tape byte setup           [FB97]
        sta     DPSW                    ; clear byte received flag

        ldx     #$DA                    ; set timimg max byte
        jsr     InitReadTape            ; set timing                    [F8E2]

        lda     FSBLK                   ;.get copies count
        beq     A_FA70                  ;.

        sta     INBIT                   ; save receiver input bit temporary
                                        ; storage
A_FA70                                  ;                               [FA70]
        lda     #$0F                    ;.
        bit     RIDATA                  ;.
        bpl     A_FA8D                  ;.

        lda     NXTBIT                  ;.
        bne     A_FA86                  ;.

        ldx     FSBLK                   ;.get copies count
        dex                             ;.
        bne     A_FA8A                  ; if ?? restore registers and exit
                                        ; interrupt
        lda     #$08                    ; set short block
        jsr     AorIecStatus            ; OR into serial status byte    [FE1C]
        bne     A_FA8A                  ; restore registers and exit interrupt,
                                        ; branch always
A_FA86                                  ;                               [FA86]
        lda     #$00                    ;.
        sta     RIDATA                  ;.
A_FA8A                                  ;                               [FA8A]
        jmp     End_RS232_NMI           ; restore registers and exit interrupt
                                        ;                               [FEBC]
A_FA8D                                  ;                               [FA8D]
        bvs     A_FAC0                  ;.

        bne     A_FAA9                  ;.

        lda     NXTBIT                  ;.
        bne     A_FA8A                  ;.

        lda     RODATA                  ;.
        bne     A_FA8A                  ;.

        lda     INBIT                   ; get receiver input bit temporary
                                        ; storage
        lsr                             ;.

        lda     ROPRTY                  ;.get RS232 parity byte
        bmi     A_FAA3                  ;.

        bcc     A_FABA                  ;.

        clc                             ;.
A_FAA3                                  ;                               [FAA3]
        bcs     A_FABA                  ;.

        and     #$0F                    ;.
        sta     RIDATA                  ;.
A_FAA9                                  ;                               [FAA9]
        dec     RIDATA                  ;.
        bne     A_FA8A                  ;.

        lda     #$40                    ;.
        sta     RIDATA                  ;.

        jsr     CopyIoAdr2Buf           ; copy I/O start address to buffer
                                        ; address                       [FB8E]
        lda     #$00                    ;.
        sta     RIPRTY                  ;.
        beq     A_FA8A                  ;.
A_FABA                                  ;                               [FABA]
        lda     #$80                    ;.
        sta     RIDATA                  ;.
        bne     A_FA8A                  ; restore registers and exit interrupt,
                                        ; branch always
A_FAC0                                  ;                               [FAC0]
        lda     NXTBIT                  ;.
        beq     A_FACE                  ;.

        lda     #$04                    ;.
        jsr     AorIecStatus            ; OR into serial status byte    [FE1C]

        lda     #$00                    ;.
        jmp     J_FB4A                  ;.                              [FB4A]

A_FACE                                  ;                               [FACE]
        jsr     ChkRdWrPtr              ; check read/write pointer, return
                                        ;Cb = 1 if pointer >= end       [FCD1]
        bcc     A_FAD6                  ;.

        jmp     J_FB48                  ;.                              [FB48]

A_FAD6                                  ;                               [FAD6]
        ldx     INBIT                   ; get receiver input bit temporary
                                        ; storage
        dex                             ;.
        beq     A_FB08                  ;.

        lda     LoadVerify2             ; get load/verify flag
        beq     A_FAEB                  ; if load go ??

        ldy     #$00                    ; clear index
        lda     ROPRTY                  ;.get RS232 parity byte
        cmp     (SAL),Y                 ;.
        beq     A_FAEB                  ;.

        lda     #$01                    ;.
        sta     RODATA                  ;.
A_FAEB                                  ;                               [FAEB]
        lda     RODATA                  ;.
        beq     J_FB3A                  ;.

        ldx     #$3D                    ;.
        cpx     PTR1                    ;.
        bcc     A_FB33                  ;.

        ldx     PTR1                    ;.
        lda     SAL+1                   ;.
        sta     STACK+1,X               ;.

        lda     SAL                     ;.
        sta     STACK,X                 ;.

        inx                             ;.
        inx                             ;.
        stx     PTR1                    ;.

        jmp     J_FB3A                  ;.                              [FB3A]

A_FB08                                  ;                               [FB08]
        ldx     PTR2                    ;.
        cpx     PTR1                    ;.
        beq     A_FB43                  ;.

        lda     SAL                     ;.
        cmp     STACK,X                 ;.
        bne     A_FB43                  ;.

        lda     SAL+1                   ;.
        cmp     STACK+1,X               ;.
        bne     A_FB43                  ;.

        inc     PTR2                    ;.
        inc     PTR2                    ;.

        lda     LoadVerify2             ; get load/verify flag
        beq     A_FB2F                  ; if load ??

        lda     ROPRTY                  ;.get RS232 parity byte
        ldy     #$00                    ;.
        cmp     (SAL),Y                 ;.
        beq     A_FB43                  ;.

        iny                             ;.
        sty     RODATA                  ;.
A_FB2F                                  ;                               [FB2F]
        lda     RODATA                  ;.
        beq     J_FB3A                  ;.
A_FB33                                  ;                               [FB33]
        lda     #$10                    ;.
        jsr     AorIecStatus            ; OR into serial status byte    [FE1C]
        bne     A_FB43                  ;.
J_FB3A                                  ;                               [FB3A]
        lda     LoadVerify2             ; get load/verify flag
        bne     A_FB43                  ; if verify go ??

        tay                             ;.
        lda     ROPRTY                  ;.get RS232 parity byte
        sta     (SAL),Y                 ;.
A_FB43                                  ;                               [FB43]
        jsr     IncRdWrPtr              ; increment read/write pointer  [FCDB]
        bne     A_FB8B                  ; restore registers and exit interrupt,
                                        ; branch always
J_FB48                                  ;                               [FB48]
        lda     #$80                    ;.
J_FB4A                                  ;                               [FB4A]
        sta     RIDATA                  ;.

        sei                             ;.

        ldx     #$01                    ; disable timer A interrupt
        stx     CIA1IRQ                 ; save CIA 1 ICR

        ldx     CIA1IRQ                 ; read CIA 1 ICR

        ldx     FSBLK                   ;.get copies count
        dex                             ;.
        bmi     A_FB5C                  ;.

        stx     FSBLK                   ;.save copies count
A_FB5C                                  ;                               [FB5C]
        dec     INBIT                   ; decrement receiver input bit temporary
                                        ; storage
        beq     A_FB68                  ;.

        lda     PTR1                    ;.
        bne     A_FB8B                  ; if ?? restore registers and exit
                                        ; interrupt
        sta     FSBLK                   ;.save copies count
        beq     A_FB8B                  ; restore registers and exit interrupt,
                                        ; branch always
A_FB68                                  ;                               [FB68]
        jsr     StopUsingTape           ; restore everything for STOP   [FC93]
        jsr     CopyIoAdr2Buf           ; copy I/O start address to buffer
                                        ; address       [FB8E]

        ldy     #$00                    ; clear index
        sty     RIPRTY                  ; clear checksum
A_FB72                                  ;                               [FB72]
        lda     (SAL),Y                 ; get byte from buffer
        eor     RIPRTY                  ; XOR with checksum
        sta     RIPRTY                  ; save new checksum

        jsr     IncRdWrPtr              ; increment read/write pointer  [FCDB]

        jsr     ChkRdWrPtr              ; check read/write pointer, return 
                                        ;Cb = 1 if pointer >= end       [FCD1]
        bcc     A_FB72                  ; loop if not at end

        lda     RIPRTY                  ; get computed checksum
        eor     ROPRTY                  ; compare with stored checksum ??
        beq     A_FB8B                  ; if checksum ok restore registers and
                                        ; exit interrupt
        lda     #$20                    ; else set checksum error
        jsr     AorIecStatus            ; OR into the serial status byte [FE1C]
A_FB8B                                  ;                               [FB8B]
        jmp     End_RS232_NMI           ; restore registers and exit interrupt
                                        ;                               [FEBC]

;******************************************************************************
;
; copy I/O start address to buffer address

CopyIoAdr2Buf                           ;                               [FB8E]
        lda     STAL+1                  ; get I/O start address HB
        sta     SAL+1                   ; set buffer address HB

        lda     STAL                    ; get I/O start address LB
        sta     SAL                     ; set buffer address LB

        rts


;******************************************************************************
;
; new tape byte setup

SetCounter                              ;                               [FB97]
        lda     #$08                    ; eight bits to do
        sta     TEMPA3                  ; set bit count

        lda     #$00                    ; clear A
        sta     TEMPA4                  ; clear tape bit cycle phase
        sta     BITCI                   ; clear start bit first cycle done flag
        sta     PRTY                    ; clear byte parity
        sta     RINONE                  ; clear start bit check flag, set no
                                        ; start bit yet
        rts


;******************************************************************************
;
; send lsb from tape write byte to tape

; this routine tests the least significant bit in the tape write byte and sets
; CIA 2 T2 depending on the state of the bit. if the bit is a 1 a time of $00B0
; cycles is set, if the bot is a 0 a time of $0060 cycles is set. note that
; this routine does not shift the bits of the tape write byte but uses a copy
; of that byte, the byte itself is shifted elsewhere

WriteBitToTape                          ;                               [FBA6]
        lda     ROPRTY                  ; get tape write byte
        lsr                             ; shift lsb into Cb

        lda     #$60                    ; set time constant LB for bit = 0
        bcc     SetTimeHByte            ; branch if bit was 0

; set time constant for bit = 1 and toggle tape

SetTimeBitIs1                           ;                               [FBAD]
        lda     #$B0                    ; set time constant LB for bit = 1

; write time constant and toggle tape

SetTimeHByte                            ;                               [FBAF]
        ldx     #$00                    ; set time constant HB

; write time constant and toggle tape

WrTimeTgglTape                          ;                               [FBB1]
        sta     CIA1TI2L                ; save CIA 1 timer B LB
        stx     CIA1TI2H                ; save CIA 1 timer B HB

        lda     CIA1IRQ                 ; read CIA 1 ICR

        lda     #$19                    ; load timer B, timer B single shot,
                                        ; start timer B
        sta     CIA1CTR2                ; save CIA 1 CRB

        lda     P6510                   ; read the 6510 I/O port
        eor     #$08                    ; toggle tape out bit
        sta     P6510                   ; save the 6510 I/O port

        and     #$08                    ; mask tape out bit
        rts


;******************************************************************************
;
; flag block done and exit interrupt

FlagBlockDone                           ;                               [FBC8]
        sec                             ; set carry flag
        ror     RODATA                  ; set buffer address HB negative, flag
                                        ; all sync, data and checksum bytes
                                        ; written
        bmi     A_FC09                  ; restore registers and exit interrupt,
                                        ; branch always

;******************************************************************************
;
; tape write IRQ routine

; this is the routine that writes the bits to the tape. it is called each time
; CIA 2 T2 times out and checks if the start bit is done, if so checks if the
; data bits are done, if so it checks if the byte is done, if so it checks if
; the synchronisation bytes are done, if so it checks if the data bytes are
; done, if so it checks if the checksum byte is done, if so it checks if both
; the load and verify copies have been done, if so it stops the tape

TapeWrite_IRQ                           ;                               [FBCD]
        lda     BITCI                   ; get start bit first cycle done flag
        bne     A_FBE3                  ; if first cycle done go do rest of byte

; each byte sent starts with two half cycles of $0110 ststem clocks and the
; whole block ends with two more such half cycles

        lda     #$10                    ; set first start cycle time constant LB
        ldx     #$01                    ; set first start cycle time constant HB
        jsr     WrTimeTgglTape          ; write time constant and toggle tape
                                        ;                               [FBB1]
        bne     A_FC09                  ; if first half cycle go restore
                                        ; registers and exit interrupt
        inc     BITCI                   ; set start bit first start cycle done
                                        ; flag
        lda     RODATA                  ; get buffer address HB
        bpl     A_FC09                  ; if block not complete go restore
                                        ; registers and exit interrupt. The end
                                        ; of a block is indicated by the tape
                                        ; buffer HB b7 being set to 1
        jmp     J_FC57                  ; else do tape routine, block complete
                                        ; exit                          [FC57]

; continue tape byte write. the first start cycle, both half cycles of it, is
; complete so the routine drops straight through to here

A_FBE3                                  ;                               [FBE3]
        lda     RINONE                  ; get start bit check flag
        bne     A_FBF0                  ; if start bit is complete, go send byte

; after the two half cycles of $0110 ststem clocks the start bit is completed
; with two half cycles of $00B0 system clocks. this is the same as the first
; part of a 1 bit

        jsr     SetTimeBitIs1           ; set time constant for bit = 1 and 
                                        ; toggle tape                   [FBAD]
        bne     A_FC09                  ; if first half cycle go restore
                                        ; registers and exit interrupt
        inc     RINONE                  ; set start bit check flag
        bne     A_FC09                  ; restore registers and exit interrupt,
                                        ; branch always

; continue tape byte write. the start bit, both cycles of it, is complete so
; the routine drops straight through to here. now the cycle pairs for each bit,
; and the parity bit, are sent

A_FBF0                                  ;                               [FBF0]
        jsr     WriteBitToTape          ; send lsb from tape write byte to tape
                                        ;                               [FBA6]
        bne     A_FC09                  ; if first half cycle go restore
                                        ; registers and exit interrupt
; else two half cycles have been done
        lda     TEMPA4                  ; get tape bit cycle phase
        eor     #$01                    ; toggle b0
        sta     TEMPA4                  ; save tape bit cycle phase
        beq     A_FC0C                  ; if bit cycle phase complete go setup
                                        ; for next bit

; each bit is written as two full cycles. a 1 is sent as a full cycle of $0160
; system clocks then a full cycle of $00C0 system clocks. a 0 is sent as a full
; cycle of $00C0 system clocks then a full cycle of $0160 system clocks. to do
; this each bit from the write byte is inverted during the second bit cycle
; phase. as the bit is inverted it is also added to the, one bit, parity count
; for this byte

        lda     ROPRTY                  ; get tape write byte
        eor     #$01                    ; invert bit being sent
        sta     ROPRTY                  ; save tape write byte

        and     #$01                    ; mask b0
        eor     PRTY                    ; EOR with tape write byte parity bit
        sta     PRTY                    ; save tape write byte parity bit
A_FC09                                  ;                               [FC09]
        jmp     End_RS232_NMI           ; restore registers and exit interrupt
                                        ;                               [FEBC]

; the bit cycle phase is complete so shift out the just written bit and test
; for byte end

A_FC0C                                  ;                               [FC0C]
        lsr     ROPRTY                  ; shift bit out of tape write byte

        dec     TEMPA3                  ; decrement tape write bit count

        lda     TEMPA3                  ; get tape write bit count
        beq     A_FC4E                  ; if all data bits have been written, do
                                        ; setup for sending parity bit next and
                                        ; exit the interrupt
        bpl     A_FC09                  ; if all data bits are not yet sent,
                                        ; just restore registers and exit
                                        ; interrupt
; do next tape byte

; the byte is complete. the start bit, data bits and parity bit have been
; written to the tape so setup for the next byte

A_FC16                                  ;                               [FC16]
        jsr     SetCounter              ; new tape byte setup           [FB97]

        cli                             ; enable the interrupts

        lda     CNTDN                   ; get cassette synchronization character
                                        ; count
        beq     A_FC30                  ; if synchronisation characters done,
                                        ; do block data

; at the start of each block sent to tape there are a number of synchronisation
; bytes that count down to the actual data. the commodore tape system saves two
; copies of all the tape data, the first is loaded and is indicated by the
; synchronisation bytes having b7 set, and the second copy is indicated by the
; synchronisation bytes having b7 clear. the sequence goes $09, $08, ..... $02,
; $01, data bytes

        ldx     #$00                    ; clear X
        stx     TEMPD7                  ; clear checksum byte

        dec     CNTDN                   ; decrement cassette synchronization
                                        ; byte count
        ldx     FSBLK                   ; get cassette copies count
        cpx     #$02                    ; compare with load block indicator
        bne     A_FC2C                  ; branch if not the load block

        ora     #$80                    ; this is the load block so make the
                                        ; synchronisation count
                                        ; go $89, $88, ..... $82, $81
A_FC2C                                  ;                               [FC2C]
        sta     ROPRTY                  ; save the synchronisation byte as the
                                        ; tape write byte
        bne     A_FC09                  ; restore registers and exit interrupt,
                                        ; branch always

; the synchronization bytes have been done so now check and do the actual block
; data

A_FC30                                  ;                               [FC30]
        jsr     ChkRdWrPtr              ; check read/write pointer, return
                                        ; Cb = 1 if pointer >= end      [FCD1]
        bcc     A_FC3F                  ; if not all done yet go get the byte
                                        ; to send
        bne     FlagBlockDone           ; if pointer > end go flag block done
                                        ; and exit interrupt

; else the block is complete, it only remains to write the checksum byte to the
; tape so setup for that
        inc     SAL+1                   ; increment buffer pointer HB, this
                                        ; means block done branch will always be
                                        ; taken next time without having to
                                        ; worry about the LB wrapping to zero
        lda     TEMPD7                  ; get checksum byte
        sta     ROPRTY                  ; save checksum as tape write byte
        bcs     A_FC09                  ; restore registers and exit interrupt,
                                        ; branch always

; the block isn't finished so get the next byte to write to tape

A_FC3F                                  ;                               [FC3F]
        ldy     #$00                    ; clear index
        lda     (SAL),Y                 ; get byte from buffer
        sta     ROPRTY                  ; save as tape write byte

        eor     TEMPD7                  ; XOR with checksum byte
        sta     TEMPD7                  ; save new checksum byte

        jsr     IncRdWrPtr              ; increment read/write pointer  [FCDB]
        bne     A_FC09                  ; restore registers and exit interrupt,
                                        ; branch always

; set parity as next bit and exit interrupt
A_FC4E                                  ;                               [FC4E]
        lda     PRTY                    ; get parity bit
        eor     #$01                    ; toggle it
        sta     ROPRTY                  ; save as tape write byte
A_FC54                                  ;                               [FC54]
        jmp     End_RS232_NMI           ; restore registers and exit interrupt
                                        ;       [FEBC]

; tape routine, block complete exit
J_FC57                                  ;                               [FC57]
        dec     FSBLK                   ; decrement copies remaining to
                                        ; read/write
        bne     A_FC5E                  ; branch if more to do

        jsr     StopTapeMotor           ; stop the cassette motor       [FCCA]
A_FC5E                                  ;                               [FC5E]
        lda     #$50                    ; set tape write leader count
        sta     INBIT                   ; save tape write leader count

        ldx     #$08                    ; set index for write tape leader vector

        sei                             ; disable the interrupts

        jsr     SetTapeVector           ; set the tape vector           [FCBD]
        bne     A_FC54                  ; restore registers and exit interrupt,
                                        ; branch always


;******************************************************************************
;
; write tape leader IRQ routine

TapeLeader_IRQ                          ;                               [FC6A]
        lda     #$78                    ; set time constant LB for bit = leader
        jsr     SetTimeHByte            ; write time constant and toggle tape
                                        ;                               [FBAF]
        bne     A_FC54                  ; if tape bit high restore registers
                                        ; and exit interrupt
        dec     INBIT                   ; decrement cycle count
        bne     A_FC54                  ; if not all done restore registers and
                                        ; exit interrupt
        jsr     SetCounter              ; new tape byte setup           [FB97]

        dec     RIPRTY                  ; decrement cassette leader count
        bpl     A_FC54                  ; if not all done restore registers and
                                        ; exit interrupt
        ldx     #$0A                    ; set index for tape write vector
        jsr     SetTapeVector           ; set the tape vector           [FCBD]

        cli                             ; enable the interrupts

        inc     RIPRTY                  ; clear cassette leader counter, was $FF

        lda     FSBLK                   ; get cassette block count
        beq     A_FCB8                  ; if all done restore everything for
                                        ; STOP and exit the interrupt
        jsr     CopyIoAdr2Buf           ; copy I/O start address to buffer
                                        ; address                       [FB8E]
        ldx     #$09                    ; set nine synchronisation bytes
        stx     CNTDN                   ; save cassette synchron. byte count
        stx     RODATA                  ;.
        bne     A_FC16                  ; go do next tape byte, branch always


;******************************************************************************
;
; restore everything for STOP

StopUsingTape                           ;                               [FC93]
        php                             ; save status

        sei                             ; disable the interrupts

        lda     VICCTR1                 ; read the vertical fine scroll and
                                        ; control register
        ora     #$10                    ; unblank the screen
        sta     VICCTR1                 ; save the vertical fine scroll and
                                        ; control register
        jsr     StopTapeMotor           ; stop the cassette motor       [FCCA]

        lda     #$7F                    ; disable all interrupts
        sta     CIA1IRQ                 ; save CIA 1 ICR

        jsr     TimingPalNtsc           ;.                              [FDDD]

        lda     IRQTMP+1                ; get saved IRQ vector HB
        beq     A_FCB6                  ; branch if null

        sta     CINV+1                  ; restore IRQ vector HB

        lda     IRQTMP                  ; get saved IRQ vector LB
        sta     CINV                    ; restore IRQ vector LB
A_FCB6                                  ;                               [FCB6]
        plp                             ; restore status

        rts


;******************************************************************************
;
; reset vector

A_FCB8                                  ;                               [FCB8]
        jsr     StopUsingTape           ; restore everything for STOP   [FC93]
        beq     A_FC54                  ; restore registers and exit interrupt,
                                        ; branch always

;******************************************************************************
;
; set tape vector

SetTapeVector                           ;                               [FCBD]
        lda     TapeIrqVectors-8,X      ; get tape IRQ vector LB
        sta     CINV                    ; set IRQ vector LB

        lda     TapeIrqVectors-7,X      ; get tape IRQ vector HB
        sta     CINV+1                  ; set IRQ vector HB

        rts


;******************************************************************************
;
; stop the cassette motor

StopTapeMotor                           ;                               [FCCA]
        lda     P6510                   ; read the 6510 I/O port
        ora     #$20                    ; mask xx1x, turn the cassette motor off
        sta     P6510                   ; save the 6510 I/O port

        rts


;******************************************************************************
;
; check read/write pointer
; return Cb = 1 if pointer >= end

ChkRdWrPtr                              ;                               [FCD1]
        sec                             ; set carry for subtract
        lda     SAL                     ; get buffer address LB
        sbc     EAL                     ; subtract buffer end LB

        lda     SAL+1                   ; get buffer address HB
        sbc     EAL+1                   ; subtract buffer end HB

        rts


;******************************************************************************
;
; increment read/write pointer

IncRdWrPtr                              ;                               [FCDB]
        inc     SAL                     ; increment buffer address LB
        bne     A_FCE1                  ; branch if no overflow

        inc     SAL+1                   ; increment buffer address LB
A_FCE1                                  ;                               [FCE1]
        rts


;******************************************************************************
;
; RESET, hardware reset starts here

RESET_routine                           ;                               [FCE2]
        ldx     #$FF                    ; set X for stack
        sei                             ; disable the interrupts
        txs                             ; clear stack

        cld                             ; clear decimal mode

        jsr     Chk4Cartridge           ; scan for autostart ROM at $8000 [FD02]
        bne     A_FCEF                  ; if not there continue startup

        jmp     (RomStart)              ; else call ROM start code

A_FCEF                                  ;                               [FCEF]
        stx     VICCTR2                 ; read the horizontal fine scroll and 
                                        ;control register
        jsr     InitSidCIAIrq2          ; initialise SID, CIA and IRQ   [FDA3]
        jsr     TestRAM2                ; RAM test and find RAM end     [FD50]
        jsr     SetVectorsIO2           ; restore default I/O vectors   [FD15]
.if Version=1
        jsr     InitScreenKeyb          ;                               [E518]

.else
        jsr     InitialiseVIC2          ; initialise VIC and screen editor
                                        ;                               [FF5B]
.fi
        cli                             ; enable the interrupts

        jmp     (BasicCold)             ; execute BASIC


;******************************************************************************
;
; scan for autostart ROM at $8000, returns Zb=1 if ROM found

Chk4Cartridge                           ;                               [FD02]
        ldx     #$05                    ; five characters to test
A_FD04                                  ;                               [FD04]
        lda     RomSignature-1,X        ; get test character
        cmp     RomIdentStr-1,X         ; compare wiith byte in ROM space
        bne     D_FD0F                  ; exit if no match

        dex                             ; decrement index
        bne     A_FD04                  ; loop if not all done

D_FD0F                                  ;                               [FD0F]
        rts


;******************************************************************************
;
; autostart ROM signature

RomSignature                            ;                               [FD10]
.byte   $C3,$C2,$CD,$38,$30             ; CBM80


;******************************************************************************
;
; restore default I/O vectors

; This routine restores the default values of all system vectors used in KERNAL
; and BASIC routines and interrupts. The KERNAL VECTOR routine is used to read
; and alter individual system vectors.

SetVectorsIO2                           ;                               [FD15]
        ldx     #<TblVectors            ; pointer to vector table LB
        ldy     #>TblVectors            ; pointer to vector table HB
S_FD19 
        clc                             ; flag set vectors


;******************************************************************************
;
; set/read vectored I/O from (XY), Cb = 1 to read, Cb = 0 to set

; this routine manages all system vector jump addresses stored in RAM. calling
; this routine with the accumulator carry bit set will store the current
; contents of the RAM vectors in a list pointed to by the X and Y registers.

; When this routine is called with the carry bit clear, the user list pointed
; to by the X and Y registers is transferred to the system RAM vectors.

; NOTE: This routine requires caution in its use. The best way to use it is to
; first read the entire vector contents into the user area, alter the desired
; vectors, and then copy the contents back to the system vectors.

CopyVectorsIO2                          ;                               [FD1A]
        stx     MEMUSS                  ; save pointer LB
        sty     MEMUSS+1                ; save pointer HB
        ldy     #$1F                    ; set byte count
A_FD20                                  ;                               [FD20]
        lda     CINV,Y                  ; read vector byte from vectors
        bcs     A_FD27                  ; branch if read vectors

        lda     (MEMUSS),Y              ; read vector byte from (XY)
A_FD27                                  ;                               [FD27]
        sta     (MEMUSS),Y              ; save byte to (XY)
        sta     CINV,Y                  ; save byte to vector
        dey                             ; decrement index
        bpl     A_FD20                  ; loop if more to do

        rts

; The above code works but it tries to write to the ROM. while this is usually
; harmless systems that use flash ROM may suffer. Here is a version that makes
; the extra write to RAM instead but is otherwise identical in function. ##
;
; set/read vectored I/O from (XY), Cb = 1 to read, Cb = 0 to set
;
;CopyVectorsIO2
;       STX     MEMUSS                  ; save pointer LB
;       STY     MEMUSS+1                ; save pointer HB
;       LDY     #$1F                    ; set byte count
;A_FD20:
;       LDA     (MEMUSS),Y              ; read vector byte from (XY)
;       BCC     A_FD29                  ; branch if set vectors
;
;       LDA     CINV,Y                  ; else read vector byte from vectors
;       STA     (MEMUSS),Y              ; save byte to (XY)
;A_FD29:
;       STA     CINV,Y                  ; save byte to vector
;       DEY                             ; decrement index
;       BPL     A_FD20                  ; loop if more to do
;
;       RTS


;******************************************************************************
;
; kernal vectors

TblVectors                              ;                               [FD30]
.word   IRQ_vector              ; CINV    IRQ vector
.word   BRK_vector              ; BINV    BRK vector
.word   NMI_vector              ; NMINV   NMI vector
.word   OpenLogFile2            ; IOPEN   open a logical file
.word   CloseLogFile2           ; ICLOSE  close a specified logical file
.word   OpenChanInput           ; ICHKIN  open channel for input
.word   OpenChanOutput          ; ICKOUT  open channel for output
.word   CloseIoChans            ; ICLRCH  close input and output channels
.word   ByteFromChan2           ; IBASIN  input character from channel
.word   OutByteChan2            ; IBSOUT  output character to channel
.word   Scan4StopKey            ; ISTOP   scan stop key
.word   GetByteInpDev           ; IGETIN  get character from the input device
.word   ClsAllChnFil            ; ICLALL  close all channels and files
.word   BRK_vector              ; UserFn  user function

; Vector to user defined command, currently points to BRK.

; This appears to be a holdover from PET days, when the built-in machine
; language monitor would jump through the UserFn vector when it encountered a
; command that it did not understand, allowing the user to add new commands to
; the monitor.

; Although this vector is initialized to point to the routine called by
; STOP/RESTORE and the BRK interrupt, and is updated by the kernal vector
; routine at $FD57, it no longer has any function.

.word   LoadRamFrmDev22                 ; ILOAD load
.word   SaveRamToDev22                  ; ISAVE save


;******************************************************************************
;
; test RAM and find RAM end

TestRAM2                                ;                               [FD50]
        lda     #$00                    ; clear A
        tay                             ; clear index
A_FD53                                  ;                               [FD53]
        sta     D6510+2,Y               ; clear page 0, don't do $0000 or $0001
        sta     CommandBuf,Y            ; clear page 2
        sta     IERROR,Y                ; clear page 3

        iny                             ; increment index
        bne     A_FD53                  ; loop if more to do

        ldx     #<TapeBuffer            ; set cassette buffer pointer LB
        ldy     #>TapeBuffer            ; set cassette buffer pointer HB
        stx     TapeBufPtr              ; save tape buffer start pointer LB
        sty     TapeBufPtr+1            ; save tape buffer start pointer HB

        tay                             ; clear Y

        lda     #$03                    ; set RAM test pointer HB
        sta     STAL+1                  ; save RAM test pointer HB
A_FD6C                                  ;                               [FD6C]
        inc     STAL+1                  ; increment RAM test pointer HB
A_FD6E                                  ;                               [FD6E]
        lda     (STAL),Y                ;.
        tax                             ;.

        lda     #$55                    ;.
        sta     (STAL),Y                ;.
        cmp     (STAL),Y                ;.
        bne     A_FD88                  ;.

        rol                             ;.
        sta     (STAL),Y                ;.

        cmp     (STAL),Y                ;.
        bne     A_FD88                  ;.

        txa                             ;.
        sta     (STAL),Y                ;.

        iny                             ;.
        bne     A_FD6E                  ;.
        beq     A_FD6C                  ; always ->

A_FD88                                  ;                               [FD88]
        tya                             ;.
        tax                             ;.

        ldy     STAL+1                  ;.
        clc                             ;.
        jsr     SetTopOfMem2            ; set the top of memory         [FE2D]

        lda     #$08                    ;.
        sta     StartOfMem+1            ; save the OS start of memory HB

        lda     #$04                    ;.
        sta     HIBASE                  ; save the screen memory page

        rts


;******************************************************************************
;
; tape IRQ vectors

TapeIrqVectors                          ;                               [FD9B]
.word   TapeLeader_IRQ                  ; $08   write tape leader IRQ routine
.word   TapeWrite_IRQ                   ; $0A   tape write IRQ routine
.word   IRQ_vector                      ; $0C   normal IRQ vector
.word   TapeRead_IRQ                    ; $0E   read tape bits IRQ routine


;******************************************************************************
;
; initialise SID, CIA and IRQ

InitSidCIAIrq2                          ;                               [FDA3]
        lda     #$7F                    ; disable all interrupts
        sta     CIA1IRQ                 ; save CIA 1 ICR
        sta     CIA2IRQ                 ; save CIA 2 ICR
        sta     CIA1DRA                 ; save CIA 1 DRA, keyboard column drive

        lda     #$08                    ; set timer single shot
        sta     CIA1CTR1                ; save CIA 1 CRA
        sta     CIA2CTR1                ; save CIA 2 CRA
        sta     CIA1CTR2                ; save CIA 1 CRB
        sta     CIA2CTR2                ; save CIA 2 CRB

        ldx     #$00                    ; set all inputs
        stx     CIA1DDRB                ; save CIA 1 DDRB, keyboard row
        stx     CIA2DDRB                ; save CIA 2 DDRB, RS232 port
        stx     SIDFMVO                 ; clear the volume and filter select
                                        ; register

        dex                             ; set X = $FF
        stx     CIA1DDRA                ; save CIA 1 DDRA, keyboard column

        lda     #$07                    ; DATA out high, CLK out high, ATN out
                                        ; high, RE232 Tx DATA, high, video
                                        ; address 15 = 1, video address 14 = 1
        sta     CIA2DRA                 ; save CIA 2 DRA, serial port and video
                                        ; address
        lda     #$3F                    ; set serial DATA and serial CLK input
        sta     CIA2DDRA                ; save CIA 2 DDRA, serial port and video
                                        ; address
        lda     #$E7                    ; set 1110 0111, motor off, enable I/O,
                                        ; enable KERNAL, enable BASIC
        sta     P6510                   ; save the 6510 I/O port

        lda     #$2F                    ; set 0010 1111, 0 = input, 1 = output
        sta     D6510                   ; save 6510 I/O port direction register
TimingPalNtsc                           ;                               [FDDD]
.if Version=1
        lda     #$1B
        sta     CIA1TI1L

        lda     #$41
        sta     CIA1TI1H

        lda     #$81
        sta     CIA1IRQ

        lda     CIA1CTR1
        and     #$80
        ora     #$11
        sta     CIA1CTR1

        jmp     IecClockL               ;                               [EE8E]
.else
        lda     PALNTSC                 ; get the PAL/NTSC flag
        beq     A_FDEC                  ; if NTSC go set NTSC timing

; else set PAL timing
        lda     #$25                    ;.
        sta     CIA1TI1L                ; save CIA 1 timer A LB

        lda     #$40                    ;.
        jmp     J_FDF3                  ;.                              [FDF3]

A_FDEC                                  ;                               [FDEC]
        lda     #$95                    ;.
        sta     CIA1TI1L                ; save CIA 1 timer A LB

        lda     #$42                    ;.
J_FDF3                                  ;                               [FDF3]
        sta     CIA1TI1H                ; save CIA 1 timer A HB

        jmp     SetTimerIRQ             ;.                              [FF6E]
.fi


;******************************************************************************
;
; set filename

; this routine is used to set up the filename for the OPEN, SAVE, or LOAD
; routines. The accumulator must be loaded with the length of the file and XY
; with the pointer to filename, X being the LB. The address can be any
; valid memory address in the system where a string of characters for the file
; name is stored. If no filename desired the accumulator must be set to 0,
; representing a zero file length, in that case  XY may be set to any memory
; address.

SetFileName2                            ;                               [FDF9]
        sta     FNLEN                   ; set filename length
        stx     FNADR                   ; set filename pointer LB
        sty     FNADR+1                 ; set filename pointer HB

        rts


;******************************************************************************
;
; set logical, first and second addresses

; this routine will set the logical file number, device address, and secondary
; address, command number, for other KERNAL routines.

; the logical file number is used by the system as a key to the file table
; created by the OPEN file routine. Device addresses can range from 0 to 30.
; The following codes are used by the computer to stand for the following CBM
; devices:

; ADDRESS       DEVICE
; =======       ======
;  0            Keyboard
;  1            Cassette #1
;  2            RS-232C device
;  3            CRT display
;  4            Serial bus printer
;  8            CBM Serial bus disk drive

; device numbers of four or greater automatically refer to devices on the
; serial bus.

; a command to the device is sent as a secondary address on the serial bus
; after the device number is sent during the serial attention handshaking
; sequence. If no secondary address is to be sent Y should be set to $FF.

SetAddresses2                           ;                               [FE00]
        sta     LA                      ; save the logical file
        stx     FA                      ; save the device number
        sty     SA                      ; save the secondary address

        rts


;******************************************************************************
;
; read I/O status word

; this routine returns the current status of the I/O device in the accumulator.
; The routine is usually called after new communication to an I/O device. The
; routine will give information about device status, or errors that have
; occurred during the I/O operation.

ReadIoStatus2                           ;                               [FE07]
        lda     FA                      ; get the device number
        cmp     #$02                    ; compare device with RS232 device
        bne     A_FE1A                  ; if not RS232 device go ??

; get RS232 device status
        lda     RSSTAT                  ; get the RS232 status register
        pha                             ; save the RS232 status value

        lda     #$00                    ; clear A
        sta     RSSTAT                  ; clear the RS232 status register

        pla                             ; restore the RS232 status value
        rts


;******************************************************************************
;
; control kernal messages

; this routine controls the printing of error and control messages by the
; KERNAL. Either print error messages or print control messages can be selected
; by setting the accumulator when the routine is called.

; FILE NOT FOUND is an example of an error message. PRESS PLAY ON CASSETTE is
; an example of a control message.

; bits 6 and 7 of this value determine where the message will come from. If bit
; 7 is set one of the error messages from the KERNAL will be printed. If bit 6
; is set a control message will be printed.

CtrlKernalMsg2                          ;                               [FE18]
        sta     MSGFLG                  ; set message mode flag
A_FE1A                                  ;                               [FE1A]
        lda     STATUS                  ; read the serial status byte


;******************************************************************************
;
; OR into the serial status byte

AorIecStatus                            ;                               [FE1C]
        ora     STATUS                  ; OR with the serial status byte
        sta     STATUS                  ; save the serial status byte

        rts


;******************************************************************************
;
; set timeout on serial bus

; this routine sets the timeout flag for the serial bus. When the timeout flag
; is set, the computer will wait for a device on the serial port for 64
; milliseconds. If the device does not respond to the computer's DAV signal
; within that time the computer will recognize an error condition and leave the
; handshake sequence. When this routine is called and the accumulator contains
; a 0 in bit 7, timeouts are enabled. A 1 in bit 7 will disable the timeouts.

; NOTE: The the timeout feature is used to communicate that a disk file is not
; found on an attempt to OPEN a file.

IecTimeout2                             ;                               [FE21]
        sta     TIMOUT                  ; save serial bus timeout flag

        rts


;******************************************************************************
;
; read/set the top of memory, Cb = 1 to read, Cb = 0 to set

; this routine is used to read and set the top of RAM. When this routine is
; called with the carry bit set the pointer to the top of RAM will be loaded
; into XY. When this routine is called with the carry bit clear XY will be
; saved as the top of memory pointer changing the top of memory.

TopOfMem2                               ;                               [FE25]
        bcc     SetTopOfMem2            ; if Cb clear go set the top of memory


;******************************************************************************
;
; read the top of memory

ReadTopOfMem                            ;                               [FE27]
        ldx     EndOfMem                ; get memory top LB
        ldy     EndOfMem+1              ; get memory top HB


;******************************************************************************
;
; set the top of memory

SetTopOfMem2                            ;                               [FE2D]
        stx     EndOfMem                ; set memory top LB
        sty     EndOfMem+1              ; set memory top HB

        rts


;******************************************************************************
;
; read/set the bottom of memory, Cb = 1 to read, Cb = 0 to set

; this routine is used to read and set the bottom of RAM. When this routine is
; called with the carry bit set the pointer to the bottom of RAM will be loaded
; into XY. When this routine is called with the carry bit clear XY will be
; saved as the bottom of memory pointer changing the bottom of memory.

BottomOfMem2                            ;                               [FE34]
        bcc     A_FE3C                  ; if Cb clear go set bottom of memory

        ldx     StartOfMem              ; get the OS start of memory LB
        ldy     StartOfMem+1            ; get the OS start of memory HB

; set the bottom of memory

A_FE3C                                  ;                               [FE3C]
        stx     StartOfMem              ; save the OS start of memory LB
        sty     StartOfMem+1            ; save the OS start of memory HB

        rts


;******************************************************************************
;
; NMI vector

NMI_routine                             ;                               [FE43]
        sei                             ; disable the interrupts

        jmp     (NMINV)                 ; do NMI vector


;******************************************************************************
;
; NMI handler

NMI_vector                              ;                               [FE47]
        pha                             ; save A

        txa                             ; copy X
        pha                             ; save X

        tya                             ; copy Y
        pha                             ; save Y

        lda     #$7F                    ; disable all interrupts
        sta     CIA2IRQ                 ; save CIA 2 ICR

        ldy     CIA2IRQ                 ; NMI from RS-232 ?
        bmi     RS232_NMI               ; yes, ->

        jsr     Chk4Cartridge           ; scan for autostart ROM at $8000 [FD02]
        bne     A_FE5E                  ; branch if no autostart ROM

        jmp     (RomIRQ)                ; else do autostart ROM break entry

A_FE5E                                  ;                               [FE5E]
        jsr     IncrClock22             ; increment real time clock     [F6BC]

        jsr     ScanStopKey             ; scan stop key                 [FFE1]
        bne     RS232_NMI               ; if not [STOP] restore registers and
                                        ; exit interrupt


;******************************************************************************
;
; user function default vector
; BRK handler

BRK_vector                              ;                               [FE66]
        jsr     SetVectorsIO2           ; restore default I/O vectors   [FD15]
        jsr     InitSidCIAIrq2          ; initialise SID, CIA and IRQ   [FDA3]
        jsr     InitScreenKeyb          ; initialise the screen and keyboard
                                        ;                               [E518]
        jmp     (BasicNMI)              ; do BASIC break entry


;******************************************************************************
;
; RS232 NMI routine

RS232_NMI                               ;                               [FE72]
        tya                             ;.
        and     ENABL                   ; AND with RS-232 interrupt enable byte
        tax                             ;.

        and     #$01                    ;.
        beq     A_FEA3                  ;.

        lda     CIA2DRA                 ; read CIA 2 DRA, serial port and video
                                        ; address
        and     #$FB                    ; mask x0xx, clear RS232 Tx DATA
        ora     NXTBIT                  ; OR in the RS232 transmit data bit
        sta     CIA2DRA                 ; save CIA 2 DRA, serial port and video
                                        ; address
        lda     ENABL                   ; get RS-232 interrupt enable byte
        sta     CIA2IRQ                 ; save CIA 2 ICR

        txa                             ;.
        and     #$12                    ;.
        beq     J_FE9D                  ;.

        and     #$02                    ;.
        beq     A_FE9A                  ;.

        jsr     ReadFromRS232           ;.                              [FED6]
        jmp     J_FE9D                  ;.                              [FE9D]

A_FE9A                                  ;                               [FE9A]
        jsr     WriteToRS232            ;.                              [FF07]
J_FE9D                                  ;                               [FE9D]
        jsr     RS232_TX_NMI            ;.                              [EEBB]
        jmp     J_FEB6                  ;.                              [FEB6]

A_FEA3                                  ;                               [FEA3]
        txa                             ; get active interrupts back
        and     #$02                    ; mask ?? interrupt
        beq     A_FEAE                  ; branch if not ?? interrupt

; was ?? interrupt
        jsr     ReadFromRS232           ;.                              [FED6]
        jmp     J_FEB6                  ;.                              [FEB6]

A_FEAE                                  ;                               [FEAE]
        txa                             ; get active interrupts back
        and     #$10                    ; mask CB1 interrupt, Rx data bit
                                        ; transition
        beq     J_FEB6                  ; if no bit restore registers and exit
                                        ; interrupt
        jsr     WriteToRS232            ;.                              [FF07]
J_FEB6                                  ;                               [FEB6]
        lda     ENABL                   ; get RS-232 interrupt enable byte
        sta     CIA2IRQ                 ; save CIA 2 ICR
End_RS232_NMI                           ;                               [FEBC]
        pla                             ; pull Y
        tay                             ; restore Y

        pla                             ; pull X
        tax                             ; restore X

        pla                             ; restore A

        rti


;******************************************************************************
;
; baud rate word is calculated from ..
;
; (system clock / baud rate) / 2 - 100
;
;               system clock
;               ------------
; PAL             985248 Hz
; NTSC           1022727 Hz

; baud rate tables for NTSC C64

TblBaudNTSC                             ;                               [FEC2]
.if Version=1
.byte $AC, $26, $A7, $19, $5D, $11, $1F, $0E
.byte $A1, $0C, $1F, $06, $DD, $02, $3D, $01
.byte $B2, $00, $6C, $00
.else
.word   $27C1                           ;   50   baud   1027700
.word   $1A3E                           ;   75   baud   1022700
.word   $11C5                           ;  110   baud   1022780
.word   $0E74                           ;  134.5 baud   1022200
.word   $0CED                           ;  150   baud   1022700
.word   $0645                           ;  300   baud   1023000
.word   $02F0                           ;  600   baud   1022400
.word   $0146                           ; 1200   baud   1022400
.word   $00B8                           ; 1800   baud   1022400
.word   $0071                           ; 2400   baud   1022400
.fi


;******************************************************************************
;
; Read from RS-232

ReadFromRS232                           ;                               [FED6]
        lda     CIA2DRB                 ; read CIA 2 DRB, RS232 port
        and     #$01                    ; mask 0000 000x, RS232 Rx DATA
        sta     INBIT                   ; save the RS232 received data bit

        lda     CIA2TI2L                ; get CIA 2 timer B LB
        sbc     #$1C                    ;.
        adc     BAUDOF                  ;.
        sta     CIA2TI2L                ; save CIA 2 timer B LB

        lda     CIA2TI2H                ; get CIA 2 timer B HB
        adc     BAUDOF+1                ;.
        sta     CIA2TI2H                ; save CIA 2 timer B HB

        lda     #$11                    ; set timer B single shot, start timer B
        sta     CIA2CTR2                ; save CIA 2 CRB

        lda     ENABL                   ; get RS-232 interrupt enable byte
        sta     CIA2IRQ                 ; save CIA 2 ICR

        lda     #$FF                    ;.
        sta     CIA2TI2L                ; save CIA 2 timer B LB
        sta     CIA2TI2H                ; save CIA 2 timer B HB

        jmp     RS232_RX_NMI            ;.                              [EF59]



;******************************************************************************
;
; Write to RS-232

WriteToRS232                            ;                               [FF07]
.if Version=1
        lda     M51CTR
        and     #$0F
        bne     A_FF1A

        lda     M51AJB
        sta     CIA2TI2L

        lda     M51AJB+1
        jmp     J_FF25                  ;                               [FF25]

A_FF1A                                  ;                               [FF1A]
        asl     A
        tax
        lda     TblBaudNTSC-2,X
        sta     CIA2TI2L

        lda     TblBaudNTSC-1,X
J_FF25                                  ;                               [FF25]
        sta     CIA2TI2H

        lda     #$11
        sta     CIA2CTR2

        lda     #$12
        eor     ENABL
        sta     ENABL

        lda     #$FF
        sta     CIA2TI2L
        sta     CIA2TI2H

        ldx     BITNUM
        stx     BITCI

        rts
.else
        lda     M51AJB                  ; nonstandard bit timing LB
        sta     CIA2TI2L                ; save CIA 2 timer B LB

        lda     M51AJB+1                ; nonstandard bit timing HB
        sta     CIA2TI2H                ; save CIA 2 timer B HB

        lda     #$11                    ; set timer B single shot, start timer B
        sta     CIA2CTR2                ; save CIA 2 CRB

        lda     #$12                    ;.
        eor     ENABL                   ; EOR with RS-232 interrupt enable byte
        sta     ENABL                   ; save RS-232 interrupt enable byte

        lda     #$FF                    ;.
        sta     CIA2TI2L                ; save CIA 2 timer B LB
        sta     CIA2TI2H                ; save CIA 2 timer B HB

        ldx     BITNUM                  ;.
        stx     BITCI                   ;.

        rts


;******************************************************************************
;
; Set the timer for the Baud rate

SetTimerBaudR                           ;                               [FF2E]
        tax                             ;.

        lda     M51AJB+1                ; nonstandard bit timing HB
        rol                             ;.
        tay                             ;.

        txa                             ;.
        adc     #$C8                    ;.
        sta     BAUDOF                  ;.

        tya                             ;.
        adc     #$00                    ; add any carry
        sta     BAUDOF+1                ;.

        rts


;******************************************************************************
;
; unused bytes

;S_FF41
        nop                             ; waste cycles
        nop                             ; waste cycles
.fi


;******************************************************************************
;
; save the status and do the IRQ routine

SaveStatGoIRQ                           ;                               [FF43]
        php                             ; save the processor status

        pla                             ; pull the processor status
        and     #$EF                    ; mask xxx0, clear the break bit
        pha                             ; save the modified processor status


;******************************************************************************
;
; IRQ vector

IRQ_routine                             ;                               [FF48]
        pha                             ; save A

        txa                             ; copy X
        pha                             ; save X

        tya                             ; copy Y
        pha                             ; save Y

        tsx                             ; copy stack pointer
        lda     STACK+4,X               ; get stacked status register
        and     #$10                    ; mask BRK flag
        beq     A_FF58                  ; branch if not BRK

        jmp     (BINV)                  ; else do BRK vector (iBRK)

A_FF58                                  ;                               [FF58]
        jmp     (CINV)                  ; do IRQ vector (iIRQ)


.if Version=1
.fill 38,$AA                            ;                               [FF5B]

 
InitialiseVIC                           ;                               [FF81]
        jmp     InitScreenKeyb          ;                               [E518]
.else
;******************************************************************************
;
; initialise VIC and screen editor

InitialiseVIC2                          ;                               [FF5B]
        jsr     InitScreenKeyb          ; initialise the screen and keyboard
                                        ;                               [E518]
A_FF5E                                  ;                               [FF5E]
        lda     VICLINE                 ; read the raster compare register
        bne     A_FF5E                  ; loop if not raster line $00
A_FF63                                  ;                               [FF63]
        lda     VICIRQ                  ; read the vic interrupt flag register
        and     #$01                    ; mask the raster compare flag
        sta     PALNTSC                 ; save the PAL/NTSC flag
        jmp     TimingPalNtsc           ;.                              [FDDD]


;******************************************************************************
;
; Set the timer that generates the interrupts

SetTimerIRQ                             ;                               [FF6E]
        lda     #$81                    ; enable timer A interrupt
        sta     CIA1IRQ                 ; save CIA 1 ICR

        lda     CIA1CTR1                ; read CIA 1 CRA
        and     #$80                    ; mask x000 0000, TOD clock
        ora     #$11                    ; mask xxx1 xxx1, load timer A, start
                                        ; timer A
        sta     CIA1CTR1                ; save CIA 1 CRA

        jmp     IecClockL               ; set the serial clock out low and
                                        ; return                        [EE8E]


.if Version=3
FF80    .byte   $03                     ; unused byte ??
.else
FF80    .byte   $00                     ; unused byte ??
.fi


;******************************************************************************
;
; initialise VIC and screen editor

InitialiseVIC                           ;                               [FF81]
        jmp     InitialiseVIC2          ; initialise VIC and screen editor
.fi


;******************************************************************************
;
; initialise SID, CIA and IRQ, unused

InitSidCIAIrq                           ;                               [FF84]
        jmp     InitSidCIAIrq2          ; initialise SID, CIA and IRQ   [FDA3]


;******************************************************************************
;
; RAM test and find RAM end

;F_FF87                                 ;                               [FF87]
        jmp     TestRAM2                ; RAM test and find RAM end     [FD50]


;******************************************************************************
;
; restore default I/O vectors

; this routine restores the default values of all system vectors used in KERNAL
; and BASIC routines and interrupts.

SetVectorsIO                            ;                               [FF8A]
        jmp     SetVectorsIO2           ; restore default I/O vectors   [FD15]


;******************************************************************************
;
; read/set vectored I/O

; this routine manages all system vector jump addresses stored in RAM. Calling
; this routine with the carry bit set will store the current contents of the
; RAM vectors in a list pointed to by the X and Y registers. When this routine
; is called with the carry bit clear, the user list pointed to by the X and Y
; registers is copied to the system RAM vectors.

; NOTE: This routine requires caution in its use. The best way to use it is to
; first read the entire vector contents into the user area, alter the desired
; vectors and then copy the contents back to the system vectors.

CopyVectorsIO                           ;                               [FF8D]
        jmp     CopyVectorsIO2          ; read/set vectored I/O         [FD1A]


;******************************************************************************
;
; control kernal messages

; this routine controls the printing of error and control messages by the
; KERNAL. Either print error messages or print control messages can be selected
; by setting the accumulator when the routine is called.

; FILE NOT FOUND is an example of an error message. PRESS PLAY ON CASSETTE is
; an example of a control message.

; bits 6 and 7 of this value determine where the message will come from. If bit
; 7 is set one of the error messages from the KERNAL will be printed. If bit 6
; is set a control message will be printed.

CtrlKernalMsg                           ;                               [FF90]
        jmp     CtrlKernalMsg2          ; control kernal messages       [FE18]


;******************************************************************************
;
; send secondary address after LISTEN

; this routine is used to send a secondary address to an I/O device after a
; call to the LISTEN routine is made and the device commanded to LISTEN. The
; routine cannot be used to send a secondary address after a call to the TALK
; routine.

; A secondary address is usually used to give set-up information to a device
; before I/O operations begin.

; When a secondary address is to be sent to a device on the serial bus the
; address must first be ORed with $60.

SAafterLISTEN                           ;                               [FF93]
        jmp     SAafterLISTEN2          ; send secondary address after LISTEN
                                        ;       [EDB9]

;******************************************************************************
;
; send secondary address after TALK

; this routine transmits a secondary address on the serial bus for a TALK
; device. This routine must be called with a number between 4 and 31 in the
; accumulator. The routine will send this number as a secondary address command
; over the serial bus. This routine can only be called after a call to the TALK
; routine. It will not work after a LISTEN.

SAafterTALK                             ;                               [FF96]
        jmp     SAafterTALK2            ; send secondary address after TALK
                                        ;                               [EDC7]

;******************************************************************************
;
; read/set the top of memory

; this routine is used to read and set the top of RAM. When this routine is
; called with the carry bit set the pointer to the top of RAM will be loaded
; into XY. When this routine is called with the carry bit clear XY will be
; saved as the top of memory pointer changing the top of memory.

TopOfMem                                ;                               [FF99]
        jmp     TopOfMem2               ; read/set the top of memory    [FE25]


;******************************************************************************
;
; read/set the bottom of memory

; this routine is used to read and set the bottom of RAM. When this routine is
; called with the carry bit set the pointer to the bottom of RAM will be loaded
; into XY. When this routine is called with the carry bit clear XY will be
; saved as the bottom of memory pointer changing the bottom of memory.

BottomOfMem                             ;                               [FF9C]
        jmp     BottomOfMem2            ; read/set the bottom of memory [FE34]


;******************************************************************************
;
; scan the keyboard

; this routine will scan the keyboard and check for pressed keys. It is the
; same routine called by the interrupt handler. If a key is down, its ASCII
; value is placed in the keyboard queue.

ScanKeyboard                            ;                               [FF9F]
        jmp     ScanKeyboard2           ; scan keyboard                 [EA87]


;******************************************************************************
;
; set timeout on serial bus

; this routine sets the timeout flag for the serial bus. When the timeout flag
; is set, the computer will wait for a device on the serial port for 64
; milliseconds. If the device does not respond to the computer's DAV signal
; within that time the computer will recognize an error condition and leave the
; handshake sequence. When this routine is called and the accumulator contains
; a 0 in bit 7, timeouts are enabled. A 1 in bit 7 will disable the timeouts.

; NOTE: The the timeout feature is used to communicate that a disk file is not
; found on an attempt to OPEN a file.

IecTimeout                              ;                               [FFA2]
        jmp     IecTimeout2             ; set timeout on serial bus     [FE21]


;******************************************************************************
;
; input byte from serial bus
;
; this routine reads a byte of data from the serial bus using full handshaking.
; the data is returned in the accumulator. before using this routine the TALK
; routine, $FFB4, must have been called first to command the device on the
; serial bus to send data on the bus. if the input device needs a secondary
; command it must be sent by using the TKSA routine, $FF96, before calling
; this routine.
; errors are returned in the status word which can be read by calling the
; READST routine, ReadIoStatus.

IecByteIn                               ;                               [FFA5]
        jmp     IecByteIn2              ; input byte from serial bus    [EE13]


;******************************************************************************
;
; output a byte to serial bus

; this routine is used to send information to devices on the serial bus. A call
; to this routine will put a data byte onto the serial bus using full
; handshaking. Before this routine is called the LISTEN routine, F_FFB1, must
; be used to command a device on the serial bus to get ready to receive data.

; the accumulator is loaded with a byte to output as data on the serial bus. A
; device must be listening or the status word will return a timeout. This
; routine always buffers one character. So when a call to the UNLISTEN routine,
; F_FFAE, is made to end the data transmission, the buffered character is
; sent with EOI set. Then the UNLISTEN command is sent to the device.

IecByteOut                              ;                               [FFA8]
        jmp     IecByteOut2             ; output byte to serial bus     [EDDD]


;******************************************************************************
;
; command serial bus to UNTALK

; this routine will transmit an UNTALK command on the serial bus. All devices
; previously set to TALK will stop sending data when this command is received.

IecUNTALK                               ;                               [FFAB]
        jmp     IecUNTALK2              ; command serial bus to UNTALK  [EDEF]


;******************************************************************************
;
; command serial bus to UNLISTEN

; this routine commands all devices on the serial bus to stop receiving data
; from the computer. Calling this routine results in an UNLISTEN command being
; transmitted on the serial bus. Only devices previously commanded to listen
; will be affected.

; This routine is normally used after the computer is finished sending data to
; external devices. Sending the UNLISTEN will command the listening devices to
; get off the serial bus so it can be used for other purposes.

IecUNLISTEN                             ;                               [FFAE]
        jmp     IecUNLISTEN2            ; command serial bus to UNLISTEN [EDFE]


;******************************************************************************
;
; command devices on the serial bus to LISTEN

; this routine will command a device on the serial bus to receive data. The
; accumulator must be loaded with a device number between 4 and 31 before
; calling this routine. LISTEN convert this to a listen address then transmit
; this data as a command on the serial bus. The specified device will then go
; into listen mode and be ready to accept information.

CmdLISTEN                               ;                               [FFB1]
        jmp     CmdLISTEN2              ; command devices on the serial bus to
                                        ; LISTEN                        [ED0C]

;******************************************************************************
;
; command serial bus device to TALK

; to use this routine the accumulator must first be loaded with a device number
; between 4 and 30. When called this routine converts this device number to a
; talk address. Then this data is transmitted as a command on the Serial bus.

CmdTALK                                 ;                               [FFB4]
        jmp     CmdTALK2                ; command serial bus device to TALK
                                        ;                               [ED09]

;******************************************************************************
;
; read I/O status word

; this routine returns the current status of the I/O device in the accumulator.
; The routine is usually called after new communication to an I/O device. The
; routine will give information about device status, or errors that have
; occurred during the I/O operation.

ReadIoStatus                            ;                               [FFB7]
        jmp     ReadIoStatus2           ; read I/O status word          [FE07]


;******************************************************************************
;
; set logical, first and second addresses

; this routine will set the logical file number, device address, and secondary
; address, command number, for other KERNAL routines.

; the logical file number is used by the system as a key to the file table
; created by the OPEN file routine. Device addresses can range from 0 to 30.
; The following codes are used by the computer to stand for the following CBM
; devices:

; ADDRESS       DEVICE
; =======       ======
;  0            Keyboard
;  1            Cassette #1
;  2            RS-232C device
;  3            CRT display
;  4            Serial bus printer
;  8            CBM Serial bus disk drive

; device numbers of four or greater automatically refer to devices on the
; serial bus.

; a command to the device is sent as a secondary address on the serial bus
; after the device number is sent during the serial attention handshaking
; sequence. If no secondary address is to be sent Y should be set to $FF.

SetAddresses                            ;                               [FFBA]
        jmp     SetAddresses2           ; set logical, first and second
                                        ; addresses                     [FE00]

;******************************************************************************
;
; set the filename

; this routine is used to set up the filename for the OPEN, SAVE, or LOAD
; routines. The accumulator must be loaded with the length of the file and XY
; with the pointer to filename, X being th LB. The address can be any
; valid memory address in the system where a string of characters for the file
; name is stored. If no filename desired the accumulator must be set to 0,
; representing a zero file length, in that case  XY may be set to any memory
; address.

SetFileName                             ;                               [FFBD]
        jmp     SetFileName2            ; set the filename              [FDF9]


;******************************************************************************
;
; open a logical file

; this routine is used to open a logical file. Once the logical file is set up
; it can be used for input/output operations. Most of the I/O KERNAL routines
; call on this routine to create the logical files to operate on. No arguments
; need to be set up to use this routine, but both the SETLFS, SetAddresses, and
; SETNAM, SetFileName, KERNAL routines must be called before using this routine.

OpenLogFile                             ;                               [FFC0]
        jmp     (IOPEN)                 ; do open a logical file


;******************************************************************************
;
; close a specified logical file

; this routine is used to close a logical file after all I/O operations have
; been completed on that file. This routine is called after the accumulator is
; loaded with the logical file number to be closed, the same number used when
; the file was opened using the OPEN routine.

CloseLogFile                            ;                               [FFC3]
        jmp     (ICLOSE)                ; do close a specified logical file


;******************************************************************************
;
; open channel for input

; any logical file that has already been opened by the OPEN routine,
; OpenLogFile, can be defined as an input channel by this routine. the device
; on the channel must be an input device or an error will occur and the routine
; will abort.
;
; if you are getting data from anywhere other than the keyboard, this routine
; must be called before using either the CHRIN routine, ByteFromChan, or the
; GETIN; routine, GetCharInpDev. if you are getting data from the keyboard and
; no other input channels are open then the calls to this routine and to the
; OPEN routine, OpenLogFile, are not needed.
; when used with a device on the serial bus this routine will automatically
; send the listen address specified by the OPEN routine, OpenLogFile, and any
; secondary address.
; possible errors are:
;
;       3 : file not open
;       5 : device not present
;       6 : file is not an input file

OpenChan4Inp                            ;                               [FFC6]
        jmp     (ICHKIN)                ; do open channel for input


;******************************************************************************
;
; open channel for output

; any logical file that has already been opened by the OPEN routine,
; OpenLogFile, can be defined as an output channel by this routine the device
; on the channel must be an output device or an error will occur and the
; routine will abort.
;
; if you are sending data to anywhere other than the screen this routine must
; be called before using the CHROUT routine, OutByteChan. if you are sending
; data to the screen and no other output channels are open then the calls to
; this routine and to the OPEN routine, OpenLogFile, are not needed.
;
; when used with a device on the serial bus this routine will automatically
; send the listen address specified by the OPEN routine, OpenLogFile, and any
; secondary address.
; possible errors are:
;
;       3 : file not open
;       5 : device not present
;       7 : file is not an output file

OpenChan4Outp                           ;                               [FFC9]
        jmp     (ICKOUT)                ; do open channel for output


;******************************************************************************
;
; close input and output channels

; this routine is called to clear all open channels and restore the I/O
; channels to their original default values. It is usually called after opening
; other I/O channels and using them for input/output operations. The default
; input device is 0, the keyboard. The default output device is 3, the screen.

; If one of the channels to be closed is to the serial port, an UNTALK signal
; is sent first to clear the input channel or an UNLISTEN is sent to clear the
; output channel. By not calling this routine and leaving listener(s) active on
; the serial bus, several devices can receive the same data from the VIC at the
; same time. One way to take advantage of this would be to command the printer
; to TALK and the disk to LISTEN. This would allow direct printing of a disk
; file.

CloseIoChannls                          ;                               [FFCC]
        jmp     (ICLRCH)                ; do close input and output channels


;******************************************************************************
;
; input character from channel

; this routine will get a byte of data from the channel already set up as the
; input channel by the CHKIN routine, OpenChan4Inp.
;
; If CHKIN, OpenChan4Inp, has not been used to define another input channel the
; data is expected to be from the keyboard. the data byte is returned in the
; accumulator. the channel remains open after the call.
;
; input from the keyboard is handled in a special way. first, the cursor is
; turned on and it will blink until a carriage return is typed on the keyboard.
; all characters on the logical line, up to 80 characters, will be stored in
; the BASIC input buffer. then the characters can be returned one at a time by
; calling this routine once for each character. when the carriage return is
; returned the entire line has been processed. the next time this routine is
; called the whole process begins again.

ByteFromChan                            ;                               [FFCF]
        jmp     (IBASIN)                ; do input character from channel


;******************************************************************************
;
; output character to channel

; this routine will output a character to an already opened channel. Use the
; OPEN routine, OpenLogFile, and the CHKOUT routine, OpenChan4Outp, to set up
; the output channel before calling this routine. If these calls are omitted,
; data will be sent to the default output device, device 3, the screen. The data
; byte to be output is loaded into the accumulator, and this routine is called.
; The data is then sent to the specified output device. The channel is left
; open after the call.

; NOTE: Care must be taken when using routine to send data to a serial device
; since data will be sent to all open output channels on the bus. Unless this
; is desired, all open output channels on the serial bus other than the
; actually intended destination channel must be closed by a call to the KERNAL
; close channel routine.

OutByteChan                             ;                               [FFD2]
        jmp     (IBSOUT)                ; do output character to channel


;******************************************************************************
;
; load RAM from a device

; this routine will load data bytes from any input device directly into the
; memory of the computer. It can also be used for a verify operation comparing
; data from a device with the data already in memory, leaving the data stored
; in RAM unchanged.

; The accumulator must be set to 0 for a load operation or 1 for a verify. If
; the input device was OPENed with a secondary address of 0 the header
; information from device will be ignored. In this case XY must contain the
; starting address for the load. If the device was addressed with a secondary
; address of 1 or 2 the data will load into memory starting at the location
; specified by the header. This routine returns the address of the highest RAM
; location which was loaded.

; Before this routine can be called, the SETLFS, SetAddresses, and SETNAM,
; SetFileName, routines must be called.

LoadRamFrmDev                           ;                               [FFD5]
        jmp     LoadRamFrmDev2          ; load RAM from a device        [F49E]


;******************************************************************************
;
; save RAM to a device

; this routine saves a section of memory. Memory is saved from an indirect
; address on page 0 specified by A, to the address stored in XY, to a logical
; file. The SETLFS, SetAddresses, and SETNAM, SetFileName, routines must be used
; before calling this routine. However, a filename is not required to SAVE to
; device 1, the cassette. Any attempt to save to other devices without using a
; filename results in an error.

; NOTE: device 0, the keyboard, and device 3, the screen, cannot be SAVEd to.
; If the attempt is made, an error will occur, and the SAVE stopped.

SaveRamToDev                            ;                               [FFD8]
        jmp     SaveRamToDev2           ; save RAM to device            [F5DD]


;******************************************************************************
;
; set the real time clock

; the system clock is maintained by an interrupt routine that updates the clock
; every 1/60th of a second. The clock is three bytes long which gives the
; capability to count from zero up to 5,184,000 jiffies - 24 hours plus one
; jiffy. At that point the clock resets to zero. Before calling this routine to
; set the clock the new time, in jiffies, should be in YXA, the accumulator
; containing the most significant byte.

SetClock                                ;                               [FFDB]
        jmp     SetClock2               ; set real time clock           [F6E4]


;******************************************************************************
;
; read the real time clock

; this routine returns the time, in jiffies, in AXY. The accumulator contains
; the most significant byte.

ReadClock                               ;                               [FFDE]
        jmp     ReadClock2              ; read real time clock          [F6DD]


;******************************************************************************
;
; scan the stop key

; if the STOP key on the keyboard is pressed when this routine is called the Z
; flag will be set. All other flags remain unchanged. If the STOP key is not
; pressed then the accumulator will contain a byte representing the last row of
; the keyboard scan.

; The user can also check for certain other keys this way.

ScanStopKey                             ;                               [FFE1]
        jmp     (ISTOP)                 ; do scan stop key


;******************************************************************************
;
; get character from input device

; in practice this routine operates identically to the CHRIN routine,
; ByteFromChan, for all devices except for the keyboard. If the keyboard is the
; current input device this routine will get one character from the keyboard
; buffer. It depends on the IRQ routine to read the keyboard and put characters
; into the buffer.

; If the keyboard buffer is empty the value returned in the accumulator will be
; zero.

GetCharInpDev                           ;                               [FFE4]
        jmp     (IGETIN)                ; do get character from input device


;******************************************************************************
;
; close all channels and files

; this routine closes all open files. When this routine is called, the pointers
; into the open file table are reset, closing all files. Also the routine
; automatically resets the I/O channels.

CloseAllChan                            ;                               [FFE7]
        jmp     (ICLALL)                ; do close all channels and files


;******************************************************************************
;
; increment real time clock

; this routine updates the system clock. Normally this routine is called by the
; normal KERNAL interrupt routine every 1/60th of a second. If the user program
; processes its own interrupts this routine must be called to update the time.
; Also, the STOP key routine must be called if the stop key is to remain
; functional.

IncrClock                               ;                               [FFEA]
        jmp     IncrClock2              ; increment real time clock     [F69B]


;******************************************************************************
;
; return X,Y organization of screen

; this routine returns the x,y organisation of the screen in X,Y

GetSizeScreen                           ;                               [FFED]
        jmp     GetSizeScreen2          ; return X,Y organization of screen
                                        ;                               [E505]


;******************************************************************************
;
; read/set X,Y cursor position

; this routine, when called with the carry flag set, loads the current position
; of the cursor on the screen into the X and Y registers. X is the column
; number of the cursor location and Y is the row number of the cursor. A call
; with the carry bit clear moves the cursor to the position determined by the X
; and Y registers.

CursorPosXY                             ;                               [FFF0]
        jmp     CursorPosXY2            ; read/set X,Y cursor position  [E50A]


;******************************************************************************
;
; return the base address of the I/O devices

; this routine will set XY to the address of the memory section where the
; memory mapped I/O devices are located. This address can then be used with an
; offset to access the memory mapped I/O devices in the computer.

GetAddrIoDevs                           ;                               [FFF3]
        jmp     GetAddrIoDevs2          ; return the base address of the I/O
                                        ; devices                       [E500]

;******************************************************************************
;

;S_FFF6
.text   "RRBY"

; hardware vectors

;S_FFFA
.word   NMI_routine                     ; NMI vector                    [FE43]
.word   RESET_routine                   ; RESET vector                  [FCE2]
.word   IRQ_routine                     ; IRQ vector                    [FF48]


;******************************************************************************


