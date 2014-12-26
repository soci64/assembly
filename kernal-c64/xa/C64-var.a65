;******************************************************************************
;******************************************************************************
;
; The almost completely commented C64 ROM disassembly. V1.01 Lee Davison 2012

;******************************************************************************
;******************************************************************************
;
; first a whole load of equates

D6510                   = $00           ; 6510 I/O port data direction register
                                        ; bit   default
                                        ; ---   -------
                                        ;  7    unused
                                        ;  6    unused
                                        ;  5    1 = output
                                        ;  4    0 = input
                                        ;  3    1 = output
                                        ;  2    1 = output
                                        ;  1    1 = output
                                        ;  0    1 = output

P6510                   = $01           ; 6510 I/O port data register
                                        ; bit   name            function
                                        ; ---   ----            --------
                                        ;  7    unused
                                        ;  6    unused
                                        ;  5    cass motor 1 = off, 0 = on
                                        ;  4    cass sw    1 = off, 0 = on
                                        ;  3    cass data
                                        ;  2    CHAREN     1 = I/O,
                                        ;                  0 = chraracter ROM
                                        ;  1    HIRAM   1 = Kernal,     0 = RAM
                                        ;  0    LORAM   1 = BASIC,      0 = RAM

ZP02                    = $02           ; unused

; This vector points to the address of the BASIC routine which converts a
; floating point number to an integer, however BASIC does not use this vector.
; It may be of assistance to the programmer who wishes to use data that is;
; stored in floating point format. The parameter passed by the USR command is
; available only in that format for example.

ADRAY1                  = $03           ; float to fixed vector
; ... $04


; This vector points to the address of the BASIC routine which converts an
; integer to a floating point number, however BASIC does not use this vector.
; It may be used by the programmer who needs to make such a conversion for a
; machine language program that interacts with BASIC.  To return an integer
; value with the USR command for example.

ADRAY2                  = $05           ; fixed to float vector
; ... $06


; These locations hold searched for characters when BASIC is searching for the
; end of a srting or crunching BASIC lines

CHARAC                  = $07           ; search character
ENDCHR                  = $08           ; scan quotes flag


; The cursor column position prior to the TAB or SPC is moved here from $D3,
; and is used to calculate where the cursor ends up after one of these
; functions is invoked.

; Note that the value contained here shows the position of the cursor on a
; logical line. Since one logical line can be up to four physical lines long,
; the value stored here can range from 0 to 87.

TRMPOS                  = $09           ; TAB column save


; The routine that converts the text in the input buffer into lines of
; executable program tokes, and the routines that link these program lines
; together, use this location as an index into the input buffer area. After the
; job of converting text to tokens is done, the value in this location is equal
; to the length of the tokenized line.

; The routines which build an array or locate an element in an array use this
; location to calculate the number of DIMensions called for and the amount of
; storage required for a newly created array, or the number of subscripts when
; referencing an array element.

LoadVerify              = $0A           ; load/verify flag, 0 = load, 1 = verify
COUNT                   = $0B           ; temporary byte, line crunch/array
                                        ; access/logic operators

; This is used as a flag by the routines that build an array or reference an
; existing array. It is used to determine whether a variable is in an array,
; whether the array has already been DIMensioned, and whether a new array
; should assume the default size.

DIMFLG                  = $0C           ; DIM flag


; This flag is used to indicate whether data being operated upon is string or
; numeric. A value of $FF in this location indicates string data while a $00
; indicates numeric data.

VALTYP                  = $0D           ; data type flag, $FF = string,
                                        ;                 $00 = numeric

; If the above flag indicates numeric then a $80 in this location identifies
; the number as an integer, and a $00 indicates a floating point number.

INTFLG                  = $0E           ; data type flag, $80 = integer,
                                        ;                 $00 = floating point

; The garbage collection routine uses this location as a flag to indicate that
; garbage collection has already been tried before adding a new string. If
; there is still not; enough memory, an OUT OF MEMORY error message will
; result.

; LIST uses this byte as a flag to let it know when it has come to a character
; string in quotes. It will then print the string,rather than search it for
; BASIC keyword tokens.

; This location is also used during the process of converting a line of text in
; the BASIC input buffer into a linked program line of BASIC keyword tokens to
; flag a DATA line is being processed.

GARBFL                  = $0F           ; garbage collected/open quote/DATA flag


; If an opening parenthesis is found, this flag is set to indicate that the
; variable in; question is either an array variable or a user-defined function.

SUBFLG                  = $10           ; subscript/FNx flag


; This location is used to determine whether the sign of the value returned by
; the functions SIN, COS, ATN or TAN is positive or negative.

; Also the comparison routines use this location to indicate the outcome of the
; compare. For A <=> B the value here will be $01 if A > B, $02 if A = B, and
; $04 if A < B. If more than one comparison operator was used to compare the
; two variables then the value here will be a combination of the above values.

INPFLG                  = $11           ; input mode flag, $00 = INPUT,
                                        ; $40 = GET, $98 = READ
TANSGN                  = $12           ; ATN sign/comparison evaluation flag


; When the default input or output device is used the value here will be a
; zero, and the format of prompting and output will be the standard screen
; output format. The location $B8 is used to decide what device actually to
; put input from or output to.

CurIoChan               = $13           ; current I/O channel


; Used whenever a 16 bit integer is used e.g. the target line number for GOTO,
; LIST, ON, and GOSUB also the number of a BASIC line that is to be added or
; replaced. additionally PEEK, POKE, WAIT, and SYS use this location as a
; pointer to the address which is the subject of the command.

LINNUM                  = $14           ; temporary integer
; ... $15

LINNUMJ                 = $0014         ; used with SYS: JMP ($0014)


; This location points to the next available slot in the temporary string
; descriptor stack located at $19-$21.

TEMPPT                  = $16           ; descriptor stack pointer, next free


; This contains information about temporary strings which have not yet been
; assigned to a string variable.

LASTPT                  = $17           ; current descriptor stack item
; ... $18

TEMST                   = $19           ; stack for temporary strings
; ... $21

; These locations are used by BASIC multiplication and division routines. They
; are also used by the routines which compute the size of the area required to
; store an array which is being created.

INDEX                   = $22           ; misc temp byte
; ... $25

