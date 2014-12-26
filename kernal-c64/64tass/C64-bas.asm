;******************************************************************************
;******************************************************************************
;
; The almost completely commented C64 ROM disassembly. V1.01 Lee Davison 2012
;

;******************************************************************************
;
; start of the BASIC ROM
;
; version 901227-01
;

*=      $A000

BasicCold 
.word   BasicColdStart                  ; BASIC cold start entry point
BasicNMI 
.word   BasicWarmStart                  ; BASIC warm start entry point

;A_A004
.text   "CBMBASIC"                      ; ROM name, unreferenced


;******************************************************************************
;
; action addresses for primary commands. these are called by pushing the
; address onto the stack and doing an RTS so the actual address -1 needs to be
; pushed

TblBasicInstr                           ;                               [A00C]
.word   bcEND-1                         ; perform END           $80
.word   bcFOR-1                         ; perform FOR           $81
.word   bcNEXT-1                        ; perform NEXT          $82
.word   bcDATA-1                        ; perform DATA          $83
.word   bcINPUTH-1                      ; perform INPUT#        $84
.word   bcINPUT-1                       ; perform INPUT         $85
.word   bcDIM-1                         ; perform DIM           $86
.word   bcREAD-1                        ; perform READ          $87

.word   bcLET-1                         ; perform LET           $88
.word   bcGOTO-1                        ; perform GOTO          $89
.word   bcRUN-1                         ; perform RUN           $8A
.word   bcIF-1                          ; perform IF            $8B
.word   bcRESTORE-1                     ; perform RESTORE       $8C
.word   bcGOSUB-1                       ; perform GOSUB         $8D
.word   bcRETURN-1                      ; perform RETURN        $8E
.word   bcREM-1                         ; perform REM           $8F

.word   bcSTOP-1                        ; perform STOP          $90
.word   bcON-1                          ; perform ON            $91
.word   bcWAIT-1                        ; perform WAIT          $92
.word   bcLOAD-1                        ; perform LOAD          $93
.word   bcSAVE-1                        ; perform SAVE          $94
.word   bcVERIFY-1                      ; perform VERIFY        $95
.word   bcDEF-1                         ; perform DEF           $96
.word   bcPOKE-1                        ; perform POKE          $97

.word   bcPRINTH-1                      ; perform PRINT#        $98
.word   bcPRINT-1                       ; perform PRINT         $99
.word   bcCONT-1                        ; perform CONT          $9A
.word   bcLIST-1                        ; perform LIST          $9B
.word   bcCLR-1                         ; perform CLR           $9C
.word   bcCMD-1                         ; perform CMD           $9D
.word   bcSYS-1                         ; perform SYS           $9E
.word   bcOPEN-1                        ; perform OPEN          $9F

.word   bcCLOSE-1                       ; perform CLOSE         $A0
.word   bcGET-1                         ; perform GET           $A1
.word   bcNEW-1                         ; perform NEW           $A2


;******************************************************************************
;
; action addresses for functions

TblFunctions                            ;                               [A052]
.word   bcSGN                           ; perform SGN()         $B4
.word   bcINT                           ; perform INT()         $B5
.word   bcABS                           ; perform ABS()         $B6
.word   UserJump                        ; perform USR()         $B7

.word   bcFRE                           ; perform FRE()         $B8
.word   bcPOS                           ; perform POS()         $B9
.word   bcSQR                           ; perform SQR()         $BA
.word   bcRND                           ; perform RND()         $BB
.word   bcLOG                           ; perform LOG()         $BC
.word   bcEXP                           ; perform EXP()         $BD
.word   bcCOS                           ; perform COS()         $BE
.word   bcSIN                           ; perform SIN()         $BF

.word   bcTAN                           ; perform TAN()         $C0
.word   bcATN                           ; perform ATN()         $C1
.word   bcPEEK                          ; perform PEEK()        $C2
.word   bcLEN                           ; perform LEN()         $C3
.word   bcSTR                           ; perform STR$()        $C4
.word   bcVAL                           ; perform VAL()         $C5
.word   bcASC                           ; perform ASC()         $C6
.word   bcCHR                           ; perform CHR$()        $C7

.word   bcLEFT                          ; perform LEFT$()       $C8
.word   bcRIGHT                         ; perform RIGHT$()      $C9
.word   bcMID                           ; perform MID$()        $CA


;******************************************************************************
;
; precedence byte and action addresses for operators. like the primarry
; commands these are called by pushing the address onto the stack and doing an
; RTS, so again the actual address -1 needs to be pushed

HierachyCode                            ;                               [A080]
.byte   $79
.word   bcPLUS-1                        ; +
.byte   $79
.word   bcMINUS-1                       ; -
.byte   $7B
.word   bcMULTIPLY-1                    ; *
.byte   $7B
.word   bcDIVIDE-1                      ; /
.byte   $7F
.word   bcPOWER-1                       ; ^
.byte   $50
.word   bcAND-1                         ; AND
.byte   $46
.word   bcOR-1                          ; OR
.byte   $7D
.word   bcGREATER-1                     ; >
.byte   $5A
.word   bcEQUAL-1                       ; =
.byte   $64
.word   bcSMALLER-1                     ; <


;******************************************************************************
;
; BASIC keywords. each word has bit 7 set in it's last character as an end
; marker, even the one character keywords such as "<" or "="

; first are the primary command keywords, only these can start a statement

TblBasicCodes                           ;                               [A09E]
D_A09E          .shift 'END'            ; END           $80             128
D_A0A1          .shift 'FOR'            ; FOR           $81             129
D_A0A4          .shift 'NEXT'           ; NEXT          $82             130
D_A0A8          .shift 'DATA'           ; DATA          $83             131
D_A0AC          .shift 'INPUT#'         ; INPUT#        $84             132
D_A0B2          .shift 'INPUT'          ; INPUT         $85             133
D_A0B7          .shift 'DIM'            ; DIM           $86             134
D_A0BA          .shift 'READ'           ; READ          $87             135
D_A0BE          .shift 'LET'            ; LET           $88             136
D_A0C1          .shift 'GOTO'           ; GOTO          $89             137
D_A0C5          .shift 'RUN'            ; RUN           $8A             138
D_A0C8          .shift 'IF'             ; IF            $8B             139
D_A0CA          .shift 'RESTORE'                ; RESTORE       $8C             140
D_A0D1          .shift 'GOSUB'          ; GOSUB         $8D             141
D_A0D6          .shift 'RETURN'         ; RETURN        $8E             142
D_A0DC          .shift 'REM'            ; REM           $8F             143
D_A0DF          .shift 'STOP'           ; STOP          $90             144
D_A0E3          .shift 'ON'             ; ON            $91             145
D_A0E5          .shift 'WAIT'           ; WAIT          $92             146
D_A0E9          .shift 'LOAD'           ; LOAD          $93             147
D_A0ED          .shift 'SAVE'           ; SAVE          $94             148
D_A0F1          .shift 'VERIFY'         ; VERIFY        $95             149
D_A0F7          .shift 'DEF'            ; DEF           $96             150
D_A0FA          .shift 'POKE'           ; POKE          $97             151
D_A0FE          .shift 'PRINT#'         ; PRINT#        $98             152
D_A104          .shift 'PRINT'          ; PRINT         $99             153
D_A109          .shift 'CONT'           ; CONT          $9A             154
D_A10D          .shift 'LIST'           ; LIST          $9B             155
D_A111          .shift 'CLR'            ; CLR           $9C             156
D_A114          .shift 'CMD'            ; CMD           $9D             157
D_A117          .shift 'SYS'            ; SYS           $9E             158
D_A11A          .shift 'OPEN'           ; OPEN          $9F             159
D_A11E          .shift 'CLOSE'          ; CLOSE         $A0             160
D_A123          .shift 'GET'            ; GET           $A1             161
D_A126          .shift 'NEW'            ; NEW           $A2             162

; table of functions, each ended with a +$80    
; next are the secondary command keywords, these can not start a statement