RESHO                   = $26           ; temp mantissa 1
; ... $29


; Two byte pointer to where the BASIC program text is stored.

TXTTAB                  = $2B           ; start of memory
; ... $2C


; Two byte pointer to the start of the BASIC variable storage area.

VARTAB                  = $2D           ; start of variables
; ... $2E


; Two byte pointer to the start of the BASIC array storage area.

ARYTAB                  = $2F           ; end of variables
; ... $30


; Two byte pointer to end of the start of free RAM.

STREND                  = $31           ; end of arrays
; ... $32


; Two byte pointer to the bottom of the string text storage area.

FRETOP                  = $33           ; bottom of string space
; ... $34


; Used as a temporary pointer to the most current string added by the routines
; which build strings or move them in memory.

FRESPC                  = $35           ; string utility ptr
; ... $36


; Two byte pointer to the highest address used by BASIC +1.

MEMSIZ                  = $37           ; end of memory
; ... $38


; These locations contain the line number of the BASIC statement which is
; currently being executed. A value of $FF in location $3A means that BASIC is
; in immediate mode.

CURLIN                  = $39           ; current line number
; ... $3A


; When program execution ends or stops the last line number executed is stored
; here.

OLDLIN                  = $3B           ; break line number
; ... $3C


; These locations contain the address of the start of the text of the BASIC
; statement that is being executed.  The value of the pointer to the address of
; the BASIC text character currently being scanned is stored here each time a
; new BASIC statement begins execution.

OLDTXT                  = $3D           ; continue pointer
; ... $3E


; These locations hold the line number of the current DATA statement being
; READ. If an error concerning the DATA occurs this number will be moved to
; $39/$3A so that the error message will show the line that contains the DATA
; statement rather than in the line that contains the READ statement.

DATLIN                  = $3F           ; current DATA line number
; ... $40


; These locations point to the address where the next DATA will be READ from.
; RESTORE; sets this pointer back to the address indicated by the start of
; BASIC pointer.

DATPTR                  = $41           ; DATA pointer
; ... $42


; READ, INPUT and GET all use this as a pointer to the address of the source of
; incoming data, such as DATA statements, or the text input buffer.

INPPTR                  = $43           ; READ pointer
; ... $44

VARNAM                  = $45           ; current variable name
; ... $46


; These locations point to the value of the current BASIC variable Specifically
; they point to the byte just after the two-character variable name.

VARPNT                  = $47           ; current variable address
; ... $48


; The address of the BASIC variable which is the subject of a FOR/NEXT loop is
; first stored here before being pushed onto the stack.

FORPNT                  = $49           ; FOR/NEXT variable pointer
; ... $4A


; The expression evaluation routine creates this to let it know whether the
; current comparison operation is a < $01, = $02 or > $04 comparison or
; combination.

TEMPSTR                 = $4B           ; BASIC execute pointer temporary
                                        ; /precedence flag
; ... $4C

CompEvalFlg             = $4D           ; comparrison evaluation flag


; These locations are used as a pointer to the function that is created during
; function definition . During function execution it points to where the
; evaluation results should be saved.

GarbagePtr              = $4E           ; FAC temp store/function/variable
                                        ;   /garbage pointer
; ... $4F


; Temporary Pointer to the current string descriptor.

TempPtr                 = $50           ; FAC temp store/descriptor pointer
; ... $51

GarbColStep             = $53           ; garbage collection step size


; The first byte is the 6502 JMP instruction $4C, followed by the address of
; the required function taken from the table at $C052.

Jump0054                = $54           ; JMP opcode for functions
                                        ; $0054 normally contains $4C = JMP
; ... $56

FacTempStor             = $57           ; FAC temp store
; ... $60


; floating point accumulator 1

FACEXP                  = $61           ; FAC1 exponent
FacMantissa             = $62           ; FAC1 mantissa 1
; ... $65
FACSGN                  = $66           ; FAC1 sign
SGNFLG                  = $67           ; constant count/-ve flag
BITS                    = $68           ; FAC1 overflow


; floating point accumulator 2

ARGEXP                  = $69           ; FAC2 exponent
ArgMantissa             = $6A           ; FAC2 mantissa 1
; ... $6D
ARGSGN                  = $6E           ; FAC2 sign
ARISGN                  = $6F           ; FAC sign comparrison
FACOV                   = $70           ; FAC1 rounding

FBUFPT                  = $71           ; temp BASIC execute/array pointer
                                        ;   /index
; ... $72


CHRGET                  = $73           ; increment and scan memory, BASIC byte get
CHRGOT                  = $79           ; scan memory, BASIC byte get

TXTPTR                  = $7A           ; BASIC execute pointer
; ... $7B

NumericTest             = $80           ; numeric test entry

RND_seed                = $8B           ; RND() seed, five bytes
; ... $8F


; kernal work area

STATUS                  = $90           ; serial status byte
                                        ;       function
                                        ; bit   casette         serial bus
                                        ; ---   --------        ----------
                                        ;  7    end of tape     device not present
                                        ;  6    end of file     EOI
                                        ;  5    checksum error
                                        ;  4    read error
                                        ;  3    long block
                                        ;  2    short block
                                        ;  1                    time out read
                                        ;  0                    time out write


; This location is updated every 1/60 second during the IRQ routine. The value
; saved is the keyboard c7 column byte which contains the stop key

StopKey                 = $91           ; stop key column
                                        ; bit   key, 0 = pressed
                                        ; ---   --------
                                        ;  7    [RUN]
                                        ;  6    Q
                                        ;  5    [CBM]
                                        ;  4    [SP]
                                        ;  3    2
                                        ;  2    [CTL]
                                        ;  1    [LFT]
                                        ;  0    1


; This location is used as an adjustable timing constant for tape reads to
; allow for slight speed variations on tapes.

SVXT                    = $92           ; timing constant for tape read


; The same routine is used for both LOAD and VERIFY, the flag here determines
; which that routine does.

LoadVerify2             = $93           ; load/verify flag, load = $00,
                                        ;                   verify = $01


; This location is used to indecate that a serial byte is waiting to be sent.

C3PO                    = $94           ; serial output: deferred character flag
                                        ; $00 = no character waiting,
                                        ; $xx = character waiting


; This location holds the serial character waiting to be sent. A value of $FF
; here means no character is waiting.

BSOUR                   = $95           ; serial output: deferred character
                                        ; $FF = no character waiting,
                                        ; $xx = waiting character

SYNO                    = $96           ; cassette block synchronization number


; X register save location for routines that get and put an ASCII character.

TEMP97                  = $97           ; X register save


; The number of currently open I/O files is stored here. The maximum number
; that can be open at one time is ten. The number stored here is used as the
; index to the end of the tables that hold the file numbers, device numbers,
; and secondary addresses.

LDTND                   = $98           ; open file count


; The default value of this location is 0, the keyboard.

DFLTN                   = $99           ; input device number


; The default value of this location is 3, the screen.

DFLTO                   = $9A           ; output device number
                                        ; number        device
                                        ; ------        ------
                                        ;  0            keyboard
                                        ;  1            cassette
                                        ;  2            RS-232C
                                        ;  3            screen
                                        ;  4-31 serial bus


PRTY                    = $9B           ; tape character parity
DPSW                    = $9C           ; tape byte received flag

MSGFLG                  = $9D           ; message mode flag,
                                        ; $C0 = both control and kernal messages,
                                        ; $80 = control messages only = direct mode
                                        ; $40 = kernal messages only,
                                        ; $00 = neither control or kernal messages
                                        ;     = program mode

PTR1                    = $9E           ; tape Pass 1 error log/character buffer

PTR2                    = $9F           ; tape Pass 1 error log/character index


; These three locations form a counter which is updated 60 times a second, and
; serves as a software clock which counts the number of jiffies that have
; elapsed since the computer was turned on. After 24 hours and one jiffy these
; locations are set back to $000000.

TimeBytes               = $A0           ; jiffy clock high byte
; ... $A2


TEMPA3                  = $A3           ; EOI flag byte/tape bit count

; b0 of this location reflects the current phase of the tape output cycle.

TEMPA4                  = $A4           ; tape bit cycle phase
CNTDN                   = $A5           ; cassette synchronization byte count/
                                        ;   serial bus bit count

BUFPNT                  = $A6           ; tape buffer index
INBIT                   = $A7           ; receiver input bit temp storage
BITCI                   = $A8           ; receiver bit count in
RINONE                  = $A9           ; receiver start bit check flag,
                                        ; $90 = no start bit
                                        ; received, $00 = start bit received
RIDATA                  = $AA           ; receiver byte buffer/assembly location
RIPRTY                  = $AB           ; receiver parity bit storage

SAL                     = $AC           ; tape buffer start pointer
                                        ; scroll screen ?? byte
; ... $AD

EAL                     = $AE           ; tape buffer end pointer
                                        ; scroll screen ?? byte
; ... $AF

CMPO                    = $B0           ; tape timing constant
; ... $B1


; Thess two locations point to the address of the cassette buffer. This pointer
; must be greater than or equal to $0200 or an ILLEGAL DEVICE NUMBER error will
; be sent when tape I/O is tried. This pointer must also be less that $8000 or
; the routine will terminate early.

TapeBufPtr              = $B2           ; tape buffer start pointer
; ... $B3


; RS232 routines use this to count the number of bits transmitted and for
; parity and stop bit manipulation. Tape load routines use this location to
; flag when they are ready to receive data bytes.

BITTS                   = $B4           ; transmitter bit count out


; This location is used by the RS232 routines to hold the next bit to be sent
; and by the tape routines to indicate what part of a block the read routine is
; currently reading.

NXTBIT                  = $B5           ; transmitter next bit to be sent


; RS232 routines use this area to disassemble each byte to be sent from the
; transmission buffer pointed to by $F9.

RODATA                  = $B6           ; transmitter byte buffer/disassembly
                                        ; location

; Disk filenames may be up to 16 characters in length while tape filenames be
; up to 187 characters in length.

; If a tape name is longer than 16 characters the excess will be truncated by
; the SEARCHING and FOUND messages, but will still be present on the tape.

; A disk file is always referred to by a name. This location will always be
; greater than zero if the current file is a disk file.

; An RS232 OPEN command may specify a filename of up to four characters. These
; characters are copied to locations $293 to $296 and determine baud rate, word
; length, and parity, or they would do if the feature was fully implemented.

FNLEN                   = $B7           ; filename length

LA                      = $B8           ; logical file
SA                      = $B9           ; secondary address
FA                      = $BA           ; current device number
                                        ; number        device
                                        ; ------        ------
                                        ;  0            keyboard
                                        ;  1            cassette
                                        ;  2            RS-232C
                                        ;  3            screen
                                        ;  4-31 serial bus

FNADR                   = $BB           ; filename pointer
; ... $BC

ROPRTY                  = $BD           ; tape write byte/RS232 parity byte


; Used by the tape routines to count the number of copies of a data block
; remaining to be read or written.

FSBLK                   = $BE           ; tape copies count

MYCH                    = $BF           ; tape parity count

CAS1                    = $C0           ; tape motor interlock

STAL                    = $C1           ; I/O start addresses
; ... $C2

MEMUSS                  = $C3           ; kernal setup pointer
; ... $C4

LSTX                    = $C5           ; current key pressed
                                        ;
                                        ;  # key         # key
                                        ; -- ---        -- ---
                                        ; 00 1          10 none
                                        ; 01 3          11 A
                                        ; 02 5          12 D
                                        ; 03 7          13 G
                                        ; 04 9          14 J
                                        ; 05 +          15 L
                                        ; 06 [UKP]      16 ;
                                        ; 07 [DEL]      17 [CSR R]
                                        ; 08 [<-]       18 [STOP]
                                        ; 09 W          19 none
                                        ; 0A R          1A X
                                        ; 0B Y          1B V
                                        ; 0C I          1C N
                                        ; 0D P          1D ,
                                        ; 0E *          1E /
                                        ; 0F [RET]      1F [CSR D]

                                        ; 20 [SPACE]    30 Q
                                        ; 21 Z          31 E
                                        ; 22 C          32 T
                                        ; 23 B          33 U
                                        ; 24 M          34 O
                                        ; 25 .          35 @
                                        ; 26 none       36 ^
                                        ; 27 [F1]       37 [F5]
                                        ; 28 none       38 2
                                        ; 29 S          39 4
                                        ; 2A F          3A 6
                                        ; 2B H          3B 8
                                        ; 2C K          3C 0
                                        ; 2D :          3D -
                                        ; 2E =          3E [HOME]
                                        ; 2F [F3]       3F [F7]