D_A129          .shift 'TAB('           ; TAB(          $A3             163
D_A12D          .shift 'TO'             ; TO            $A4             164
D_A12F          .shift 'FN'             ; FN            $A5             165
D_A131          .shift 'SPC('           ; SPC(          $A6             166
D_A135          .shift 'THEN'           ; THEN          $A7             167
D_A139          .shift 'NOT'            ; NOT           $A8             168
D_A13C          .shift 'STEP'           ; STEP          $A9             169

; next are the operators

D_A140          .shift '+'              ; +             $AA             170
D_A141          .shift '-'              ; -             $AB             171
D_A142          .shift '*'              ; *             $AC             172
D_A143          .shift '/'              ; /             $AD             173
D_A144          .shift '^'              ; ^             $AE             174
D_A145          .shift 'AND'            ; AND           $AF             175
D_A148          .shift 'OR'             ; OR            $B0             176
D_A14A          .shift '>'              ; >             $B1             177
D_A14B          .shift '='              ; =             $B2             178
D_A14C          .shift '<'              ; <             $B3             179

; and finally the functions

D_A14D          .shift 'SGN'            ; SGN           $B4             180
D_A150          .shift 'INT'            ; INT           $B5             181
D_A153          .shift 'ABS'            ; ABS           $B6             182
D_A156          .shift 'USR'            ; USR           $B7             183
D_A159          .shift 'FRE'            ; FRE           $B8             184
D_A15C          .shift 'POS'            ; POS           $B9             185
D_A15F          .shift 'SQR'            ; SQR           $BA             186
D_A162          .shift 'RND'            ; RND           $BB             187
D_A165          .shift 'LOG'            ; LOG           $BC             188
D_A168          .shift 'EXP'            ; EXP           $BD             189
D_A16B          .shift 'COS'            ; COS           $BE             190
D_A16E          .shift 'SIN'            ; SIN           $BF             191
D_A171          .shift 'TAN'            ; TAN           $C0             192
D_A174          .shift 'ATN'            ; ATN           $C1             193
D_A177          .shift 'PEEK'           ; PEEK          $C2             194
D_A17B          .shift 'LEN'            ; LEN           $C3             195
D_A17E          .shift 'STR$'           ; STR$          $C4             196
D_A182          .shift 'VAL'            ; VAL           $C5             197
D_A185          .shift 'ASC'            ; ASC           $C6             198
D_A188          .shift 'CHR$'           ; CHR$          $C7             199
D_A18C          .shift 'LEFT$'          ; LEFT$         $C8             200
D_A191          .shift 'RIGHT$'         ; RIGHT$        $C9             201
D_A197          .shift 'MID$'           ; MID$          $CA             202

; lastly is GO, this is an add on so that GO TO, as well as GOTO, will work

D_A19B          .byte $47,$CF           ; GO            $CB             203

.byte   $00                             ; end marker


;******************************************************************************
;
; BASIC error messages

TxtTooManyFile          .shift 'TOO MANY FILES'         ;               [A19E]
TxtFileOpen             .shift 'FILE OPEN'              ;               [A1AC]
TxtFileNotOpen          .shift 'FILE NOT OPEN'          ;               [A1B5]
TxtFileNotFound         .shift 'FILE NOT FOUND'         ;               [A1C2]
TxtDevNotPresent        .shift 'DEVICE NOT PRESENT'     ;               [A1D0]
TxtNotInputFile         .shift 'NOT INPUT FILE'         ;               [A1E2]
TxtNotOutputFile        .shift 'NOT OUTPUT FILE'        ;               [A1F0]
TxtMissingFile          .shift 'MISSING FILE NAME'      ;               [A1FF]
TxtIllegalDevice        .shift 'ILLEGAL DEVICE NUMBER'  ;               [A210]
TxtNextWithout          .shift 'NEXT WITHOUT FOR'       ;               [A225]
TxtSyntax               .shift 'SYNTAX'                 ;               [A235]
TxtReturnWithout        .shift 'RETURN WITHOUT GOSUB'   ;               [A23B]
TxtOutOfData            .shift 'OUT OF DATA'            ;               [A24F]
TxtIllegalQuan          .shift 'ILLEGAL QUANTITY'       ;               [A25A]
TxtOverflow             .shift 'OVERFLOW'               ;               [A26A]
TxtOutOfMemory          .shift 'OUT OF MEMORY'          ;               [A272]
TxtUndefdState          .shift "UNDEF'D STATEMENT"      ;               [A27F]
TxtBadSubscript         .shift 'BAD SUBSCRIPT'          ;               [A290]
TxtRedimdArray          .shift "REDIM'D ARRAY"          ;               [A29D]
TxtDivisByZero          .shift 'DIVISION BY ZERO'       ;               [A2AA]
TxtIllegalDirect        .shift 'ILLEGAL DIRECT'         ;               [A2BA]
TxtTypeMismatc          .shift 'TYPE MISMATCH'          ;               [A2C8]
TxtStringTooLong        .shift 'STRING TOO LONG'        ;               [A2D5]
TxtFileData             .shift 'FILE DATA'              ;               [A2E4]
TxtFormulaTooC          .shift 'FORMULA TOO COMPLEX'    ;               [A2ED]
TxtCantContinue         .shift "CAN'T CONTINUE"         ;               [A300]
TxtUndefdFunct          .shift "UNDEF'D FUNCTION"       ;               [A30E]
TxtVerify               .shift 'VERIFY'                 ;               [A31E]
TxtLoad                 .shift 'LOAD'                   ;               [A324]


; error message pointer table

AddrErrorMsg                            ;                               [A328]
.word   TxtTooManyFile                  ; $01   TOO MANY FILES
.word   TxtFileOpen                     ; $02   FILE OPEN
.word   TxtFileNotOpen                  ; $03   FILE NOT OPEN
.word   TxtFileNotFound                 ; $04   FILE NOT FOUND
.word   TxtDevNotPresent                ; $05   DEVICE NOT PRESENT
.word   TxtNotInputFile                 ; $06   NOT INPUT FILE
.word   TxtNotOutputFile                ; $07   NOT OUTPUT FILE
.word   TxtMissingFile                  ; $08   MISSING FILE NAME
.word   TxtIllegalDevice                ; $09   ILLEGAL DEVICE NUMBER
.word   TxtNextWithout                  ; $0A   NEXT WITHOUT FOR
.word   TxtSyntax                       ; $0B   SYNTAX
.word   TxtReturnWithout                ; $0C   RETURN WITHOUT GOSUB
.word   TxtOutOfData                    ; $0D   OUT OF DATA
.word   TxtIllegalQuan                  ; $0E   ILLEGAL QUANTITY
.word   TxtOverflow                     ; $0F   OVERFLOW
.word   TxtOutOfMemory                  ; $10   OUT OF MEMORY
.word   TxtUndefdState                  ; $11   UNDEF'D STATEMENT
.word   TxtBadSubscript                 ; $12   BAD SUBSCRIPT
.word   TxtRedimdArray                  ; $13   REDIM'D ARRAY
.word   TxtDivisByZero                  ; $14   DIVISION BY ZERO
.word   TxtIllegalDirect                ; $15   ILLEGAL DIRECT
.word   TxtTypeMismatc                  ; $16   TYPE MISMATCH
.word   TxtStringTooLong                ; $17   STRING TOO LONG
.word   TxtFileData                     ; $18   FILE DATA
.word   TxtFormulaTooC                  ; $19   FORMULA TOO COMPLEX
.word   TxtCantContinue                 ; $1A   CAN'T CONTINUE
.word   TxtUndefdFunct                  ; $1B   UNDEF'D FUNCTION
.word   TxtVerify                       ; $1C   VERIFY
.word   TxtLoad                         ; $1D   LOAD
.word   TxtBreak2                       ; $1E   BREAK


;******************************************************************************
;
; BASIC messages

TxtOK           .text $0D, 'OK', $0D, $00
TxtError        .text '  ERROR', $00
TxtIn           .text ' IN ', $00
TxtReady        .text $0D, $0A, 'READY.', $0D, $0A, $00
TxtBreak        .text $0D, $0A
TxtBreak2       .text 'BREAK', $00


;******************************************************************************
;
; spare byte, not referenced

A390            .byte   $A0             ; unused


;******************************************************************************
;
; search the stack for FOR or GOSUB activity
; return Zb=1 if FOR variable found

SrchForNext                             ;                               [A38A]
        tsx                             ; copy stack pointer
        inx                             ; +1 pass return address
        inx                             ; +2 pass return address
        inx                             ; +3 pass calling routine return address
        inx                             ; +4 pass calling routine return address
A_A38F                                  ;                               [A38F]
        lda     STACK+1,X               ; get the token byte from the stack
        cmp     #TK_FOR                 ; is it the FOR token
        bne     A_A3B7                  ; if not FOR token just exit

; it was the FOR token

        lda     FORPNT+1                ; get FOR/NEXT variable pointer HB
        bne     A_A3A4                  ; branch if not null

        lda     STACK+2,X               ; get FOR variable pointer LB
        sta     FORPNT                  ; save FOR/NEXT variable pointer LB
        lda     STACK+3,X               ; get FOR variable pointer HB
        sta     FORPNT+1                ; save FOR/NEXT variable pointer HB
A_A3A4                                  ;                               [A3A4]
        cmp     STACK+3,X               ; compare variable pointer with stacked
                                        ; variable pointer HB
        bne     A_A3B0                  ; branch if no match

        lda     FORPNT                  ; get FOR/NEXT variable pointer LB
        cmp     STACK+2,X               ; compare variable pointer with stacked
                                        ; variable pointer LB
        beq     A_A3B7                  ; exit if match found

A_A3B0                                  ;                               [A3B0]
        txa                             ; copy index
        clc                             ; clear carry for add
        adc     #$12                    ; add FOR stack use size
        tax                             ; copy back to index
        bne     A_A38F                  ; loop if not at start of stack
A_A3B7                                  ;                               [A3B7]
        rts


;******************************************************************************
;
; Move a block of memory
; - open up a space in the memory, set the end of arrays

MoveBlock                               ;                               [A3B8]
        jsr     CheckAvailMem           ; check available memory, do out of
                                        ; memory error if no room       [A408]
        sta     STREND                  ; set end of arrays LB
        sty     STREND+1                ; set end of arrays HB

; - open up a space in the memory, don't set the array end

MoveBlock2                              ;                               [A3BF]
        sec                             ; set carry for subtract
        lda     FacTempStor+3           ; get block end LB
        sbc     FacTempStor+8           ; subtract block start LB
        sta     INDEX                   ; save MOD(block length/$100) byte

        tay                             ; copy MOD(block length/$100) byte to Y
        lda     FacTempStor+4           ; get block end HB
        sbc     FacTempStor+9           ; subtract block start HB
        tax                             ; copy block length HB to X

        inx                             ; +1 to allow for count=0 exit

        tya                             ; copy block length LB to A
        beq     A_A3F3                  ; branch if length LB=0

; block is (X-1)*256+Y bytes, do the Y bytes first
        lda     FacTempStor+3           ; get block end LB
        sec                             ; set carry for subtract
        sbc     INDEX                   ; subtract MOD(block length/$100) byte
        sta     FacTempStor+3           ; save corrected old block end LB
        bcs     A_A3DC                  ; branch if no underflow

        dec     FacTempStor+4           ; else decrement block end HB
        sec                             ; set carry for subtract
A_A3DC                                  ;                               [A3DC]
        lda     FacTempStor+1           ; get destination end LB
        sbc     INDEX                   ; subtract MOD(block length/$100) byte
        sta     FacTempStor+1           ; save modified new block end LB
        bcs     A_A3EC                  ; branch if no underflow

        dec     FacTempStor+2           ; else decrement block end HB
        bcc     A_A3EC                  ; branch always
A_A3E8                                  ;                               [A3E8]
        lda     (FacTempStor+3),Y       ; get byte from source
        sta     (FacTempStor+1),Y       ; copy byte to destination
A_A3EC                                  ;                               [A3EC]
        dey                             ; decrement index
        bne     A_A3E8                  ; loop until Y=0

; now do Y=0 indexed byte
        lda     (FacTempStor+3),Y       ; get byte from source
        sta     (FacTempStor+1),Y       ; save byte to destination
A_A3F3                                  ;                               [A3F3]
        dec     FacTempStor+4           ; decrement source pointer HB
        dec     FacTempStor+2           ; decrement destination pointer HB

        dex                             ; decrement block count
        bne     A_A3EC                  ; loop until count = $0

        rts


;******************************************************************************
;
; check room on stack for A bytes
; if stack too deep do out of memory error

CheckRoomStack                          ;                               [A3FB]
        asl                             ; *2
        adc     #$3E                    ; need at least $3E bytes free
        bcs     OutOfMemory             ; if overflow go do out of memory error
                                        ; then warm start
        sta     INDEX                   ; save result in temp byte

        tsx                             ; copy stack
        cpx     INDEX                   ; compare new limit with stack
        bcc     OutOfMemory             ; if stack < limit do out of memory
                                        ; error then warm start
        rts


;******************************************************************************
;
; check available memory, do out of memory error if no room

CheckAvailMem 
        cpy     FRETOP+1                ; compare with bottom of string space HB
        bcc     A_A434                  ; if less then exit (is ok)
        bne     A_A412                  ; skip next test if greater (tested <)

; HB was =, now do LB
        cmp     FRETOP                  ; compare with bottom of string space LB
        bcc     A_A434                  ; if less then exit (is ok)

; address is > string storage ptr (oops!)
A_A412                                  ;                               [A412]
        pha                             ; push address LB

        ldx     #$09                    ; set index to save FacTempStor to
                                        ; FacTempStor+9 inclusive
        tya                             ; copy address HB (to push on stack)

; save misc numeric work area
A_A416                                  ;                               [A416]
        pha                             ; push byte

        lda     FacTempStor,X           ; get byte from FacTempStor to
                                        ; FacTempStor+9
        dex                             ; decrement index
        bpl     A_A416                  ; loop until all done

        jsr     CollectGarbage          ; do garbage collection routine [B526]

; restore misc numeric work area
        ldx     #$F7                    ; set index to restore bytes
A_A421                                  ;                               [A421]
        pla                             ; pop byte
        sta     FacTempStor+9+1,X       ; save byte to FacTempStor to
                                        ; FacTempStor+9
        inx                             ; increment index
        bmi     A_A421                  ; loop while -ve

        pla                             ; pop address HB
        tay                             ; copy back to Y

        pla                             ; pop address LB

        cpy     FRETOP+1                ; compare with bottom of string space HB
        bcc     A_A434                  ; if less then exit (is ok)

        bne     OutOfMemory             ; if greater do out of memory error
                                        ; then warm start
; HB was =, now do LB
        cmp     FRETOP                  ; compare with bottom of string space LB
        bcs     OutOfMemory             ; if >= do out of memory error then
                                        ; warm start
; ok exit, carry clear
A_A434                                  ;                               [A434]
        rts


;******************************************************************************
;
; do out of memory error then warm start

OutOfMemory 
        ldx     #$10                    ; error code $10, out of memory error

; do error #X then warm start

OutputErrMsg 
        jmp     (IERROR)                ; do error message


;******************************************************************************
;
; do error #X then warm start, the error message vector is initialised to point
; here

OutputErrMsg2                           ;                               [A43A]
        txa                             ; copy error number
        asl                             ; *2
        tax                             ; copy to index

        lda     AddrErrorMsg-2,X        ; get error message pointer LB
        sta     INDEX                   ; save it

        lda     AddrErrorMsg-1,X        ; get error message pointer HB
        sta     INDEX+1                 ; save it

        jsr     CloseIoChannls          ; close input and output channels [FFCC]

        lda     #$00                    ; clear A
        sta     CurIoChan               ; clear current I/O channel, flag
                                        ; default
        jsr     OutCRLF                 ; print CR/LF                   [AAD7]
        jsr     PrintQuestMark          ; print "?"                     [AB45]

        ldy     #$00                    ; clear index
A_A456                                  ;                               [A456]
        lda     (INDEX),Y               ; get byte from message
        pha                             ; save status
        and     #$7F                    ; mask 0xxx xxxx, clear b7
        jsr     PrintChar               ; output character              [CB47]

        iny                             ; increment index
        pla                             ; restore status
        bpl     A_A456                  ; loop if character was not end marker

        jsr     ClrBasicStack           ; flush BASIC stack and clear continue
                                        ; pointer                       [A67A]
        lda     #<TxtERROR              ; set " ERROR" pointer LB
        ldy     #>TxtERROR              ; set " ERROR" pointer HB


;******************************************************************************
;
; print string and do warm start, break entry

OutputMessage                           ;                               [A469]
        jsr     OutputString            ; print null terminated string  [AB1E]

        ldy     CURLIN+1                ; get current line number HB
        iny                             ; increment it
        beq     OutputREADY             ; branch if was in immediate mode

        jsr     Print_IN                ; do " IN " line number message [BDC2]


;******************************************************************************
;
; do warm start, print READY on the screen

OutputREADY                             ;                               [A474]
        lda     #<TxtREADY              ; set "READY." pointer LB
        ldy     #>TxtREADY              ; set "READY." pointer HB
        jsr     OutputString            ; print null terminated string  [AB1E]

        lda     #$80                    ; set for control messages only
        jsr     CtrlKernalMsg           ; control kernal messages       [FF90]


;******************************************************************************
;
; Main wait loop

MainWaitLoop 
        jmp     (IMAIN)                 ; do BASIC warm start


;******************************************************************************
;
; BASIC warm start, the warm start vector is initialised to point here

MainWaitLoop2                           ;                               [A483]
        jsr     InputNewLine            ; call for BASIC input          [A560]
        stx     TXTPTR                  ; save BASIC execute pointer LB
        sty     TXTPTR+1                ; save BASIC execute pointer HB

        jsr     CHRGET                  ; increment and scan memory     [0073]
        tax                             ; copy byte to set flags
        beq     MainWaitLoop            ; loop if no input

; got to interpret the input line now ....

        ldx     #$FF                    ; current line HB to -1, indicates
                                        ; immediate mode
        stx     CURLIN+1                ; set current line number HB
        bcc     A_A49C                  ; if numeric character go handle new
                                        ; BASIC line
; no line number .. immediate mode
S_A496 
        jsr     Text2TokenCode          ; crunch keywords into BASIC tokens
                                        ;                               [A579]
        jmp     InterpretLoop2          ; go scan and interpret code    [A7E1]


;******************************************************************************
;
; handle new BASIC line

A_A49C                                  ;                               [A49C]
        jsr     LineNum2Addr            ; get fixed-point number into temporary
                                        ; integer                       [A96B]
        jsr     Text2TokenCode          ; crunch keywords into BASIC tokens
                                        ;                               [A579]
        sty     COUNT                   ; save index pointer to end of crunched
                                        ; line
        jsr     CalcStartAddr           ; search BASIC for temporary integer
                                        ; line number                   [A613]
        bcc     A_A4ED                  ; if not found skip the line delete

; line # already exists so delete it
        ldy     #$01                    ; set index to next line pointer HB
        lda     (FacTempStor+8),Y       ; get next line pointer HB
        sta     INDEX+1                 ; save it

        lda     VARTAB                  ; get start of variables LB
        sta     INDEX                   ; save it

        lda     FacTempStor+9           ; get found line pointer HB
        sta     INDEX+3                 ; save it

        lda     FacTempStor+8           ; get found line pointer LB
        dey                             ; decrement index
        sbc     (FacTempStor+8),Y       ; subtract next line pointer LB
        clc                             ; clear carry for add
        adc     VARTAB                  ; add start of variables LB
        sta     VARTAB                  ; set start of variables LB
        sta     INDEX+2                 ; save destination pointer LB

        lda     VARTAB+1                ; get start of variables HB
        adc     #$FF                    ; -1 + carry
        sta     VARTAB+1                ; set start of variables HB

        sbc     FacTempStor+9           ; subtract found line pointer HB
        tax                             ; copy to block count

        sec                             ; set carry for subtract
        lda     FacTempStor+8           ; get found line pointer LB
        sbc     VARTAB                  ; subtract start of variables LB
        tay                             ; copy to bytes in first block count
        bcs     A_A4D7                  ; branch if no underflow

        inx                             ; increment block count, correct for =
                                        ; 0 loop exit
        dec     INDEX+3                 ; decrement destination HB
A_A4D7                                  ;                               [A4D7]
        clc                             ; clear carry for add
        adc     INDEX                   ; add source pointer LB
        bcc     A_A4DF                  ; branch if no overflow

        dec     INDEX+1                 ; else decrement source pointer HB
        clc                             ; clear carry

; close up memory to delete old line
A_A4DF                                  ;                               [A4DF]
        lda     (INDEX),Y               ; get byte from source
        sta     (INDEX+2),Y             ; copy to destination
        iny                             ; increment index
        bne     A_A4DF                  ; while <> 0 do this block

        inc     INDEX+1                 ; increment source pointer HB
        inc     INDEX+3                 ; increment destination pointer HB

        dex                             ; decrement block count
        bne     A_A4DF                  ; loop until all done

; got new line in buffer and no existing same #
A_A4ED                                  ;                               [A4ED]
        jsr     ResetExecPtr            ; reset execution to start, clear
                                        ; variables, flush stack        [A659]
                                        ; and return
        jsr     BindLine                ; rebuild BASIC line chaining   [A533]

        lda     CommandBuf              ; get first byte from buffer
        beq     MainWaitLoop            ; if no line go do BASIC warm start

; else insert line into memory
        clc                             ; clear carry for add
        lda     VARTAB                  ; get start of variables LB
        sta     FacTempStor+3           ; save as source end pointer LB

        adc     COUNT                   ; add index pointer to end of crunched
                                        ; line
        sta     FacTempStor+1           ; save as destination end pointer LB

        ldy     VARTAB+1                ; get start of variables HB
        sty     FacTempStor+4           ; save as source end pointer HB
        bcc     A_A508                  ; branch if no carry to HB

        iny                             ; else increment HB
A_A508                                  ;                               [A508]
        sty     FacTempStor+2           ; save as destination end pointer HB

        jsr     MoveBlock               ; open up space in memory       [A3B8]

; most of what remains to do is copy the crunched line into the space opened up
; in memory, however, before the crunched line comes the next line pointer and
; the line number. the line number is retrieved from the temporary integer and
; stored in memory, this overwrites the bottom two bytes on the stack. next the
; line is copied and the next line pointer is filled with whatever was in two
; bytes above the line number in the stack. this is ok because the line pointer
; gets fixed in the line chain re-build.

        lda     LINNUM                  ; get line number LB
        ldy     LINNUM+1                ; get line number HB
        sta     STACK+$FE               ; save line number LB before crunched
                                        ; line
        sty     CommandBuf-1            ; save line number HB before crunched
                                        ; line

        lda     STREND                  ; get end of arrays LB
        ldy     STREND+1                ; get end of arrays HB
        sta     VARTAB                  ; set start of variables LB
        sty     VARTAB+1                ; set start of variables HB

        ldy     COUNT                   ; get index to end of crunched line
        dey                             ; -1
A_A522                                  ;                               [A522]
        lda     STACK+$FC,Y             ; get byte from crunched line
        sta     (FacTempStor+8),Y       ; save byte to memory

        dey                             ; decrement index
        bpl     A_A522                  ; loop while more to do

; reset execution, clear variables, flush stack, rebuild BASIC chain and do
; warm start

J_A52A                                  ;                               [A52A]
        jsr     ResetExecPtr            ; reset execution to start, clear
                                        ; variables and flush stack     [A659]
        jsr     BindLine                ; rebuild BASIC line chaining   [A533]
        jmp     MainWaitLoop            ; go do BASIC warm start        [A480]


;******************************************************************************
;
; rebuild BASIC line chaining

BindLine                                ;                               [A533]
        lda     TXTTAB                  ; get start of memory LB
        ldy     TXTTAB+1                ; get start of memory HB
        sta     INDEX                   ; set line start pointer LB
        sty     INDEX+1                 ; set line start pointer HB
        clc                             ; clear carry for add
A_A53C                                  ;                               [A53C]
        ldy     #$01                    ; set index to pointer to next line HB
        lda     (INDEX),Y               ; get pointer to next line HB
        beq     A_A55F                  ; exit if null, [EOT]

        ldy     #$04                    ; point to first code byte of line
                                        ; there is always 1 byte + [EOL] as null
                                        ; entries are deleted
A_A544                                  ;                               [A544]
        iny                             ; next code byte
        lda     (INDEX),Y               ; get byte
        bne     A_A544                  ; loop if not [EOL]

        iny                             ; point to byte past [EOL], start of
                                        ; next line
        tya                             ; copy it

        adc     INDEX                   ; add line start pointer LB
        tax                             ; copy to X

        ldy     #$00                    ; clear index, point to this line's next
                                        ; line pointer
        sta     (INDEX),Y               ; set next line pointer LB

        lda     INDEX+1                 ; get line start pointer HB
        adc     #$00                    ; add any overflow
        iny                             ; increment index to HB
        sta     (INDEX),Y               ; set next line pointer HB
        stx     INDEX                   ; set line start pointer LB
        sta     INDEX+1                 ; set line start pointer HB
        bcc     A_A53C                  ; go do next line, branch always

A_A55F                                  ;                               [A55F]
        rts


;******************************************************************************
;
; call for BASIC input

InputNewLine                            ;                               [A560]
        ldx     #$00                    ; set channel $00, keyboard
A_A562                                  ;                               [A562]
        jsr     InpCharErrChan          ; input character from channel with
                                        ; error check                   [E112]
        cmp     #$0D                    ; compare with [CR]
        beq     A_A576                  ; if [CR] set XY to Command buffer - 1,
                                        ; print [CR] and exit
; character was not [CR]
        sta     CommandBuf,X            ; save character to buffer

        inx                             ; increment buffer index
        cpx     #$59                    ; compare with max+1
        bcc     A_A562                  ; branch if < max+1

        ldx     #$17                    ; error $17, string too long error
        jmp     OutputErrMsg            ; do error #X then warm start   [A437]

A_A576                                  ;                               [A576]
        jmp     SetXY2CmdBuf            ; set XY to Command buffer - 1 and
                                        ; print [CR]                    [AACA]


;******************************************************************************
;
; crunch BASIC tokens vector

Text2TokenCode                          ;                               [A579]
        jmp     (ICRNCH)                ; do crunch BASIC tokens


;******************************************************************************
;
; crunch BASIC tokens, the crunch BASIC tokens vector is initialised to point
; here

Text2TokenCod2                          ;                               [A57C]
        ldx     TXTPTR                  ; get BASIC execute pointer LB
        ldy     #$04                    ; set save index
        sty     GARBFL                  ; clear open quote/DATA flag
A_A582                                  ;                               [A582]
        lda     CommandBuf,X            ; get a byte from the input buffer
        bpl     A_A58E                  ; if b7 clear go do crunching

        cmp     #TK_PI                  ; compare with the token for PI, this
                                        ; toke is input directly from the
                                        ; keyboard as the PI character
        beq     A_A5C9                  ; if PI then save byte and continue
                                        ; crunching

; this is the bit of code that stops you being able to enter some keywords as
; just single shifted characters. If this dropped through you would be able to
; enter GOTO as just [SHIFT]G

        inx                             ; increment read index
        bne     A_A582                  ; loop if more to do, branch always

A_A58E                                  ;                               [A58E]
        cmp     #' '                    ; compare with [SPACE]
        beq     A_A5C9                  ; if [SPACE] save byte then continue
                                        ; crunching

        sta     ENDCHR                  ; save buffer byte as search character

        cmp     #'"'                    ; compare with quote character
        beq     A_A5EE                  ; if quote go copy quoted string

        bit     GARBFL                  ; get open quote/DATA token flag
        bvs     A_A5C9                  ; branch if b6 of Oquote set, was DATA
                                        ; go save byte then continue crunching

        cmp     #'?'                    ; compare with "?" character
        bne     A_A5A4                  ; if not "?" continue crunching

        lda     #TK_PRINT               ; else the keyword token is $99, PRINT
        bne     A_A5C9                  ; go save byte then continue crunching,
                                        ; branch always
A_A5A4                                  ;                               [A5A4]
        cmp     #'0'                    ; compare with "0"
        bcc     A_A5AC                  ; branch if <, continue crunching

        cmp     #'<'                    ; compare with "<"
        bcc     A_A5C9                  ; if <, 0123456789:; go save byte then
                                        ; continue crunching
; gets here with next character not numeric, ";" or ":"
A_A5AC                                  ;                               [A5AC]
        sty     FBUFPT                  ; copy save index

        ldy     #$00                    ; clear table pointer
        sty     COUNT                   ; clear word index

        dey                             ; adjust for pre increment loop

        stx     TXTPTR                  ; save BASIC execute pointer LB, buffer
                                        ; index
        dex                             ; adjust for pre increment loop
A_A5B6                                  ;                               [A5B6]
        iny                             ; next table byte
        inx                             ; next buffer byte
A_A5B8                                  ;                               [A5B8]
        lda     CommandBuf,X            ; get byte from input buffer
        sec                             ; set carry for subtract
        sbc     TblBasicCodes,Y         ; subtract table byte
        beq     A_A5B6                  ; go compare next if match

        cmp     #$80                    ; was it end marker match ?
        bne     A_A5F5                  ; branch if not, not found keyword

; actually this works even if the input buffer byte is the end marker, i.e. a
; shifted character. As you can't enter any keywords as a single shifted
; character, see above, you can enter keywords in shorthand by shifting any
; character after the first. so RETURN can be entered as R[SHIFT]E, RE[SHIFT]T,
; RET[SHIFT]U or RETU[SHIFT]R. RETUR[SHIFT]N however will not work because the
; [SHIFT]N will match the RETURN end marker so the routine will try to match
; the next character.

; else found keyword
        ora     COUNT                   ; OR with word index, +$80 in A makes
                                        ; token
A_A5C7                                  ;                               [A5C7]
        ldy     FBUFPT                  ; restore save index

; save byte then continue crunching

A_A5C9                                  ;                               [A5C9]
        inx                             ; increment buffer read index
        iny                             ; increment save index
        sta     CommandBuf-5,Y          ; save byte to output

        lda     CommandBuf-5,Y          ; get byte from output, set flags
        beq     A_A609                  ; branch if was null [EOL]

; A holds the token here
        sec                             ; set carry for subtract
        sbc     #':'                    ; subtract ":"
        beq     A_A5DC                  ; branch if it was (is now $00)

; A now holds token-':'
        cmp     #TK_DATA-':'            ; compare with the token for DATA-':'
        bne     A_A5DE                  ; if not DATA go try REM

; token was : or DATA

A_A5DC                                  ;                               [A5DC]
        sta     GARBFL                  ; save the token-$3A
A_A5DE                                  ;                               [A5DE]
        sec                             ; set carry for subtract
        sbc     #TK_REM-':'             ; subtract the token for REM-':'
        bne     A_A582                  ; if wasn't REM crunch next bit of line
S_A5E3 
        sta     ENDCHR                  ; else was REM so set search for [EOL]

; loop for "..." etc.
A_A5E5                                  ;                               [A5E5]
        lda     CommandBuf,X            ; get byte from input buffer
        beq     A_A5C9                  ; if null [EOL] save byte then continue
                                        ; crunching
        cmp     ENDCHR                  ; compare with stored character
        beq     A_A5C9                  ; if match save byte then continue
                                        ; crunching
A_A5EE                                  ;                               [A5EE]
        iny                             ; increment save index
        sta     CommandBuf-5,Y          ; save byte to output

        inx                             ; increment buffer index
        bne     A_A5E5                  ; loop while <> 0, should never reach 0

; not found keyword this go
A_A5F5                                  ;                               [A5F5]
        ldx     TXTPTR                  ; restore BASIC execute pointer LB
        inc     COUNT                   ; increment word index (next word)

; now find end of this word in the table
A_A5F9                                  ;                               [A5F9]
        iny                             ; increment table index
        lda     TblBasicCodes-1,Y       ; get table byte
        bpl     A_A5F9                  ; loop if not end of word yet

        lda     TblBasicCodes,Y         ; get byte from keyword table
        bne     A_A5B8                  ; go test next word if not zero byte,
                                        ; end of table
; reached end of table with no match
        lda     CommandBuf,X            ; restore byte from input buffer
        bpl     A_A5C7                  ; branch always, all unmatched bytes in
                                        ; the buffer are $00 to $7F, go save
                                        ; byte in output and continue crunching
; reached [EOL]
A_A609                                  ;                               [A609]
        sta     STACK+$FD,Y             ; save [EOL]

        dec     TXTPTR+1                ; decrement BASIC execute pointer HB

        lda     #$FF                    ; point to start of buffer-1
        sta     TXTPTR                  ; set BASIC execute pointer LB

        rts


;******************************************************************************
;
; search BASIC for temporary integer line number

CalcStartAddr                           ;                               [A613]
        lda     TXTTAB                  ; get start of memory LB
        ldx     TXTTAB+1                ; get start of memory HB


;******************************************************************************
;
; search Basic for temp integer line number from AX
; returns carry set if found

CalcStartAddr2                          ;                               [A617]
        ldy     #$01                    ; set index to next line pointer HB
        sta     FacTempStor+8           ; save LB as current
        stx     FacTempStor+9           ; save HB as current

        lda     (FacTempStor+8),Y       ; get next line pointer HB from address
        beq     A_A640                  ; pointer was zero so done, exit

        iny                             ; increment index ...
        iny                             ; ... to line # HB
        lda     LINNUM+1                ; get temporary integer HB
        cmp     (FacTempStor+8),Y       ; compare with line # HB
        bcc     A_A641                  ; exit if temp < this line, target line
                                        ; passed
        beq     A_A62E                  ; go check LB if =

        dey                             ; else decrement index
        bne     A_A637                  ; branch always

A_A62E                                  ;                               [A62E]
        lda     LINNUM                  ; get temporary integer LB
        dey                             ; decrement index to line # LB
        cmp     (FacTempStor+8),Y       ; compare with line # LB
        bcc     A_A641                  ; exit if temp < this line, target line
                                        ; passed
        beq     A_A641                  ; exit if temp = (found line#)

; not quite there yet
A_A637                                  ;                               [A637]
        dey                             ; decrement index to next line pointer
                                        ; HB
        lda     (FacTempStor+8),Y       ; get next line pointer HB
        tax                             ; copy to X

        dey                             ; decrement index to next line pointer
                                        ; LB
        lda     (FacTempStor+8),Y       ; get next line pointer LB
        bcs     CalcStartAddr2          ; go search for line # in temporary
                                        ; integer from AX, carry always set
A_A640                                  ;                               [A640]
        clc                             ; clear found flag
A_A641                                  ;                               [A641]
        rts


;******************************************************************************
;
; perform NEW

bcNEW                                   ;                               [A642]
        bne     A_A641                  ; exit if following byte to allow syntax
                                        ; error
bcNEW2                                  ;                               [A644]
        lda     #$00                    ; clear A
        tay                             ; clear index
        sta     (TXTTAB),Y              ; clear pointer to next line LB

        iny                             ; increment index
        sta     (TXTTAB),Y              ; clear pointer to next line HB, erase
                                        ; program
        lda     TXTTAB                  ; get start of memory LB
        clc                             ; clear carry for add
        adc     #$02                    ; add null program length
        sta     VARTAB                  ; set start of variables LB

        lda     TXTTAB+1                ; get start of memory HB
        adc     #$00                    ; add carry
        sta     VARTAB+1                ; set start of variables HB


;******************************************************************************
;
; reset execute pointer and do CLR

ResetExecPtr                            ;                               [A659]
        jsr     SetBasExecPtr           ; set BASIC execute pointer to start of
                                        ; memory - 1                    [A68E]
        lda     #$00                    ; set Zb for CLR entry


;******************************************************************************
;
; perform CLR

bcCLR                                   ;                               [A65E]
        bne     A_A68D                  ; exit if following byte to allow syntax
                                        ; error
bcCLR2                                  ;                               [A660]
        jsr     CloseAllChan            ; close all channels and files  [FFE7]
bcCLR3                                  ;                               [A663]
        lda     MEMSIZ                  ; get end of memory LB
        ldy     MEMSIZ+1                ; get end of memory HB
        sta     FRETOP                  ; set bottom of string space LB, clear
                                        ; strings
        sty     FRETOP+1                ; set bottom of string space HB

        lda     VARTAB                  ; get start of variables LB
        ldy     VARTAB+1                ; get start of variables HB
        sta     ARYTAB                  ; set end of variables LB, clear
                                        ; variables
        sty     ARYTAB+1                ; set end of variables HB
        sta     STREND                  ; set end of arrays LB, clear arrays
        sty     STREND+1                ; set end of arrays HB


;******************************************************************************
;
; do RESTORE and clear stack

bcCLR4                                  ;                               [A677]
        jsr     bcRESTORE               ; perform RESTORE               [A81D]


;******************************************************************************
;
; flush BASIC stack and clear the continue pointer

ClrBasicStack                           ;                               [A67A]
        ldx     #LASTPT+2               ; get the descriptor stack start
        stx     TEMPPT                  ; set the descriptor stack pointer

        pla                             ; pull the return address LB
        tay                             ; copy it

        pla                             ; pull the return address HB

        ldx     #$FA                    ; set the cleared stack pointer
        txs                             ; set the stack

        pha                             ; push the return address HB

        tya                             ; restore the return address LB
        pha                             ; push the return address LB

        lda     #$00                    ; clear A
        sta     OLDTXT+1                ; clear the continue pointer HB
        sta     SUBFLG                  ; clear the subscript/FNX flag
A_A68D                                  ;                               [A68D]
        rts


;******************************************************************************
;
; set BASIC execute pointer to start of memory - 1

SetBasExecPtr                           ;                               [A68E]
        clc                             ; clear carry for add
        lda     TXTTAB                  ; get start of memory LB
        adc     #$FF                    ; add -1 LB
        sta     TXTPTR                  ; set BASIC execute pointer LB

        lda     TXTTAB+1                ; get start of memory HB
        adc     #$FF                    ; add -1 HB
        sta     TXTPTR+1                ; save BASIC execute pointer HB

        rts


;******************************************************************************
;
; perform LIST

bcLIST                                  ;                               [A69C]
        bcc     A_A6A4                  ; branch if next character not token
                                        ; (LIST n...)
        beq     A_A6A4                  ; branch if next character [NULL] (LIST)

        cmp     #TK_MINUS               ; compare with token for -
        bne     A_A68D                  ; exit if not - (LIST -m)

; LIST [[n][-m]]
; this bit sets the n , if present, as the start and end
A_A6A4                                  ;                               [A6A4]
        jsr     LineNum2Addr            ; get fixed-point number into temporary
                                        ; integer                       [A96B]
        jsr     CalcStartAddr           ; search BASIC for temporary integer
                                        ; line number   [A613]
        jsr     CHRGOT                  ; scan memory                   [0079]
        beq     A_A6BB                  ; branch if no more chrs

; this bit checks the - is present
        cmp     #TK_MINUS               ; compare with token for -
        bne     A_A641                  ; return if not "-" (will be SN error)

; LIST [n]-m
; the - was there so set m as the end value
        jsr     CHRGET                  ; increment and scan memory     [0073]

        jsr     LineNum2Addr            ; get fixed-point number into temporary
                                        ; integer                       [A96B]
        bne     A_A641                  ; exit if not ok
A_A6BB                                  ;                               [A6BB]
        pla                             ; dump return address LB
        pla                             ; dump return address HB

        lda     LINNUM                  ; get temporary integer LB
        ora     LINNUM+1                ; OR temporary integer HB
        bne     A_A6C9                  ; branch if start set
bcLIST2                                 ;                               [A6C3]
        lda     #$FF                    ; set for -1
        sta     LINNUM                  ; set temporary integer LB
        sta     LINNUM+1                ; set temporary integer HB
A_A6C9                                  ;                               [A6C9]
        ldy     #$01                    ; set index for line
        sty     GARBFL                  ; clear open quote flag

        lda     (FacTempStor+8),Y       ; get next line pointer HB
        beq     A_A714                  ; if null all done so exit

        jsr     BasChkStopKey           ; do CRTL-C check vector        [A82C]
bcLIST3                                 ;                               [A6D4]
        jsr     OutCRLF                 ; print CR/LF                   [AAD7]

        iny                             ; increment index for line
        lda     (FacTempStor+8),Y       ; get line number LB
        tax                             ; copy to X

        iny                             ; increment index
        lda     (FacTempStor+8),Y       ; get line number HB
        cmp     LINNUM+1                ; compare with temporary integer HB
        bne     A_A6E6                  ; branch if no HB match

        cpx     LINNUM                  ; compare with temporary integer LB
        beq     A_A6E8                  ; branch if = last line to do, < will
                                        ; pass next branch
A_A6E6                                  ; else ...:
        bcs     A_A714                  ; if greater all done so exit
A_A6E8                                  ;                               [A6E8]
        sty     FORPNT                  ; save index for line

        jsr     PrintXAasInt            ; print XA as unsigned integer  [BDCD]

        lda     #' '                    ; space is the next character
A_A6EF                                  ;                               [A6EF]
        ldy     FORPNT                  ; get index for line
        and     #$7F                    ; mask top out bit of character
A_A6F3                                  ;                               [A6F3]
        jsr     PrintChar               ; go print the character        [AB47]
        cmp     #'"'                    ; was it " character
        bne     A_A700                  ; if not skip the quote handle

; we are either entering or leaving a pair of quotes
        lda     GARBFL                  ; get open quote flag
        eor     #$FF                    ; toggle it
        sta     GARBFL                  ; save it back
A_A700                                  ;                               [A700]
        iny                             ; increment index
        beq     A_A714                  ; line too long so just bail out and do
                                        ; a warm start
        lda     (FacTempStor+8),Y       ; get next byte
        bne     TokCode2Text            ; if not [EOL] (go print character)

; was [EOL]
        tay                             ; else clear index
        lda     (FacTempStor+8),Y       ; get next line pointer LB
        tax                             ; copy to X

        iny                             ; increment index
        lda     (FacTempStor+8),Y       ; get next line pointer HB
        stx     FacTempStor+8           ; set pointer to line LB
        sta     FacTempStor+9           ; set pointer to line HB
        bne     A_A6C9                  ; go do next line if not [EOT]
                                        ; else ...
A_A714                                  ;                               [A714]
        jmp     BasWarmStart2           ; do warm start                 [E386]


;******************************************************************************
;
; uncrunch BASIC tokens

TokCode2Text                            ;                               [A717]
        jmp     (IQPLOP)                ; do uncrunch BASIC tokens


;******************************************************************************
;
; uncrunch BASIC tokens, the uncrunch BASIC tokens vector is initialised to
; point here

TokCode2Text2                           ;                               [A71A]
        bpl     A_A6F3                  ; just go print it if not token byte
                                        ; else was token byte so uncrunch it

        cmp     #TK_PI                  ; compare with the token for PI. in this
                                        ; case the token is the same as the PI
                                        ; character so it just needs printing
        beq     A_A6F3                  ; just print it if so

        bit     GARBFL                  ; test the open quote flag
        bmi     A_A6F3                  ; just go print char if open quote set

        sec                             ; else set carry for subtract
        sbc     #$7F                    ; reduce token range to 1 to whatever
        tax                             ; copy token # to X

        sty     FORPNT                  ; save index for line

        ldy     #$FF                    ; start from -1, adjust for pre-
                                        ; increment
A_A72C                                  ;                               [A72C]
        dex                             ; decrement token #
        beq     A_A737                  ; if now found go do printing
A_A72F                                  ;                               [A72F]
        iny                             ; else increment index
        lda     TblBasicCodes,Y         ; get byte from keyword table
        bpl     A_A72F                  ; loop until keyword end marker

        bmi     A_A72C                  ; go test if this is required keyword,
                                        ; branch always
; found keyword, it's the next one
A_A737                                  ;                               [A737]
        iny                             ; increment keyword table index
        lda     TblBasicCodes,Y         ; get byte from table
        bmi     A_A6EF                  ; go restore index, mask byte and print
                                        ; if byte was end marker
        jsr     PrintChar               ; else go print the character   [AB47]
        bne     A_A737                  ; go get next character, branch always


;******************************************************************************
;
; perform FOR

bcFOR                                   ;                               [A742]
        lda     #$80                    ; set FNX
        sta     SUBFLG                  ; set subscript/FNX flag

        jsr     bcLET                   ; perform LET                   [A9A5]

        jsr     SrchForNext             ; search stack for FOR or GOSUB activity
                                        ;                               [A38A]
        bne     A_A753                  ; branch if FOR not found

; FOR, this variable, was found so first we dump the old one
        txa                             ; copy index
        adc     #$0F                    ; add FOR structure size-2
        tax                             ; copy to index
        txs                             ; set stack (dump FOR structure)
A_A753                                  ;                               [A753]
        pla                             ; pull return address
        pla                             ; pull return address

        lda     #$09                    ; we need 18d bytes !
        jsr     CheckRoomStack          ; check room on stack for 2*A bytes
                                        ;                               [A3FB]
        jsr     FindNextColon           ; scan for next BASIC statement ([:] or
                                        ; [EOL])                        [A906]

        clc                             ; clear carry for add
        tya                             ; copy index to A
        adc     TXTPTR                  ; add BASIC execute pointer LB
        pha                             ; push onto stack

        lda     TXTPTR+1                ; get BASIC execute pointer HB
        adc     #$00                    ; add carry
        pha                             ; push onto stack

        lda     CURLIN+1                ; get current line number HB
        pha                             ; push onto stack

        lda     CURLIN                  ; get current line number LB
        pha                             ; push onto stack

        lda     #TK_TO                  ; set "TO" token
        jsr     Chk4CharInA             ; scan for CHR$(A), else do syntax error
                                        ; then warm start               [AEFF]
        jsr     CheckIfNumeric          ; check if source is numeric, else do
                                        ; type mismatch                 [AD8D]
        jsr     EvalExpression          ; evaluate expression and check is
                                        ; numeric, else do type mismatch [AD8A]
        lda     FACSGN                  ; get FAC1 sign (b7)
        ora     #$7F                    ; set all non sign bits
        and     FacMantissa             ; and FAC1 mantissa 1
        sta     FacMantissa             ; save FAC1 mantissa 1

        lda     #<bcFOR2                ; set return address LB
        ldy     #>bcFOR2                ; set return address HB
        sta     INDEX                   ; save return address LB
        sty     INDEX+1                 ; save return address HB

        jmp     FAC1ToStack             ; round FAC1 and put on stack, returns
                                        ; to next instruction           [AE43]

bcFOR2                                  ;                               [A78B]
        lda     #<Constant1             ; set 1 pointer low address, default
                                        ; step size
        ldy     #>Constant1             ; set 1 pointer high address
        jsr     UnpackAY2FAC1           ; unpack memory (AY) into FAC1  [BBA2]

        jsr     CHRGOT                  ; scan memory                   [0079]
        cmp     #TK_STEP                ; compare with STEP token
        bne     A_A79F                  ; if not "STEP" continue

; was step so ....

        jsr     CHRGET                  ; increment and scan memory     [0073]
        jsr     EvalExpression          ; evaluate expression and check is
                                        ; numeric, else do type mismatch [AD8A]
A_A79F                                  ;                               [A79F]
        jsr     GetFacSign              ; get FAC1 sign, return A = $FF -ve,
                                        ; A = $01 +ve   [BC2B]
        jsr     SgnFac1ToStack          ; push sign, round FAC1 and put on stack
                                        ;                               [AE38]

        lda     FORPNT+1                ; get FOR/NEXT variable pointer HB
        pha                             ; push on stack

        lda     FORPNT                  ; get FOR/NEXT variable pointer LB
        pha                             ; push on stack

        lda     #TK_FOR                 ; get FOR token
        pha                             ; push on stack


;******************************************************************************
;
; interpreter inner loop

InterpretLoop                           ;                               [A7AE]
        jsr     BasChkStopKey           ; do CRTL-C check vector        [A82C]

        lda     TXTPTR                  ; get the BASIC execute pointer LB
        ldy     TXTPTR+1                ; get the BASIC execute pointer HB
        cpy     #$02                    ; compare the HB with $02xx
        nop                             ; unused byte
        beq     A_A7BE                  ; if immediate mode skip the continue
                                        ; pointer save
        sta     OLDTXT                  ; save the continue pointer LB
        sty     OLDTXT+1                ; save the continue pointer HB
A_A7BE                                  ;                               [A7BE]
        ldy     #$00                    ; clear the index
        lda     (TXTPTR),Y              ; get a BASIC byte
        bne     A_A807                  ; if not [EOL] go test for ":"

        ldy     #$02                    ; else set the index
        lda     (TXTPTR),Y              ; get next line pointer HB
        clc                             ; clear carry for no "BREAK" message
        bne     A_A7CE                  ; branch if not end of program

        jmp     bcEND2                  ; else go to immediate mode, was
                                        ; immediate or [EOT] marker     [A84B]
A_A7CE                                  ;                               [A7CE]
        iny                             ; increment index
        lda     (TXTPTR),Y              ; get line number LB
        sta     CURLIN                  ; save current line number LB
        
        iny                             ; increment index
        lda     (TXTPTR),Y              ; get line # HB
        sta     CURLIN+1                ; save current line number HB
        
        tya                             ; A now = 4
        adc     TXTPTR                  ; add BASIC execute pointer LB, now
                                        ; points to code
        sta     TXTPTR                  ; save BASIC execute pointer LB
        bcc     InterpretLoop2          ; branch if no overflow

        inc     TXTPTR+1                ; else increment BASIC execute pointer
                                        ; HB
InterpretLoop2                          ;                               [A7E1]
        jmp     (IGONE)                 ; do start new BASIC code


;******************************************************************************
;
; start new BASIC code, the start new BASIC code vector is initialised to point
; here

InterpretLoop3                          ;                               [A7E4]
        jsr     CHRGET                  ; increment and scan memory     [0073]
        jsr     DecodeBASIC             ; go interpret BASIC code from BASIC
                                        ; execute pointer               [A7ED]
        jmp     InterpretLoop           ; loop                          [A7AE]


;******************************************************************************
;
; go interpret BASIC code from BASIC execute pointer

DecodeBASIC                             ;                               [A7ED]
        beq     A_A82B                  ; if the first byte is null just exit

DecodeBASIC2                            ;                               [A7EF]
        sbc     #$80                    ; normalise the token
        bcc     A_A804                  ; if wasn't token go do LET

        cmp     #TK_TAB-$80             ; compare with token for TAB(-$80
        bcs     A_A80E                  ; branch if >= TAB(

        asl                             ; *2 bytes per vector
        tay                             ; copy to index

        lda     TblBasicInstr+1,Y       ; get vector HB
        pha                             ; push on stack

        lda     TblBasicInstr,Y         ; get vector LB
        pha                             ; push on stack

        jmp     CHRGET                  ; increment and scan memory and return.
                                        ; The return in [0073] this case calls
                                        ; the command code, the return from
                                        ; that will eventually return to the
                                        ; interpreter inner loop above
A_A804                                  ;                               [A804]
        jmp     bcLET                   ; perform LET                   [A9A5]

; was not [EOL]
A_A807                                  ;                               [A807]
        cmp     #':'                    ; comapre with ":"
        beq     InterpretLoop2          ; if ":" go execute new code

; else ...
A_A80B                                  ;                               [A80B]
        jmp     SyntaxError             ; do syntax error then warm start [AF08]

; token was >= TAB(
A_A80E                                  ;                               [A80E]
        cmp     #TK_GO-$80              ; compare with the token for GO
        bne     A_A80B                  ; if not "GO" do syntax error then warm
                                        ; start
; else was "GO"

        jsr     CHRGET                  ; increment and scan memory     [0073]

        lda     #TK_TO                  ; set "TO" token
        jsr     Chk4CharInA             ; scan for CHR$(A), else do syntax error
                                        ; then warm start               [AEFF]

        jmp     bcGOTO                  ; perform GOTO                  [A8A0]


;******************************************************************************
;
; perform RESTORE

bcRESTORE 
        sec                             ; set carry for subtract
        lda     TXTTAB                  ; get start of memory LB
        sbc     #$01                    ; -1
        ldy     TXTTAB+1                ; get start of memory HB
        bcs     bcRESTORE2              ; branch if no rollunder

        dey                             ; else decrement HB
bcRESTORE2                              ;                               [A827]
        sta     DATPTR                  ; set DATA pointer LB
        sty     DATPTR+1                ; set DATA pointer HB
A_A82B                                  ;                               [A82B]
        rts


;******************************************************************************
;
; do CRTL-C check vector

BasChkStopKey                           ;                               [A82C]
        jsr     ScanStopKey             ; scan stop key                 [FFE1]


;******************************************************************************
;
; perform STOP

bcSTOP 
        bcs     A_A832                  ; if carry set do BREAK instead of just
                                        ; END

;******************************************************************************
;
; perform END

bcEND 
        clc                             ; clear carry
A_A832                                  ;                               [A832]
        bne     A_A870                  ; return if wasn't CTRL-C

        lda     TXTPTR                  ; get BASIC execute pointer LB
        ldy     TXTPTR+1                ; get BASIC execute pointer HB
        ldx     CURLIN+1                ; get current line number HB

        inx                             ; increment it
        beq     A_A849                  ; branch if was immediate mode

        sta     OLDTXT                  ; save continue pointer LB
        sty     OLDTXT+1                ; save continue pointer HB

        lda     CURLIN                  ; get current line number LB
        ldy     CURLIN+1                ; get current line number HB
        sta     OLDLIN                  ; save break line number LB
        sty     OLDLIN+1                ; save break line number HB
A_A849                                  ;                               [A849]
        pla                             ; dump return address LB
        pla                             ; dump return address HB
bcEND2                                  ;                               [A84B]
        lda     #<TxtBreak              ; set [CR][LF]"BREAK" pointer LB
        ldy     #>TxtBreak              ; set [CR][LF]"BREAK" pointer HB
        bcc     A_A854                  ; if was program end skip the print
                                        ; string
        jmp     OutputMessage           ; print string and do warm start [A469]

A_A854                                  ;                               [A854]
        jmp     BasWarmStart2           ; do warm start                 [E386]


;******************************************************************************
;
; perform CONT

bcCONT 
        bne     A_A870                  ; exit if following byte to allow
                                        ; syntax error
        ldx     #$1A                    ; error code $1A, can't continue error
        ldy     OLDTXT+1                ; get continue pointer HB
        bne     A_A862                  ; go do continue if we can

        jmp     OutputErrMsg            ; else do error #X then warm start
                                        ; [A437]
; we can continue so ...
A_A862                                  ;                               [A862]
        lda     OLDTXT                  ; get continue pointer LB
        sta     TXTPTR                  ; save BASIC execute pointer LB

        sty     TXTPTR+1                ; save BASIC execute pointer HB

        lda     OLDLIN                  ; get break line LB
        ldy     OLDLIN+1                ; get break line HB
        sta     CURLIN                  ; set current line number LB
        sty     CURLIN+1                ; set current line number HB
A_A870                                  ;                               [A870]
        rts


;******************************************************************************
;
; perform RUN

bcRUN 
        php                             ; save status

        lda     #$00                    ; no control or kernal messages
        jsr     CtrlKernalMsg           ; control kernal messages       [FF90]

        plp                             ; restore status
        bne     A_A87D                  ; branch if RUN n

        jmp     ResetExecPtr            ; reset execution to start, clear
                                        ; variables, flush stack        [A659]
                                        ; and return
A_A87D                                  ;                               [A87D]
        jsr     bcCLR2                  ; go do "CLEAR"                 [A660]
        jmp     bcGOSUB2                ; get n and do GOTO n           [A897]


;******************************************************************************
;
; perform GOSUB

bcGOSUB 
        lda     #$03                    ; need 6 bytes for GOSUB
        jsr     CheckRoomStack          ; check room on stack for 2*A bytes
                                        ;                               [A3FB]
        lda     TXTPTR+1                ; get BASIC execute pointer HB
        pha                             ; save it

        lda     TXTPTR                  ; get BASIC execute pointer LB
        pha                             ; save it

        lda     CURLIN+1                ; get current line number HB
        pha                             ; save it

        lda     CURLIN                  ; get current line number LB
        pha                             ; save it

        lda     #TK_GOSUB               ; token for GOSUB
        pha                             ; save it
bcGOSUB2                                ;                               [A897]
        jsr     CHRGOT                  ; scan memory                   [0079]
        jsr     bcGOTO                  ; perform GOTO                  [A8A0]
        jmp     InterpretLoop           ; go do interpreter inner loop  [A7AE]


;******************************************************************************
;
; perform GOTO

bcGOTO 
        jsr     LineNum2Addr            ; get fixed-point number into temporary
                                        ; integer                       [A96B]
        jsr     FindEndOfLine           ; scan for next BASIC line      [A909]

        sec                             ; set carry for subtract
        lda     CURLIN                  ; get current line number LB
        sbc     LINNUM                  ; subtract temporary integer LB

        lda     CURLIN+1                ; get current line number HB
        sbc     LINNUM+1                ; subtract temporary integer HB
        bcs     A_A8BC                  ; if current line number >= temporary
                                        ; integer, go search from the start of
                                        ; memory
        tya                             ; else copy line index to A
        sec                             ; set carry (+1)
        adc     TXTPTR                  ; add BASIC execute pointer LB
        ldx     TXTPTR+1                ; get BASIC execute pointer HB
        bcc     A_A8C0                  ; branch if no overflow to HB

        inx                             ; increment HB
        bcs     A_A8C0                  ; branch always (can never be carry)


;******************************************************************************
;
; search for line number in temporary integer from start of memory pointer

A_A8BC                                  ;                               [A8BC]
        lda     TXTTAB                  ; get start of memory LB
        ldx     TXTTAB+1                ; get start of memory HB


;******************************************************************************
;
; search for line # in temporary integer from (AX)

A_A8C0                                  ;                               [A8C0]
        jsr     CalcStartAddr2          ; search Basic for temp integer line
                                        ; number from AX                [A617]
        bcc     A_A8E3                  ; if carry clear go do unsdefined
                                        ; statement error
; carry all ready set for subtract
        lda     FacTempStor+8           ; get pointer LB
        sbc     #$01                    ; -1
        sta     TXTPTR                  ; save BASIC execute pointer LB

        lda     FacTempStor+9           ; get pointer HB
        sbc     #$00                    ; subtract carry
        sta     TXTPTR+1                ; save BASIC execute pointer HB
A_A8D1                                  ;                               [A8D1]
        rts


;******************************************************************************
;
; perform RETURN

bcRETURN 
        bne     A_A8D1                  ; exit if following token to allow
                                        ; syntax error
        lda     #$FF                    ; set byte so no match possible
        sta     FORPNT+1                ; save FOR/NEXT variable pointer HB
        jsr     SrchForNext             ; search the stack for FOR or GOSUB
                                        ; activity, get token off stack [A38A]
        txs                             ; correct the stack
        cmp     #TK_GOSUB               ; compare with GOSUB token
        beq     A_A8EB                  ; if matching GOSUB go continue RETURN

        ldx     #$0C                    ; else error code $04, return without
                                        ; gosub error
.byte   $2C                             ; makes next line BIT $11A2
A_A8E3                                  ;                               [A8E3]
        ldx     #$11                    ; error code $11, undefined statement
                                        ; error
        jmp     OutputErrMsg            ; do error #X then warm start   [A437]

A_A8E8                                  ;                               [A8E8]
        jmp     SyntaxError             ; do syntax error then warm start [AF08]

; was matching GOSUB token
A_A8EB                                  ;                               [A8EB]
        pla                             ; dump token byte
        pla                             ; pull return line LB
        sta     CURLIN                  ; save current line number LB
        pla                             ; pull return line HB
        sta     CURLIN+1                ; save current line number HB
        pla                             ; pull return address LB
        sta     TXTPTR                  ; save BASIC execute pointer LB
        pla                             ; pull return address HB
        sta     TXTPTR+1                ; save BASIC execute pointer HB


;******************************************************************************
;
; perform DATA

bcDATA 
        jsr     FindNextColon           ; scan for next BASIC statement ([:] or
                                        ; [EOL])                        [A906]

;******************************************************************************
;
; add Y to the BASIC execute pointer

bcDATA2                                 ;                               [A8FB]
        tya                             ; copy index to A
S_A8FC 
        clc                             ; clear carry for add
        adc     TXTPTR                  ; add BASIC execute pointer LB
        sta     TXTPTR                  ; save BASIC execute pointer LB
        bcc     A_A905                  ; skip increment if no carry

        inc     TXTPTR+1                ; else increment BASIC execute pointer
                                        ; HB
A_A905                                  ;                               [A905]
        rts


;******************************************************************************
;
; scan for next BASIC statement ([:] or [EOL])
; returns Y as index to [:] or [EOL]

FindNextColon                           ;                               [A906]
        ldx     #':'                    ; set look for character = ":"
.byte   $2C                             ; makes next line BIT $00A2


;******************************************************************************
;
; scan for next BASIC line
; returns Y as index to [EOL]

FindEndOfLine                           ;                               [A909]
        ldx     #$00                    ; set alternate search character = [EOL]
        stx     CHARAC                  ; store alternate search character

        ldy     #$00                    ; set search character = [EOL]
        sty     ENDCHR                  ; save the search character
A_A911                                  ;                               [A911]
        lda     ENDCHR                  ; get search character
        ldx     CHARAC                  ; get alternate search character
        sta     CHARAC                  ; make search character = alternate
                                        ; search character
FindOtherChar                           ;                               [A917]
        stx     ENDCHR                  ; make alternate search character =
                                        ; search character
A_A919                                  ;                               [A919]
        lda     (TXTPTR),Y              ; get BASIC byte
        beq     A_A905                  ; exit if null [EOL]

        cmp     ENDCHR                  ; compare with search character
        beq     A_A905                  ; exit if found

        iny                             ; else increment index

        cmp     #'"'                    ; compare current character with open
                                        ; quote
        bne     A_A919                  ; if found go swap search character for
                                        ; alternate search character
        beq     A_A911                  ; loop for next character, branch always


;******************************************************************************
;
; perform IF

bcIF 
        jsr     EvaluateValue           ; evaluate expression           [AD9E]

        jsr     CHRGOT                  ; scan memory                   [0079]
        cmp     #TK_GOTO                ; compare with "GOTO" token
        beq     A_A937                  ; if it was  the token for GOTO go do
                                        ; IF ... GOTO
; wasn't IF ... GOTO so must be IF ... THEN
        lda     #TK_THEN                ; set "THEN" token
        jsr     Chk4CharInA             ; scan for CHR$(A), else do syntax error
                                        ; then warm start               [AEFF]
A_A937                                  ;                               [A937]
        lda     FACEXP                  ; get FAC1 exponent
        bne     A_A940                  ; if result was non zero continue
                                        ; execution
; else REM rest of line


;******************************************************************************
;
; perform REM

bcREM 
        jsr     FindEndOfLine           ; scan for next BASIC line      [A909]
        beq     bcDATA2                 ; add Y to the BASIC execute pointer and
                                        ; return, branch always

; result was non zero so do rest of line
A_A940                                  ;                               [A940]
        jsr     CHRGOT                  ; scan memory                   [0079]
        bcs     A_A948                  ; branch if not numeric character, is
                                        ; variable or keyword
        jmp     bcGOTO                  ; else perform GOTO n           [A8A0]

; is variable or keyword
A_A948                                  ;                               [A948]
        jmp     DecodeBASIC             ; interpret BASIC code from BASIC
                                        ; execute pointer               [A7ED]

;******************************************************************************
;
; perform ON

bcON 
        jsr     GetByteParm2            ; get byte parameter            [B79E]
        pha                             ; push next character
        cmp     #TK_GOSUB               ; compare with GOSUB token
        beq     A_A957                  ; if GOSUB go see if it should be
                                        ; executed
A_A953                                  ;                               [A953]
        cmp     #TK_GOTO                ; compare with GOTO token
        bne     A_A8E8                  ; if not GOTO do syntax error then warm
                                        ; start
; next character was GOTO or GOSUB, see if it should be executed

A_A957                                  ;                               [A957]
        dec     FacMantissa+3           ; decrement the byte value
        bne     A_A95F                  ; if not zero go see if another line
                                        ; number exists
        pla                             ; pull keyword token
        jmp     DecodeBASIC2            ; go execute it                 [A7EF]

A_A95F                                  ;                               [A95F]
        jsr     CHRGET                  ; increment and scan memory     [0073]
        jsr     LineNum2Addr            ; get fixed-point number into temporary
                                        ; integer                       [A96B]
        cmp     #','                    ; compare next character with ","
        beq     A_A957                  ; loop if ","

        pla                             ; else pull keyword token, ran out of
                                        ; options
A_A96A                                  ;                               [A96A]
        rts


;******************************************************************************
;
; get fixed-point number into temporary integer

LineNum2Addr                            ;                               [A96B]
        ldx     #$00                    ; clear X
        stx     LINNUM                  ; clear temporary integer LB
        stx     LINNUM+1                ; clear temporary integer HB
LineNum2Addr2                           ;                               [A971]
        bcs     A_A96A                  ; return if carry set, end of scan,
                                        ; character was not 0-9
        sbc     #'0'-1                  ; subtract $30, $2F+carry, from byte
        sta     CHARAC                  ; store #

        lda     LINNUM+1                ; get temporary integer HB
        sta     INDEX                   ; save it for now
        cmp     #$19                    ; compare with $19
        bcs     A_A953                  ; branch if >= this makes the maximum
                                        ; line number 63999 because the next
; bit does $1900 * $0A = $FA00 = 64000 decimal. the branch target is really the
; SYNTAX error at A_A8E8 but that is too far so an intermediate; compare and
; branch to that location is used. the problem with this is that line number
; that gives a partial result from $8900 to $89FF, 35072x to 35327x, will pass
; the new target compare and will try to execute the remainder of the ON n
; GOTO/GOSUB. a solution to this is to copy the byte in A before the branch to
; X and then branch to A_A955 skipping the second compare

        lda     LINNUM                  ; get temporary integer LB
        asl                             ; *2 LB
        rol     INDEX                   ; *2 HB
        asl                             ; *2 LB
        rol     INDEX                   ; *2 HB (*4)
        adc     LINNUM                  ; + LB (*5)
        sta     LINNUM                  ; save it

        lda     INDEX                   ; get HB temp
        adc     LINNUM+1                ; + HB (*5)
        sta     LINNUM+1                ; save it

        asl     LINNUM                  ; *2 LB (*10d)
        rol     LINNUM+1                ; *2 HB (*10d)

        lda     LINNUM                  ; get LB
        adc     CHARAC                  ; add #
        sta     LINNUM                  ; save LB
        bcc     A_A99F                  ; branch if no overflow to HB

        inc     LINNUM+1                ; else increment HB
A_A99F                                  ;                               [A99F]
        jsr     CHRGET                  ; increment and scan memory     [0073]
        jmp     LineNum2Addr2           ; loop for next character       [A971]


;******************************************************************************
;
; perform LET

bcLET 
        jsr     GetAddrVar              ; get variable address          [B08B]
        sta     FORPNT                  ; save variable address LB
        sty     FORPNT+1                ; save variable address HB

        lda     #TK_EQUAL               ; $B2 is "=" token
        jsr     Chk4CharInA             ; scan for CHR$(A), else do syntax error
                                        ; then warm start               [AEFF]
        lda     INTFLG                  ; get data type flag, $80 = integer,
                                        ; $00 = float
        pha                             ; push data type flag

        lda     VALTYP                  ; get data type flag, $FF = string,
                                        ; $00 = numeric
        pha                             ; push data type flag

        jsr     EvaluateValue           ; evaluate expression           [AD9E]

        pla                             ; pop data type flag
        rol                             ; string bit into carry
        jsr     ChkIfNumStr             ; do type match check           [AD90]
        bne     A_A9D9                  ; branch if string

        pla                             ; pop integer/float data type flag

; assign value to numeric variable

SetIntegerVar                           ;                               [A9C2]
        bpl     A_A9D6                  ; branch if float

; expression is numeric integer
        jsr     RoundFAC1               ; round FAC1                    [BC1B]
        jsr     EvalInteger3            ; evaluate integer expression, no sign
                                        ; check                         [B1BF]
        ldy     #$00                    ; clear index
        lda     FacMantissa+2           ; get FAC1 mantissa 3
        sta     (FORPNT),Y              ; save as integer variable LB

        iny                             ; increment index
        lda     FacMantissa+3           ; get FAC1 mantissa 4
        sta     (FORPNT),Y              ; save as integer variable HB

        rts

; Set the value of a real variable
A_A9D6                                  ;                               [A9D6]
        jmp     Fac1ToVarPtr            ; pack FAC1 into variable pointer and
                                        ; return                        [BBD0]

; assign value to numeric variable

A_A9D9                                  ;                               [A9D9]
        pla                             ; dump integer/float data type flag
SetValueString                          ;                               [A9DA]
        ldy     FORPNT+1                ; get variable pointer HB
        cpy     #>L_BF13                ; was it TI$ pointer
        bne     A_AA2C                  ; branch if not

; else it's TI$ = <expr$>
        jsr     PopStrDescStk           ; pop string off descriptor stack, or
                                        ; from top of string space returns with
                                        ; A = length, X = pointer LB, Y =
                                        ; pointer HB                    [B6A6]
        cmp     #$06                    ; compare length with 6
        bne     A_AA24                  ; if length not 6 do illegal quantity
                                        ; error then warm start
        ldy     #$00                    ; clear index
        sty     FACEXP                  ; clear FAC1 exponent
        sty     FACSGN                  ; clear FAC1 sign (b7)
A_A9ED                                  ;                               [A9ED]
        sty     FBUFPT                  ; save index

        jsr     ChkCharIsNum            ; check and evaluate numeric digit
                                        ;                               [AA1D]
        jsr     Fac1x10                 ; multiply FAC1 by 10           [BAE2]

        inc     FBUFPT                  ; increment index

        ldy     FBUFPT                  ; restore index
        jsr     ChkCharIsNum            ; check and evaluate numeric digit
                                        ;                               [AA1D]
        jsr     CopyFAC1toFAC2          ; round and copy FAC1 to FAC2   [BC0C]
        tax                             ; copy FAC1 exponent
        beq     A_AA07                  ; branch if FAC1 zero

        inx                             ; increment index, * 2
        txa                             ; copy back to A

        jsr     FAC1plFAC2x2            ; FAC1 = (FAC1 + (FAC2 * 2)) * 2 =
                                        ; FAC1 * 6                      [BAED]
A_AA07                                  ;                               [AA07]
        ldy     FBUFPT                  ; get index
        iny                             ; increment index
        cpy     #$06                    ; compare index with 6
        bne     A_A9ED                  ; loop if not 6

        jsr     Fac1x10                 ; multiply FAC1 by 10           [BAE2]
        jsr     FAC1Float2Fix           ; convert FAC1 floating to fixed [BC9B]

        ldx     FacMantissa+2           ; get FAC1 mantissa 3
        ldy     FacMantissa+1           ; get FAC1 mantissa 2
        lda     FacMantissa+3           ; get FAC1 mantissa 4

        jmp     SetClock                ; set real time clock and return [FFDB]


;******************************************************************************
;
; check and evaluate numeric digit

ChkCharIsNum                            ;                               [AA1D]
        lda     (INDEX),Y               ; get byte from string
        jsr     NumericTest             ; clear Cb if numeric. this call should
                                        ; be to $84 as the code from NumericTest
                                        ; first comapres the byte with [SPACE]
                                        ; and does a BASIC increment and get if
                                        ; it is                         [0080]
        bcc     A_AA27                  ; branch if numeric
A_AA24                                  ;                               [AA24]
        jmp     IllegalQuant            ; do illegal quantity error then warm
                                        ; start                         [B248]
A_AA27                                  ;                               [AA27]
        sbc     #'0'-1                  ; subtract $2F + carry to convert ASCII
                                        ; to binary
        jmp     EvalNewDigit            ; evaluate new ASCII digit and return
                                        ;                               [BD7E]

;******************************************************************************
;
; assign value to numeric variable, but not TI$

A_AA2C                                  ;                               [AA2C]
        ldy     #$02                    ; index to string pointer HB
        lda     (FacMantissa+2),Y       ; get string pointer HB
        cmp     FRETOP+1                ; compare with bottom of string space HB
        bcc     A_AA4B                  ; branch if string pointer HB is less
                                        ; than bottom of string space HB

        bne     A_AA3D                  ; branch if string pointer HB is greater
                                        ; than bottom of string space HB

; else HBs were equal
        dey                             ; decrement index to string pointer LB
        lda     (FacMantissa+2),Y       ; get string pointer LB
        cmp     FRETOP                  ; compare with bottom of string space LB
        bcc     A_AA4B                  ; branch if string pointer LB is less
                                        ; than bottom of string space LB

A_AA3D                                  ;                               [AA3D]
        ldy     FacMantissa+3           ; get descriptor pointer HB
        cpy     VARTAB+1                ; compare with start of variables HB
        bcc     A_AA4B                  ; branch if less, is on string stack

        bne     A_AA52                  ; if greater make space and copy string

; else HBs were equal
        lda     FacMantissa+2           ; get descriptor pointer LB
        cmp     VARTAB                  ; compare with start of variables LB
        bcs     A_AA52                  ; if greater or equal make space and 
                                        ; copy string
A_AA4B                                  ;                               [AA4B]
        lda     FacMantissa+2           ; get descriptor pointer LB
        ldy     FacMantissa+3           ; get descriptor pointer HB
        jmp     A_AA68                  ; go copy descriptor to variable [AA68]

A_AA52                                  ;                               [AA52]
        ldy     #$00                    ; clear index
        lda     (FacMantissa+2),Y       ; get string length
        jsr     StringVector            ; copy descriptor pointer and make
                                        ; string space A bytes long     [B475]
        lda     TempPtr                 ; copy old descriptor pointer LB
        ldy     TempPtr+1               ; copy old descriptor pointer HB
        sta     ARISGN                  ; save old descriptor pointer LB
        sty     FACOV                   ; save old descriptor pointer HB

        jsr     Str2UtilPtr             ; copy string from descriptor to utility
                                        ; pointer                       [B67A]

        lda     #<FACEXP                ; get descriptor pointer LB
        ldy     #>FACEXP                ; get descriptor pointer HB
A_AA68                                  ;                               [AA68]
        sta     TempPtr                 ; save descriptor pointer LB
        sty     TempPtr+1               ; save descriptor pointer HB

        jsr     ClrDescrStack           ; clean descriptor stack, YA = pointer
                                        ;                               [B6DB]
        ldy     #$00                    ; clear index
        lda     (TempPtr),Y             ; get string length from new descriptor
        sta     (FORPNT),Y              ; copy string length to variable

        iny                             ; increment index
        lda     (TempPtr),Y             ; get string pointer LB from new
                                        ; descriptor
        sta     (FORPNT),Y              ; copy string pointer LB to variable

        iny                             ; increment index
        lda     (TempPtr),Y             ; get string pointer HB from new
                                        ; descriptor
        sta     (FORPNT),Y              ; copy string pointer HB to variable

        rts


;******************************************************************************
;
; perform PRINT#

bcPRINTH 
        jsr     bcCMD                   ; perform CMD                   [AA86]
        jmp     bcINPUTH2               ; close input and output channels and
                                        ; return                        [ABB5]

;******************************************************************************
;
; perform CMD

bcCMD 
        jsr     GetByteParm2            ; get byte parameter            [B79E]
        beq     A_AA90                  ; branch if following byte is ":" or
                                        ; [EOT]
        lda     #','                    ; set ","
        jsr     Chk4CharInA             ; scan for CHR$(A), else do syntax error
                                        ; then warm start               [AEFF]
A_AA90                                  ;                               [AA90]
        php                             ; save status

        stx     CurIoChan               ; set current I/O channel

        jsr     OpenChan4OutpA          ; open channel for output with error
                                        ; check                         [E118]
        plp                             ; restore status
        jmp     bcPRINT                 ; perform PRINT                 [AAA0]

A_AA9A                                  ;                               [AA9A]
        jsr     OutputString2           ; print string from utility pointer
                                        ;                               [AB21]
A_AA9D                                  ;                               [AA9D]
        jsr     CHRGOT                  ; scan memory                   [0079]


;******************************************************************************
;
; perform PRINT

bcPRINT 
        beq     OutCRLF                 ; if nothing following just print CR/LF

bcPRINT2                                ;                               [AAA2]
        beq     A_AAE7                  ; exit if nothing following, end of
                                        ; PRINT branch
        cmp     #TK_TAB                 ; compare with token for TAB(
        beq     A_AAF8                  ; if TAB( go handle it

        cmp     #TK_SPC                 ; compare with token for SPC(
        clc                             ; flag SPC(
        beq     A_AAF8                  ; if SPC( go handle it

        cmp     #','                    ; compare with ","
        beq     A_AAE8                  ; if "," go skip to the next TAB
                                        ; position
        cmp     #';'                    ; compare with ";"
        beq     A_AB13                  ; if ";" go continue the print loop

        jsr     EvaluateValue           ; evaluate expression           [AD9E]
        bit     VALTYP                  ; test data type flag, $FF = string,
                                        ; $00 = numeric
        bmi     A_AA9A                  ; if string go print string, scan memory
                                        ; and continue PRINT

        jsr     FAC1toASCII             ; convert FAC1 to ASCII string result
                                        ; in (AY)                       [BDDD]
        jsr     QuoteStr2UtPtr          ; print " terminated string to utility
                                        ; pointer                       [B487]
        jsr     OutputString2           ; print string from utility pointer
                                        ;                               [AB21]
        jsr     PrintSpace              ; print [SPACE] or [CURSOR RIGHT] [AB3B]
        bne     A_AA9D                  ; always -> go scan memory and continue
                                        ; PRINT

;******************************************************************************
;
; set XY to CommandBuf - 1 

SetXY2CmdBuf                            ;                               [AACA]
        lda     #$00                    ; clear A
        sta     CommandBuf,X            ; clear first byte of input buffer

        ldx     #<CommandBuf-1          ; CommandBuf - 1 LB
        ldy     #>CommandBuf-1          ; CommandBuf - 1 HB

        lda     CurIoChan               ; get current I/O channel
        bne     A_AAE7                  ; exit if not default channel


;******************************************************************************
;
; print CR/LF

OutCRLF                                 ;                               [AAD7]
        lda     #$0D                    ; set [CR]
        jsr     PrintChar               ; print the character           [AB47]
        bit     CurIoChan               ; test current I/O channel
        bpl     EOR_FF                  ; if ?? toggle A, EOR #$FF and return

        lda     #$0A                    ; set [LF]
        jsr     PrintChar               ; print the character           [AB47]

; toggle A

EOR_FF                                  ;                               [AAE5]
        eor     #$FF                    ; invert A
A_AAE7                                  ;                               [AAE7]
        rts

; was ","
A_AAE8                                  ;                               [AAE8]
        sec                             ; set C flag for read cursor position
        jsr     CursorPosXY             ; read/set X,Y cursor position  [FFF0]
        tya                             ; copy cursor Y

        sec                             ; set carry for subtract
A_AAEE                                  ;                               [AAEE]
        sbc     #$0A                    ; subtract one TAB length
        bcs     A_AAEE                  ; loop if result was +ve

        eor     #$FF                    ; complement it
        adc     #$01                    ; +1, twos complement
        bne     A_AB0E                  ; always print A spaces, result is
                                        ; never $00
A_AAF8                                  ;                               [AAF8]
        php                             ; save TAB( or SPC( status

        sec                             ; set Cb for read cursor position
        jsr     CursorPosXY             ; read/set X,Y cursor position  [FFF0]
        sty     TRMPOS                  ; save current cursor position

        jsr     GetByteParm             ; scan and get byte parameter   [B79B]
        cmp     #')'                    ; compare with ")"
        bne     A_AB5F                  ; if not ")" do syntax error

        plp                             ; restore TAB( or SPC( status
        bcc     A_AB0F                  ; branch if was SPC(

; else was TAB(
        txa                             ; copy TAB() byte to A
        sbc     TRMPOS                  ; subtract current cursor position
        bcc     A_AB13                  ; go loop for next if already past
                                        ; requited position
A_AB0E                                  ;                               [AB0E]
        tax                             ; copy [SPACE] count to X
A_AB0F                                  ;                               [AB0F]
        inx                             ; increment count
A_AB10                                  ;                               [AB10]
        dex                             ; decrement count
        bne     A_AB19                  ; branch if count was not zero

; was ";" or [SPACES] printed
A_AB13                                  ;                               [AB13]
        jsr     CHRGET                  ; increment and scan memory     [0073]
        jmp     bcPRINT2                ; continue print loop           [AAA2]

A_AB19                                  ;                               [AB19]
        jsr     PrintSpace              ; print [SPACE] or [CURSOR RIGHT] [AB3B]
        bne     A_AB10                  ; loop, branch always


;******************************************************************************
;
; print null terminated string

OutputString                            ;                               [AB1E]
        jsr     QuoteStr2UtPtr          ; print " terminated string to utility
                                        ; pointer                       [B487]

;******************************************************************************
;
; print string from utility pointer

OutputString2                           ;                               [AB21]
        jsr     PopStrDescStk           ; pop string off descriptor stack, or
                                        ; from top of string            [B6A6]
                                        ; space returns with A = length, 
                                        ; X = pointer LB, Y = pointer HB
        tax                             ; copy length

        ldy     #$00                    ; clear index
        inx                             ; increment length, for pre decrement
                                        ; loop
OutputString3                           ;                               [AB28]
        dex                             ; decrement length
        beq     A_AAE7                  ; exit if done

        lda     (INDEX),Y               ; get byte from string
        jsr     PrintChar               ; print the character           [AB47]

        iny                             ; increment index

        cmp     #$0D                    ; compare byte with [CR]
        bne     OutputString3           ; loop if not [CR]

        jsr     EOR_FF                  ; toggle A, EOR #$FF. what is the point
                                        ; of this ??                    [AAE5]
        jmp     OutputString3           ; loop                          [AB28]


;******************************************************************************
;
; print [SPACE] or [CURSOR RIGHT]

PrintSpace                              ;                               [AB3B]
        lda     CurIoChan               ; get current I/O channel
        beq     A_AB42                  ; if default channel go output
                                        ; [CURSOR RIGHT]
        lda     #' '                    ; else output [SPACE]
.byte   $2C                             ; makes next line BIT $1DA9
A_AB42                                  ;                               [AB42]
        lda     #$1D                    ; set [CURSOR RIGHT]
.byte   $2C                             ; makes next line BIT $3FA9


;******************************************************************************
;
; print "?"

PrintQuestMark                          ;                               [AB45]
        lda     #'?'                    ; set "?"


;******************************************************************************
;
; print character

PrintChar                               ;                               [AB47]
        jsr     OutCharErrChan          ; output character to channel with
                                        ; error check                   [E10C]
        and     #$FF                    ; set the flags on A
        rts


;******************************************************************************
;
; bad input routine
; Check the variable INPFLG where the error lays

CheckINPFLG                             ;                               [AB4D]
        lda     INPFLG                  ; get INPUT mode flag, $00 = INPUT,
                                        ; $40 = GET, $98 = READ
        beq     A_AB62                  ; branch if INPUT

        bmi     A_AB57                  ; branch if READ

; else was GET
        ldy     #$FF                    ; set current line HB to -1, indicate
                                        ; immediate mode
        bne     A_AB5B                  ; branch always

; error with READ
A_AB57                                  ;                               [AB57]
        lda     DATLIN                  ; get current DATA line number LB
        ldy     DATLIN+1                ; get current DATA line number HB

; error with GET
A_AB5B                                  ;                               [AB5B]
        sta     CURLIN                  ; set current line number LB
        sty     CURLIN+1                ; set current line number HB
A_AB5F                                  ;                               [AB5F]
        jmp     SyntaxError             ; do syntax error then warm start [AF08]

; was INPUT
; error with INPUT
A_AB62                                  ;                               [AB62]
        lda     CurIoChan               ; get current I/O channel
        beq     A_AB6B                  ; branch if default channel

        ldx     #$18                    ; else error $18, file data error
        jmp     OutputErrMsg            ; do error #X then warm start   [A437]

A_AB6B                                  ;                               [AB6B]
        lda     #<txtREDOFROM           ; set "?REDO FROM START" pointer LB
        ldy     #>txtREDOFROM           ; set "?REDO FROM START" pointer HB
        jsr     OutputString            ; print null terminated string  [AB1E]

        lda     OLDTXT                  ; get continue pointer LB
        ldy     OLDTXT+1                ; get continue pointer HB
        sta     TXTPTR                  ; save BASIC execute pointer LB
        sty     TXTPTR+1                ; save BASIC execute pointer HB

        rts


;******************************************************************************
;
; perform GET

bcGET 
        jsr     ChkDirectMode           ; check not Direct, back here if ok
                                        ;                               [B3A6]
        cmp     #'#'                    ; compare with "#"
        bne     A_AB92                  ; branch if not GET#

        jsr     CHRGET                  ; increment and scan memory     [0073]
        jsr     GetByteParm2            ; get byte parameter            [B79E]

        lda     #','                    ; set ","
        jsr     Chk4CharInA             ; scan for CHR$(A), else do syntax error
                                        ; then warm start               [AEFF]
        stx     CurIoChan               ; set current I/O channel

        jsr     OpenChan4Inp0           ; open channel for input with error
                                        ; check                         [E11E]
A_AB92                                  ;                               [AB92]
        ldx     #<CommandBuf+1          ; set pointer LB
        ldy     #>CommandBuf+1          ; set pointer HB

        lda     #$00                    ; clear A
        sta     CommandBuf+1            ; ensure null terminator

        lda     #$40                    ; input mode = GET
        jsr     bcREAD2                 ; perform the GET part of READ  [AC0F]

        ldx     CurIoChan               ; get current I/O channel
        bne     A_ABB7                  ; if not default channel go do channel
                                        ; close and return
        rts


;******************************************************************************
;
; perform INPUT#

bcINPUTH 
        jsr     GetByteParm2            ; get byte parameter            [B79E]

        lda     #','                    ; set ","
        jsr     Chk4CharInA             ; scan for CHR$(A), else do syntax error
                                        ; then warm start               [AEFF]
        stx     CurIoChan               ; set current I/O channel

        jsr     OpenChan4Inp0           ; open channel for input with error
                                        ; check                         [E11E]
        jsr     bcINPUT2                ; perform INPUT with no prompt string
                                        ;                               [ABCE]


;******************************************************************************
;
; close input and output channels

bcINPUTH2                               ;                               [ABB5]
        lda     CurIoChan               ; get current I/O channel
A_ABB7                                  ;                               [ABB7]
        jsr     CloseIoChannls          ; close input and output channels [FFCC]

        ldx     #$00                    ; clear X
        stx     CurIoChan               ; clear current I/O channel, flag
                                        ; default
        rts


;******************************************************************************
;
; perform INPUT

bcINPUT 
        cmp     #'"'                    ; compare next byte with open quote
        bne     bcINPUT2                ; if no prompt string just do INPUT

        jsr     GetNextParm3            ; print "..." string            [AEBD]

        lda     #';'                    ; load A with ";"
        jsr     Chk4CharInA             ; scan for CHR$(A), else do syntax error
                                        ; then warm start               [AEFF]
        jsr     OutputString2           ; print string from utility pointer
                                        ;                               [AB21]
; done with prompt, now get data
bcINPUT2                                ;                               [ABCE]
        jsr     ChkDirectMode           ; check not Direct, back here if ok
                                        ;                               [B3A6]
        lda     #','                    ; set ","
        sta     CommandBuf-1            ; save to start of buffer - 1
A_ABD6                                  ;                               [ABD6]
        jsr     OutQuestMark            ; print "? " and get BASIC input [ABF9]

        lda     CurIoChan               ; get current I/O channel
        beq     A_ABEA                  ; branch if default I/O channel

        jsr     ReadIoStatus            ; read I/O status word          [FFB7]
        and     #$02                    ; mask no DSR/timeout
        beq     A_ABEA                  ; branch if not error

        jsr     bcINPUTH2               ; close input and output channels [ABB5]
        jmp     bcDATA                  ; perform DATA                  [A8F8]

A_ABEA                                  ;                               [ABEA]
        lda     CommandBuf              ; get first byte in input buffer
        bne     A_AC0D                  ; branch if not null

; else ..
        lda     CurIoChan               ; get current I/O channel
        bne     A_ABD6                  ; if not default channel go get BASIC
                                        ; input
        jsr     FindNextColon           ; scan for next BASIC statement ([:] or
                                        ; [EOL])                        [A906]
        jmp     bcDATA2                 ; add Y to the BASIC execute pointer
                                        ; and return                    [A8FB]

;******************************************************************************
;
; print "? " and get BASIC input

OutQuestMark                            ;                               [ABF9]
        lda     CurIoChan               ; get current I/O channel
        bne     A_AC03                  ; skip "?" prompt if not default channel

        jsr     PrintQuestMark          ; print "?"                     [AB45]
        jsr     PrintSpace              ; print [SPACE] or [CURSOR RIGHT] [AB3B]
A_AC03                                  ;                               [AC03]
        jmp     InputNewLine            ; call for BASIC input and return [A560]


;******************************************************************************
;
; perform READ

bcREAD 
        ldx     DATPTR                  ; get DATA pointer LB
        ldy     DATPTR+1                ; get DATA pointer HB
        lda     #$98                    ; set input mode = READ
.byte   $2C                             ; makes next line BIT $00A9
A_AC0D                                  ;                               [AC0D]
        lda     #$00                    ; set input mode = INPUT


;******************************************************************************
;
; perform GET

bcREAD2                                 ;                               [AC0F]
        sta     INPFLG                  ; set input mode flag, $00 = INPUT,
                                        ; $40 = GET, $98 = READ
        stx     INPPTR                  ; save READ pointer LB
        sty     INPPTR+1                ; save READ pointer HB

; READ, GET or INPUT next variable from list
bcREAD3                                 ;                               [AC15]
        jsr     GetAddrVar              ; get variable address          [B08B]
        sta     FORPNT                  ; save address LB
        sty     FORPNT+1                ; save address HB

        lda     TXTPTR                  ; get BASIC execute pointer LB
        ldy     TXTPTR+1                ; get BASIC execute pointer HB
        sta     TEMPSTR                 ; save BASIC execute pointer LB
        sty     TEMPSTR+1               ; save BASIC execute pointer HB

        ldx     INPPTR                  ; get READ pointer LB
        ldy     INPPTR+1                ; get READ pointer HB
        stx     TXTPTR                  ; save as BASIC execute pointer LB
        sty     TXTPTR+1                ; save as BASIC execute pointer HB

        jsr     CHRGOT                  ; scan memory                   [0079]
        bne     bcREAD4                 ; branch if not null

; pointer was to null entry
        bit     INPFLG                  ; test input mode flag, $00 = INPUT,
                                        ; $40 = GET, $98 = READ
        bvc     A_AC41                  ; branch if not GET

; else was GET
        jsr     GetCharFromIO           ; get character from input device with
                                        ; error check                   [E124]
        sta     CommandBuf              ; save to buffer

        ldx     #<CommandBuf-1          ; set pointer LB
        ldy     #>CommandBuf-1          ; set pointer HB
        bne     A_AC4D                  ; go interpret single character

A_AC41                                  ;                               [AC41]
        bmi     A_ACB8                  ; branch if READ

; else was INPUT
        lda     CurIoChan               ; get current I/O channel
        bne     A_AC4A                  ; skip "?" prompt if not default channel

        jsr     PrintQuestMark          ; print "?"                     [AB45]
A_AC4A                                  ;                               [AC4A]
        jsr     OutQuestMark            ; print "? " and get BASIC input [ABF9]
A_AC4D                                  ;                               [AC4D]
        stx     TXTPTR                  ; save BASIC execute pointer LB
        sty     TXTPTR+1                ; save BASIC execute pointer HB
bcREAD4                                 ;                               [AC51]
        jsr     CHRGET                  ; increment and scan memory, execute
                                        ; pointer now points to         [0073]
                                        ; start of next data or null terminator
        bit     VALTYP                  ; test data type flag, $FF = string,
                                        ; $00 = numeric
        bpl     A_AC89                  ; branch if numeric

; type is string
        bit     INPFLG                  ; test INPUT mode flag, $00 = INPUT,
                                        ; $40 = GET, $98 = READ
        bvc     A_AC65                  ; branch if not GET

; else do string GET
        inx                             ; clear X ??
        stx     TXTPTR                  ; save BASIC execute pointer LB

        lda     #$00                    ; clear A
        sta     CHARAC                  ; clear search character
        beq     A_AC71                  ; branch always

; is string INPUT or string READ
A_AC65                                  ;                               [AC65]
        sta     CHARAC                  ; save search character

        cmp     #'"'                    ; compare with "
        beq     A_AC72                  ; branch if quote

; string is not in quotes so ":", "," or $00 are the termination characters
        lda     #':'                    ; set ":"
        sta     CHARAC                  ; set search character

        lda     #','                    ; set ","
A_AC71                                  ;                               [AC71]
        clc                             ; clear carry for add
A_AC72                                  ;                               [AC72]
        sta     ENDCHR                  ; set scan quotes flag


        lda     TXTPTR                  ; get BASIC execute pointer LB
        ldy     TXTPTR+1                ; get BASIC execute pointer HB
        adc     #$00                    ; add to pointer LB. this add increments
                                        ; the pointer if the mode is INPUT or
                                        ; READ and the data is a "..." string
        bcc     A_AC7D                  ; branch if no rollover

        iny                             ; else increment pointer HB
A_AC7D                                  ;                               [AC7D]
        jsr     PrtStr2UtiPtr           ; print string to utility pointer [B48D]
        jsr     RestBasExecPtr          ; restore BASIC execute pointer from
                                        ; temp                          [B7E2]
        jsr     SetValueString          ; perform string LET            [A9DA]
        jmp     bcREAD5                 ; continue processing command   [AC91]

; GET, INPUT or READ is numeric
A_AC89                                  ;                               [AC89]
        jsr     String2FAC1             ; get FAC1 from string          [BCF3]

        lda     INTFLG                  ; get data type flag, $80 = integer,
                                        ; $00 = float
        jsr     SetIntegerVar           ; assign value to numeric variable
                                        ;                               [A9C2]
bcREAD5                                 ;                               [AC91]
        jsr     CHRGOT                  ; scan memory                   [0079]
        beq     A_AC9D                  ; branch if ":" or [EOL]

        cmp     #','                    ; comparte with ","
        beq     A_AC9D                  ; branch if ","

        jmp     CheckINPFLG             ; else go do bad input routine  [AB4D]

; string terminated with ":", "," or $00
A_AC9D                                  ;                               [AC9D]
        lda     TXTPTR                  ; get BASIC execute pointer LB
        ldy     TXTPTR+1                ; get BASIC execute pointer HB
        sta     INPPTR                  ; save READ pointer LB
        sty     INPPTR+1                ; save READ pointer HB

        lda     TEMPSTR                 ; get saved BASIC execute pointer LB
        ldy     TEMPSTR+1               ; get saved BASIC execute pointer HB
        sta     TXTPTR                  ; restore BASIC execute pointer LB
        sty     TXTPTR+1                ; restore BASIC execute pointer HB

        jsr     CHRGOT                  ; scan memory                   [0079]
        beq     A_ACDF                  ; branch if ":" or [EOL]

        jsr     Chk4Comma               ; scan for ",", else do syntax error
                                        ; then warm start               [AEFD]
        jmp     bcREAD3                 ; go READ or INPUT next variable from
                                        ; list                          [AC15]
; was READ
A_ACB8                                  ;                               [ACB8]
        jsr     FindNextColon           ; scan for next BASIC statement ([:] or
                                        ; [EOL])                        [A906]
        iny                             ; increment index to next byte
        tax                             ; copy byte to X
        bne     A_ACD1                  ; branch if ":"

        ldx     #$0D                    ; else set error $0D, out of data error
        iny                             ; incr. index to next line pointer HB
        lda     (TXTPTR),Y              ; get next line pointer HB
        beq     A_AD32                  ; branch if program end, eventually does
                                        ; error X
        iny                             ; increment index
        lda     (TXTPTR),Y              ; get next line # LB
        sta     DATLIN                  ; save current DATA line LB

        iny                             ; increment index
        lda     (TXTPTR),Y              ; get next line # HB
        iny                             ; increment index
        sta     DATLIN+1                ; save current DATA line HB
A_ACD1                                  ;                               [ACD1]
        jsr     bcDATA2                 ; add Y to the BASIC execute pointer
                                        ;                               [A8FB]
        jsr     CHRGOT                  ; scan memory                   [0079]
        tax                             ; copy the byte
        cpx     #TK_DATA                ; compare it with token for DATA
        bne     A_ACB8                  ; loop if not DATA

        jmp     bcREAD4                 ; continue evaluating READ      [AC51]

A_ACDF                                  ;                               [ACDF]
        lda     INPPTR                  ; get READ pointer LB
        ldy     INPPTR+1                ; get READ pointer HB

        ldx     INPFLG                  ; get INPUT mode flag, $00 = INPUT,
                                        ; $40 = GET, $98 = READ
        bpl     A_ACEA                  ; branch if INPUT or GET

        jmp     bcRESTORE2              ; else set data pointer and exit [A827]

A_ACEA                                  ;                               [ACEA]
        ldy     #$00                    ; clear index
        lda     (INPPTR),Y              ; get READ byte
        beq     A_ACFB                  ; exit if [EOL]

        lda     CurIoChan               ; get current I/O channel
        bne     A_ACFB                  ; exit if not default channel

        lda     #<txtEXTRA              ; set "?EXTRA IGNORED" pointer LB
        ldy     #>txtEXTRA              ; set "?EXTRA IGNORED" pointer HB
        jmp     OutputString            ; print null terminated string  [AB1E]

A_ACFB                                  ;                               [ACFB]
        rts


;******************************************************************************
;
; input error messages

txtEXTRA                                ;                               [ACFC]
.text   "?EXTRA IGNORED",$0D,$00

txtREDOFROM                             ;                               [AD0C]
.text   "?REDO FROM START",$0D,$00


;******************************************************************************
;
; perform NEXT

bcNEXT 
        bne     bcNEXT2                 ; branch if NEXT variable

        ldy     #$00                    ; else clear Y
        beq     A_AD27                  ; branch always

; NEXT variable

bcNEXT2                                 ;                               [AD24]
        jsr     GetAddrVar              ; get variable address          [B08B]
A_AD27                                  ;                               [AD27]
        sta     FORPNT                  ; save FOR/NEXT variable pointer LB
        sty     FORPNT+1                ; save FOR/NEXT variable pointer HB
                                        ; (HB cleared if no variable defined)
        jsr     SrchForNext             ; search the stack for FOR or GOSUB
                                        ; activity                      [A38A]
        beq     A_AD35                  ; branch if FOR, this variable, found

        ldx     #$0A                    ; else set error $0A, next without for
                                        ; error
A_AD32                                  ;                               [AD32]
        jmp     OutputErrMsg            ; do error #X then warm start   [A437]

; found this FOR variable
A_AD35                                  ;                               [AD35]
        txs                             ; update stack pointer

        txa                             ; copy stack pointer
        clc                             ; clear carry for add
        adc     #$04                    ; point to STEP value
        pha                             ; save it

        adc     #$06                    ; point to TO value
        sta     INDEX+2                 ; save pointer to TO variable for
                                        ; compare
        pla                             ; restore pointer to STEP value

        ldy     #$01                    ; point to stack page
        jsr     UnpackAY2FAC1           ; unpack memory (AY) into FAC1  [BBA2]

        tsx                             ; get stack pointer back
        lda     STACK+9,X               ; get step sign
        sta     FACSGN                  ; save FAC1 sign (b7)

        lda     FORPNT                  ; get FOR/NEXT variable pointer LB
        ldy     FORPNT+1                ; get FOR/NEXT variable pointer HB
        jsr     AddFORvar2FAC1          ; add FOR variable to FAC1      [B867]

        jsr     Fac1ToVarPtr            ; pack FAC1 into FOR variable   [BBD0]

        ldy     #$01                    ; point to stack page
        jsr     CmpFAC1withAY2          ; compare FAC1 with TO value    [BC5D]

        tsx                             ; get stack pointer back
        sec                             ; set carry for subtract
        sbc     STACK+9,X               ; subtract step sign
        beq     A_AD78                  ; branch if =, loop complete

; loop back and do it all again
        lda     STACK+$0F,X             ; get FOR line LB
        sta     CURLIN                  ; save current line number LB

        lda     STACK+$10,X             ; get FOR line HB
        sta     CURLIN+1                ; save current line number HB

        lda     STACK+$12,X             ; get BASIC execute pointer LB
        sta     TXTPTR                  ; save BASIC execute pointer LB

        lda     STACK+$11,X             ; get BASIC execute pointer HB
        sta     TXTPTR+1                ; save BASIC execute pointer HB
A_AD75                                  ;                               [AD75]
        jmp     InterpretLoop           ; go do interpreter inner loop  [A7AE]

; NEXT loop comlete

A_AD78                                  ;                               [AD78]
        txa                             ; stack copy to A
        adc     #$11                    ; add $12, $11 + carry, to dump FOR
                                        ; structure
        tax                             ; copy back to index

        txs                             ; copy to stack pointer

        jsr     CHRGOT                  ; scan memory                   [0079]
        cmp     #','                    ; compare with ","
        bne     A_AD75                  ; if not "," go do interpreter inner
                                        ; loop
; was "," so another NEXT variable to do
        jsr     CHRGET                  ; increment and scan memory     [0073]
        jsr     bcNEXT2                 ; do NEXT variable              [AD24]


;******************************************************************************
;
; evaluate expression and check type mismatch

EvalExpression                          ;                               [AD8A]
        jsr     EvaluateValue           ; evaluate expression           [AD9E]

; check if source and destination are numeric

CheckIfNumeric                          ;                               [AD8D]
        clc
.byte   $24                             ; makes next line BIT MEMSIZ+1

; check if source and destination are string

CheckIfString                           ;                               [AD8F]
        sec                             ; destination is string

; type match check, set C for string, clear C for numeric

ChkIfNumStr                             ;                               [AD90]
        bit     VALTYP                  ; test data type flag, $FF = string,
                                        ; $00 = numeric
        bmi     A_AD97                  ; branch if string

        bcs     A_AD99                  ; if destiantion is numeric do type
                                        ; missmatch error
A_AD96                                  ;                               [AD96]
        rts

A_AD97                                  ;                               [AD97]
        bcs     A_AD96                  ; exit if destination is string

; do type missmatch error

A_AD99                                  ;                               [AD99]
        ldx     #$16                    ; error code $16, type missmatch error
        jmp     OutputErrMsg            ; do error #X then warm start   [A437]


;******************************************************************************
;
; evaluate expression

EvaluateValue                           ;                               [AD9E]
        ldx     TXTPTR                  ; get BASIC execute pointer LB
        bne     A_ADA4                  ; skip next if not zero

        dec     TXTPTR+1                ; else decr. BASIC execute pointer HB
A_ADA4                                  ;                               [ADA4]
        dec     TXTPTR                  ; decrement BASIC execute pointer LB

        ldx     #$00                    ; set null precedence, flag done
.byte   $24                             ; makes next line BIT VARPNT+1
EvaluateValue2                          ;                               [ADA9]
        pha                             ; push compare evaluation byte if branch
                                        ; to here
        txa                             ; copy precedence byte
        pha                             ; push precedence byte

        lda     #$01                    ; 2 bytes
        jsr     CheckRoomStack          ; check room on stack for A*2 bytes
                                        ;                               [A3FB]
        jsr     GetNextParm             ; get value from line           [AE83]

        lda     #$00                    ; clear A
        sta     CompEvalFlg             ; clear comparrison evaluation flag
EvaluateValue3                          ;                               [ADB8]
        jsr     CHRGOT                  ; scan memory                   [0079]
EvaluateValue4                          ;                               [ADBB]
        sec                             ; set carry for subtract
        sbc     #TK_GT                  ; subtract the token for ">"
        bcc     A_ADD7                  ; branch if < ">"

        cmp     #$03                    ; compare with ">" to +3
        bcs     A_ADD7                  ; branch if >= 3

; was token for ">" "=" or "<"
        cmp     #$01                    ; compare with token for =
        rol                             ; b0 := carry (=1 if token was = or <)
        eor     #$01                    ; toggle b0
        eor     CompEvalFlg             ; EOR with comparrison evaluation flag
        cmp     CompEvalFlg             ; comp with comparrison evaluation flag
        bcc     A_AE30                  ; if < saved flag do syntax error then
                                        ; warm start
        sta     CompEvalFlg             ; save new comparrison evaluation flag

        jsr     CHRGET                  ; increment and scan memory     [0073]
        jmp     EvaluateValue4          ; go do next character          [ADBB]


A_ADD7                                  ;                               [ADD7]
        ldx     CompEvalFlg             ; get comparrison evaluation flag
        bne     A_AE07                  ; branch if compare function

        bcs     A_AE58                  ; go do functions

; else was < TK_GT so is operator or lower
        adc     #$07                    ; add # of operators (+, -, *, /, ^,
                                        ; AND or OR)
        bcc     A_AE58                  ; branch if < + operator

; carry was set so token was +, -, *, /, ^, AND or OR
        adc     VALTYP                  ; add data type flag, $FF = string,
                                        ; $00 = numeric
        bne     A_ADE8                  ; branch if not string or not + token

; will only be $00 if type is string and token was +
        jmp     ConcatStrings           ; add strings, string 1 is in the
                                        ; descriptor, string 2  [B63D]
                                        ; is in line, and return

A_ADE8                                  ;                               [ADE8]
        adc     #$FF                    ; -1 (corrects for carry add)
        sta     INDEX                   ; save it

        asl                             ; *2
        adc     INDEX                   ; *3
        tay                             ; copy to index
A_ADF0                                  ;                               [ADF0]
        pla                             ; pull previous precedence
        cmp     HierachyCode,Y          ; compare with precedence byte
        bcs     A_AE5D                  ; branch if A >=

        jsr     CheckIfNumeric          ; check if source is numeric, else do
                                        ; type mismatch                 [AD8D]
A_ADF9                                  ;                               [ADF9]
        pha                             ; save precedence
EvaluateValue5                          ;                               [ADFA]
        jsr     EvaluateValue6          ; get vector, execute function then
                                        ; continue evaluation           [AE20]

        pla                             ; restore precedence

        ldy     TEMPSTR                 ; get precedence stacked flag
        bpl     A_AE19                  ; branch if stacked values

        tax                             ; copy precedence, set flags
        beq     A_AE5B                  ; exit if done

        bne     A_AE66                  ; branch always

A_AE07                                  ;                               [AE07]
        lsr     VALTYP                  ; clear data type flag, $FF = string,
                                        ; $00 = numeric
        txa                             ; copy compare function flag

        rol                             ; <<1, shift data type flag into b0,
                                        ; 1 = string, 0 = num
        ldx     TXTPTR                  ; get BASIC execute pointer LB
        bne     A_AE11                  ; branch if no underflow

        dec     TXTPTR+1                ; else decr. BASIC execute pointer HB
A_AE11                                  ;                               [AE11]
        dec     TXTPTR                  ; decrement BASIC execute pointer LB

        ldy     #$1B                    ; set offset to = operator precedence
                                        ; entry
        sta     CompEvalFlg             ; save new comparrison evaluation flag
        bne     A_ADF0                  ; branch always

A_AE19                                  ;                               [AE19]
        cmp     HierachyCode,Y          ; compare with stacked function
                                        ; precedence
        bcs     A_AE66                  ; if A >=, pop FAC2 and return

        bcc     A_ADF9                  ; else go stack this one and continue,
                                        ; branch always

;******************************************************************************
;
; get vector, execute function then continue evaluation

EvaluateValue6                          ;                               [AE20]
        lda     HierachyCode+2,Y        ; get function vector HB
        pha                             ; onto stack

        lda     HierachyCode+1,Y        ; get function vector LB
        pha                             ; onto stack

; now push sign, round FAC1 and put on stack
        jsr     EvaluateValue7          ; function will return here, then the
                                        ; next RTS will call the function [AE33]
        lda     CompEvalFlg             ; get comparrison evaluation flag
        jmp     EvaluateValue2          ; continue evaluating expression [ADA9]

A_AE30                                  ;                               [AE30]
        jmp     SyntaxError             ; do syntax error then warm start [AF08]

EvaluateValue7                          ;                               [AE33]
        lda     FACSGN                  ; get FAC1 sign (b7)
        ldx     HierachyCode,Y          ; get precedence byte


;******************************************************************************
;
; push sign, round FAC1 and put on stack

SgnFac1ToStack                          ;                               [AE38]
        tay                             ; copy sign

        pla                             ; get return address LB
        sta     INDEX                   ; save it

        inc     INDEX                   ; increment it as return-1 is pushed.
; Note, no check is made on the HB so if the calling routine ever assembles to
; a page edge then this all goes horribly wrong!

        pla                             ; get return address HB
        sta     INDEX+1                 ; save it

        tya                             ; restore sign
        pha                             ; push sign


;******************************************************************************
;
; round FAC1 and put on stack

FAC1ToStack                             ;                               [AE43]
        jsr     RoundFAC1               ; round FAC1                    [BC1B]

        lda     FacMantissa+3           ; get FAC1 mantissa 4
        pha                             ; save it

        lda     FacMantissa+2           ; get FAC1 mantissa 3
        pha                             ; save it

        lda     FacMantissa+1           ; get FAC1 mantissa 2
        pha                             ; save it

        lda     FacMantissa             ; get FAC1 mantissa 1
        pha                             ; save it

        lda     FACEXP                  ; get FAC1 exponent
        pha                             ; save it

        jmp     (INDEX)                 ; return, sort of


;******************************************************************************
;
; do functions

A_AE58                                  ;                               [AE58]
        ldy     #$FF                    ; flag function
        pla                             ; pull precedence byte
A_AE5B                                  ;                               [AE5B]
        beq     A_AE80                  ; exit if done

A_AE5D                                  ;                               [AE5D]
        cmp     #$64                    ; compare previous precedence with $64
        beq     A_AE64                  ; branch if was $64 (< function)

        jsr     CheckIfNumeric          ; check if source is numeric, else do
                                        ; type mismatch [AD8D]
A_AE64                                  ;                               [AE64]
        sty     TEMPSTR                 ; save precedence stacked flag

; pop FAC2 and return
A_AE66                                  ;                               [AE66]
        pla                             ; pop byte
        lsr                             ; shift out comparison evaluation
                                        ; lowest bit
        sta     TANSGN                  ; save the comparison evaluation flag

        pla                             ; pop exponent
        sta     ARGEXP                  ; save FAC2 exponent

        pla                             ; pop mantissa 1
        sta     ArgMantissa             ; save FAC2 mantissa 1

        pla                             ; pop mantissa 2
        sta     ArgMantissa+1           ; save FAC2 mantissa 2

        pla                             ; pop mantissa 3
        sta     ArgMantissa+2           ; save FAC2 mantissa 3

        pla                             ; pop mantissa 4
        sta     ArgMantissa+3           ; save FAC2 mantissa 4

        pla                             ; pop sign
        sta     ARGSGN                  ; save FAC2 sign (b7)

        eor     FACSGN                  ; EOR FAC1 sign (b7)
        sta     ARISGN                  ; save sign compare (FAC1 EOR FAC2)
A_AE80                                  ;                               [AE80]
        lda     FACEXP                  ; get FAC1 exponent
        rts


;******************************************************************************
;
; get value from line

GetNextParm                             ;                               [AE83]
        jmp     (IEVAL)                 ; get arithmetic element


;******************************************************************************
;
; get arithmetic element, the get arithmetic element vector is initialised to
; point here

GetNextParm2                            ;                               [AE86]
        lda     #$00                    ; clear byte
        sta     VALTYP                  ; clear data type flag, $FF = string,
                                        ; $00 = numeric
A_AE8A                                  ;                               [AE8A]
        jsr     CHRGET                  ; increment and scan memory     [0073]
A_AE8D 
        bcs     A_AE92                  ; branch if not numeric character

; else numeric string found (e.g. 123)
A_AE8F                                  ;                               [AE8F]
        jmp     String2FAC1             ; get FAC1 from string and return [BCF3]

; get value from line .. continued

; wasn't a number so ...
A_AE92                                  ;                               [AE92]
        jsr     CheckAtoZ               ; check byte, return Cb = 0 if < "A" or
                                        ; > "Z"                         [B113]
        bcc     A_AE9A                  ; branch if not variable name

        jmp     GetVariable             ; variable name set-up and return [AF28]

A_AE9A                                  ;                               [AE9A]
        cmp     #TK_PI                  ; compare with token for PI
        bne     A_AEAD                  ; branch if not PI

        lda     #<Tbl_PI_Value          ; get PI pointer LB
        ldy     #>Tbl_PI_Value          ; get PI pointer HB
        jsr     UnpackAY2FAC1           ; unpack memory (AY) into FAC1  [BBA2]

        jmp     CHRGET                  ; increment and scan memory and return
                                        ;       [0073]

;******************************************************************************
;
; PI as floating number

Tbl_PI_Value                            ;                               [AEA8]
.byte   $82,$49,$0F,$DA,$A1             ; 3.141592653


;******************************************************************************
;
; get value from line .. continued

; wasn't variable name so ...
A_AEAD                                  ;                               [AEAD]
        cmp     #'.'                    ; compare with "."
        beq     A_AE8F                  ; if so get FAC1 from string and return,
                                        ; e.g. was .123
; wasn't .123 so ...
        cmp     #TK_MINUS               ; compare with token for -
        beq     A_AF0D                  ; branch if - token, do set-up for
                                        ; functions
; wasn't -123 so ...
        cmp     #TK_PLUS                ; compare with token for +
        beq     A_AE8A                  ; branch if + token, +1 = 1 so ignore
                                        ; leading +
; it wasn't any sort of number so ...
        cmp     #'"'                    ; compare with "
        bne     A_AECC                  ; branch if not open quote

; was open quote so get the enclosed string


;******************************************************************************
;
; print "..." string to string utility area

GetNextParm3                            ;                               [AEBD]
        lda     TXTPTR                  ; get BASIC execute pointer LB
        ldy     TXTPTR+1                ; get BASIC execute pointer HB
        adc     #$00                    ; add carry to LB
        bcc     A_AEC6                  ; branch if no overflow

        iny                             ; increment HB
A_AEC6                                  ;                               [AEC6]
        jsr     QuoteStr2UtPtr          ; print " terminated string to utility
                                        ; pointer                       [B487]
        jmp     RestBasExecPtr          ; restore BASIC execute pointer from
                                        ; temp and return               [B7E2]
; get value from line .. continued

; wasn't a string so ...
A_AECC                                  ;                               [AECC]
        cmp     #TK_NOT                 ; compare with token for NOT
        bne     A_AEE3                  ; branch if not token for NOT

; was NOT token
        ldy     #$18                    ; offset to NOT function
        bne     A_AF0F                  ; do set-up for function then execute,
                                        ; branch always
; do = compare

bcEQUAL 
        jsr     EvalInteger3            ; evaluate integer expression, no sign
                                        ; check                         [B1BF]
        lda     FacMantissa+3           ; get FAC1 mantissa 4
        eor     #$FF                    ; invert it
        tay                             ; copy it

        lda     FacMantissa+2           ; get FAC1 mantissa 3
        eor     #$FF                    ; invert it
        jmp     ConvertAY2FAC1          ; convert fixed integer AY to float FAC1
                                        ; and return                    [B391]
; get value from line .. continued

; wasn't a string or NOT so ...
A_AEE3                                  ;                               [AEE3]
        cmp     #TK_FN                  ; compare with token for FN
        bne     A_AEEA                  ; branch if not token for FN

        jmp     EvaluateFNx             ; else go evaluate FNx          [B3F4]

; get value from line .. continued

; wasn't a string, NOT or FN so ...
A_AEEA                                  ;                               [AEEA]
        cmp     #TK_SGN                 ; compare with token for SGN
        bcc     Chk4Parens              ; if less than SGN token evaluate
                                        ; expression in parentheses
; else was a function token
        jmp     GetReal                 ; go set up function references [AFA7]

; get value from line .. continued
; if here it can only be something in brackets so ....

; evaluate expression within parentheses

Chk4Parens                              ;                               [AEF1]
        jsr     Chk4OpenParen           ; scan for "(", else do syntax error
                                        ; then warm start               [AEFA]
        jsr     EvaluateValue           ; evaluate expression           [AD9E]

; all the 'scan for' routines return the character after the sought character

; scan for ")", else do syntax error then warm start

Chk4CloseParen                          ;                               [AEF7]
        lda     #')'                    ; load A with ")"
.byte   $2C                             ; makes next line BIT RESHO+2A9

; scan for "(", else do syntax error then warm start

Chk4OpenParen                           ;                               [AEFA]
        lda     #'('                    ; load A with "("
.byte   $2C                             ; makes next line BIT TXTTAB+1A9

; scan for ",", else do syntax error then warm start

Chk4Comma                               ;                               [AEFD]
        lda     #','                    ; load A with ","

; scan for CHR$(A), else do syntax error then warm start

Chk4CharInA                             ;                               [AEFF]
        ldy     #$00                    ; clear index
        cmp     (TXTPTR),Y              ; compare with BASIC byte
        bne     SyntaxError             ; if not expected byte do syntax error
                                        ; then warm start
        jmp     CHRGET                  ; else increment and scan memory and
                                        ; return                        [0073]
; syntax error then warm start

SyntaxError                             ;                               [AF08]
        ldx     #$0B                    ; error code $0B, syntax error
        jmp     OutputErrMsg            ; do error #X then warm start   [A437]


A_AF0D                                  ;                               [AF0D]
        ldy     #$15                    ; set offset from base to > operator
A_AF0F                                  ;                               [AF0F]
        pla                             ; dump return address LB
        pla                             ; dump return address HB

        jmp     EvaluateValue5          ; execute function then continue
                                        ; evaluation                    [ADFA]

;******************************************************************************
;
; check address range, return C = 1 if address in BASIC ROM

ChkIfVariable                           ;                               [AF14]
        sec                             ; set carry for subtract
        lda     FacMantissa+2           ; get variable address LB
        sbc     #<BasicCold             ; subtract BasicCold LB

        lda     FacMantissa+3           ; get variable address HB
        sbc     #>BasicCold             ; subtract BasicCold HB
        bcc     A_AF27                  ; exit if address < BasicCold

        lda     #<DataCHRGET            ; get end of BASIC marker LB
        sbc     FacMantissa+2           ; subtract variable address LB

        lda     #>DataCHRGET            ; get end of BASIC marker HB
        sbc     FacMantissa+3           ; subtract variable address HB
A_AF27                                  ;                               [AF27]
        rts


;******************************************************************************
;
; variable name set-up

GetVariable                             ;                               [AF28]
        jsr     GetAddrVar              ; get variable address          [B08B]
        sta     FacMantissa+2           ; save variable pointer LB
        sty     FacMantissa+3           ; save variable pointer HB

        ldx     VARNAM                  ; get current variable name first char
        ldy     VARNAM+1                ; get current variable name second char

        lda     VALTYP                  ; get data type flag, $FF = string,
                                        ; $00 = numeric
        beq     A_AF5D                  ; branch if numeric

; variable is string
        lda     #$00                    ; else clear A
        sta     FACOV                   ; clear FAC1 rounding byte

        jsr     ChkIfVariable           ; check address range           [AF14]
        bcc     A_AF5C                  ; exit if not in BASIC ROM

        cpx     #'T'                    ; compare variable name first character
                                        ; with "T"
        bne     A_AF5C                  ; exit if not "T"

        cpy     #'I'+$80                ; compare variable name second character
                                        ; with "I$"
        bne     A_AF5C                  ; exit if not "I$"

; variable name was "TI$"
        jsr     GetTime                 ; read real time clock into FAC1
                                        ; mantissa, 0HML                [AF84]
        sty     FacTempStor+7           ; clear exponent count adjust

        dey                             ; Y = $FF
        sty     FBUFPT                  ; set output string index, -1 to allow
                                        ; for pre increment
        ldy     #$06                    ; HH:MM:SS is six digits
        sty     FacTempStor+6           ; set number of characters before the
                                        ; decimal point
        ldy     #D_BF3A-D_BF16          ; index to jiffy conversion table
        jsr     JiffyCnt2Str            ; convert jiffy count to string [BE68]

        jmp     bcSTR2                  ; exit via STR$() code tail     [B46F]

A_AF5C                                  ;                               [AF5C]
        rts

; variable name set-up, variable is numeric
A_AF5D                                  ;                               [AF5D]
        bit     INTFLG                  ; test data type flag, $80 = integer,
                                        ; $00 = float
        bpl     A_AF6E                  ; branch if float

        ldy     #$00                    ; clear index
        lda     (FacMantissa+2),Y       ; get integer variable LB
        tax                             ; copy to X

        iny                             ; increment index
        lda     (FacMantissa+2),Y       ; get integer variable HB
        tay                             ; copy to Y

        txa                             ; copy loa byte to A
        jmp     ConvertAY2FAC1          ; convert fixed integer AY to float FAC1
                                        ; and return                    [B391]
; variable name set-up, variable is float
A_AF6E                                  ;                               [AF6E]
        jsr     ChkIfVariable           ; check address range           [AF14]
        bcc     A_AFA0                  ; if not in BASIC ROM get pointer and
                                        ; unpack into FAC1
        cpx     #'T'                    ; compare variable name first character
                                        ; with "T"
        bne     A_AF92                  ; branch if not "T"

        cpy     #'I'                    ; compare variable name second character
                                        ; with "I"
        bne     A_AFA0                  ; branch if not "I"

; variable name was "TI"
        jsr     GetTime                 ; read real time clock into FAC1
                                        ; mantissa, 0HML                [AF84]
        tya                             ; clear A

        ldx     #$A0                    ; set exponent to 32 bit value
        jmp     J_BC4F                  ; set exponent = X and normalise FAC1
                                        ;                               [BC4F]

;******************************************************************************
;
; read real time clock into FAC1 mantissa, 0HML

GetTime                                 ;                               [AF84]
        jsr     ReadClock               ; read real time clock          [FFDE]
        stx     FacMantissa+2           ; save jiffy clock mid byte as  FAC1
                                        ; mantissa 3
        sty     FacMantissa+1           ; save jiffy clock HB as  FAC1
                                        ; mantissa 2
        sta     FacMantissa+3           ; save jiffy clock LB as  FAC1
                                        ; mantissa 4
        ldy     #$00                    ; clear Y
        sty     FacMantissa             ; clear FAC1 mantissa 1

        rts

; variable name set-up, variable is float and not "Tx"
A_AF92                                  ;                               [AF92]
        cpx     #'S'                    ; compare variable name first character
                                        ; with "S"
        bne     A_AFA0                  ; if not "S" go do normal floating
                                        ; variable
        cpy     #'T'                    ; compare variable name second character
                                        ; with "T"
        bne     A_AFA0                  ; if not "T" go do normal floating
                                        ; variable
; variable name was "ST"
        jsr     ReadIoStatus            ; read I/O status word          [FFB7]
        jmp     AtoInteger              ; save A as integer byte and return
                                        ;                               [BC3C]
; variable is float
A_AFA0                                  ;                               [AFA0]
        lda     FacMantissa+2           ; get variable pointer LB
        ldy     FacMantissa+3           ; get variable pointer HB
        jmp     UnpackAY2FAC1           ; unpack memory (AY) into FAC1  [BBA2]


;******************************************************************************
;
; get value from line continued
; only functions left so ..

; set up function references

GetReal                                 ;                               [AFA7]
        asl                             ; *2 (2 bytes per function address)
        pha                             ; save function offset
        tax                             ; copy function offset

        jsr     CHRGET                  ; increment and scan memory     [0073]
        cpx     #$8F                    ; compare function offset to CHR$ token
                                        ; offset+1
        bcc     A_AFD1                  ; branch if < LEFT$ (can not be =)

; get value from line .. continued
; was LEFT$, RIGHT$ or MID$ so..

        jsr     Chk4OpenParen           ; scan for "(", else do syntax error
                                        ; then warm start               [AEFA]
        jsr     EvaluateValue           ; evaluate, should be string, expression
                                        ;                               [AD9E]
        jsr     Chk4Comma               ; scan for ",", else do syntax error
                                        ; then warm start               [AEFD]
        jsr     CheckIfString           ; check if source is string, else do
                                        ; type mismatch                 [AD8F]

        pla                             ; restore function offset
        tax                             ; copy it

        lda     FacMantissa+3           ; get descriptor pointer HB
        pha                             ; push string pointer HB

        lda     FacMantissa+2           ; get descriptor pointer LB
        pha                             ; push string pointer LB

        txa                             ; restore function offset
        pha                             ; save function offset

        jsr     GetByteParm2            ; get byte parameter            [B79E]

        pla                             ; restore function offset
        tay                             ; copy function offset

        txa                             ; copy byte parameter to A
        pha                             ; push byte parameter

        jmp     J_AFD6                  ; go call function              [AFD6]

; get value from line .. continued
; was SGN() to CHR$() so..

A_AFD1                                  ;                               [AFD1]
        jsr     Chk4Parens              ; evaluate expression within parentheses
                                        ;                               [AEF1]
        pla                             ; restore function offset
        tay                             ; copy to index
J_AFD6                                  ;                               [AFD6]
        lda     TblFunctions-$68,Y      ; get function jump vector LB
        sta     Jump0054+1              ; save functions jump vector LB

        lda     TblFunctions-$67,Y      ; get function jump vector HB
        sta     Jump0054+2              ; save functions jump vector HB

        jsr     Jump0054                ; do function call              [0054]
        jmp     CheckIfNumeric          ; check if source is numeric and RTS,
                                        ; else do type mismatch string functions
                                        ; avoid this by dumping the return
                                        ; address                       [AD8D]


;******************************************************************************
;
; perform OR
; this works because NOT(NOT(x) AND NOT(y)) = x OR y

bcOR                                    ;                               [AFE6]
        ldy     #$FF                    ; set Y for OR
.byte   $2C                             ; makes next line BIT $00A0


;******************************************************************************
;
; perform AND

bcAND                                   ;                               [AFE9]
        ldy     #$00                    ; clear Y for AND
        sty     COUNT                   ; set AND/OR invert value

        jsr     EvalInteger3            ; evaluate integer expression, no sign
                                        ; check                         [B1BF]

        lda     FacMantissa+2           ; get FAC1 mantissa 3
        eor     COUNT                   ; EOR LB
        sta     CHARAC                  ; save it

        lda     FacMantissa+3           ; get FAC1 mantissa 4
        eor     COUNT                   ; EOR HB
        sta     ENDCHR                  ; save it

        jsr     CopyFAC2toFAC1          ; copy FAC2 to FAC1, get 2nd value in
                                        ; expression                    [BBFC]
        jsr     EvalInteger3            ; evaluate integer expression, no sign
                                        ; check                         [B1BF]
        lda     FacMantissa+3           ; get FAC1 mantissa 4
        eor     COUNT                   ; EOR HB
        and     ENDCHR                  ; AND with expression 1 HB
        eor     COUNT                   ; EOR result HB
        tay                             ; save in Y

        lda     FacMantissa+2           ; get FAC1 mantissa 3
        eor     COUNT                   ; EOR LB
        and     CHARAC                  ; AND with expression 1 LB
        eor     COUNT                   ; EOR result LB
        jmp     ConvertAY2FAC1          ; convert fixed integer AY to float FAC1
                                        ; and return                    [B391]


;******************************************************************************
;
; perform comparisons

; do < compare

bcSMALLER                               ;                               [D016]
        jsr     ChkIfNumStr             ; type match check, set C for string
                                        ;                               [AD90]
        bcs     A_B02E                  ; branch if string

; do numeric < compare
        lda     ARGSGN                  ; get FAC2 sign (b7)
        ora     #$7F                    ; set all non sign bits
        and     ArgMantissa             ; and FAC2 mantissa 1 (AND in sign bit)
        sta     ArgMantissa             ; save FAC2 mantissa 1

        lda     #<ARGEXP                ; set pointer LB to FAC2
        ldy     #>ARGEXP                ; set pointer HB to FAC2
        jsr     CmpFAC1withAY           ; compare FAC1 with (AY)        [BC5B]
        tax                             ; copy the result

        jmp     J_B061                  ; go evaluate result            [B061]

; do string < compare
A_B02E                                  ;                               [B02E]
        lda     #$00                    ; clear byte
        sta     VALTYP                  ; clear data type flag, $FF = string,
                                        ; $00 = numeric
        dec     CompEvalFlg             ; clear < bit in comparrison evaluation
                                        ; flag
        jsr     PopStrDescStk           ; pop string off descriptor stack, or
                                        ; from top of string. Space returns with
                                        ; A = length, X = pointer LB,
                                        ; Y = pointer HB                [B6A6]
        sta     FACEXP                  ; save length
        stx     FacMantissa             ; save string pointer LB
        sty     FacMantissa+1           ; save string pointer HB

        lda     ArgMantissa+2           ; get descriptor pointer LB
        ldy     ArgMantissa+3           ; get descriptor pointer HB
        jsr     PopStrDescStk2          ; pop (YA) descriptor off stack or from
                                        ; top of string space returns with A =
                                        ; length, X = pointer low byte,
                                        ; Y = pointer high byte         [B6AA]
        stx     ArgMantissa+2           ; save string pointer LB
        sty     ArgMantissa+3           ; save string pointer HB

        tax                             ; copy length

        sec                             ; set carry for subtract
        sbc     FACEXP                  ; subtract string 1 length
        beq     A_B056                  ; branch if string 1 length = string 2
                                        ; length
        lda     #$01                    ; set str 1 length > string 2 length
        bcc     A_B056                  ; branch if so

        ldx     FACEXP                  ; get string 1 length
        lda     #$FF                    ; set str 1 length < string 2 length
A_B056                                  ;                               [B056]
        sta     FACSGN                  ; save length compare

        ldy     #$FF                    ; set index
        inx                             ; adjust for loop
A_B05B                                  ;                               [B05B]
        iny                             ; increment index

        dex                             ; decrement count
        bne     A_B066                  ; branch if still bytes to do

        ldx     FACSGN                  ; get length compare back
J_B061                                  ;                               [B061]
        bmi     A_B072                  ; branch if str 1 < str 2

        clc                             ; flag str 1 <= str 2
        bcc     A_B072                  ; go evaluate result

A_B066                                  ;                               [B066]
        lda     (ArgMantissa+2),Y       ; get string 2 byte
        cmp     (FacMantissa),Y         ; compare with string 1 byte
        beq     A_B05B                  ; loop if bytes =

        ldx     #$FF                    ; set str 1 < string 2
        bcs     A_B072                  ; branch if so

        ldx     #$01                    ; set str 1 > string 2
A_B072                                  ;                               [B072]
        inx                             ; x = 0, 1 or 2

        txa                             ; copy to A
        rol                             ; * 2 (1, 2 or 4)
        and     TANSGN                  ; AND with the comparison evaluation
                                        ; flag
        beq     A_B07B                  ; branch if 0 (compare is false)

        lda     #$FF                    ; else set result true
A_B07B                                  ;                               [B07B]
        jmp     AtoInteger              ; save A as integer byte and return
                                        ;                               [BC3C]

A_B07E                                  ;                               [B07E]
        jsr     Chk4Comma               ; scan for ",", else do syntax error
                                        ; then warm start               [AEFD]

;******************************************************************************
;
; perform DIM

bcDIM                                   ;                               [D081]
        tax                             ; copy "DIM" flag to X
        jsr     GetAddrVar2             ; search for variable           [B090]

        jsr     CHRGOT                  ; scan memory                   [0079]
        bne     A_B07E                  ; scan for "," and loop if not null

        rts


;******************************************************************************
;
; search for variable

GetAddrVar                              ;                               [B08B]
        ldx     #$00                    ; set DIM flag = $00
        jsr     CHRGOT                  ; scan memory, 1st character    [0079]
GetAddrVar2                             ;                               [B090]
        stx     DIMFLG                  ; save DIM flag
GetAddrVar3                             ;                               [B092]
        sta     VARNAM                  ; save 1st character

        jsr     CHRGOT                  ; scan memory                   [0079]

        jsr     CheckAtoZ               ; check byte, return Cb = 0 if < "A"
                                        ; or > "Z"                      [B113]
        bcs     A_B09F                  ; branch if ok

A_B09C                                  ;                               [B09C]
        jmp     SyntaxError             ; else syntax error then warm start
                                        ;                               [AF08]

; was variable name so ...
A_B09F                                  ;                               [B09F]
        ldx     #$00                    ; clear 2nd character temp
        stx     VALTYP                  ; clear data type flag, $FF = string,
                                        ; $00 = numeric
        stx     INTFLG                  ; clear data type flag, $80 = integer,
                                        ; $00 = float
        jsr     CHRGET                  ; increment and scan memory, 2nd
                                        ; character                     [0073]
        bcc     A_B0AF                  ; if character = "0"-"9" (ok) go save
                                        ; 2nd character

; 2nd character wasn't "0" to "9" so ...
        jsr     CheckAtoZ               ; check byte, return Cb = 0 if < "A" or
                                        ; > "Z"                         [B113]
        bcc     A_B0BA                  ; branch if <"A" or >"Z" (go check if
                                        ; string)
A_B0AF                                  ;                               [B0AF]
        tax                             ; copy 2nd character

; ignore further (valid) characters in the variable name
A_B0B0                                  ;                               [B0B0]
        jsr     CHRGET                  ; increment and scan memory, 3rd
                                        ; character                     [0073]
        bcc     A_B0B0                  ; loop if character = "0"-"9" (ignore)

        jsr     CheckAtoZ               ; check byte, return Cb = 0 if < "A" or
                                        ; > "Z"                         [B113]
        bcs     A_B0B0                  ; loop if character = "A"-"Z" (ignore)

; check if string variable
A_B0BA                                  ;                               [B0BA]
        cmp     #'$'                    ; compare with "$"
        bne     A_B0C4                  ; branch if not string

; type is string
        lda     #$FF                    ; set data type = string
        sta     VALTYP                  ; set data type flag, $FF = string,
                                        ; $00 = numeric
        bne     A_B0D4                  ; branch always

A_B0C4                                  ;                               [B0C4]
        cmp     #'%'                    ; compare with "%"
        bne     A_B0DB                  ; branch if not integer

        lda     SUBFLG                  ; get subscript/FNX flag
        bne     A_B09C                  ; if ?? do syntax error then warm start

        lda     #$80                    ; set integer type
        sta     INTFLG                  ; set data type = integer

        ora     VARNAM                  ; OR current variable name first byte
        sta     VARNAM                  ; save current variable name first byte
A_B0D4                                  ;                               [B0D4]
        txa                             ; get 2nd character back
        ora     #$80                    ; set top bit, indicate string or
                                        ; integer variable
        tax                             ; copy back to 2nd character temp

        jsr     CHRGET                  ; increment and scan memory     [0073]
A_B0DB                                  ;                               [B0DB]
        stx     VARNAM+1                ; save 2nd character

        sec                             ; set carry for subtract
        ora     SUBFLG                  ; or with subscript/FNX flag - or FN
                                        ; name
        sbc     #'('                    ; subtract "("
        bne     A_B0E7                  ; branch if not "("

        jmp     FindMakeArray           ; go find, or make, array       [B1D1]

; either find or create variable

; variable name wasn't xx(.... so look for plain variable
A_B0E7                                  ;                               [B0E7]
        ldy     #$00                    ; clear A
        sty     SUBFLG                  ; clear subscript/FNX flag

        lda     VARTAB                  ; get start of variables LB
        ldx     VARTAB+1                ; get start of variables HB
A_B0EF                                  ;                               [B0EF]
        stx     FacTempStor+9           ; save search address HB
A_B0F1                                  ;                               [B0F1]
        sta     FacTempStor+8           ; save search address LB

        cpx     ARYTAB+1                ; compare with end of variables HB
        bne     A_B0FB                  ; skip next compare if <>

; high addresses were = so compare low addresses
        cmp     ARYTAB                  ; compare low address with end of
                                        ; variables LB
        beq     A_B11D                  ; if not found go make new variable

A_B0FB                                  ;                               [B0FB]
        lda     VARNAM                  ; get 1st character of variable to find
        cmp     (FacTempStor+8),Y       ; compare with variable name 1st
                                        ; character
        bne     A_B109                  ; branch if no match

; 1st characters match so compare 2nd character
        lda     VARNAM+1                ; get 2nd character of variable to find
        iny                             ; index to point to variable name 2nd
                                        ; character
        cmp     (FacTempStor+8),Y       ; compare with variable name 2nd
                                        ; character
        beq     A_B185                  ; branch if match (found variable)

        dey                             ; else decrement index (now = $00)
A_B109                                  ;                               [B109]
        clc                             ; clear carry for add
        lda     FacTempStor+8           ; get search address LB
        adc     #$07                    ; +7, offset to next variable name
        bcc     A_B0F1                  ; loop if no overflow to HB

        inx                             ; else increment HB
        bne     A_B0EF                  ; loop always, RAM doesn't extend to
                                        ; $FFFF
; check byte, return C = 0 if <"A" or >"Z"

CheckAtoZ                               ;                               [B113]
        cmp     #'A'                    ; compare with "A"
        bcc     A_B11C                  ; exit if less

; carry is set
        sbc     #'Z'+1                  ; subtract "Z"+1

        sec                             ; set carry
        sbc     #$A5                    ; subtract $A5 (restore byte)
                                        ; carry clear if byte > $5A
A_B11C                                  ;                               [B11C]
        rts

; reached end of variable memory without match
; ... so create new variable
A_B11D                                  ;                               [B11D]
        pla                             ; pop return address LB
        pha                             ; push return address LB

        cmp     #<(GetVariable+2)       ; compare with expected calling routine
                                        ; return LB
        bne     A_B128                  ; if not get variable go create new
                                        ; variable

; this will only drop through if the call was from GetVariable and is only
; called from there if it is searching for a variable from the right hand side
; of a LET a=b statement, it prevents the creation of variables not assigned a
; value.

; value returned by this is either numeric zero, exponent byte is $00, or null
; string, descriptor length byte is $00. in fact a pointer to any $00 byte
; would have done.

; else return dummy null value
A_B123                                  ;                               [B123]
        lda     #<L_BF13                ; set result pointer LB
        ldy     #>L_BF13                ; set result pointer HB
        rts

; create new numeric variable
A_B128                                  ;                               [B128]
        lda     VARNAM                  ; get variable name first character

        ldy     VARNAM+1                ; get variable name second character
        cmp     #'T'                    ; compare first character with "T"
        bne     A_B13B                  ; branch if not "T"

        cpy     #'I'+$80                ; compare second character with "I$"
        beq     A_B123                  ; if "I$" return null value

        cpy     #'I'                    ; compare second character with "I"
        bne     A_B13B                  ; branch if not "I"

; if name is "TI" do syntax error
A_B138                                  ;                               [B138]
        jmp     SyntaxError             ; do syntax error then warm start [AF08]

A_B13B                                  ;                               [B13B]
        cmp     #'S'                    ; compare first character with "S"
        bne     A_B143                  ; branch if not "S"

        cpy     #'T'                    ; compare second character with "T"
        beq     A_B138                  ; if name is "ST" do syntax error

A_B143                                  ;                               [B143]
        lda     ARYTAB                  ; get end of variables LB
        ldy     ARYTAB+1                ; get end of variables HB
        sta     FacTempStor+8           ; save old block start LB
        sty     FacTempStor+9           ; save old block start HB

        lda     STREND                  ; get end of arrays LB
        ldy     STREND+1                ; get end of arrays HB
        sta     FacTempStor+3           ; save old block end LB
        sty     FacTempStor+4           ; save old block end HB

        clc                             ; clear carry for add
        adc     #$07                    ; +7, space for one variable
        bcc     A_B159                  ; branch if no overflow to HB

        iny                             ; else increment HB
A_B159                                  ;                               [B159]
        sta     FacTempStor+1           ; set new block end LB
        sty     FacTempStor+2           ; set new block end HB

        jsr     MoveBlock               ; open up space in memory       [A3B8]

        lda     FacTempStor+1           ; get new start LB
        ldy     FacTempStor+2           ; get new start HB (-$100)
        iny                             ; correct HB
        sta     ARYTAB                  ; set end of variables LB
        sty     ARYTAB+1                ; set end of variables HB

        ldy     #$00                    ; clear index
        lda     VARNAM                  ; get variable name 1st character
        sta     (FacTempStor+8),Y       ; save variable name 1st character

        iny                             ; increment index
        lda     VARNAM+1                ; get variable name 2nd character
        sta     (FacTempStor+8),Y       ; save variable name 2nd character

        lda     #$00                    ; clear A
        iny                             ; increment index
        sta     (FacTempStor+8),Y       ; initialise variable byte

        iny                             ; increment index
        sta     (FacTempStor+8),Y       ; initialise variable byte

        iny                             ; increment index
        sta     (FacTempStor+8),Y       ; initialise variable byte

        iny                             ; increment index
        sta     (FacTempStor+8),Y       ; initialise variable byte

        iny                             ; increment index
        sta     (FacTempStor+8),Y       ; initialise variable byte

; found a match for variable
A_B185                                  ;                               [B185]
        lda     FacTempStor+8           ; get variable address LB
        clc                             ; clear carry for add
        adc     #$02                    ; +2, offset past variable name bytes
        ldy     FacTempStor+9           ; get variable address HB
        bcc     A_B18F                  ; branch if no overflow from add

        iny                             ; else increment HB
A_B18F                                  ;                               [B18F]
        sta     VARPNT                  ; save current variable pointer LB
        sty     VARPNT+1                ; save current variable pointer HB
        rts

; set-up array pointer to first element in array

SetupPointer                            ;                               [B194]
        lda     COUNT                   ; get # of dimensions (1, 2 or 3)
        asl                             ; *2 (also clears the carry !)
        adc     #$05                    ; +5 (result is 7, 9 or 11 here)
        adc     FacTempStor+8           ; add array start pointer LB
        ldy     FacTempStor+9           ; get array pointer HB
        bcc     A_B1A0                  ; branch if no overflow

        iny                             ; else increment HB
A_B1A0                                  ;                               [B1A0]
        sta     FacTempStor+1           ; save array data pointer LB
        sty     FacTempStor+2           ; save array data pointer HB
        rts


;******************************************************************************
;
; -32768 as floating value

M32768                                  ;                               [B1A5]
.byte   $90,$80,$00,$00,$00             ; -32768


;******************************************************************************
;
; convert float to fixed

Float2Fixed                             ;                               [B1AA]
        jsr     EvalInteger3            ; evaluate integer expression, no sign
                                        ; check [B1BF]

        lda     FacMantissa+2           ; get result LB
        ldy     FacMantissa+3           ; get result HB
        rts


;******************************************************************************
;
; evaluate integer expression

EvalInteger                             ;                               [B1B2]
        jsr     CHRGET                  ; increment and scan memory     [0073]
        jsr     EvaluateValue           ; evaluate expression           [AD9E]

; evaluate integer expression, sign check

EvalInteger2                            ;                               [B1B8]
        jsr     CheckIfNumeric          ; check if source is numeric, else do
                                        ; type mismatch                 [AD8D]
        lda     FACSGN                  ; get FAC1 sign (b7)
        bmi     A_B1CC                  ; do illegal quantity error if -ve

; evaluate integer expression, no sign check

EvalInteger3                            ;                               [B1BF]
        lda     FACEXP                  ; get FAC1 exponent
        cmp     #$90                    ; compare with exponent = 2^16 (n>2^15)
        bcc     A_B1CE                  ; if n<2^16 go convert FAC1 floating to
                                        ; fixed and return
        lda     #<M32768                ; set pointer LB to -32768
        ldy     #>M32768                ; set pointer HB to -32768
        jsr     CmpFAC1withAY           ; compare FAC1 with (AY)        [BC5B]
A_B1CC                                  ;                               [B1CC]
        bne     IllegalQuant            ; if <> do illegal quantity error then
                                        ; warm start
A_B1CE                                  ;                               [B1CE]
        jmp     FAC1Float2Fix           ; convert FAC1 floating to fixed and
                                        ; return                        [BC9B]

;******************************************************************************
;
; an array is stored as follows
;
; array name            ; two bytes with following patterns for different types
;                       ; 1st char  2nd char
;                       ;   b7        b7      type    element size
;                       ; --------  --------  -----   ------------
;                       ;   0         0       Real       5
;                       ;   0         1       string     3
;                       ;   1         1       integer    2
; offset to next array  ; word
; dimension count       ; byte
; 1st dimension size    ; word, this is the number of elements including 0
; 2nd dimension size    ; word, only here if the array has a second dimension
; 2nd dimension size    ; word, only here if the array has a third dimension
;                       ; note: the dimension size word is in HB LB
;                       ; format, not like most 6502 words
; then for each element the required number of bytes given as the element size
; above

; find or make array

FindMakeArray                           ;                               [B1D1]
        lda     DIMFLG                  ; get DIM flag
        ora     INTFLG                  ; OR with data type flag
        pha                             ; push it

        lda     VALTYP                  ; get data type flag, $FF = string,
                                        ; $00 = numeric
        pha                             ; push it

        ldy     #$00                    ; clear dimensions count

; now get the array dimension(s) and stack it (them) before the data type and
; DIM flag

A_B1DB                                  ;                               [B1DB]
        tya                             ; copy dimensions count
        pha                             ; save it

        lda     VARNAM+1                ; get array name 2nd byte
        pha                             ; save it

        lda     VARNAM                  ; get array name 1st byte
        pha                             ; save it

        jsr     EvalInteger             ; evaluate integer expression   [B1B2]

        pla                             ; pull array name 1st byte
        sta     VARNAM                  ; restore array name 1st byte

        pla                             ; pull array name 2nd byte
        sta     VARNAM+1                ; restore array name 2nd byte

        pla                             ; pull dimensions count
        tay                             ; restore it

        tsx                             ; copy stack pointer
        lda     STACK+2,X               ; get DIM flag
        pha                             ; push it

        lda     STACK+1,X               ; get data type flag
        pha                             ; push it

        lda     FacMantissa+2           ; get this dimension size HB
        sta     STACK+2,X               ; stack before flag bytes

        lda     FacMantissa+3           ; get this dimension size LB
        sta     STACK+1,X               ; stack before flag bytes

        iny                             ; increment dimensions count

        jsr     CHRGOT                  ; scan memory                   [0079]
        cmp     #','                    ; compare with ","
        beq     A_B1DB                  ; if found go do next dimension

        sty     COUNT                   ; store dimensions count

        jsr     Chk4CloseParen          ; scan for ")", else do syntax error
                                        ; then warm start               [AEF7]
        pla                             ; pull data type flag
        sta     VALTYP                  ; restore data type flag, $FF = string,
                                        ; $00 = numeric
        pla                             ; pull data type flag
        sta     INTFLG                  ; restore data type flag, $80 = integer,
                                        ; $00 = float
        and     #$7F                    ; mask dim flag
        sta     DIMFLG                  ; restore DIM flag

        ldx     ARYTAB                  ; set end of variables LB
                                        ; (array memory start LB)
        lda     ARYTAB+1                ; set end of variables HB
                                        ; (array memory start HB)

; now check to see if we are at the end of array memory, we would be if there
; were no arrays.

A_B21C                                  ;                               [B21C]
        stx     FacTempStor+8           ; save as array start pointer LB
        sta     FacTempStor+9           ; save as array start pointer HB

        cmp     STREND+1                ; compare with end of arrays HB
        bne     A_B228                  ; branch if not reached array memory end

        cpx     STREND                  ; else compare with end of arrays LB
        beq     A_B261                  ; go build array if not found

; search for array
A_B228                                  ;                               [B228]
        ldy     #$00                    ; clear index
        lda     (FacTempStor+8),Y       ; get array name first byte
        iny                             ; increment index to second name byte
        cmp     VARNAM                  ; compare with this array name first
                                        ; byte
        bne     A_B237                  ; branch if no match

        lda     VARNAM+1                ; else get this array name second byte
        cmp     (FacTempStor+8),Y       ; compare with array name second byte
        beq     A_B24D                  ; array found so branch

; no match
A_B237                                  ;                               [B237]
        iny                             ; increment index
        lda     (FacTempStor+8),Y       ; get array size LB
        clc                             ; clear carry for add
        adc     FacTempStor+8           ; add array start pointer LB
        tax                             ; copy LB to X

        iny                             ; increment index
        lda     (FacTempStor+8),Y       ; get array size HB
        adc     FacTempStor+9           ; add array memory pointer HB
        bcc     A_B21C                  ; if no overflow go check next array


;******************************************************************************
;
; do bad subscript error

BadSubscript                            ;                               [B245]
        ldx     #$12                    ; error $12, bad subscript error
.byte   $2C                             ; makes next line BIT $0EA2


;******************************************************************************
;
; do illegal quantity error

IllegalQuant                            ;                               [B248]
        ldx     #$0E                    ; error $0E, illegal quantity error
A_B24A                                  ;                               [B24A]
        jmp     OutputErrMsg            ; do error #X then warm start   [A437]


;******************************************************************************
;
; found the array

A_B24D                                  ;                               [B24D]
        ldx     #$13                    ; set error $13, double dimension error

        lda     DIMFLG                  ; get DIM flag
        bne     A_B24A                  ; if we are trying to dimension it do
                                        ; error #X then warm start

; found the array and we're not dimensioning it so we must find an element in
; it

        jsr     SetupPointer            ; set-up array pointer to first element
                                        ; in array                      [B194]
        lda     COUNT                   ; get dimensions count
        ldy     #$04                    ; set index to array's # of dimensions
        cmp     (FacTempStor+8),Y       ; compare with no of dimensions
        bne     BadSubscript            ; if wrong do bad subscript error

        jmp     GetArrElement           ; found array so go get element [B2EA]

; array not found, so build it
A_B261                                  ;                               [B261]
        jsr     SetupPointer            ; set-up array pointer to first element
                                        ; in array                      [B194]
        jsr     CheckAvailMem           ; check available memory, do out of
                                        ; memory error if no room       [A408]
        ldy     #$00                    ; clear Y
        sty     FBUFPT+1                ; clear array data size HB

        ldx     #$05                    ; set default element size
        lda     VARNAM                  ; get variable name 1st byte
        sta     (FacTempStor+8),Y       ; save array name 1st byte
        bpl     A_B274                  ; branch if not string or floating
                                        ; point array
        dex                             ; decrement element size, $04
A_B274                                  ;                               [B274]
        iny                             ; increment index
        lda     VARNAM+1                ; get variable name 2nd byte
        sta     (FacTempStor+8),Y       ; save array name 2nd byte
        bpl     A_B27D                  ; branch if not integer or string

        dex                             ; decrement element size, $03
        dex                             ; decrement element size, $02
A_B27D                                  ;                               [B27D]
        stx     FBUFPT                  ; save element size

        lda     COUNT                   ; get dimensions count
        iny                             ; increment index ..
        iny                             ; .. to array  ..
        iny                             ; .. dimension count
        sta     (FacTempStor+8),Y       ; save array dimension count
A_B286                                  ;                               [B286]
        ldx     #$0B                    ; set default dimension size LB
        lda     #$00                    ; set default dimension size HB
        bit     DIMFLG                  ; test DIM flag
        bvc     A_B296                  ; branch if default to be used

        pla                             ; pull dimension size LB
        clc                             ; clear carry for add
        adc     #$01                    ; add 1, allow for zeroeth element
        tax                             ; copy LB to X

        pla                             ; pull dimension size HB
        adc     #$00                    ; add carry to HB
A_B296                                  ;                               [B296]
        iny                             ; incement index to dimension size HB
        sta     (FacTempStor+8),Y       ; save dimension size HB

        iny                             ; incement index to dimension size LB
        txa                             ; copy dimension size LB
        sta     (FacTempStor+8),Y       ; save dimension size LB

        jsr     CalcArraySize           ; compute array size            [B34C]
        stx     FBUFPT                  ; save result LB
        sta     FBUFPT+1                ; save result HB

        ldy     INDEX                   ; restore index
        dec     COUNT                   ; decrement dimensions count
        bne     A_B286                  ; loop if not all done

        adc     FacTempStor+2           ; add array data pointer HB
        bcs     A_B30B                  ; if overflow do out of memory error
                                        ; then warm start
        sta     FacTempStor+2           ; save array data pointer HB

        tay                             ; copy array data pointer HB

        txa                             ; copy array size LB
        adc     FacTempStor+1           ; add array data pointer LB
        bcc     A_B2B9                  ; branch if no rollover

        iny                             ; else increment next array pointer HB
        beq     A_B30B                  ; if rolled over do out of memory error
                                        ; then warm start
A_B2B9                                  ;                               [B2B9]
        jsr     CheckAvailMem           ; check available memory, do out of
                                        ; memory error if no room       [A408]
        sta     STREND                  ; set end of arrays LB
        sty     STREND+1                ; set end of arrays HB

; now the aray is created we need to zero all the elements in it

        lda     #$00                    ; clear A for array clear

        inc     FBUFPT+1                ; increment array size HB, now block
                                        ; count
        ldy     FBUFPT                  ; get array size LB, now index to block
        beq     A_B2CD                  ; branch if $00
A_B2C8                                  ;                               [B2C8]
        dey                             ; decrement index, do 0 to n-1
        sta     (FacTempStor+1),Y       ; clear array element byte
        bne     A_B2C8                  ; loop until this block done

A_B2CD                                  ;                               [B2CD]
        dec     FacTempStor+2           ; decrement array pointer HB

        dec     FBUFPT+1                ; decrement block count HB
        bne     A_B2C8                  ; loop until all blocks done

        inc     FacTempStor+2           ; correct for last loop

        sec                             ; set carry for subtract
        lda     STREND                  ; get end of arrays LB
        sbc     FacTempStor+8           ; subtract array start LB
        ldy     #$02                    ; index to array size LB
        sta     (FacTempStor+8),Y       ; save array size LB

        lda     STREND+1                ; get end of arrays HB
        iny                             ; index to array size HB
        sbc     FacTempStor+9           ; subtract array start HB
        sta     (FacTempStor+8),Y       ; save array size HB

        lda     DIMFLG                  ; get default DIM flag
        bne     A_B34B                  ; exit if this was a DIM command

; else, find element
        iny                             ; set index to # of dimensions, the
                                        ; dimension indeces are on the stack and
                                        ; and will be removed as the position
                                        ; of the array element is calculated

GetArrElement                           ;                               [B2EA]
        lda     (FacTempStor+8),Y       ; get array's dimension count
        sta     COUNT                   ; save it

        lda     #$00                    ; clear byte
        sta     FBUFPT                  ; clear array data pointer LB
A_B2F2                                  ;                               [B2F2]
        sta     FBUFPT+1                ; save array data pointer HB

        iny                             ; increment index, point to array bound
                                        ; HB
        pla                             ; pull array index LB
        tax                             ; copy to X
        sta     FacMantissa+2           ; save index LB to FAC1 mantissa 3

        pla                             ; pull array index HB
        sta     FacMantissa+3           ; save index HB to FAC1 mantissa 4

        cmp     (FacTempStor+8),Y       ; compare with array bound HB
        bcc     A_B30E                  ; branch if within bounds

        bne     A_B308                  ; if outside bounds do bad subscript
                                        ; error
; else HB was = so test LBs
        iny                             ; index to array bound LB
        txa                             ; get array index LB
        cmp     (FacTempStor+8),Y       ; compare with array bound LB
        bcc     A_B30F                  ; branch if within bounds

A_B308                                  ;                               [B308]
        jmp     BadSubscript            ; do bad subscript error        [B245]

A_B30B                                  ;                               [B30B]
        jmp     OutOfMemory             ; do out of memory error then warm start
                                        ;                               [A435]

A_B30E                                  ;                               [B30E]
        iny                             ; index to array bound LB
A_B30F                                  ;                               [B30F]
        lda     FBUFPT+1                ; get array data pointer HB
        ora     FBUFPT                  ; OR with array data pointer LB
        clc
        beq     A_B320                  ; branch if array data pointer = null,
                                        ; skip multiply
        jsr     CalcArraySize           ; compute array size            [B34C]

        txa                             ; get result LB
        adc     FacMantissa+2           ; add index LB from FAC1 mantissa 3
        tax                             ; save result LB

        tya                             ; get result HB
        ldy     INDEX                   ; restore index
A_B320                                  ;                               [B320]
        adc     FacMantissa+3           ; add index HB from FAC1 mantissa 4

        stx     FBUFPT                  ; save array data pointer LB

        dec     COUNT                   ; decrement dimensions count
        bne     A_B2F2                  ; loop if dimensions still to do

        sta     FBUFPT+1                ; save array data pointer HB

        ldx     #$05                    ; set default element size

        lda     VARNAM                  ; get variable name 1st byte
        bpl     A_B331                  ; branch if not string or floating
                                        ; point array
        dex                             ; decrement element size, $04
A_B331                                  ;                               [B331]
        lda     VARNAM+1                ; get variable name 2nd byte
        bpl     A_B337                  ; branch if not integer or string

        dex                             ; decrement element size, $03
        dex                             ; decrement element size, $02
A_B337                                  ;                               [B337]
        stx     RESHO+2                 ; save dimension size LB

        lda     #$00                    ; clear dimension size HB
        jsr     CalcArraySize2          ; compute array size            [B355]

        txa                             ; copy array size LB
        adc     FacTempStor+1           ; add array data start pointer LB
        sta     VARPNT                  ; save as current variable pointer LB

        tya                             ; copy array size HB
        adc     FacTempStor+2           ; add array data start pointer HB
        sta     VARPNT+1                ; save as current variable pointer HB

        tay                             ; copy HB to Y
        lda     VARPNT                  ; get current variable pointer LB
                                        ; pointer to element is now in AY
A_B34B                                  ;                               [B34B]
        rts


; compute array size, result in XY

CalcArraySize                           ;                               [B34C]
        sty     INDEX                   ; save index
        lda     (FacTempStor+8),Y       ; get dimension size LB
        sta     RESHO+2                 ; save dimension size LB

        dey                             ; decrement index
        lda     (FacTempStor+8),Y       ; get dimension size HB
CalcArraySize2                          ;                               [B355]
        sta     RESHO+3                 ; save dimension size HB

        lda     #$10                    ; count = $10 (16 bit multiply)
        sta     FacTempStor+6           ; save bit count

        ldx     #$00                    ; clear result LB
        ldy     #$00                    ; clear result HB
A_B35F                                  ;                               [B35F]
        txa                             ; get result LB
        asl                             ; *2
        tax                             ; save result LB

        tya                             ; get result HB
        rol                             ; *2
        tay                             ; save result HB
        bcs     A_B30B                  ; if overflow go do "Out of memory"
                                        ; error
        asl     FBUFPT                  ; shift element size LB
        rol     FBUFPT+1                ; shift element size HB
        bcc     A_B378                  ; skip add if no carry

        clc                             ; else clear carry for add
        txa                             ; get result LB
        adc     RESHO+2                 ; add dimension size LB
        tax                             ; save result LB

        tya                             ; get result HB
        adc     RESHO+3                 ; add dimension size HB
        tay                             ; save result HB
        bcs     A_B30B                  ; if overflow go do "Out of memory"
                                        ; error
A_B378                                  ;                               [B378]
        dec     FacTempStor+6           ; decrement bit count
        bne     A_B35F                  ; loop until all done

        rts

; perform FRE()

bcFRE                                   ;                               [B37D]
        lda     VALTYP                  ; get data type flag, $FF = string,
                                        ; $00 = numeric
        beq     A_B384                  ; branch if numeric

        jsr     PopStrDescStk           ; pop string off descriptor stack, or
                                        ; from top of string space returns with
                                        ; A = length, X=$71=pointer LB,
                                        ; Y=$72=pointer HB              [B6A6]
; FRE(n) was numeric so do this
A_B384                                  ;                               [B384]
        jsr     CollectGarbage          ; go do garbage collection      [B526]

        sec                             ; set carry for subtract
        lda     FRETOP                  ; get bottom of string space LB
        sbc     STREND                  ; subtract end of arrays LB
        tay                             ; copy result to Y

        lda     FRETOP+1                ; get bottom of string space HB
        sbc     STREND+1                ; subtract end of arrays HB


;******************************************************************************
;
; convert fixed integer AY to float FAC1

ConvertAY2FAC1                          ;                               [B391]
        ldx     #$00                    ; set type = numeric
        stx     VALTYP                  ; clear data type flag, $FF = string,
                                        ; $00 = numeric
        sta     FacMantissa             ; save FAC1 mantissa 1
        sty     FacMantissa+1           ; save FAC1 mantissa 2

        ldx     #$90                    ; set exponent=2^16 (integer)
        jmp     J_BC44                  ; set exp = X, clear FAC1 3 and 4,
                                        ; normalise and return          [BC44]

;******************************************************************************
;
; perform POS()

bcPOS                                   ;                               [B39E]
        sec                             ; set Cb for read cursor position
        jsr     CursorPosXY             ; read/set X,Y cursor position  [FFF0]
bcPOS2                                  ;                               [B3A2]
        lda     #$00                    ; clear HB
        beq     ConvertAY2FAC1          ; convert fixed integer AY to float
                                        ; FAC1, branch always
; check not Direct, used by DEF and INPUT

ChkDirectMode                           ;                               [B3A6]
        ldx     CURLIN+1                ; get current line number HB
        inx                             ; increment it
        bne     A_B34B                  ; return if not direct mode

; else do illegal direct error
        ldx     #$15                    ; error $15, illegal direct error
.byte   $2C                             ; makes next line BIT $1BA2
A_B3AE                                  ;                               [B3AE]
        ldx     #$1B                    ; error $1B, undefined function error
        jmp     OutputErrMsg            ; do error #X then warm start   [A437]


;******************************************************************************
;
; perform DEF

bcDEF                                   ;                               [B3B3]
        jsr     ChkFNxSyntax            ; check FNx syntax              [B3E1]
        jsr     ChkDirectMode           ; check not direct, back here if ok
                                        ;                               [B3A6]
        jsr     Chk4OpenParen           ; scan for "(", else do syntax error
                                        ; then warm start               [AEFA]

        lda     #$80                    ; set flag for FNx
        sta     SUBFLG                  ; save subscript/FNx flag

        jsr     GetAddrVar              ; get variable address          [B08B]
        jsr     CheckIfNumeric          ; check if source is numeric, else do
                                        ; type mismatch                 [AD8D]
        jsr     Chk4CloseParen          ; scan for ")", else do syntax error
                                        ; then warm start               [AEF7]

        lda     #TK_EQUAL               ; get = token
        jsr     Chk4CharInA             ; scan for CHR$(A), else do syntax
                                        ; error then warm start         [AEFF]
        pha                             ; push next character

        lda     VARPNT+1                ; get current variable pointer HB
        pha                             ; push it

        lda     VARPNT                  ; get current variable pointer LB
        pha                             ; push it

        lda     TXTPTR+1                ; get BASIC execute pointer HB
        pha                             ; push it

        lda     TXTPTR                  ; get BASIC execute pointer LB
        pha                             ; push it

        jsr     bcDATA                  ; perform DATA                  [A8F8]
        jmp     Ptrs2Function           ; put execute pointer and variable
                                        ; pointer into function and return
                                        ;                               [B44F]

;******************************************************************************
;
; check FNx syntax

ChkFNxSyntax                            ;                               [B3E1]
        lda     #TK_FN                  ; set FN token
        jsr     Chk4CharInA             ; scan for CHR$(A), else do syntax error
                                        ; then warm start               [AEFF]

        ora     #$80                    ; set FN flag bit
        sta     SUBFLG                  ; save FN name

        jsr     GetAddrVar3             ; search for FN variable        [B092]
        sta     GarbagePtr              ; save function pointer LB
        sty     GarbagePtr+1            ; save function pointer HB

        jmp     CheckIfNumeric          ; check if source is numeric and return,
                                        ; else do type mismatch         [AD8D]

;******************************************************************************
;
; Evaluate FNx

EvaluateFNx                             ;                               [B3F4]
        jsr     ChkFNxSyntax            ; check FNx syntax              [B3E1]

        lda     GarbagePtr+1            ; get function pointer HB
        pha                             ; push it

        lda     GarbagePtr              ; get function pointer LB
        pha                             ; push it

        jsr     Chk4Parens              ; evaluate expression within parentheses
                                        ;                               [AEF1]
        jsr     CheckIfNumeric          ; check if source is numeric, else do
                                        ; type mismatch                 [AD8D]

        pla                             ; pop function pointer LB
        sta     GarbagePtr              ; restore it

        pla                             ; pop function pointer HB
        sta     GarbagePtr+1            ; restore it

        ldy     #$02                    ; index to variable pointer HB
        lda     (GarbagePtr),Y          ; get variable address LB
        sta     VARPNT                  ; save current variable pointer LB

        tax                             ; copy address LB

        iny                             ; index to variable address HB
        lda     (GarbagePtr),Y          ; get variable pointer HB
        beq     A_B3AE                  ; branch if HB zero

        sta     VARPNT+1                ; save current variable pointer HB
        iny                             ; index to mantissa 3

; now stack the function variable value before use
A_B418                                  ;                               [B418]
        lda     (VARPNT),Y              ; get byte from variable
        pha                             ; stack it

        dey                             ; decrement index
        bpl     A_B418                  ; loop until variable stacked

        ldy     VARPNT+1                ; get current variable pointer HB
        jsr     PackFAC1intoXY          ; pack FAC1 into (XY)           [BBD4]

        lda     TXTPTR+1                ; get BASIC execute pointer HB
        pha                             ; push it

        lda     TXTPTR                  ; get BASIC execute pointer LB
        pha                             ; push it

        lda     (GarbagePtr),Y          ; get function execute pointer LB
        sta     TXTPTR                  ; save BASIC execute pointer LB

        iny                             ; index to HB
        lda     (GarbagePtr),Y          ; get function execute pointer HB
        sta     TXTPTR+1                ; save BASIC execute pointer HB

        lda     VARPNT+1                ; get current variable pointer HB
        pha                             ; push it

        lda     VARPNT                  ; get current variable pointer LB
        pha                             ; push it

        jsr     EvalExpression          ; evaluate expression and check is
                                        ; numeric, else do type mismatch [AD8A]
        pla                             ; pull variable address LB
        sta     GarbagePtr              ; save variable address LB

        pla                             ; pull variable address HB
        sta     GarbagePtr+1            ; save variable address HB

        jsr     CHRGOT                  ; scan memory                   [0079]
        beq     A_B449                  ; branch if null ([EOL] marker)

        jmp     SyntaxError             ; else syntax error then warm start
                                        ;                               [AF08]

; restore BASIC execute pointer and function variable from stack

A_B449                                  ;                               [B449]
        pla                             ; pull BASIC execute pointer LB
        sta     TXTPTR                  ; save BASIC execute pointer LB

        pla                             ; pull BASIC execute pointer HB
        sta     TXTPTR+1                ; save BASIC execute pointer HB

;******************************************************************************
;
; put execute pointer and variable pointer into function

Ptrs2Function                           ;                               [B44F]
        ldy     #$00                    ; clear index
        pla                             ; pull BASIC execute pointer LB
        sta     (GarbagePtr),Y          ; save to function

        pla                             ; pull BASIC execute pointer HB
        iny                             ; increment index
        sta     (GarbagePtr),Y          ; save to function

        pla                             ; pull current variable address LB
        iny                             ; increment index
        sta     (GarbagePtr),Y          ; save to function

        pla                             ; pull current variable address HB
        iny                             ; increment index
        sta     (GarbagePtr),Y          ; save to function

        pla                             ; pull ??
        iny                             ; increment index
        sta     (GarbagePtr),Y          ; save to function

        rts


;******************************************************************************
;
; perform STR$()

bcSTR                                   ;                               [B465]
        jsr     CheckIfNumeric          ; check if source is numeric, else do
                                        ; type mismatch                 [AD8D]
        ldy     #$00                    ; set string index
        jsr     FAC12String             ; convert FAC1 to string        [BDDF]

        pla                             ; dump return address (skip type check)
        pla                             ; dump return address (skip type check)
bcSTR2                                  ;                               [B46F]
        lda     #<StrConvAddr           ; set result string low pointer

        ldy     #>StrConvAddr           ; set result string high pointer
        beq     QuoteStr2UtPtr          ; print null terminated string to
                                        ; utility pointer

;******************************************************************************
;
; do string vector
; copy descriptor pointer and make string space A bytes long

StringVector                            ;                               [B475]
        ldx     FacMantissa+2           ; get descriptor pointer LB
        ldy     FacMantissa+3           ; get descriptor pointer HB
        stx     TempPtr                 ; save descriptor pointer LB
        sty     TempPtr+1               ; save descriptor pointer HB


;******************************************************************************
;
; make string space A bytes long

StringLengthA                           ;                               [B47D]
        jsr     CreStrAlong             ; make space in string memory for string
                                        ; A long                        [B4F4]
        stx     FacMantissa             ; save string pointer LB
        sty     FacMantissa+1           ; save string pointer HB
        sta     FACEXP                  ; save length

        rts


;******************************************************************************
;
; scan, set up string
; print " terminated string to utility pointer

QuoteStr2UtPtr                          ;                               [B487]
        ldx     #'"'                    ; set terminator to "
        stx     CHARAC                  ; set search character, terminator 1
        stx     ENDCHR                  ; set terminator 2

; print search or alternate terminated string to utility pointer
; source is AY

PrtStr2UtiPtr                           ;                               [B48D]
        sta     ARISGN                  ; store string start LB
        sty     FACOV                   ; store string start HB
        sta     FacMantissa             ; save string pointer LB
        sty     FacMantissa+1           ; save string pointer HB

        ldy     #$FF                    ; set length to -1
A_B497                                  ;                               [B497]
        iny                             ; increment length
        lda     (ARISGN),Y              ; get byte from string
        beq     A_B4A8                  ; exit loop if null byte [EOS]

        cmp     CHARAC                  ; compare with search character,
                                        ; terminator 1
        beq     A_B4A4                  ; branch if terminator

        cmp     ENDCHR                  ; compare with terminator 2
        bne     A_B497                  ; loop if not terminator 2

A_B4A4                                  ;                               [B4A4]
        cmp     #'"'                    ; compare with "
        beq     A_B4A9                  ; branch if " (carry set if = !)

A_B4A8                                  ;                               [B4A8]
        clc                             ; clear carry for add (only if [EOL]
                                        ; terminated string)
A_B4A9                                  ;                               [B4A9]
        sty     FACEXP                  ; save length in FAC1 exponent

        tya                             ; copy length to A
        adc     ARISGN                  ; add string start LB
        sta     FBUFPT                  ; save string end LB

        ldx     FACOV                   ; get string start HB
        bcc     A_B4B5                  ; branch if no LB overflow

        inx                             ; else increment HB
A_B4B5                                  ;                               [B4B5]
        stx     FBUFPT+1                ; save string end HB

        lda     FACOV                   ; get string start HB
        beq     A_B4BF                  ; branch if in utility area

        cmp     #$02                    ; compare with input buffer memory HB
        bne     ChkRoomDescStk          ; branch if not in input buffer memory

; string in input buffer or utility area, move to string memory
A_B4BF                                  ;                               [B4BF]
        tya                             ; copy length to A
        jsr     StringVector            ; copy descriptor pointer and make
                                        ; string space A bytes long     [B475]
        ldx     ARISGN                  ; get string start LB
        ldy     FACOV                   ; get string start HB
S_B4C7 
        jsr     Str2UtilPtr2            ; store string A bytes long from XY to
                                        ; utility pointer               [B688]

; check for space on descriptor stack then ...
; put string address and length on descriptor stack and update stack pointers

ChkRoomDescStk                          ;                               [B4CA]
        ldx     TEMPPT                  ; get the descriptor stack pointer
        cpx     #LASTPT+2+9             ; compare it with the maximum + 1
        bne     A_B4D5                  ; if there is space on the string stack
                                        ; continue
; else do string too complex error
        ldx     #$19                    ; error $19, string too complex error
A_B4D2                                  ;                               [B4D2]
        jmp     OutputErrMsg            ; do error #X then warm start   [A437]

; put string address and length on descriptor stack and update stack pointers

A_B4D5                                  ;                               [B4D5]
        lda     FACEXP                  ; get the string length
        sta     D6510,X                 ; put it on the string stack

        lda     FacMantissa             ; get the string pointer LB
        sta     D6510+1,X               ; put it on the string stack

        lda     FacMantissa+1           ; get the string pointer HB
        sta     D6510+2,X               ; put it on the string stack

        ldy     #$00                    ; clear Y
        stx     FacMantissa+2           ; save the string descriptor pointer LB
        sty     FacMantissa+3           ; save the string descriptor pointer HB,
                                        ; always $00
        sty     FACOV                   ; clear FAC1 rounding byte

        dey                             ; Y = $FF
        sty     VALTYP                  ; save the data type flag, $FF = string
        stx     LASTPT                  ; save the current descriptor stack
                                        ; item pointer LB
        inx                             ; update the stack pointer
        inx                             ; update the stack pointer
        inx                             ; update the stack pointer
        stx     TEMPPT                  ; save the new descriptor stack pointer

        rts


;******************************************************************************
;
; make space in string memory for string A long
; return X = pointer LB, Y = pointer HB

CreStrAlong                             ;                               [B4F4]
        lsr     GARBFL                  ; clear garbage collected flag (b7)

; make space for string A long
A_B4F6                                  ;                               [B4F6]
        pha                             ; save string length

        eor     #$FF                    ; complement it
        sec                             ; set carry for subtract, two's
                                        ; complement add
        adc     FRETOP                  ; add bottom of string space LB,
                                        ; subtract length
        ldy     FRETOP+1                ; get bottom of string space HB
        bcs     A_B501                  ; skip decrement if no underflow

        dey                             ; decrement bottom of string space HB
A_B501                                  ;                               [B501]
        cpy     STREND+1                ; compare with end of arrays HB
        bcc     A_B516                  ; do out of memory error if less

        bne     A_B50B                  ; if not = skip next test

        cmp     STREND                  ; compare with end of arrays LB
        bcc     A_B516                  ; do out of memory error if less

A_B50B                                  ;                               [B50B]
        sta     FRETOP                  ; save bottom of string space LB
        sty     FRETOP+1                ; save bottom of string space HB
        sta     FRESPC                  ; save string utility ptr LB
        sty     FRESPC+1                ; save string utility ptr HB

        tax                             ; copy LB to X

        pla                             ; get string length back
        rts

A_B516                                  ;                               [B516]
        ldx     #$10                    ; error code $10, out of memory error

        lda     GARBFL                  ; get garbage collected flag
        bmi     A_B4D2                  ; if set then do error code X

        jsr     CollectGarbage          ; else go do garbage collection [B526]

        lda     #$80                    ; flag for garbage collected
        sta     GARBFL                  ; set garbage collected flag

        pla                             ; pull length
        bne     A_B4F6                  ; go try again (loop always, length
                                        ; should never be = $00)

;******************************************************************************
;
; garbage collection routine

CollectGarbage                          ;                               [B526]
        ldx     MEMSIZ                  ; get end of memory LB
        lda     MEMSIZ+1                ; get end of memory HB

; re-run routine from last ending

CollectGarbag2                          ;                               [B52A]
        stx     FRETOP                  ; set bottom of string space LB
        sta     FRETOP+1                ; set bottom of string space HB

        ldy     #$00                    ; clear index
        sty     GarbagePtr+1            ; clear working pointer HB
        sty     GarbagePtr              ; clear working pointer LB

        lda     STREND                  ; get end of arrays LB
        ldx     STREND+1                ; get end of arrays HB
        sta     FacTempStor+8           ; save as highest uncollected string
                                        ; pointer LB
        stx     FacTempStor+9           ; save as highest uncollected string
                                        ; pointer HB
        lda     #LASTPT+2               ; set descriptor stack pointer
        ldx     #$00                    ; clear X
        sta     INDEX                   ; save descriptor stack pointer LB
        stx     INDEX+1                 ; save descriptor stack pointer HB ($00)
A_B544                                  ;                               [B544]
        cmp     TEMPPT                  ; compare with descriptor stack pointer
        beq     A_B54D                  ; branch if =

        jsr     ChkStrSalvage           ; check string salvageability   [B5C7]
        beq     A_B544                  ; loop always

; done stacked strings, now do string variables
A_B54D                                  ;                               [B54D]
        lda     #$07                    ; set step size = $07, collecting
                                        ; variables
        sta     GarbColStep             ; save garbage collection step size

        lda     VARTAB                  ; get start of variables LB
        ldx     VARTAB+1                ; get start of variables HB
        sta     INDEX                   ; save as pointer LB
        stx     INDEX+1                 ; save as pointer HB
A_B559                                  ;                               [B559]
        cpx     ARYTAB+1                ; compare end of variables HB,
                                        ; start of arrays HB
        bne     A_B561                  ; branch if no HB match

        cmp     ARYTAB                  ; else compare end of variables LB,
                                        ; start of arrays LB
        beq     A_B566                  ; branch if = variable memory end

A_B561                                  ;                               [B561]
        jsr     ChkVarSalvage           ; check variable salvageability [B5BD]
        beq     A_B559                  ; loop always

; done string variables, now do string arrays
A_B566                                  ;                               [B566]
        sta     FacTempStor+1           ; save start of arrays LB as working
                                        ; pointer
        stx     FacTempStor+2           ; save start of arrays HB as working
                                        ; pointer

        lda     #$03                    ; set step size, collecting descriptors
        sta     GarbColStep             ; save step size
A_B56E                                  ;                               [B56E]
        lda     FacTempStor+1           ; get pointer LB
        ldx     FacTempStor+2           ; get pointer HB
A_B572                                  ;                               [B572]
        cpx     STREND+1                ; compare with end of arrays HB
        bne     A_B57D                  ; branch if not at end

        cmp     STREND                  ; else compare with end of arrays LB
        bne     A_B57D                  ; branch if not at end

        jmp     CollectString           ; collect string, tidy up and exit if
                                        ; at end ??                     [B606]

A_B57D                                  ;                               [B57D]
        sta     INDEX                   ; save pointer LB
        stx     INDEX+1                 ; save pointer HB

        ldy     #$00                    ; set index
        lda     (INDEX),Y               ; get array name first byte
        tax                             ; copy it

        iny                             ; increment index
        lda     (INDEX),Y               ; get array name second byte

        php                             ; push the flags

        iny                             ; increment index
        lda     (INDEX),Y               ; get array size LB
        adc     FacTempStor+1           ; add start of this array LB
        sta     FacTempStor+1           ; save start of next array LB

        iny                             ; increment index
        lda     (INDEX),Y               ; get array size HB
        adc     FacTempStor+2           ; add start of this array HB
        sta     FacTempStor+2           ; save start of next array HB

        plp                             ; restore the flags
        bpl     A_B56E                  ; skip if not string array

; was possibly string array so ...

        txa                             ; get name first byte back
        bmi     A_B56E                  ; skip if not string array

        iny                             ; increment index
        lda     (INDEX),Y               ; get # of dimensions
        ldy     #$00                    ; clear index
        asl                             ; *2
        adc     #$05                    ; +5 (array header size)
        adc     INDEX                   ; add pointer LB
        sta     INDEX                   ; save pointer LB
        bcc     A_B5AE                  ; branch if no rollover

        inc     INDEX+1                 ; else increment pointer hgih byte
A_B5AE                                  ;                               [B5AE]
        ldx     INDEX+1                 ; get pointer HB
A_B5B0                                  ;                               [B5B0]
        cpx     FacTempStor+2           ; compare pointer HB with end of this
                                        ; array HB
        bne     A_B5B8                  ; branch if not there yet

        cmp     FacTempStor+1           ; compare pointer LB with end of this
                                        ; array LB
        beq     A_B572                  ; if at end of this array go check next
                                        ; array
A_B5B8                                  ;                               [B5B8]
        jsr     ChkStrSalvage           ; check string salvageability   [B5C7]
        beq     A_B5B0                  ; loop

; check variable salvageability

ChkVarSalvage                           ;                               [B5BD]
        lda     (INDEX),Y               ; get variable name first byte
        bmi     A_B5F6                  ; add step and exit if not string

        iny                             ; increment index
        lda     (INDEX),Y               ; get variable name second byte
        bpl     A_B5F6                  ; add step and exit if not string

        iny                             ; increment index

; check string salvageability

ChkStrSalvage                           ;                               [B5C7]
        lda     (INDEX),Y               ; get string length
        beq     A_B5F6                  ; add step and exit if null string

        iny                             ; increment index
        lda     (INDEX),Y               ; get string pointer LB
        tax                             ; copy to X

        iny                             ; increment index
        lda     (INDEX),Y               ; get string pointer HB
        cmp     FRETOP+1                ; compare string pointer HB with bottom
                                        ; of string space HB
        bcc     A_B5DC                  ; if bottom of string space greater, go
                                        ; test against highest uncollected
                                        ; string
        bne     A_B5F6                  ; if bottom of string space less string
                                        ; has been collected so go update
                                        ; pointers, step to next and return
; HBs were equal so test LBs
        cpx     FRETOP                  ; compare string pointer LB with bottom
                                        ; of string space LB
        bcs     A_B5F6                  ; if bottom of string space less string
                                        ; has been collected so go update
                                        ; pointers, step to next and return
; else test string against highest uncollected string so far
A_B5DC                                  ;                               [B5DC]
        cmp     FacTempStor+9           ; compare string pointer HB with highest
                                        ; uncollected string HB
        bcc     A_B5F6                  ; if highest uncollected string is
                                        ; greater then go update pointers, step
                                        ; to next and return
        bne     A_B5E6                  ; if highest uncollected string is less
                                        ; then go set this string as highest
                                        ; uncollected so far
; HBs were equal so test LBs
        cpx     FacTempStor+8           ; compare string pointer LB with highest
                                        ; uncollected string LB
        bcc     A_B5F6                  ; if highest uncollected string is
                                        ; greater then go update pointers, step
                                        ; to next and return
; else set current string as highest uncollected string
A_B5E6                                  ;                               [B5E6]
        stx     FacTempStor+8           ; save string pointer LB as highest
                                        ; uncollected string LB
        sta     FacTempStor+9           ; save string pointer HB as highest
                                        ; uncollected string HB
        lda     INDEX                   ; get descriptor pointer LB
        ldx     INDEX+1                 ; get descriptor pointer HB
        sta     GarbagePtr              ; save working pointer HB
        stx     GarbagePtr+1            ; save working pointer LB

        lda     GarbColStep             ; get step size
        sta     Jump0054+1              ; copy step size
A_B5F6                                  ;                               [B5F6]
        lda     GarbColStep             ; get step size
        clc                             ; clear carry for add
        adc     INDEX                   ; add pointer LB
        sta     INDEX                   ; save pointer LB
        bcc     A_B601                  ; branch if no rollover

        inc     INDEX+1                 ; else increment pointer HB
A_B601                                  ;                               [B601]
        ldx     INDEX+1                 ; get pointer HB
        ldy     #$00                    ; flag not moved
        rts

; collect string

CollectString                           ;                               [B606]
        lda     GarbagePtr+1            ; get working pointer LB
        ora     GarbagePtr              ; OR working pointer HB
        beq     A_B601                  ; exit if nothing to collect

        lda     Jump0054+1              ; get copied step size
        and     #$04                    ; mask step size, $04 for variables,
                                        ; $00 for array or stack
        lsr                             ; >> 1
        tay                             ; copy to index
        sta     Jump0054+1              ; save offset to descriptor start

        lda     (GarbagePtr),Y          ; get string length LB
        adc     FacTempStor+8           ; add string start LB
        sta     FacTempStor+3           ; set block end LB

        lda     FacTempStor+9           ; get string start HB
        adc     #$00                    ; add carry
        sta     FacTempStor+4           ; set block end HB

        lda     FRETOP                  ; get bottom of string space LB
        ldx     FRETOP+1                ; get bottom of string space HB
        sta     FacTempStor+1           ; save destination end LB
        stx     FacTempStor+2           ; save destination end HB

        jsr     MoveBlock2              ; open up space in memory, don't set
                                        ; array end. this copies the string from
                                        ; where it is to the end of the
                                        ; uncollected string memory     [A3BF]
        ldy     Jump0054+1              ; restore offset to descriptor start
        iny                             ; increment index to string pointer LB
        lda     FacTempStor+1           ; get new string pointer LB
        sta     (GarbagePtr),Y          ; save new string pointer LB
        tax                             ; copy string pointer LB

        inc     FacTempStor+2           ; increment new string pointer HB

        lda     FacTempStor+2           ; get new string pointer HB
        iny                             ; increment index to string pointer HB
        sta     (GarbagePtr),Y          ; save new string pointer HB

        jmp     CollectGarbag2          ; re-run routine from last ending, XA
                                        ; holds new bottom              [B52A]
                                        ; of string memory pointer


;******************************************************************************
;
; concatenate
; add strings, the first string is in the descriptor, the second string is in
; line

ConcatStrings                           ;                               [B63D]
        lda     FacMantissa+3           ; get descriptor pointer HB
        pha                             ; put on stack

        lda     FacMantissa+2           ; get descriptor pointer LB
        pha                             ; put on stack

        jsr     GetNextParm             ; get value from line           [AE83]
        jsr     CheckIfString           ; check if source is string, else do
                                        ; type mismatch                 [AD8F]
        pla                             ; get descriptor pointer LB back
        sta     ARISGN                  ; set pointer LB

        pla                             ; get descriptor pointer HB back
        sta     FACOV                   ; set pointer HB

        ldy     #$00                    ; clear index
        lda     (ARISGN),Y              ; get length of first string from 
                                        ; descriptor
        clc                             ; clear carry for add
        adc     (FacMantissa+2),Y       ; add length of second string
        bcc     A_B65D                  ; branch if no overflow

        ldx     #$17                    ; else error $17, string too long error
        jmp     OutputErrMsg            ; do error #X then warm start   [A437]

A_B65D                                  ;                               [B65D]
        jsr     StringVector            ; copy descriptor pointer and make
                                        ; string space A bytes long     [B475]
        jsr     Str2UtilPtr             ; copy string from descriptor to utility
                                        ; pointer                       [B67A]

        lda     TempPtr                 ; get descriptor pointer LB
        ldy     TempPtr+1               ; get descriptor pointer HB
        jsr     PopStrDescStk2          ; pop (YA) descriptor off stack or from
                                        ; top of string space returns with
                                        ; A = length, X = pointer LB,
                                        ; Y = pointer HB                [B6AA]
        jsr     Str2UtilPtr3            ; store string from pointer to utility
                                        ; pointer                       [B68C]
        lda     ARISGN                  ; get descriptor pointer LB
        ldy     FACOV                   ; get descriptor pointer HB
        jsr     PopStrDescStk2          ; pop (YA) descriptor off stack or from
                                        ; top of string space returns with
                                        ; A = length, X = pointer LB,
                                        ; Y = pointer HB                [B6AA]
        jsr     ChkRoomDescStk          ; check space on descriptor stack then
                                        ; put string address and length on
                                        ; descriptor stack and update stack
                                        ; pointers                      [B4CA]
        jmp     EvaluateValue3          ; continue evaluation           [ADB8]


;******************************************************************************
;
; copy string from descriptor to utility pointer

Str2UtilPtr                             ;                               [B67A]
        ldy     #$00                    ; clear index
        lda     (ARISGN),Y              ; get string length
        pha                             ; save it

        iny                             ; increment index
        lda     (ARISGN),Y              ; get string pointer LB
        tax                             ; copy to X

        iny                             ; increment index
        lda     (ARISGN),Y              ; get string pointer HB
        tay                             ; copy to Y

        pla                             ; get length back
Str2UtilPtr2                            ;                               [B688]
        stx     INDEX                   ; save string pointer LB
        sty     INDEX+1                 ; save string pointer HB

; store string from pointer to utility pointer

Str2UtilPtr3                            ;                               [B68C]
        tay                             ; copy length as index
        beq     A_B699                  ; branch if null string

        pha                             ; save length
A_B690                                  ;                               [B690]
        dey                             ; decrement length/index
        lda     (INDEX),Y               ; get byte from string
        sta     (FRESPC),Y              ; save byte to destination

        tya                             ; copy length/index
        bne     A_B690                  ; loop if not all done yet

        pla                             ; restore length
A_B699                                  ;                               [B699]
        clc                             ; clear carry for add
        adc     FRESPC                  ; add string utility ptr LB
        sta     FRESPC                  ; save string utility ptr LB
        bcc     A_B6A2                  ; branch if no rollover

        inc     FRESPC+1                ; increment string utility ptr HB
A_B6A2                                  ;                               [B6A2]
        rts


;******************************************************************************
;
; evaluate string

EvalString                              ;                               [B6A3]
        jsr     CheckIfString           ; check if source is string, else do
                                        ; type mismatch                 [AD8F]

; pop string off descriptor stack, or from top of string space
; returns with A = length, X = pointer LB, Y = pointer HB

PopStrDescStk                           ;                               [B6A6]
        lda     FacMantissa+2           ; get descriptor pointer LB
        ldy     FacMantissa+3           ; get descriptor pointer HB

; pop (YA) descriptor off stack or from top of string space
; returns with A = length, X = pointer LB, Y = pointer HB

PopStrDescStk2                          ;                               [B6AA]
        sta     INDEX                   ; save string pointer LB
        sty     INDEX+1                 ; save string pointer HB

        jsr     ClrDescrStack           ; clean descriptor stack, YA = pointer
                                        ;                               [B6DB]
        php                             ; save status flags

        ldy     #$00                    ; clear index
        lda     (INDEX),Y               ; get length from string descriptor
        pha                             ; put on stack

        iny                             ; increment index
        lda     (INDEX),Y               ; get string pointer LB from descriptor
        tax                             ; copy to X

        iny                             ; increment index
        lda     (INDEX),Y               ; get string pointer HB from descriptor
        tay                             ; copy to Y

        pla                             ; get string length back

        plp                             ; restore status
        bne     A_B6D6                  ; branch if pointer <> last_sl,last_sh

        cpy     FRETOP+1                ; compare with bottom of string space HB
        bne     A_B6D6                  ; branch if <>

        cpx     FRETOP                  ; else compare with bottom of string
                                        ; space LB
        bne     A_B6D6                  ; branch if <>

        pha                             ; save string length

        clc                             ; clear carry for add
        adc     FRETOP                  ; add bottom of string space LB
        sta     FRETOP                  ; set bottom of string space LB
        bcc     A_B6D5                  ; skip increment if no overflow

        inc     FRETOP+1                ; increment bottom of string space HB
A_B6D5                                  ;                               [B6D5]
        pla                             ; restore string length
A_B6D6                                  ;                               [B6D6]
        stx     INDEX                   ; save string pointer LB
        sty     INDEX+1                 ; save string pointer HB

        rts

; clean descriptor stack, YA = pointer
; checks if AY is on the descriptor stack, if so does a stack discard

ClrDescrStack                           ;                               [B6DB]
        cpy     LASTPT+1                ; compare HB with current descriptor
                                        ; stack item pointer HB
        bne     A_B6EB                  ; exit if <>

        cmp     LASTPT                  ; compare LB with current descriptor
                                        ; stack item pointer LB
        bne     A_B6EB                  ; exit if <>

        sta     TEMPPT                  ; set descriptor stack pointer
        sbc     #$03                    ; update last string pointer LB
        sta     LASTPT                  ; save current descriptor stack item
                                        ; pointer LB
        ldy     #$00                    ; clear HB
A_B6EB                                  ;                               [B6EB]
        rts


;******************************************************************************
;
; perform CHR$()

bcCHR                                   ;                               [B6EC]
        jsr     EvalByteExpr            ; evaluate byte expression, result in X
                                        ;                               [B7A1]
        txa                             ; copy to A
        pha                             ; save character

        lda     #$01                    ; string is single byte
        jsr     StringLengthA           ; make string space A bytes long [B47D]

        pla                             ; get character back
        ldy     #$00                    ; clear index
        sta     (FacMantissa),Y         ; save byte in string - byte IS string!

        pla                             ; dump return address (skip type check)
        pla                             ; dump return address (skip type check)

        jmp     ChkRoomDescStk          ; check space on descriptor stack then
                                        ; put string address and length on
                                        ; descriptor stack and update stack
                                        ; pointers                      [B4CA]

;******************************************************************************
;
; perform LEFT$()

bcLEFT                                  ;                               [B700]
        jsr     PullStrFromStk          ; pull string data and byte parameter
                                        ; from stack return pointer in
                                        ; descriptor, byte in A (and X), Y=0
                                        ;                               [B761]
        cmp     (TempPtr),Y             ; compare byte parameter with string
                                        ; length
        tya                             ; clear A
bcLEFT2                                 ;                               [B706]
        bcc     A_B70C                  ; branch if string length > byte param

        lda     (TempPtr),Y             ; else make parameter = length
        tax                             ; copy to byte parameter copy

        tya                             ; clear string start offset
A_B70C                                  ;                               [B70C]
        pha                             ; save string start offset
A_B70D                                  ;                               [B70D]
        txa                             ; copy byte parameter (or string length
                                        ; if <)
A_B70E                                  ;                               [B70E]
        pha                             ; save string length

        jsr     StringLengthA           ; make string space A bytes long [B47D]

        lda     TempPtr                 ; get descriptor pointer LB
        ldy     TempPtr+1               ; get descriptor pointer HB
        jsr     PopStrDescStk2          ; pop (YA) descriptor off stack or from
                                        ; top of string space returns with
                                        ; A = length, X = pointer LB,
                                        ; Y = pointer HB                [B6AA]
        pla                             ; get string length back
        tay                             ; copy length to Y

        pla                             ; get string start offset back
        clc                             ; clear carry for add
        adc     INDEX                   ; add start offset to string start
                                        ; pointer LB
        sta     INDEX                   ; save string start pointer LB
        bcc     A_B725                  ; branch if no overflow

        inc     INDEX+1                 ; else increment string start pointer HB
A_B725                                  ;                               [B725]
        tya                             ; copy length to A
        jsr     Str2UtilPtr3            ; store string from pointer to utility
                                        ; pointer                       [B68C]

        jmp     ChkRoomDescStk          ; check space on descriptor stack then
                                        ; put string address and length on
                                        ; descriptor stack and update stack
                                        ; pointers                      [B4CA]

;******************************************************************************
;
; perform RIGHT$()

bcRIGHT                                 ;                               [B72C]
        jsr     PullStrFromStk          ; pull string data and byte parameter
                                        ; from stack return pointer in
                                        ; descriptor, byte in A (and X), Y=0
                                        ;                               [B761]
        clc                             ; clear carry for add-1
        sbc     (TempPtr),Y             ; subtract string length
        eor     #$FF                    ; invert it (A=LEN(expression$)-l)
        jmp     bcLEFT2                 ; go do rest of LEFT$()         [B706]


;******************************************************************************
;
; perform MID$()

bcMID                                   ;                               [B737]
        lda     #$FF                    ; set default length = 255
        sta     FacMantissa+3           ; save default length

        jsr     CHRGOT                  ; scan memory                   [0079]
        cmp     #')'                    ; compare with ")"
        beq     A_B748                  ; branch if = ")" (skip second byte get)

        jsr     Chk4Comma               ; scan for ",", else do syntax error
                                        ; then warm start               [AEFD]
        jsr     GetByteParm2            ; get byte parameter            [B79E]
A_B748                                  ;                               [B748]
        jsr     PullStrFromStk          ; pull string data and byte parameter
                                        ; from stack return pointer in
                                        ; descriptor, byte in A (and X), Y=0
                                        ;                               [B761]
        beq     A_B798                  ; if null do illegal quantity error then
                                        ; warm start
        dex                             ; decrement start index
        txa                             ; copy to A
        pha                             ; save string start offset

        clc                             ; clear carry for sub-1
        ldx     #$00                    ; clear output string length
        sbc     (TempPtr),Y             ; subtract string length
        bcs     A_B70D                  ; if start>string length go do null
                                        ; string
        eor     #$FF                    ; complement -length
        cmp     FacMantissa+3           ; compare byte parameter
        bcc     A_B70E                  ; if length > remaining string go do
                                        ; RIGHT$
        lda     FacMantissa+3           ; get length byte
        bcs     A_B70E                  ; go do string copy, branch always


;******************************************************************************
;
; pull string data and byte parameter from stack
; return pointer in descriptor, byte in A (and X), Y=0

PullStrFromStk                          ;                               [B761]
        jsr     Chk4CloseParen          ; scan for ")", else do syntax error
                                        ; then warm start               [AEF7]
        pla                             ; pull return address LB
        tay                             ; save return address LB

        pla                             ; pull return address HB
        sta     Jump0054+1              ; save return address HB

        pla                             ; dump call to function vector LB
        pla                             ; dump call to function vector HB

        pla                             ; pull byte parameter
        tax                             ; copy byte parameter to X

        pla                             ; pull string pointer LB
        sta     TempPtr                 ; save it

        pla                             ; pull string pointer HB
        sta     TempPtr+1               ; save it

        lda     Jump0054+1              ; get return address HB
        pha                             ; back on stack

        tya                             ; get return address LB
        pha                             ; back on stack

        ldy     #$00                    ; clear index
        txa                             ; copy byte parameter

        rts


;******************************************************************************
;
; perform LEN()

bcLEN                                   ;                               [B77C]
        jsr     GetLengthStr            ; evaluate string, get length in A
                                        ; (and Y)                       [B782]
        jmp     bcPOS2                  ; convert Y to byte in FAC1 and return
                                        ;                               [B3A2]

;******************************************************************************
;
; evaluate string, get length in Y

GetLengthStr                            ;                               [B782]
        jsr     EvalString              ; evaluate string               [B6A3]

        ldx     #$00                    ; set data type = numeric
        stx     VALTYP                  ; clear data type flag, $FF = string,
                                        ; $00 = numeric
        tay                             ; copy length to Y

        rts


;******************************************************************************
;
; perform ASC()

bcASC                                   ;                               [B78B]
        jsr     GetLengthStr            ; evaluate string, get length in A
                                        ; (and Y)                       [B782]
        beq     A_B798                  ; if null do illegal quantity error then
                                        ; warm start
        ldy     #$00                    ; set index to first character
        lda     (INDEX),Y               ; get byte
        tay                             ; copy to Y

        jmp     bcPOS2                  ; convert Y to byte in FAC1 and return
                                        ;                               [B3A2]

;******************************************************************************
;
; do illegal quantity error then warm start

A_B798                                  ;                               [B798]
        jmp     IllegalQuant            ; do illegal quantity error then warm
                                        ; start                         [B248]

;******************************************************************************
;
; scan and get byte parameter

GetByteParm                             ;                               [B79B]
        jsr     CHRGET                  ; increment and scan memory     [0073]


;******************************************************************************
;
; get byte parameter

GetByteParm2                            ;                               [B79E]
        jsr     EvalExpression          ; evaluate expression and check is
                                        ; numeric, else do type mismatch [AD8A]

;******************************************************************************
;
; evaluate byte expression, result in X

EvalByteExpr                            ;                               [B7A1]
        jsr     EvalInteger2            ; evaluate integer expression, sign
                                        ; check                         [B1B8]
        ldx     FacMantissa+2           ; get FAC1 mantissa 3
        bne     A_B798                  ; if not null do illegal quantity error
                                        ; then warm start
        ldx     FacMantissa+3           ; get FAC1 mantissa 4
        jmp     CHRGOT                  ; scan memory and return        [0079]


;******************************************************************************
;
; perform VAL()

bcVAL                                   ;                               [B7AD]
        jsr     GetLengthStr            ; evaluate string, get length in A
                                        ; (and Y)                       [B782]
        bne     A_B7B5                  ; branch if not null string

; string was null so set result = $00
        jmp     ClrFAC1ExpSgn           ; clear FAC1 exponent and sign and
                                        ; return                        [B8F7]
A_B7B5                                  ;                               [B7B5]
        ldx     TXTPTR                  ; get BASIC execute pointer LB
        ldy     TXTPTR+1                ; get BASIC execute pointer HB
        stx     FBUFPT                  ; save BASIC execute pointer LB
        sty     FBUFPT+1                ; save BASIC execute pointer HB

        ldx     INDEX                   ; get string pointer LB
        stx     TXTPTR                  ; save BASIC execute pointer LB

        clc                             ; clear carry for add
        adc     INDEX                   ; add string length
        sta     INDEX+2                 ; save string end LB

        ldx     INDEX+1                 ; get string pointer HB
        stx     TXTPTR+1                ; save BASIC execute pointer HB
        bcc     A_B7CD                  ; branch if no HB increment

        inx                             ; increment string end HB
A_B7CD                                  ;                               [B7CD]
        stx     INDEX+3                 ; save string end HB

        ldy     #$00                    ; set index to $00
        lda     (INDEX+2),Y             ; get string end byte
        pha                             ; push it

        tya                             ; clear A
        sta     (INDEX+2),Y             ; terminate string with $00

        jsr     CHRGOT                  ; scan memory                   [0079]
        jsr     String2FAC1             ; get FAC1 from string          [BCF3]

        pla                             ; restore string end byte
        ldy     #$00                    ; clear index
        sta     (INDEX+2),Y             ; put string end byte back


;******************************************************************************
;
; restore BASIC execute pointer from temp

RestBasExecPtr                          ;                               [B7E2]
        ldx     FBUFPT                  ; get BASIC execute pointer LB back
        ldy     FBUFPT+1                ; get BASIC execute pointer HB back
        stx     TXTPTR                  ; save BASIC execute pointer LB
        sty     TXTPTR+1                ; save BASIC execute pointer HB

        rts


;******************************************************************************
;
; get parameters for POKE/WAIT

GetParms                                ;                               [B7EB]
        jsr     EvalExpression          ; evaluate expression and check is
                                        ; numeric, else do type mismatch [AD8A]
        jsr     FAC1toTmpInt            ; convert FAC_1 to integer in temporary
                                        ; integer                       [B7F7]
GetParms2                               ;                               [B7F1]
        jsr     Chk4Comma               ; scan for ",", else do syntax error
                                        ; then warm start               [AEFD]
        jmp     GetByteParm2            ; get byte parameter and return [B79E]


;******************************************************************************
;
; convert FAC_1 to integer in temporary integer

FAC1toTmpInt                            ;                               [B7F7]
        lda     FACSGN                  ; get FAC1 sign
        bmi     A_B798                  ; if -ve do illegal quantity error then
                                        ; warm start
        lda     FACEXP                  ; get FAC1 exponent
        cmp     #$91                    ; compare with exponent = 2^16
        bcs     A_B798                  ; if >= do illegal quantity error then
                                        ; warm start
        jsr     FAC1Float2Fix           ; convert FAC1 floating to fixed [BC9B]

        lda     FacMantissa+2           ; get FAC1 mantissa 3
        ldy     FacMantissa+3           ; get FAC1 mantissa 4
        sty     LINNUM                  ; save temporary integer LB
        sta     LINNUM+1                ; save temporary integer HB

        rts


;******************************************************************************
;
; perform PEEK()

bcPEEK                                  ;                               [B80D]
        lda     LINNUM+1                ; get line number HB
        pha                             ; save line number HB

        lda     LINNUM                  ; get line number LB
        pha                             ; save line number LB

        jsr     FAC1toTmpInt            ; convert FAC_1 to integer in temporary
                                        ; integer                       [B7F7]
        ldy     #$00                    ; clear index
        lda     (LINNUM),Y              ; read byte
        tay                             ; copy byte to A

        pla                             ; pull byte
        sta     LINNUM                  ; restore line number LB

        pla                             ; pull byte
        sta     LINNUM+1                ; restore line number HB

        jmp     bcPOS2                  ; convert Y to byte in FAC_1 and return
                                        ;                               [B3A2]

;******************************************************************************
;
; perform POKE

bcPOKE                                  ;                               [B824]
        jsr     GetParms                ; get parameters for POKE/WAIT  [B7EB]
        txa                             ; copy byte to A
        ldy     #$00                    ; clear index
        sta     (LINNUM),Y              ; write byte
        rts


;******************************************************************************
;
; perform WAIT

bcWAIT                                  ;                               [B82D]
        jsr     GetParms                ; get parameters for POKE/WAIT  [B7EB]
        stx     FORPNT                  ; save byte

        ldx     #$00                    ; clear mask
        jsr     CHRGOT                  ; scan memory                   [0079]
        beq     A_B83C                  ; skip if no third argument

        jsr     GetParms2               ; scan for "," and get byte, else syntax
                                        ; error then warm start [B7F1]
A_B83C                                  ;                               [B83C]
        stx     FORPNT+1                ; save EOR argument

        ldy     #$00                    ; clear index
A_B840                                  ;                               [B840]
        lda     (LINNUM),Y              ; get byte via temporary integer
        eor     FORPNT+1                ; EOR with second argument (mask)
        and     FORPNT                  ; AND with first argument (byte)
        beq     A_B840                  ; loop if result is zero

A_B848                                  ;                               [B848]
        rts


;******************************************************************************
;
; add 0.5 to FAC1 (round FAC1)

FAC1plus05                              ;                               [B849]
        lda     #<L_BF11                ; set 0.5 pointer LB
        ldy     #>L_BF11                ; set 0.5 pointer HB
        jmp     AddFORvar2FAC1          ; add (AY) to FAC1              [B867]


;******************************************************************************
;
; perform subtraction, FAC1 from (AY)

AYminusFAC1                             ;                               [B850]
        jsr     UnpackAY2FAC2           ; unpack memory (AY) into FAC2  [BA8C]


;******************************************************************************
;
; perform subtraction, FAC1 from FAC2

bcMINUS 
        lda     FACSGN                  ; get FAC1 sign (b7)
        eor     #$FF                    ; complement it
        sta     FACSGN                  ; save FAC1 sign (b7)
        eor     ARGSGN                  ; EOR with FAC2 sign (b7)
        sta     ARISGN                  ; save sign compare (FAC1 EOR FAC2)
        lda     FACEXP                  ; get FAC1 exponent
        jmp     bcPLUS                  ; add FAC2 to FAC1 and return   [B86A]

A_B862                                  ;                               [B862]
        jsr     shftFACxAright          ; shift FACX A times right (>8 shifts)
                                        ;                               [B999]
        bcc     A_B8A3                  ;.go subtract mantissas


;******************************************************************************
;
; add (AY) to FAC1

AddFORvar2FAC1                          ;                               [B867]
        jsr     UnpackAY2FAC2           ; unpack memory (AY) into FAC2  [BA8C]


;******************************************************************************
;
; add FAC2 to FAC1

bcPLUS                                  ;                               [B86A]
        bne     A_B86F                  ; branch if FAC1 is not zero

        jmp     CopyFAC2toFAC1          ; FAC1 was zero so copy FAC2 to FAC1
                                        ; and return                    [BBFC]

; FAC1 is non zero
A_B86F                                  ;                               [B86F]
        ldx     FACOV                   ; get FAC1 rounding byte
        stx     Jump0054+2              ; save as FAC2 rounding byte

        ldx     #ARGEXP                 ; set index to FAC2 exponent address
        lda     ARGEXP                  ; get FAC2 exponent
bcPLUS2                                 ;                               [B877]
        tay                             ; copy exponent
        beq     A_B848                  ; exit if zero

        sec                             ; set carry for subtract
        sbc     FACEXP                  ; subtract FAC1 exponent
        beq     A_B8A3                  ; if equal go add mantissas

        bcc     A_B893                  ; if FAC2 < FAC1 then shift FAC2 right

; else FAC2 > FAC1
        sty     FACEXP                  ; save FAC1 exponent

        ldy     ARGSGN                  ; get FAC2 sign (b7)
        sty     FACSGN                  ; save FAC1 sign (b7)

        eor     #$FF                    ; complement A
        adc     #$00                    ; +1, twos complement, carry is set

        ldy     #$00                    ; clear Y
        sty     Jump0054+2              ; clear FAC2 rounding byte

        ldx     #FACEXP                 ; set index to FAC1 exponent address
        bne     A_B897                  ; branch always

; FAC2 < FAC1
A_B893                                  ;                               [B893]
        ldy     #$00                    ; clear Y
        sty     FACOV                   ; clear FAC1 rounding byte
A_B897                                  ;                               [B897]
        cmp     #$F9                    ; compare exponent diff with $F9
        bmi     A_B862                  ; branch if range $79-$F8

        tay                             ; copy exponent difference to Y

        lda     FACOV                   ; get FAC1 rounding byte

        lsr     D6510+1,X               ; shift FAC? mantissa 1

        jsr     shftFACxYright          ; shift FACX Y times right      [B9B0]

; exponents are equal now do mantissa subtract
A_B8A3                                  ;                               [B8A3]
        bit     ARISGN                  ; test sign compare (FAC1 EOR FAC2)
        bpl     A_B8FE                  ; if = add FAC2 mantissa to FAC1
                                        ; mantissa and return
        ldy     #FACEXP                 ; set the Y index to FAC1 exponent
                                        ; address
        cpx     #ARGEXP                 ; compare X to FAC2 exponent address
        beq     A_B8AF                  ; if = continue, Y = FAC1, X = FAC2

        ldy     #ARGEXP                 ; else set the Y index to FAC2 exponent
                                        ; address
; subtract the smaller from the bigger (take the sign of
; the bigger)
A_B8AF                                  ;                               [B8AF]
        sec                             ; set carry for subtract
        eor     #$FF                    ; ones complement A
        adc     Jump0054+2              ; add FAC2 rounding byte
        sta     FACOV                   ; save FAC1 rounding byte

        lda     D6510+4,Y               ; get FACY mantissa 4
        sbc     D6510+4,X               ; subtract FACX mantissa 4
        sta     FacMantissa+3           ; save FAC1 mantissa 4

        lda     D6510+3,Y               ; get FACY mantissa 3
        sbc     D6510+3,X               ; subtract FACX mantissa 3
        sta     FacMantissa+2           ; save FAC1 mantissa 3

        lda     D6510+2,Y               ; get FACY mantissa 2
        sbc     D6510+2,X               ; subtract FACX mantissa 2
        sta     FacMantissa+1           ; save FAC1 mantissa 2

        lda     D6510+1,Y               ; get FACY mantissa 1
        sbc     D6510+1,X               ; subtract FACX mantissa 1
        sta     FacMantissa             ; save FAC1 mantissa 1


;******************************************************************************
;
; do ABS and normalise FAC1

AbsNormalFAC1                           ;                               [B8D2]
        bcs     NormaliseFAC1           ; branch if number is positive

        jsr     NegateFAC1              ; negate FAC1                   [B947]


;******************************************************************************
;
; normalise FAC1

NormaliseFAC1                           ;                               [B8D7]
        ldy     #$00                    ; clear Y
        tya                             ; clear A
        clc                             ; clear carry for add
A_B8DB                                  ;                               [B8DB]
        ldx     FacMantissa             ; get FAC1 mantissa 1
        bne     A_B929                  ; if not zero normalise FAC1

        ldx     FacMantissa+1           ; get FAC1 mantissa 2
        stx     FacMantissa             ; save FAC1 mantissa 1

        ldx     FacMantissa+2           ; get FAC1 mantissa 3
        stx     FacMantissa+1           ; save FAC1 mantissa 2

        ldx     FacMantissa+3           ; get FAC1 mantissa 4
        stx     FacMantissa+2           ; save FAC1 mantissa 3

        ldx     FACOV                   ; get FAC1 rounding byte
        stx     FacMantissa+3           ; save FAC1 mantissa 4

        sty     FACOV                   ; clear FAC1 rounding byte

        adc     #$08                    ; add x to exponent offset
        cmp     #$20                    ; compare with $20, max offset, all bits
                                        ; would be = 0
        bne     A_B8DB                  ; loop if not max


;******************************************************************************
;
; clear FAC1 exponent and sign

ClrFAC1ExpSgn                           ;                               [B8F7]
        lda     #$00                    ; clear A
ClrFAC1Exp                              ;                               [B8F9]
        sta     FACEXP                  ; set FAC1 exponent


;******************************************************************************
;
; save FAC1 sign

SaveFAC1Sign                            ;                               [B8FB]
        sta     FACSGN                  ; save FAC1 sign (b7)
        rts


;******************************************************************************
;
; add FAC2 mantissa to FAC1 mantissa

A_B8FE                                  ;                               [B8FE]
        adc     Jump0054+2              ; add FAC2 rounding byte
        sta     FACOV                   ; save FAC1 rounding byte

        lda     FacMantissa+3           ; get FAC1 mantissa 4
        adc     ArgMantissa+3           ; add FAC2 mantissa 4
        sta     FacMantissa+3           ; save FAC1 mantissa 4

        lda     FacMantissa+2           ; get FAC1 mantissa 3
        adc     ArgMantissa+2           ; add FAC2 mantissa 3
        sta     FacMantissa+2           ; save FAC1 mantissa 3

        lda     FacMantissa+1           ; get FAC1 mantissa 2
        adc     ArgMantissa+1           ; add FAC2 mantissa 2
        sta     FacMantissa+1           ; save FAC1 mantissa 2

        lda     FacMantissa             ; get FAC1 mantissa 1
        adc     ArgMantissa             ; add FAC2 mantissa 1
        sta     FacMantissa             ; save FAC1 mantissa 1

        jmp     NormaliseFAC12          ; test and normalise FAC1 for C=0/1
                                        ;                               [B936]

A_B91D                                  ;                               [B91D]
        adc     #$01                    ; add 1 to exponent offset
        asl     FACOV                   ; shift FAC1 rounding byte
        rol     FacMantissa+3           ; shift FAC1 mantissa 4
        rol     FacMantissa+2           ; shift FAC1 mantissa 3
        rol     FacMantissa+1           ; shift FAC1 mantissa 2
        rol     FacMantissa             ; shift FAC1 mantissa 1

; normalise FAC1

A_B929                                  ;                               [B929]
        bpl     A_B91D                  ; loop if not normalised

        sec                             ; set carry for subtract
        sbc     FACEXP                  ; subtract FAC1 exponent
        bcs     ClrFAC1ExpSgn           ; branch if underflow (set result = $0)

        eor     #$FF                    ; complement exponent
        adc     #$01                    ; +1 (twos complement)
        sta     FACEXP                  ; save FAC1 exponent

; test and normalise FAC1 for C=0/1

NormaliseFAC12                          ;                               [B936]
        bcc     A_B946                  ; exit if no overflow

; normalise FAC1 for C=1

NormaliseFAC13                          ;                               [B938]
        inc     FACEXP                  ; increment FAC1 exponent
        beq     OverflowError           ; if zero do overflow error then warm
                                        ; start
        ror     FacMantissa             ; shift FAC1 mantissa 1
        ror     FacMantissa+1           ; shift FAC1 mantissa 2
        ror     FacMantissa+2           ; shift FAC1 mantissa 3
        ror     FacMantissa+3           ; shift FAC1 mantissa 4
        ror     FACOV                   ; shift FAC1 rounding byte
A_B946                                  ;                               [B946]
        rts


;******************************************************************************
;
; negate FAC1

NegateFAC1                              ;                               [B947]
        lda     FACSGN                  ; get FAC1 sign (b7)
        eor     #$FF                    ; complement it
        sta     FACSGN                  ; save FAC1 sign (b7)

; twos complement FAC1 mantissa

TwoComplFAC1                            ;                               [B94D]
        lda     FacMantissa             ; get FAC1 mantissa 1
        eor     #$FF                    ; complement it
        sta     FacMantissa             ; save FAC1 mantissa 1

        lda     FacMantissa+1           ; get FAC1 mantissa 2
        eor     #$FF                    ; complement it
        sta     FacMantissa+1           ; save FAC1 mantissa 2

        lda     FacMantissa+2           ; get FAC1 mantissa 3
        eor     #$FF                    ; complement it
        sta     FacMantissa+2           ; save FAC1 mantissa 3

        lda     FacMantissa+3           ; get FAC1 mantissa 4
        eor     #$FF                    ; complement it
        sta     FacMantissa+3           ; save FAC1 mantissa 4

        lda     FACOV                   ; get FAC1 rounding byte
        eor     #$FF                    ; complement it
        sta     FACOV                   ; save FAC1 rounding byte

        inc     FACOV                   ; increment FAC1 rounding byte
        bne     A_B97D                  ; exit if no overflow

; increment FAC1 mantissa

IncFAC1Mant                             ;                               [B96F]
        inc     FacMantissa+3           ; increment FAC1 mantissa 4
        bne     A_B97D                  ; finished if no rollover

        inc     FacMantissa+2           ; increment FAC1 mantissa 3
        bne     A_B97D                  ; finished if no rollover

        inc     FacMantissa+1           ; increment FAC1 mantissa 2
        bne     A_B97D                  ; finished if no rollover

        inc     FacMantissa             ; increment FAC1 mantissa 1
A_B97D                                  ;                               [B97D]
        rts


;******************************************************************************
;
; do overflow error then warm start

OverflowError                           ;                               [B97E]
        ldx     #$0F                    ; error $0F, overflow error
        jmp     OutputErrMsg            ; do error #X then warm start   [A437]


;******************************************************************************
;
; shift register to the right

ShiftRegRight                           ;                               [B983]
        ldx     #RESHO-1                ; set the offset to FACtemp
A_B985                                  ;                               [B985]
        ldy     RESHO-$22,X             ; get FACX mantissa 4
        sty     FACOV                   ; save as FAC1 rounding byte

        ldy     RESHO-$23,X             ; get FACX mantissa 3
        sty     RESHO-$22,X             ; save FACX mantissa 4

        ldy     RESHO-$24,X             ; get FACX mantissa 2
        sty     RESHO-$23,X             ; save FACX mantissa 3

        ldy     RESHO-$25,X             ; get FACX mantissa 1
        sty     RESHO-$24,X             ; save FACX mantissa 2

        ldy     BITS                    ; get FAC1 overfLB
        sty     RESHO-$25,X             ; save FACX mantissa 1

; shift FACX -A times right (> 8 shifts)

shftFACxAright                          ;                               [B999]
        adc     #$08                    ; add 8 to shift count
        bmi     A_B985                  ; go do 8 shift if still -ve

        beq     A_B985                  ; go do 8 shift if zero

        sbc     #$08                    ; else subtract 8 again
        tay                             ; save count to Y

        lda     FACOV                   ; get FAC1 rounding byte
        bcs     A_B9BA                  ;.

A_B9A6                                  ;                               [B9A6]
        asl     D6510+1,X               ; shift FACX mantissa 1
        bcc     A_B9AC                  ; branch if +ve

        inc     D6510+1,X               ; this sets b7 eventually
A_B9AC                                  ;                               [B9AC]
        ror     D6510+1,X               ; shift FACX mantissa 1, correct for ASL
        ror     D6510+1,X               ; shift FACX mantissa 1, put carry in b7

; shift FACX Y times right

shftFACxYright                          ;                               [B9B0]
        ror     D6510+2,X               ; shift FACX mantissa 2
        ror     D6510+3,X               ; shift FACX mantissa 3
        ror     D6510+4,X               ; shift FACX mantissa 4
        ror                             ; shift FACX rounding byte

        iny                             ; increment exponent diff
        bne     A_B9A6                  ; branch if range adjust not complete

A_B9BA                                  ;                               [B9BA]
        clc                             ; just clear it
        rts


;******************************************************************************
;
; constants and series for LOG(n)

Constant1                               ;                               [B9BC]
.byte   $81,$00,$00,$00,$00             ; 1

ConstLogCoef                            ;                               [B9C1]
.byte   $03                             ; series counter
.byte   $7F,$5E,$56,$CB,$79
.byte   $80,$13,$9B,$0B,$64
.byte   $80,$76,$38,$93,$16
.byte   $82,$38,$AA,$3B,$20

Const1divSQR2                           ;                               [B9D6]
.byte   $80,$35,$04,$F3,$34             ; 0.70711       1/root 2
ConstSQR2                               ;                               [B9DB]
.byte   $81,$35,$04,$F3,$34             ; 1.41421       root 2
Const05                                 ;                               [B9E0]
.byte   $80,$80,$00,$00,$00             ; -0.5  1/2
ConstLOG2                               ;                               [B9E5]
.byte   $80,$31,$72,$17,$F8             ; 0.69315       LOG(2)


;******************************************************************************
;
; perform LOG()

bcLOG                                   ;                               [B9EA]
        jsr     GetFacSign              ; test sign and zero            [BC2B]
        beq     A_B9F1                  ; if zero do illegal quantity error then
                                        ; warm start
        bpl     A_B9F4                  ; skip error if +ve

A_B9F1                                  ;                               [B9F1]
        jmp     IllegalQuant            ; do illegal quantity error then warm
                                        ; start                         [B248]
A_B9F4                                  ;                               [B9F4]
        lda     FACEXP                  ; get FAC1 exponent
        sbc     #$7F                    ; normalise it
        pha                             ; save it

        lda     #$80                    ; set exponent to zero
        sta     FACEXP                  ; save FAC1 exponent

        lda     #<Const1divSQR2         ; pointer to 1/root 2 LB
        ldy     #>Const1divSQR2         ; pointer to 1/root 2 HB
        jsr     AddFORvar2FAC1          ; add (AY) to FAC1 (1/root2)    [B867]

        lda     #<ConstSQR2             ; pointer to root 2 LB
        ldy     #>ConstSQR2             ; pointer to root 2 HB
        jsr     AYdivFAC1               ; convert AY and do (AY)/FAC1
                                        ; (root2/(x+(1/root2)))         [BB0F]

        lda     #<Constant1             ; pointer to 1 LB
        ldy     #>Constant1             ; pointer to 1 HB
        jsr     AYminusFAC1             ; subtr FAC1 ((root2/(x+(1/root2)))-1)
                                        ; from (AY)                     [B850]
        lda     #<ConstLogCoef          ; pointer to series for LOG(n) LB
        ldy     #>ConstLogCoef          ; pointer to series for LOG(n) HB
        jsr     Power2                  ; ^2 then series evaluation     [E043]

        lda     #<Const05               ; pointer to -0.5 LB
        ldy     #>Const05               ; pointer to -0.5 HB
        jsr     AddFORvar2FAC1          ; add (AY) to FAC1              [B867]

        pla                             ; restore FAC1 exponent
        jsr     EvalNewDigit            ; evaluate new ASCII digit      [BD7E]

        lda     #<ConstLOG2             ; pointer to LOG(2) LB
        ldy     #>ConstLOG2             ; pointer to LOG(2) HB


;******************************************************************************
;
; do convert AY, FCA1*(AY)

FAC1xAY                                 ;                               [BA28]
        jsr     UnpackAY2FAC2           ; unpack memory (AY) into FAC2  [BA8C]
bcMULTIPLY                              ;                               [BA2B]
        bne     A_BA30                  ; multiply FAC1 by FAC2 ??

        jmp     JmpRTS                  ; exit if zero                  [BA8B]

A_BA30                                  ;                               [BA30]
        jsr     TestAdjFACs             ; test and adjust accumulators  [BAB7]

        lda     #$00                    ; clear A
        sta     RESHO                   ; clear temp mantissa 1
        sta     RESHO+1                 ; clear temp mantissa 2
        sta     RESHO+2                 ; clear temp mantissa 3
        sta     RESHO+3                 ; clear temp mantissa 4

        lda     FACOV                   ; get FAC1 rounding byte
        jsr     ShftAddFAC2             ; go do shift/add FAC2          [BA59]

        lda     FacMantissa+3           ; get FAC1 mantissa 4
        jsr     ShftAddFAC2             ; go do shift/add FAC2          [BA59]

        lda     FacMantissa+2           ; get FAC1 mantissa 3
        jsr     ShftAddFAC2             ; go do shift/add FAC2          [BA59]

        lda     FacMantissa+1           ; get FAC1 mantissa 2
        jsr     ShftAddFAC2             ; go do shift/add FAC2          [BA59]

        lda     FacMantissa             ; get FAC1 mantissa 1
        jsr     ShftAddFAC22            ; go do shift/add FAC2          [BA5E]

        jmp     TempToFAC1              ; copy temp to FAC1, normalise and
                                        ; return                        [BB8F]
ShftAddFAC2                             ;                               [BA59]
        bne     ShftAddFAC22            ; branch if byte <> zero

        jmp     ShiftRegRight           ; shift FCAtemp << A+8 times    [B983]

; else do shift and add
ShftAddFAC22                            ;                               [BA5E]
        lsr                             ; shift byte
        ora     #$80                    ; set top bit (mark for 8 times)
A_BA61                                  ;                               [BA61]
        tay                             ; copy result
        bcc     A_BA7D                  ; skip next if bit was zero

        clc                             ; clear carry for add
        lda     RESHO+3                 ; get temp mantissa 4
        adc     ArgMantissa+3           ; add FAC2 mantissa 4
        sta     RESHO+3                 ; save temp mantissa 4

        lda     RESHO+2                 ; get temp mantissa 3
        adc     ArgMantissa+2           ; add FAC2 mantissa 3
        sta     RESHO+2                 ; save temp mantissa 3

        lda     RESHO+1                 ; get temp mantissa 2
        adc     ArgMantissa+1           ; add FAC2 mantissa 2
        sta     RESHO+1                 ; save temp mantissa 2

        lda     RESHO                   ; get temp mantissa 1
        adc     ArgMantissa             ; add FAC2 mantissa 1
        sta     RESHO                   ; save temp mantissa 1
A_BA7D                                  ;                               [BA7D]
        ror     RESHO                   ; shift temp mantissa 1
        ror     RESHO+1                 ; shift temp mantissa 2
        ror     RESHO+2                 ; shift temp mantissa 3
        ror     RESHO+3                 ; shift temp mantissa 4
        ror     FACOV                   ; shift temp rounding byte

        tya                             ; get byte back
        lsr                             ; shift byte
        bne     A_BA61                  ; loop if all bits not done

JmpRTS                                  ;                               [BA8B]
        rts


;******************************************************************************
;
; unpack memory (AY) into FAC2

UnpackAY2FAC2                           ;                               [BA8C]
        sta     INDEX                   ; save pointer LB
        sty     INDEX+1                 ; save pointer HB

        ldy     #$04                    ; 5 bytes to get (0-4)
        lda     (INDEX),Y               ; get mantissa 4
        sta     ArgMantissa+3           ; save FAC2 mantissa 4

        dey                             ; decrement index
        lda     (INDEX),Y               ; get mantissa 3
        sta     ArgMantissa+2           ; save FAC2 mantissa 3

        dey                             ; decrement index
        lda     (INDEX),Y               ; get mantissa 2
        sta     ArgMantissa+1           ; save FAC2 mantissa 2

        dey                             ; decrement index
        lda     (INDEX),Y               ; get mantissa 1 + sign
        sta     ARGSGN                  ; save FAC2 sign (b7)

        eor     FACSGN                  ; EOR with FAC1 sign (b7)
        sta     ARISGN                  ; save sign compare (FAC1 EOR FAC2)

        lda     ARGSGN                  ; recover FAC2 sign (b7)
        ora     #$80                    ; set 1xxx xxx (set normal bit)
        sta     ArgMantissa             ; save FAC2 mantissa 1

        dey                             ; decrement index
        lda     (INDEX),Y               ; get exponent byte
        sta     ARGEXP                  ; save FAC2 exponent

        lda     FACEXP                  ; get FAC1 exponent
        rts


;******************************************************************************
;
; test and adjust accumulators

TestAdjFACs                             ;                               [BAB7]
        lda     ARGEXP                  ; get FAC2 exponent

TestAdjFACs2                            ;                               [BAB9]
        beq     A_BADA                  ; branch if FAC2 = $00, handle underflow

        clc                             ; clear carry for add
        adc     FACEXP                  ; add FAC1 exponent
        bcc     A_BAC4                  ; branch if sum of exponents < $0100

        bmi     A_BADF                  ; do overflow error

        clc                             ; clear carry for the add
.byte   $2C                             ; makes next line BIT $1410
A_BAC4                                  ;                               [BAC4]
        bpl     A_BADA                  ; if +ve go handle underflow

        adc     #$80                    ; adjust exponent
        sta     FACEXP                  ; save FAC1 exponent
        bne     A_BACF                  ; branch if not zero

        jmp     SaveFAC1Sign            ; save FAC1 sign and return     [B8FB]


A_BACF                                  ;                               [BACF]
        lda     ARISGN                  ; get sign compare (FAC1 EOR FAC2)
        sta     FACSGN                  ; save FAC1 sign (b7)

        rts

; handle overflow and underflow

HndlOvUnFlErr                           ;                               [BAD4]
        lda     FACSGN                  ; get FAC1 sign (b7)
        eor     #$FF                    ; complement it
        bmi     A_BADF                  ; do overflow error

; handle underflow
A_BADA                                  ;                               [BADA]
        pla                             ; pop return address LB
        pla                             ; pop return address HB
        jmp     ClrFAC1ExpSgn           ; clear FAC1 exponent and sign and
                                        ; return                        [B8F7]

A_BADF                                  ;                               [BADF]
        jmp     OverflowError           ; do overflow error then warm start
                                        ;                               [B97E]

;******************************************************************************
;
; multiply FAC1 by 10

Fac1x10                                 ;                               [BAE2]
        jsr     CopyFAC1toFAC2          ; round and copy FAC1 to FAC2   [BC0C]
        tax                             ; copy exponent (set the flags)
        beq     A_BAF8                  ; exit if zero

        clc                             ; clear carry for add
        adc     #$02                    ; add two to exponent (*4)
        bcs     A_BADF                  ; do overflow error if > $FF

; FAC1 = (FAC1 + FAC2) * 2

FAC1plFAC2x2                            ;                               [BAED]
        ldx     #$00                    ; clear byte
        stx     ARISGN                  ; clear sign compare (FAC1 EOR FAC2)
        jsr     bcPLUS2                 ; add FAC2 to FAC1 (*5)         [B877]
        inc     FACEXP                  ; increment FAC1 exponent (*10)
        beq     A_BADF                  ; if exponent now zero go do overflow
                                        ; error
A_BAF8                                  ;                               [BAF8]
        rts


;******************************************************************************
;
; 10 as a floating value

Constant10                              ;                               [BAF9]
.byte   $84,$20,$00,$00,$00             ; 10


;******************************************************************************
;
; divide FAC1 by 10

FAC1div10                               ;                               [BAFE]
        jsr     CopyFAC1toFAC2          ; round and copy FAC1 to FAC2   [BC0C]

        lda     #<Constant10            ; set 10 pointer LB
        ldy     #>Constant10            ; set 10 pointer HB
        ldx     #$00                    ; clear sign


;******************************************************************************
;
; divide by (AY) (X=sign)

FAC1divAY                               ;                               [BB07]
        stx     ARISGN                  ; save sign compare (FAC1 EOR FAC2)
        jsr     UnpackAY2FAC1           ; unpack memory (AY) into FAC1  [BBA2]
        jmp     bcDIVIDE                ; do FAC2/FAC1                  [BB12]


;******************************************************************************
;
; convert AY and do (AY)/FAC1

AYdivFAC1                               ;                               [BB0F]
        jsr     UnpackAY2FAC2           ; unpack memory (AY) into FAC2  [BA8C]
bcDIVIDE 
        beq     A_BB8A                  ; if zero go do /0 error

        jsr     RoundFAC1               ; round FAC1                    [BC1B]

        lda     #$00                    ; clear A
        sec                             ; set carry for subtract
        sbc     FACEXP                  ; subtract FAC1 exponent (2s complement)
        sta     FACEXP                  ; save FAC1 exponent

        jsr     TestAdjFACs             ; test and adjust accumulators  [BAB7]

        inc     FACEXP                  ; increment FAC1 exponent
        beq     A_BADF                  ; if zero do overflow error

        ldx     #$FC                    ; set index to FAC temp
        lda     #$01                    ;.set byte
A_BB29                                  ;                               [BB29]
        ldy     ArgMantissa             ; get FAC2 mantissa 1
        cpy     FacMantissa             ; compare FAC1 mantissa 1
        bne     A_BB3F                  ; branch if <>

        ldy     ArgMantissa+1           ; get FAC2 mantissa 2
        cpy     FacMantissa+1           ; compare FAC1 mantissa 2
        bne     A_BB3F                  ; branch if <>

        ldy     ArgMantissa+2           ; get FAC2 mantissa 3
        cpy     FacMantissa+2           ; compare FAC1 mantissa 3
        bne     A_BB3F                  ; branch if <>

        ldy     ArgMantissa+3           ; get FAC2 mantissa 4
        cpy     FacMantissa+3           ; compare FAC1 mantissa 4
A_BB3F                                  ;                               [BB3F]
        php                             ; save FAC2-FAC1 compare status

        rol                             ;.shift byte
        bcc     A_BB4C                  ; skip next if no carry

        inx                             ; increment index to FAC temp
        sta     RESHO+3,X               ;.
        beq     A_BB7A                  ;.

        bpl     A_BB7E                  ;.

        lda     #$01                    ;.
A_BB4C                                  ;                               [BB4C]
        plp                             ; restore FAC2-FAC1 compare status
        bcs     A_BB5D                  ; if FAC2 >= FAC1 then do subtract

; FAC2 = FAC2*2
FAC2x2                                  ;                               [BB4F]
        asl     ArgMantissa+3           ; shift FAC2 mantissa 4
        rol     ArgMantissa+2           ; shift FAC2 mantissa 3
        rol     ArgMantissa+1           ; shift FAC2 mantissa 2
        rol     ArgMantissa             ; shift FAC2 mantissa 1
        bcs     A_BB3F                  ; loop with no compare

        bmi     A_BB29                  ; loop with compare

        bpl     A_BB3F                  ; Always -> loop with no compare


A_BB5D                                  ;                               [BB5D]
        tay                             ; save FAC2-FAC1 compare status

        lda     ArgMantissa+3           ; get FAC2 mantissa 4
        sbc     FacMantissa+3           ; subtract FAC1 mantissa 4
        sta     ArgMantissa+3           ; save FAC2 mantissa 4

        lda     ArgMantissa+2           ; get FAC2 mantissa 3
        sbc     FacMantissa+2           ; subtract FAC1 mantissa 3
        sta     ArgMantissa+2           ; save FAC2 mantissa 3

        lda     ArgMantissa+1           ; get FAC2 mantissa 2
        sbc     FacMantissa+1           ; subtract FAC1 mantissa 2
        sta     ArgMantissa+1           ; save FAC2 mantissa 2

        lda     ArgMantissa             ; get FAC2 mantissa 1
        sbc     FacMantissa             ; subtract FAC1 mantissa 1
        sta     ArgMantissa             ; save FAC2 mantissa 1

        tya                             ; restore FAC2-FAC1 compare status
        jmp     FAC2x2                  ;.                              [BB4F]


A_BB7A                                  ;                               [BB7A]
        lda     #$40                    ;.
        bne     A_BB4C                  ; branch always


; do A<<6, save as FAC1 rounding byte, normalise and return

A_BB7E                                  ;                               [BB7E]
        asl                             ;.
        asl                             ;.
        asl                             ;.
        asl                             ;.
        asl                             ;.
        asl                             ;.
        sta     FACOV                   ; save FAC1 rounding byte
        plp                             ; dump FAC2-FAC1 compare status
        jmp     TempToFAC1              ; copy temp to FAC1, normalise and
                                        ; return                        [BB8F]
; do "Divide by zero" error

A_BB8A                                  ;                               [BB8A]
        ldx     #$14                    ; error $14, divide by zero error
        jmp     OutputErrMsg            ; do error #X then warm start   [A437]

TempToFAC1                              ;                               [BB8F]
        lda     RESHO                   ; get temp mantissa 1
        sta     FacMantissa             ; save FAC1 mantissa 1

        lda     RESHO+1                 ; get temp mantissa 2
        sta     FacMantissa+1           ; save FAC1 mantissa 2

        lda     RESHO+2                 ; get temp mantissa 3
        sta     FacMantissa+2           ; save FAC1 mantissa 3

        lda     RESHO+3                 ; get temp mantissa 4
        sta     FacMantissa+3           ; save FAC1 mantissa 4

        jmp     NormaliseFAC1           ; normalise FAC1 and return     [B8D7]


;******************************************************************************
;
; unpack memory (AY) into FAC1

UnpackAY2FAC1                           ;                               [BBA2]
        sta     INDEX                   ; save pointer LB
        sty     INDEX+1                 ; save pointer HB

        ldy     #$04                    ; 5 bytes to do
        lda     (INDEX),Y               ; get fifth byte
        sta     FacMantissa+3           ; save FAC1 mantissa 4

        dey                             ; decrement index
        lda     (INDEX),Y               ; get fourth byte
        sta     FacMantissa+2           ; save FAC1 mantissa 3

        dey                             ; decrement index
        lda     (INDEX),Y               ; get third byte
        sta     FacMantissa+1           ; save FAC1 mantissa 2

        dey                             ; decrement index
        lda     (INDEX),Y               ; get second byte
        sta     FACSGN                  ; save FAC1 sign (b7)

        ora     #$80                    ; set 1xxx, (add normal bit)
        sta     FacMantissa             ; save FAC1 mantissa 1

        dey                             ; decrement index
        lda     (INDEX),Y               ; get first byte (exponent)
        sta     FACEXP                  ; save FAC1 exponent
        sty     FACOV                   ; clear FAC1 rounding byte

        rts


;******************************************************************************
;
; pack FAC1 into FacTempStor+5

FAC1toTemp5                             ;                               [BBC7]
        ldx     #<FacTempStor+5         ; set pointer LB
.byte   $2C                             ; makes next line BIT FacTempStorA2


;******************************************************************************
;
; pack FAC1 into FacTempStor

FAC1toTemp                              ;                               [BBCA]
        ldx     #<FacTempStor           ; set pointer LB
        ldy     #>FacTempStor           ; set pointer HB
        beq     PackFAC1intoXY          ; pack FAC1 into (XY) and return,
                                        ; branch always

;******************************************************************************
;
; pack FAC1 into variable pointer

Fac1ToVarPtr                            ;                               [BBD0]
        ldx     FORPNT                  ; get destination pointer LB
        ldy     FORPNT+1                ; get destination pointer HB


;******************************************************************************
;
; pack FAC1 into (XY)

PackFAC1intoXY                          ;                               [BBD4]
        jsr     RoundFAC1               ; round FAC1                    [BC1B]
        stx     INDEX                   ; save pointer LB
        sty     INDEX+1                 ; save pointer HB

        ldy     #$04                    ; set index
        lda     FacMantissa+3           ; get FAC1 mantissa 4
        sta     (INDEX),Y               ; store in destination

        dey                             ; decrement index
        lda     FacMantissa+2           ; get FAC1 mantissa 3
        sta     (INDEX),Y               ; store in destination

        dey                             ; decrement index
        lda     FacMantissa+1           ; get FAC1 mantissa 2
        sta     (INDEX),Y               ; store in destination

        dey                             ; decrement index
        lda     FACSGN                  ; get FAC1 sign (b7)
        ora     #$7F                    ; set bits x111 1111
        and     FacMantissa             ; AND in FAC1 mantissa 1
        sta     (INDEX),Y               ; store in destination

        dey                             ; decrement index
        lda     FACEXP                  ; get FAC1 exponent
        sta     (INDEX),Y               ; store in destination
        sty     FACOV                   ; clear FAC1 rounding byte

        rts


;******************************************************************************
;
; copy FAC2 to FAC1

CopyFAC2toFAC1                          ;                               [BBFC]
        lda     ARGSGN                  ; get FAC2 sign (b7)

; save FAC1 sign and copy ABS(FAC2) to FAC1

CpFAC2toFAC12                           ;                               [BBFE]
        sta     FACSGN                  ; save FAC1 sign (b7)
        ldx     #$05                    ; 5 bytes to copy
A_BC02                                  ;                               [BC02]
        lda     BITS,X                  ; get byte from FAC2,X
        sta     FacTempStor+9,X         ; save byte at FAC1,X

        dex                             ; decrement count
        bne     A_BC02                  ; loop if not all done

        stx     FACOV                   ; clear FAC1 rounding byte
        rts


;******************************************************************************
;
; round and copy FAC1 to FAC2

CopyFAC1toFAC2                          ;                               [BC0C]
        jsr     RoundFAC1               ; round FAC1                    [BC1B]

; copy FAC1 to FAC2

CpFAC1toFAC22                           ;                               [BC0F]
        ldx     #$06                    ; 6 bytes to copy
A_BC11                                  ;                               [BC11]
        lda     FacTempStor+9,X         ; get byte from FAC1,X
        sta     BITS,X                  ; save byte at FAC2,X
        dex                             ; decrement count
        bne     A_BC11                  ; loop if not all done

        stx     FACOV                   ; clear FAC1 rounding byte
A_BC1A                                  ;                               [BC1A]
        rts


;******************************************************************************
;
; round FAC1

RoundFAC1                               ;                               [BC1B]
        lda     FACEXP                  ; get FAC1 exponent
        beq     A_BC1A                  ; exit if zero

        asl     FACOV                   ; shift FAC1 rounding byte
        bcc     A_BC1A                  ; exit if no overflow

; round FAC1 (no check)

RoundFAC12                              ;                               [BC23]
        jsr     IncFAC1Mant             ; increment FAC1 mantissa       [B96F]
        bne     A_BC1A                  ; branch if no overflow

        jmp     NormaliseFAC13          ; nornalise FAC1 for C=1 and return
                                        ;                               [B938]

;******************************************************************************
;
; get FAC1 sign
; return A = $FF, Cb = 1/-ve A = $01, Cb = 0/+ve, A = $00, Cb = ?/0

GetFacSign                              ;                               [BC2B]
        lda     FACEXP                  ; get FAC1 exponent
        beq     A_BC38                  ; exit if zero (allready correct
                                        ; SGN(0)=0)

;******************************************************************************
;
; return A = $FF, Cb = 1/-ve A = $01, Cb = 0/+ve
; no = 0 check

A_BC2F                                  ;                               [BC2F]
        lda     FACSGN                  ; else get FAC1 sign (b7)


;******************************************************************************
;
; return A = $FF, Cb = 1/-ve A = $01, Cb = 0/+ve
; no = 0 check, sign in A

J_BC31                                  ;                               [BC31]
        rol                             ; move sign bit to carry
        lda     #$FF                    ; set byte for -ve result
        bcs     A_BC38                  ; return if sign was set (-ve)

        lda     #$01                    ; else set byte for +ve result
A_BC38                                  ;                               [BC38]
        rts


;******************************************************************************
;
; perform SGN()

bcSGN                                   ;                               [BC39]
        jsr     GetFacSign              ; get FAC1 sign, return A = $FF -ve,
                                        ; A = $01 +ve                   [BC2B]

;******************************************************************************
;
; save A as integer byte

AtoInteger                              ;                               [BC3C]
        sta     FacMantissa             ; save FAC1 mantissa 1

        lda     #$00                    ; clear A
        sta     FacMantissa+1           ; clear FAC1 mantissa 2

        ldx     #$88                    ; set exponent

; set exponent = X, clear FAC1 3 and 4 and normalise

J_BC44                                  ;                               [BC44]
        lda     FacMantissa             ; get FAC1 mantissa 1
        eor     #$FF                    ; complement it
        rol                             ; sign bit into carry

; set exponent = X, clear mantissa 4 and 3 and normalise FAC1

SetExpontIsX                            ;                               [BC49]
        lda     #$00                    ; clear A
        sta     FacMantissa+3           ; clear FAC1 mantissa 4
        sta     FacMantissa+2           ; clear FAC1 mantissa 3

; set exponent = X and normalise FAC1

J_BC4F                                  ;                               [BC4F]
        stx     FACEXP                  ; set FAC1 exponent
        sta     FACOV                   ; clear FAC1 rounding byte
        sta     FACSGN                  ; clear FAC1 sign (b7)

        jmp     AbsNormalFAC1           ; do ABS and normalise FAC1     [B8D2]


;******************************************************************************
;
; perform ABS()

bcABS                                   ;                               [BC58]
        lsr     FACSGN                  ; clear FAC1 sign, put zero in b7
        rts


;******************************************************************************
;
; compare FAC1 with (AY)
; returns A=$00 if FAC1 = (AY)
; returns A=$01 if FAC1 > (AY)
; returns A=$FF if FAC1 < (AY)

CmpFAC1withAY                           ;                               [BC5B]
        sta     INDEX+2                 ; save pointer LB
CmpFAC1withAY2                          ;                               [BC5D]
        sty     INDEX+3                 ; save pointer HB

        ldy     #$00                    ; clear index
        lda     (INDEX+2),Y             ; get exponent
        iny                             ; increment index
        tax                             ; copy (AY) exponent to X
        beq     GetFacSign              ; branch if (AY) exponent=0 and get FAC1
                                        ; sign A = $FF, Cb = 1/-ve, A = $01,
                                        ; Cb = 0/+ve
        lda     (INDEX+2),Y             ; get (AY) mantissa 1, with sign
        eor     FACSGN                  ; EOR FAC1 sign (b7)
        bmi     A_BC2F                  ; if signs <> do return A = $FF,
                                        ; Cb = 1/-ve, A = $01, Cb = 0/+ve and
                                        ; return
        cpx     FACEXP                  ; compare (AY) exponent with FAC1
                                        ; exponent
        bne     A_BC92                  ; branch if different

        lda     (INDEX+2),Y             ; get (AY) mantissa 1, with sign
        ora     #$80                    ; normalise top bit
        cmp     FacMantissa             ; compare with FAC1 mantissa 1
        bne     A_BC92                  ; branch if different

        iny                             ; increment index
        lda     (INDEX+2),Y             ; get mantissa 2
        cmp     FacMantissa+1           ; compare with FAC1 mantissa 2
        bne     A_BC92                  ; branch if different

        iny                             ; increment index
        lda     (INDEX+2),Y             ; get mantissa 3
        cmp     FacMantissa+2           ; compare with FAC1 mantissa 3
        bne     A_BC92                  ; branch if different

        iny                             ; increment index
        lda     #$7F                    ; set for 1/2 value rounding byte
        cmp     FACOV                   ; compare with FAC1 rounding byte
                                        ; (set carry)
        lda     (INDEX+2),Y             ; get mantissa 4
        sbc     FacMantissa+3           ; subtract FAC1 mantissa 4
        beq     A_BCBA                  ; exit if mantissa 4 equal

; gets here if number <> FAC1

A_BC92                                  ;                               [BC92]
        lda     FACSGN                  ; get FAC1 sign (b7)
        bcc     A_BC98                  ; branch if FAC1 > (AY)

        eor     #$FF                    ; else toggle FAC1 sign
A_BC98                                  ;                               [BC98]
        jmp     J_BC31                  ; return A = $FF, Cb = 1/-ve A = $01,
                                        ; Cb = 0/+ve                    [BC31]

;******************************************************************************
;
; convert FAC1 floating to fixed

FAC1Float2Fix                           ;                               [BC9B]
        lda     FACEXP                  ; get FAC1 exponent
        beq     A_BCE9                  ; if zero go clear FAC1 and return

        sec                             ; set carry for subtract
        sbc     #$A0                    ; subtract maximum integer range
                                        ; exponent
        bit     FACSGN                  ; test FAC1 sign (b7)
        bpl     A_BCAF                  ; branch if FAC1 +ve

; FAC1 was -ve
        tax                             ; copy subtracted exponent
        lda     #$FF                    ; overflow for -ve number
        sta     BITS                    ; set FAC1 overfLB

        jsr     TwoComplFAC1            ; twos complement FAC1 mantissa [B94D]
        txa                             ; restore subtracted exponent
A_BCAF                                  ;                               [BCAF]
        ldx     #$61                    ; set index to FAC1
        cmp     #$F9                    ; compare exponent result
        bpl     A_BCBB                  ; if < 8 shifts shift FAC1 A times right
                                        ; and return
        jsr     shftFACxAright          ; shift FAC1 A times right (> 8 shifts)
                                        ;                               [B999]
        sty     BITS                    ; clear FAC1 overfLB
A_BCBA                                  ;                               [BCBA]
        rts


;******************************************************************************
;
; shift FAC1 A times right

A_BCBB                                  ;                               [BCBB]
        tay                             ; copy shift count

        lda     FACSGN                  ; get FAC1 sign (b7)
        and     #$80                    ; mask sign bit only (x000 0000)
        lsr     FacMantissa             ; shift FAC1 mantissa 1
        ora     FacMantissa             ; OR sign in b7 FAC1 mantissa 1
        sta     FacMantissa             ; save FAC1 mantissa 1

        jsr     shftFACxYright          ; shift FAC1 Y times right      [B9B0]
        sty     BITS                    ; clear FAC1 overfLB

        rts


;******************************************************************************
;
; perform INT()

bcINT                                   ;                               [BCCC]
        lda     FACEXP                  ; get FAC1 exponent
        cmp     #$A0                    ; compare with max int
        bcs     A_BCF2                  ; exit if >= (allready int, too big for
                                        ; fractional part!)
        jsr     FAC1Float2Fix           ; convert FAC1 floating to fixed [BC9B]
        sty     FACOV                   ; save FAC1 rounding byte

        lda     FACSGN                  ; get FAC1 sign (b7)
        sty     FACSGN                  ; save FAC1 sign (b7)
        eor     #$80                    ; toggle FAC1 sign
        rol                             ; shift into carry

        lda     #$A0                    ; set new exponent
        sta     FACEXP                  ; save FAC1 exponent

        lda     FacMantissa+3           ; get FAC1 mantissa 4
        sta     CHARAC                  ; save FAC1 mantissa 4 for power
                                        ; function
        jmp     AbsNormalFAC1           ; do ABS and normalise FAC1     [B8D2]


;******************************************************************************
;
; clear FAC1 and return

A_BCE9                                  ;                               [BCE9]
        sta     FacMantissa             ; clear FAC1 mantissa 1
        sta     FacMantissa+1           ; clear FAC1 mantissa 2
        sta     FacMantissa+2           ; clear FAC1 mantissa 3
        sta     FacMantissa+3           ; clear FAC1 mantissa 4

        tay                             ; clear Y
A_BCF2                                  ;                               [BCF2]
        rts


;******************************************************************************
;
; get FAC1 from string

String2FAC1                             ;                               [BCF3]
        ldy     #$00                    ; clear Y
        ldx     #$0A                    ; set index
A_BCF7                                  ;                               [BCF7]
        sty     FacTempStor+6,X         ; clear byte

        dex                             ; decrement index
        bpl     A_BCF7                  ; loop until numexp to negnum
                                        ; (and FAC1 = $00)
        bcc     A_BD0D                  ; branch if first character is numeric

        cmp     #'-'                    ; else compare with "-"
        bne     A_BD06                  ; branch if not "-"

        stx     SGNFLG                  ; set flag for -ve n (negnum = $FF)
        beq     J_BD0A                  ; branch always

A_BD06                                  ;                               [BD06]
        cmp     #'+'                    ; else compare with "+"
        bne     A_BD0F                  ; branch if not "+"

J_BD0A                                  ;                               [BD0A]
        jsr     CHRGET                  ; increment and scan memory     [0073]
A_BD0D                                  ;                               [BD0D]
        bcc     A_BD6A                  ; branch if numeric character

A_BD0F                                  ;                               [BD0F]
        cmp     #'.'                    ; else compare with "."
        beq     A_BD41                  ; branch if "."

        cmp     #'E'                    ; else compare with "E"
        bne     A_BD47                  ; branch if not "E"

; was "E" so evaluate exponential part
        jsr     CHRGET                  ; increment and scan memory     [0073]
        bcc     A_BD33                  ; branch if numeric character

        cmp     #TK_MINUS               ; else compare with token for -
        beq     A_BD2E                  ; branch if token for -

        cmp     #'-'                    ; else compare with "-"
        beq     A_BD2E                  ; branch if "-"

        cmp     #TK_PLUS                ; else compare with token for +
        beq     J_BD30                  ; branch if token for +

        cmp     #'+'                    ; else compare with "+"
        beq     J_BD30                  ; branch if "+"

        bne     A_BD35                  ; branch always

A_BD2E                                  ;                               [BD2E]
        ror     FacTempStor+9           ; set exponent -ve flag (C, which=1,
                                        ; into b7)
J_BD30                                  ;                               [BD30]
        jsr     CHRGET                  ; increment and scan memory     [0073]
A_BD33                                  ;                               [BD33]
        bcc     A_BD91                  ; branch if numeric character

A_BD35                                  ;                               [BD35]
        bit     FacTempStor+9           ; test exponent -ve flag
        bpl     A_BD47                  ; if +ve go evaluate exponent

; else do exponent = -exponent
        lda     #$00                    ; clear result
        sec                             ; set carry for subtract
        sbc     FacTempStor+7           ; subtract exponent byte

        jmp     J_BD49                  ; go evaluate exponent          [BD49]

A_BD41                                  ;                               [BD41]
        ror     FacTempStor+8           ; set decimal point flag
        bit     FacTempStor+8           ; test decimal point flag
        bvc     J_BD0A                  ; branch if only one decimal point so
                                        ; far
; evaluate exponent
A_BD47                                  ;                               [BD47]
        lda     FacTempStor+7           ; get exponent count byte
J_BD49                                  ;                               [BD49]
        sec                             ; set carry for subtract
        sbc     FacTempStor+6           ; subtract numerator exponent
        sta     FacTempStor+7           ; save exponent count byte
        beq     A_BD62                  ; branch if no adjustment

        bpl     A_BD5B                  ; else if +ve go do FAC1*10^expcnt

; else go do FAC1/10^(0-expcnt)
A_BD52                                  ;                               [BD52]
        jsr     FAC1div10               ; divide FAC1 by 10             [BAFE]

        inc     FacTempStor+7           ; increment exponent count byte
        bne     A_BD52                  ; loop until all done

        beq     A_BD62                  ; branch always


A_BD5B                                  ;                               [BD5B]
        jsr     Fac1x10                 ; multiply FAC1 by 10           [BAE2]

        dec     FacTempStor+7           ; decrement exponent count byte
        bne     A_BD5B                  ; loop until all done

A_BD62                                  ;                               [BD62]
        lda     SGNFLG                  ; get -ve flag
        bmi     A_BD67                  ; if -ve do - FAC1 and return

        rts


;******************************************************************************
;
; do - FAC1 and return

A_BD67                                  ;                               [BD67]
        jmp     bcGREATER               ; do - FAC1                     [BFB4]

; do unsigned FAC1*10+number

A_BD6A                                  ;                               [BD6A]
        pha                             ; save character

        bit     FacTempStor+8           ; test decimal point flag
        bpl     A_BD71                  ; skip exponent increment if not set

        inc     FacTempStor+6           ; else increment number exponent
A_BD71                                  ;                               [BD71]
        jsr     Fac1x10                 ; multiply FAC1 by 10           [BAE2]

        pla                             ; restore character
        sec                             ; set carry for subtract
        sbc     #'0'                    ; convert to binary
        jsr     EvalNewDigit            ; evaluate new ASCII digit      [BD7E]

        jmp     J_BD0A                  ; go do next character          [BD0A]

; evaluate new ASCII digit
; multiply FAC1 by 10 then (ABS) add in new digit

EvalNewDigit                            ;                               [BD7E]
        pha                             ; save digit

        jsr     CopyFAC1toFAC2          ; round and copy FAC1 to FAC2   [BC0C]

        pla                             ; restore digit
        jsr     AtoInteger              ; save A as integer byte        [BC3C]

        lda     ARGSGN                  ; get FAC2 sign (b7)
        eor     FACSGN                  ; toggle with FAC1 sign (b7)
        sta     ARISGN                  ; save sign compare (FAC1 EOR FAC2)

        ldx     FACEXP                  ; get FAC1 exponent
        jmp     bcPLUS                  ; add FAC2 to FAC1 and return   [B86A]

; evaluate next character of exponential part of number

A_BD91                                  ;                               [BD91]
        lda     FacTempStor+7           ; get exponent count byte
        cmp     #$0A                    ; compare with 10 decimal
        bcc     A_BDA0                  ; branch if less

        lda     #$64                    ; make all -ve exponents = -100 decimal
                                        ; (causes underflow)
        bit     FacTempStor+9           ; test exponent -ve flag
        bmi     A_BDAE                  ; branch if -ve

        jmp     OverflowError           ; else do overflow error then warm start
                                        ;                               [B97E]
A_BDA0                                  ;                               [BDA0]
        asl                             ; *2
        asl                             ; *4
        clc                             ; clear carry for add
        adc     FacTempStor+7           ; *5
        asl                             ; *10
        clc                             ; clear carry for add
        ldy     #$00                    ; set index
        adc     (TXTPTR),Y              ; add character (will be $30 too much!)
        sec                             ; set carry for subtract
        sbc     #'0'                    ; convert character to binary
A_BDAE                                  ;                               [BDAE]
        sta     FacTempStor+7           ; save exponent count byte

        jmp     J_BD30                  ; go get next character         [BD30]


;******************************************************************************
;
; limits for scientific mode

C99999999                               ;                               [BDB3]
.byte   $9B,$3E,$BC,$1F,$FD             ; 99999999.90625, maximum value with at
                                        ; least one decimal
C999999999                              ;                               [BDB8]
.byte   $9E,$6E,$6B,$27,$FD             ; 999999999.25, maximum value before
                                        ; scientific notation
C1000000000                             ;                               [BDBD]
.byte   $9E,$6E,$6B,$28,$00             ; 1000000000


;******************************************************************************
;
; do " IN " line number message

Print_IN                                ;                               [BDC2]
        lda     #<TxtIN                 ; set " IN " pointer LB
        ldy     #>TxtIN                 ; set " IN " pointer HB
        jsr     OutputString0           ; print null terminated string  [BDDA]

        lda     CURLIN+1                ; get the current line number HB
        ldx     CURLIN                  ; get the current line number LB


;******************************************************************************
;
; print XA as unsigned integer

PrintXAasInt                            ;                               [BDCD]
        sta     FacMantissa             ; save HB as FAC1 mantissa1
        stx     FacMantissa+1           ; save LB as FAC1 mantissa2
S_BDD1 
        ldx     #$90                    ; set exponent to 16d bits
        sec                             ; set integer is +ve flag
        jsr     SetExpontIsX            ; set exponent = X, clear mantissa 4
                                        ; and 3 and normalise FAC1      [BC49]
        jsr     FAC12String             ; convert FAC1 to string        [BDDF]
OutputString0                           ;                               [BDDA]
        jmp     OutputString            ; print null terminated string  [AB1E]


;******************************************************************************
;
; convert FAC1 to ASCII string result in (AY)

FAC1toASCII                             ;                               [BDDD]
        ldy     #$01                    ; set index = 1
FAC12String                             ;                               [BDDF]
        lda     #' '                    ; character = " " (assume +ve)
        bit     FACSGN                  ; test FAC1 sign (b7)
        bpl     A_BDE7                  ; branch if +ve

        lda     #'-'                    ; else character = "-"
A_BDE7                                  ;                               [BDE7]
        sta     StrConvAddr,Y           ; save leading character (" " or "-")
        sta     FACSGN                  ; save FAC1 sign (b7)
        sty     FBUFPT                  ; save index

        iny                             ; increment index

        lda     #'0'                    ; set character = "0"

        ldx     FACEXP                  ; get FAC1 exponent
        bne     A_BDF8                  ; branch if FAC1<>0

; exponent was $00 so FAC1 is 0
        jmp     J_BF04                  ; save last character, [EOT] and exit
                                        ;                               [BF04]

; FAC1 is some non zero value
A_BDF8                                  ;                               [BDF8]
        lda     #$00                    ; clear (number exponent count)
        cpx     #$80                    ; compare FAC1 exponent with $80
                                        ; (<1.00000)
        beq     A_BE00                  ; branch if 0.5 <= FAC1 < 1.0

        bcs     A_BE09                  ; branch if FAC1=>1

A_BE00                                  ;                               [BE00]
        lda     #<C1000000000           ; set 1000000000 pointer LB
        ldy     #>C1000000000           ; set 1000000000 pointer HB
        jsr     FAC1xAY                 ; do convert AY, FCA1*(AY)      [BA28]

        lda     #$F7                    ; set number exponent count
A_BE09                                  ;                               [BE09]
        sta     FacTempStor+6           ; save number exponent count
A_BE0B                                  ;                               [BE0B]
        lda     #<C999999999            ; set 999999999.25 pointer LB (max
                                        ; before sci note)
        ldy     #>C999999999            ; set 999999999.25 pointer HB
        jsr     CmpFAC1withAY           ; compare FAC1 with (AY)        [BC5B]
        beq     A_BE32                  ; exit if FAC1 = (AY)

        bpl     A_BE28                  ; go do /10 if FAC1 > (AY)

; FAC1 < (AY)
A_BE16                                  ;                               [BE16]
        lda     #<C99999999             ; set 99999999.90625 pointer LB
        ldy     #>C99999999             ; set 99999999.90625 pointer HB
        jsr     CmpFAC1withAY           ; compare FAC1 with (AY)        [BC5B]
        beq     A_BE21                  ; branch if FAC1 = (AY) (allow decimal
                                        ; places)
        bpl     A_BE2F                  ; branch if FAC1 > (AY) (no decimal
                                        ; places)
; FAC1 <= (AY)
A_BE21                                  ;                               [BE21]
        jsr     Fac1x10                 ; multiply FAC1 by 10           [BAE2]

        dec     FacTempStor+6           ; decrement number exponent count
        bne     A_BE16                  ; go test again, branch always

A_BE28                                  ;                               [BE28]
        jsr     FAC1div10               ; divide FAC1 by 10             [BAFE]

        inc     FacTempStor+6           ; increment number exponent count
        bne     A_BE0B                  ; go test again, branch always

; now we have just the digits to do

A_BE2F                                  ;                               [BE2F]
        jsr     FAC1plus05              ; add 0.5 to FAC1 (round FAC1)  [B849]
A_BE32                                  ;                               [BE32]
        jsr     FAC1Float2Fix           ; convert FAC1 floating to fixed [BC9B]

        ldx     #$01                    ; set default digits before dp = 1

        lda     FacTempStor+6           ; get number exponent count
        clc                             ; clear carry for add
        adc     #$0A                    ; up to 9 digits before point
        bmi     A_BE47                  ; if -ve then 1 digit before dp

        cmp     #$0B                    ; A>=$0B if n>=1E9
        bcs     A_BE48                  ; branch if >= $0B

; carry is clear
        adc     #$FF                    ; take 1 from digit count
        tax                             ; copy to X

        lda     #$02                    ;.set exponent adjust
A_BE47                                  ;                               [BE47]
        sec                             ; set carry for subtract
A_BE48                                  ;                               [BE48]
        sbc     #$02                    ; -2
        sta     FacTempStor+7           ;.save exponent adjust
        stx     FacTempStor+6           ; save digits before dp count

        txa                             ; copy to A
        beq     A_BE53                  ; branch if no digits before dp

        bpl     A_BE66                  ; branch if digits before dp

A_BE53                                  ;                               [BE53]
        ldy     FBUFPT                  ; get output string index
        lda     #'.'                    ; character "."
        iny                             ; increment index
        sta     StrConvAddr,Y           ; save to output string

        txa                             ;.
        beq     A_BE64                  ;.

        lda     #'0'                    ; character "0"
        iny                             ; increment index
        sta     StrConvAddr,Y           ; save to output string
A_BE64                                  ;                               [BE64]
        sty     FBUFPT                  ; save output string index
A_BE66                                  ;                               [BE66]
        ldy     #$00                    ; clear index (point to 100,000)
JiffyCnt2Str                            ;                               [BE68]
        ldx     #$80                    ;.
A_BE6A                                  ;                               [BE6A]
        lda     FacMantissa+3           ; get FAC1 mantissa 4
        clc                             ; clear carry for add
        adc     D_BF16+3,Y              ; add byte 4, least significant
        sta     FacMantissa+3           ; save FAC1 mantissa4

        lda     FacMantissa+2           ; get FAC1 mantissa 3
        adc     D_BF16+2,Y              ; add byte 3
        sta     FacMantissa+2           ; save FAC1 mantissa3

        lda     FacMantissa+1           ; get FAC1 mantissa 2
        adc     D_BF16+1,Y              ; add byte 2
        sta     FacMantissa+1           ; save FAC1 mantissa2

        lda     FacMantissa             ; get FAC1 mantissa 1
        adc     D_BF16+0,Y              ; add byte 1, most significant
        sta     FacMantissa             ; save FAC1 mantissa1

        inx                             ; increment the digit, set the sign on
                                        ; the test sense bit
        bcs     A_BE8E                  ; if the carry is set go test if the
                                        ; result was positive
; else the result needs to be negative
        bpl     A_BE6A                  ; not -ve so try again

        bmi     A_BE90                  ; else done so return the digit
A_BE8E                                  ;                               [BE8E]
        bmi     A_BE6A                  ; not +ve so try again

; else done so return the digit

A_BE90                                  ;                               [BE90]
        txa                             ; copy the digit
        bcc     A_BE97                  ; if Cb=0 just use it

        eor     #$FF                    ; else make the 2's complement ..
        adc     #$0A                    ; .. and subtract it from 10
A_BE97                                  ;                               [BE97]
        adc     #'0'-1                  ; add "0"-1 to result

        iny                             ; increment ..
        iny                             ; .. index to..
        iny                             ; .. next less ..
        iny                             ; .. power of ten
        sty     VARPNT                  ; save current variable pointer LB

        ldy     FBUFPT                  ; get output string index
        iny                             ; increment output string index

        tax                             ; copy character to X

        and     #$7F                    ; mask out top bit
        sta     StrConvAddr,Y           ; save to output string

        dec     FacTempStor+6           ; decrement # of characters before dp
        bne     A_BEB2                  ; branch if still characters to do

; else output the point
        lda     #'.'                    ; character "."
        iny                             ; increment output string index
        sta     STACK-1,Y               ; save to output string
A_BEB2                                  ;                               [BEB2]
        sty     FBUFPT                  ; save output string index

        ldy     VARPNT                  ; get current variable pointer LB

        txa                             ; get character back
        eor     #$FF                    ; toggle the test sense bit
        and     #$80                    ; clear the digit
        tax                             ; copy it to the new digit

        cpy     #D_BF3A-D_BF16          ; compare the table index with the max
                                        ; for decimal numbers
        beq     A_BEC4                  ; if at the max exit the digit loop

        cpy     #D_BF52-D_BF16          ; compare the table index with the max
                                        ; for time
        bne     A_BE6A                  ; loop if not at the max

; now remove trailing zeroes

A_BEC4                                  ;                               [BEC4]
        ldy     FBUFPT                  ; restore the output string index
A_BEC6                                  ;                               [BEC6]
        lda     STACK-1,Y               ; get character from output string
        dey                             ; decrement output string index
        cmp     #'0'                    ; compare with "0"
        beq     A_BEC6                  ; loop until non "0" character found

        cmp     #'.'                    ; compare with "."
        beq     A_BED3                  ; branch if was dp

; restore last character
        iny                             ; increment output string index
A_BED3                                  ;                               [BED3]
        lda     #'+'                    ; character "+"

        ldx     FacTempStor+7           ; get exponent count
        beq     A_BF07                  ; if zero go set null terminator and
                                        ; exit
; exponent isn't zero so write exponent
        bpl     A_BEE3                  ; branch if exponent count +ve

        lda     #$00                    ; clear A
        sec                             ; set carry for subtract
        sbc     FacTempStor+7           ; subtract exponent count adjust
                                        ; (convert -ve to +ve)
        tax                             ; copy exponent count to X

        lda     #'-'                    ; character "-"
A_BEE3                                  ;                               [BEE3]
        sta     STACK+1,Y               ; save to output string

        lda     #'E'                    ; character "E"
        sta     STACK,Y                 ; save exponent sign to output string

        txa                             ; get exponent count back

        ldx     #'0'-1                  ; one less than "0" character
        sec                             ; set carry for subtract
A_BEEF                                  ;                               [BEEF]
        inx                             ; increment 10's character

        sbc     #$0A                    ;.subtract 10 from exponent count
        bcs     A_BEEF                  ; loop while still >= 0

        adc     #':'                    ; add character ":" ($30+$0A, result is
                                        ; 10 less that value)
        sta     STACK+3,Y               ; save to output string

        txa                             ; copy 10's character
        sta     STACK+2,Y               ; save to output string

        lda     #$00                    ; set null terminator
        sta     STACK+4,Y               ; save to output string
        beq     A_BF0C                  ; go set string pointer (AY) and exit,
                                        ; branch always
; save last character, [EOT] and exit

J_BF04                                  ;                               [BF04]
        sta     STACK-1,Y               ; save last character to output string

; set null terminator and exit
A_BF07                                  ;                               [BF07]
        lda     #$00                    ; set null terminator
        sta     STACK,Y                 ; save after last character

; set string pointer (AY) and exit
A_BF0C                                  ;                               [BF0C]
        lda     #<STACK                 ; set result string pointer LB
        ldy     #>STACK                 ; set result string pointer HB
        rts


;******************************************************************************
;
; constants

L_BF11                                  ;                               [BF11]
.byte   $80,$00                         ; 0.5, first two bytes
L_BF13                                  ;                               [BF13]
.byte   $00,$00,$00                     ; null return for undefined variables

D_BF16                                  ;                               [BF16]
.byte   $FA,$0A,$1F,$00                 ; -100000000
.byte   $00,$98,$96,$80                 ;  +10000000
.byte   $FF,$F0,$BD,$C0                 ;   -1000000
.byte   $00,$01,$86,$A0                 ;    +100000
.byte   $FF,$FF,$D8,$F0                 ;     -10000
.byte   $00,$00,$03,$E8                 ;      +1000
.byte   $FF,$FF,$FF,$9C                 ;       -100
.byte   $00,$00,$00,$0A                 ;        +10
.byte   $FF,$FF,$FF,$FF                 ;         -1

; jiffy counts

D_BF3A                                  ;                               [BF3A]
.byte   $FF,$DF,$0A,$80                 ; -2160000      10s hours
.byte   $00,$03,$4B,$C0                 ;  +216000          hours
.byte   $FF,$FF,$73,$60                 ;   -36000      10s mins
.byte   $00,$00,$0E,$10                 ;    +3600          mins
.byte   $FF,$FF,$FD,$A8                 ;     -600      10s secs
.byte   $00,$00,$00,$3C                 ;      +60          secs
D_BF52                                  ;                               [BF52]


;******************************************************************************
;
; not referenced

.byte   $EC                             ; checksum byte


;******************************************************************************
;
; spare bytes, not referenced

.byte   $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
.byte   $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA


;******************************************************************************
;
; perform SQR()

bcSQR                                   ;                               [BF71]
        jsr     CopyFAC1toFAC2          ; round and copy FAC1 to FAC2   [BC0C]

        lda     #<L_BF11                ; set 0.5 pointer low address
        ldy     #>L_BF11                ; set 0.5 pointer high address
        jsr     UnpackAY2FAC1           ; unpack memory (AY) into FAC1  [BBA2]


;******************************************************************************
;
; perform power function

bcPOWER                                 ;                               [BF7B]
        beq     bcEXP                   ; perform EXP()

        lda     ARGEXP                  ; get FAC2 exponent
        bne     A_BF84                  ; branch if FAC2<>0

        jmp     ClrFAC1Exp              ; clear FAC1 exponent and sign and
                                        ; return                        [B8F9]
A_BF84                                  ;                               [BF84]
        ldx     #<GarbagePtr            ; set destination pointer LB
        ldy     #>GarbagePtr            ; set destination pointer HB
        jsr     PackFAC1intoXY          ; pack FAC1 into (XY)           [BBD4]

        lda     ARGSGN                  ; get FAC2 sign (b7)
        bpl     A_BF9E                  ; branch if FAC2>0

; else FAC2 is -ve and can only be raised to an integer power which gives an
; x + j0 result
        jsr     bcINT                   ; perform INT()                 [BCCC]

        lda     #<GarbagePtr            ; set source pointer LB
        ldy     #>GarbagePtr            ; set source pointer HB
        jsr     CmpFAC1withAY           ; compare FAC1 with (AY)        [BC5B]
        bne     A_BF9E                  ; branch if FAC1 <> (AY) to allow
                                        ; Function Call error this will leave
                                        ; FAC1 -ve and cause a Function Call
                                        ; error when LOG() is called
        tya                             ; clear sign b7
        ldy     CHARAC                  ; get FAC1 mantissa 4 from INT()
                                        ; function as sign in Y for possible
                                        ; later negation, b0 only needed
A_BF9E                                  ;                               [BF9E]
        jsr     CpFAC2toFAC12           ; save FAC1 sign and copy ABS(FAC2) to
                                        ; FAC1                          [BBFE]
        tya                             ; copy sign back ..
        pha                             ; .. and save it

        jsr     bcLOG                   ; perform LOG()                 [B9EA]

        lda     #<GarbagePtr            ; set pointer LB
        ldy     #>GarbagePtr            ; set pointer HB
        jsr     FAC1xAY                 ; do convert AY, FCA1*(AY)      [BA28]

        jsr     bcEXP                   ; perform EXP()                 [BFED]

        pla                             ; pull sign from stack
        lsr                             ; b0 is to be tested
        bcc     A_BFBE                  ; if no bit then exit

; do - FAC1

bcGREATER                               ;                               [BFB4]
        lda     FACEXP                  ; get FAC1 exponent
        beq     A_BFBE                  ; exit if FAC1_e = $00

        lda     FACSGN                  ; get FAC1 sign (b7)
        eor     #$FF                    ; complement it
        sta     FACSGN                  ; save FAC1 sign (b7)
A_BFBE                                  ;                               [BFBE]
        rts


;******************************************************************************
;
; exp(n) constant and series

ConstantEXP                             ;                               [BFBF]
.byte   $81,$38,$AA,$3B,$29             ; 1.443

TblEXPseries                            ;                               [BFC4]
.byte   $07                             ; series count
.byte   $71,$34,$58,$3E,$56             ; 2.14987637E-5
.byte   $74,$16,$7E,$B3,$1B             ; 1.43523140E-4
.byte   $77,$2F,$EE,$E3,$85             ; 1.34226348E-3
.byte   $7A,$1D,$84,$1C,$2A             ; 9.61401701E-3
.byte   $7C,$63,$59,$58,$0A             ; 5.55051269E-2
.byte   $7E,$75,$FD,$E7,$C6             ; 2.40226385E-1
.byte   $80,$31,$72,$18,$10             ; 6.93147186E-1
.byte   $81,$00,$00,$00,$00             ; 1.00000000


;******************************************************************************
;
; perform EXP()

bcEXP                                   ;                               [BFED]
        lda     #<ConstantEXP           ; set 1.443 pointer LB
        ldy     #>ConstantEXP           ; set 1.443 pointer HB
        jsr     FAC1xAY                 ; do convert AY, FCA1*(AY)      [BA28]

        lda     FACOV                   ; get FAC1 rounding byte
        adc     #$50                    ; +$50/$100
        bcc     A_BFFD                  ; skip rounding if no carry

        jsr     RoundFAC12              ; round FAC1 (no check)         [BC23]
A_BFFD                                  ;                               [BFFD]
        jmp     bcEXP2                  ; continue EXP()                [E000]