NDX                     = $C6           ; keyboard buffer length/index


; When the [CTRL][RVS-ON] characters are printed this flag is set to $12, and
; the print; routines will add $80 to the screen code of each character which
; is printed, so that the caracter will appear on the screen with its colours
; reversed.

; Note that the contents of this location are cleared not only upon entry of a
; [CTRL][RVS-OFF] character but also at every carriage return.

RVS                     = $C7           ; reverse flag $12 = reverse, $00 = normal


; This pointer indicates the column number of the last nonblank character on
; the logical line that is to be input. Since a logical line can be up to 88
; characters long this number can range from 0-87.

INDX                    = $C8           ; input [EOL] pointer


; These locations keep track of the logical line that the cursor is on and its
; column position on that logical line.

; Each logical line may contain up to four 22 column physical lines. So there
; may be as many as 23 logical lines, or as few as 6 at any one time.
; Therefore, the logical line number might be anywhere from 1-23. Depending on
; the length of the logical line, the cursor column may be from 1-22, 1-44,
; 1-66 or 1-88.

; For a more on logical lines, see the description of the screen line link
; table, $D9.

CursorRow               = $C9           ; input cursor row
CursorCol               = $CA           ; input cursor column


; The keyscan interrupt routine uses this location to indicate which key is
; currently being pressed. The value here is then used as an index into the
; appropriate keyboard; table to determine which character to print when a key
; is struck.

; The correspondence between the key pressed and the number stored here is as
; follows:

; $00   1               $10     not used        $20     [SPACE]         $30     Q       $40     [NO KEY]
; $01   3               $11     A               $21     Z               $31     E       $xx     invalid
; $02   5               $12     D               $22     C               $32     T
; $03   7               $13     G               $23     B               $33     U
; $04   9               $14     J               $24     M               $34     O
; $05   +               $15     L               $25     .               $35     @
; $06   [POUND]         $16     ;               $26     not used        $36     [U ARROW]
; $07   [DEL]           $17     [RIGHT]         $27     [F1]            $37     [F5]    
; $08   [L ARROW]       $18     [STOP]          $28     not used        $38     2
; $09   W               $19     not used        $29     S               $39     4
; $0A   R               $1A     X               $2A     F               $3A     6
; $0B   Y               $1B     V               $2B     H               $3B     8
; $0C   I               $1C     N               $2C     K               $3C     0
; $0D   P               $1D     ,               $2D     :               $3D     -
; $0E   *               $1E     /               $2E     =               $3E     [HOME]
; $0F   [RETURN]        $1F     [DOWN]          $2F     [F3]            $3F     [F7]

SFDX                    = $CB           ; which key


; When this flag is set to a nonzero value, it indicates to the routine that
; normally flashes the cursor not to do so. The cursor blink is turned off when
; there are characters in the keyboard buffer, or when the program is running.

BLNSW                   = $CC           ; cursor enable, $00 = flash cursor


; The routine that blinks the cursor uses this location to tell when it's time
; for a blink. The number 20 is put here and decremented every jiffy until it
; reaches zero. Then the cursor state is changed, the number 20 is put back
; here, and the cycle starts all over again.

BLNCT                   = $CD           ; cursor timing countdown


; The cursor is formed by printing the inverse of the character that occupies
; the cursor position. If that characters is the letter A, for example, the
; flashing cursor merely alternates between printing an A and a reverse-A. This
; location keeps track of the normal screen code of the character that is
; located at the cursor position, so that it may be restored when the cursor
; moves on.

GDBLN                   = $CE           ; character under cursor


; This location keeps track of whether, during the current cursor blink, the
; character under the cursor was reversed, or was restored to normal. This
; location will contain $00 if the character is reversed, and $01 if the
; character is not reversed.

BLNON                   = $CF           ; cursor blink phase

CRSW                    = $D0           ; input from keyboard or screen, $xx = input is available
                                        ; from the screen, $00 = input should be obtained from the
                                        ; keyboard

; These locations point to the address in screen RAM of the first column of the
; logical line upon which the cursor is currently positioned.

CurScrLine              = $D1           ; current screen line pointer
; ... $D2


; This holds the cursor column position within the logical line pointed to by
; CurScrLine. Since a logical line can comprise up to four physical lines, this
; value may be from $00 to $57.

LineCurCol              = $D3           ; cursor column


; A nonzero value in this location indicates that the editor is in quote mode.
; Quote mode is toggled every time that you type in a quotation mark on a given
; line, the first quote mark turns it on, the second turns it off, the third
; turns it on, etc.

; If the editor is in this mode when a cursor control character or other
; nonprinting character is entered, a printed equivalent will appear on the
; screen instead of the cursor movement or other control operation taking
; place. Instead, that action is deferred until the string is sent to the
; string by a PRINT statement, at which time the cursor movement or other
; control operation will take place.

; The exception to this rule is the DELETE key, which will function normally
; within quote mode. The only way to print a character which is equivalent to
; the DELETE key is by entering insert mode. Quote mode may be exited by
; printing a closing quote or by hitting the RETURN or SHIFT-RETURN keys.

QTSW                    = $D4           ; cursor quote flag


; The line editor uses this location when the end of a line has been reached to
; determine whether another physical line can be added to the current logical
; line or if a new logical line must be started.

CurLineLeng             = $D5           ; current screen line length


; This location contains the current physical screen line position of the
; cursor, 0 to 22.

PhysCurRow              = $D6           ; cursor row

; The ASCII value of the last character printed to the screen is held here
; temporarily.

TEMPD7                  = $D7           ; checksum byte/temporary last character


; When the INST key is pressed, the screen editor shifts the line to the right,
; allocates another physical line to the logical line if necessary (and
; possible), updates the screen line length in $D5, and adjusts the screen line
; link table at $D9. This location is used to keep track of the number of
; spaces that has been opened up in this way.

; Until the spaces that have been opened up are filled, the editor acts as if
; in quote mode. See location $D4, the quote mode flag. This means that cursor
; control characters that are normally nonprinting will leave a printed
; equivalent on the screen when entered, instead of having their normal effect
; on cursor movement, etc. The only difference between insert and quote mode is
; that the DELETE key will leave a printed equivalent in insert mode, while the
; INSERT key will insert spaces as normal.

InsertCount             = $D8           ; insert count


; This table contains 25 entries, one for each row of the screen display. Each
; entry has two functions. Bits 0-3 indicate on which of the four pages of
; screen memory the first byte of memory for that row is located. This is used
; in calculating the pointer to the starting address of a screen line at .eq
; CurScrLine.
; The high byte is calculated by adding the value of the starting page of
; screen memory held in $288 to the displacement page held here.
;
; The other function of this table is to establish the makeup of logical lines
; on the screen. While each screen line is only 40 characters long, BASIC
; allows the entry of program lines that contain up to 80 characters.
; Therefore, some method must be used to determine which physical lines are
; linked into a longer logical line, so that this longer logical line may be
; edited as a unit.
; The high bit of each byte here is used as a flag by the screen editor. That
; bit is set when a line is the first or only physical line in a logical line.
; The high bit is reset to 0 only when a line is an extension to this logical
; line.

LDTB1                   = $D9           ; screen line link table
; ... $F1

ColorRamPtr             = $F3           ; colour RAM pointer
; ... $F4


; This pointer points to the address of the keyboard matrix lookup table
; currently being used. Although there are only 64 keys on the keyboard matrix,
; each key can be used to print up to four different characters, depending on
; whether it is struck by itself or in combination with the SHIFT, CTRL, or C=
; keys.

; These tables hold the ASCII value of each of the 64 keys for one of these
; possible combinations of keypresses. When it comes time to print the
; character, the table that is used determines which character is printed.

; The addresses of the tables are:

;       TblStandardKeys         ; unshifted
;       TblShiftKeys            ; shifted
;       TblCbmKeys                      ; commodore
;       TblControlKeys          ; control

KEYTAB                  = $F5           ; keyboard pointer
; ... $F6


; When device the RS232 channel is opened two buffers of 256 bytes each are
; created at the top of memory. These locations point to the address of the one
; which is used to store characters as they are received.

RIBUF                   = $F7           ; RS232 Rx pointer
; ... $F8


; These locations point to the address of the 256 byte output buffer that is
; used for transmitting data to RS232 devices.

ROBUF                   = $F9           ; RS232 Tx pointer
; ... $FA


StrConvAddr             = $FF           ; string conversion address

STACK                   = $0100         ; processor stack
; ... $01FF


; Input buffer. For some routines the byte before the input buffer needs to be
; set to a specific value for the routine to work correctly
CommandBuf              = $0200

LogFileTbl              = $0259         ; logical file table
; ... $0262

DevNumTbl               = $0263         ; device number table
; ... $026C

SecAddrTbl              = $026D         ; secondary address table
; ... $0276

KeyboardBuf             = $0277         ; keyboard buffer
; ... $0280

StartOfMem              = $0281         ; OS start of memory
; ... $0282

EndOfMem                = $0283         ; OS top of memory
; ... $0284

TIMOUT                  = $0285         ; serial bus timeout flag

COLOR                   = $0286         ; current colour code
                                        ; $00   black
                                        ; $01   white
                                        ; $02   red
                                        ; $03   cyan
                                        ; $04   magents
                                        ; $05   green
                                        ; $06   blue
                                        ; $07   yellow
                                        ; $08   orange
                                        ; $09   brown
                                        ; $0A   light red
                                        ; $0B   dark grey
                                        ; $0C   medium grey
                                        ; $0D   light green
                                        ; $0E   light blue
                                        ; $0F   light grey

GDCOL                   = $0287         ; colour under cursor
HIBASE                  = $0288         ; screen memory page
XMAX                    = $0289         ; maximum keyboard buffer size
RPTFLG                  = $028A         ; key repeat. $80 = repeat all, $40 = repeat none,
                                        ; $00 = repeat cursor movement keys, insert/delete
                                        ; key and the space bar
KOUNT                   = $028B         ; repeat speed counter
DELAY                   = $028C         ; repeat delay counter


; This flag signals which of the SHIFT, CTRL, or C= keys are currently being
; pressed.

; A value of $01 signifies that one of the SHIFT keys is being pressed, a $02
; shows that the C= key is down, and $04 means that the CTRL key is being
; pressed. If more than one key is held down, these values will be added e.g
; $03 indicates that SHIFT and C= are both held down.

; Pressing the SHIFT and C= keys at the same time will toggle the character set
; that is presently being used between the uppercase/graphics set, and the
; lowercase/uppercase set.

; While this changes the appearance of all of the characters on the screen at
; once it has nothing whatever to do with the keyboard shift tables and should
; not be confused with the printing of SHIFTed characters, which affects only
; one character at a time.

SHFLAG                  = $028D         ; keyboard shift/control flag
                                        ; bit   key(s) 1 = down
                                        ; ---   ---------------
                                        ; 7-3   unused
                                        ;  2    CTRL
                                        ;  1    C=
                                        ;  0    SHIFT


; This location, in combination with the one above, is used to debounce the
; special SHIFT keys. This will keep the SHIFT/C= combination from changing
; character sets back and forth during a single pressing of both keys.

LSTSHF                  = $028E         ; SHIFT/CTRL/C= keypress last pattern


; This location points to the address of the Operating System routine which
; actually determines which keyboard matrix lookup table will be used.

; The routine looks at the value of the SHIFT flag at $28D, and based on what
; value it finds there, stores the address of the correct table to use at
; location $F5.

KEYLOG                  = $028F         ; keyboard decode logic pointer
; ... $0290


; This flag is used to enable or disable the feature which lets you switch
; between the uppercase/graphics and upper/lowercase character sets by pressing
; the SHIFT and Commodore logo keys simultaneously.

MODE                    = $0291         ; shift mode switch, $00 = enabled, $80 = locked


; This location is used to determine whether moving the cursor past the ??xx 
; column of a logical line will cause another physical line to be added to the
; logical line.

; A value of 0 enables the screen to scroll the following lines down in order
; to add that line; any nonzero value will disable the scroll.

; This flag is set to disable the scroll temporarily when there are characters
; waiting in the keyboard buffer, these may include cursor movement characters
; that would eliminate the need for a scroll.

AUTODN                  = $0292         ; screen scrolling flag, $00 = enabled


M51CTR                  = $0293         ; pseudo 6551 control register. the first character of
                                        ; the OPEN RS232 filename will be stored here
                                        ; bit   function
                                        ; ---   --------
                                        ;  7    2 stop bits/1 stop bit
                                        ; 65    word length
                                        ; ---   -----------
                                        ; 00    8 bits
                                        ; 01    7 bits
                                        ; 10    6 bits
                                        ; 11    5 bits
                                        ;  4    unused
                                        ; 3210  baud rate
                                        ; ----  ---------
                                        ; 0000  user rate *
                                        ; 0001     50
                                        ; 0010     75
                                        ; 0011    110
                                        ; 0100    134.5
                                        ; 0101    150
                                        ; 0110    300
                                        ; 0111    600
                                        ; 1000   1200
                                        ; 1001   1800
                                        ; 1010   2400
                                        ; 1011   3600
                                        ; 1100   4800 *
                                        ; 1101   7200 *
                                        ; 1110   9600 *
                                        ; 1111  19200 * * = not implemented

M51CDR                  = $0294         ; pseudo 6551 command register. the second character of
                                        ; the OPEN RS232 filename will be stored here
                                        ; bit   function
                                        ; ---   --------
                                        ; 7-5   parity
                                        ;       xx0 = disabled
                                        ;       001 = odd
                                        ;       011 = even
                                        ;       101 = mark
                                        ;       111 = space
                                        ;  4    duplex half/full
                                        ;  3    unused
                                        ;  2    unused
                                        ;  1    unused
                                        ;  0    handshake - X line/3 line

M51AJB                  = $0295         ; nonstandard bit timing. the third
                                        ; character of the OPEN RS232 filename
                                        ; will be stored here
; ... $0296

RSSTAT                  = $0297         ; RS-232 status register
                                        ; bit   function
                                        ; ---   --------
                                        ;  7    break
                                        ;  6    no DSR detected
                                        ;  5    unused
                                        ;  4    no CTS detected
                                        ;  3    unused
                                        ;  2    Rx buffer overrun
                                        ;  1    framing error
                                        ;  0    parity error

BITNUM                  = $0298         ; number of bits to be sent/received
BAUDOF                  = $0299         ; bit time
; ... $029A


; Time Required to Send a Bit
;
; This location holds the prescaler value used by CIA #2 timers A and B.
; These timers cause an NMI interrupt to drive the RS-232 receive and transmit
; routines CLOCK/PRESCALER times per second each, where CLOCK is the system 02
; frequency of 1,022,730 Hz (985,250 if you are using the European PAL
; television standard rather than the American NTSC standard), and PRESCALER is
; the value stored at 56580-1 ($DD04-5) and 56582-3 ($DD06-7), in low-byte,
; high-byte order.  You can use the following formula to figure the correct
; prescaler value for a particular RS-232 baud rate:
;
; PRESCALER=((CLOCK/BAUDRATE)/2)-100
;
; The American (NTSC standard) prescaler values for the standard RS-232 baud
; rates which the control register at 659 ($293) makes available are stored in
; a table at 65218 ($FEC2), starting with the two-byte value used for 50 baud.
; The European (PAL standard) version of that table is located at 58604
; ($E4EC).
; Location Range: 667-670 ($29B-$29E)
; Byte Indices to the Beginning and End of Receive and Transmit Buffers
;
; The two 256-byte First In, First Out (FIFO) buffers for RS-232 data reception
; and transmission are dynamic wraparound buffers.  This means that the
; starting point and the ending point of the buffer can change over time, and
; either point can be anywhere withing the buffer.  If, for example, the
; starting point is at byte 100, the buffer will fill towards byte 255, at
; which point it will wrap around to byte 0 again.  To maintain this system,
; the following four locations are used as indices to the starting and the
; ending point of each buffer.

RIDBE                   = $029B         ; index to Rx buffer end
RIDBS                   = $029C         ; index to Rx buffer start
RODBE                   = $029D         ; index to Tx buffer start
RODBS                   = $029E         ; index to Tx buffer end

IRQTMP                  = $029F         ; saved IRQ
; ... $02A0


; This location holds the active NMI interrupt flag byte from CIA 2 ICR, .eq
; CIA2IRQ

ENABL                   = $02A1         ; RS-232 interrupt enable byte
                                        ; bit   function
                                        ; ---   --------
                                        ;  7    unused
                                        ;  6    unused
                                        ;  5    unused
                                        ;  4    1 = waiting for Rx edge
                                        ;  3    unused
                                        ;  2    unused
                                        ;  1    1 = Rx data timer
                                        ;  0    1 = Tx data timer

Copy6522CRB             = $02A2         ; CIA 1 CRB shadow copy
Copy6522ICR             = $02A3         ; CIA 1 ICR shadow copy
Copy6522CRA             = $02A4         ; CIA 1 CRA shadow copy

TmpLineScrl             = $02A5         ; temp Index to the next line for scrolling

PALNTSC                 = $02A6         ; PAL/NTSC flag
                                        ; $00 = NTSC
                                        ; $01 = PAL

; $02A7 to $02FF - unused

IERROR                  = $0300         ; vector to the print BASIC error message routine
IMAIN                   = $0302         ; Vector to the main BASIC program Loop
ICRNCH                  = $0304         ; Vector to the the ASCII text to keywords routine
IQPLOP                  = $0306         ; Vector to the list BASIC program as ASCII routine
IGONE                   = $0308         ; Vector to the execute next BASIC command routine
IEVAL                   = $030A         ; Vector to the get value from BASIC line routine

; Before every SYS command each of the registers is loaded with the value found
; in the corresponding storage address. Upon returning to BASIC with an RTS
; instruction, the new value of each register is stored in the appropriate
; storage address.

; This feature allows you to place the necessary values into the registers from
; BASIC before you SYS to a Kernal or BASIC ML routine. It also enables you to
; examine the resulting effect of the routine on the registers, and to preserve
; the condition of the registers on exit for subsequent SYS calls.

SAREG                   = $030C         ; A for SYS command
SXREG                   = $030D         ; X for SYS command
SYREG                   = $030E         ; Y for SYS command
SPREG                   = $030F         ; P for SYS command

UserJump                = $0310         ; JMP instruction for user function

USRADD                  = $0311         ; user function vector
; ... $0312

CINV                    = $0314         ; IRQ vector
BINV                    = $0316         ; BRK vector
NMINV                   = $0318         ; NMI vector
IOPEN                   = $031A         ; kernal vector - open a logical file
ICLOSE                  = $031C         ; kernal vector - close a specified logical file
ICHKIN                  = $031E         ; kernal vector - open channel for input
ICKOUT                  = $0320         ; kernal vector - open channel for output
ICLRCH                  = $0322         ; kernal vector - close input and output channels
IBASIN                  = $0324         ; kernal vector - input character from channel
IBSOUT                  = $0326         ; kernal vector - output character to channel
ISTOP                   = $0328         ; kernal vector - scan stop key
IGETIN                  = $032A         ; kernal vector - get character from keyboard queue
ICLALL                  = $032C         ; kernal vector - close all channels and files
; ???
ILOAD                   = $0330         ; kernal vector - load
ISAVE                   = $0332         ; kernal vector - save

TapeBuffer              = $033C         ; cassette buffer


RomStart                = $8000         ; autostart ROM initial entry vector
RomIRQ                  = $8002         ; autostart ROM break entry
RomIdentStr             = $8004         ; autostart ROM identifier string start


VIC_chip                = $D000         ; vic ii chip base address
VICCTR1                 = $D011         ; vertical fine scroll and control
VICLINE                 = $D012         ; raster compare register
VICLPX                  = $D013         ; lightpen, X position 
VICLPY                  = $D014         ; lightpen, Y position 
VICSPEN                 = $D015         ; enable sprites, 1 = on
VICCTR2                 = $D016         ; horizontal fine scroll and control
VICRAM                  = $D018         ; memory control
VICESPV                 = $D017         ; enlarge sprites vertical * 2
VICIRQ                  = $D019         ; vic interrupt flag register
VICBOCL                 = $D020         ; border color
VICBAC0                 = $D021         ; backgroundcolor 0

SIDFMVO                 = $D418         ; volume and filter select

ColourRAM               = $D800         ; 1K colour RAM base address


; CIA 1

CIA1DRA                 = $DC00         ; CIA 1 DRA, keyboard column drive
CIA1DRB                 = $DC01         ; CIA 1 DRB, keyboard row port
                                        ;   keyboard matrix layout
                                        ; keyboard matrix layout
                                        ;       c7      c6      c5      c4      c3      c2      c1      c0
                                        ;   +----------------------------------------------------------------
                                        ; r7|   [RUN]   /       ,       N       V       X       [LSH]   [DN]
                                        ; r6|   Q       [UP]    @       O       U       T       E       [F5]
                                        ; r5|   [CBM]= :        K       H       F       S       [F3]
                                        ; r4|   [SP]    [RSH]   .       M       B       C       Z       [F1]
                                        ; r3|   2       [Home]- 0       8       6       4       [F7]
                                        ; r2|   [CTL]   ;       L       J       G       D       A       [RGT]
                                        ; r1|   [LFT]   *       P       I       Y       R       W       [RET]
                                        ; r0|   1       £      +       9       7       5       3       [DEL]
CIA1DDRA                = $DC02         ; CIA 1 DDRA, keyboard column
CIA1DDRB                = $DC03         ; CIA 1 DDRB, keyboard row
CIA1TI1L                = $DC04         ; CIA 1 timer A low byte
CIA1TI1H                = $DC05         ; CIA 1 timer A high byte
CIA1TI2L                = $DC06         ; CIA 1 timer B low byte
CIA1TI2H                = $DC07         ; CIA 1 timer B high byte
CIA1IRQ                 = $DC0D         ; CIA 1 ICR
                                        ; bit   function
                                        ; ---   --------
                                        ;  7    interrupt
                                        ;  6    unused
                                        ;  5    unused
                                        ;  4    FLAG
                                        ;  3    shift register
                                        ;  2    TOD alarm
                                        ;  1    timer B
                                        ;  0    timer A
CIA1CTR1                = $DC0E         ; CIA 1 CRA
                                        ; bit   function
                                        ; ---   --------
                                        ;  7    TOD clock, 1 = 50Hz, 0 = 60Hz
                                        ;  6    serial port direction, 1 = out, 0 = in
                                        ;  5    timer A input, 1 = phase2, 0 = CNT in
                                        ;  4    1 = force load timer A
                                        ;  3    timer A mode, 1 = single shot, 0 = continuous
                                        ;  2    PB6 mode, 1 = toggle, 0 = single shot
                                        ;  1    1 = timer A to PB6
                                        ;  0    1 = start timer A
CIA1CTR2                = $DC0F         ; CIA 1 CRB
                                        ; bit   function
                                        ; ---   --------
                                        ;  7    TOD register select, 1 = clock, 0 = alarm
                                        ; 6-5   timer B mode
                                        ;     11 = timer A with CNT enable
                                        ;     10 = timer A
                                        ;     01 = CNT in
                                        ;     00 = phase 2
                                        ;  4    1 = force load timer B
                                        ;  3    timer B mode, 1 = single shot, 0 = continuous
                                        ;  2    PB7 mode, 1 = toggle, 0 = single shot
                                        ;  1    1 = timer B to PB7
                                        ;  0    1 = start timer B


; CIA 2

CIA2DRA                 = $DD00         ; CIA 2 DRA, serial port and video address
                                        ; bit   function
                                        ; ---   --------
                                        ;  7    serial DATA in
                                        ;  6    serial CLK in
                                        ;  5    serial DATA out
                                        ;  4    serial CLK out
                                        ;  3    serial ATN out
                                        ;  2    RS232 Tx DATA
                                        ;  1    video address 15
                                        ;  0    video address 14
CIA2DRB                 = $DD01         ; CIA 2 DRB, RS232 port
                                        ; bit   function
                                        ; ---   --------
                                        ;  7    RS232 DSR
                                        ;  6    RS232 CTS
                                        ;  5    unused
                                        ;  4    RS232 DCD
                                        ;  3    RS232 RI
                                        ;  2    RS232 DTR
                                        ;  1    RS232 RTS
                                        ;  0    RS232 Rx DATA
CIA2DDRA                = $DD02         ; CIA 2 DDRA, serial port and video address
CIA2DDRB                = $DD03         ; CIA 2 DDRB, RS232 port
CIA2TI1L                = $DD04         ; CIA 2 timer A low byte
CIA2TI1H                = $DD05         ; CIA 2 timer A high byte
CIA2TI2L                = $DD06         ; CIA 2 timer B low byte
CIA2TI2H                = $DD07         ; CIA 2 timer B high byte
CIA2IRQ                 = $DD0D         ; CIA 2 ICR
                                        ; bit   function
                                        ; ---   --------
                                        ;  7    interrupt
                                        ;  6    unused
                                        ;  5    unused
                                        ;  4    FLAG
                                        ;  3    shift register
                                        ;  2    TOD alarm
                                        ;  1    timer B
                                        ;  0    timer A
CIA2CTR1                = $DD0E         ; CIA 2 CRA
                                        ; bit   function
                                        ; ---   --------
                                        ;  7    TOD clock, 1 = 50Hz, 0 = 60Hz
                                        ;  6    serial port direction, 1 = out, 0 = in
                                        ;  5    timer A input, 1 = phase2, 0 = CNT in
                                        ;  4    1 = force load timer A
                                        ;  3    timer A mode, 1 = single shot, 0 = continuous
                                        ;  2    PB6 mode, 1 = toggle, 0 = single shot
                                        ;  1    1 = timer A to PB6
                                        ;  0    1 = start timer A
CIA2CTR2                = $DD0F         ; CIA 2 CRB
                                        ; bit   function
                                        ; ---   --------
                                        ;  7    TOD register select, 1 = clock, 0 = alarm
                                        ; 6-5   timer B mode
                                        ;     11 = timer A with CNT enable
                                        ;     10 = timer A
                                        ;     01 = CNT in
                                        ;     00 = phase 2
                                        ;  4    1 = force load timer B
                                        ;  3    timer B mode, 1 = single shot, 0 = continuous
                                        ;  2    PB7 mode, 1 = toggle, 0 = single shot
                                        ;  1    1 = timer B to PB7
                                        ;  0    1 = start timer B


;******************************************************************************
;
; BASIC keyword token values. tokens not used in the source are included for
; completeness but commented out

; command tokens

; TK_END        = $80                   ; END token
TK_FOR                  = $81           ; FOR token
; TK_NEXT       = $82                   ; NEXT token
TK_DATA                 = $83           ; DATA token
; TK_INFL       = $84                   ; INPUT# token
; TK_INPUT      = $85                   ; INPUT token
; TK_DIM        = $86                   ; DIM token
; TK_READ       = $87                   ; READ token

; TK_LET        = $88                   ; LET token
TK_GOTO                 = $89           ; GOTO token
; TK_RUN        = $8A                   ; RUN token
; TK_IF         = $8B                   ; IF token
; TK_RESTORE    = $8C                   ; RESTORE token
TK_GOSUB                = $8D           ; GOSUB token
; TK_RETURN     = $8E                   ; RETURN token
TK_REM                  = $8F           ; REM token

; TK_STOP       = $90                   ; STOP token
; TK_ON         = $91                   ; ON token
; TK_WAIT       = $92                   ; WAIT token
; TK_LOAD       = $93                   ; LOAD token
; TK_SAVE       = $94                   ; SAVE token
; TK_VERIFY     = $95                   ; VERIFY token
; TK_DEF        = $96                   ; DEF token
; TK_POKE       = $97                   ; POKE token

; TK_PRINFL     = $98                   ; PRINT# token
TK_PRINT                = $99           ; PRINT token
; TK_CONT       = $9A                   ; CONT token
; TK_LIST       = $9B                   ; LIST token
; TK_CLR        = $9C                   ; CLR token
; TK_CMD        = $9D                   ; CMD token
; TK_SYS        = $9E                   ; SYS token
; TK_OPEN       = $9F                   ; OPEN token

; TK_CLOSE      = $A0                   ; CLOSE token
; TK_GET        = $A1                   ; GET token
; TK_NEW        = $A2                   ; NEW token

; secondary keyword tokens

TK_TAB                  = $A3           ; TAB( token
TK_TO                   = $A4           ; TO token
TK_FN                   = $A5           ; FN token
TK_SPC                  = $A6           ; SPC( token
TK_THEN                 = $A7           ; THEN token

TK_NOT                  = $A8           ; NOT token
TK_STEP                 = $A9           ; STEP token

; operator tokens

TK_PLUS                 = $AA           ; + token
TK_MINUS                = $AB           ; - token
; TK_MUL        = $AC                   ; * token
; TK_DIV        = $AD                   ; / token
; TK_POWER      = $AE                   ; ^ token
; TK_AND        = $AF                   ; AND token

; TK_OR         = $B0                   ; OR token
TK_GT                   = $B1           ; > token
TK_EQUAL                = $B2           ; = token
; TK_LT         = $B3                   ; < token

; function tokens

TK_SGN                  = $B4           ; SGN token
; TK_INT        = $B5                   ; INT token
; TK_ABS        = $B6                   ; ABS token
; TK_USR        = $B7                   ; USR token

; TK_FRE        = $B8                   ; FRE token
; TK_POS        = $B9                   ; POS token
; TK_SQR        = $BA                   ; SQR token
; TK_RND        = $BB                   ; RND token
; TK_LOG        = $BC                   ; LOG token
; TK_EXP        = $BD                   ; EXP token
; TK_COS        = $BE                   ; COS token
; TK_SIN        = $BF                   ; SIN token

; TK_TAN        = $C0                   ; TAN token
; TK_ATN        = $C1                   ; ATN token
; TK_PEEK       = $C2                   ; PEEK token
; TK_LEN        = $C3                   ; LEN token
; TK_STRS       = $C4                   ; STR$ token
; TK_VAL        = $C5                   ; VAL token
; TK_ASC        = $C6                   ; ASC token
; TK_CHRS       = $C7                   ; CHR$ token

; TK_LEFTS      = $C8                   ; LEFT$ token
; TK_RIGHTS     = $C9                   ; RIGHT$ token
; TK_MIDS       = $CA                   ; MID$ token
TK_GO                   = $CB           ; GO token

TK_PI                   = $FF           ; PI token


