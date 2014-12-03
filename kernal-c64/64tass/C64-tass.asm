;******************************************************************************
;******************************************************************************
;
; The almost completely commented C64 ROM disassembly. V1.01 Lee Davison 2012
;
; Changed by Ruud Baltissen 2014
; - changed names of routines and variables, LAzB_xx and LAzB_xxxx,
;   into more logical ones
; - length of lines < 81 (if possible)
; - combined low and high bytes to one variable
; - corrected some small errors

; This is a bit correct assembly listing for the C64 BASIC and kernal ROMs
; as two 8K ROMs. You should be able to assemble the C64 ROMs from this with
; most 6502 assemblers, as no macros or 'special' features were used. This has
; been tested using Michal Kowalski's 6502 Simulator assemble function.
; See http://exifpro.com/utils.html for this program.

; Many references were used to complete this disassembly including, but not
; limited to, "Mapping the Vic 20", "Mapping the C64", "C64 Programmers
; reference", "C64 user guide", "The complete Commodore inner space anthology",
; "VIC Revealed" and various text files, pictures and other documents.


;******************************************************************************
;******************************************************************************
;
; first a whole load of equates

D6510			= $00		; 6510 I/O port data direction register
					; bit	default
					; ---	-------
					;  7	unused
					;  6	unused
					;  5	1 = output
					;  4	0 = input
					;  3	1 = output
					;  2	1 = output
					;  1	1 = output
					;  0	1 = output

P6510			= $01		; 6510 I/O port data register
					; bit	name		function
					; ---	----		--------
					;  7	unused
					;  6	unused
					;  5	cass motor 1 = off, 0 = on
					;  4	cass sw	   1 = off, 0 = on
					;  3	cass data
					;  2	CHAREN	   1 = I/O,
					;		   0 = chraracter ROM
					;  1	HIRAM	1 = Kernal,	0 = RAM
					;  0	LORAM	1 = BASIC,	0 = RAM

ZP02			= $02		; unused

; This vector points to the address of the BASIC routine which converts a
; floating point number to an integer, however BASIC does not use this vector.
; It may be of assistance to the programmer who wishes to use data that is;
; stored in floating point format. The parameter passed by the USR command is
; available only in that format for example.

ADRAY1			= $03		; float to fixed vector
; ... $04


; This vector points to the address of the BASIC routine which converts an
; integer to a floating point number, however BASIC does not use this vector.
; It may be used by the programmer who needs to make such a conversion for a
; machine language program that interacts with BASIC.  To return an integer
; value with the USR command for example.

ADRAY2			= $05		; fixed to float vector
; ... $06


; These locations hold searched for characters when BASIC is searching for the
; end of a srting or crunching BASIC lines

CHARAC			= $07		; search character
ENDCHR			= $08		; scan quotes flag


; The cursor column position prior to the TAB or SPC is moved here from $D3,
; and is used to calculate where the cursor ends up after one of these
; functions is invoked.

; Note that the value contained here shows the position of the cursor on a
; logical line. Since one logical line can be up to four physical lines long,
; the value stored here can range from 0 to 87.

TRMPOS			= $09		; TAB column save


; The routine that converts the text in the input buffer into lines of
; executable program tokes, and the routines that link these program lines
; together, use this location as an index into the input buffer area. After the
; job of converting text to tokens is done, the value in this location is equal
; to the length of the tokenized line.

; The routines which build an array or locate an element in an array use this
; location to calculate the number of DIMensions called for and the amount of
; storage required for a newly created array, or the number of subscripts when
; referencing an array element.

LoadVerify		= $0A		; load/verify flag, 0 = load, 1 = verify
COUNT			= $0B		; temporary byte, line crunch/array
					; access/logic operators

; This is used as a flag by the routines that build an array or reference an
; existing array. It is used to determine whether a variable is in an array,
; whether the array has already been DIMensioned, and whether a new array
; should assume the default size.

DIMFLG			= $0C		; DIM flag


; This flag is used to indicate whether data being operated upon is string or
; numeric. A value of $FF in this location indicates string data while a $00
; indicates numeric data.

VALTYP			= $0D		; data type flag, $FF = string,
					;		  $00 = numeric

; If the above flag indicates numeric then a $80 in this location identifies
; the number as an integer, and a $00 indicates a floating point number.

INTFLG			= $0E		; data type flag, $80 = integer,
					;		  $00 = floating point

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

GARBFL			= $0F		; garbage collected/open quote/DATA flag


; If an opening parenthesis is found, this flag is set to indicate that the
; variable in; question is either an array variable or a user-defined function.

SUBFLG			= $10		; subscript/FNx flag


; This location is used to determine whether the sign of the value returned by
; the functions SIN, COS, ATN or TAN is positive or negative.

; Also the comparison routines use this location to indicate the outcome of the
; compare. For A <=> B the value here will be $01 if A > B, $02 if A = B, and
; $04 if A < B. If more than one comparison operator was used to compare the
; two variables then the value here will be a combination of the above values.

INPFLG			= $11		; input mode flag, $00 = INPUT,
					; $40 = GET, $98 = READ
TANSGN			= $12		; ATN sign/comparison evaluation flag


; When the default input or output device is used the value here will be a
; zero, and the format of prompting and output will be the standard screen
; output format. The location $B8 is used to decide what device actually to
; put input from or output to.

CurIoChan		= $13		; current I/O channel


; Used whenever a 16 bit integer is used e.g. the target line number for GOTO,
; LIST, ON, and GOSUB also the number of a BASIC line that is to be added or
; replaced. additionally PEEK, POKE, WAIT, and SYS use this location as a
; pointer to the address which is the subject of the command.

LINNUM			= $14		; temporary integer
; ... $15

LINNUMJ			= $0014		; used with SYS: JMP ($0014)


; This location points to the next available slot in the temporary string
; descriptor stack located at $19-$21.

TEMPPT			= $16		; descriptor stack pointer, next free


; This contains information about temporary strings which have not yet been
; assigned to a string variable.

LASTPT			= $17		; current descriptor stack item
; ... $18

TEMST			= $19		; stack for temporary strings
; ... $21

; These locations are used by BASIC multiplication and division routines. They
; are also used by the routines which compute the size of the area required to
; store an array which is being created.

INDEX			= $22		; misc temp byte
; ... $25

RESHO			= $26		; temp mantissa 1
; ... $29


; Two byte pointer to where the BASIC program text is stored.

TXTTAB			= $2B		; start of memory
; ... $2C


; Two byte pointer to the start of the BASIC variable storage area.

VARTAB			= $2D		; start of variables
; ... $2E


; Two byte pointer to the start of the BASIC array storage area.

ARYTAB			= $2F		; end of variables
; ... $30


; Two byte pointer to end of the start of free RAM.

STREND			= $31		; end of arrays
; ... $32


; Two byte pointer to the bottom of the string text storage area.

FRETOP			= $33		; bottom of string space
; ... $34


; Used as a temporary pointer to the most current string added by the routines
; which build strings or move them in memory.

FRESPC			= $35		; string utility ptr
; ... $36


; Two byte pointer to the highest address used by BASIC +1.

MEMSIZ			= $37		; end of memory
; ... $38


; These locations contain the line number of the BASIC statement which is
; currently being executed. A value of $FF in location $3A means that BASIC is
; in immediate mode.

CURLIN			= $39		; current line number
; ... $3A


; When program execution ends or stops the last line number executed is stored
; here.

OLDLIN			= $3B		; break line number
; ... $3C


; These locations contain the address of the start of the text of the BASIC
; statement that is being executed.  The value of the pointer to the address of
; the BASIC text character currently being scanned is stored here each time a
; new BASIC statement begins execution.

OLDTXT			= $3D		; continue pointer
; ... $3E


; These locations hold the line number of the current DATA statement being
; READ. If an error concerning the DATA occurs this number will be moved to
; $39/$3A so that the error message will show the line that contains the DATA
; statement rather than in the line that contains the READ statement.

DATLIN			= $3F		; current DATA line number
; ... $40


; These locations point to the address where the next DATA will be READ from.
; RESTORE; sets this pointer back to the address indicated by the start of
; BASIC pointer.

DATPTR			= $41		; DATA pointer
; ... $42


; READ, INPUT and GET all use this as a pointer to the address of the source of
; incoming data, such as DATA statements, or the text input buffer.

INPPTR			= $43		; READ pointer
; ... $44

VARNAM			= $45		; current variable name
; ... $46


; These locations point to the value of the current BASIC variable Specifically
; they point to the byte just after the two-character variable name.

VARPNT			= $47		; current variable address
; ... $48


; The address of the BASIC variable which is the subject of a FOR/NEXT loop is
; first stored here before being pushed onto the stack.

FORPNT			= $49		; FOR/NEXT variable pointer
; ... $4A


; The expression evaluation routine creates this to let it know whether the
; current comparison operation is a < $01, = $02 or > $04 comparison or
; combination.

TEMPSTR			= $4B		; BASIC execute pointer temporary
					; /precedence flag
; ... $4C

CompEvalFlg		= $4D		; comparrison evaluation flag


; These locations are used as a pointer to the function that is created during
; function definition . During function execution it points to where the
; evaluation results should be saved.

GarbagePtr		= $4E		; FAC temp store/function/variable
					;   /garbage pointer
; ... $4F


; Temporary Pointer to the current string descriptor.

TempPtr			= $50		; FAC temp store/descriptor pointer
; ... $51

GarbColStep		= $53		; garbage collection step size


; The first byte is the 6502 JMP instruction $4C, followed by the address of
; the required function taken from the table at $C052.

Jump0054		= $54		; JMP opcode for functions
					; $0054 normally contains $4C = JMP
; ... $56

FacTempStor		= $57		; FAC temp store
; ... $60


; floating point accumulator 1

FACEXP			= $61		; FAC1 exponent
FacMantissa		= $62		; FAC1 mantissa 1
; ... $65
FACSGN			= $66		; FAC1 sign
SGNFLG			= $67		; constant count/-ve flag
BITS			= $68		; FAC1 overflow


; floating point accumulator 2

ARGEXP			= $69		; FAC2 exponent
ArgMantissa		= $6A		; FAC2 mantissa 1
; ... $6D
ARGSGN			= $6E		; FAC2 sign
ARISGN			= $6F		; FAC sign comparrison
FACOV			= $70		; FAC1 rounding

FBUFPT			= $71		; temp BASIC execute/array pointer
					;   /index
; ... $72


CHRGET			= $73		; increment and scan memory, BASIC byte get
CHRGOT			= $79		; scan memory, BASIC byte get

TXTPTR			= $7A		; BASIC execute pointer
; ... $7B

NumericTest		= $80		; numeric test entry

RND_seed		= $8B		; RND() seed, five bytes
; ... $8F


; kernal work area

STATUS			= $90		; serial status byte
					;	function
					; bit	casette		serial bus
					; ---	--------	----------
					;  7	end of tape	device not present
					;  6	end of file	EOI
					;  5	checksum error
					;  4	read error
					;  3	long block
					;  2	short block
					;  1			time out read
					;  0			time out write


; This location is updated every 1/60 second during the IRQ routine. The value
; saved is the keyboard c7 column byte which contains the stop key

StopKey			= $91		; stop key column
					; bit	key, 0 = pressed
					; ---	--------
					;  7	[RUN]
					;  6	Q
					;  5	[CBM]
					;  4	[SP]
					;  3	2
					;  2	[CTL]
					;  1	[LFT]
					;  0	1


; This location is used as an adjustable timing constant for tape reads to
; allow for slight speed variations on tapes.

SVXT			= $92		; timing constant for tape read


; The same routine is used for both LOAD and VERIFY, the flag here determines
; which that routine does.

LoadVerify2		= $93		; load/verify flag, load = $00,
					;		    verify = $01


; This location is used to indecate that a serial byte is waiting to be sent.

C3PO			= $94		; serial output: deferred character flag
					; $00 = no character waiting,
					; $xx = character waiting


; This location holds the serial character waiting to be sent. A value of $FF
; here means no character is waiting.

BSOUR			= $95		; serial output: deferred character
					; $FF = no character waiting,
					; $xx = waiting character

SYNO			= $96		; cassette block synchronization number


; X register save location for routines that get and put an ASCII character.

TEMP97			= $97		; X register save


; The number of currently open I/O files is stored here. The maximum number
; that can be open at one time is ten. The number stored here is used as the
; index to the end of the tables that hold the file numbers, device numbers,
; and secondary addresses.

LDTND			= $98		; open file count


; The default value of this location is 0, the keyboard.

DFLTN			= $99		; input device number


; The default value of this location is 3, the screen.

DFLTO			= $9A		; output device number
					; number	device
					; ------	------
					;  0		keyboard
					;  1		cassette
					;  2		RS-232C
					;  3		screen
					;  4-31	serial bus


PRTY			= $9B		; tape character parity
DPSW			= $9C		; tape byte received flag

MSGFLG			= $9D		; message mode flag,
					; $C0 = both control and kernal messages,
					; $80 = control messages only = direct mode
					; $40 = kernal messages only,
					; $00 = neither control or kernal messages
					;     = program mode

PTR1			= $9E		; tape Pass 1 error log/character buffer

PTR2			= $9F		; tape Pass 1 error log/character index


; These three locations form a counter which is updated 60 times a second, and
; serves as a software clock which counts the number of jiffies that have
; elapsed since the computer was turned on. After 24 hours and one jiffy these
; locations are set back to $000000.

TimeBytes		= $A0		; jiffy clock high byte
; ... $A2


TEMPA3			= $A3		; EOI flag byte/tape bit count

; b0 of this location reflects the current phase of the tape output cycle.

TEMPA4			= $A4		; tape bit cycle phase
CNTDN			= $A5		; cassette synchronization byte count/
					;   serial bus bit count

BUFPNT			= $A6		; tape buffer index
INBIT			= $A7		; receiver input bit temp storage
BITCI			= $A8		; receiver bit count in
RINONE			= $A9		; receiver start bit check flag,
					; $90 = no start bit
					; received, $00 = start bit received
RIDATA			= $AA		; receiver byte buffer/assembly location
RIPRTY			= $AB		; receiver parity bit storage

SAL			= $AC		; tape buffer start pointer
					; scroll screen ?? byte
; ... $AD

EAL			= $AE		; tape buffer end pointer
					; scroll screen ?? byte
; ... $AF

CMPO			= $B0		; tape timing constant
; ... $B1


; Thess two locations point to the address of the cassette buffer. This pointer
; must be greater than or equal to $0200 or an ILLEGAL DEVICE NUMBER error will
; be sent when tape I/O is tried. This pointer must also be less that $8000 or
; the routine will terminate early.

TapeBufPtr		= $B2		; tape buffer start pointer
; ... $B3


; RS232 routines use this to count the number of bits transmitted and for
; parity and stop bit manipulation. Tape load routines use this location to
; flag when they are ready to receive data bytes.

BITTS			= $B4		; transmitter bit count out


; This location is used by the RS232 routines to hold the next bit to be sent
; and by the tape routines to indicate what part of a block the read routine is
; currently reading.

NXTBIT			= $B5		; transmitter next bit to be sent


; RS232 routines use this area to disassemble each byte to be sent from the
; transmission buffer pointed to by $F9.

RODATA			= $B6		; transmitter byte buffer/disassembly
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

FNLEN			= $B7		; filename length

LA			= $B8		; logical file
SA			= $B9		; secondary address
FA			= $BA		; current device number
					; number	device
					; ------	------
					;  0		keyboard
					;  1		cassette
					;  2		RS-232C
					;  3		screen
					;  4-31	serial bus

FNADR			= $BB		; filename pointer
; ... $BC

ROPRTY			= $BD		; tape write byte/RS232 parity byte


; Used by the tape routines to count the number of copies of a data block
; remaining to be read or written.

FSBLK			= $BE		; tape copies count

MYCH			= $BF		; tape parity count

CAS1			= $C0		; tape motor interlock

STAL			= $C1		; I/O start addresses
; ... $C2

MEMUSS			= $C3		; kernal setup pointer
; ... $C4

LSTX			= $C5		; current key pressed
					;
					;  # key	 # key
					; -- ---	-- ---
					; 00 1		10 none
					; 01 3		11 A
					; 02 5		12 D
					; 03 7		13 G
					; 04 9		14 J
					; 05 +		15 L
					; 06 [UKP]	16 ;
					; 07 [DEL]	17 [CSR R]
					; 08 [<-]	18 [STOP]
					; 09 W		19 none
					; 0A R		1A X
					; 0B Y		1B V
					; 0C I		1C N
					; 0D P		1D ,
					; 0E *		1E /
					; 0F [RET]	1F [CSR D]

					; 20 [SPACE]	30 Q
					; 21 Z		31 E
					; 22 C		32 T
					; 23 B		33 U
					; 24 M		34 O
					; 25 .		35 @
					; 26 none	36 ^
					; 27 [F1]	37 [F5]
					; 28 none	38 2
					; 29 S		39 4
					; 2A F		3A 6
					; 2B H		3B 8
					; 2C K		3C 0
					; 2D :		3D -
					; 2E =		3E [HOME]
					; 2F [F3]	3F [F7]


NDX			= $C6		; keyboard buffer length/index


; When the [CTRL][RVS-ON] characters are printed this flag is set to $12, and
; the print; routines will add $80 to the screen code of each character which
; is printed, so that the caracter will appear on the screen with its colours
; reversed.

; Note that the contents of this location are cleared not only upon entry of a
; [CTRL][RVS-OFF] character but also at every carriage return.

RVS			= $C7		; reverse flag $12 = reverse, $00 = normal


; This pointer indicates the column number of the last nonblank character on
; the logical line that is to be input. Since a logical line can be up to 88
; characters long this number can range from 0-87.

INDX			= $C8		; input [EOL] pointer


; These locations keep track of the logical line that the cursor is on and its
; column position on that logical line.

; Each logical line may contain up to four 22 column physical lines. So there
; may be as many as 23 logical lines, or as few as 6 at any one time.
; Therefore, the logical line number might be anywhere from 1-23. Depending on
; the length of the logical line, the cursor column may be from 1-22, 1-44,
; 1-66 or 1-88.

; For a more on logical lines, see the description of the screen line link
; table, $D9.

CursorRow		= $C9		; input cursor row
CursorCol		= $CA		; input cursor column


; The keyscan interrupt routine uses this location to indicate which key is
; currently being pressed. The value here is then used as an index into the
; appropriate keyboard; table to determine which character to print when a key
; is struck.

; The correspondence between the key pressed and the number stored here is as
; follows:

; $00	1		$10	not used	$20	[SPACE]		$30	Q	$40	[NO KEY]
; $01	3		$11	A		$21	Z		$31	E	$xx	invalid
; $02	5		$12	D		$22	C		$32	T
; $03	7		$13	G		$23	B		$33	U
; $04	9		$14	J		$24	M		$34	O
; $05	+		$15	L		$25	.		$35	@
; $06	[POUND]		$16	;		$26	not used	$36	[U ARROW]
; $07	[DEL]		$17	[RIGHT]		$27	[F1]		$37	[F5]
; $08	[L ARROW]	$18	[STOP]		$28	not used	$38	2
; $09	W		$19	not used	$29	S		$39	4
; $0A	R		$1A	X		$2A	F		$3A	6
; $0B	Y		$1B	V		$2B	H		$3B	8
; $0C	I		$1C	N		$2C	K		$3C	0
; $0D	P		$1D	,		$2D	:		$3D	-
; $0E	*		$1E	/		$2E	=		$3E	[HOME]
; $0F	[RETURN]	$1F	[DOWN]		$2F	[F3]		$3F	[F7]

SFDX			= $CB		; which key


; When this flag is set to a nonzero value, it indicates to the routine that
; normally flashes the cursor not to do so. The cursor blink is turned off when
; there are characters in the keyboard buffer, or when the program is running.

BLNSW			= $CC		; cursor enable, $00 = flash cursor


; The routine that blinks the cursor uses this location to tell when it's time
; for a blink. The number 20 is put here and decremented every jiffy until it
; reaches zero. Then the cursor state is changed, the number 20 is put back
; here, and the cycle starts all over again.

BLNCT			= $CD		; cursor timing countdown


; The cursor is formed by printing the inverse of the character that occupies
; the cursor position. If that characters is the letter A, for example, the
; flashing cursor merely alternates between printing an A and a reverse-A. This
; location keeps track of the normal screen code of the character that is
; located at the cursor position, so that it may be restored when the cursor
; moves on.

GDBLN			= $CE		; character under cursor


; This location keeps track of whether, during the current cursor blink, the
; character under the cursor was reversed, or was restored to normal. This
; location will contain $00 if the character is reversed, and $01 if the
; character is not reversed.

BLNON			= $CF		; cursor blink phase

CRSW			= $D0		; input from keyboard or screen, $xx = input is available
					; from the screen, $00 = input should be obtained from the
					; keyboard

; These locations point to the address in screen RAM of the first column of the
; logical line upon which the cursor is currently positioned.

CurScrLine		= $D1		; current screen line pointer
; ... $D2


; This holds the cursor column position within the logical line pointed to by
; CurScrLine. Since a logical line can comprise up to four physical lines, this
; value may be from $00 to $57.

LineCurCol		= $D3		; cursor column


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

QTSW			= $D4		; cursor quote flag


; The line editor uses this location when the end of a line has been reached to
; determine whether another physical line can be added to the current logical
; line or if a new logical line must be started.

CurLineLeng		= $D5		; current screen line length


; This location contains the current physical screen line position of the
; cursor, 0 to 22.

PhysCurRow		= $D6		; cursor row

; The ASCII value of the last character printed to the screen is held here
; temporarily.

TEMPD7			= $D7		; checksum byte/temporary last character


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

InsertCount		= $D8		; insert count


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

LDTB1			= $D9		; screen line link table
; ... $F1

ColorRamPtr		= $F3		; colour RAM pointer
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

;	TblStandardKeys			; unshifted
;	TblShiftKeys			; shifted
;	TblCbmKeys			; commodore
;	TblControlKeys			; control

KEYTAB			= $F5		; keyboard pointer
; ... $F6


; When device the RS232 channel is opened two buffers of 256 bytes each are
; created at the top of memory. These locations point to the address of the one
; which is used to store characters as they are received.

RIBUF			= $F7		; RS232 Rx pointer
; ... $F8


; These locations point to the address of the 256 byte output buffer that is
; used for transmitting data to RS232 devices.

ROBUF			= $F9		; RS232 Tx pointer
; ... $FA


StrConvAddr		= $FF		; string conversion address

STACK			= $0100		; processor stack
; ... $01FF


; Input buffer. For some routines the byte before the input buffer needs to be
; set to a specific value for the routine to work correctly
CommandBuf		= $0200

LogFileTbl		= $0259		; logical file table
; ... $0262

DevNumTbl		= $0263		; device number table
; ... $026C

SecAddrTbl		= $026D		; secondary address table
; ... $0276

KeyboardBuf		= $0277		; keyboard buffer
; ... $0280

StartOfMem		= $0281		; OS start of memory
; ... $0282

EndOfMem		= $0283		; OS top of memory
; ... $0284

TIMOUT			= $0285		; serial bus timeout flag

COLOR			= $0286		; current colour code
					; $00	black
					; $01	white
					; $02	red
					; $03	cyan
					; $04	magents
					; $05	green
					; $06	blue
					; $07	yellow
					; $08	orange
					; $09	brown
					; $0A	light red
					; $0B	dark grey
					; $0C	medium grey
					; $0D	light green
					; $0E	light blue
					; $0F	light grey

GDCOL			= $0287		; colour under cursor
HIBASE			= $0288		; screen memory page
XMAX			= $0289		; maximum keyboard buffer size
RPTFLG			= $028A		; key repeat. $80 = repeat all, $40 = repeat none,
					; $00 = repeat cursor movement keys, insert/delete
					; key and the space bar
KOUNT			= $028B		; repeat speed counter
DELAY			= $028C		; repeat delay counter


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

SHFLAG			= $028D		; keyboard shift/control flag
					; bit	key(s) 1 = down
					; ---	---------------
					; 7-3	unused
					;  2	CTRL
					;  1	C=
					;  0	SHIFT


; This location, in combination with the one above, is used to debounce the
; special SHIFT keys. This will keep the SHIFT/C= combination from changing
; character sets back and forth during a single pressing of both keys.

LSTSHF			= $028E		; SHIFT/CTRL/C= keypress last pattern


; This location points to the address of the Operating System routine which
; actually determines which keyboard matrix lookup table will be used.

; The routine looks at the value of the SHIFT flag at $28D, and based on what
; value it finds there, stores the address of the correct table to use at
; location $F5.

KEYLOG			= $028F		; keyboard decode logic pointer
; ... $0290


; This flag is used to enable or disable the feature which lets you switch
; between the uppercase/graphics and upper/lowercase character sets by pressing
; the SHIFT and Commodore logo keys simultaneously.

MODE			= $0291		; shift mode switch, $00 = enabled, $80 = locked


; This location is used to determine whether moving the cursor past the ??xx
; column of a logical line will cause another physical line to be added to the
; logical line.

; A value of 0 enables the screen to scroll the following lines down in order
; to add that line; any nonzero value will disable the scroll.

; This flag is set to disable the scroll temporarily when there are characters
; waiting in the keyboard buffer, these may include cursor movement characters
; that would eliminate the need for a scroll.

AUTODN			= $0292		; screen scrolling flag, $00 = enabled


M51CTR			= $0293		; pseudo 6551 control register. the first character of
					; the OPEN RS232 filename will be stored here
					; bit	function
					; ---	--------
					;  7	2 stop bits/1 stop bit
					; 65	word length
					; ---	-----------
					; 00	8 bits
					; 01	7 bits
					; 10	6 bits
					; 11	5 bits
					;  4	unused
					; 3210	baud rate
					; ----	---------
					; 0000	user rate *
					; 0001	   50
					; 0010	   75
					; 0011	  110
					; 0100	  134.5
					; 0101	  150
					; 0110	  300
					; 0111	  600
					; 1000	 1200
					; 1001	 1800
					; 1010	 2400
					; 1011	 3600
					; 1100	 4800 *
					; 1101	 7200 *
					; 1110	 9600 *
					; 1111	19200 *	* = not implemented

M51CDR			= $0294		; pseudo 6551 command register. the second character of
					; the OPEN RS232 filename will be stored here
					; bit	function
					; ---	--------
					; 7-5	parity
					;	xx0 = disabled
					;	001 = odd
					;	011 = even
					;	101 = mark
					;	111 = space
					;  4	duplex half/full
					;  3	unused
					;  2	unused
					;  1	unused
					;  0	handshake - X line/3 line

M51AJB			= $0295		; nonstandard bit timing. the third
					; character of the OPEN RS232 filename
					; will be stored here
; ... $0296

RSSTAT			= $0297		; RS-232 status register
					; bit	function
					; ---	--------
					;  7	break
					;  6	no DSR detected
					;  5	unused
					;  4	no CTS detected
					;  3	unused
					;  2	Rx buffer overrun
					;  1	framing error
					;  0	parity error

BITNUM			= $0298		; number of bits to be sent/received
BAUDOF			= $0299		; bit time
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

RIDBE			= $029B		; index to Rx buffer end
RIDBS			= $029C		; index to Rx buffer start
RODBE			= $029D		; index to Tx buffer start
RODBS			= $029E		; index to Tx buffer end

IRQTMP			= $029F		; saved IRQ
; ... $02A0


; This location holds the active NMI interrupt flag byte from CIA 2 ICR, .eq
; CIA2IRQ

ENABL			= $02A1		; RS-232 interrupt enable byte
					; bit	function
					; ---	--------
					;  7	unused
					;  6	unused
					;  5	unused
					;  4	1 = waiting for Rx edge
					;  3	unused
					;  2	unused
					;  1	1 = Rx data timer
					;  0	1 = Tx data timer

Copy6522CRB		= $02A2		; CIA 1 CRB shadow copy
Copy6522ICR		= $02A3		; CIA 1 ICR shadow copy
Copy6522CRA		= $02A4		; CIA 1 CRA shadow copy

TmpLineScrl		= $02A5		; temp Index to the next line for scrolling

PALNTSC			= $02A6		; PAL/NTSC flag
					; $00 = NTSC
					; $01 = PAL

; $02A7 to $02FF - unused

IERROR			= $0300		; vector to the print BASIC error message routine
IMAIN			= $0302		; Vector to the main BASIC program Loop
ICRNCH			= $0304		; Vector to the the ASCII text to keywords routine
IQPLOP			= $0306		; Vector to the list BASIC program as ASCII routine
IGONE			= $0308		; Vector to the execute next BASIC command routine
IEVAL			= $030A		; Vector to the get value from BASIC line routine

; Before every SYS command each of the registers is loaded with the value found
; in the corresponding storage address. Upon returning to BASIC with an RTS
; instruction, the new value of each register is stored in the appropriate
; storage address.

; This feature allows you to place the necessary values into the registers from
; BASIC before you SYS to a Kernal or BASIC ML routine. It also enables you to
; examine the resulting effect of the routine on the registers, and to preserve
; the condition of the registers on exit for subsequent SYS calls.

SAREG			= $030C		; A for SYS command
SXREG			= $030D		; X for SYS command
SYREG			= $030E		; Y for SYS command
SPREG			= $030F		; P for SYS command

UserJump		= $0310		; JMP instruction for user function

USRADD			= $0311		; user function vector
; ... $0312

CINV			= $0314		; IRQ vector
BINV			= $0316		; BRK vector
NMINV			= $0318		; NMI vector
IOPEN			= $031A		; kernal vector - open a logical file
ICLOSE			= $031C		; kernal vector - close a specified logical file
ICHKIN			= $031E		; kernal vector - open channel for input
ICKOUT			= $0320		; kernal vector - open channel for output
ICLRCH			= $0322		; kernal vector - close input and output channels
IBASIN			= $0324		; kernal vector - input character from channel
IBSOUT			= $0326		; kernal vector - output character to channel
ISTOP			= $0328		; kernal vector - scan stop key
IGETIN			= $032A		; kernal vector - get character from keyboard queue
ICLALL			= $032C		; kernal vector - close all channels and files
; ???
ILOAD			= $0330		; kernal vector - load
ISAVE			= $0332		; kernal vector - save

TapeBuffer		= $033C		; cassette buffer


RomStart		= $8000		; autostart ROM initial entry vector
RomIRQ			= $8002		; autostart ROM break entry
RomIdentStr		= $8004		; autostart ROM identifier string start


VIC_chip		= $D000		; vic ii chip base address
VICCTR1			= $D011		; vertical fine scroll and control
VICLINE			= $D012		; raster compare register
VICLPX			= $D013		; lightpen, X position
VICLPY			= $D014		; lightpen, Y position
VICSPEN			= $D015		; enable sprites, 1 = on
VICCTR2			= $D016		; horizontal fine scroll and control
VICRAM			= $D018		; memory control
VICESPV			= $D017		; enlarge sprites vertical * 2
VICIRQ			= $D019		; vic interrupt flag register
SIDFMVO			= $D418		; volume and filter select

ColourRAM		= $D800		; 1K colour RAM base address


; CIA 1

CIA1DRA			= $DC00		; CIA 1 DRA, keyboard column drive
CIA1DRB			= $DC01		; CIA 1 DRB, keyboard row port

; keyboard matrix layout
;	c7	c6	c5	c4	c3	c2	c1	c0
;   +----------------------------------------------------------------
; r7|	[RUN]	/	,	N	V	X	[LSH]	[DN]
; r6|	Q	[UP]	@	O	U	T	E	[F5]
; r5|	[CBM]= :	K	H	F	S	[F3]
; r4|	[SP]	[RSH]	.	M	B	C	Z	[F1]
; r3|	2	[Home]-	0	8	6	4	[F7]
; r2|	[CTL]	;	L	J	G	D	A	[RGT]
; r1|	[LFT]	*	P	I	Y	R	W	[RET]
; r0|	1	£	+	9	7	5	3	[DEL]

CIA1DDRA		= $DC02		; CIA 1 DDRA, keyboard column
CIA1DDRB		= $DC03		; CIA 1 DDRB, keyboard row
CIA1TI1L		= $DC04		; CIA 1 timer A low byte
CIA1TI1H		= $DC05		; CIA 1 timer A high byte
CIA1TI2L		= $DC06		; CIA 1 timer B low byte
CIA1TI2H		= $DC07		; CIA 1 timer B high byte
CIA1IRQ			= $DC0D		; CIA 1 ICR
					; bit	function
					; ---	--------
					;  7	interrupt
					;  6	unused
					;  5	unused
					;  4	FLAG
					;  3	shift register
					;  2	TOD alarm
					;  1	timer B
					;  0	timer A
CIA1CTR1		= $DC0E		; CIA 1 CRA
					; bit	function
					; ---	--------
					;  7	TOD clock, 1 = 50Hz, 0 = 60Hz
					;  6	serial port direction, 1 = out, 0 = in
					;  5	timer A input, 1 = phase2, 0 = CNT in
					;  4	1 = force load timer A
					;  3	timer A mode, 1 = single shot, 0 = continuous
					;  2	PB6 mode, 1 = toggle, 0 = single shot
					;  1	1 = timer A to PB6
					;  0	1 = start timer A
CIA1CTR2		= $DC0F		; CIA 1 CRB
					; bit	function
					; ---	--------
					;  7	TOD register select, 1 = clock, 0 = alarm
					; 6-5	timer B mode
					;     11 = timer A with CNT enable
					;     10 = timer A
					;     01 = CNT in
					;     00 = phase 2
					;  4	1 = force load timer B
					;  3	timer B mode, 1 = single shot, 0 = continuous
					;  2	PB7 mode, 1 = toggle, 0 = single shot
					;  1	1 = timer B to PB7
					;  0	1 = start timer B


; CIA 2

CIA2DRA			= $DD00		; CIA 2 DRA, serial port and video address
					; bit	function
					; ---	--------
					;  7	serial DATA in
					;  6	serial CLK in
					;  5	serial DATA out
					;  4	serial CLK out
					;  3	serial ATN out
					;  2	RS232 Tx DATA
					;  1	video address 15
					;  0	video address 14
CIA2DRB			= $DD01		; CIA 2 DRB, RS232 port
					; bit	function
					; ---	--------
					;  7	RS232 DSR
					;  6	RS232 CTS
					;  5	unused
					;  4	RS232 DCD
					;  3	RS232 RI
					;  2	RS232 DTR
					;  1	RS232 RTS
					;  0	RS232 Rx DATA
CIA2DDRA		= $DD02		; CIA 2 DDRA, serial port and video address
CIA2DDRB		= $DD03		; CIA 2 DDRB, RS232 port
CIA2TI1L		= $DD04		; CIA 2 timer A low byte
CIA2TI1H		= $DD05		; CIA 2 timer A high byte
CIA2TI2L		= $DD06		; CIA 2 timer B low byte
CIA2TI2H		= $DD07		; CIA 2 timer B high byte
CIA2IRQ			= $DD0D		; CIA 2 ICR
					; bit	function
					; ---	--------
					;  7	interrupt
					;  6	unused
					;  5	unused
					;  4	FLAG
					;  3	shift register
					;  2	TOD alarm
					;  1	timer B
					;  0	timer A
CIA2CTR1		= $DD0E		; CIA 2 CRA
					; bit	function
					; ---	--------
					;  7	TOD clock, 1 = 50Hz, 0 = 60Hz
					;  6	serial port direction, 1 = out, 0 = in
					;  5	timer A input, 1 = phase2, 0 = CNT in
					;  4	1 = force load timer A
					;  3	timer A mode, 1 = single shot, 0 = continuous
					;  2	PB6 mode, 1 = toggle, 0 = single shot
					;  1	1 = timer A to PB6
					;  0	1 = start timer A
CIA2CTR2		= $DD0F		; CIA 2 CRB
					; bit	function
					; ---	--------
					;  7	TOD register select, 1 = clock, 0 = alarm
					; 6-5	timer B mode
					;     11 = timer A with CNT enable
					;     10 = timer A
					;     01 = CNT in
					;     00 = phase 2
					;  4	1 = force load timer B
					;  3	timer B mode, 1 = single shot, 0 = continuous
					;  2	PB7 mode, 1 = toggle, 0 = single shot
					;  1	1 = timer B to PB7
					;  0	1 = start timer B


;******************************************************************************
;
; BASIC keyword token values. tokens not used in the source are included for
; completeness but commented out

; command tokens

; TK_END	= $80			; END token
TK_FOR		= $81			; FOR token
; TK_NEXT	= $82			; NEXT token
TK_DATA		= $83			; DATA token
; TK_INFL	= $84			; INPUT# token
; TK_INPUT	= $85			; INPUT token
; TK_DIM	= $86			; DIM token
; TK_READ	= $87			; READ token

; TK_LET	= $88			; LET token
TK_GOTO		= $89			; GOTO token
; TK_RUN	= $8A			; RUN token
; TK_IF		= $8B			; IF token
; TK_RESTORE	= $8C			; RESTORE token
TK_GOSUB	= $8D			; GOSUB token
; TK_RETURN	= $8E			; RETURN token
TK_REM		= $8F			; REM token

; TK_STOP	= $90			; STOP token
; TK_ON		= $91			; ON token
; TK_WAIT	= $92			; WAIT token
; TK_LOAD	= $93			; LOAD token
; TK_SAVE	= $94			; SAVE token
; TK_VERIFY	= $95			; VERIFY token
; TK_DEF	= $96			; DEF token
; TK_POKE	= $97			; POKE token

; TK_PRINFL	= $98			; PRINT# token
TK_PRINT	= $99			; PRINT token
; TK_CONT	= $9A			; CONT token
; TK_LIST	= $9B			; LIST token
; TK_CLR	= $9C			; CLR token
; TK_CMD	= $9D			; CMD token
; TK_SYS	= $9E			; SYS token
; TK_OPEN	= $9F			; OPEN token

; TK_CLOSE	= $A0			; CLOSE token
; TK_GET	= $A1			; GET token
; TK_NEW	= $A2			; NEW token

; secondary keyword tokens

TK_TAB		= $A3			; TAB( token
TK_TO		= $A4			; TO token
TK_FN		= $A5			; FN token
TK_SPC		= $A6			; SPC( token
TK_THEN		= $A7			; THEN token

TK_NOT		= $A8			; NOT token
TK_STEP		= $A9			; STEP token

; operator tokens

TK_PLUS		= $AA			; + token
TK_MINUS	= $AB			; - token
; TK_MUL	= $AC			; * token
; TK_DIV	= $AD			; / token
; TK_POWER	= $AE			; ^ token
; TK_AND	= $AF			; AND token

; TK_OR		= $B0			; OR token
TK_GT		= $B1			; > token
TK_EQUAL	= $B2			; = token
; TK_LT		= $B3			; < token

; function tokens

TK_SGN		= $B4			; SGN token
; TK_INT	= $B5			; INT token
; TK_ABS	= $B6			; ABS token
; TK_USR	= $B7			; USR token

; TK_FRE	= $B8			; FRE token
; TK_POS	= $B9			; POS token
; TK_SQR	= $BA			; SQR token
; TK_RND	= $BB			; RND token
; TK_LOG	= $BC			; LOG token
; TK_EXP	= $BD			; EXP token
; TK_COS	= $BE			; COS token
; TK_SIN	= $BF			; SIN token

; TK_TAN	= $C0			; TAN token
; TK_ATN	= $C1			; ATN token
; TK_PEEK	= $C2			; PEEK token
; TK_LEN	= $C3			; LEN token
; TK_STRS	= $C4			; STR$ token
; TK_VAL	= $C5			; VAL token
; TK_ASC	= $C6			; ASC token
; TK_CHRS	= $C7			; CHR$ token

; TK_LEFTS	= $C8			; LEFT$ token
; TK_RIGHTS	= $C9			; RIGHT$ token
; TK_MIDS	= $CA			; MID$ token
TK_GO		= $CB			; GO token

TK_PI		= $FF			; PI token



;******************************************************************************
;
; start of the BASIC ROM

*= $A000

BasicCold
.word	BasicColdStart			; BASIC cold start entry point
BasicNMI
.word	BasicWarmStart			; BASIC warm start entry point

;A_A004
.text	"cbmbasic"			; ROM name, unreferenced


;******************************************************************************
;
; action addresses for primary commands. these are called by pushing the
; address onto the stack and doing an RTS so the actual address -1 needs to be
; pushed

TblBasicInstr				;				[A00C]
.rta	bcEND				; perform END		$80
.rta	bcFOR				; perform FOR		$81
.rta	bcNEXT				; perform NEXT		$82
.rta	bcDATA				; perform DATA		$83
.rta	bcINPUTH			; perform INPUT#	$84
.rta	bcINPUT				; perform INPUT		$85
.rta	bcDIM				; perform DIM		$86
.rta	bcREAD				; perform READ		$87

.rta	bcLET				; perform LET		$88
.rta	bcGOTO				; perform GOTO		$89
.rta	bcRUN				; perform RUN		$8A
.rta	bcIF				; perform IF		$8B
.rta	bcRESTORE			; perform RESTORE	$8C
.rta	bcGOSUB				; perform GOSUB		$8D
.rta	bcRETURN			; perform RETURN	$8E
.rta	bcREM				; perform REM		$8F

.rta	bcSTOP				; perform STOP		$90
.rta	bcON				; perform ON		$91
.rta	bcWAIT				; perform WAIT		$92
.rta	bcLOAD				; perform LOAD		$93
.rta	bcSAVE				; perform SAVE		$94
.rta	bcVERIFY			; perform VERIFY	$95
.rta	bcDEF				; perform DEF		$96
.rta	bcPOKE				; perform POKE		$97

.rta	bcPRINTH			; perform PRINT#	$98
.rta	bcPRINT				; perform PRINT		$99
.rta	bcCONT				; perform CONT		$9A
.rta	bcLIST				; perform LIST		$9B
.rta	bcCLR				; perform CLR		$9C
.rta	bcCMD				; perform CMD		$9D
.rta	bcSYS				; perform SYS		$9E
.rta	bcOPEN				; perform OPEN		$9F

.rta	bcCLOSE				; perform CLOSE		$A0
.rta	bcGET				; perform GET		$A1
.rta	bcNEW				; perform NEW		$A2


;******************************************************************************
;
; action addresses for functions

TblFunctions				;				[A052]
.word	bcSGN				; perform SGN()		$B4
.word	bcINT				; perform INT()		$B5
.word	bcABS				; perform ABS()		$B6
.word	UserJump			; perform USR()		$B7

.word	bcFRE				; perform FRE()		$B8
.word	bcPOS				; perform POS()		$B9
.word	bcSQR				; perform SQR()		$BA
.word	bcRND				; perform RND()		$BB
.word	bcLOG				; perform LOG()		$BC
.word	bcEXP				; perform EXP()		$BD
.word	bcCOS				; perform COS()		$BE
.word	bcSIN				; perform SIN()		$BF

.word	bcTAN				; perform TAN()		$C0
.word	bcATN				; perform ATN()		$C1
.word	bcPEEK				; perform PEEK()	$C2
.word	bcLEN				; perform LEN()		$C3
.word	bcSTR				; perform STR$()	$C4
.word	bcVAL				; perform VAL()		$C5
.word	bcASC				; perform ASC()		$C6
.word	bcCHR				; perform CHR$()	$C7

.word	bcLEFT				; perform LEFT$()	$C8
.word	bcRIGHT				; perform RIGHT$()	$C9
.word	bcMID				; perform MID$()	$CA


;******************************************************************************
;
; precedence byte and action addresses for operators. like the primarry
; commands these are called by pushing the address onto the stack and doing an
; RTS, so again the actual address -1 needs to be pushed

HierachyCode				;				[A080]
.byte	$79
.rta	bcPLUS				; +
.byte	$79
.rta	bcMINUS				; -
.byte	$7B
.rta	bcMULTIPLY			; *
.byte	$7B
.rta	bcDIVIDE			; /
.byte	$7F
.rta	bcPOWER				; ^
.byte	$50
.rta	bcAND				; AND
.byte	$46
.rta	bcOR				; OR
.byte	$7D
.rta	bcGREATER			; >
.byte	$5A
.rta	bcEQUAL				; =
.byte	$64
.rta	bcSMALLER			; <


;******************************************************************************
;
; BASIC keywords. each word has bit 7 set in it's last character as an end
; marker, even the one character keywords such as "<" or "="

; first are the primary command keywords, only these can start a statement

TblBasicCodes				;				[A09E]
D_A09E		.shift "end"		; END		$80		128
D_A0A1		.shift "for"		; FOR		$81		129
D_A0A4		.shift "next"		; NEXT		$82		130
D_A0A8		.shift "data"		; DATA		$83		131
D_A0AC		.shift "input#"		; INPUT#	$84		132
D_A0B2		.shift "input"		; INPUT		$85		133
D_A0B7		.shift "dim"		; DIM		$86		134
D_A0BA		.shift "read"		; READ		$87		135
D_A0BE		.shift "let"		; LET		$88		136
D_A0C1		.shift "goto"		; GOTO		$89		137
D_A0C5		.shift "run"		; RUN		$8A		138
D_A0C8		.shift "if"		; IF		$8B		139
D_A0CA		.shift "restore"	; RESTORE	$8C		140
D_A0D1		.shift "gosub"		; GOSUB		$8D		141
D_A0D6		.shift "return"		; RETURN	$8E		142
D_A0DC		.shift "rem"		; REM		$8F		143
D_A0DF		.shift "stop"		; STOP		$90		144
D_A0E3		.shift "on"		; ON		$91		145
D_A0E5		.shift "wait"		; WAIT		$92		146
D_A0E9		.shift "load"		; LOAD		$93		147
D_A0ED		.shift "save"		; SAVE		$94		148
D_A0F1		.shift "verify"		; VERIFY	$95		149
D_A0F7		.shift "def"		; DEF		$96		150
D_A0FA		.shift "poke"		; POKE		$97		151
D_A0FE		.shift "print#"		; PRINT#	$98		152
D_A104		.shift "print"		; PRINT		$99		153
D_A109		.shift "cont"		; CONT		$9A		154
D_A10D		.shift "list"		; LIST		$9B		155
D_A111		.shift "clr"		; CLR		$9C		156
D_A114		.shift "cmd"		; CMD		$9D		157
D_A117		.shift "sys"		; SYS		$9E		158
D_A11A		.shift "open"		; OPEN		$9F		159
D_A11E		.shift "close"		; CLOSE		$A0		160
D_A123		.shift "get"		; GET		$A1		161
D_A126		.shift "new"		; NEW		$A2		162

; table of functions, each ended with a +$80
; next are the secondary command keywords, these can not start a statement

D_A129		.shift "tab("		; TAB(		$A3		163
D_A12D		.shift "to"		; TO		$A4		164
D_A12F		.shift "fn"		; FN		$A5		165
D_A131		.shift "spc("		; SPC(		$A6		166
D_A135		.shift "then"		; THEN		$A7		167
D_A139		.shift "not"		; NOT		$A8		168
D_A13C		.shift "step"		; STEP		$A9		169

; next are the operators

D_A140		.shift "+"		; +		$AA		170
D_A141		.shift "-"		; -		$AB		171
D_A142		.shift "*"		; *		$AC		172
D_A143		.shift "/"		; /		$AD		173
D_A144		.shift "{up arrow}"	; ^		$AE		174
D_A145		.shift "and"		; AND		$AF		175
D_A148		.shift "or"		; OR		$B0		176
D_A14A		.shift ">"		; >		$B1		177
D_A14B		.shift "="		; =		$B2		178
D_A14C		.shift "<"		; <		$B3		179

; and finally the functions

D_A14D		.shift "sgn"		; SGN		$B4		180
D_A150		.shift "int"		; INT		$B5		181
D_A153		.shift "abs"		; ABS		$B6		182
D_A156		.shift "usr"		; USR		$B7		183
D_A159		.shift "fre"		; FRE		$B8		184
D_A15C		.shift "pos"		; POS		$B9		185
D_A15F		.shift "sqr"		; SQR		$BA		186
D_A162		.shift "rnd"		; RND		$BB		187
D_A165		.shift "log"		; LOG		$BC		188
D_A168		.shift "exp"		; EXP		$BD		189
D_A16B		.shift "cos"		; COS		$BE		190
D_A16E		.shift "sin"		; SIN		$BF		191
D_A171		.shift "tan"		; TAN		$C0		192
D_A174		.shift "atn"		; ATN		$C1		193
D_A177		.shift "peek"		; PEEK		$C2		194
D_A17B		.shift "len"		; LEN		$C3		195
D_A17E		.shift "str$"		; STR$		$C4		196
D_A182		.shift "val"		; VAL		$C5		197
D_A185		.shift "asc"		; ASC		$C6		198
D_A188		.shift "chr$"		; CHR$		$C7		199
D_A18C		.shift "left$"		; LEFT$		$C8		200
D_A191		.shift "right$"		; RIGHT$	$C9		201
D_A197		.shift "mid$"		; MID$		$CA		202

; lastly is GO, this is an add on so that GO TO, as well as GOTO, will work

D_A19B		.shift "go"		; GO		$CB		203

.byte	$00				; end marker


;******************************************************************************
;
; BASIC error messages

TxtTooManyFile		.shift "too many files"		  ;	[A19E]
TxtFileOpen		.shift "file open"		  ;	[A1AC]
TxtFileNotOpen		.shift "file not open"		  ;	[A1B5]
TxtFileNotFound		.shift "file not found"		  ;	[A1C2]
TxtDevNotPresent	.shift "device not present"	  ;	[A1D0]
TxtNotInputFile		.shift "not input file"		  ;	[A1E2]
TxtNotOutputFile	.shift "not output file"	  ;	[A1F0]
TxtMissingFile		.shift "missing file name"	  ;	[A1FF]
TxtIllegalDevice	.shift "illegal device number"	  ;	[A210]
TxtNextWithout		.shift "next without for"	  ;	[A225]
TxtSyntax		.shift "syntax"			  ;	[A235]
TxtReturnWithout	.shift "return without gosub"	  ;	[A23B]
TxtOutOfData		.shift "out of data"		  ;	[A24F]
TxtIllegalQuan		.shift "illegal quantity"	  ;	[A25A]
TxtOverflow		.shift "overflow"		  ;	[A26A]
TxtOutOfMemory		.shift "out of memory"		  ;	[A272]
TxtUndefdState		.shift "undef'd statement"	  ;	[A27F]
TxtBadSubscript		.shift "bad subscript"		  ;	[A290]
TxtRedimdArray		.shift "redim'd array"		  ;	[A29D]
TxtDivisByZero		.shift "division by zero"	  ;	[A2AA]
TxtIllegalDirect	.shift "illegal direct"		  ;	[A2BA]
TxtTypeMismatc		.shift "type mismatch"		  ;	[A2C8]
TxtStringTooLong	.shift "string too long"	  ;	[A2D5]
TxtFileData		.shift "file data"		  ;	[A2E4]
TxtFormulaTooC		.shift "formula too complex"	  ;	[A2ED]
TxtCantContinue		.shift "can't continue"		  ;	[A300]
TxtUndefdFunct		.shift "undef'd function"	  ;	[A30E]
TxtVerify		.shift "verify"			  ;	[A31E]
TxtLoad			.shift "load"			  ;	[A324]


; error message pointer table

AddrErrorMsg				;				[A328]
.word	TxtTooManyFile			; $01	TOO MANY FILES
.word	TxtFileOpen			; $02	FILE OPEN
.word	TxtFileNotOpen			; $03	FILE NOT OPEN
.word	TxtFileNotFound			; $04	FILE NOT FOUND
.word	TxtDevNotPresent		; $05	DEVICE NOT PRESENT
.word	TxtNotInputFile			; $06	NOT INPUT FILE
.word	TxtNotOutputFile		; $07	NOT OUTPUT FILE
.word	TxtMissingFile			; $08	MISSING FILE NAME
.word	TxtIllegalDevice		; $09	ILLEGAL DEVICE NUMBER
.word	TxtNextWithout			; $0A	NEXT WITHOUT FOR
.word	TxtSyntax			; $0B	SYNTAX
.word	TxtReturnWithout		; $0C	RETURN WITHOUT GOSUB
.word	TxtOutOfData			; $0D	OUT OF DATA
.word	TxtIllegalQuan			; $0E	ILLEGAL QUANTITY
.word	TxtOverflow			; $0F	OVERFLOW
.word	TxtOutOfMemory			; $10	OUT OF MEMORY
.word	TxtUndefdState			; $11	UNDEF'D STATEMENT
.word	TxtBadSubscript			; $12	BAD SUBSCRIPT
.word	TxtRedimdArray			; $13	REDIM'D ARRAY
.word	TxtDivisByZero			; $14	DIVISION BY ZERO
.word	TxtIllegalDirect		; $15	ILLEGAL DIRECT
.word	TxtTypeMismatc			; $16	TYPE MISMATCH
.word	TxtStringTooLong		; $17	STRING TOO LONG
.word	TxtFileData			; $18	FILE DATA
.word	TxtFormulaTooC			; $19	FORMULA TOO COMPLEX
.word	TxtCantContinue			; $1A	CAN'T CONTINUE
.word	TxtUndefdFunct			; $1B	UNDEF'D FUNCTION
.word	TxtVerify			; $1C	VERIFY
.word	TxtLoad				; $1D	LOAD
.word	TxtBreak2			; $1E	BREAK


;******************************************************************************
;
; BASIC messages

TxtOK		.null "{cr}ok{cr}"
TxtError	.null "  error"
TxtIn		.null " in "
TxtReady	.null "{cr}{lf}ready.{cr}{lf}"
TxtBreak	.text "{cr}{lf}"
TxtBreak2	.null "break"


;******************************************************************************
;
; spare byte, not referenced

A390		.byte	$A0		; unused


;******************************************************************************
;
; search the stack for FOR or GOSUB activity
; return Zb=1 if FOR variable found

SrchForNext				;				[A38A]
	tsx				; copy stack pointer
	inx				; +1 pass return address
	inx				; +2 pass return address
	inx				; +3 pass calling routine return address
	inx				; +4 pass calling routine return address
A_A38F					;				[A38F]
	lda	STACK+1,X		; get the token byte from the stack
	cmp	#TK_FOR			; is it the FOR token
	bne	A_A3B7			; if not FOR token just exit

; it was the FOR token

	lda	FORPNT+1		; get FOR/NEXT variable pointer HB
	bne	A_A3A4			; branch if not null

	lda	STACK+2,X		; get FOR variable pointer LB
	sta	FORPNT			; save FOR/NEXT variable pointer LB
	lda	STACK+3,X		; get FOR variable pointer HB
	sta	FORPNT+1		; save FOR/NEXT variable pointer HB
A_A3A4					;				[A3A4]
	cmp	STACK+3,X		; compare variable pointer with stacked
					; variable pointer HB
	bne	A_A3B0			; branch if no match

	lda	FORPNT			; get FOR/NEXT variable pointer LB
	cmp	STACK+2,X		; compare variable pointer with stacked
					; variable pointer LB
	beq	A_A3B7			; exit if match found

A_A3B0					;				[A3B0]
	txa				; copy index
	clc				; clear carry for add
	adc	#$12			; add FOR stack use size
	tax				; copy back to index
	bne	A_A38F			; loop if not at start of stack
A_A3B7					;				[A3B7]
	rts


;******************************************************************************
;
; Move a block of memory
; - open up a space in the memory, set the end of arrays

MoveBlock				;				[A3B8]
	jsr	CheckAvailMem		; check available memory, do out of
					; memory error if no room	[A408]
	sta	STREND			; set end of arrays LB
	sty	STREND+1		; set end of arrays HB

; - open up a space in the memory, don't set the array end

MoveBlock2				;				[A3BF]
	sec				; set carry for subtract
	lda	FacTempStor+3		; get block end LB
	sbc	FacTempStor+8		; subtract block start LB
	sta	INDEX			; save MOD(block length/$100) byte

	tay				; copy MOD(block length/$100) byte to Y
	lda	FacTempStor+4		; get block end HB
	sbc	FacTempStor+9		; subtract block start HB
	tax				; copy block length HB to X

	inx				; +1 to allow for count=0 exit

	tya				; copy block length LB to A
	beq	A_A3F3			; branch if length LB=0

; block is (X-1)*256+Y bytes, do the Y bytes first
	lda	FacTempStor+3		; get block end LB
	sec				; set carry for subtract
	sbc	INDEX			; subtract MOD(block length/$100) byte
	sta	FacTempStor+3		; save corrected old block end LB
	bcs	A_A3DC			; branch if no underflow

	dec	FacTempStor+4		; else decrement block end HB
	sec				; set carry for subtract
A_A3DC					;				[A3DC]
	lda	FacTempStor+1		; get destination end LB
	sbc	INDEX			; subtract MOD(block length/$100) byte
	sta	FacTempStor+1		; save modified new block end LB
	bcs	A_A3EC			; branch if no underflow

	dec	FacTempStor+2		; else decrement block end HB
	bcc	A_A3EC			; branch always
A_A3E8					;				[A3E8]
	lda	(FacTempStor+3),Y	; get byte from source
	sta	(FacTempStor+1),Y	; copy byte to destination
A_A3EC					;				[A3EC]
	dey				; decrement index
	bne	A_A3E8			; loop until Y=0

; now do Y=0 indexed byte
	lda	(FacTempStor+3),Y	; get byte from source
	sta	(FacTempStor+1),Y	; save byte to destination
A_A3F3					;				[A3F3]
	dec	FacTempStor+4		; decrement source pointer HB
	dec	FacTempStor+2		; decrement destination pointer HB

	dex				; decrement block count
	bne	A_A3EC			; loop until count = $0

	rts


;******************************************************************************
;
; check room on stack for A bytes
; if stack too deep do out of memory error

CheckRoomStack				;				[A3FB]
	asl				; *2
	adc	#$3E			; need at least $3E bytes free
	bcs	OutOfMemory		; if overflow go do out of memory error
					; then warm start
	sta	INDEX			; save result in temp byte

	tsx				; copy stack
	cpx	INDEX			; compare new limit with stack
	bcc	OutOfMemory		; if stack < limit do out of memory
					; error then warm start
	rts


;******************************************************************************
;
; check available memory, do out of memory error if no room

CheckAvailMem
	cpy	FRETOP+1		; compare with bottom of string space HB
	bcc	A_A434			; if less then exit (is ok)
	bne	A_A412			; skip next test if greater (tested <)

; HB was =, now do LB
	cmp	FRETOP			; compare with bottom of string space LB
	bcc	A_A434			; if less then exit (is ok)

; address is > string storage ptr (oops!)
A_A412					;				[A412]
	pha				; push address LB

	ldx	#$09			; set index to save FacTempStor to
					; FacTempStor+9 inclusive
	tya				; copy address HB (to push on stack)

; save misc numeric work area
A_A416					;				[A416]
	pha				; push byte

	lda	FacTempStor,X		; get byte from FacTempStor to
					; FacTempStor+9
	dex				; decrement index
	bpl	A_A416			; loop until all done

	jsr	CollectGarbage		; do garbage collection routine	[B526]

; restore misc numeric work area
	ldx	#$F7			; set index to restore bytes
A_A421					;				[A421]
	pla				; pop byte
	sta	FacTempStor+9+1,X	; save byte to FacTempStor to
					; FacTempStor+9
	inx				; increment index
	bmi	A_A421			; loop while -ve

	pla				; pop address HB
	tay				; copy back to Y

	pla				; pop address LB

	cpy	FRETOP+1		; compare with bottom of string space HB
	bcc	A_A434			; if less then exit (is ok)

	bne	OutOfMemory		; if greater do out of memory error
					; then warm start
; HB was =, now do LB
	cmp	FRETOP			; compare with bottom of string space LB
	bcs	OutOfMemory		; if >= do out of memory error then
					; warm start
; ok exit, carry clear
A_A434					;				[A434]
	rts


;******************************************************************************
;
; do out of memory error then warm start

OutOfMemory
	ldx	#$10			; error code $10, out of memory error

; do error #X then warm start

OutputErrMsg
	jmp	(IERROR)		; do error message


;******************************************************************************
;
; do error #X then warm start, the error message vector is initialised to point
; here

OutputErrMsg2				;				[A43A]
	txa				; copy error number
	asl				; *2
	tax				; copy to index

	lda	AddrErrorMsg-2,X	; get error message pointer LB
	sta	INDEX			; save it

	lda	AddrErrorMsg-1,X	; get error message pointer HB
	sta	INDEX+1			; save it

	jsr	CloseIoChannls		; close input and output channels [FFCC]

	lda	#$00			; clear A
	sta	CurIoChan		; clear current I/O channel, flag
					; default
	jsr	OutCRLF			; print CR/LF			[AAD7]
	jsr	PrintQuestMark		; print "?"			[AB45]

	ldy	#$00			; clear index
A_A456					;				[A456]
	lda	(INDEX),Y		; get byte from message
	pha				; save status
	and	#$7F			; mask 0xxx xxxx, clear b7
	jsr	PrintChar		; output character		[CB47]

	iny				; increment index
	pla				; restore status
	bpl	A_A456			; loop if character was not end marker

	jsr	ClrBasicStack		; flush BASIC stack and clear continue
					; pointer			[A67A]
	lda	#<TxtError		; set " ERROR" pointer LB
	ldy	#>TxtError		; set " ERROR" pointer HB


;******************************************************************************
;
; print string and do warm start, break entry

OutputMessage				;				[A469]
	jsr	OutputString		; print null terminated string	[AB1E]

	ldy	CURLIN+1		; get current line number HB
	iny				; increment it
	beq	OutputREADY		; branch if was in immediate mode

	jsr	Print_IN		; do " IN " line number message	[BDC2]


;******************************************************************************
;
; do warm start, print READY on the screen

OutputREADY				;				[A474]
	lda	#<TxtReady		; set "READY." pointer LB
	ldy	#>TxtReady		; set "READY." pointer HB
	jsr	OutputString		; print null terminated string	[AB1E]

	lda	#$80			; set for control messages only
	jsr	CtrlKernalMsg		; control kernal messages	[FF90]


;******************************************************************************
;
; Main wait loop

MainWaitLoop
	jmp	(IMAIN)			; do BASIC warm start


;******************************************************************************
;
; BASIC warm start, the warm start vector is initialised to point here

MainWaitLoop2				;				[A483]
	jsr	InputNewLine		; call for BASIC input		[A560]
	stx	TXTPTR			; save BASIC execute pointer LB
	sty	TXTPTR+1		; save BASIC execute pointer HB

	jsr	CHRGET			; increment and scan memory	[0073]
	tax				; copy byte to set flags
	beq	MainWaitLoop		; loop if no input

; got to interpret the input line now ....

	ldx	#$FF			; current line HB to -1, indicates
					; immediate mode
	stx	CURLIN+1		; set current line number HB
	bcc	A_A49C			; if numeric character go handle new
					; BASIC line
; no line number .. immediate mode
S_A496
	jsr	Text2TokenCode		; crunch keywords into BASIC tokens
					;				[A579]
	jmp	InterpretLoop2		; go scan and interpret code	[A7E1]


;******************************************************************************
;
; handle new BASIC line

A_A49C					;				[A49C]
	jsr	LineNum2Addr		; get fixed-point number into temporary
					; integer			[A96B]
	jsr	Text2TokenCode		; crunch keywords into BASIC tokens
					;				[A579]
	sty	COUNT			; save index pointer to end of crunched
					; line
	jsr	CalcStartAddr		; search BASIC for temporary integer
					; line number			[A613]
	bcc	A_A4ED			; if not found skip the line delete

; line # already exists so delete it
	ldy	#$01			; set index to next line pointer HB
	lda	(FacTempStor+8),Y	; get next line pointer HB
	sta	INDEX+1			; save it

	lda	VARTAB			; get start of variables LB
	sta	INDEX			; save it

	lda	FacTempStor+9		; get found line pointer HB
	sta	INDEX+3			; save it

	lda	FacTempStor+8		; get found line pointer LB
	dey				; decrement index
	sbc	(FacTempStor+8),Y	; subtract next line pointer LB
	clc				; clear carry for add
	adc	VARTAB			; add start of variables LB
	sta	VARTAB			; set start of variables LB
	sta	INDEX+2			; save destination pointer LB

	lda	VARTAB+1		; get start of variables HB
	adc	#$FF			; -1 + carry
	sta	VARTAB+1		; set start of variables HB

	sbc	FacTempStor+9		; subtract found line pointer HB
	tax				; copy to block count

	sec				; set carry for subtract
	lda	FacTempStor+8		; get found line pointer LB
	sbc	VARTAB			; subtract start of variables LB
	tay				; copy to bytes in first block count
	bcs	A_A4D7			; branch if no underflow

	inx				; increment block count, correct for =
					; 0 loop exit
	dec	INDEX+3			; decrement destination HB
A_A4D7					;				[A4D7]
	clc				; clear carry for add
	adc	INDEX			; add source pointer LB
	bcc	A_A4DF			; branch if no overflow

	dec	INDEX+1			; else decrement source pointer HB
	clc				; clear carry

; close up memory to delete old line
A_A4DF					;				[A4DF]
	lda	(INDEX),Y		; get byte from source
	sta	(INDEX+2),Y		; copy to destination
	iny				; increment index
	bne	A_A4DF			; while <> 0 do this block

	inc	INDEX+1			; increment source pointer HB
	inc	INDEX+3			; increment destination pointer HB

	dex				; decrement block count
	bne	A_A4DF			; loop until all done

; got new line in buffer and no existing same #
A_A4ED					;				[A4ED]
	jsr	ResetExecPtr		; reset execution to start, clear
					; variables, flush stack	[A659]
					; and return
	jsr	BindLine		; rebuild BASIC line chaining	[A533]

	lda	CommandBuf		; get first byte from buffer
	beq	MainWaitLoop		; if no line go do BASIC warm start

; else insert line into memory
	clc				; clear carry for add
	lda	VARTAB			; get start of variables LB
	sta	FacTempStor+3		; save as source end pointer LB

	adc	COUNT			; add index pointer to end of crunched
					; line
	sta	FacTempStor+1		; save as destination end pointer LB

	ldy	VARTAB+1		; get start of variables HB
	sty	FacTempStor+4		; save as source end pointer HB
	bcc	A_A508			; branch if no carry to HB

	iny				; else increment HB
A_A508					;				[A508]
	sty	FacTempStor+2		; save as destination end pointer HB

	jsr	MoveBlock		; open up space in memory	[A3B8]

; most of what remains to do is copy the crunched line into the space opened up
; in memory, however, before the crunched line comes the next line pointer and
; the line number. the line number is retrieved from the temporary integer and
; stored in memory, this overwrites the bottom two bytes on the stack. next the
; line is copied and the next line pointer is filled with whatever was in two
; bytes above the line number in the stack. this is ok because the line pointer
; gets fixed in the line chain re-build.

	lda	LINNUM			; get line number LB
	ldy	LINNUM+1		; get line number HB
	sta	STACK+$FE		; save line number LB before crunched
					; line
	sty	CommandBuf-1		; save line number HB before crunched
					; line

	lda	STREND			; get end of arrays LB
	ldy	STREND+1		; get end of arrays HB
	sta	VARTAB			; set start of variables LB
	sty	VARTAB+1		; set start of variables HB

	ldy	COUNT			; get index to end of crunched line
	dey				; -1
A_A522					;				[A522]
	lda	STACK+$FC,Y		; get byte from crunched line
	sta	(FacTempStor+8),Y	; save byte to memory

	dey				; decrement index
	bpl	A_A522			; loop while more to do

; reset execution, clear variables, flush stack, rebuild BASIC chain and do
; warm start

J_A52A					;				[A52A]
	jsr	ResetExecPtr		; reset execution to start, clear
					; variables and flush stack	[A659]
	jsr	BindLine		; rebuild BASIC line chaining	[A533]
	jmp	MainWaitLoop		; go do BASIC warm start	[A480]


;******************************************************************************
;
; rebuild BASIC line chaining

BindLine				;				[A533]
	lda	TXTTAB			; get start of memory LB
	ldy	TXTTAB+1		; get start of memory HB
	sta	INDEX			; set line start pointer LB
	sty	INDEX+1			; set line start pointer HB
	clc				; clear carry for add
A_A53C					;				[A53C]
	ldy	#$01			; set index to pointer to next line HB
	lda	(INDEX),Y		; get pointer to next line HB
	beq	A_A55F			; exit if null, [EOT]

	ldy	#$04			; point to first code byte of line
					; there is always 1 byte + [EOL] as null
					; entries are deleted
A_A544					;				[A544]
	iny				; next code byte
	lda	(INDEX),Y		; get byte
	bne	A_A544			; loop if not [EOL]

	iny				; point to byte past [EOL], start of
					; next line
	tya				; copy it

	adc	INDEX			; add line start pointer LB
	tax				; copy to X

	ldy	#$00			; clear index, point to this line's next
					; line pointer
	sta	(INDEX),Y		; set next line pointer LB

	lda	INDEX+1			; get line start pointer HB
	adc	#$00			; add any overflow
	iny				; increment index to HB
	sta	(INDEX),Y		; set next line pointer HB
	stx	INDEX			; set line start pointer LB
	sta	INDEX+1			; set line start pointer HB
	bcc	A_A53C			; go do next line, branch always

A_A55F					;				[A55F]
	rts


;******************************************************************************
;
; call for BASIC input

InputNewLine				;				[A560]
	ldx	#$00			; set channel $00, keyboard
A_A562					;				[A562]
	jsr	InpCharErrChan		; input character from channel with
					; error check			[E112]
	cmp	#'{cr}'			; compare with [CR]
	beq	A_A576			; if [CR] set XY to Command buffer - 1,
					; print [CR] and exit
; character was not [CR]
	sta	CommandBuf,X		; save character to buffer

	inx				; increment buffer index
	cpx	#$59			; compare with max+1
	bcc	A_A562			; branch if < max+1

	ldx	#$17			; error $17, string too long error
	jmp	OutputErrMsg		; do error #X then warm start	[A437]

A_A576					;				[A576]
	jmp	SetXY2CmdBuf		; set XY to Command buffer - 1 and
					; print [CR]			[AACA]


;******************************************************************************
;
; crunch BASIC tokens vector

Text2TokenCode				;				[A579]
	jmp	(ICRNCH)		; do crunch BASIC tokens


;******************************************************************************
;
; crunch BASIC tokens, the crunch BASIC tokens vector is initialised to point
; here

Text2TokenCod2				;				[A57C]
	ldx	TXTPTR			; get BASIC execute pointer LB
	ldy	#$04			; set save index
	sty	GARBFL			; clear open quote/DATA flag
A_A582					;				[A582]
	lda	CommandBuf,X		; get a byte from the input buffer
	bpl	A_A58E			; if b7 clear go do crunching

	cmp	#TK_PI			; compare with the token for PI, this
					; toke is input directly from the
					; keyboard as the PI character
	beq	A_A5C9			; if PI then save byte and continue
					; crunching

; this is the bit of code that stops you being able to enter some keywords as
; just single shifted characters. If this dropped through you would be able to
; enter GOTO as just [SHIFT]G

	inx				; increment read index
	bne	A_A582			; loop if more to do, branch always

A_A58E					;				[A58E]
	cmp	#' '			; compare with [SPACE]
	beq	A_A5C9			; if [SPACE] save byte then continue
					; crunching

	sta	ENDCHR			; save buffer byte as search character

	cmp	#'"'			; compare with quote character
	beq	A_A5EE			; if quote go copy quoted string

	bit	GARBFL			; get open quote/DATA token flag
	bvs	A_A5C9			; branch if b6 of Oquote set, was DATA
					; go save byte then continue crunching

	cmp	#'?'			; compare with "?" character
	bne	A_A5A4			; if not "?" continue crunching

	lda	#TK_PRINT		; else the keyword token is $99, PRINT
	bne	A_A5C9			; go save byte then continue crunching,
					; branch always
A_A5A4					;				[A5A4]
	cmp	#'0'			; compare with "0"
	bcc	A_A5AC			; branch if <, continue crunching

	cmp	#'<'			; compare with "<"
	bcc	A_A5C9			; if <, 0123456789:; go save byte then
					; continue crunching
; gets here with next character not numeric, ";" or ":"
A_A5AC					;				[A5AC]
	sty	FBUFPT			; copy save index

	ldy	#$00			; clear table pointer
	sty	COUNT			; clear word index

	dey				; adjust for pre increment loop

	stx	TXTPTR			; save BASIC execute pointer LB, buffer
					; index
	dex				; adjust for pre increment loop
A_A5B6					;				[A5B6]
	iny				; next table byte
	inx				; next buffer byte
A_A5B8					;				[A5B8]
	lda	CommandBuf,X		; get byte from input buffer
	sec				; set carry for subtract
	sbc	TblBasicCodes,Y		; subtract table byte
	beq	A_A5B6			; go compare next if match

	cmp	#$80			; was it end marker match ?
	bne	A_A5F5			; branch if not, not found keyword

; actually this works even if the input buffer byte is the end marker, i.e. a
; shifted character. As you can't enter any keywords as a single shifted
; character, see above, you can enter keywords in shorthand by shifting any
; character after the first. so RETURN can be entered as R[SHIFT]E, RE[SHIFT]T,
; RET[SHIFT]U or RETU[SHIFT]R. RETUR[SHIFT]N however will not work because the
; [SHIFT]N will match the RETURN end marker so the routine will try to match
; the next character.

; else found keyword
	ora	COUNT			; OR with word index, +$80 in A makes
					; token
A_A5C7					;				[A5C7]
	ldy	FBUFPT			; restore save index

; save byte then continue crunching

A_A5C9					;				[A5C9]
	inx				; increment buffer read index
	iny				; increment save index
	sta	CommandBuf-5,Y		; save byte to output

	lda	CommandBuf-5,Y		; get byte from output, set flags
	beq	A_A609			; branch if was null [EOL]

; A holds the token here
	sec				; set carry for subtract
	sbc	#':'			; subtract ":"
	beq	A_A5DC			; branch if it was (is now $00)

; A now holds token-':'
	cmp	#TK_DATA-':'		; compare with the token for DATA-':'
	bne	A_A5DE			; if not DATA go try REM

; token was : or DATA

A_A5DC					;				[A5DC]
	sta	GARBFL			; save the token-$3A
A_A5DE					;				[A5DE]
	sec				; set carry for subtract
	sbc	#TK_REM-':'		; subtract the token for REM-':'
	bne	A_A582			; if wasn't REM crunch next bit of line
S_A5E3
	sta	ENDCHR			; else was REM so set search for [EOL]

; loop for "..." etc.
A_A5E5					;				[A5E5]
	lda	CommandBuf,X		; get byte from input buffer
	beq	A_A5C9			; if null [EOL] save byte then continue
					; crunching
	cmp	ENDCHR			; compare with stored character
	beq	A_A5C9			; if match save byte then continue
					; crunching
A_A5EE					;				[A5EE]
	iny				; increment save index
	sta	CommandBuf-5,Y		; save byte to output

	inx				; increment buffer index
	bne	A_A5E5			; loop while <> 0, should never reach 0

; not found keyword this go
A_A5F5					;				[A5F5]
	ldx	TXTPTR			; restore BASIC execute pointer LB
	inc	COUNT			; increment word index (next word)

; now find end of this word in the table
A_A5F9					;				[A5F9]
	iny				; increment table index
	lda	TblBasicCodes-1,Y	; get table byte
	bpl	A_A5F9			; loop if not end of word yet

	lda	TblBasicCodes,Y		; get byte from keyword table
	bne	A_A5B8			; go test next word if not zero byte,
					; end of table
; reached end of table with no match
	lda	CommandBuf,X		; restore byte from input buffer
	bpl	A_A5C7			; branch always, all unmatched bytes in
					; the buffer are $00 to $7F, go save
					; byte in output and continue crunching
; reached [EOL]
A_A609					;				[A609]
	sta	STACK+$FD,Y		; save [EOL]

	dec	TXTPTR+1		; decrement BASIC execute pointer HB

	lda	#$FF			; point to start of buffer-1
	sta	TXTPTR			; set BASIC execute pointer LB

	rts


;******************************************************************************
;
; search BASIC for temporary integer line number

CalcStartAddr				;				[A613]
	lda	TXTTAB			; get start of memory LB
	ldx	TXTTAB+1		; get start of memory HB


;******************************************************************************
;
; search Basic for temp integer line number from AX
; returns carry set if found

CalcStartAddr2				;				[A617]
	ldy	#$01			; set index to next line pointer HB
	sta	FacTempStor+8		; save LB as current
	stx	FacTempStor+9		; save HB as current

	lda	(FacTempStor+8),Y	; get next line pointer HB from address
	beq	A_A640			; pointer was zero so done, exit

	iny				; increment index ...
	iny				; ... to line # HB
	lda	LINNUM+1		; get temporary integer HB
	cmp	(FacTempStor+8),Y	; compare with line # HB
	bcc	A_A641			; exit if temp < this line, target line
					; passed
	beq	A_A62E			; go check LB if =

	dey				; else decrement index
	bne	A_A637			; branch always

A_A62E					;				[A62E]
	lda	LINNUM			; get temporary integer LB
	dey				; decrement index to line # LB
	cmp	(FacTempStor+8),Y	; compare with line # LB
	bcc	A_A641			; exit if temp < this line, target line
					; passed
	beq	A_A641			; exit if temp = (found line#)

; not quite there yet
A_A637					;				[A637]
	dey				; decrement index to next line pointer
					; HB
	lda	(FacTempStor+8),Y	; get next line pointer HB
	tax				; copy to X

	dey				; decrement index to next line pointer
					; LB
	lda	(FacTempStor+8),Y	; get next line pointer LB
	bcs	CalcStartAddr2		; go search for line # in temporary
					; integer from AX, carry always set
A_A640					;				[A640]
	clc				; clear found flag
A_A641					;				[A641]
	rts


;******************************************************************************
;
; perform NEW

bcNEW					;				[A642]
	bne	A_A641			; exit if following byte to allow syntax
					; error
bcNEW2					;				[A644]
	lda	#$00			; clear A
	tay				; clear index
	sta	(TXTTAB),Y		; clear pointer to next line LB

	iny				; increment index
	sta	(TXTTAB),Y		; clear pointer to next line HB, erase
					; program
	lda	TXTTAB			; get start of memory LB
	clc				; clear carry for add
	adc	#$02			; add null program length
	sta	VARTAB			; set start of variables LB

	lda	TXTTAB+1		; get start of memory HB
	adc	#$00			; add carry
	sta	VARTAB+1		; set start of variables HB


;******************************************************************************
;
; reset execute pointer and do CLR

ResetExecPtr				;				[A659]
	jsr	SetBasExecPtr		; set BASIC execute pointer to start of
					; memory - 1			[A68E]
	lda	#$00			; set Zb for CLR entry


;******************************************************************************
;
; perform CLR

bcCLR					;				[A65E]
	bne	A_A68D			; exit if following byte to allow syntax
					; error
bcCLR2					;				[A660]
	jsr	CloseAllChan		; close all channels and files	[FFE7]
bcCLR3					;				[A663]
	lda	MEMSIZ			; get end of memory LB
	ldy	MEMSIZ+1		; get end of memory HB
	sta	FRETOP			; set bottom of string space LB, clear
					; strings
	sty	FRETOP+1		; set bottom of string space HB

	lda	VARTAB			; get start of variables LB
	ldy	VARTAB+1		; get start of variables HB
	sta	ARYTAB			; set end of variables LB, clear
					; variables
	sty	ARYTAB+1		; set end of variables HB
	sta	STREND			; set end of arrays LB, clear arrays
	sty	STREND+1		; set end of arrays HB


;******************************************************************************
;
; do RESTORE and clear stack

bcCLR4					;				[A677]
	jsr	bcRESTORE		; perform RESTORE		[A81D]


;******************************************************************************
;
; flush BASIC stack and clear the continue pointer

ClrBasicStack				;				[A67A]
	ldx	#LASTPT+2		; get the descriptor stack start
	stx	TEMPPT			; set the descriptor stack pointer

	pla				; pull the return address LB
	tay				; copy it

	pla				; pull the return address HB

	ldx	#$FA			; set the cleared stack pointer
	txs				; set the stack

	pha				; push the return address HB

	tya				; restore the return address LB
	pha				; push the return address LB

	lda	#$00			; clear A
	sta	OLDTXT+1		; clear the continue pointer HB
	sta	SUBFLG			; clear the subscript/FNX flag
A_A68D					;				[A68D]
	rts


;******************************************************************************
;
; set BASIC execute pointer to start of memory - 1

SetBasExecPtr				;				[A68E]
	clc				; clear carry for add
	lda	TXTTAB			; get start of memory LB
	adc	#$FF			; add -1 LB
	sta	TXTPTR			; set BASIC execute pointer LB

	lda	TXTTAB+1		; get start of memory HB
	adc	#$FF			; add -1 HB
	sta	TXTPTR+1		; save BASIC execute pointer HB

	rts


;******************************************************************************
;
; perform LIST

bcLIST					;				[A69C]
	bcc	A_A6A4			; branch if next character not token
					; (LIST n...)
	beq	A_A6A4			; branch if next character [NULL] (LIST)

	cmp	#TK_MINUS		; compare with token for -
	bne	A_A68D			; exit if not - (LIST -m)

; LIST [[n][-m]]
; this bit sets the n , if present, as the start and end
A_A6A4					;				[A6A4]
	jsr	LineNum2Addr		; get fixed-point number into temporary
					; integer			[A96B]
	jsr	CalcStartAddr		; search BASIC for temporary integer
					; line number	[A613]
	jsr	CHRGOT			; scan memory			[0079]
	beq	A_A6BB			; branch if no more chrs

; this bit checks the - is present
	cmp	#TK_MINUS		; compare with token for -
	bne	A_A641			; return if not "-" (will be SN error)

; LIST [n]-m
; the - was there so set m as the end value
	jsr	CHRGET			; increment and scan memory	[0073]

	jsr	LineNum2Addr		; get fixed-point number into temporary
					; integer			[A96B]
	bne	A_A641			; exit if not ok
A_A6BB					;				[A6BB]
	pla				; dump return address LB
	pla				; dump return address HB

	lda	LINNUM			; get temporary integer LB
	ora	LINNUM+1		; OR temporary integer HB
	bne	A_A6C9			; branch if start set
bcLIST2					;				[A6C3]
	lda	#$FF			; set for -1
	sta	LINNUM			; set temporary integer LB
	sta	LINNUM+1		; set temporary integer HB
A_A6C9					;				[A6C9]
	ldy	#$01			; set index for line
	sty	GARBFL			; clear open quote flag

	lda	(FacTempStor+8),Y	; get next line pointer HB
	beq	A_A714			; if null all done so exit

	jsr	BasChkStopKey		; do CRTL-C check vector	[A82C]
bcLIST3					;				[A6D4]
	jsr	OutCRLF			; print CR/LF			[AAD7]

	iny				; increment index for line
	lda	(FacTempStor+8),Y	; get line number LB
	tax				; copy to X

	iny				; increment index
	lda	(FacTempStor+8),Y	; get line number HB
	cmp	LINNUM+1		; compare with temporary integer HB
	bne	A_A6E6			; branch if no HB match

	cpx	LINNUM			; compare with temporary integer LB
	beq	A_A6E8			; branch if = last line to do, < will
					; pass next branch
A_A6E6					; else ...:
	bcs	A_A714			; if greater all done so exit
A_A6E8					;				[A6E8]
	sty	FORPNT			; save index for line

	jsr	PrintXAasInt		; print XA as unsigned integer	[BDCD]

	lda	#' '			; space is the next character
A_A6EF					;				[A6EF]
	ldy	FORPNT			; get index for line
	and	#$7F			; mask top out bit of character
A_A6F3					;				[A6F3]
	jsr	PrintChar		; go print the character	[AB47]
	cmp	#'"'			; was it " character
	bne	A_A700			; if not skip the quote handle

; we are either entering or leaving a pair of quotes
	lda	GARBFL			; get open quote flag
	eor	#$FF			; toggle it
	sta	GARBFL			; save it back
A_A700					;				[A700]
	iny				; increment index
	beq	A_A714			; line too long so just bail out and do
					; a warm start
	lda	(FacTempStor+8),Y	; get next byte
	bne	TokCode2Text		; if not [EOL] (go print character)

; was [EOL]
	tay				; else clear index
	lda	(FacTempStor+8),Y	; get next line pointer LB
	tax				; copy to X

	iny				; increment index
	lda	(FacTempStor+8),Y	; get next line pointer HB
	stx	FacTempStor+8		; set pointer to line LB
	sta	FacTempStor+9		; set pointer to line HB
	bne	A_A6C9			; go do next line if not [EOT]
					; else ...
A_A714					;				[A714]
	jmp	BasWarmStart2		; do warm start			[E386]


;******************************************************************************
;
; uncrunch BASIC tokens

TokCode2Text				;				[A717]
	jmp	(IQPLOP)		; do uncrunch BASIC tokens


;******************************************************************************
;
; uncrunch BASIC tokens, the uncrunch BASIC tokens vector is initialised to
; point here

TokCode2Text2				;				[A71A]
	bpl	A_A6F3			; just go print it if not token byte
					; else was token byte so uncrunch it

	cmp	#TK_PI			; compare with the token for PI. in this
					; case the token is the same as the PI
					; character so it just needs printing
	beq	A_A6F3			; just print it if so

	bit	GARBFL			; test the open quote flag
	bmi	A_A6F3			; just go print char if open quote set

	sec				; else set carry for subtract
	sbc	#$7F			; reduce token range to 1 to whatever
	tax				; copy token # to X

	sty	FORPNT			; save index for line

	ldy	#$FF			; start from -1, adjust for pre-
					; increment
A_A72C					;				[A72C]
	dex				; decrement token #
	beq	A_A737			; if now found go do printing
A_A72F					;				[A72F]
	iny				; else increment index
	lda	TblBasicCodes,Y		; get byte from keyword table
	bpl	A_A72F			; loop until keyword end marker

	bmi	A_A72C			; go test if this is required keyword,
					; branch always
; found keyword, it's the next one
A_A737					;				[A737]
	iny				; increment keyword table index
	lda	TblBasicCodes,Y		; get byte from table
	bmi	A_A6EF			; go restore index, mask byte and print
					; if byte was end marker
	jsr	PrintChar		; else go print the character	[AB47]
	bne	A_A737			; go get next character, branch always


;******************************************************************************
;
; perform FOR

bcFOR					;				[A742]
	lda	#$80			; set FNX
	sta	SUBFLG			; set subscript/FNX flag

	jsr	bcLET			; perform LET			[A9A5]

	jsr	SrchForNext		; search stack for FOR or GOSUB activity
					;				[A38A]
	bne	A_A753			; branch if FOR not found

; FOR, this variable, was found so first we dump the old one
	txa				; copy index
	adc	#$0F			; add FOR structure size-2
	tax				; copy to index
	txs				; set stack (dump FOR structure)
A_A753					;				[A753]
	pla				; pull return address
	pla				; pull return address

	lda	#$09			; we need 18d bytes !
	jsr	CheckRoomStack		; check room on stack for 2*A bytes
					;				[A3FB]
	jsr	FindNextColon		; scan for next BASIC statement ([:] or
					; [EOL])			[A906]

	clc				; clear carry for add
	tya				; copy index to A
	adc	TXTPTR			; add BASIC execute pointer LB
	pha				; push onto stack

	lda	TXTPTR+1		; get BASIC execute pointer HB
	adc	#$00			; add carry
	pha				; push onto stack

	lda	CURLIN+1		; get current line number HB
	pha				; push onto stack

	lda	CURLIN			; get current line number LB
	pha				; push onto stack

	lda	#TK_TO			; set "TO" token
	jsr	Chk4CharInA		; scan for CHR$(A), else do syntax error
					; then warm start		[AEFF]
	jsr	CheckIfNumeric		; check if source is numeric, else do
					; type mismatch			[AD8D]
	jsr	EvalExpression		; evaluate expression and check is
					; numeric, else do type mismatch [AD8A]
	lda	FACSGN			; get FAC1 sign (b7)
	ora	#$7F			; set all non sign bits
	and	FacMantissa		; and FAC1 mantissa 1
	sta	FacMantissa		; save FAC1 mantissa 1

	lda	#<bcFOR2		; set return address LB
	ldy	#>bcFOR2		; set return address HB
	sta	INDEX			; save return address LB
	sty	INDEX+1			; save return address HB

	jmp	FAC1ToStack		; round FAC1 and put on stack, returns
					; to next instruction		[AE43]

bcFOR2					;				[A78B]
	lda	#<Constant1		; set 1 pointer low address, default
					; step size
	ldy	#>Constant1		; set 1 pointer high address
	jsr	UnpackAY2FAC1		; unpack memory (AY) into FAC1	[BBA2]

	jsr	CHRGOT			; scan memory			[0079]
	cmp	#TK_STEP		; compare with STEP token
	bne	A_A79F			; if not "STEP" continue

; was step so ....

	jsr	CHRGET			; increment and scan memory	[0073]
	jsr	EvalExpression		; evaluate expression and check is
					; numeric, else do type mismatch [AD8A]
A_A79F					;				[A79F]
	jsr	GetFacSign		; get FAC1 sign, return A = $FF -ve,
					; A = $01 +ve	[BC2B]
	jsr	SgnFac1ToStack		; push sign, round FAC1 and put on stack
					;				[AE38]

	lda	FORPNT+1		; get FOR/NEXT variable pointer HB
	pha				; push on stack

	lda	FORPNT			; get FOR/NEXT variable pointer LB
	pha				; push on stack

	lda	#TK_FOR			; get FOR token
	pha				; push on stack


;******************************************************************************
;
; interpreter inner loop

InterpretLoop				;				[A7AE]
	jsr	BasChkStopKey		; do CRTL-C check vector	[A82C]

	lda	TXTPTR			; get the BASIC execute pointer LB
	ldy	TXTPTR+1		; get the BASIC execute pointer HB
	cpy	#$02			; compare the HB with $02xx
	nop				; unused byte
	beq	A_A7BE			; if immediate mode skip the continue
					; pointer save
	sta	OLDTXT			; save the continue pointer LB
	sty	OLDTXT+1		; save the continue pointer HB
A_A7BE					;				[A7BE]
	ldy	#$00			; clear the index
	lda	(TXTPTR),Y		; get a BASIC byte
	bne	A_A807			; if not [EOL] go test for ":"

	ldy	#$02			; else set the index
	lda	(TXTPTR),Y		; get next line pointer HB
	clc				; clear carry for no "BREAK" message
	bne	A_A7CE			; branch if not end of program

	jmp	bcEND2			; else go to immediate mode, was
					; immediate or [EOT] marker	[A84B]
A_A7CE					;				[A7CE]
	iny				; increment index
	lda	(TXTPTR),Y		; get line number LB
	sta	CURLIN			; save current line number LB

	iny				; increment index
	lda	(TXTPTR),Y		; get line # HB
	sta	CURLIN+1		; save current line number HB

	tya				; A now = 4
	adc	TXTPTR			; add BASIC execute pointer LB, now
					; points to code
	sta	TXTPTR			; save BASIC execute pointer LB
	bcc	InterpretLoop2		; branch if no overflow

	inc	TXTPTR+1		; else increment BASIC execute pointer
					; HB
InterpretLoop2				;				[A7E1]
	jmp	(IGONE)			; do start new BASIC code


;******************************************************************************
;
; start new BASIC code, the start new BASIC code vector is initialised to point
; here

InterpretLoop3				;				[A7E4]
	jsr	CHRGET			; increment and scan memory	[0073]
	jsr	DecodeBASIC		; go interpret BASIC code from BASIC
					; execute pointer		[A7ED]
	jmp	InterpretLoop		; loop				[A7AE]


;******************************************************************************
;
; go interpret BASIC code from BASIC execute pointer

DecodeBASIC				;				[A7ED]
	beq	A_A82B			; if the first byte is null just exit

DecodeBASIC2				;				[A7EF]
	sbc	#$80			; normalise the token
	bcc	A_A804			; if wasn't token go do LET

	cmp	#TK_TAB-$80		; compare with token for TAB(-$80
	bcs	A_A80E			; branch if >= TAB(

	asl				; *2 bytes per vector
	tay				; copy to index

	lda	TblBasicInstr+1,Y	; get vector HB
	pha				; push on stack

	lda	TblBasicInstr,Y		; get vector LB
	pha				; push on stack

	jmp	CHRGET			; increment and scan memory and return.
					; The return in	[0073] this case calls
					; the command code, the return from
					; that will eventually return to the
					; interpreter inner loop above
A_A804					;				[A804]
	jmp	bcLET			; perform LET			[A9A5]

; was not [EOL]
A_A807					;				[A807]
	cmp	#':'			; comapre with ":"
	beq	InterpretLoop2		; if ":" go execute new code

; else ...
A_A80B					;				[A80B]
	jmp	SyntaxError		; do syntax error then warm start [AF08]

; token was >= TAB(
A_A80E					;				[A80E]
	cmp	#TK_GO-$80		; compare with the token for GO
	bne	A_A80B			; if not "GO" do syntax error then warm
					; start
; else was "GO"

	jsr	CHRGET			; increment and scan memory	[0073]

	lda	#TK_TO			; set "TO" token
	jsr	Chk4CharInA		; scan for CHR$(A), else do syntax error
					; then warm start		[AEFF]

	jmp	bcGOTO			; perform GOTO			[A8A0]


;******************************************************************************
;
; perform RESTORE

bcRESTORE
	sec				; set carry for subtract
	lda	TXTTAB			; get start of memory LB
	sbc	#$01			; -1
	ldy	TXTTAB+1		; get start of memory HB
	bcs	bcRESTORE2		; branch if no rollunder

	dey				; else decrement HB
bcRESTORE2				;				[A827]
	sta	DATPTR			; set DATA pointer LB
	sty	DATPTR+1		; set DATA pointer HB
A_A82B					;				[A82B]
	rts


;******************************************************************************
;
; do CRTL-C check vector

BasChkStopKey				;				[A82C]
	jsr	ScanStopKey		; scan stop key			[FFE1]


;******************************************************************************
;
; perform STOP

bcSTOP
	bcs	A_A832			; if carry set do BREAK instead of just
					; END

;******************************************************************************
;
; perform END

bcEND
	clc				; clear carry
A_A832					;				[A832]
	bne	A_A870			; return if wasn't CTRL-C

	lda	TXTPTR			; get BASIC execute pointer LB
	ldy	TXTPTR+1		; get BASIC execute pointer HB
	ldx	CURLIN+1		; get current line number HB

	inx				; increment it
	beq	A_A849			; branch if was immediate mode

	sta	OLDTXT			; save continue pointer LB
	sty	OLDTXT+1		; save continue pointer HB

	lda	CURLIN			; get current line number LB
	ldy	CURLIN+1		; get current line number HB
	sta	OLDLIN			; save break line number LB
	sty	OLDLIN+1		; save break line number HB
A_A849					;				[A849]
	pla				; dump return address LB
	pla				; dump return address HB
bcEND2					;				[A84B]
	lda	#<TxtBreak		; set [CR][LF]"BREAK" pointer LB
	ldy	#>TxtBreak		; set [CR][LF]"BREAK" pointer HB
	bcc	A_A854			; if was program end skip the print
					; string
	jmp	OutputMessage		; print string and do warm start [A469]

A_A854					;				[A854]
	jmp	BasWarmStart2		; do warm start			[E386]


;******************************************************************************
;
; perform CONT

bcCONT
	bne	A_A870			; exit if following byte to allow
					; syntax error
	ldx	#$1A			; error code $1A, can't continue error
	ldy	OLDTXT+1		; get continue pointer HB
	bne	A_A862			; go do continue if we can

	jmp	OutputErrMsg		; else do error #X then warm start
					; [A437]
; we can continue so ...
A_A862					;				[A862]
	lda	OLDTXT			; get continue pointer LB
	sta	TXTPTR			; save BASIC execute pointer LB

	sty	TXTPTR+1		; save BASIC execute pointer HB

	lda	OLDLIN			; get break line LB
	ldy	OLDLIN+1		; get break line HB
	sta	CURLIN			; set current line number LB
	sty	CURLIN+1		; set current line number HB
A_A870					;				[A870]
	rts


;******************************************************************************
;
; perform RUN

bcRUN
	php				; save status

	lda	#$00			; no control or kernal messages
	jsr	CtrlKernalMsg		; control kernal messages	[FF90]

	plp				; restore status
	bne	A_A87D			; branch if RUN n

	jmp	ResetExecPtr		; reset execution to start, clear
					; variables, flush stack	[A659]
					; and return
A_A87D					;				[A87D]
	jsr	bcCLR2			; go do "CLEAR"			[A660]
	jmp	bcGOSUB2		; get n and do GOTO n		[A897]


;******************************************************************************
;
; perform GOSUB

bcGOSUB
	lda	#$03			; need 6 bytes for GOSUB
	jsr	CheckRoomStack		; check room on stack for 2*A bytes
					;				[A3FB]
	lda	TXTPTR+1		; get BASIC execute pointer HB
	pha				; save it

	lda	TXTPTR			; get BASIC execute pointer LB
	pha				; save it

	lda	CURLIN+1		; get current line number HB
	pha				; save it

	lda	CURLIN			; get current line number LB
	pha				; save it

	lda	#TK_GOSUB		; token for GOSUB
	pha				; save it
bcGOSUB2				;				[A897]
	jsr	CHRGOT			; scan memory			[0079]
	jsr	bcGOTO			; perform GOTO			[A8A0]
	jmp	InterpretLoop		; go do interpreter inner loop	[A7AE]


;******************************************************************************
;
; perform GOTO

bcGOTO
	jsr	LineNum2Addr		; get fixed-point number into temporary
					; integer			[A96B]
	jsr	FindEndOfLine		; scan for next BASIC line	[A909]

	sec				; set carry for subtract
	lda	CURLIN			; get current line number LB
	sbc	LINNUM			; subtract temporary integer LB

	lda	CURLIN+1		; get current line number HB
	sbc	LINNUM+1		; subtract temporary integer HB
	bcs	A_A8BC			; if current line number >= temporary
					; integer, go search from the start of
					; memory
	tya				; else copy line index to A
	sec				; set carry (+1)
	adc	TXTPTR			; add BASIC execute pointer LB
	ldx	TXTPTR+1		; get BASIC execute pointer HB
	bcc	A_A8C0			; branch if no overflow to HB

	inx				; increment HB
	bcs	A_A8C0			; branch always (can never be carry)


;******************************************************************************
;
; search for line number in temporary integer from start of memory pointer

A_A8BC					;				[A8BC]
	lda	TXTTAB			; get start of memory LB
	ldx	TXTTAB+1		; get start of memory HB


;******************************************************************************
;
; search for line # in temporary integer from (AX)

A_A8C0					;				[A8C0]
	jsr	CalcStartAddr2		; search Basic for temp integer line
					; number from AX		[A617]
	bcc	A_A8E3			; if carry clear go do unsdefined
					; statement error
; carry all ready set for subtract
	lda	FacTempStor+8		; get pointer LB
	sbc	#$01			; -1
	sta	TXTPTR			; save BASIC execute pointer LB

	lda	FacTempStor+9		; get pointer HB
	sbc	#$00			; subtract carry
	sta	TXTPTR+1		; save BASIC execute pointer HB
A_A8D1					;				[A8D1]
	rts


;******************************************************************************
;
; perform RETURN

bcRETURN
	bne	A_A8D1			; exit if following token to allow
					; syntax error
	lda	#$FF			; set byte so no match possible
	sta	FORPNT+1		; save FOR/NEXT variable pointer HB
	jsr	SrchForNext		; search the stack for FOR or GOSUB
					; activity, get token off stack	[A38A]
	txs				; correct the stack
	cmp	#TK_GOSUB		; compare with GOSUB token
	beq	A_A8EB			; if matching GOSUB go continue RETURN

	ldx	#$0C			; else error code $04, return without
					; gosub error
.byte	$2C				; makes next line BIT $11A2
A_A8E3					;				[A8E3]
	ldx	#$11			; error code $11, undefined statement
					; error
	jmp	OutputErrMsg		; do error #X then warm start	[A437]

A_A8E8					;				[A8E8]
	jmp	SyntaxError		; do syntax error then warm start [AF08]

; was matching GOSUB token
A_A8EB					;				[A8EB]
	pla				; dump token byte
	pla				; pull return line LB
	sta	CURLIN			; save current line number LB
	pla				; pull return line HB
	sta	CURLIN+1		; save current line number HB
	pla				; pull return address LB
	sta	TXTPTR			; save BASIC execute pointer LB
	pla				; pull return address HB
	sta	TXTPTR+1		; save BASIC execute pointer HB


;******************************************************************************
;
; perform DATA

bcDATA
	jsr	FindNextColon		; scan for next BASIC statement ([:] or
					; [EOL])			[A906]

;******************************************************************************
;
; add Y to the BASIC execute pointer

bcDATA2					;				[A8FB]
	tya				; copy index to A
S_A8FC
	clc				; clear carry for add
	adc	TXTPTR			; add BASIC execute pointer LB
	sta	TXTPTR			; save BASIC execute pointer LB
	bcc	A_A905			; skip increment if no carry

	inc	TXTPTR+1		; else increment BASIC execute pointer
					; HB
A_A905					;				[A905]
	rts


;******************************************************************************
;
; scan for next BASIC statement ([:] or [EOL])
; returns Y as index to [:] or [EOL]

FindNextColon				;				[A906]
	ldx	#':'			; set look for character = ":"
.byte	$2C				; makes next line BIT $00A2


;******************************************************************************
;
; scan for next BASIC line
; returns Y as index to [EOL]

FindEndOfLine				;				[A909]
	ldx	#$00			; set alternate search character = [EOL]
	stx	CHARAC			; store alternate search character

	ldy	#$00			; set search character = [EOL]
	sty	ENDCHR			; save the search character
A_A911					;				[A911]
	lda	ENDCHR			; get search character
	ldx	CHARAC			; get alternate search character
	sta	CHARAC			; make search character = alternate
					; search character
FindOtherChar				;				[A917]
	stx	ENDCHR			; make alternate search character =
					; search character
A_A919					;				[A919]
	lda	(TXTPTR),Y		; get BASIC byte
	beq	A_A905			; exit if null [EOL]

	cmp	ENDCHR			; compare with search character
	beq	A_A905			; exit if found

	iny				; else increment index

	cmp	#'"'			; compare current character with open
					; quote
	bne	A_A919			; if found go swap search character for
					; alternate search character
	beq	A_A911			; loop for next character, branch always


;******************************************************************************
;
; perform IF

bcIF
	jsr	EvaluateValue		; evaluate expression		[AD9E]

	jsr	CHRGOT			; scan memory			[0079]
	cmp	#TK_GOTO		; compare with "GOTO" token
	beq	A_A937			; if it was  the token for GOTO go do
					; IF ... GOTO
; wasn't IF ... GOTO so must be IF ... THEN
	lda	#TK_THEN		; set "THEN" token
	jsr	Chk4CharInA		; scan for CHR$(A), else do syntax error
					; then warm start		[AEFF]
A_A937					;				[A937]
	lda	FACEXP			; get FAC1 exponent
	bne	A_A940			; if result was non zero continue
					; execution
; else REM rest of line


;******************************************************************************
;
; perform REM

bcREM
	jsr	FindEndOfLine		; scan for next BASIC line	[A909]
	beq	bcDATA2			; add Y to the BASIC execute pointer and
					; return, branch always

; result was non zero so do rest of line
A_A940					;				[A940]
	jsr	CHRGOT			; scan memory			[0079]
	bcs	A_A948			; branch if not numeric character, is
					; variable or keyword
	jmp	bcGOTO			; else perform GOTO n		[A8A0]

; is variable or keyword
A_A948					;				[A948]
	jmp	DecodeBASIC		; interpret BASIC code from BASIC
					; execute pointer		[A7ED]

;******************************************************************************
;
; perform ON

bcON
	jsr	GetByteParm2		; get byte parameter		[B79E]
	pha				; push next character
	cmp	#TK_GOSUB		; compare with GOSUB token
	beq	A_A957			; if GOSUB go see if it should be
					; executed
A_A953					;				[A953]
	cmp	#TK_GOTO		; compare with GOTO token
	bne	A_A8E8			; if not GOTO do syntax error then warm
					; start
; next character was GOTO or GOSUB, see if it should be executed

A_A957					;				[A957]
	dec	FacMantissa+3		; decrement the byte value
	bne	A_A95F			; if not zero go see if another line
					; number exists
	pla				; pull keyword token
	jmp	DecodeBASIC2		; go execute it			[A7EF]

A_A95F					;				[A95F]
	jsr	CHRGET			; increment and scan memory	[0073]
	jsr	LineNum2Addr		; get fixed-point number into temporary
					; integer			[A96B]
	cmp	#','			; compare next character with ","
	beq	A_A957			; loop if ","

	pla				; else pull keyword token, ran out of
					; options
A_A96A					;				[A96A]
	rts


;******************************************************************************
;
; get fixed-point number into temporary integer

LineNum2Addr				;				[A96B]
	ldx	#$00			; clear X
	stx	LINNUM			; clear temporary integer LB
	stx	LINNUM+1		; clear temporary integer HB
LineNum2Addr2				;				[A971]
	bcs	A_A96A			; return if carry set, end of scan,
					; character was not 0-9
	sbc	#'0'-1			; subtract $30, $2F+carry, from byte
	sta	CHARAC			; store #

	lda	LINNUM+1		; get temporary integer HB
	sta	INDEX			; save it for now
	cmp	#$19			; compare with $19
	bcs	A_A953			; branch if >= this makes the maximum
					; line number 63999 because the next
; bit does $1900 * $0A = $FA00 = 64000 decimal. the branch target is really the
; SYNTAX error at A_A8E8 but that is too far so an intermediate; compare and
; branch to that location is used. the problem with this is that line number
; that gives a partial result from $8900 to $89FF, 35072x to 35327x, will pass
; the new target compare and will try to execute the remainder of the ON n
; GOTO/GOSUB. a solution to this is to copy the byte in A before the branch to
; X and then branch to A_A955 skipping the second compare

	lda	LINNUM			; get temporary integer LB
	asl				; *2 LB
	rol	INDEX			; *2 HB
	asl				; *2 LB
	rol	INDEX			; *2 HB (*4)
	adc	LINNUM			; + LB (*5)
	sta	LINNUM			; save it

	lda	INDEX			; get HB temp
	adc	LINNUM+1		; + HB (*5)
	sta	LINNUM+1		; save it

	asl	LINNUM			; *2 LB (*10d)
	rol	LINNUM+1		; *2 HB (*10d)

	lda	LINNUM			; get LB
	adc	CHARAC			; add #
	sta	LINNUM			; save LB
	bcc	A_A99F			; branch if no overflow to HB

	inc	LINNUM+1		; else increment HB
A_A99F					;				[A99F]
	jsr	CHRGET			; increment and scan memory	[0073]
	jmp	LineNum2Addr2		; loop for next character	[A971]


;******************************************************************************
;
; perform LET

bcLET
	jsr	GetAddrVar		; get variable address		[B08B]
	sta	FORPNT			; save variable address LB
	sty	FORPNT+1		; save variable address HB

	lda	#TK_EQUAL		; $B2 is "=" token
	jsr	Chk4CharInA		; scan for CHR$(A), else do syntax error
					; then warm start		[AEFF]
	lda	INTFLG			; get data type flag, $80 = integer,
					; $00 = float
	pha				; push data type flag

	lda	VALTYP			; get data type flag, $FF = string,
					; $00 = numeric
	pha				; push data type flag

	jsr	EvaluateValue		; evaluate expression		[AD9E]

	pla				; pop data type flag
	rol				; string bit into carry
	jsr	ChkIfNumStr		; do type match check		[AD90]
	bne	A_A9D9			; branch if string

	pla				; pop integer/float data type flag

; assign value to numeric variable

SetIntegerVar				;				[A9C2]
	bpl	A_A9D6			; branch if float

; expression is numeric integer
	jsr	RoundFAC1		; round FAC1			[BC1B]
	jsr	EvalInteger3		; evaluate integer expression, no sign
					; check				[B1BF]
	ldy	#$00			; clear index
	lda	FacMantissa+2		; get FAC1 mantissa 3
	sta	(FORPNT),Y		; save as integer variable LB

	iny				; increment index
	lda	FacMantissa+3		; get FAC1 mantissa 4
	sta	(FORPNT),Y		; save as integer variable HB

	rts

; Set the value of a real variable
A_A9D6					;				[A9D6]
	jmp	Fac1ToVarPtr		; pack FAC1 into variable pointer and
					; return			[BBD0]

; assign value to numeric variable

A_A9D9					;				[A9D9]
	pla				; dump integer/float data type flag
SetValueString				;				[A9DA]
	ldy	FORPNT+1		; get variable pointer HB
	cpy	#>L_BF13		; was it TI$ pointer
	bne	A_AA2C			; branch if not

; else it's TI$ = <expr$>
	jsr	PopStrDescStk		; pop string off descriptor stack, or
					; from top of string space returns with
					; A = length, X = pointer LB, Y =
					; pointer HB			[B6A6]
	cmp	#$06			; compare length with 6
	bne	A_AA24			; if length not 6 do illegal quantity
					; error then warm start
	ldy	#$00			; clear index
	sty	FACEXP			; clear FAC1 exponent
	sty	FACSGN			; clear FAC1 sign (b7)
A_A9ED					;				[A9ED]
	sty	FBUFPT			; save index

	jsr	ChkCharIsNum		; check and evaluate numeric digit
					;				[AA1D]
	jsr	Fac1x10			; multiply FAC1 by 10		[BAE2]

	inc	FBUFPT			; increment index

	ldy	FBUFPT			; restore index
	jsr	ChkCharIsNum		; check and evaluate numeric digit
					;				[AA1D]
	jsr	CopyFAC1toFAC2		; round and copy FAC1 to FAC2	[BC0C]
	tax				; copy FAC1 exponent
	beq	A_AA07			; branch if FAC1 zero

	inx				; increment index, * 2
	txa				; copy back to A

	jsr	FAC1plFAC2x2		; FAC1 = (FAC1 + (FAC2 * 2)) * 2 =
					; FAC1 * 6			[BAED]
A_AA07					;				[AA07]
	ldy	FBUFPT			; get index
	iny				; increment index
	cpy	#$06			; compare index with 6
	bne	A_A9ED			; loop if not 6

	jsr	Fac1x10			; multiply FAC1 by 10		[BAE2]
	jsr	FAC1Float2Fix		; convert FAC1 floating to fixed [BC9B]

	ldx	FacMantissa+2		; get FAC1 mantissa 3
	ldy	FacMantissa+1		; get FAC1 mantissa 2
	lda	FacMantissa+3		; get FAC1 mantissa 4

	jmp	SetClock		; set real time clock and return [FFDB]


;******************************************************************************
;
; check and evaluate numeric digit

ChkCharIsNum				;				[AA1D]
	lda	(INDEX),Y		; get byte from string
	jsr	NumericTest		; clear Cb if numeric. this call should
					; be to $84 as the code from NumericTest
					; first comapres the byte with [SPACE]
					; and does a BASIC increment and get if
					; it is				[0080]
	bcc	A_AA27			; branch if numeric
A_AA24					;				[AA24]
	jmp	IllegalQuant		; do illegal quantity error then warm
					; start				[B248]
A_AA27					;				[AA27]
	sbc	#'0'-1			; subtract $2F + carry to convert ASCII
					; to binary
	jmp	EvalNewDigit		; evaluate new ASCII digit and return
					;				[BD7E]

;******************************************************************************
;
; assign value to numeric variable, but not TI$

A_AA2C					;				[AA2C]
	ldy	#$02			; index to string pointer HB
	lda	(FacMantissa+2),Y	; get string pointer HB
	cmp	FRETOP+1		; compare with bottom of string space HB
	bcc	A_AA4B			; branch if string pointer HB is less
					; than bottom of string space HB

	bne	A_AA3D			; branch if string pointer HB is greater
					; than bottom of string space HB

; else HBs were equal
	dey				; decrement index to string pointer LB
	lda	(FacMantissa+2),Y	; get string pointer LB
	cmp	FRETOP			; compare with bottom of string space LB
	bcc	A_AA4B			; branch if string pointer LB is less
					; than bottom of string space LB

A_AA3D					;				[AA3D]
	ldy	FacMantissa+3		; get descriptor pointer HB
	cpy	VARTAB+1		; compare with start of variables HB
	bcc	A_AA4B			; branch if less, is on string stack

	bne	A_AA52			; if greater make space and copy string

; else HBs were equal
	lda	FacMantissa+2		; get descriptor pointer LB
	cmp	VARTAB			; compare with start of variables LB
	bcs	A_AA52			; if greater or equal make space and
					; copy string
A_AA4B					;				[AA4B]
	lda	FacMantissa+2		; get descriptor pointer LB
	ldy	FacMantissa+3		; get descriptor pointer HB
	jmp	A_AA68			; go copy descriptor to variable [AA68]

A_AA52					;				[AA52]
	ldy	#$00			; clear index
	lda	(FacMantissa+2),Y	; get string length
	jsr	StringVector		; copy descriptor pointer and make
					; string space A bytes long	[B475]
	lda	TempPtr			; copy old descriptor pointer LB
	ldy	TempPtr+1		; copy old descriptor pointer HB
	sta	ARISGN			; save old descriptor pointer LB
	sty	FACOV			; save old descriptor pointer HB

	jsr	Str2UtilPtr		; copy string from descriptor to utility
					; pointer			[B67A]

	lda	#<FACEXP		; get descriptor pointer LB
	ldy	#>FACEXP		; get descriptor pointer HB
A_AA68					;				[AA68]
	sta	TempPtr			; save descriptor pointer LB
	sty	TempPtr+1		; save descriptor pointer HB

	jsr	ClrDescrStack		; clean descriptor stack, YA = pointer
					;				[B6DB]
	ldy	#$00			; clear index
	lda	(TempPtr),Y		; get string length from new descriptor
	sta	(FORPNT),Y		; copy string length to variable

	iny				; increment index
	lda	(TempPtr),Y		; get string pointer LB from new
					; descriptor
	sta	(FORPNT),Y		; copy string pointer LB to variable

	iny				; increment index
	lda	(TempPtr),Y		; get string pointer HB from new
					; descriptor
	sta	(FORPNT),Y		; copy string pointer HB to variable

	rts


;******************************************************************************
;
; perform PRINT#

bcPRINTH
	jsr	bcCMD			; perform CMD			[AA86]
	jmp	bcINPUTH2		; close input and output channels and
					; return			[ABB5]

;******************************************************************************
;
; perform CMD

bcCMD
	jsr	GetByteParm2		; get byte parameter		[B79E]
	beq	A_AA90			; branch if following byte is ":" or
					; [EOT]
	lda	#','			; set ","
	jsr	Chk4CharInA		; scan for CHR$(A), else do syntax error
					; then warm start		[AEFF]
A_AA90					;				[AA90]
	php				; save status

	stx	CurIoChan		; set current I/O channel

	jsr	OpenChan4OutpA		; open channel for output with error
					; check				[E118]
	plp				; restore status
	jmp	bcPRINT			; perform PRINT			[AAA0]

A_AA9A					;				[AA9A]
	jsr	OutputString2		; print string from utility pointer
					;				[AB21]
A_AA9D					;				[AA9D]
	jsr	CHRGOT			; scan memory			[0079]


;******************************************************************************
;
; perform PRINT

bcPRINT
	beq	OutCRLF			; if nothing following just print CR/LF

bcPRINT2				;				[AAA2]
	beq	A_AAE7			; exit if nothing following, end of
					; PRINT branch
	cmp	#TK_TAB			; compare with token for TAB(
	beq	A_AAF8			; if TAB( go handle it

	cmp	#TK_SPC			; compare with token for SPC(
	clc				; flag SPC(
	beq	A_AAF8			; if SPC( go handle it

	cmp	#','			; compare with ","
	beq	A_AAE8			; if "," go skip to the next TAB
					; position
	cmp	#';'			; compare with ";"
	beq	A_AB13			; if ";" go continue the print loop

	jsr	EvaluateValue		; evaluate expression		[AD9E]
	bit	VALTYP			; test data type flag, $FF = string,
					; $00 = numeric
	bmi	A_AA9A			; if string go print string, scan memory
					; and continue PRINT

	jsr	FAC1toASCII		; convert FAC1 to ASCII string result
					; in (AY)			[BDDD]
	jsr	QuoteStr2UtPtr		; print " terminated string to utility
					; pointer			[B487]
	jsr	OutputString2		; print string from utility pointer
					;				[AB21]
	jsr	PrintSpace		; print [SPACE] or [CURSOR RIGHT] [AB3B]
	bne	A_AA9D			; always -> go scan memory and continue
					; PRINT

;******************************************************************************
;
; set XY to CommandBuf - 1

SetXY2CmdBuf				;				[AACA]
	lda	#$00			; clear A
	sta	CommandBuf,X		; clear first byte of input buffer

	ldx	#<(CommandBuf-1)	; CommandBuf - 1 LB
	ldy	#>(CommandBuf-1)	; CommandBuf - 1 HB

	lda	CurIoChan		; get current I/O channel
	bne	A_AAE7			; exit if not default channel


;******************************************************************************
;
; print CR/LF

OutCRLF					;				[AAD7]
	lda	#'{cr}'			; set [CR]
	jsr	PrintChar		; print the character		[AB47]
	bit	CurIoChan		; test current I/O channel
	bpl	EOR_FF			; if ?? toggle A, EOR #$FF and return

	lda	#'{lf}'			; set [LF]
	jsr	PrintChar		; print the character		[AB47]

; toggle A

EOR_FF					;				[AAE5]
	eor	#$FF			; invert A
A_AAE7					;				[AAE7]
	rts

; was ","
A_AAE8					;				[AAE8]
	sec				; set C flag for read cursor position
	jsr	CursorPosXY		; read/set X,Y cursor position	[FFF0]
	tya				; copy cursor Y

	sec				; set carry for subtract
A_AAEE					;				[AAEE]
	sbc	#$0A			; subtract one TAB length
	bcs	A_AAEE			; loop if result was +ve

	eor	#$FF			; complement it
	adc	#$01			; +1, twos complement
	bne	A_AB0E			; always print A spaces, result is
					; never $00
A_AAF8					;				[AAF8]
	php				; save TAB( or SPC( status

	sec				; set Cb for read cursor position
	jsr	CursorPosXY		; read/set X,Y cursor position	[FFF0]
	sty	TRMPOS			; save current cursor position

	jsr	GetByteParm		; scan and get byte parameter	[B79B]
	cmp	#')'			; compare with ")"
	bne	A_AB5F			; if not ")" do syntax error

	plp				; restore TAB( or SPC( status
	bcc	A_AB0F			; branch if was SPC(

; else was TAB(
	txa				; copy TAB() byte to A
	sbc	TRMPOS			; subtract current cursor position
	bcc	A_AB13			; go loop for next if already past
					; requited position
A_AB0E					;				[AB0E]
	tax				; copy [SPACE] count to X
A_AB0F					;				[AB0F]
	inx				; increment count
A_AB10					;				[AB10]
	dex				; decrement count
	bne	A_AB19			; branch if count was not zero

; was ";" or [SPACES] printed
A_AB13					;				[AB13]
	jsr	CHRGET			; increment and scan memory	[0073]
	jmp	bcPRINT2		; continue print loop		[AAA2]

A_AB19					;				[AB19]
	jsr	PrintSpace		; print [SPACE] or [CURSOR RIGHT] [AB3B]
	bne	A_AB10			; loop, branch always


;******************************************************************************
;
; print null terminated string

OutputString				;				[AB1E]
	jsr	QuoteStr2UtPtr		; print " terminated string to utility
					; pointer			[B487]

;******************************************************************************
;
; print string from utility pointer

OutputString2				;				[AB21]
	jsr	PopStrDescStk		; pop string off descriptor stack, or
					; from top of string		[B6A6]
					; space returns with A = length,
					; X = pointer LB, Y = pointer HB
	tax				; copy length

	ldy	#$00			; clear index
	inx				; increment length, for pre decrement
					; loop
OutputString3				;				[AB28]
	dex				; decrement length
	beq	A_AAE7			; exit if done

	lda	(INDEX),Y		; get byte from string
	jsr	PrintChar		; print the character		[AB47]

	iny				; increment index

	cmp	#'{cr}'			; compare byte with [CR]
	bne	OutputString3		; loop if not [CR]

	jsr	EOR_FF			; toggle A, EOR #$FF. what is the point
					; of this ??			[AAE5]
	jmp	OutputString3		; loop				[AB28]


;******************************************************************************
;
; print [SPACE] or [CURSOR RIGHT]

PrintSpace				;				[AB3B]
	lda	CurIoChan		; get current I/O channel
	beq	A_AB42			; if default channel go output
					; [CURSOR RIGHT]
	lda	#' '			; else output [SPACE]
.byte	$2C				; makes next line BIT $1DA9
A_AB42					;				[AB42]
	lda	#$1D			; set [CURSOR RIGHT]
.byte	$2C				; makes next line BIT $3FA9


;******************************************************************************
;
; print "?"

PrintQuestMark				;				[AB45]
	lda	#'?'			; set "?"


;******************************************************************************
;
; print character

PrintChar				;				[AB47]
	jsr	OutCharErrChan		; output character to channel with
					; error check			[E10C]
	and	#$FF			; set the flags on A
	rts


;******************************************************************************
;
; bad input routine
; Check the variable INPFLG where the error lays

CheckINPFLG				;				[AB4D]
	lda	INPFLG			; get INPUT mode flag, $00 = INPUT,
					; $40 = GET, $98 = READ
	beq	A_AB62			; branch if INPUT

	bmi	A_AB57			; branch if READ

; else was GET
	ldy	#$FF			; set current line HB to -1, indicate
					; immediate mode
	bne	A_AB5B			; branch always

; error with READ
A_AB57					;				[AB57]
	lda	DATLIN			; get current DATA line number LB
	ldy	DATLIN+1		; get current DATA line number HB

; error with GET
A_AB5B					;				[AB5B]
	sta	CURLIN			; set current line number LB
	sty	CURLIN+1		; set current line number HB
A_AB5F					;				[AB5F]
	jmp	SyntaxError		; do syntax error then warm start [AF08]

; was INPUT
; error with INPUT
A_AB62					;				[AB62]
	lda	CurIoChan		; get current I/O channel
	beq	A_AB6B			; branch if default channel

	ldx	#$18			; else error $18, file data error
	jmp	OutputErrMsg		; do error #X then warm start	[A437]

A_AB6B					;				[AB6B]
	lda	#<txtREDOFROM		; set "?REDO FROM START" pointer LB
	ldy	#>txtREDOFROM		; set "?REDO FROM START" pointer HB
	jsr	OutputString		; print null terminated string	[AB1E]

	lda	OLDTXT			; get continue pointer LB
	ldy	OLDTXT+1		; get continue pointer HB
	sta	TXTPTR			; save BASIC execute pointer LB
	sty	TXTPTR+1		; save BASIC execute pointer HB

	rts


;******************************************************************************
;
; perform GET

bcGET
	jsr	ChkDirectMode		; check not Direct, back here if ok
					;				[B3A6]
	cmp	#'#'			; compare with "#"
	bne	A_AB92			; branch if not GET#

	jsr	CHRGET			; increment and scan memory	[0073]
	jsr	GetByteParm2		; get byte parameter		[B79E]

	lda	#','			; set ","
	jsr	Chk4CharInA		; scan for CHR$(A), else do syntax error
					; then warm start		[AEFF]
	stx	CurIoChan		; set current I/O channel

	jsr	OpenChan4Inp0		; open channel for input with error
					; check				[E11E]
A_AB92					;				[AB92]
	ldx	#<CommandBuf+1		; set pointer LB
	ldy	#>CommandBuf+1		; set pointer HB

	lda	#$00			; clear A
	sta	CommandBuf+1		; ensure null terminator

	lda	#$40			; input mode = GET
	jsr	bcREAD2			; perform the GET part of READ	[AC0F]

	ldx	CurIoChan		; get current I/O channel
	bne	A_ABB7			; if not default channel go do channel
					; close and return
	rts


;******************************************************************************
;
; perform INPUT#

bcINPUTH
	jsr	GetByteParm2		; get byte parameter		[B79E]

	lda	#','			; set ","
	jsr	Chk4CharInA		; scan for CHR$(A), else do syntax error
					; then warm start		[AEFF]
	stx	CurIoChan		; set current I/O channel

	jsr	OpenChan4Inp0		; open channel for input with error
					; check				[E11E]
	jsr	bcINPUT2		; perform INPUT with no prompt string
					;				[ABCE]


;******************************************************************************
;
; close input and output channels

bcINPUTH2				;				[ABB5]
	lda	CurIoChan		; get current I/O channel
A_ABB7					;				[ABB7]
	jsr	CloseIoChannls		; close input and output channels [FFCC]

	ldx	#$00			; clear X
	stx	CurIoChan		; clear current I/O channel, flag
					; default
	rts


;******************************************************************************
;
; perform INPUT

bcINPUT
	cmp	#'"'			; compare next byte with open quote
	bne	bcINPUT2		; if no prompt string just do INPUT

	jsr	GetNextParm3		; print "..." string		[AEBD]

	lda	#';'			; load A with ";"
	jsr	Chk4CharInA		; scan for CHR$(A), else do syntax error
					; then warm start		[AEFF]
	jsr	OutputString2		; print string from utility pointer
					;				[AB21]
; done with prompt, now get data
bcINPUT2				;				[ABCE]
	jsr	ChkDirectMode		; check not Direct, back here if ok
					;				[B3A6]
	lda	#','			; set ","
	sta	CommandBuf-1		; save to start of buffer - 1
A_ABD6					;				[ABD6]
	jsr	OutQuestMark		; print "? " and get BASIC input [ABF9]

	lda	CurIoChan		; get current I/O channel
	beq	A_ABEA			; branch if default I/O channel

	jsr	ReadIoStatus		; read I/O status word		[FFB7]
	and	#$02			; mask no DSR/timeout
	beq	A_ABEA			; branch if not error

	jsr	bcINPUTH2		; close input and output channels [ABB5]
	jmp	bcDATA			; perform DATA			[A8F8]

A_ABEA					;				[ABEA]
	lda	CommandBuf		; get first byte in input buffer
	bne	A_AC0D			; branch if not null

; else ..
	lda	CurIoChan		; get current I/O channel
	bne	A_ABD6			; if not default channel go get BASIC
					; input
	jsr	FindNextColon		; scan for next BASIC statement ([:] or
					; [EOL])			[A906]
	jmp	bcDATA2			; add Y to the BASIC execute pointer
					; and return			[A8FB]

;******************************************************************************
;
; print "? " and get BASIC input

OutQuestMark				;				[ABF9]
	lda	CurIoChan		; get current I/O channel
	bne	A_AC03			; skip "?" prompt if not default channel

	jsr	PrintQuestMark		; print "?"			[AB45]
	jsr	PrintSpace		; print [SPACE] or [CURSOR RIGHT] [AB3B]
A_AC03					;				[AC03]
	jmp	InputNewLine		; call for BASIC input and return [A560]


;******************************************************************************
;
; perform READ

bcREAD
	ldx	DATPTR			; get DATA pointer LB
	ldy	DATPTR+1		; get DATA pointer HB
	lda	#$98			; set input mode = READ
.byte	$2C				; makes next line BIT $00A9
A_AC0D					;				[AC0D]
	lda	#$00			; set input mode = INPUT


;******************************************************************************
;
; perform GET

bcREAD2					;				[AC0F]
	sta	INPFLG			; set input mode flag, $00 = INPUT,
					; $40 = GET, $98 = READ
	stx	INPPTR			; save READ pointer LB
	sty	INPPTR+1		; save READ pointer HB

; READ, GET or INPUT next variable from list
bcREAD3					;				[AC15]
	jsr	GetAddrVar		; get variable address		[B08B]
	sta	FORPNT			; save address LB
	sty	FORPNT+1		; save address HB

	lda	TXTPTR			; get BASIC execute pointer LB
	ldy	TXTPTR+1		; get BASIC execute pointer HB
	sta	TEMPSTR			; save BASIC execute pointer LB
	sty	TEMPSTR+1		; save BASIC execute pointer HB

	ldx	INPPTR			; get READ pointer LB
	ldy	INPPTR+1		; get READ pointer HB
	stx	TXTPTR			; save as BASIC execute pointer LB
	sty	TXTPTR+1		; save as BASIC execute pointer HB

	jsr	CHRGOT			; scan memory			[0079]
	bne	bcREAD4			; branch if not null

; pointer was to null entry
	bit	INPFLG			; test input mode flag, $00 = INPUT,
					; $40 = GET, $98 = READ
	bvc	A_AC41			; branch if not GET

; else was GET
	jsr	GetCharFromIO		; get character from input device with
					; error check			[E124]
	sta	CommandBuf		; save to buffer

	ldx	#<(CommandBuf-1)	; set pointer LB
	ldy	#>(CommandBuf-1)	; set pointer HB
	bne	A_AC4D			; go interpret single character

A_AC41					;				[AC41]
	bmi	A_ACB8			; branch if READ

; else was INPUT
	lda	CurIoChan		; get current I/O channel
	bne	A_AC4A			; skip "?" prompt if not default channel

	jsr	PrintQuestMark		; print "?"			[AB45]
A_AC4A					;				[AC4A]
	jsr	OutQuestMark		; print "? " and get BASIC input [ABF9]
A_AC4D					;				[AC4D]
	stx	TXTPTR			; save BASIC execute pointer LB
	sty	TXTPTR+1		; save BASIC execute pointer HB
bcREAD4					;				[AC51]
	jsr	CHRGET			; increment and scan memory, execute
					; pointer now points to		[0073]
					; start of next data or null terminator
	bit	VALTYP			; test data type flag, $FF = string,
					; $00 = numeric
	bpl	A_AC89			; branch if numeric

; type is string
	bit	INPFLG			; test INPUT mode flag, $00 = INPUT,
					; $40 = GET, $98 = READ
	bvc	A_AC65			; branch if not GET

; else do string GET
	inx				; clear X ??
	stx	TXTPTR			; save BASIC execute pointer LB

	lda	#$00			; clear A
	sta	CHARAC			; clear search character
	beq	A_AC71			; branch always

; is string INPUT or string READ
A_AC65					;				[AC65]
	sta	CHARAC			; save search character

	cmp	#'"'			; compare with "
	beq	A_AC72			; branch if quote

; string is not in quotes so ":", "," or $00 are the termination characters
	lda	#':'			; set ":"
	sta	CHARAC			; set search character

	lda	#','			; set ","
A_AC71					;				[AC71]
	clc				; clear carry for add
A_AC72					;				[AC72]
	sta	ENDCHR			; set scan quotes flag


	lda	TXTPTR			; get BASIC execute pointer LB
	ldy	TXTPTR+1		; get BASIC execute pointer HB
	adc	#$00			; add to pointer LB. this add increments
					; the pointer if the mode is INPUT or
					; READ and the data is a "..." string
	bcc	A_AC7D			; branch if no rollover

	iny				; else increment pointer HB
A_AC7D					;				[AC7D]
	jsr	PrtStr2UtiPtr		; print string to utility pointer [B48D]
	jsr	RestBasExecPtr		; restore BASIC execute pointer from
					; temp				[B7E2]
	jsr	SetValueString		; perform string LET		[A9DA]
	jmp	bcREAD5			; continue processing command	[AC91]

; GET, INPUT or READ is numeric
A_AC89					;				[AC89]
	jsr	String2FAC1		; get FAC1 from string		[BCF3]

	lda	INTFLG			; get data type flag, $80 = integer,
					; $00 = float
	jsr	SetIntegerVar		; assign value to numeric variable
					;				[A9C2]
bcREAD5					;				[AC91]
	jsr	CHRGOT			; scan memory			[0079]
	beq	A_AC9D			; branch if ":" or [EOL]

	cmp	#','			; comparte with ","
	beq	A_AC9D			; branch if ","

	jmp	CheckINPFLG		; else go do bad input routine	[AB4D]

; string terminated with ":", "," or $00
A_AC9D					;				[AC9D]
	lda	TXTPTR			; get BASIC execute pointer LB
	ldy	TXTPTR+1		; get BASIC execute pointer HB
	sta	INPPTR			; save READ pointer LB
	sty	INPPTR+1		; save READ pointer HB

	lda	TEMPSTR			; get saved BASIC execute pointer LB
	ldy	TEMPSTR+1		; get saved BASIC execute pointer HB
	sta	TXTPTR			; restore BASIC execute pointer LB
	sty	TXTPTR+1		; restore BASIC execute pointer HB

	jsr	CHRGOT			; scan memory			[0079]
	beq	A_ACDF			; branch if ":" or [EOL]

	jsr	Chk4Comma		; scan for ",", else do syntax error
					; then warm start		[AEFD]
	jmp	bcREAD3			; go READ or INPUT next variable from
					; list				[AC15]
; was READ
A_ACB8					;				[ACB8]
	jsr	FindNextColon		; scan for next BASIC statement ([:] or
					; [EOL])			[A906]
	iny				; increment index to next byte
	tax				; copy byte to X
	bne	A_ACD1			; branch if ":"

	ldx	#$0D			; else set error $0D, out of data error
	iny				; incr. index to next line pointer HB
	lda	(TXTPTR),Y		; get next line pointer HB
	beq	A_AD32			; branch if program end, eventually does
					; error X
	iny				; increment index
	lda	(TXTPTR),Y		; get next line # LB
	sta	DATLIN			; save current DATA line LB

	iny				; increment index
	lda	(TXTPTR),Y		; get next line # HB
	iny				; increment index
	sta	DATLIN+1		; save current DATA line HB
A_ACD1					;				[ACD1]
	jsr	bcDATA2			; add Y to the BASIC execute pointer
					;				[A8FB]
	jsr	CHRGOT			; scan memory			[0079]
	tax				; copy the byte
	cpx	#TK_DATA		; compare it with token for DATA
	bne	A_ACB8			; loop if not DATA

	jmp	bcREAD4			; continue evaluating READ	[AC51]

A_ACDF					;				[ACDF]
	lda	INPPTR			; get READ pointer LB
	ldy	INPPTR+1		; get READ pointer HB

	ldx	INPFLG			; get INPUT mode flag, $00 = INPUT,
					; $40 = GET, $98 = READ
	bpl	A_ACEA			; branch if INPUT or GET

	jmp	bcRESTORE2		; else set data pointer and exit [A827]

A_ACEA					;				[ACEA]
	ldy	#$00			; clear index
	lda	(INPPTR),Y		; get READ byte
	beq	A_ACFB			; exit if [EOL]

	lda	CurIoChan		; get current I/O channel
	bne	A_ACFB			; exit if not default channel

	lda	#<txtEXTRA		; set "?EXTRA IGNORED" pointer LB
	ldy	#>txtEXTRA		; set "?EXTRA IGNORED" pointer HB
	jmp	OutputString		; print null terminated string	[AB1E]

A_ACFB					;				[ACFB]
	rts


;******************************************************************************
;
; input error messages

txtEXTRA				;				[ACFC]
.null	"?extra ignored{cr}"

txtREDOFROM				;				[AD0C]
.null	"?redo from start{cr}"


;******************************************************************************
;
; perform NEXT

bcNEXT
	bne	bcNEXT2			; branch if NEXT variable

	ldy	#$00			; else clear Y
	beq	A_AD27			; branch always

; NEXT variable

bcNEXT2					;				[AD24]
	jsr	GetAddrVar		; get variable address		[B08B]
A_AD27					;				[AD27]
	sta	FORPNT			; save FOR/NEXT variable pointer LB
	sty	FORPNT+1		; save FOR/NEXT variable pointer HB
					; (HB cleared if no variable defined)
	jsr	SrchForNext		; search the stack for FOR or GOSUB
					; activity			[A38A]
	beq	A_AD35			; branch if FOR, this variable, found

	ldx	#$0A			; else set error $0A, next without for
					; error
A_AD32					;				[AD32]
	jmp	OutputErrMsg		; do error #X then warm start	[A437]

; found this FOR variable
A_AD35					;				[AD35]
	txs				; update stack pointer

	txa				; copy stack pointer
	clc				; clear carry for add
	adc	#$04			; point to STEP value
	pha				; save it

	adc	#$06			; point to TO value
	sta	INDEX+2			; save pointer to TO variable for
					; compare
	pla				; restore pointer to STEP value

	ldy	#$01			; point to stack page
	jsr	UnpackAY2FAC1		; unpack memory (AY) into FAC1	[BBA2]

	tsx				; get stack pointer back
	lda	STACK+9,X		; get step sign
	sta	FACSGN			; save FAC1 sign (b7)

	lda	FORPNT			; get FOR/NEXT variable pointer LB
	ldy	FORPNT+1		; get FOR/NEXT variable pointer HB
	jsr	AddFORvar2FAC1		; add FOR variable to FAC1	[B867]

	jsr	Fac1ToVarPtr		; pack FAC1 into FOR variable	[BBD0]

	ldy	#$01			; point to stack page
	jsr	CmpFAC1withAY2		; compare FAC1 with TO value	[BC5D]

	tsx				; get stack pointer back
	sec				; set carry for subtract
	sbc	STACK+9,X		; subtract step sign
	beq	A_AD78			; branch if =, loop complete

; loop back and do it all again
	lda	STACK+$0F,X		; get FOR line LB
	sta	CURLIN			; save current line number LB

	lda	STACK+$10,X		; get FOR line HB
	sta	CURLIN+1		; save current line number HB

	lda	STACK+$12,X		; get BASIC execute pointer LB
	sta	TXTPTR			; save BASIC execute pointer LB

	lda	STACK+$11,X		; get BASIC execute pointer HB
	sta	TXTPTR+1		; save BASIC execute pointer HB
A_AD75					;				[AD75]
	jmp	InterpretLoop		; go do interpreter inner loop	[A7AE]

; NEXT loop comlete

A_AD78					;				[AD78]
	txa				; stack copy to A
	adc	#$11			; add $12, $11 + carry, to dump FOR
					; structure
	tax				; copy back to index

	txs				; copy to stack pointer

	jsr	CHRGOT			; scan memory			[0079]
	cmp	#','			; compare with ","
	bne	A_AD75			; if not "," go do interpreter inner
					; loop
; was "," so another NEXT variable to do
	jsr	CHRGET			; increment and scan memory	[0073]
	jsr	bcNEXT2			; do NEXT variable		[AD24]


;******************************************************************************
;
; evaluate expression and check type mismatch

EvalExpression				;				[AD8A]
	jsr	EvaluateValue		; evaluate expression		[AD9E]

; check if source and destination are numeric

CheckIfNumeric				;				[AD8D]
	clc
.byte	$24				; makes next line BIT MEMSIZ+1

; check if source and destination are string

CheckIfString				;				[AD8F]
	sec				; destination is string

; type match check, set C for string, clear C for numeric

ChkIfNumStr				;				[AD90]
	bit	VALTYP			; test data type flag, $FF = string,
					; $00 = numeric
	bmi	A_AD97			; branch if string

	bcs	A_AD99			; if destiantion is numeric do type
					; missmatch error
A_AD96					;				[AD96]
	rts

A_AD97					;				[AD97]
	bcs	A_AD96			; exit if destination is string

; do type missmatch error

A_AD99					;				[AD99]
	ldx	#$16			; error code $16, type missmatch error
	jmp	OutputErrMsg		; do error #X then warm start	[A437]


;******************************************************************************
;
; evaluate expression

EvaluateValue				;				[AD9E]
	ldx	TXTPTR			; get BASIC execute pointer LB
	bne	A_ADA4			; skip next if not zero

	dec	TXTPTR+1		; else decr. BASIC execute pointer HB
A_ADA4					;				[ADA4]
	dec	TXTPTR			; decrement BASIC execute pointer LB

	ldx	#$00			; set null precedence, flag done
.byte	$24				; makes next line BIT VARPNT+1
EvaluateValue2				;				[ADA9]
	pha				; push compare evaluation byte if branch
					; to here
	txa				; copy precedence byte
	pha				; push precedence byte

	lda	#$01			; 2 bytes
	jsr	CheckRoomStack		; check room on stack for A*2 bytes
					;				[A3FB]
	jsr	GetNextParm		; get value from line		[AE83]

	lda	#$00			; clear A
	sta	CompEvalFlg		; clear comparrison evaluation flag
EvaluateValue3				;				[ADB8]
	jsr	CHRGOT			; scan memory			[0079]
EvaluateValue4				;				[ADBB]
	sec				; set carry for subtract
	sbc	#TK_GT			; subtract the token for ">"
	bcc	A_ADD7			; branch if < ">"

	cmp	#$03			; compare with ">" to +3
	bcs	A_ADD7			; branch if >= 3

; was token for ">" "=" or "<"
	cmp	#$01			; compare with token for =
	rol				; b0 := carry (=1 if token was = or <)
	eor	#$01			; toggle b0
	eor	CompEvalFlg		; EOR with comparrison evaluation flag
	cmp	CompEvalFlg		; comp with comparrison evaluation flag
	bcc	A_AE30			; if < saved flag do syntax error then
					; warm start
	sta	CompEvalFlg		; save new comparrison evaluation flag

	jsr	CHRGET			; increment and scan memory	[0073]
	jmp	EvaluateValue4		; go do next character		[ADBB]


A_ADD7					;				[ADD7]
	ldx	CompEvalFlg		; get comparrison evaluation flag
	bne	A_AE07			; branch if compare function

	bcs	A_AE58			; go do functions

; else was < TK_GT so is operator or lower
	adc	#$07			; add # of operators (+, -, *, /, ^,
					; AND or OR)
	bcc	A_AE58			; branch if < + operator

; carry was set so token was +, -, *, /, ^, AND or OR
	adc	VALTYP			; add data type flag, $FF = string,
					; $00 = numeric
	bne	A_ADE8			; branch if not string or not + token

; will only be $00 if type is string and token was +
	jmp	ConcatStrings		; add strings, string 1 is in the
					; descriptor, string 2	[B63D]
					; is in line, and return

A_ADE8					;				[ADE8]
	adc	#$FF			; -1 (corrects for carry add)
	sta	INDEX			; save it

	asl				; *2
	adc	INDEX			; *3
	tay				; copy to index
A_ADF0					;				[ADF0]
	pla				; pull previous precedence
	cmp	HierachyCode,Y		; compare with precedence byte
	bcs	A_AE5D			; branch if A >=

	jsr	CheckIfNumeric		; check if source is numeric, else do
					; type mismatch			[AD8D]
A_ADF9					;				[ADF9]
	pha				; save precedence
EvaluateValue5				;				[ADFA]
	jsr	EvaluateValue6		; get vector, execute function then
					; continue evaluation		[AE20]

	pla				; restore precedence

	ldy	TEMPSTR			; get precedence stacked flag
	bpl	A_AE19			; branch if stacked values

	tax				; copy precedence, set flags
	beq	A_AE5B			; exit if done

	bne	A_AE66			; branch always

A_AE07					;				[AE07]
	lsr	VALTYP			; clear data type flag, $FF = string,
					; $00 = numeric
	txa				; copy compare function flag

	rol				; <<1, shift data type flag into b0,
					; 1 = string, 0 = num
	ldx	TXTPTR			; get BASIC execute pointer LB
	bne	A_AE11			; branch if no underflow

	dec	TXTPTR+1		; else decr. BASIC execute pointer HB
A_AE11					;				[AE11]
	dec	TXTPTR			; decrement BASIC execute pointer LB

	ldy	#$1B			; set offset to = operator precedence
					; entry
	sta	CompEvalFlg		; save new comparrison evaluation flag
	bne	A_ADF0			; branch always

A_AE19					;				[AE19]
	cmp	HierachyCode,Y		; compare with stacked function
					; precedence
	bcs	A_AE66			; if A >=, pop FAC2 and return

	bcc	A_ADF9			; else go stack this one and continue,
					; branch always

;******************************************************************************
;
; get vector, execute function then continue evaluation

EvaluateValue6				;				[AE20]
	lda	HierachyCode+2,Y	; get function vector HB
	pha				; onto stack

	lda	HierachyCode+1,Y	; get function vector LB
	pha				; onto stack

; now push sign, round FAC1 and put on stack
	jsr	EvaluateValue7		; function will return here, then the
					; next RTS will call the function [AE33]
	lda	CompEvalFlg		; get comparrison evaluation flag
	jmp	EvaluateValue2		; continue evaluating expression [ADA9]

A_AE30					;				[AE30]
	jmp	SyntaxError		; do syntax error then warm start [AF08]

EvaluateValue7				;				[AE33]
	lda	FACSGN			; get FAC1 sign (b7)
	ldx	HierachyCode,Y		; get precedence byte


;******************************************************************************
;
; push sign, round FAC1 and put on stack

SgnFac1ToStack				;				[AE38]
	tay				; copy sign

	pla				; get return address LB
	sta	INDEX			; save it

	inc	INDEX			; increment it as return-1 is pushed.
; Note, no check is made on the HB so if the calling routine ever assembles to
; a page edge then this all goes horribly wrong!

	pla				; get return address HB
	sta	INDEX+1			; save it

	tya				; restore sign
	pha				; push sign


;******************************************************************************
;
; round FAC1 and put on stack

FAC1ToStack				;				[AE43]
	jsr	RoundFAC1		; round FAC1			[BC1B]

	lda	FacMantissa+3		; get FAC1 mantissa 4
	pha				; save it

	lda	FacMantissa+2		; get FAC1 mantissa 3
	pha				; save it

	lda	FacMantissa+1		; get FAC1 mantissa 2
	pha				; save it

	lda	FacMantissa		; get FAC1 mantissa 1
	pha				; save it

	lda	FACEXP			; get FAC1 exponent
	pha				; save it

	jmp	(INDEX)			; return, sort of


;******************************************************************************
;
; do functions

A_AE58					;				[AE58]
	ldy	#$FF			; flag function
	pla				; pull precedence byte
A_AE5B					;				[AE5B]
	beq	A_AE80			; exit if done

A_AE5D					;				[AE5D]
	cmp	#$64			; compare previous precedence with $64
	beq	A_AE64			; branch if was $64 (< function)

	jsr	CheckIfNumeric		; check if source is numeric, else do
					; type mismatch	[AD8D]
A_AE64					;				[AE64]
	sty	TEMPSTR			; save precedence stacked flag

; pop FAC2 and return
A_AE66					;				[AE66]
	pla				; pop byte
	lsr				; shift out comparison evaluation
					; lowest bit
	sta	TANSGN			; save the comparison evaluation flag

	pla				; pop exponent
	sta	ARGEXP			; save FAC2 exponent

	pla				; pop mantissa 1
	sta	ArgMantissa		; save FAC2 mantissa 1

	pla				; pop mantissa 2
	sta	ArgMantissa+1		; save FAC2 mantissa 2

	pla				; pop mantissa 3
	sta	ArgMantissa+2		; save FAC2 mantissa 3

	pla				; pop mantissa 4
	sta	ArgMantissa+3		; save FAC2 mantissa 4

	pla				; pop sign
	sta	ARGSGN			; save FAC2 sign (b7)

	eor	FACSGN			; EOR FAC1 sign (b7)
	sta	ARISGN			; save sign compare (FAC1 EOR FAC2)
A_AE80					;				[AE80]
	lda	FACEXP			; get FAC1 exponent
	rts


;******************************************************************************
;
; get value from line

GetNextParm				;				[AE83]
	jmp	(IEVAL)			; get arithmetic element


;******************************************************************************
;
; get arithmetic element, the get arithmetic element vector is initialised to
; point here

GetNextParm2				;				[AE86]
	lda	#$00			; clear byte
	sta	VALTYP			; clear data type flag, $FF = string,
					; $00 = numeric
A_AE8A					;				[AE8A]
	jsr	CHRGET			; increment and scan memory	[0073]
	bcs	A_AE92			; branch if not numeric character

; else numeric string found (e.g. 123)
A_AE8F					;				[AE8F]
	jmp	String2FAC1		; get FAC1 from string and return [BCF3]

; get value from line .. continued

; wasn't a number so ...
A_AE92					;				[AE92]
	jsr	CheckAtoZ		; check byte, return Cb = 0 if < "A" or
					; > "Z"				[B113]
	bcc	A_AE9A			; branch if not variable name

	jmp	GetVariable		; variable name set-up and return [AF28]

A_AE9A					;				[AE9A]
	cmp	#TK_PI			; compare with token for PI
	bne	A_AEAD			; branch if not PI

	lda	#<Tbl_PI_Value		; get PI pointer LB
	ldy	#>Tbl_PI_Value		; get PI pointer HB
	jsr	UnpackAY2FAC1		; unpack memory (AY) into FAC1	[BBA2]

	jmp	CHRGET			; increment and scan memory and return
					;	[0073]

;******************************************************************************
;
; PI as floating number

Tbl_PI_Value				;				[AEA8]
.byte	$82,$49,$0F,$DA,$A1		; 3.141592653


;******************************************************************************
;
; get value from line .. continued

; wasn't variable name so ...
A_AEAD					;				[AEAD]
	cmp	#'.'			; compare with "."
	beq	A_AE8F			; if so get FAC1 from string and return,
					; e.g. was .123
; wasn't .123 so ...
	cmp	#TK_MINUS		; compare with token for -
	beq	A_AF0D			; branch if - token, do set-up for
					; functions
; wasn't -123 so ...
	cmp	#TK_PLUS		; compare with token for +
	beq	A_AE8A			; branch if + token, +1 = 1 so ignore
					; leading +
; it wasn't any sort of number so ...
	cmp	#'"'			; compare with "
	bne	A_AECC			; branch if not open quote

; was open quote so get the enclosed string


;******************************************************************************
;
; print "..." string to string utility area

GetNextParm3				;				[AEBD]
	lda	TXTPTR			; get BASIC execute pointer LB
	ldy	TXTPTR+1		; get BASIC execute pointer HB
	adc	#$00			; add carry to LB
	bcc	A_AEC6			; branch if no overflow

	iny				; increment HB
A_AEC6					;				[AEC6]
	jsr	QuoteStr2UtPtr		; print " terminated string to utility
					; pointer			[B487]
	jmp	RestBasExecPtr		; restore BASIC execute pointer from
					; temp and return		[B7E2]
; get value from line .. continued

; wasn't a string so ...
A_AECC					;				[AECC]
	cmp	#TK_NOT			; compare with token for NOT
	bne	A_AEE3			; branch if not token for NOT

; was NOT token
	ldy	#$18			; offset to NOT function
	bne	A_AF0F			; do set-up for function then execute,
					; branch always
; do = compare

bcEQUAL
	jsr	EvalInteger3		; evaluate integer expression, no sign
					; check				[B1BF]
	lda	FacMantissa+3		; get FAC1 mantissa 4
	eor	#$FF			; invert it
	tay				; copy it

	lda	FacMantissa+2		; get FAC1 mantissa 3
	eor	#$FF			; invert it
	jmp	ConvertAY2FAC1		; convert fixed integer AY to float FAC1
					; and return			[B391]
; get value from line .. continued

; wasn't a string or NOT so ...
A_AEE3					;				[AEE3]
	cmp	#TK_FN			; compare with token for FN
	bne	A_AEEA			; branch if not token for FN

	jmp	EvaluateFNx		; else go evaluate FNx		[B3F4]

; get value from line .. continued

; wasn't a string, NOT or FN so ...
A_AEEA					;				[AEEA]
	cmp	#TK_SGN			; compare with token for SGN
	bcc	Chk4Parens		; if less than SGN token evaluate
					; expression in parentheses
; else was a function token
	jmp	GetReal			; go set up function references	[AFA7]

; get value from line .. continued
; if here it can only be something in brackets so ....

; evaluate expression within parentheses

Chk4Parens				;				[AEF1]
	jsr	Chk4OpenParen		; scan for "(", else do syntax error
					; then warm start		[AEFA]
	jsr	EvaluateValue		; evaluate expression		[AD9E]

; all the 'scan for' routines return the character after the sought character

; scan for ")", else do syntax error then warm start

Chk4CloseParen				;				[AEF7]
	lda	#')'			; load A with ")"
.byte	$2C				; makes next line BIT RESHO+2A9

; scan for "(", else do syntax error then warm start

Chk4OpenParen				;				[AEFA]
	lda	#'('			; load A with "("
.byte	$2C				; makes next line BIT TXTTAB+1A9

; scan for ",", else do syntax error then warm start

Chk4Comma				;				[AEFD]
	lda	#','			; load A with ","

; scan for CHR$(A), else do syntax error then warm start

Chk4CharInA				;				[AEFF]
	ldy	#$00			; clear index
	cmp	(TXTPTR),Y		; compare with BASIC byte
	bne	SyntaxError		; if not expected byte do syntax error
					; then warm start
	jmp	CHRGET			; else increment and scan memory and
					; return			[0073]
; syntax error then warm start

SyntaxError				;				[AF08]
	ldx	#$0B			; error code $0B, syntax error
	jmp	OutputErrMsg		; do error #X then warm start	[A437]


A_AF0D					;				[AF0D]
	ldy	#$15			; set offset from base to > operator
A_AF0F					;				[AF0F]
	pla				; dump return address LB
	pla				; dump return address HB

	jmp	EvaluateValue5		; execute function then continue
					; evaluation			[ADFA]

;******************************************************************************
;
; check address range, return C = 1 if address in BASIC ROM

ChkIfVariable				;				[AF14]
	sec				; set carry for subtract
	lda	FacMantissa+2		; get variable address LB
	sbc	#<BasicCold		; subtract BasicCold LB

	lda	FacMantissa+3		; get variable address HB
	sbc	#>BasicCold		; subtract BasicCold HB
	bcc	A_AF27			; exit if address < BasicCold

	lda	#<DataCHRGET		; get end of BASIC marker LB
	sbc	FacMantissa+2		; subtract variable address LB

	lda	#>DataCHRGET		; get end of BASIC marker HB
	sbc	FacMantissa+3		; subtract variable address HB
A_AF27					;				[AF27]
	rts


;******************************************************************************
;
; variable name set-up

GetVariable				;				[AF28]
	jsr	GetAddrVar		; get variable address		[B08B]
	sta	FacMantissa+2		; save variable pointer LB
	sty	FacMantissa+3		; save variable pointer HB

	ldx	VARNAM			; get current variable name first char
	ldy	VARNAM+1		; get current variable name second char

	lda	VALTYP			; get data type flag, $FF = string,
					; $00 = numeric
	beq	A_AF5D			; branch if numeric

; variable is string
	lda	#$00			; else clear A
	sta	FACOV			; clear FAC1 rounding byte

	jsr	ChkIfVariable		; check address range		[AF14]
	bcc	A_AF5C			; exit if not in BASIC ROM

	cpx	#'t'			; compare variable name first character
					; with "T"
	bne	A_AF5C			; exit if not "T"

	cpy	#$C9		; compare variable name second character
					; with "I$"
	bne	A_AF5C			; exit if not "I$"

; variable name was "TI$"
	jsr	GetTime			; read real time clock into FAC1
					; mantissa, 0HML		[AF84]
	sty	FacTempStor+7		; clear exponent count adjust

	dey				; Y = $FF
	sty	FBUFPT			; set output string index, -1 to allow
					; for pre increment
	ldy	#$06			; HH:MM:SS is six digits
	sty	FacTempStor+6		; set number of characters before the
					; decimal point
	ldy	#D_BF3A-D_BF16		; index to jiffy conversion table
	jsr	JiffyCnt2Str		; convert jiffy count to string	[BE68]

	jmp	bcSTR2			; exit via STR$() code tail	[B46F]

A_AF5C					;				[AF5C]
	rts

; variable name set-up, variable is numeric
A_AF5D					;				[AF5D]
	bit	INTFLG			; test data type flag, $80 = integer,
					; $00 = float
	bpl	A_AF6E			; branch if float

	ldy	#$00			; clear index
	lda	(FacMantissa+2),Y	; get integer variable LB
	tax				; copy to X

	iny				; increment index
	lda	(FacMantissa+2),Y	; get integer variable HB
	tay				; copy to Y

	txa				; copy loa byte to A
	jmp	ConvertAY2FAC1		; convert fixed integer AY to float FAC1
					; and return			[B391]
; variable name set-up, variable is float
A_AF6E					;				[AF6E]
	jsr	ChkIfVariable		; check address range		[AF14]
	bcc	A_AFA0			; if not in BASIC ROM get pointer and
					; unpack into FAC1
	cpx	#'t'			; compare variable name first character
					; with "T"
	bne	A_AF92			; branch if not "T"

	cpy	#'i'			; compare variable name second character
					; with "I"
	bne	A_AFA0			; branch if not "I"

; variable name was "TI"
	jsr	GetTime			; read real time clock into FAC1
					; mantissa, 0HML		[AF84]
	tya				; clear A

	ldx	#$A0			; set exponent to 32 bit value
	jmp	J_BC4F			; set exponent = X and normalise FAC1
					;				[BC4F]

;******************************************************************************
;
; read real time clock into FAC1 mantissa, 0HML

GetTime					;				[AF84]
	jsr	ReadClock		; read real time clock		[FFDE]
	stx	FacMantissa+2		; save jiffy clock mid byte as	FAC1
					; mantissa 3
	sty	FacMantissa+1		; save jiffy clock HB as  FAC1
					; mantissa 2
	sta	FacMantissa+3		; save jiffy clock LB as  FAC1
					; mantissa 4
	ldy	#$00			; clear Y
	sty	FacMantissa		; clear FAC1 mantissa 1

	rts

; variable name set-up, variable is float and not "Tx"
A_AF92					;				[AF92]
	cpx	#'s'			; compare variable name first character
					; with "S"
	bne	A_AFA0			; if not "S" go do normal floating
					; variable
	cpy	#'t'			; compare variable name second character
					; with "T"
	bne	A_AFA0			; if not "T" go do normal floating
					; variable
; variable name was "ST"
	jsr	ReadIoStatus		; read I/O status word		[FFB7]
	jmp	AtoInteger		; save A as integer byte and return
					;				[BC3C]
; variable is float
A_AFA0					;				[AFA0]
	lda	FacMantissa+2		; get variable pointer LB
	ldy	FacMantissa+3		; get variable pointer HB
	jmp	UnpackAY2FAC1		; unpack memory (AY) into FAC1	[BBA2]


;******************************************************************************
;
; get value from line continued
; only functions left so ..

; set up function references

GetReal					;				[AFA7]
	asl				; *2 (2 bytes per function address)
	pha				; save function offset
	tax				; copy function offset

	jsr	CHRGET			; increment and scan memory	[0073]
	cpx	#$8F			; compare function offset to CHR$ token
					; offset+1
	bcc	A_AFD1			; branch if < LEFT$ (can not be =)

; get value from line .. continued
; was LEFT$, RIGHT$ or MID$ so..

	jsr	Chk4OpenParen		; scan for "(", else do syntax error
					; then warm start		[AEFA]
	jsr	EvaluateValue		; evaluate, should be string, expression
					;				[AD9E]
	jsr	Chk4Comma		; scan for ",", else do syntax error
					; then warm start		[AEFD]
	jsr	CheckIfString		; check if source is string, else do
					; type mismatch			[AD8F]

	pla				; restore function offset
	tax				; copy it

	lda	FacMantissa+3		; get descriptor pointer HB
	pha				; push string pointer HB

	lda	FacMantissa+2		; get descriptor pointer LB
	pha				; push string pointer LB

	txa				; restore function offset
	pha				; save function offset

	jsr	GetByteParm2		; get byte parameter		[B79E]

	pla				; restore function offset
	tay				; copy function offset

	txa				; copy byte parameter to A
	pha				; push byte parameter

	jmp	J_AFD6			; go call function		[AFD6]

; get value from line .. continued
; was SGN() to CHR$() so..

A_AFD1					;				[AFD1]
	jsr	Chk4Parens		; evaluate expression within parentheses
					;				[AEF1]
	pla				; restore function offset
	tay				; copy to index
J_AFD6					;				[AFD6]
	lda	TblFunctions-$68,Y	; get function jump vector LB
	sta	Jump0054+1		; save functions jump vector LB

	lda	TblFunctions-$67,Y	; get function jump vector HB
	sta	Jump0054+2		; save functions jump vector HB

	jsr	Jump0054		; do function call		[0054]
	jmp	CheckIfNumeric		; check if source is numeric and RTS,
					; else do type mismatch string functions
					; avoid this by dumping the return
					; address			[AD8D]


;******************************************************************************
;
; perform OR
; this works because NOT(NOT(x) AND NOT(y)) = x OR y

bcOR					;				[AFE6]
	ldy	#$FF			; set Y for OR
.byte	$2C				; makes next line BIT $00A0


;******************************************************************************
;
; perform AND

bcAND					;				[AFE9]
	ldy	#$00			; clear Y for AND
	sty	COUNT			; set AND/OR invert value

	jsr	EvalInteger3		; evaluate integer expression, no sign
					; check				[B1BF]

	lda	FacMantissa+2		; get FAC1 mantissa 3
	eor	COUNT			; EOR LB
	sta	CHARAC			; save it

	lda	FacMantissa+3		; get FAC1 mantissa 4
	eor	COUNT			; EOR HB
	sta	ENDCHR			; save it

	jsr	CopyFAC2toFAC1		; copy FAC2 to FAC1, get 2nd value in
					; expression			[BBFC]
	jsr	EvalInteger3		; evaluate integer expression, no sign
					; check				[B1BF]
	lda	FacMantissa+3		; get FAC1 mantissa 4
	eor	COUNT			; EOR HB
	and	ENDCHR			; AND with expression 1 HB
	eor	COUNT			; EOR result HB
	tay				; save in Y

	lda	FacMantissa+2		; get FAC1 mantissa 3
	eor	COUNT			; EOR LB
	and	CHARAC			; AND with expression 1 LB
	eor	COUNT			; EOR result LB
	jmp	ConvertAY2FAC1		; convert fixed integer AY to float FAC1
					; and return			[B391]


;******************************************************************************
;
; perform comparisons

; do < compare

bcSMALLER				;				[D016]
	jsr	ChkIfNumStr		; type match check, set C for string
					;				[AD90]
	bcs	A_B02E			; branch if string

; do numeric < compare
	lda	ARGSGN			; get FAC2 sign (b7)
	ora	#$7F			; set all non sign bits
	and	ArgMantissa		; and FAC2 mantissa 1 (AND in sign bit)
	sta	ArgMantissa		; save FAC2 mantissa 1

	lda	#<ARGEXP		; set pointer LB to FAC2
	ldy	#>ARGEXP		; set pointer HB to FAC2
	jsr	CmpFAC1withAY		; compare FAC1 with (AY)	[BC5B]
	tax				; copy the result

	jmp	J_B061			; go evaluate result		[B061]

; do string < compare
A_B02E					;				[B02E]
	lda	#$00			; clear byte
	sta	VALTYP			; clear data type flag, $FF = string,
					; $00 = numeric
	dec	CompEvalFlg		; clear < bit in comparrison evaluation
					; flag
	jsr	PopStrDescStk		; pop string off descriptor stack, or
					; from top of string. Space returns with
					; A = length, X = pointer LB,
					; Y = pointer HB		[B6A6]
	sta	FACEXP			; save length
	stx	FacMantissa		; save string pointer LB
	sty	FacMantissa+1		; save string pointer HB

	lda	ArgMantissa+2		; get descriptor pointer LB
	ldy	ArgMantissa+3		; get descriptor pointer HB
	jsr	PopStrDescStk2		; pop (YA) descriptor off stack or from
					; top of string space returns with A =
					; length, X = pointer low byte,
					; Y = pointer high byte		[B6AA]
	stx	ArgMantissa+2		; save string pointer LB
	sty	ArgMantissa+3		; save string pointer HB

	tax				; copy length

	sec				; set carry for subtract
	sbc	FACEXP			; subtract string 1 length
	beq	A_B056			; branch if string 1 length = string 2
					; length
	lda	#$01			; set str 1 length > string 2 length
	bcc	A_B056			; branch if so

	ldx	FACEXP			; get string 1 length
	lda	#$FF			; set str 1 length < string 2 length
A_B056					;				[B056]
	sta	FACSGN			; save length compare

	ldy	#$FF			; set index
	inx				; adjust for loop
A_B05B					;				[B05B]
	iny				; increment index

	dex				; decrement count
	bne	A_B066			; branch if still bytes to do

	ldx	FACSGN			; get length compare back
J_B061					;				[B061]
	bmi	A_B072			; branch if str 1 < str 2

	clc				; flag str 1 <= str 2
	bcc	A_B072			; go evaluate result

A_B066					;				[B066]
	lda	(ArgMantissa+2),Y	; get string 2 byte
	cmp	(FacMantissa),Y		; compare with string 1 byte
	beq	A_B05B			; loop if bytes =

	ldx	#$FF			; set str 1 < string 2
	bcs	A_B072			; branch if so

	ldx	#$01			; set str 1 > string 2
A_B072					;				[B072]
	inx				; x = 0, 1 or 2

	txa				; copy to A
	rol				; * 2 (1, 2 or 4)
	and	TANSGN			; AND with the comparison evaluation
					; flag
	beq	A_B07B			; branch if 0 (compare is false)

	lda	#$FF			; else set result true
A_B07B					;				[B07B]
	jmp	AtoInteger		; save A as integer byte and return
					;				[BC3C]

A_B07E					;				[B07E]
	jsr	Chk4Comma		; scan for ",", else do syntax error
					; then warm start		[AEFD]

;******************************************************************************
;
; perform DIM

bcDIM					;				[D081]
	tax				; copy "DIM" flag to X
	jsr	GetAddrVar2		; search for variable		[B090]

	jsr	CHRGOT			; scan memory			[0079]
	bne	A_B07E			; scan for "," and loop if not null

	rts


;******************************************************************************
;
; search for variable

GetAddrVar				;				[B08B]
	ldx	#$00			; set DIM flag = $00
	jsr	CHRGOT			; scan memory, 1st character	[0079]
GetAddrVar2				;				[B090]
	stx	DIMFLG			; save DIM flag
GetAddrVar3				;				[B092]
	sta	VARNAM			; save 1st character

	jsr	CHRGOT			; scan memory			[0079]

	jsr	CheckAtoZ		; check byte, return Cb = 0 if < "A"
					; or > "Z"			[B113]
	bcs	A_B09F			; branch if ok

A_B09C					;				[B09C]
	jmp	SyntaxError		; else syntax error then warm start
					;				[AF08]

; was variable name so ...
A_B09F					;				[B09F]
	ldx	#$00			; clear 2nd character temp
	stx	VALTYP			; clear data type flag, $FF = string,
					; $00 = numeric
	stx	INTFLG			; clear data type flag, $80 = integer,
					; $00 = float
	jsr	CHRGET			; increment and scan memory, 2nd
					; character			[0073]
	bcc	A_B0AF			; if character = "0"-"9" (ok) go save
					; 2nd character

; 2nd character wasn't "0" to "9" so ...
	jsr	CheckAtoZ		; check byte, return Cb = 0 if < "A" or
					; > "Z"				[B113]
	bcc	A_B0BA			; branch if <"A" or >"Z" (go check if
					; string)
A_B0AF					;				[B0AF]
	tax				; copy 2nd character

; ignore further (valid) characters in the variable name
A_B0B0					;				[B0B0]
	jsr	CHRGET			; increment and scan memory, 3rd
					; character			[0073]
	bcc	A_B0B0			; loop if character = "0"-"9" (ignore)

	jsr	CheckAtoZ		; check byte, return Cb = 0 if < "A" or
					; > "Z"				[B113]
	bcs	A_B0B0			; loop if character = "A"-"Z" (ignore)

; check if string variable
A_B0BA					;				[B0BA]
	cmp	#'$'			; compare with "$"
	bne	A_B0C4			; branch if not string

; type is string
	lda	#$FF			; set data type = string
	sta	VALTYP			; set data type flag, $FF = string,
					; $00 = numeric
	bne	A_B0D4			; branch always

A_B0C4					;				[B0C4]
	cmp	#'%'			; compare with "%"
	bne	A_B0DB			; branch if not integer

	lda	SUBFLG			; get subscript/FNX flag
	bne	A_B09C			; if ?? do syntax error then warm start

	lda	#$80			; set integer type
	sta	INTFLG			; set data type = integer

	ora	VARNAM			; OR current variable name first byte
	sta	VARNAM			; save current variable name first byte
A_B0D4					;				[B0D4]
	txa				; get 2nd character back
	ora	#$80			; set top bit, indicate string or
					; integer variable
	tax				; copy back to 2nd character temp

	jsr	CHRGET			; increment and scan memory	[0073]
A_B0DB					;				[B0DB]
	stx	VARNAM+1		; save 2nd character

	sec				; set carry for subtract
	ora	SUBFLG			; or with subscript/FNX flag - or FN
					; name
	sbc	#'('			; subtract "("
	bne	A_B0E7			; branch if not "("

	jmp	FindMakeArray		; go find, or make, array	[B1D1]

; either find or create variable

; variable name wasn't xx(.... so look for plain variable
A_B0E7					;				[B0E7]
	ldy	#$00			; clear A
	sty	SUBFLG			; clear subscript/FNX flag

	lda	VARTAB			; get start of variables LB
	ldx	VARTAB+1		; get start of variables HB
A_B0EF					;				[B0EF]
	stx	FacTempStor+9		; save search address HB
A_B0F1					;				[B0F1]
	sta	FacTempStor+8		; save search address LB

	cpx	ARYTAB+1		; compare with end of variables HB
	bne	A_B0FB			; skip next compare if <>

; high addresses were = so compare low addresses
	cmp	ARYTAB			; compare low address with end of
					; variables LB
	beq	A_B11D			; if not found go make new variable

A_B0FB					;				[B0FB]
	lda	VARNAM			; get 1st character of variable to find
	cmp	(FacTempStor+8),Y	; compare with variable name 1st
					; character
	bne	A_B109			; branch if no match

; 1st characters match so compare 2nd character
	lda	VARNAM+1		; get 2nd character of variable to find
	iny				; index to point to variable name 2nd
					; character
	cmp	(FacTempStor+8),Y	; compare with variable name 2nd
					; character
	beq	A_B185			; branch if match (found variable)

	dey				; else decrement index (now = $00)
A_B109					;				[B109]
	clc				; clear carry for add
	lda	FacTempStor+8		; get search address LB
	adc	#$07			; +7, offset to next variable name
	bcc	A_B0F1			; loop if no overflow to HB

	inx				; else increment HB
	bne	A_B0EF			; loop always, RAM doesn't extend to
					; $FFFF
; check byte, return C = 0 if <"A" or >"Z"

CheckAtoZ				;				[B113]
	cmp	#'a'			; compare with "A"
	bcc	A_B11C			; exit if less

; carry is set
	sbc	#'z'+1			; subtract "Z"+1

	sec				; set carry
	sbc	#$A5			; subtract $A5 (restore byte)
					; carry clear if byte > $5A
A_B11C					;				[B11C]
	rts

; reached end of variable memory without match
; ... so create new variable
A_B11D					;				[B11D]
	pla				; pop return address LB
	pha				; push return address LB

	cmp	#<(GetVariable+2)	; compare with expected calling routine
					; return LB
	bne	A_B128			; if not get variable go create new
					; variable

; this will only drop through if the call was from GetVariable and is only
; called from there if it is searching for a variable from the right hand side
; of a LET a=b statement, it prevents the creation of variables not assigned a
; value.

; value returned by this is either numeric zero, exponent byte is $00, or null
; string, descriptor length byte is $00. in fact a pointer to any $00 byte
; would have done.

; else return dummy null value
A_B123					;				[B123]
	lda	#<L_BF13		; set result pointer LB
	ldy	#>L_BF13		; set result pointer HB
	rts

; create new numeric variable
A_B128					;				[B128]
	lda	VARNAM			; get variable name first character

	ldy	VARNAM+1		; get variable name second character
	cmp	#'t'			; compare first character with "T"
	bne	A_B13B			; branch if not "T"

	cpy	#$C9		; compare second character with "I$"
	beq	A_B123			; if "I$" return null value

	cpy	#'i'			; compare second character with "I"
	bne	A_B13B			; branch if not "I"

; if name is "TI" do syntax error
A_B138					;				[B138]
	jmp	SyntaxError		; do syntax error then warm start [AF08]

A_B13B					;				[B13B]
	cmp	#'s'			; compare first character with "S"
	bne	A_B143			; branch if not "S"

	cpy	#'t'			; compare second character with "T"
	beq	A_B138			; if name is "ST" do syntax error

A_B143					;				[B143]
	lda	ARYTAB			; get end of variables LB
	ldy	ARYTAB+1		; get end of variables HB
	sta	FacTempStor+8		; save old block start LB
	sty	FacTempStor+9		; save old block start HB

	lda	STREND			; get end of arrays LB
	ldy	STREND+1		; get end of arrays HB
	sta	FacTempStor+3		; save old block end LB
	sty	FacTempStor+4		; save old block end HB

	clc				; clear carry for add
	adc	#$07			; +7, space for one variable
	bcc	A_B159			; branch if no overflow to HB

	iny				; else increment HB
A_B159					;				[B159]
	sta	FacTempStor+1		; set new block end LB
	sty	FacTempStor+2		; set new block end HB

	jsr	MoveBlock		; open up space in memory	[A3B8]

	lda	FacTempStor+1		; get new start LB
	ldy	FacTempStor+2		; get new start HB (-$100)
	iny				; correct HB
	sta	ARYTAB			; set end of variables LB
	sty	ARYTAB+1		; set end of variables HB

	ldy	#$00			; clear index
	lda	VARNAM			; get variable name 1st character
	sta	(FacTempStor+8),Y	; save variable name 1st character

	iny				; increment index
	lda	VARNAM+1		; get variable name 2nd character
	sta	(FacTempStor+8),Y	; save variable name 2nd character

	lda	#$00			; clear A
	iny				; increment index
	sta	(FacTempStor+8),Y	; initialise variable byte

	iny				; increment index
	sta	(FacTempStor+8),Y	; initialise variable byte

	iny				; increment index
	sta	(FacTempStor+8),Y	; initialise variable byte

	iny				; increment index
	sta	(FacTempStor+8),Y	; initialise variable byte

	iny				; increment index
	sta	(FacTempStor+8),Y	; initialise variable byte

; found a match for variable
A_B185					;				[B185]
	lda	FacTempStor+8		; get variable address LB
	clc				; clear carry for add
	adc	#$02			; +2, offset past variable name bytes
	ldy	FacTempStor+9		; get variable address HB
	bcc	A_B18F			; branch if no overflow from add

	iny				; else increment HB
A_B18F					;				[B18F]
	sta	VARPNT			; save current variable pointer LB
	sty	VARPNT+1		; save current variable pointer HB
	rts

; set-up array pointer to first element in array

SetupPointer				;				[B194]
	lda	COUNT			; get # of dimensions (1, 2 or 3)
	asl				; *2 (also clears the carry !)
	adc	#$05			; +5 (result is 7, 9 or 11 here)
	adc	FacTempStor+8		; add array start pointer LB
	ldy	FacTempStor+9		; get array pointer HB
	bcc	A_B1A0			; branch if no overflow

	iny				; else increment HB
A_B1A0					;				[B1A0]
	sta	FacTempStor+1		; save array data pointer LB
	sty	FacTempStor+2		; save array data pointer HB
	rts


;******************************************************************************
;
; -32768 as floating value

M32768					;				[B1A5]
.byte	$90,$80,$00,$00,$00		; -32768


;******************************************************************************
;
; convert float to fixed

Float2Fixed				;				[B1AA]
	jsr	EvalInteger3		; evaluate integer expression, no sign
					; check	[B1BF]

	lda	FacMantissa+2		; get result LB
	ldy	FacMantissa+3		; get result HB
	rts


;******************************************************************************
;
; evaluate integer expression

EvalInteger				;				[B1B2]
	jsr	CHRGET			; increment and scan memory	[0073]
	jsr	EvaluateValue		; evaluate expression		[AD9E]

; evaluate integer expression, sign check

EvalInteger2				;				[B1B8]
	jsr	CheckIfNumeric		; check if source is numeric, else do
					; type mismatch			[AD8D]
	lda	FACSGN			; get FAC1 sign (b7)
	bmi	A_B1CC			; do illegal quantity error if -ve

; evaluate integer expression, no sign check

EvalInteger3				;				[B1BF]
	lda	FACEXP			; get FAC1 exponent
	cmp	#$90			; compare with exponent = 2^16 (n>2^15)
	bcc	A_B1CE			; if n<2^16 go convert FAC1 floating to
					; fixed and return
	lda	#<M32768		; set pointer LB to -32768
	ldy	#>M32768		; set pointer HB to -32768
	jsr	CmpFAC1withAY		; compare FAC1 with (AY)	[BC5B]
A_B1CC					;				[B1CC]
	bne	IllegalQuant		; if <> do illegal quantity error then
					; warm start
A_B1CE					;				[B1CE]
	jmp	FAC1Float2Fix		; convert FAC1 floating to fixed and
					; return			[BC9B]

;******************************************************************************
;
; an array is stored as follows
;
; array name		; two bytes with following patterns for different types
;			; 1st char  2nd char
;			;   b7	      b7      type    element size
;			; --------  --------  -----   ------------
;			;   0	      0	      Real	 5
;			;   0	      1	      string	 3
;			;   1	      1	      integer	 2
; offset to next array	; word
; dimension count	; byte
; 1st dimension size	; word, this is the number of elements including 0
; 2nd dimension size	; word, only here if the array has a second dimension
; 2nd dimension size	; word, only here if the array has a third dimension
;			; note: the dimension size word is in HB LB
;			; format, not like most 6502 words
; then for each element the required number of bytes given as the element size
; above

; find or make array

FindMakeArray				;				[B1D1]
	lda	DIMFLG			; get DIM flag
	ora	INTFLG			; OR with data type flag
	pha				; push it

	lda	VALTYP			; get data type flag, $FF = string,
					; $00 = numeric
	pha				; push it

	ldy	#$00			; clear dimensions count

; now get the array dimension(s) and stack it (them) before the data type and
; DIM flag

A_B1DB					;				[B1DB]
	tya				; copy dimensions count
	pha				; save it

	lda	VARNAM+1		; get array name 2nd byte
	pha				; save it

	lda	VARNAM			; get array name 1st byte
	pha				; save it

	jsr	EvalInteger		; evaluate integer expression	[B1B2]

	pla				; pull array name 1st byte
	sta	VARNAM			; restore array name 1st byte

	pla				; pull array name 2nd byte
	sta	VARNAM+1		; restore array name 2nd byte

	pla				; pull dimensions count
	tay				; restore it

	tsx				; copy stack pointer
	lda	STACK+2,X		; get DIM flag
	pha				; push it

	lda	STACK+1,X		; get data type flag
	pha				; push it

	lda	FacMantissa+2		; get this dimension size HB
	sta	STACK+2,X		; stack before flag bytes

	lda	FacMantissa+3		; get this dimension size LB
	sta	STACK+1,X		; stack before flag bytes

	iny				; increment dimensions count

	jsr	CHRGOT			; scan memory			[0079]
	cmp	#','			; compare with ","
	beq	A_B1DB			; if found go do next dimension

	sty	COUNT			; store dimensions count

	jsr	Chk4CloseParen		; scan for ")", else do syntax error
					; then warm start		[AEF7]
	pla				; pull data type flag
	sta	VALTYP			; restore data type flag, $FF = string,
					; $00 = numeric
	pla				; pull data type flag
	sta	INTFLG			; restore data type flag, $80 = integer,
					; $00 = float
	and	#$7F			; mask dim flag
	sta	DIMFLG			; restore DIM flag

	ldx	ARYTAB			; set end of variables LB
					; (array memory start LB)
	lda	ARYTAB+1		; set end of variables HB
					; (array memory start HB)

; now check to see if we are at the end of array memory, we would be if there
; were no arrays.

A_B21C					;				[B21C]
	stx	FacTempStor+8		; save as array start pointer LB
	sta	FacTempStor+9		; save as array start pointer HB

	cmp	STREND+1		; compare with end of arrays HB
	bne	A_B228			; branch if not reached array memory end

	cpx	STREND			; else compare with end of arrays LB
	beq	A_B261			; go build array if not found

; search for array
A_B228					;				[B228]
	ldy	#$00			; clear index
	lda	(FacTempStor+8),Y	; get array name first byte
	iny				; increment index to second name byte
	cmp	VARNAM			; compare with this array name first
					; byte
	bne	A_B237			; branch if no match

	lda	VARNAM+1		; else get this array name second byte
	cmp	(FacTempStor+8),Y	; compare with array name second byte
	beq	A_B24D			; array found so branch

; no match
A_B237					;				[B237]
	iny				; increment index
	lda	(FacTempStor+8),Y	; get array size LB
	clc				; clear carry for add
	adc	FacTempStor+8		; add array start pointer LB
	tax				; copy LB to X

	iny				; increment index
	lda	(FacTempStor+8),Y	; get array size HB
	adc	FacTempStor+9		; add array memory pointer HB
	bcc	A_B21C			; if no overflow go check next array


;******************************************************************************
;
; do bad subscript error

BadSubscript				;				[B245]
	ldx	#$12			; error $12, bad subscript error
.byte	$2C				; makes next line BIT $0EA2


;******************************************************************************
;
; do illegal quantity error

IllegalQuant				;				[B248]
	ldx	#$0E			; error $0E, illegal quantity error
A_B24A					;				[B24A]
	jmp	OutputErrMsg		; do error #X then warm start	[A437]


;******************************************************************************
;
; found the array

A_B24D					;				[B24D]
	ldx	#$13			; set error $13, double dimension error

	lda	DIMFLG			; get DIM flag
	bne	A_B24A			; if we are trying to dimension it do
					; error #X then warm start

; found the array and we're not dimensioning it so we must find an element in
; it

	jsr	SetupPointer		; set-up array pointer to first element
					; in array			[B194]
	lda	COUNT			; get dimensions count
	ldy	#$04			; set index to array's # of dimensions
	cmp	(FacTempStor+8),Y	; compare with no of dimensions
	bne	BadSubscript		; if wrong do bad subscript error

	jmp	GetArrElement		; found array so go get element	[B2EA]

; array not found, so build it
A_B261					;				[B261]
	jsr	SetupPointer		; set-up array pointer to first element
					; in array			[B194]
	jsr	CheckAvailMem		; check available memory, do out of
					; memory error if no room	[A408]
	ldy	#$00			; clear Y
	sty	FBUFPT+1		; clear array data size HB

	ldx	#$05			; set default element size
	lda	VARNAM			; get variable name 1st byte
	sta	(FacTempStor+8),Y	; save array name 1st byte
	bpl	A_B274			; branch if not string or floating
					; point array
	dex				; decrement element size, $04
A_B274					;				[B274]
	iny				; increment index
	lda	VARNAM+1		; get variable name 2nd byte
	sta	(FacTempStor+8),Y	; save array name 2nd byte
	bpl	A_B27D			; branch if not integer or string

	dex				; decrement element size, $03
	dex				; decrement element size, $02
A_B27D					;				[B27D]
	stx	FBUFPT			; save element size

	lda	COUNT			; get dimensions count
	iny				; increment index ..
	iny				; .. to array  ..
	iny				; .. dimension count
	sta	(FacTempStor+8),Y	; save array dimension count
A_B286					;				[B286]
	ldx	#$0B			; set default dimension size LB
	lda	#$00			; set default dimension size HB
	bit	DIMFLG			; test DIM flag
	bvc	A_B296			; branch if default to be used

	pla				; pull dimension size LB
	clc				; clear carry for add
	adc	#$01			; add 1, allow for zeroeth element
	tax				; copy LB to X

	pla				; pull dimension size HB
	adc	#$00			; add carry to HB
A_B296					;				[B296]
	iny				; incement index to dimension size HB
	sta	(FacTempStor+8),Y	; save dimension size HB

	iny				; incement index to dimension size LB
	txa				; copy dimension size LB
	sta	(FacTempStor+8),Y	; save dimension size LB

	jsr	CalcArraySize		; compute array size		[B34C]
	stx	FBUFPT			; save result LB
	sta	FBUFPT+1		; save result HB

	ldy	INDEX			; restore index
	dec	COUNT			; decrement dimensions count
	bne	A_B286			; loop if not all done

	adc	FacTempStor+2		; add array data pointer HB
	bcs	A_B30B			; if overflow do out of memory error
					; then warm start
	sta	FacTempStor+2		; save array data pointer HB

	tay				; copy array data pointer HB

	txa				; copy array size LB
	adc	FacTempStor+1		; add array data pointer LB
	bcc	A_B2B9			; branch if no rollover

	iny				; else increment next array pointer HB
	beq	A_B30B			; if rolled over do out of memory error
					; then warm start
A_B2B9					;				[B2B9]
	jsr	CheckAvailMem		; check available memory, do out of
					; memory error if no room	[A408]
	sta	STREND			; set end of arrays LB
	sty	STREND+1		; set end of arrays HB

; now the aray is created we need to zero all the elements in it

	lda	#$00			; clear A for array clear

	inc	FBUFPT+1		; increment array size HB, now block
					; count
	ldy	FBUFPT			; get array size LB, now index to block
	beq	A_B2CD			; branch if $00
A_B2C8					;				[B2C8]
	dey				; decrement index, do 0 to n-1
	sta	(FacTempStor+1),Y	; clear array element byte
	bne	A_B2C8			; loop until this block done

A_B2CD					;				[B2CD]
	dec	FacTempStor+2		; decrement array pointer HB

	dec	FBUFPT+1		; decrement block count HB
	bne	A_B2C8			; loop until all blocks done

	inc	FacTempStor+2		; correct for last loop

	sec				; set carry for subtract
	lda	STREND			; get end of arrays LB
	sbc	FacTempStor+8		; subtract array start LB
	ldy	#$02			; index to array size LB
	sta	(FacTempStor+8),Y	; save array size LB

	lda	STREND+1		; get end of arrays HB
	iny				; index to array size HB
	sbc	FacTempStor+9		; subtract array start HB
	sta	(FacTempStor+8),Y	; save array size HB

	lda	DIMFLG			; get default DIM flag
	bne	A_B34B			; exit if this was a DIM command

; else, find element
	iny				; set index to # of dimensions, the
					; dimension indeces are on the stack and
					; and will be removed as the position
					; of the array element is calculated

GetArrElement				;				[B2EA]
	lda	(FacTempStor+8),Y	; get array's dimension count
	sta	COUNT			; save it

	lda	#$00			; clear byte
	sta	FBUFPT			; clear array data pointer LB
A_B2F2					;				[B2F2]
	sta	FBUFPT+1		; save array data pointer HB

	iny				; increment index, point to array bound
					; HB
	pla				; pull array index LB
	tax				; copy to X
	sta	FacMantissa+2		; save index LB to FAC1 mantissa 3

	pla				; pull array index HB
	sta	FacMantissa+3		; save index HB to FAC1 mantissa 4

	cmp	(FacTempStor+8),Y	; compare with array bound HB
	bcc	A_B30E			; branch if within bounds

	bne	A_B308			; if outside bounds do bad subscript
					; error
; else HB was = so test LBs
	iny				; index to array bound LB
	txa				; get array index LB
	cmp	(FacTempStor+8),Y	; compare with array bound LB
	bcc	A_B30F			; branch if within bounds

A_B308					;				[B308]
	jmp	BadSubscript		; do bad subscript error	[B245]

A_B30B					;				[B30B]
	jmp	OutOfMemory		; do out of memory error then warm start
					;				[A435]

A_B30E					;				[B30E]
	iny				; index to array bound LB
A_B30F					;				[B30F]
	lda	FBUFPT+1		; get array data pointer HB
	ora	FBUFPT			; OR with array data pointer LB
	clc
	beq	A_B320			; branch if array data pointer = null,
					; skip multiply
	jsr	CalcArraySize		; compute array size		[B34C]

	txa				; get result LB
	adc	FacMantissa+2		; add index LB from FAC1 mantissa 3
	tax				; save result LB

	tya				; get result HB
	ldy	INDEX			; restore index
A_B320					;				[B320]
	adc	FacMantissa+3		; add index HB from FAC1 mantissa 4

	stx	FBUFPT			; save array data pointer LB

	dec	COUNT			; decrement dimensions count
	bne	A_B2F2			; loop if dimensions still to do

	sta	FBUFPT+1		; save array data pointer HB

	ldx	#$05			; set default element size

	lda	VARNAM			; get variable name 1st byte
	bpl	A_B331			; branch if not string or floating
					; point array
	dex				; decrement element size, $04
A_B331					;				[B331]
	lda	VARNAM+1		; get variable name 2nd byte
	bpl	A_B337			; branch if not integer or string

	dex				; decrement element size, $03
	dex				; decrement element size, $02
A_B337					;				[B337]
	stx	RESHO+2			; save dimension size LB

	lda	#$00			; clear dimension size HB
	jsr	CalcArraySize2		; compute array size		[B355]

	txa				; copy array size LB
	adc	FacTempStor+1		; add array data start pointer LB
	sta	VARPNT			; save as current variable pointer LB

	tya				; copy array size HB
	adc	FacTempStor+2		; add array data start pointer HB
	sta	VARPNT+1		; save as current variable pointer HB

	tay				; copy HB to Y
	lda	VARPNT			; get current variable pointer LB
					; pointer to element is now in AY
A_B34B					;				[B34B]
	rts


; compute array size, result in XY

CalcArraySize				;				[B34C]
	sty	INDEX			; save index
	lda	(FacTempStor+8),Y	; get dimension size LB
	sta	RESHO+2			; save dimension size LB

	dey				; decrement index
	lda	(FacTempStor+8),Y	; get dimension size HB
CalcArraySize2				;				[B355]
	sta	RESHO+3			; save dimension size HB

	lda	#$10			; count = $10 (16 bit multiply)
	sta	FacTempStor+6		; save bit count

	ldx	#$00			; clear result LB
	ldy	#$00			; clear result HB
A_B35F					;				[B35F]
	txa				; get result LB
	asl				; *2
	tax				; save result LB

	tya				; get result HB
	rol				; *2
	tay				; save result HB
	bcs	A_B30B			; if overflow go do "Out of memory"
					; error
	asl	FBUFPT			; shift element size LB
	rol	FBUFPT+1		; shift element size HB
	bcc	A_B378			; skip add if no carry

	clc				; else clear carry for add
	txa				; get result LB
	adc	RESHO+2			; add dimension size LB
	tax				; save result LB

	tya				; get result HB
	adc	RESHO+3			; add dimension size HB
	tay				; save result HB
	bcs	A_B30B			; if overflow go do "Out of memory"
					; error
A_B378					;				[B378]
	dec	FacTempStor+6		; decrement bit count
	bne	A_B35F			; loop until all done

	rts

; perform FRE()

bcFRE					;				[B37D]
	lda	VALTYP			; get data type flag, $FF = string,
					; $00 = numeric
	beq	A_B384			; branch if numeric

	jsr	PopStrDescStk		; pop string off descriptor stack, or
					; from top of string space returns with
					; A = length, X=$71=pointer LB,
					; Y=$72=pointer HB		[B6A6]
; FRE(n) was numeric so do this
A_B384					;				[B384]
	jsr	CollectGarbage		; go do garbage collection	[B526]

	sec				; set carry for subtract
	lda	FRETOP			; get bottom of string space LB
	sbc	STREND			; subtract end of arrays LB
	tay				; copy result to Y

	lda	FRETOP+1		; get bottom of string space HB
	sbc	STREND+1		; subtract end of arrays HB


;******************************************************************************
;
; convert fixed integer AY to float FAC1

ConvertAY2FAC1				;				[B391]
	ldx	#$00			; set type = numeric
	stx	VALTYP			; clear data type flag, $FF = string,
					; $00 = numeric
	sta	FacMantissa		; save FAC1 mantissa 1
	sty	FacMantissa+1		; save FAC1 mantissa 2

	ldx	#$90			; set exponent=2^16 (integer)
	jmp	J_BC44			; set exp = X, clear FAC1 3 and 4,
					; normalise and return		[BC44]

;******************************************************************************
;
; perform POS()

bcPOS					;				[B39E]
	sec				; set Cb for read cursor position
	jsr	CursorPosXY		; read/set X,Y cursor position	[FFF0]
bcPOS2					;				[B3A2]
	lda	#$00			; clear HB
	beq	ConvertAY2FAC1		; convert fixed integer AY to float
					; FAC1, branch always
; check not Direct, used by DEF and INPUT

ChkDirectMode				;				[B3A6]
	ldx	CURLIN+1		; get current line number HB
	inx				; increment it
	bne	A_B34B			; return if not direct mode

; else do illegal direct error
	ldx	#$15			; error $15, illegal direct error
.byte	$2C				; makes next line BIT $1BA2
A_B3AE					;				[B3AE]
	ldx	#$1B			; error $1B, undefined function error
	jmp	OutputErrMsg		; do error #X then warm start	[A437]


;******************************************************************************
;
; perform DEF

bcDEF					;				[B3B3]
	jsr	ChkFNxSyntax		; check FNx syntax		[B3E1]
	jsr	ChkDirectMode		; check not direct, back here if ok
					;				[B3A6]
	jsr	Chk4OpenParen		; scan for "(", else do syntax error
					; then warm start		[AEFA]

	lda	#$80			; set flag for FNx
	sta	SUBFLG			; save subscript/FNx flag

	jsr	GetAddrVar		; get variable address		[B08B]
	jsr	CheckIfNumeric		; check if source is numeric, else do
					; type mismatch			[AD8D]
	jsr	Chk4CloseParen		; scan for ")", else do syntax error
					; then warm start		[AEF7]

	lda	#TK_EQUAL		; get = token
	jsr	Chk4CharInA		; scan for CHR$(A), else do syntax
					; error then warm start		[AEFF]
	pha				; push next character

	lda	VARPNT+1		; get current variable pointer HB
	pha				; push it

	lda	VARPNT			; get current variable pointer LB
	pha				; push it

	lda	TXTPTR+1		; get BASIC execute pointer HB
	pha				; push it

	lda	TXTPTR			; get BASIC execute pointer LB
	pha				; push it

	jsr	bcDATA			; perform DATA			[A8F8]
	jmp	Ptrs2Function		; put execute pointer and variable
					; pointer into function	and return
					;				[B44F]

;******************************************************************************
;
; check FNx syntax

ChkFNxSyntax				;				[B3E1]
	lda	#TK_FN			; set FN token
	jsr	Chk4CharInA		; scan for CHR$(A), else do syntax error
					; then warm start		[AEFF]

	ora	#$80			; set FN flag bit
	sta	SUBFLG			; save FN name

	jsr	GetAddrVar3		; search for FN variable	[B092]
	sta	GarbagePtr		; save function pointer LB
	sty	GarbagePtr+1		; save function pointer HB

	jmp	CheckIfNumeric		; check if source is numeric and return,
					; else do type mismatch		[AD8D]

;******************************************************************************
;
; Evaluate FNx

EvaluateFNx				;				[B3F4]
	jsr	ChkFNxSyntax		; check FNx syntax		[B3E1]

	lda	GarbagePtr+1		; get function pointer HB
	pha				; push it

	lda	GarbagePtr		; get function pointer LB
	pha				; push it

	jsr	Chk4Parens		; evaluate expression within parentheses
					;				[AEF1]
	jsr	CheckIfNumeric		; check if source is numeric, else do
					; type mismatch			[AD8D]

	pla				; pop function pointer LB
	sta	GarbagePtr		; restore it

	pla				; pop function pointer HB
	sta	GarbagePtr+1		; restore it

	ldy	#$02			; index to variable pointer HB
	lda	(GarbagePtr),Y		; get variable address LB
	sta	VARPNT			; save current variable pointer LB

	tax				; copy address LB

	iny				; index to variable address HB
	lda	(GarbagePtr),Y		; get variable pointer HB
	beq	A_B3AE			; branch if HB zero

	sta	VARPNT+1		; save current variable pointer HB
	iny				; index to mantissa 3

; now stack the function variable value before use
A_B418					;				[B418]
	lda	(VARPNT),Y		; get byte from variable
	pha				; stack it

	dey				; decrement index
	bpl	A_B418			; loop until variable stacked

	ldy	VARPNT+1		; get current variable pointer HB
	jsr	PackFAC1intoXY		; pack FAC1 into (XY)		[BBD4]

	lda	TXTPTR+1		; get BASIC execute pointer HB
	pha				; push it

	lda	TXTPTR			; get BASIC execute pointer LB
	pha				; push it

	lda	(GarbagePtr),Y		; get function execute pointer LB
	sta	TXTPTR			; save BASIC execute pointer LB

	iny				; index to HB
	lda	(GarbagePtr),Y		; get function execute pointer HB
	sta	TXTPTR+1		; save BASIC execute pointer HB

	lda	VARPNT+1		; get current variable pointer HB
	pha				; push it

	lda	VARPNT			; get current variable pointer LB
	pha				; push it

	jsr	EvalExpression		; evaluate expression and check is
					; numeric, else do type mismatch [AD8A]
	pla				; pull variable address LB
	sta	GarbagePtr		; save variable address LB

	pla				; pull variable address HB
	sta	GarbagePtr+1		; save variable address HB

	jsr	CHRGOT			; scan memory			[0079]
	beq	A_B449			; branch if null ([EOL] marker)

	jmp	SyntaxError		; else syntax error then warm start
					;				[AF08]

; restore BASIC execute pointer and function variable from stack

A_B449					;				[B449]
	pla				; pull BASIC execute pointer LB
	sta	TXTPTR			; save BASIC execute pointer LB

	pla				; pull BASIC execute pointer HB
	sta	TXTPTR+1		; save BASIC execute pointer HB

;******************************************************************************
;
; put execute pointer and variable pointer into function

Ptrs2Function				;				[B44F]
	ldy	#$00			; clear index
	pla				; pull BASIC execute pointer LB
	sta	(GarbagePtr),Y		; save to function

	pla				; pull BASIC execute pointer HB
	iny				; increment index
	sta	(GarbagePtr),Y		; save to function

	pla				; pull current variable address LB
	iny				; increment index
	sta	(GarbagePtr),Y		; save to function

	pla				; pull current variable address HB
	iny				; increment index
	sta	(GarbagePtr),Y		; save to function

	pla				; pull ??
	iny				; increment index
	sta	(GarbagePtr),Y		; save to function

	rts


;******************************************************************************
;
; perform STR$()

bcSTR					;				[B465]
	jsr	CheckIfNumeric		; check if source is numeric, else do
					; type mismatch			[AD8D]
	ldy	#$00			; set string index
	jsr	FAC12String		; convert FAC1 to string	[BDDF]

	pla				; dump return address (skip type check)
	pla				; dump return address (skip type check)
bcSTR2					;				[B46F]
	lda	#<StrConvAddr		; set result string low pointer

	ldy	#>StrConvAddr		; set result string high pointer
	beq	QuoteStr2UtPtr		; print null terminated string to
					; utility pointer

;******************************************************************************
;
; do string vector
; copy descriptor pointer and make string space A bytes long

StringVector				;				[B475]
	ldx	FacMantissa+2		; get descriptor pointer LB
	ldy	FacMantissa+3		; get descriptor pointer HB
	stx	TempPtr			; save descriptor pointer LB
	sty	TempPtr+1		; save descriptor pointer HB


;******************************************************************************
;
; make string space A bytes long

StringLengthA				;				[B47D]
	jsr	CreStrAlong		; make space in string memory for string
					; A long			[B4F4]
	stx	FacMantissa		; save string pointer LB
	sty	FacMantissa+1		; save string pointer HB
	sta	FACEXP			; save length

	rts


;******************************************************************************
;
; scan, set up string
; print " terminated string to utility pointer

QuoteStr2UtPtr				;				[B487]
	ldx	#'"'			; set terminator to "
	stx	CHARAC			; set search character, terminator 1
	stx	ENDCHR			; set terminator 2

; print search or alternate terminated string to utility pointer
; source is AY

PrtStr2UtiPtr				;				[B48D]
	sta	ARISGN			; store string start LB
	sty	FACOV			; store string start HB
	sta	FacMantissa		; save string pointer LB
	sty	FacMantissa+1		; save string pointer HB

	ldy	#$FF			; set length to -1
A_B497					;				[B497]
	iny				; increment length
	lda	(ARISGN),Y		; get byte from string
	beq	A_B4A8			; exit loop if null byte [EOS]

	cmp	CHARAC			; compare with search character,
					; terminator 1
	beq	A_B4A4			; branch if terminator

	cmp	ENDCHR			; compare with terminator 2
	bne	A_B497			; loop if not terminator 2

A_B4A4					;				[B4A4]
	cmp	#'"'			; compare with "
	beq	A_B4A9			; branch if " (carry set if = !)

A_B4A8					;				[B4A8]
	clc				; clear carry for add (only if [EOL]
					; terminated string)
A_B4A9					;				[B4A9]
	sty	FACEXP			; save length in FAC1 exponent

	tya				; copy length to A
	adc	ARISGN			; add string start LB
	sta	FBUFPT			; save string end LB

	ldx	FACOV			; get string start HB
	bcc	A_B4B5			; branch if no LB overflow

	inx				; else increment HB
A_B4B5					;				[B4B5]
	stx	FBUFPT+1		; save string end HB

	lda	FACOV			; get string start HB
	beq	A_B4BF			; branch if in utility area

	cmp	#$02			; compare with input buffer memory HB
	bne	ChkRoomDescStk		; branch if not in input buffer memory

; string in input buffer or utility area, move to string memory
A_B4BF					;				[B4BF]
	tya				; copy length to A
	jsr	StringVector		; copy descriptor pointer and make
					; string space A bytes long	[B475]
	ldx	ARISGN			; get string start LB
	ldy	FACOV			; get string start HB
S_B4C7
	jsr	Str2UtilPtr2		; store string A bytes long from XY to
					; utility pointer		[B688]

; check for space on descriptor stack then ...
; put string address and length on descriptor stack and update stack pointers

ChkRoomDescStk				;				[B4CA]
	ldx	TEMPPT			; get the descriptor stack pointer
	cpx	#LASTPT+2+9		; compare it with the maximum + 1
	bne	A_B4D5			; if there is space on the string stack
					; continue
; else do string too complex error
	ldx	#$19			; error $19, string too complex error
A_B4D2					;				[B4D2]
	jmp	OutputErrMsg		; do error #X then warm start	[A437]

; put string address and length on descriptor stack and update stack pointers

A_B4D5					;				[B4D5]
	lda	FACEXP			; get the string length
	sta	D6510,X			; put it on the string stack

	lda	FacMantissa		; get the string pointer LB
	sta	D6510+1,X		; put it on the string stack

	lda	FacMantissa+1		; get the string pointer HB
	sta	D6510+2,X		; put it on the string stack

	ldy	#$00			; clear Y
	stx	FacMantissa+2		; save the string descriptor pointer LB
	sty	FacMantissa+3		; save the string descriptor pointer HB,
					; always $00
	sty	FACOV			; clear FAC1 rounding byte

	dey				; Y = $FF
	sty	VALTYP			; save the data type flag, $FF = string
	stx	LASTPT			; save the current descriptor stack
					; item pointer LB
	inx				; update the stack pointer
	inx				; update the stack pointer
	inx				; update the stack pointer
	stx	TEMPPT			; save the new descriptor stack pointer

	rts


;******************************************************************************
;
; make space in string memory for string A long
; return X = pointer LB, Y = pointer HB

CreStrAlong				;				[B4F4]
	lsr	GARBFL			; clear garbage collected flag (b7)

; make space for string A long
A_B4F6					;				[B4F6]
	pha				; save string length

	eor	#$FF			; complement it
	sec				; set carry for subtract, two's
					; complement add
	adc	FRETOP			; add bottom of string space LB,
					; subtract length
	ldy	FRETOP+1		; get bottom of string space HB
	bcs	A_B501			; skip decrement if no underflow

	dey				; decrement bottom of string space HB
A_B501					;				[B501]
	cpy	STREND+1		; compare with end of arrays HB
	bcc	A_B516			; do out of memory error if less

	bne	A_B50B			; if not = skip next test

	cmp	STREND			; compare with end of arrays LB
	bcc	A_B516			; do out of memory error if less

A_B50B					;				[B50B]
	sta	FRETOP			; save bottom of string space LB
	sty	FRETOP+1		; save bottom of string space HB
	sta	FRESPC			; save string utility ptr LB
	sty	FRESPC+1		; save string utility ptr HB

	tax				; copy LB to X

	pla				; get string length back
	rts

A_B516					;				[B516]
	ldx	#$10			; error code $10, out of memory error

	lda	GARBFL			; get garbage collected flag
	bmi	A_B4D2			; if set then do error code X

	jsr	CollectGarbage		; else go do garbage collection	[B526]

	lda	#$80			; flag for garbage collected
	sta	GARBFL			; set garbage collected flag

	pla				; pull length
	bne	A_B4F6			; go try again (loop always, length
					; should never be = $00)

;******************************************************************************
;
; garbage collection routine

CollectGarbage				;				[B526]
	ldx	MEMSIZ			; get end of memory LB
	lda	MEMSIZ+1		; get end of memory HB

; re-run routine from last ending

CollectGarbag2				;				[B52A]
	stx	FRETOP			; set bottom of string space LB
	sta	FRETOP+1		; set bottom of string space HB

	ldy	#$00			; clear index
	sty	GarbagePtr+1		; clear working pointer HB
	sty	GarbagePtr		; clear working pointer LB

	lda	STREND			; get end of arrays LB
	ldx	STREND+1		; get end of arrays HB
	sta	FacTempStor+8		; save as highest uncollected string
					; pointer LB
	stx	FacTempStor+9		; save as highest uncollected string
					; pointer HB
	lda	#LASTPT+2		; set descriptor stack pointer
	ldx	#$00			; clear X
	sta	INDEX			; save descriptor stack pointer LB
	stx	INDEX+1			; save descriptor stack pointer HB ($00)
A_B544					;				[B544]
	cmp	TEMPPT			; compare with descriptor stack pointer
	beq	A_B54D			; branch if =

	jsr	ChkStrSalvage		; check string salvageability	[B5C7]
	beq	A_B544			; loop always

; done stacked strings, now do string variables
A_B54D					;				[B54D]
	lda	#$07			; set step size = $07, collecting
					; variables
	sta	GarbColStep		; save garbage collection step size

	lda	VARTAB			; get start of variables LB
	ldx	VARTAB+1		; get start of variables HB
	sta	INDEX			; save as pointer LB
	stx	INDEX+1			; save as pointer HB
A_B559					;				[B559]
	cpx	ARYTAB+1		; compare end of variables HB,
					; start of arrays HB
	bne	A_B561			; branch if no HB match

	cmp	ARYTAB			; else compare end of variables LB,
					; start of arrays LB
	beq	A_B566			; branch if = variable memory end

A_B561					;				[B561]
	jsr	ChkVarSalvage		; check variable salvageability	[B5BD]
	beq	A_B559			; loop always

; done string variables, now do string arrays
A_B566					;				[B566]
	sta	FacTempStor+1		; save start of arrays LB as working
					; pointer
	stx	FacTempStor+2		; save start of arrays HB as working
					; pointer

	lda	#$03			; set step size, collecting descriptors
	sta	GarbColStep		; save step size
A_B56E					;				[B56E]
	lda	FacTempStor+1		; get pointer LB
	ldx	FacTempStor+2		; get pointer HB
A_B572					;				[B572]
	cpx	STREND+1		; compare with end of arrays HB
	bne	A_B57D			; branch if not at end

	cmp	STREND			; else compare with end of arrays LB
	bne	A_B57D			; branch if not at end

	jmp	CollectString		; collect string, tidy up and exit if
					; at end ??			[B606]

A_B57D					;				[B57D]
	sta	INDEX			; save pointer LB
	stx	INDEX+1			; save pointer HB

	ldy	#$00			; set index
	lda	(INDEX),Y		; get array name first byte
	tax				; copy it

	iny				; increment index
	lda	(INDEX),Y		; get array name second byte

	php				; push the flags

	iny				; increment index
	lda	(INDEX),Y		; get array size LB
	adc	FacTempStor+1		; add start of this array LB
	sta	FacTempStor+1		; save start of next array LB

	iny				; increment index
	lda	(INDEX),Y		; get array size HB
	adc	FacTempStor+2		; add start of this array HB
	sta	FacTempStor+2		; save start of next array HB

	plp				; restore the flags
	bpl	A_B56E			; skip if not string array

; was possibly string array so ...

	txa				; get name first byte back
	bmi	A_B56E			; skip if not string array

	iny				; increment index
	lda	(INDEX),Y		; get # of dimensions
	ldy	#$00			; clear index
	asl				; *2
	adc	#$05			; +5 (array header size)
	adc	INDEX			; add pointer LB
	sta	INDEX			; save pointer LB
	bcc	A_B5AE			; branch if no rollover

	inc	INDEX+1			; else increment pointer hgih byte
A_B5AE					;				[B5AE]
	ldx	INDEX+1			; get pointer HB
A_B5B0					;				[B5B0]
	cpx	FacTempStor+2		; compare pointer HB with end of this
					; array HB
	bne	A_B5B8			; branch if not there yet

	cmp	FacTempStor+1		; compare pointer LB with end of this
					; array LB
	beq	A_B572			; if at end of this array go check next
					; array
A_B5B8					;				[B5B8]
	jsr	ChkStrSalvage		; check string salvageability	[B5C7]
	beq	A_B5B0			; loop

; check variable salvageability

ChkVarSalvage				;				[B5BD]
	lda	(INDEX),Y		; get variable name first byte
	bmi	A_B5F6			; add step and exit if not string

	iny				; increment index
	lda	(INDEX),Y		; get variable name second byte
	bpl	A_B5F6			; add step and exit if not string

	iny				; increment index

; check string salvageability

ChkStrSalvage				;				[B5C7]
	lda	(INDEX),Y		; get string length
	beq	A_B5F6			; add step and exit if null string

	iny				; increment index
	lda	(INDEX),Y		; get string pointer LB
	tax				; copy to X

	iny				; increment index
	lda	(INDEX),Y		; get string pointer HB
	cmp	FRETOP+1		; compare string pointer HB with bottom
					; of string space HB
	bcc	A_B5DC			; if bottom of string space greater, go
					; test against highest uncollected
					; string
	bne	A_B5F6			; if bottom of string space less string
					; has been collected so go update
					; pointers, step to next and return
; HBs were equal so test LBs
	cpx	FRETOP			; compare string pointer LB with bottom
					; of string space LB
	bcs	A_B5F6			; if bottom of string space less string
					; has been collected so go update
					; pointers, step to next and return
; else test string against highest uncollected string so far
A_B5DC					;				[B5DC]
	cmp	FacTempStor+9		; compare string pointer HB with highest
					; uncollected string HB
	bcc	A_B5F6			; if highest uncollected string is
					; greater then go update pointers, step
					; to next and return
	bne	A_B5E6			; if highest uncollected string is less
					; then go set this string as highest
					; uncollected so far
; HBs were equal so test LBs
	cpx	FacTempStor+8		; compare string pointer LB with highest
					; uncollected string LB
	bcc	A_B5F6			; if highest uncollected string is
					; greater then go update pointers, step
					; to next and return
; else set current string as highest uncollected string
A_B5E6					;				[B5E6]
	stx	FacTempStor+8		; save string pointer LB as highest
					; uncollected string LB
	sta	FacTempStor+9		; save string pointer HB as highest
					; uncollected string HB
	lda	INDEX			; get descriptor pointer LB
	ldx	INDEX+1			; get descriptor pointer HB
	sta	GarbagePtr		; save working pointer HB
	stx	GarbagePtr+1		; save working pointer LB

	lda	GarbColStep		; get step size
	sta	Jump0054+1		; copy step size
A_B5F6					;				[B5F6]
	lda	GarbColStep		; get step size
	clc				; clear carry for add
	adc	INDEX			; add pointer LB
	sta	INDEX			; save pointer LB
	bcc	A_B601			; branch if no rollover

	inc	INDEX+1			; else increment pointer HB
A_B601					;				[B601]
	ldx	INDEX+1			; get pointer HB
	ldy	#$00			; flag not moved
	rts

; collect string

CollectString				;				[B606]
	lda	GarbagePtr+1		; get working pointer LB
	ora	GarbagePtr		; OR working pointer HB
	beq	A_B601			; exit if nothing to collect

	lda	Jump0054+1		; get copied step size
	and	#$04			; mask step size, $04 for variables,
					; $00 for array or stack
	lsr				; >> 1
	tay				; copy to index
	sta	Jump0054+1		; save offset to descriptor start

	lda	(GarbagePtr),Y		; get string length LB
	adc	FacTempStor+8		; add string start LB
	sta	FacTempStor+3		; set block end LB

	lda	FacTempStor+9		; get string start HB
	adc	#$00			; add carry
	sta	FacTempStor+4		; set block end HB

	lda	FRETOP			; get bottom of string space LB
	ldx	FRETOP+1		; get bottom of string space HB
	sta	FacTempStor+1		; save destination end LB
	stx	FacTempStor+2		; save destination end HB

	jsr	MoveBlock2		; open up space in memory, don't set
					; array end. this copies the string from
					; where it is to the end of the
					; uncollected string memory	[A3BF]
	ldy	Jump0054+1		; restore offset to descriptor start
	iny				; increment index to string pointer LB
	lda	FacTempStor+1		; get new string pointer LB
	sta	(GarbagePtr),Y		; save new string pointer LB
	tax				; copy string pointer LB

	inc	FacTempStor+2		; increment new string pointer HB

	lda	FacTempStor+2		; get new string pointer HB
	iny				; increment index to string pointer HB
	sta	(GarbagePtr),Y		; save new string pointer HB

	jmp	CollectGarbag2		; re-run routine from last ending, XA
					; holds new bottom		[B52A]
					; of string memory pointer


;******************************************************************************
;
; concatenate
; add strings, the first string is in the descriptor, the second string is in
; line

ConcatStrings				;				[B63D]
	lda	FacMantissa+3		; get descriptor pointer HB
	pha				; put on stack

	lda	FacMantissa+2		; get descriptor pointer LB
	pha				; put on stack

	jsr	GetNextParm		; get value from line		[AE83]
	jsr	CheckIfString		; check if source is string, else do
					; type mismatch			[AD8F]
	pla				; get descriptor pointer LB back
	sta	ARISGN			; set pointer LB

	pla				; get descriptor pointer HB back
	sta	FACOV			; set pointer HB

	ldy	#$00			; clear index
	lda	(ARISGN),Y		; get length of first string from
					; descriptor
	clc				; clear carry for add
	adc	(FacMantissa+2),Y	; add length of second string
	bcc	A_B65D			; branch if no overflow

	ldx	#$17			; else error $17, string too long error
	jmp	OutputErrMsg		; do error #X then warm start	[A437]

A_B65D					;				[B65D]
	jsr	StringVector		; copy descriptor pointer and make
					; string space A bytes long	[B475]
	jsr	Str2UtilPtr		; copy string from descriptor to utility
					; pointer			[B67A]

	lda	TempPtr			; get descriptor pointer LB
	ldy	TempPtr+1		; get descriptor pointer HB
	jsr	PopStrDescStk2		; pop (YA) descriptor off stack or from
					; top of string space returns with
					; A = length, X = pointer LB,
					; Y = pointer HB		[B6AA]
	jsr	Str2UtilPtr3		; store string from pointer to utility
					; pointer			[B68C]
	lda	ARISGN			; get descriptor pointer LB
	ldy	FACOV			; get descriptor pointer HB
	jsr	PopStrDescStk2		; pop (YA) descriptor off stack or from
					; top of string space returns with
					; A = length, X = pointer LB,
					; Y = pointer HB		[B6AA]
	jsr	ChkRoomDescStk		; check space on descriptor stack then
					; put string address and length on
					; descriptor stack and update stack
					; pointers			[B4CA]
	jmp	EvaluateValue3		; continue evaluation		[ADB8]


;******************************************************************************
;
; copy string from descriptor to utility pointer

Str2UtilPtr				;				[B67A]
	ldy	#$00			; clear index
	lda	(ARISGN),Y		; get string length
	pha				; save it

	iny				; increment index
	lda	(ARISGN),Y		; get string pointer LB
	tax				; copy to X

	iny				; increment index
	lda	(ARISGN),Y		; get string pointer HB
	tay				; copy to Y

	pla				; get length back
Str2UtilPtr2				;				[B688]
	stx	INDEX			; save string pointer LB
	sty	INDEX+1			; save string pointer HB

; store string from pointer to utility pointer

Str2UtilPtr3				;				[B68C]
	tay				; copy length as index
	beq	A_B699			; branch if null string

	pha				; save length
A_B690					;				[B690]
	dey				; decrement length/index
	lda	(INDEX),Y		; get byte from string
	sta	(FRESPC),Y		; save byte to destination

	tya				; copy length/index
	bne	A_B690			; loop if not all done yet

	pla				; restore length
A_B699					;				[B699]
	clc				; clear carry for add
	adc	FRESPC			; add string utility ptr LB
	sta	FRESPC			; save string utility ptr LB
	bcc	A_B6A2			; branch if no rollover

	inc	FRESPC+1		; increment string utility ptr HB
A_B6A2					;				[B6A2]
	rts


;******************************************************************************
;
; evaluate string

EvalString				;				[B6A3]
	jsr	CheckIfString		; check if source is string, else do
					; type mismatch			[AD8F]

; pop string off descriptor stack, or from top of string space
; returns with A = length, X = pointer LB, Y = pointer HB

PopStrDescStk				;				[B6A6]
	lda	FacMantissa+2		; get descriptor pointer LB
	ldy	FacMantissa+3		; get descriptor pointer HB

; pop (YA) descriptor off stack or from top of string space
; returns with A = length, X = pointer LB, Y = pointer HB

PopStrDescStk2				;				[B6AA]
	sta	INDEX			; save string pointer LB
	sty	INDEX+1			; save string pointer HB

	jsr	ClrDescrStack		; clean descriptor stack, YA = pointer
					;				[B6DB]
	php				; save status flags

	ldy	#$00			; clear index
	lda	(INDEX),Y		; get length from string descriptor
	pha				; put on stack

	iny				; increment index
	lda	(INDEX),Y		; get string pointer LB from descriptor
	tax				; copy to X

	iny				; increment index
	lda	(INDEX),Y		; get string pointer HB from descriptor
	tay				; copy to Y

	pla				; get string length back

	plp				; restore status
	bne	A_B6D6			; branch if pointer <> last_sl,last_sh

	cpy	FRETOP+1		; compare with bottom of string space HB
	bne	A_B6D6			; branch if <>

	cpx	FRETOP			; else compare with bottom of string
					; space LB
	bne	A_B6D6			; branch if <>

	pha				; save string length

	clc				; clear carry for add
	adc	FRETOP			; add bottom of string space LB
	sta	FRETOP			; set bottom of string space LB
	bcc	A_B6D5			; skip increment if no overflow

	inc	FRETOP+1		; increment bottom of string space HB
A_B6D5					;				[B6D5]
	pla				; restore string length
A_B6D6					;				[B6D6]
	stx	INDEX			; save string pointer LB
	sty	INDEX+1			; save string pointer HB

	rts

; clean descriptor stack, YA = pointer
; checks if AY is on the descriptor stack, if so does a stack discard

ClrDescrStack				;				[B6DB]
	cpy	LASTPT+1		; compare HB with current descriptor
					; stack item pointer HB
	bne	A_B6EB			; exit if <>

	cmp	LASTPT			; compare LB with current descriptor
					; stack item pointer LB
	bne	A_B6EB			; exit if <>

	sta	TEMPPT			; set descriptor stack pointer
	sbc	#$03			; update last string pointer LB
	sta	LASTPT			; save current descriptor stack item
					; pointer LB
	ldy	#$00			; clear HB
A_B6EB					;				[B6EB]
	rts


;******************************************************************************
;
; perform CHR$()

bcCHR					;				[B6EC]
	jsr	EvalByteExpr		; evaluate byte expression, result in X
					;				[B7A1]
	txa				; copy to A
	pha				; save character

	lda	#$01			; string is single byte
	jsr	StringLengthA		; make string space A bytes long [B47D]

	pla				; get character back
	ldy	#$00			; clear index
	sta	(FacMantissa),Y		; save byte in string - byte IS string!

	pla				; dump return address (skip type check)
	pla				; dump return address (skip type check)

	jmp	ChkRoomDescStk		; check space on descriptor stack then
					; put string address and length on
					; descriptor stack and update stack
					; pointers			[B4CA]

;******************************************************************************
;
; perform LEFT$()

bcLEFT					;				[B700]
	jsr	PullStrFromStk		; pull string data and byte parameter
					; from stack return pointer in
					; descriptor, byte in A (and X), Y=0
					;				[B761]
	cmp	(TempPtr),Y		; compare byte parameter with string
					; length
	tya				; clear A
bcLEFT2					;				[B706]
	bcc	A_B70C			; branch if string length > byte param

	lda	(TempPtr),Y		; else make parameter = length
	tax				; copy to byte parameter copy

	tya				; clear string start offset
A_B70C					;				[B70C]
	pha				; save string start offset
A_B70D					;				[B70D]
	txa				; copy byte parameter (or string length
					; if <)
A_B70E					;				[B70E]
	pha				; save string length

	jsr	StringLengthA		; make string space A bytes long [B47D]

	lda	TempPtr			; get descriptor pointer LB
	ldy	TempPtr+1		; get descriptor pointer HB
	jsr	PopStrDescStk2		; pop (YA) descriptor off stack or from
					; top of string space returns with
					; A = length, X = pointer LB,
					; Y = pointer HB		[B6AA]
	pla				; get string length back
	tay				; copy length to Y

	pla				; get string start offset back
	clc				; clear carry for add
	adc	INDEX			; add start offset to string start
					; pointer LB
	sta	INDEX			; save string start pointer LB
	bcc	A_B725			; branch if no overflow

	inc	INDEX+1			; else increment string start pointer HB
A_B725					;				[B725]
	tya				; copy length to A
	jsr	Str2UtilPtr3		; store string from pointer to utility
					; pointer			[B68C]

	jmp	ChkRoomDescStk		; check space on descriptor stack then
					; put string address and length on
					; descriptor stack and update stack
					; pointers			[B4CA]

;******************************************************************************
;
; perform RIGHT$()

bcRIGHT					;				[B72C]
	jsr	PullStrFromStk		; pull string data and byte parameter
					; from stack return pointer in
					; descriptor, byte in A (and X), Y=0
					;				[B761]
	clc				; clear carry for add-1
	sbc	(TempPtr),Y		; subtract string length
	eor	#$FF			; invert it (A=LEN(expression$)-l)
	jmp	bcLEFT2			; go do rest of LEFT$()		[B706]


;******************************************************************************
;
; perform MID$()

bcMID					;				[B737]
	lda	#$FF			; set default length = 255
	sta	FacMantissa+3		; save default length

	jsr	CHRGOT			; scan memory			[0079]
	cmp	#')'			; compare with ")"
	beq	A_B748			; branch if = ")" (skip second byte get)

	jsr	Chk4Comma		; scan for ",", else do syntax error
					; then warm start		[AEFD]
	jsr	GetByteParm2		; get byte parameter		[B79E]
A_B748					;				[B748]
	jsr	PullStrFromStk		; pull string data and byte parameter
					; from stack return pointer in
					; descriptor, byte in A (and X), Y=0
					;				[B761]
	beq	A_B798			; if null do illegal quantity error then
					; warm start
	dex				; decrement start index
	txa				; copy to A
	pha				; save string start offset

	clc				; clear carry for sub-1
	ldx	#$00			; clear output string length
	sbc	(TempPtr),Y		; subtract string length
	bcs	A_B70D			; if start>string length go do null
					; string
	eor	#$FF			; complement -length
	cmp	FacMantissa+3		; compare byte parameter
	bcc	A_B70E			; if length > remaining string go do
					; RIGHT$
	lda	FacMantissa+3		; get length byte
	bcs	A_B70E			; go do string copy, branch always


;******************************************************************************
;
; pull string data and byte parameter from stack
; return pointer in descriptor, byte in A (and X), Y=0

PullStrFromStk				;				[B761]
	jsr	Chk4CloseParen		; scan for ")", else do syntax error
					; then warm start		[AEF7]
	pla				; pull return address LB
	tay				; save return address LB

	pla				; pull return address HB
	sta	Jump0054+1		; save return address HB

	pla				; dump call to function vector LB
	pla				; dump call to function vector HB

	pla				; pull byte parameter
	tax				; copy byte parameter to X

	pla				; pull string pointer LB
	sta	TempPtr			; save it

	pla				; pull string pointer HB
	sta	TempPtr+1		; save it

	lda	Jump0054+1		; get return address HB
	pha				; back on stack

	tya				; get return address LB
	pha				; back on stack

	ldy	#$00			; clear index
	txa				; copy byte parameter

	rts


;******************************************************************************
;
; perform LEN()

bcLEN					;				[B77C]
	jsr	GetLengthStr		; evaluate string, get length in A
					; (and Y)			[B782]
	jmp	bcPOS2			; convert Y to byte in FAC1 and return
					;				[B3A2]

;******************************************************************************
;
; evaluate string, get length in Y

GetLengthStr				;				[B782]
	jsr	EvalString		; evaluate string		[B6A3]

	ldx	#$00			; set data type = numeric
	stx	VALTYP			; clear data type flag, $FF = string,
					; $00 = numeric
	tay				; copy length to Y

	rts


;******************************************************************************
;
; perform ASC()

bcASC					;				[B78B]
	jsr	GetLengthStr		; evaluate string, get length in A
					; (and Y)			[B782]
	beq	A_B798			; if null do illegal quantity error then
					; warm start
	ldy	#$00			; set index to first character
	lda	(INDEX),Y		; get byte
	tay				; copy to Y

	jmp	bcPOS2			; convert Y to byte in FAC1 and return
					;				[B3A2]

;******************************************************************************
;
; do illegal quantity error then warm start

A_B798					;				[B798]
	jmp	IllegalQuant		; do illegal quantity error then warm
					; start				[B248]

;******************************************************************************
;
; scan and get byte parameter

GetByteParm				;				[B79B]
	jsr	CHRGET			; increment and scan memory	[0073]


;******************************************************************************
;
; get byte parameter

GetByteParm2				;				[B79E]
	jsr	EvalExpression		; evaluate expression and check is
					; numeric, else do type mismatch [AD8A]

;******************************************************************************
;
; evaluate byte expression, result in X

EvalByteExpr				;				[B7A1]
	jsr	EvalInteger2		; evaluate integer expression, sign
					; check				[B1B8]
	ldx	FacMantissa+2		; get FAC1 mantissa 3
	bne	A_B798			; if not null do illegal quantity error
					; then warm start
	ldx	FacMantissa+3		; get FAC1 mantissa 4
	jmp	CHRGOT			; scan memory and return	[0079]


;******************************************************************************
;
; perform VAL()

bcVAL					;				[B7AD]
	jsr	GetLengthStr		; evaluate string, get length in A
					; (and Y)			[B782]
	bne	A_B7B5			; branch if not null string

; string was null so set result = $00
	jmp	ClrFAC1ExpSgn		; clear FAC1 exponent and sign and
					; return			[B8F7]
A_B7B5					;				[B7B5]
	ldx	TXTPTR			; get BASIC execute pointer LB
	ldy	TXTPTR+1		; get BASIC execute pointer HB
	stx	FBUFPT			; save BASIC execute pointer LB
	sty	FBUFPT+1		; save BASIC execute pointer HB

	ldx	INDEX			; get string pointer LB
	stx	TXTPTR			; save BASIC execute pointer LB

	clc				; clear carry for add
	adc	INDEX			; add string length
	sta	INDEX+2			; save string end LB

	ldx	INDEX+1			; get string pointer HB
	stx	TXTPTR+1		; save BASIC execute pointer HB
	bcc	A_B7CD			; branch if no HB increment

	inx				; increment string end HB
A_B7CD					;				[B7CD]
	stx	INDEX+3			; save string end HB

	ldy	#$00			; set index to $00
	lda	(INDEX+2),Y		; get string end byte
	pha				; push it

	tya				; clear A
	sta	(INDEX+2),Y		; terminate string with $00

	jsr	CHRGOT			; scan memory			[0079]
	jsr	String2FAC1		; get FAC1 from string		[BCF3]

	pla				; restore string end byte
	ldy	#$00			; clear index
	sta	(INDEX+2),Y		; put string end byte back


;******************************************************************************
;
; restore BASIC execute pointer from temp

RestBasExecPtr				;				[B7E2]
	ldx	FBUFPT			; get BASIC execute pointer LB back
	ldy	FBUFPT+1		; get BASIC execute pointer HB back
	stx	TXTPTR			; save BASIC execute pointer LB
	sty	TXTPTR+1		; save BASIC execute pointer HB

	rts


;******************************************************************************
;
; get parameters for POKE/WAIT

GetParms				;				[B7EB]
	jsr	EvalExpression		; evaluate expression and check is
					; numeric, else do type mismatch [AD8A]
	jsr	FAC1toTmpInt		; convert FAC_1 to integer in temporary
					; integer			[B7F7]
GetParms2				;				[B7F1]
	jsr	Chk4Comma		; scan for ",", else do syntax error
					; then warm start		[AEFD]
	jmp	GetByteParm2		; get byte parameter and return	[B79E]


;******************************************************************************
;
; convert FAC_1 to integer in temporary integer

FAC1toTmpInt				;				[B7F7]
	lda	FACSGN			; get FAC1 sign
	bmi	A_B798			; if -ve do illegal quantity error then
					; warm start
	lda	FACEXP			; get FAC1 exponent
	cmp	#$91			; compare with exponent = 2^16
	bcs	A_B798			; if >= do illegal quantity error then
					; warm start
	jsr	FAC1Float2Fix		; convert FAC1 floating to fixed [BC9B]

	lda	FacMantissa+2		; get FAC1 mantissa 3
	ldy	FacMantissa+3		; get FAC1 mantissa 4
	sty	LINNUM			; save temporary integer LB
	sta	LINNUM+1		; save temporary integer HB

	rts


;******************************************************************************
;
; perform PEEK()

bcPEEK					;				[B80D]
	lda	LINNUM+1		; get line number HB
	pha				; save line number HB

	lda	LINNUM			; get line number LB
	pha				; save line number LB

	jsr	FAC1toTmpInt		; convert FAC_1 to integer in temporary
					; integer			[B7F7]
	ldy	#$00			; clear index
	lda	(LINNUM),Y		; read byte
	tay				; copy byte to A

	pla				; pull byte
	sta	LINNUM			; restore line number LB

	pla				; pull byte
	sta	LINNUM+1		; restore line number HB

	jmp	bcPOS2			; convert Y to byte in FAC_1 and return
					;				[B3A2]

;******************************************************************************
;
; perform POKE

bcPOKE					;				[B824]
	jsr	GetParms		; get parameters for POKE/WAIT	[B7EB]
	txa				; copy byte to A
	ldy	#$00			; clear index
	sta	(LINNUM),Y		; write byte
	rts


;******************************************************************************
;
; perform WAIT

bcWAIT					;				[B82D]
	jsr	GetParms		; get parameters for POKE/WAIT	[B7EB]
	stx	FORPNT			; save byte

	ldx	#$00			; clear mask
	jsr	CHRGOT			; scan memory			[0079]
	beq	A_B83C			; skip if no third argument

	jsr	GetParms2		; scan for "," and get byte, else syntax
					; error then warm start	[B7F1]
A_B83C					;				[B83C]
	stx	FORPNT+1		; save EOR argument

	ldy	#$00			; clear index
A_B840					;				[B840]
	lda	(LINNUM),Y		; get byte via temporary integer
	eor	FORPNT+1		; EOR with second argument (mask)
	and	FORPNT			; AND with first argument (byte)
	beq	A_B840			; loop if result is zero

A_B848					;				[B848]
	rts


;******************************************************************************
;
; add 0.5 to FAC1 (round FAC1)

FAC1plus05				;				[B849]
	lda	#<L_BF11		; set 0.5 pointer LB
	ldy	#>L_BF11		; set 0.5 pointer HB
	jmp	AddFORvar2FAC1		; add (AY) to FAC1		[B867]


;******************************************************************************
;
; perform subtraction, FAC1 from (AY)

AYminusFAC1				;				[B850]
	jsr	UnpackAY2FAC2		; unpack memory (AY) into FAC2	[BA8C]


;******************************************************************************
;
; perform subtraction, FAC1 from FAC2

bcMINUS
	lda	FACSGN			; get FAC1 sign (b7)
	eor	#$FF			; complement it
	sta	FACSGN			; save FAC1 sign (b7)
	eor	ARGSGN			; EOR with FAC2 sign (b7)
	sta	ARISGN			; save sign compare (FAC1 EOR FAC2)
	lda	FACEXP			; get FAC1 exponent
	jmp	bcPLUS			; add FAC2 to FAC1 and return	[B86A]

A_B862					;				[B862]
	jsr	shftFACxAright		; shift FACX A times right (>8 shifts)
					;				[B999]
	bcc	A_B8A3			;.go subtract mantissas


;******************************************************************************
;
; add (AY) to FAC1

AddFORvar2FAC1				;				[B867]
	jsr	UnpackAY2FAC2		; unpack memory (AY) into FAC2	[BA8C]


;******************************************************************************
;
; add FAC2 to FAC1

bcPLUS					;				[B86A]
	bne	A_B86F			; branch if FAC1 is not zero

	jmp	CopyFAC2toFAC1		; FAC1 was zero so copy FAC2 to FAC1
					; and return			[BBFC]

; FAC1 is non zero
A_B86F					;				[B86F]
	ldx	FACOV			; get FAC1 rounding byte
	stx	Jump0054+2		; save as FAC2 rounding byte

	ldx	#ARGEXP			; set index to FAC2 exponent address
	lda	ARGEXP			; get FAC2 exponent
bcPLUS2					;				[B877]
	tay				; copy exponent
	beq	A_B848			; exit if zero

	sec				; set carry for subtract
	sbc	FACEXP			; subtract FAC1 exponent
	beq	A_B8A3			; if equal go add mantissas

	bcc	A_B893			; if FAC2 < FAC1 then shift FAC2 right

; else FAC2 > FAC1
	sty	FACEXP			; save FAC1 exponent

	ldy	ARGSGN			; get FAC2 sign (b7)
	sty	FACSGN			; save FAC1 sign (b7)

	eor	#$FF			; complement A
	adc	#$00			; +1, twos complement, carry is set

	ldy	#$00			; clear Y
	sty	Jump0054+2		; clear FAC2 rounding byte

	ldx	#FACEXP			; set index to FAC1 exponent address
	bne	A_B897			; branch always

; FAC2 < FAC1
A_B893					;				[B893]
	ldy	#$00			; clear Y
	sty	FACOV			; clear FAC1 rounding byte
A_B897					;				[B897]
	cmp	#$F9			; compare exponent diff with $F9
	bmi	A_B862			; branch if range $79-$F8

	tay				; copy exponent difference to Y

	lda	FACOV			; get FAC1 rounding byte

	lsr	D6510+1,X		; shift FAC? mantissa 1

	jsr	shftFACxYright		; shift FACX Y times right	[B9B0]

; exponents are equal now do mantissa subtract
A_B8A3					;				[B8A3]
	bit	ARISGN			; test sign compare (FAC1 EOR FAC2)
	bpl	A_B8FE			; if = add FAC2 mantissa to FAC1
					; mantissa and return
	ldy	#FACEXP			; set the Y index to FAC1 exponent
					; address
	cpx	#ARGEXP			; compare X to FAC2 exponent address
	beq	A_B8AF			; if = continue, Y = FAC1, X = FAC2

	ldy	#ARGEXP			; else set the Y index to FAC2 exponent
					; address
; subtract the smaller from the bigger (take the sign of
; the bigger)
A_B8AF					;				[B8AF]
	sec				; set carry for subtract
	eor	#$FF			; ones complement A
	adc	Jump0054+2		; add FAC2 rounding byte
	sta	FACOV			; save FAC1 rounding byte

	lda	D6510+4,Y		; get FACY mantissa 4
	sbc	D6510+4,X		; subtract FACX mantissa 4
	sta	FacMantissa+3		; save FAC1 mantissa 4

	lda	D6510+3,Y		; get FACY mantissa 3
	sbc	D6510+3,X		; subtract FACX mantissa 3
	sta	FacMantissa+2		; save FAC1 mantissa 3

	lda	D6510+2,Y		; get FACY mantissa 2
	sbc	D6510+2,X		; subtract FACX mantissa 2
	sta	FacMantissa+1		; save FAC1 mantissa 2

	lda	D6510+1,Y		; get FACY mantissa 1
	sbc	D6510+1,X		; subtract FACX mantissa 1
	sta	FacMantissa		; save FAC1 mantissa 1


;******************************************************************************
;
; do ABS and normalise FAC1

AbsNormalFAC1				;				[B8D2]
	bcs	NormaliseFAC1		; branch if number is positive

	jsr	NegateFAC1		; negate FAC1			[B947]


;******************************************************************************
;
; normalise FAC1

NormaliseFAC1				;				[B8D7]
	ldy	#$00			; clear Y
	tya				; clear A
	clc				; clear carry for add
A_B8DB					;				[B8DB]
	ldx	FacMantissa		; get FAC1 mantissa 1
	bne	A_B929			; if not zero normalise FAC1

	ldx	FacMantissa+1		; get FAC1 mantissa 2
	stx	FacMantissa		; save FAC1 mantissa 1

	ldx	FacMantissa+2		; get FAC1 mantissa 3
	stx	FacMantissa+1		; save FAC1 mantissa 2

	ldx	FacMantissa+3		; get FAC1 mantissa 4
	stx	FacMantissa+2		; save FAC1 mantissa 3

	ldx	FACOV			; get FAC1 rounding byte
	stx	FacMantissa+3		; save FAC1 mantissa 4

	sty	FACOV			; clear FAC1 rounding byte

	adc	#$08			; add x to exponent offset
	cmp	#$20			; compare with $20, max offset, all bits
					; would be = 0
	bne	A_B8DB			; loop if not max


;******************************************************************************
;
; clear FAC1 exponent and sign

ClrFAC1ExpSgn				;				[B8F7]
	lda	#$00			; clear A
ClrFAC1Exp				;				[B8F9]
	sta	FACEXP			; set FAC1 exponent


;******************************************************************************
;
; save FAC1 sign

SaveFAC1Sign				;				[B8FB]
	sta	FACSGN			; save FAC1 sign (b7)
	rts


;******************************************************************************
;
; add FAC2 mantissa to FAC1 mantissa

A_B8FE					;				[B8FE]
	adc	Jump0054+2		; add FAC2 rounding byte
	sta	FACOV			; save FAC1 rounding byte

	lda	FacMantissa+3		; get FAC1 mantissa 4
	adc	ArgMantissa+3		; add FAC2 mantissa 4
	sta	FacMantissa+3		; save FAC1 mantissa 4

	lda	FacMantissa+2		; get FAC1 mantissa 3
	adc	ArgMantissa+2		; add FAC2 mantissa 3
	sta	FacMantissa+2		; save FAC1 mantissa 3

	lda	FacMantissa+1		; get FAC1 mantissa 2
	adc	ArgMantissa+1		; add FAC2 mantissa 2
	sta	FacMantissa+1		; save FAC1 mantissa 2

	lda	FacMantissa		; get FAC1 mantissa 1
	adc	ArgMantissa		; add FAC2 mantissa 1
	sta	FacMantissa		; save FAC1 mantissa 1

	jmp	NormaliseFAC12		; test and normalise FAC1 for C=0/1
					;				[B936]

A_B91D					;				[B91D]
	adc	#$01			; add 1 to exponent offset
	asl	FACOV			; shift FAC1 rounding byte
	rol	FacMantissa+3		; shift FAC1 mantissa 4
	rol	FacMantissa+2		; shift FAC1 mantissa 3
	rol	FacMantissa+1		; shift FAC1 mantissa 2
	rol	FacMantissa		; shift FAC1 mantissa 1

; normalise FAC1

A_B929					;				[B929]
	bpl	A_B91D			; loop if not normalised

	sec				; set carry for subtract
	sbc	FACEXP			; subtract FAC1 exponent
	bcs	ClrFAC1ExpSgn		; branch if underflow (set result = $0)

	eor	#$FF			; complement exponent
	adc	#$01			; +1 (twos complement)
	sta	FACEXP			; save FAC1 exponent

; test and normalise FAC1 for C=0/1

NormaliseFAC12				;				[B936]
	bcc	A_B946			; exit if no overflow

; normalise FAC1 for C=1

NormaliseFAC13				;				[B938]
	inc	FACEXP			; increment FAC1 exponent
	beq	OverflowError		; if zero do overflow error then warm
					; start
	ror	FacMantissa		; shift FAC1 mantissa 1
	ror	FacMantissa+1		; shift FAC1 mantissa 2
	ror	FacMantissa+2		; shift FAC1 mantissa 3
	ror	FacMantissa+3		; shift FAC1 mantissa 4
	ror	FACOV			; shift FAC1 rounding byte
A_B946					;				[B946]
	rts


;******************************************************************************
;
; negate FAC1

NegateFAC1				;				[B947]
	lda	FACSGN			; get FAC1 sign (b7)
	eor	#$FF			; complement it
	sta	FACSGN			; save FAC1 sign (b7)

; twos complement FAC1 mantissa

TwoComplFAC1				;				[B94D]
	lda	FacMantissa		; get FAC1 mantissa 1
	eor	#$FF			; complement it
	sta	FacMantissa		; save FAC1 mantissa 1

	lda	FacMantissa+1		; get FAC1 mantissa 2
	eor	#$FF			; complement it
	sta	FacMantissa+1		; save FAC1 mantissa 2

	lda	FacMantissa+2		; get FAC1 mantissa 3
	eor	#$FF			; complement it
	sta	FacMantissa+2		; save FAC1 mantissa 3

	lda	FacMantissa+3		; get FAC1 mantissa 4
	eor	#$FF			; complement it
	sta	FacMantissa+3		; save FAC1 mantissa 4

	lda	FACOV			; get FAC1 rounding byte
	eor	#$FF			; complement it
	sta	FACOV			; save FAC1 rounding byte

	inc	FACOV			; increment FAC1 rounding byte
	bne	A_B97D			; exit if no overflow

; increment FAC1 mantissa

IncFAC1Mant				;				[B96F]
	inc	FacMantissa+3		; increment FAC1 mantissa 4
	bne	A_B97D			; finished if no rollover

	inc	FacMantissa+2		; increment FAC1 mantissa 3
	bne	A_B97D			; finished if no rollover

	inc	FacMantissa+1		; increment FAC1 mantissa 2
	bne	A_B97D			; finished if no rollover

	inc	FacMantissa		; increment FAC1 mantissa 1
A_B97D					;				[B97D]
	rts


;******************************************************************************
;
; do overflow error then warm start

OverflowError				;				[B97E]
	ldx	#$0F			; error $0F, overflow error
	jmp	OutputErrMsg		; do error #X then warm start	[A437]


;******************************************************************************
;
; shift register to the right

ShiftRegRight				;				[B983]
	ldx	#RESHO-1		; set the offset to FACtemp
A_B985					;				[B985]
	ldy	RESHO-$22,X		; get FACX mantissa 4
	sty	FACOV			; save as FAC1 rounding byte

	ldy	RESHO-$23,X		; get FACX mantissa 3
	sty	RESHO-$22,X		; save FACX mantissa 4

	ldy	RESHO-$24,X		; get FACX mantissa 2
	sty	RESHO-$23,X		; save FACX mantissa 3

	ldy	RESHO-$25,X		; get FACX mantissa 1
	sty	RESHO-$24,X		; save FACX mantissa 2

	ldy	BITS			; get FAC1 overfLB
	sty	RESHO-$25,X		; save FACX mantissa 1

; shift FACX -A times right (> 8 shifts)

shftFACxAright				;				[B999]
	adc	#$08			; add 8 to shift count
	bmi	A_B985			; go do 8 shift if still -ve

	beq	A_B985			; go do 8 shift if zero

	sbc	#$08			; else subtract 8 again
	tay				; save count to Y

	lda	FACOV			; get FAC1 rounding byte
	bcs	A_B9BA			;.

A_B9A6					;				[B9A6]
	asl	D6510+1,X		; shift FACX mantissa 1
	bcc	A_B9AC			; branch if +ve

	inc	D6510+1,X		; this sets b7 eventually
A_B9AC					;				[B9AC]
	ror	D6510+1,X		; shift FACX mantissa 1, correct for ASL
	ror	D6510+1,X		; shift FACX mantissa 1, put carry in b7

; shift FACX Y times right

shftFACxYright				;				[B9B0]
	ror	D6510+2,X		; shift FACX mantissa 2
	ror	D6510+3,X		; shift FACX mantissa 3
	ror	D6510+4,X		; shift FACX mantissa 4
	ror				; shift FACX rounding byte

	iny				; increment exponent diff
	bne	A_B9A6			; branch if range adjust not complete

A_B9BA					;				[B9BA]
	clc				; just clear it
	rts


;******************************************************************************
;
; constants and series for LOG(n)

Constant1				;				[B9BC]
.byte	$81,$00,$00,$00,$00		; 1

ConstLogCoef				;				[B9C1]
.byte	$03				; series counter
.byte	$7F,$5E,$56,$CB,$79
.byte	$80,$13,$9B,$0B,$64
.byte	$80,$76,$38,$93,$16
.byte	$82,$38,$AA,$3B,$20

Const1divSQR2				;				[B9D6]
.byte	$80,$35,$04,$F3,$34		; 0.70711	1/root 2
ConstSQR2				;				[B9DB]
.byte	$81,$35,$04,$F3,$34		; 1.41421	root 2
Const05					;				[B9E0]
.byte	$80,$80,$00,$00,$00		; -0.5	1/2
ConstLOG2				;				[B9E5]
.byte	$80,$31,$72,$17,$F8		; 0.69315	LOG(2)


;******************************************************************************
;
; perform LOG()

bcLOG					;				[B9EA]
	jsr	GetFacSign		; test sign and zero		[BC2B]
	beq	A_B9F1			; if zero do illegal quantity error then
					; warm start
	bpl	A_B9F4			; skip error if +ve

A_B9F1					;				[B9F1]
	jmp	IllegalQuant		; do illegal quantity error then warm
					; start				[B248]
A_B9F4					;				[B9F4]
	lda	FACEXP			; get FAC1 exponent
	sbc	#$7F			; normalise it
	pha				; save it

	lda	#$80			; set exponent to zero
	sta	FACEXP			; save FAC1 exponent

	lda	#<Const1divSQR2		; pointer to 1/root 2 LB
	ldy	#>Const1divSQR2		; pointer to 1/root 2 HB
	jsr	AddFORvar2FAC1		; add (AY) to FAC1 (1/root2)	[B867]

	lda	#<ConstSQR2		; pointer to root 2 LB
	ldy	#>ConstSQR2		; pointer to root 2 HB
	jsr	AYdivFAC1		; convert AY and do (AY)/FAC1
					; (root2/(x+(1/root2)))		[BB0F]

	lda	#<Constant1		; pointer to 1 LB
	ldy	#>Constant1		; pointer to 1 HB
	jsr	AYminusFAC1		; subtr FAC1 ((root2/(x+(1/root2)))-1)
					; from (AY)			[B850]
	lda	#<ConstLogCoef		; pointer to series for LOG(n) LB
	ldy	#>ConstLogCoef		; pointer to series for LOG(n) HB
	jsr	Power2			; ^2 then series evaluation	[E043]

	lda	#<Const05		; pointer to -0.5 LB
	ldy	#>Const05		; pointer to -0.5 HB
	jsr	AddFORvar2FAC1		; add (AY) to FAC1		[B867]

	pla				; restore FAC1 exponent
	jsr	EvalNewDigit		; evaluate new ASCII digit	[BD7E]

	lda	#<ConstLOG2		; pointer to LOG(2) LB
	ldy	#>ConstLOG2		; pointer to LOG(2) HB


;******************************************************************************
;
; do convert AY, FCA1*(AY)

FAC1xAY					;				[BA28]
	jsr	UnpackAY2FAC2		; unpack memory (AY) into FAC2	[BA8C]
bcMULTIPLY				;				[BA2B]
	bne	A_BA30			; multiply FAC1 by FAC2 ??

	jmp	JmpRTS			; exit if zero			[BA8B]

A_BA30					;				[BA30]
	jsr	TestAdjFACs		; test and adjust accumulators	[BAB7]

	lda	#$00			; clear A
	sta	RESHO			; clear temp mantissa 1
	sta	RESHO+1			; clear temp mantissa 2
	sta	RESHO+2			; clear temp mantissa 3
	sta	RESHO+3			; clear temp mantissa 4

	lda	FACOV			; get FAC1 rounding byte
	jsr	ShftAddFAC2		; go do shift/add FAC2		[BA59]

	lda	FacMantissa+3		; get FAC1 mantissa 4
	jsr	ShftAddFAC2		; go do shift/add FAC2		[BA59]

	lda	FacMantissa+2		; get FAC1 mantissa 3
	jsr	ShftAddFAC2		; go do shift/add FAC2		[BA59]

	lda	FacMantissa+1		; get FAC1 mantissa 2
	jsr	ShftAddFAC2		; go do shift/add FAC2		[BA59]

	lda	FacMantissa		; get FAC1 mantissa 1
	jsr	ShftAddFAC22		; go do shift/add FAC2		[BA5E]

	jmp	TempToFAC1		; copy temp to FAC1, normalise and
					; return			[BB8F]
ShftAddFAC2				;				[BA59]
	bne	ShftAddFAC22		; branch if byte <> zero

	jmp	ShiftRegRight		; shift FCAtemp << A+8 times	[B983]

; else do shift and add
ShftAddFAC22				;				[BA5E]
	lsr				; shift byte
	ora	#$80			; set top bit (mark for 8 times)
A_BA61					;				[BA61]
	tay				; copy result
	bcc	A_BA7D			; skip next if bit was zero

	clc				; clear carry for add
	lda	RESHO+3			; get temp mantissa 4
	adc	ArgMantissa+3		; add FAC2 mantissa 4
	sta	RESHO+3			; save temp mantissa 4

	lda	RESHO+2			; get temp mantissa 3
	adc	ArgMantissa+2		; add FAC2 mantissa 3
	sta	RESHO+2			; save temp mantissa 3

	lda	RESHO+1			; get temp mantissa 2
	adc	ArgMantissa+1		; add FAC2 mantissa 2
	sta	RESHO+1			; save temp mantissa 2

	lda	RESHO			; get temp mantissa 1
	adc	ArgMantissa		; add FAC2 mantissa 1
	sta	RESHO			; save temp mantissa 1
A_BA7D					;				[BA7D]
	ror	RESHO			; shift temp mantissa 1
	ror	RESHO+1			; shift temp mantissa 2
	ror	RESHO+2			; shift temp mantissa 3
	ror	RESHO+3			; shift temp mantissa 4
	ror	FACOV			; shift temp rounding byte

	tya				; get byte back
	lsr				; shift byte
	bne	A_BA61			; loop if all bits not done

JmpRTS					;				[BA8B]
	rts


;******************************************************************************
;
; unpack memory (AY) into FAC2

UnpackAY2FAC2				;				[BA8C]
	sta	INDEX			; save pointer LB
	sty	INDEX+1			; save pointer HB

	ldy	#$04			; 5 bytes to get (0-4)
	lda	(INDEX),Y		; get mantissa 4
	sta	ArgMantissa+3		; save FAC2 mantissa 4

	dey				; decrement index
	lda	(INDEX),Y		; get mantissa 3
	sta	ArgMantissa+2		; save FAC2 mantissa 3

	dey				; decrement index
	lda	(INDEX),Y		; get mantissa 2
	sta	ArgMantissa+1		; save FAC2 mantissa 2

	dey				; decrement index
	lda	(INDEX),Y		; get mantissa 1 + sign
	sta	ARGSGN			; save FAC2 sign (b7)

	eor	FACSGN			; EOR with FAC1 sign (b7)
	sta	ARISGN			; save sign compare (FAC1 EOR FAC2)

	lda	ARGSGN			; recover FAC2 sign (b7)
	ora	#$80			; set 1xxx xxx (set normal bit)
	sta	ArgMantissa		; save FAC2 mantissa 1

	dey				; decrement index
	lda	(INDEX),Y		; get exponent byte
	sta	ARGEXP			; save FAC2 exponent

	lda	FACEXP			; get FAC1 exponent
	rts


;******************************************************************************
;
; test and adjust accumulators

TestAdjFACs				;				[BAB7]
	lda	ARGEXP			; get FAC2 exponent

TestAdjFACs2				;				[BAB9]
	beq	A_BADA			; branch if FAC2 = $00, handle underflow

	clc				; clear carry for add
	adc	FACEXP			; add FAC1 exponent
	bcc	A_BAC4			; branch if sum of exponents < $0100

	bmi	A_BADF			; do overflow error

	clc				; clear carry for the add
.byte	$2C				; makes next line BIT $1410
A_BAC4					;				[BAC4]
	bpl	A_BADA			; if +ve go handle underflow

	adc	#$80			; adjust exponent
	sta	FACEXP			; save FAC1 exponent
	bne	A_BACF			; branch if not zero

	jmp	SaveFAC1Sign		; save FAC1 sign and return	[B8FB]


A_BACF					;				[BACF]
	lda	ARISGN			; get sign compare (FAC1 EOR FAC2)
	sta	FACSGN			; save FAC1 sign (b7)

	rts

; handle overflow and underflow

HndlOvUnFlErr				;				[BAD4]
	lda	FACSGN			; get FAC1 sign (b7)
	eor	#$FF			; complement it
	bmi	A_BADF			; do overflow error

; handle underflow
A_BADA					;				[BADA]
	pla				; pop return address LB
	pla				; pop return address HB
	jmp	ClrFAC1ExpSgn		; clear FAC1 exponent and sign and
					; return			[B8F7]

A_BADF					;				[BADF]
	jmp	OverflowError		; do overflow error then warm start
					;				[B97E]

;******************************************************************************
;
; multiply FAC1 by 10

Fac1x10					;				[BAE2]
	jsr	CopyFAC1toFAC2		; round and copy FAC1 to FAC2	[BC0C]
	tax				; copy exponent (set the flags)
	beq	A_BAF8			; exit if zero

	clc				; clear carry for add
	adc	#$02			; add two to exponent (*4)
	bcs	A_BADF			; do overflow error if > $FF

; FAC1 = (FAC1 + FAC2) * 2

FAC1plFAC2x2				;				[BAED]
	ldx	#$00			; clear byte
	stx	ARISGN			; clear sign compare (FAC1 EOR FAC2)
	jsr	bcPLUS2			; add FAC2 to FAC1 (*5)		[B877]
	inc	FACEXP			; increment FAC1 exponent (*10)
	beq	A_BADF			; if exponent now zero go do overflow
					; error
A_BAF8					;				[BAF8]
	rts


;******************************************************************************
;
; 10 as a floating value

Constant10				;				[BAF9]
.byte	$84,$20,$00,$00,$00		; 10


;******************************************************************************
;
; divide FAC1 by 10

FAC1div10				;				[BAFE]
	jsr	CopyFAC1toFAC2		; round and copy FAC1 to FAC2	[BC0C]

	lda	#<Constant10		; set 10 pointer LB
	ldy	#>Constant10		; set 10 pointer HB
	ldx	#$00			; clear sign


;******************************************************************************
;
; divide by (AY) (X=sign)

FAC1divAY				;				[BB07]
	stx	ARISGN			; save sign compare (FAC1 EOR FAC2)
	jsr	UnpackAY2FAC1		; unpack memory (AY) into FAC1	[BBA2]
	jmp	bcDIVIDE		; do FAC2/FAC1			[BB12]


;******************************************************************************
;
; convert AY and do (AY)/FAC1

AYdivFAC1				;				[BB0F]
	jsr	UnpackAY2FAC2		; unpack memory (AY) into FAC2	[BA8C]
bcDIVIDE
	beq	A_BB8A			; if zero go do /0 error

	jsr	RoundFAC1		; round FAC1			[BC1B]

	lda	#$00			; clear A
	sec				; set carry for subtract
	sbc	FACEXP			; subtract FAC1 exponent (2s complement)
	sta	FACEXP			; save FAC1 exponent

	jsr	TestAdjFACs		; test and adjust accumulators	[BAB7]

	inc	FACEXP			; increment FAC1 exponent
	beq	A_BADF			; if zero do overflow error

	ldx	#$FC			; set index to FAC temp
	lda	#$01			;.set byte
A_BB29					;				[BB29]
	ldy	ArgMantissa		; get FAC2 mantissa 1
	cpy	FacMantissa		; compare FAC1 mantissa 1
	bne	A_BB3F			; branch if <>

	ldy	ArgMantissa+1		; get FAC2 mantissa 2
	cpy	FacMantissa+1		; compare FAC1 mantissa 2
	bne	A_BB3F			; branch if <>

	ldy	ArgMantissa+2		; get FAC2 mantissa 3
	cpy	FacMantissa+2		; compare FAC1 mantissa 3
	bne	A_BB3F			; branch if <>

	ldy	ArgMantissa+3		; get FAC2 mantissa 4
	cpy	FacMantissa+3		; compare FAC1 mantissa 4
A_BB3F					;				[BB3F]
	php				; save FAC2-FAC1 compare status

	rol				;.shift byte
	bcc	A_BB4C			; skip next if no carry

	inx				; increment index to FAC temp
	sta	RESHO+3,X		;.
	beq	A_BB7A			;.

	bpl	A_BB7E			;.

	lda	#$01			;.
A_BB4C					;				[BB4C]
	plp				; restore FAC2-FAC1 compare status
	bcs	A_BB5D			; if FAC2 >= FAC1 then do subtract

; FAC2 = FAC2*2
FAC2x2					;				[BB4F]
	asl	ArgMantissa+3		; shift FAC2 mantissa 4
	rol	ArgMantissa+2		; shift FAC2 mantissa 3
	rol	ArgMantissa+1		; shift FAC2 mantissa 2
	rol	ArgMantissa		; shift FAC2 mantissa 1
	bcs	A_BB3F			; loop with no compare

	bmi	A_BB29			; loop with compare

	bpl	A_BB3F			; Always -> loop with no compare


A_BB5D					;				[BB5D]
	tay				; save FAC2-FAC1 compare status

	lda	ArgMantissa+3		; get FAC2 mantissa 4
	sbc	FacMantissa+3		; subtract FAC1 mantissa 4
	sta	ArgMantissa+3		; save FAC2 mantissa 4

	lda	ArgMantissa+2		; get FAC2 mantissa 3
	sbc	FacMantissa+2		; subtract FAC1 mantissa 3
	sta	ArgMantissa+2		; save FAC2 mantissa 3

	lda	ArgMantissa+1		; get FAC2 mantissa 2
	sbc	FacMantissa+1		; subtract FAC1 mantissa 2
	sta	ArgMantissa+1		; save FAC2 mantissa 2

	lda	ArgMantissa		; get FAC2 mantissa 1
	sbc	FacMantissa		; subtract FAC1 mantissa 1
	sta	ArgMantissa		; save FAC2 mantissa 1

	tya				; restore FAC2-FAC1 compare status
	jmp	FAC2x2			;.				[BB4F]


A_BB7A					;				[BB7A]
	lda	#$40			;.
	bne	A_BB4C			; branch always


; do A<<6, save as FAC1 rounding byte, normalise and return

A_BB7E					;				[BB7E]
	asl				;.
	asl				;.
	asl				;.
	asl				;.
	asl				;.
	asl				;.
	sta	FACOV			; save FAC1 rounding byte
	plp				; dump FAC2-FAC1 compare status
	jmp	TempToFAC1		; copy temp to FAC1, normalise and
					; return			[BB8F]
; do "Divide by zero" error

A_BB8A					;				[BB8A]
	ldx	#$14			; error $14, divide by zero error
	jmp	OutputErrMsg		; do error #X then warm start	[A437]

TempToFAC1				;				[BB8F]
	lda	RESHO			; get temp mantissa 1
	sta	FacMantissa		; save FAC1 mantissa 1

	lda	RESHO+1			; get temp mantissa 2
	sta	FacMantissa+1		; save FAC1 mantissa 2

	lda	RESHO+2			; get temp mantissa 3
	sta	FacMantissa+2		; save FAC1 mantissa 3

	lda	RESHO+3			; get temp mantissa 4
	sta	FacMantissa+3		; save FAC1 mantissa 4

	jmp	NormaliseFAC1		; normalise FAC1 and return	[B8D7]


;******************************************************************************
;
; unpack memory (AY) into FAC1

UnpackAY2FAC1				;				[BBA2]
	sta	INDEX			; save pointer LB
	sty	INDEX+1			; save pointer HB

	ldy	#$04			; 5 bytes to do
	lda	(INDEX),Y		; get fifth byte
	sta	FacMantissa+3		; save FAC1 mantissa 4

	dey				; decrement index
	lda	(INDEX),Y		; get fourth byte
	sta	FacMantissa+2		; save FAC1 mantissa 3

	dey				; decrement index
	lda	(INDEX),Y		; get third byte
	sta	FacMantissa+1		; save FAC1 mantissa 2

	dey				; decrement index
	lda	(INDEX),Y		; get second byte
	sta	FACSGN			; save FAC1 sign (b7)

	ora	#$80			; set 1xxx, (add normal bit)
	sta	FacMantissa		; save FAC1 mantissa 1

	dey				; decrement index
	lda	(INDEX),Y		; get first byte (exponent)
	sta	FACEXP			; save FAC1 exponent
	sty	FACOV			; clear FAC1 rounding byte

	rts


;******************************************************************************
;
; pack FAC1 into FacTempStor+5

FAC1toTemp5				;				[BBC7]
	ldx	#<(FacTempStor+5)		; set pointer LB
.byte	$2C				; makes next line BIT FacTempStorA2


;******************************************************************************
;
; pack FAC1 into FacTempStor

FAC1toTemp				;				[BBCA]
	ldx	#<FacTempStor		; set pointer LB
	ldy	#>FacTempStor		; set pointer HB
	beq	PackFAC1intoXY		; pack FAC1 into (XY) and return,
					; branch always

;******************************************************************************
;
; pack FAC1 into variable pointer

Fac1ToVarPtr				;				[BBD0]
	ldx	FORPNT			; get destination pointer LB
	ldy	FORPNT+1		; get destination pointer HB


;******************************************************************************
;
; pack FAC1 into (XY)

PackFAC1intoXY				;				[BBD4]
	jsr	RoundFAC1		; round FAC1			[BC1B]
	stx	INDEX			; save pointer LB
	sty	INDEX+1			; save pointer HB

	ldy	#$04			; set index
	lda	FacMantissa+3		; get FAC1 mantissa 4
	sta	(INDEX),Y		; store in destination

	dey				; decrement index
	lda	FacMantissa+2		; get FAC1 mantissa 3
	sta	(INDEX),Y		; store in destination

	dey				; decrement index
	lda	FacMantissa+1		; get FAC1 mantissa 2
	sta	(INDEX),Y		; store in destination

	dey				; decrement index
	lda	FACSGN			; get FAC1 sign (b7)
	ora	#$7F			; set bits x111 1111
	and	FacMantissa		; AND in FAC1 mantissa 1
	sta	(INDEX),Y		; store in destination

	dey				; decrement index
	lda	FACEXP			; get FAC1 exponent
	sta	(INDEX),Y		; store in destination
	sty	FACOV			; clear FAC1 rounding byte

	rts


;******************************************************************************
;
; copy FAC2 to FAC1

CopyFAC2toFAC1				;				[BBFC]
	lda	ARGSGN			; get FAC2 sign (b7)

; save FAC1 sign and copy ABS(FAC2) to FAC1

CpFAC2toFAC12				;				[BBFE]
	sta	FACSGN			; save FAC1 sign (b7)
	ldx	#$05			; 5 bytes to copy
A_BC02					;				[BC02]
	lda	BITS,X			; get byte from FAC2,X
	sta	FacTempStor+9,X		; save byte at FAC1,X

	dex				; decrement count
	bne	A_BC02			; loop if not all done

	stx	FACOV			; clear FAC1 rounding byte
	rts


;******************************************************************************
;
; round and copy FAC1 to FAC2

CopyFAC1toFAC2				;				[BC0C]
	jsr	RoundFAC1		; round FAC1			[BC1B]

; copy FAC1 to FAC2

CpFAC1toFAC22				;				[BC0F]
	ldx	#$06			; 6 bytes to copy
A_BC11					;				[BC11]
	lda	FacTempStor+9,X		; get byte from FAC1,X
	sta	BITS,X			; save byte at FAC2,X
	dex				; decrement count
	bne	A_BC11			; loop if not all done

	stx	FACOV			; clear FAC1 rounding byte
A_BC1A					;				[BC1A]
	rts


;******************************************************************************
;
; round FAC1

RoundFAC1				;				[BC1B]
	lda	FACEXP			; get FAC1 exponent
	beq	A_BC1A			; exit if zero

	asl	FACOV			; shift FAC1 rounding byte
	bcc	A_BC1A			; exit if no overflow

; round FAC1 (no check)

RoundFAC12				;				[BC23]
	jsr	IncFAC1Mant		; increment FAC1 mantissa	[B96F]
	bne	A_BC1A			; branch if no overflow

	jmp	NormaliseFAC13		; nornalise FAC1 for C=1 and return
					;				[B938]

;******************************************************************************
;
; get FAC1 sign
; return A = $FF, Cb = 1/-ve A = $01, Cb = 0/+ve, A = $00, Cb = ?/0

GetFacSign				;				[BC2B]
	lda	FACEXP			; get FAC1 exponent
	beq	A_BC38			; exit if zero (allready correct
					; SGN(0)=0)

;******************************************************************************
;
; return A = $FF, Cb = 1/-ve A = $01, Cb = 0/+ve
; no = 0 check

A_BC2F					;				[BC2F]
	lda	FACSGN			; else get FAC1 sign (b7)


;******************************************************************************
;
; return A = $FF, Cb = 1/-ve A = $01, Cb = 0/+ve
; no = 0 check, sign in A

J_BC31					;				[BC31]
	rol				; move sign bit to carry
	lda	#$FF			; set byte for -ve result
	bcs	A_BC38			; return if sign was set (-ve)

	lda	#$01			; else set byte for +ve result
A_BC38					;				[BC38]
	rts


;******************************************************************************
;
; perform SGN()

bcSGN					;				[BC39]
	jsr	GetFacSign		; get FAC1 sign, return A = $FF -ve,
					; A = $01 +ve			[BC2B]

;******************************************************************************
;
; save A as integer byte

AtoInteger				;				[BC3C]
	sta	FacMantissa		; save FAC1 mantissa 1

	lda	#$00			; clear A
	sta	FacMantissa+1		; clear FAC1 mantissa 2

	ldx	#$88			; set exponent

; set exponent = X, clear FAC1 3 and 4 and normalise

J_BC44					;				[BC44]
	lda	FacMantissa		; get FAC1 mantissa 1
	eor	#$FF			; complement it
	rol				; sign bit into carry

; set exponent = X, clear mantissa 4 and 3 and normalise FAC1

SetExpontIsX				;				[BC49]
	lda	#$00			; clear A
	sta	FacMantissa+3		; clear FAC1 mantissa 4
	sta	FacMantissa+2		; clear FAC1 mantissa 3

; set exponent = X and normalise FAC1

J_BC4F					;				[BC4F]
	stx	FACEXP			; set FAC1 exponent
	sta	FACOV			; clear FAC1 rounding byte
	sta	FACSGN			; clear FAC1 sign (b7)

	jmp	AbsNormalFAC1		; do ABS and normalise FAC1	[B8D2]


;******************************************************************************
;
; perform ABS()

bcABS					;				[BC58]
	lsr	FACSGN			; clear FAC1 sign, put zero in b7
	rts


;******************************************************************************
;
; compare FAC1 with (AY)
; returns A=$00 if FAC1 = (AY)
; returns A=$01 if FAC1 > (AY)
; returns A=$FF if FAC1 < (AY)

CmpFAC1withAY				;				[BC5B]
	sta	INDEX+2			; save pointer LB
CmpFAC1withAY2				;				[BC5D]
	sty	INDEX+3			; save pointer HB

	ldy	#$00			; clear index
	lda	(INDEX+2),Y		; get exponent
	iny				; increment index
	tax				; copy (AY) exponent to X
	beq	GetFacSign		; branch if (AY) exponent=0 and get FAC1
					; sign A = $FF, Cb = 1/-ve, A = $01,
					; Cb = 0/+ve
	lda	(INDEX+2),Y		; get (AY) mantissa 1, with sign
	eor	FACSGN			; EOR FAC1 sign (b7)
	bmi	A_BC2F			; if signs <> do return A = $FF,
					; Cb = 1/-ve, A = $01, Cb = 0/+ve and
					; return
	cpx	FACEXP			; compare (AY) exponent with FAC1
					; exponent
	bne	A_BC92			; branch if different

	lda	(INDEX+2),Y		; get (AY) mantissa 1, with sign
	ora	#$80			; normalise top bit
	cmp	FacMantissa		; compare with FAC1 mantissa 1
	bne	A_BC92			; branch if different

	iny				; increment index
	lda	(INDEX+2),Y		; get mantissa 2
	cmp	FacMantissa+1		; compare with FAC1 mantissa 2
	bne	A_BC92			; branch if different

	iny				; increment index
	lda	(INDEX+2),Y		; get mantissa 3
	cmp	FacMantissa+2		; compare with FAC1 mantissa 3
	bne	A_BC92			; branch if different

	iny				; increment index
	lda	#$7F			; set for 1/2 value rounding byte
	cmp	FACOV			; compare with FAC1 rounding byte
					; (set carry)
	lda	(INDEX+2),Y		; get mantissa 4
	sbc	FacMantissa+3		; subtract FAC1 mantissa 4
	beq	A_BCBA			; exit if mantissa 4 equal

; gets here if number <> FAC1

A_BC92					;				[BC92]
	lda	FACSGN			; get FAC1 sign (b7)
	bcc	A_BC98			; branch if FAC1 > (AY)

	eor	#$FF			; else toggle FAC1 sign
A_BC98					;				[BC98]
	jmp	J_BC31			; return A = $FF, Cb = 1/-ve A = $01,
					; Cb = 0/+ve			[BC31]

;******************************************************************************
;
; convert FAC1 floating to fixed

FAC1Float2Fix				;				[BC9B]
	lda	FACEXP			; get FAC1 exponent
	beq	A_BCE9			; if zero go clear FAC1 and return

	sec				; set carry for subtract
	sbc	#$A0			; subtract maximum integer range
					; exponent
	bit	FACSGN			; test FAC1 sign (b7)
	bpl	A_BCAF			; branch if FAC1 +ve

; FAC1 was -ve
	tax				; copy subtracted exponent
	lda	#$FF			; overflow for -ve number
	sta	BITS			; set FAC1 overfLB

	jsr	TwoComplFAC1		; twos complement FAC1 mantissa	[B94D]
	txa				; restore subtracted exponent
A_BCAF					;				[BCAF]
	ldx	#$61			; set index to FAC1
	cmp	#$F9			; compare exponent result
	bpl	A_BCBB			; if < 8 shifts shift FAC1 A times right
					; and return
	jsr	shftFACxAright		; shift FAC1 A times right (> 8 shifts)
					;				[B999]
	sty	BITS			; clear FAC1 overfLB
A_BCBA					;				[BCBA]
	rts


;******************************************************************************
;
; shift FAC1 A times right

A_BCBB					;				[BCBB]
	tay				; copy shift count

	lda	FACSGN			; get FAC1 sign (b7)
	and	#$80			; mask sign bit only (x000 0000)
	lsr	FacMantissa		; shift FAC1 mantissa 1
	ora	FacMantissa		; OR sign in b7 FAC1 mantissa 1
	sta	FacMantissa		; save FAC1 mantissa 1

	jsr	shftFACxYright		; shift FAC1 Y times right	[B9B0]
	sty	BITS			; clear FAC1 overfLB

	rts


;******************************************************************************
;
; perform INT()

bcINT					;				[BCCC]
	lda	FACEXP			; get FAC1 exponent
	cmp	#$A0			; compare with max int
	bcs	A_BCF2			; exit if >= (allready int, too big for
					; fractional part!)
	jsr	FAC1Float2Fix		; convert FAC1 floating to fixed [BC9B]
	sty	FACOV			; save FAC1 rounding byte

	lda	FACSGN			; get FAC1 sign (b7)
	sty	FACSGN			; save FAC1 sign (b7)
	eor	#$80			; toggle FAC1 sign
	rol				; shift into carry

	lda	#$A0			; set new exponent
	sta	FACEXP			; save FAC1 exponent

	lda	FacMantissa+3		; get FAC1 mantissa 4
	sta	CHARAC			; save FAC1 mantissa 4 for power
					; function
	jmp	AbsNormalFAC1		; do ABS and normalise FAC1	[B8D2]


;******************************************************************************
;
; clear FAC1 and return

A_BCE9					;				[BCE9]
	sta	FacMantissa		; clear FAC1 mantissa 1
	sta	FacMantissa+1		; clear FAC1 mantissa 2
	sta	FacMantissa+2		; clear FAC1 mantissa 3
	sta	FacMantissa+3		; clear FAC1 mantissa 4

	tay				; clear Y
A_BCF2					;				[BCF2]
	rts


;******************************************************************************
;
; get FAC1 from string

String2FAC1				;				[BCF3]
	ldy	#$00			; clear Y
	ldx	#$0A			; set index
A_BCF7					;				[BCF7]
	sty	FacTempStor+6,X		; clear byte

	dex				; decrement index
	bpl	A_BCF7			; loop until numexp to negnum
					; (and FAC1 = $00)
	bcc	A_BD0D			; branch if first character is numeric

	cmp	#'-'			; else compare with "-"
	bne	A_BD06			; branch if not "-"

	stx	SGNFLG			; set flag for -ve n (negnum = $FF)
	beq	J_BD0A			; branch always

A_BD06					;				[BD06]
	cmp	#'+'			; else compare with "+"
	bne	A_BD0F			; branch if not "+"

J_BD0A					;				[BD0A]
	jsr	CHRGET			; increment and scan memory	[0073]
A_BD0D					;				[BD0D]
	bcc	A_BD6A			; branch if numeric character

A_BD0F					;				[BD0F]
	cmp	#'.'			; else compare with "."
	beq	A_BD41			; branch if "."

	cmp	#'e'			; else compare with "E"
	bne	A_BD47			; branch if not "E"

; was "E" so evaluate exponential part
	jsr	CHRGET			; increment and scan memory	[0073]
	bcc	A_BD33			; branch if numeric character

	cmp	#TK_MINUS		; else compare with token for -
	beq	A_BD2E			; branch if token for -

	cmp	#'-'			; else compare with "-"
	beq	A_BD2E			; branch if "-"

	cmp	#TK_PLUS		; else compare with token for +
	beq	J_BD30			; branch if token for +

	cmp	#'+'			; else compare with "+"
	beq	J_BD30			; branch if "+"

	bne	A_BD35			; branch always

A_BD2E					;				[BD2E]
	ror	FacTempStor+9		; set exponent -ve flag (C, which=1,
					; into b7)
J_BD30					;				[BD30]
	jsr	CHRGET			; increment and scan memory	[0073]
A_BD33					;				[BD33]
	bcc	A_BD91			; branch if numeric character

A_BD35					;				[BD35]
	bit	FacTempStor+9		; test exponent -ve flag
	bpl	A_BD47			; if +ve go evaluate exponent

; else do exponent = -exponent
	lda	#$00			; clear result
	sec				; set carry for subtract
	sbc	FacTempStor+7		; subtract exponent byte

	jmp	J_BD49			; go evaluate exponent		[BD49]

A_BD41					;				[BD41]
	ror	FacTempStor+8		; set decimal point flag
	bit	FacTempStor+8		; test decimal point flag
	bvc	J_BD0A			; branch if only one decimal point so
					; far
; evaluate exponent
A_BD47					;				[BD47]
	lda	FacTempStor+7		; get exponent count byte
J_BD49					;				[BD49]
	sec				; set carry for subtract
	sbc	FacTempStor+6		; subtract numerator exponent
	sta	FacTempStor+7		; save exponent count byte
	beq	A_BD62			; branch if no adjustment

	bpl	A_BD5B			; else if +ve go do FAC1*10^expcnt

; else go do FAC1/10^(0-expcnt)
A_BD52					;				[BD52]
	jsr	FAC1div10		; divide FAC1 by 10		[BAFE]

	inc	FacTempStor+7		; increment exponent count byte
	bne	A_BD52			; loop until all done

	beq	A_BD62			; branch always


A_BD5B					;				[BD5B]
	jsr	Fac1x10			; multiply FAC1 by 10		[BAE2]

	dec	FacTempStor+7		; decrement exponent count byte
	bne	A_BD5B			; loop until all done

A_BD62					;				[BD62]
	lda	SGNFLG			; get -ve flag
	bmi	A_BD67			; if -ve do - FAC1 and return

	rts


;******************************************************************************
;
; do - FAC1 and return

A_BD67					;				[BD67]
	jmp	bcGREATER		; do - FAC1			[BFB4]

; do unsigned FAC1*10+number

A_BD6A					;				[BD6A]
	pha				; save character

	bit	FacTempStor+8		; test decimal point flag
	bpl	A_BD71			; skip exponent increment if not set

	inc	FacTempStor+6		; else increment number exponent
A_BD71					;				[BD71]
	jsr	Fac1x10			; multiply FAC1 by 10		[BAE2]

	pla				; restore character
	sec				; set carry for subtract
	sbc	#'0'			; convert to binary
	jsr	EvalNewDigit		; evaluate new ASCII digit	[BD7E]

	jmp	J_BD0A			; go do next character		[BD0A]

; evaluate new ASCII digit
; multiply FAC1 by 10 then (ABS) add in new digit

EvalNewDigit				;				[BD7E]
	pha				; save digit

	jsr	CopyFAC1toFAC2		; round and copy FAC1 to FAC2	[BC0C]

	pla				; restore digit
	jsr	AtoInteger		; save A as integer byte	[BC3C]

	lda	ARGSGN			; get FAC2 sign (b7)
	eor	FACSGN			; toggle with FAC1 sign (b7)
	sta	ARISGN			; save sign compare (FAC1 EOR FAC2)

	ldx	FACEXP			; get FAC1 exponent
	jmp	bcPLUS			; add FAC2 to FAC1 and return	[B86A]

; evaluate next character of exponential part of number

A_BD91					;				[BD91]
	lda	FacTempStor+7		; get exponent count byte
	cmp	#$0A			; compare with 10 decimal
	bcc	A_BDA0			; branch if less

	lda	#$64			; make all -ve exponents = -100 decimal
					; (causes underflow)
	bit	FacTempStor+9		; test exponent -ve flag
	bmi	A_BDAE			; branch if -ve

	jmp	OverflowError		; else do overflow error then warm start
					;				[B97E]
A_BDA0					;				[BDA0]
	asl				; *2
	asl				; *4
	clc				; clear carry for add
	adc	FacTempStor+7		; *5
	asl				; *10
	clc				; clear carry for add
	ldy	#$00			; set index
	adc	(TXTPTR),Y		; add character (will be $30 too much!)
	sec				; set carry for subtract
	sbc	#'0'			; convert character to binary
A_BDAE					;				[BDAE]
	sta	FacTempStor+7		; save exponent count byte

	jmp	J_BD30			; go get next character		[BD30]


;******************************************************************************
;
; limits for scientific mode

C99999999				;				[BDB3]
.byte	$9B,$3E,$BC,$1F,$FD		; 99999999.90625, maximum value with at
					; least one decimal
C999999999				;				[BDB8]
.byte	$9E,$6E,$6B,$27,$FD		; 999999999.25, maximum value before
					; scientific notation
C1000000000				;				[BDBD]
.byte	$9E,$6E,$6B,$28,$00		; 1000000000


;******************************************************************************
;
; do " IN " line number message

Print_IN				;				[BDC2]
	lda	#<TxtIn			; set " IN " pointer LB
	ldy	#>TxtIn			; set " IN " pointer HB
	jsr	OutputString0		; print null terminated string	[BDDA]

	lda	CURLIN+1		; get the current line number HB
	ldx	CURLIN			; get the current line number LB


;******************************************************************************
;
; print XA as unsigned integer

PrintXAasInt				;				[BDCD]
	sta	FacMantissa		; save HB as FAC1 mantissa1
	stx	FacMantissa+1		; save LB as FAC1 mantissa2
S_BDD1
	ldx	#$90			; set exponent to 16d bits
	sec				; set integer is +ve flag
	jsr	SetExpontIsX		; set exponent = X, clear mantissa 4
					; and 3 and normalise FAC1	[BC49]
	jsr	FAC12String		; convert FAC1 to string	[BDDF]
OutputString0				;				[BDDA]
	jmp	OutputString		; print null terminated string	[AB1E]


;******************************************************************************
;
; convert FAC1 to ASCII string result in (AY)

FAC1toASCII				;				[BDDD]
	ldy	#$01			; set index = 1
FAC12String				;				[BDDF]
	lda	#' '			; character = " " (assume +ve)
	bit	FACSGN			; test FAC1 sign (b7)
	bpl	A_BDE7			; branch if +ve

	lda	#'-'			; else character = "-"
A_BDE7					;				[BDE7]
	sta	StrConvAddr,Y		; save leading character (" " or "-")
	sta	FACSGN			; save FAC1 sign (b7)
	sty	FBUFPT			; save index

	iny				; increment index

	lda	#'0'			; set character = "0"

	ldx	FACEXP			; get FAC1 exponent
	bne	A_BDF8			; branch if FAC1<>0

; exponent was $00 so FAC1 is 0
	jmp	J_BF04			; save last character, [EOT] and exit
					;				[BF04]

; FAC1 is some non zero value
A_BDF8					;				[BDF8]
	lda	#$00			; clear (number exponent count)
	cpx	#$80			; compare FAC1 exponent with $80
					; (<1.00000)
	beq	A_BE00			; branch if 0.5 <= FAC1 < 1.0

	bcs	A_BE09			; branch if FAC1=>1

A_BE00					;				[BE00]
	lda	#<C1000000000		; set 1000000000 pointer LB
	ldy	#>C1000000000		; set 1000000000 pointer HB
	jsr	FAC1xAY			; do convert AY, FCA1*(AY)	[BA28]

	lda	#$F7			; set number exponent count
A_BE09					;				[BE09]
	sta	FacTempStor+6		; save number exponent count
A_BE0B					;				[BE0B]
	lda	#<C999999999		; set 999999999.25 pointer LB (max
					; before sci note)
	ldy	#>C999999999		; set 999999999.25 pointer HB
	jsr	CmpFAC1withAY		; compare FAC1 with (AY)	[BC5B]
	beq	A_BE32			; exit if FAC1 = (AY)

	bpl	A_BE28			; go do /10 if FAC1 > (AY)

; FAC1 < (AY)
A_BE16					;				[BE16]
	lda	#<C99999999		; set 99999999.90625 pointer LB
	ldy	#>C99999999		; set 99999999.90625 pointer HB
	jsr	CmpFAC1withAY		; compare FAC1 with (AY)	[BC5B]
	beq	A_BE21			; branch if FAC1 = (AY) (allow decimal
					; places)
	bpl	A_BE2F			; branch if FAC1 > (AY) (no decimal
					; places)
; FAC1 <= (AY)
A_BE21					;				[BE21]
	jsr	Fac1x10			; multiply FAC1 by 10		[BAE2]

	dec	FacTempStor+6		; decrement number exponent count
	bne	A_BE16			; go test again, branch always

A_BE28					;				[BE28]
	jsr	FAC1div10		; divide FAC1 by 10		[BAFE]

	inc	FacTempStor+6		; increment number exponent count
	bne	A_BE0B			; go test again, branch always

; now we have just the digits to do

A_BE2F					;				[BE2F]
	jsr	FAC1plus05		; add 0.5 to FAC1 (round FAC1)	[B849]
A_BE32					;				[BE32]
	jsr	FAC1Float2Fix		; convert FAC1 floating to fixed [BC9B]

	ldx	#$01			; set default digits before dp = 1

	lda	FacTempStor+6		; get number exponent count
	clc				; clear carry for add
	adc	#$0A			; up to 9 digits before point
	bmi	A_BE47			; if -ve then 1 digit before dp

	cmp	#$0B			; A>=$0B if n>=1E9
	bcs	A_BE48			; branch if >= $0B

; carry is clear
	adc	#$FF			; take 1 from digit count
	tax				; copy to X

	lda	#$02			;.set exponent adjust
A_BE47					;				[BE47]
	sec				; set carry for subtract
A_BE48					;				[BE48]
	sbc	#$02			; -2
	sta	FacTempStor+7		;.save exponent adjust
	stx	FacTempStor+6		; save digits before dp count

	txa				; copy to A
	beq	A_BE53			; branch if no digits before dp

	bpl	A_BE66			; branch if digits before dp

A_BE53					;				[BE53]
	ldy	FBUFPT			; get output string index
	lda	#'.'			; character "."
	iny				; increment index
	sta	StrConvAddr,Y		; save to output string

	txa				;.
	beq	A_BE64			;.

	lda	#'0'			; character "0"
	iny				; increment index
	sta	StrConvAddr,Y		; save to output string
A_BE64					;				[BE64]
	sty	FBUFPT			; save output string index
A_BE66					;				[BE66]
	ldy	#$00			; clear index (point to 100,000)
JiffyCnt2Str				;				[BE68]
	ldx	#$80			;.
A_BE6A					;				[BE6A]
	lda	FacMantissa+3		; get FAC1 mantissa 4
	clc				; clear carry for add
	adc	D_BF16+3,Y		; add byte 4, least significant
	sta	FacMantissa+3		; save FAC1 mantissa4

	lda	FacMantissa+2		; get FAC1 mantissa 3
	adc	D_BF16+2,Y		; add byte 3
	sta	FacMantissa+2		; save FAC1 mantissa3

	lda	FacMantissa+1		; get FAC1 mantissa 2
	adc	D_BF16+1,Y		; add byte 2
	sta	FacMantissa+1		; save FAC1 mantissa2

	lda	FacMantissa		; get FAC1 mantissa 1
	adc	D_BF16+0,Y		; add byte 1, most significant
	sta	FacMantissa		; save FAC1 mantissa1

	inx				; increment the digit, set the sign on
					; the test sense bit
	bcs	A_BE8E			; if the carry is set go test if the
					; result was positive
; else the result needs to be negative
	bpl	A_BE6A			; not -ve so try again

	bmi	A_BE90			; else done so return the digit
A_BE8E					;				[BE8E]
	bmi	A_BE6A			; not +ve so try again

; else done so return the digit

A_BE90					;				[BE90]
	txa				; copy the digit
	bcc	A_BE97			; if Cb=0 just use it

	eor	#$FF			; else make the 2's complement ..
	adc	#$0A			; .. and subtract it from 10
A_BE97					;				[BE97]
	adc	#'0'-1			; add "0"-1 to result

	iny				; increment ..
	iny				; .. index to..
	iny				; .. next less ..
	iny				; .. power of ten
	sty	VARPNT			; save current variable pointer LB

	ldy	FBUFPT			; get output string index
	iny				; increment output string index

	tax				; copy character to X

	and	#$7F			; mask out top bit
	sta	StrConvAddr,Y		; save to output string

	dec	FacTempStor+6		; decrement # of characters before dp
	bne	A_BEB2			; branch if still characters to do

; else output the point
	lda	#'.'			; character "."
	iny				; increment output string index
	sta	STACK-1,Y		; save to output string
A_BEB2					;				[BEB2]
	sty	FBUFPT			; save output string index

	ldy	VARPNT			; get current variable pointer LB

	txa				; get character back
	eor	#$FF			; toggle the test sense bit
	and	#$80			; clear the digit
	tax				; copy it to the new digit

	cpy	#D_BF3A-D_BF16		; compare the table index with the max
					; for decimal numbers
	beq	A_BEC4			; if at the max exit the digit loop

	cpy	#D_BF52-D_BF16		; compare the table index with the max
					; for time
	bne	A_BE6A			; loop if not at the max

; now remove trailing zeroes

A_BEC4					;				[BEC4]
	ldy	FBUFPT			; restore the output string index
A_BEC6					;				[BEC6]
	lda	STACK-1,Y		; get character from output string
	dey				; decrement output string index
	cmp	#'0'			; compare with "0"
	beq	A_BEC6			; loop until non "0" character found

	cmp	#'.'			; compare with "."
	beq	A_BED3			; branch if was dp

; restore last character
	iny				; increment output string index
A_BED3					;				[BED3]
	lda	#'+'			; character "+"

	ldx	FacTempStor+7		; get exponent count
	beq	A_BF07			; if zero go set null terminator and
					; exit
; exponent isn't zero so write exponent
	bpl	A_BEE3			; branch if exponent count +ve

	lda	#$00			; clear A
	sec				; set carry for subtract
	sbc	FacTempStor+7		; subtract exponent count adjust
					; (convert -ve to +ve)
	tax				; copy exponent count to X

	lda	#'-'			; character "-"
A_BEE3					;				[BEE3]
	sta	STACK+1,Y		; save to output string

	lda	#'e'			; character "E"
	sta	STACK,Y			; save exponent sign to output string

	txa				; get exponent count back

	ldx	#'0'-1			; one less than "0" character
	sec				; set carry for subtract
A_BEEF					;				[BEEF]
	inx				; increment 10's character

	sbc	#$0A			;.subtract 10 from exponent count
	bcs	A_BEEF			; loop while still >= 0

	adc	#':'			; add character ":" ($30+$0A, result is
					; 10 less that value)
	sta	STACK+3,Y		; save to output string

	txa				; copy 10's character
	sta	STACK+2,Y		; save to output string

	lda	#$00			; set null terminator
	sta	STACK+4,Y		; save to output string
	beq	A_BF0C			; go set string pointer (AY) and exit,
					; branch always
; save last character, [EOT] and exit

J_BF04					;				[BF04]
	sta	STACK-1,Y		; save last character to output string

; set null terminator and exit
A_BF07					;				[BF07]
	lda	#$00			; set null terminator
	sta	STACK,Y			; save after last character

; set string pointer (AY) and exit
A_BF0C					;				[BF0C]
	lda	#<STACK			; set result string pointer LB
	ldy	#>STACK			; set result string pointer HB
	rts


;******************************************************************************
;
; constants

L_BF11					;				[BF11]
.byte	$80,$00				; 0.5, first two bytes
L_BF13					;				[BF13]
.byte	$00,$00,$00			; null return for undefined variables

D_BF16					;				[BF16]
.byte	$FA,$0A,$1F,$00			; -100000000
.byte	$00,$98,$96,$80			;  +10000000
.byte	$FF,$F0,$BD,$C0			;   -1000000
.byte	$00,$01,$86,$A0			;    +100000
.byte	$FF,$FF,$D8,$F0			;     -10000
.byte	$00,$00,$03,$E8			;      +1000
.byte	$FF,$FF,$FF,$9C			;	-100
.byte	$00,$00,$00,$0A			;	 +10
.byte	$FF,$FF,$FF,$FF			;	  -1

; jiffy counts

D_BF3A					;				[BF3A]
.byte	$FF,$DF,$0A,$80			; -2160000	10s hours
.byte	$00,$03,$4B,$C0			;  +216000	    hours
.byte	$FF,$FF,$73,$60			;   -36000	10s mins
.byte	$00,$00,$0E,$10			;    +3600	    mins
.byte	$FF,$FF,$FD,$A8			;     -600	10s secs
.byte	$00,$00,$00,$3C			;      +60	    secs
D_BF52					;				[BF52]


;******************************************************************************
;
; not referenced

.byte	$EC				; checksum byte


;******************************************************************************
;
; spare bytes, not referenced

.byte	$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
.byte	$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA


;******************************************************************************
;
; perform SQR()

bcSQR					;				[BF71]
	jsr	CopyFAC1toFAC2		; round and copy FAC1 to FAC2	[BC0C]

	lda	#<L_BF11		; set 0.5 pointer low address
	ldy	#>L_BF11		; set 0.5 pointer high address
	jsr	UnpackAY2FAC1		; unpack memory (AY) into FAC1	[BBA2]


;******************************************************************************
;
; perform power function

bcPOWER					;				[BF7B]
	beq	bcEXP			; perform EXP()

	lda	ARGEXP			; get FAC2 exponent
	bne	A_BF84			; branch if FAC2<>0

	jmp	ClrFAC1Exp		; clear FAC1 exponent and sign and
					; return			[B8F9]
A_BF84					;				[BF84]
	ldx	#<GarbagePtr		; set destination pointer LB
	ldy	#>GarbagePtr		; set destination pointer HB
	jsr	PackFAC1intoXY		; pack FAC1 into (XY)		[BBD4]

	lda	ARGSGN			; get FAC2 sign (b7)
	bpl	A_BF9E			; branch if FAC2>0

; else FAC2 is -ve and can only be raised to an integer power which gives an
; x + j0 result
	jsr	bcINT			; perform INT()			[BCCC]

	lda	#<GarbagePtr		; set source pointer LB
	ldy	#>GarbagePtr		; set source pointer HB
	jsr	CmpFAC1withAY		; compare FAC1 with (AY)	[BC5B]
	bne	A_BF9E			; branch if FAC1 <> (AY) to allow
					; Function Call error this will leave
					; FAC1 -ve and cause a Function Call
					; error when LOG() is called
	tya				; clear sign b7
	ldy	CHARAC			; get FAC1 mantissa 4 from INT()
					; function as sign in Y for possible
					; later negation, b0 only needed
A_BF9E					;				[BF9E]
	jsr	CpFAC2toFAC12		; save FAC1 sign and copy ABS(FAC2) to
					; FAC1				[BBFE]
	tya				; copy sign back ..
	pha				; .. and save it

	jsr	bcLOG			; perform LOG()			[B9EA]

	lda	#<GarbagePtr		; set pointer LB
	ldy	#>GarbagePtr		; set pointer HB
	jsr	FAC1xAY			; do convert AY, FCA1*(AY)	[BA28]

	jsr	bcEXP			; perform EXP()			[BFED]

	pla				; pull sign from stack
	lsr				; b0 is to be tested
	bcc	A_BFBE			; if no bit then exit

; do - FAC1

bcGREATER				;				[BFB4]
	lda	FACEXP			; get FAC1 exponent
	beq	A_BFBE			; exit if FAC1_e = $00

	lda	FACSGN			; get FAC1 sign (b7)
	eor	#$FF			; complement it
	sta	FACSGN			; save FAC1 sign (b7)
A_BFBE					;				[BFBE]
	rts


;******************************************************************************
;
; exp(n) constant and series

ConstantEXP				;				[BFBF]
.byte	$81,$38,$AA,$3B,$29		; 1.443

TblEXPseries				;				[BFC4]
.byte	$07				; series count
.byte	$71,$34,$58,$3E,$56		; 2.14987637E-5
.byte	$74,$16,$7E,$B3,$1B		; 1.43523140E-4
.byte	$77,$2F,$EE,$E3,$85		; 1.34226348E-3
.byte	$7A,$1D,$84,$1C,$2A		; 9.61401701E-3
.byte	$7C,$63,$59,$58,$0A		; 5.55051269E-2
.byte	$7E,$75,$FD,$E7,$C6		; 2.40226385E-1
.byte	$80,$31,$72,$18,$10		; 6.93147186E-1
.byte	$81,$00,$00,$00,$00		; 1.00000000


;******************************************************************************
;
; perform EXP()

bcEXP					;				[BFED]
	lda	#<ConstantEXP		; set 1.443 pointer LB
	ldy	#>ConstantEXP		; set 1.443 pointer HB
	jsr	FAC1xAY			; do convert AY, FCA1*(AY)	[BA28]

	lda	FACOV			; get FAC1 rounding byte
	adc	#$50			; +$50/$100
	bcc	A_BFFD			; skip rounding if no carry

	jsr	RoundFAC12		; round FAC1 (no check)		[BC23]
A_BFFD					;				[BFFD]
	jmp	bcEXP2			; continue EXP()		[E000]


;******************************************************************************
;
; start of the kernal ROM

*= $E000

; EXP() continued

bcEXP2					;				[E000]
	sta	Jump0054+2		; save FAC2 rounding byte

	jsr	CpFAC1toFAC22		; copy FAC1 to FAC2		[BC0F]

	lda	FACEXP			; get FAC1 exponent
	cmp	#$88			; less than EXP limit?
	bcc	A_E00E			; yes, ->
A_E00B					;				[E00B]
	jsr	HndlOvUnFlErr		; handle overflow and underflow	[BAD4]
A_E00E					;				[E00E]
	jsr	bcINT			; perform INT()			[BCCC]
	lda	CHARAC			; get mantissa 4 from INT()
	clc				; clear carry for add
	adc	#$81			; normalise +1, result $00?
	beq	A_E00B			; yes, -> go handle it

	sec				; set carry for subtract
	sbc	#$01			; exponent now correct
	pha				; save FAC2 exponent
					; swap FAC1 and FAC2
	ldx	#$05			; 4 bytes to do
A_E01E					;				[E01E]
	lda	ARGEXP,X		; get FAC2,X
	ldy	FACEXP,X		; get FAC1,X
	sta	FACEXP,X		; save FAC1,X
	sty	ARGEXP,X		; save FAC2,X
	dex				; decrement count/index
	bpl	A_E01E			; loop if not all done

	lda	Jump0054+2		; get FAC2 rounding byte
	sta	FACOV			; save as FAC1 rounding byte

	jsr	bcMINUS			; perform subtraction, FAC2 from FAC1
					;				[B853]
	jsr	bcGREATER		; do - FAC1			[BFB4]

	lda	#<TblEXPseries		; set counter pointer LB
	ldy	#>TblEXPseries		; set counter pointer HB
	jsr	CalcPolynome		; go do series evaluation	[E059]

	lda	#$00			; clear A
	sta	ARISGN			; clear sign compare (FAC1 EOR FAC2)

	pla				;.get saved FAC2 exponent
	jsr	TestAdjFACs2		; test and adjust accumulators	[BAB9]

	rts


;******************************************************************************
;
; ^2 then series evaluation

Power2					;				[E043]
	sta	FBUFPT			; save count pointer LB
	sty	FBUFPT+1		; save count pointer HB

	jsr	FAC1toTemp		; pack FAC1 into FacTempStor	[BBCA]

	lda	#<FacTempStor		; set pointer LB (Y already $00)
	jsr	FAC1xAY			; do convert AY, FCA1*(AY)	[BA28]

	jsr	CalcPolynome2		; go do series evaluation	[E05D]

	lda	#<FacTempStor		; pointer to original # LB
	ldy	#>FacTempStor		; pointer to original # HB
	jmp	FAC1xAY			; do convert AY, FCA1*(AY)	[BA28]


;******************************************************************************
;
; do series evaluation

CalcPolynome				;				[E059]
	sta	FBUFPT			; save count pointer LB
	sty	FBUFPT+1		; save count pointer HB

; do series evaluation

CalcPolynome2				;				[E05D]
	jsr	FAC1toTemp5		; pack FAC1 into FacTempStor+5	[BBC7]

	lda	(FBUFPT),Y		; get constants count
	sta	SGNFLG			; save constants count

	ldy	FBUFPT			; get count pointer LB
	iny				; increment it (now constants pointer)
	tya				; copy it, result = 0?
	bne	A_E06C			; no, -> skip next INC

	inc	FBUFPT+1		; else increment HB
A_E06C					;				[E06C]
	sta	FBUFPT			; save LB

	ldy	FBUFPT+1		; get HB
A_E070					;				[E070]
	jsr	FAC1xAY			; do convert AY, FCA1*(AY)	[BA28]

	lda	FBUFPT			; get constants pointer LB
	ldy	FBUFPT+1		; get constants pointer HB
	clc				; clear carry for add
	adc	#$05			; add 5 to low pointer (5 bytes per
					; constant)
	bcc	A_E07D			; skip next if no overflow

	iny				; increment HB
A_E07D					;				[E07D]
	sta	FBUFPT			; save pointer LB
	sty	FBUFPT+1		; save pointer HB

	jsr	AddFORvar2FAC1		; add (AY) to FAC1		[B867]

	lda	#<(FacTempStor+5)	; set pointer LB to partial
	ldy	#>(FacTempStor+5)	; set pointer HB to partial

	dec	SGNFLG			; decrement constants count, done all?
	bne	A_E070			; no, -> more...

	rts


;******************************************************************************
;
; RND values

ConstRNDmult				;				[E08D]
.byte	$98,$35,$44,$7A,$00		; 11879546		multiplier

ConstRNDoffs				;				[E092]
.byte	$68,$28,$B1,$46,$00		; 3.927677739E-8	offset


;******************************************************************************
;
; perform RND()

bcRND					;				[E097]
	jsr	GetFacSign		; get FAC1 sign			[BC2B]
					; return A = $FF -ve, A = $01 +ve
	bmi	A_E0D3			; if (n < 0) copy byte swapped FAC1 into
					; RND() seed
	bne	A_E0BE			; if (n > 0) get next number in RND()
					; sequence
; else n=0 so get the RND() number from CIA 1 timers
	jsr	GetAddrIoDevs		; return base address of I/O devices
					;				[FFF3]
	stx	INDEX			; save pointer LB
	sty	INDEX+1			; save pointer HB

	ldy	#$04			; set index to T1 LB
	lda	(INDEX),Y		; get T1 LB
	sta	FacMantissa		; save FAC1 mantissa 1

	iny				; increment index
	lda	(INDEX),Y		; get T1 HB
	sta	FacMantissa+2		; save FAC1 mantissa 3

	ldy	#$08			; set index to T2 LB
	lda	(INDEX),Y		; get T2 LB
	sta	FacMantissa+1		; save FAC1 mantissa 2

	iny				; increment index
	lda	(INDEX),Y		; get T2 HB
	sta	FacMantissa+3		; save FAC1 mantissa 4

	jmp	J_E0E3			; set exponent and exit		[E0E3]


A_E0BE					;				[E0BE]
	lda	#<RND_seed		; set seed pointer low address
	ldy	#>RND_seed		; set seed pointer high address
	jsr	UnpackAY2FAC1		; unpack memory (AY) into FAC1	[BBA2]

	lda	#<ConstRNDmult		; set 11879546 pointer LB
	ldy	#>ConstRNDmult		; set 11879546 pointer HB
	jsr	FAC1xAY			; do convert AY, FCA1*(AY)	[BA28]

	lda	#<ConstRNDoffs		; set 3.927677739E-8 pointer LB
	ldy	#>ConstRNDoffs		; set 3.927677739E-8 pointer HB
	jsr	AddFORvar2FAC1		; add (AY) to FAC1		[B867]
A_E0D3					;				[E0D3]
	ldx	FacMantissa+3		; get FAC1 mantissa 4
	lda	FacMantissa		; get FAC1 mantissa 1
	sta	FacMantissa+3		; save FAC1 mantissa 4
	stx	FacMantissa		; save FAC1 mantissa 1

	ldx	FacMantissa+1		; get FAC1 mantissa 2
	lda	FacMantissa+2		; get FAC1 mantissa 3
	sta	FacMantissa+1		; save FAC1 mantissa 2
	stx	FacMantissa+2		; save FAC1 mantissa 3
J_E0E3					;				[E0E3]
	lda	#$00			; clear byte
	sta	FACSGN			; clear FAC1 sign (always +ve)

	lda	FACEXP			; get FAC1 exponent
	sta	FACOV			; save FAC1 rounding byte

	lda	#$80			; set exponent = $80
	sta	FACEXP			; save FAC1 exponent

	jsr	NormaliseFAC1		; normalise FAC1		[B8D7]

	ldx	#<RND_seed		; set seed pointer low address
	ldy	#>RND_seed		; set seed pointer high address


;******************************************************************************
;
; pack FAC1 into (XY)

PackFAC1intoXY0				;				[E0F6]
	jmp	PackFAC1intoXY		; pack FAC1 into (XY)		[BBD4]


;******************************************************************************
;
; handle BASIC I/O error

HndlBasIoErr				;				[E0F9]
	cmp	#$F0			; error = $F0?
	bne	A_E104			; no, ->

	sty	MEMSIZ+1		; set end of memory HB
	stx	MEMSIZ			; set end of memory LB

	jmp	bcCLR3			; clear from start to end and return
					;				[A663]
; error was not $F0
A_E104					;				[E104]
	tax				; copy error #, zero?
	bne	A_E109			; no, ->

	ldx	#$1E			; else error $1E, break error
A_E109					;				[E109]
	jmp	OutputErrMsg		; do error #X then warm start	[A437]


;******************************************************************************
;
; output character to channel with error check

OutCharErrChan				;				[E10C]
	jsr	OutByteChan		; output character to channel	[FFD2]
	bcs	HndlBasIoErr		; if error go handle BASIC I/O error

	rts


;******************************************************************************
;
; input character from channel with error check

InpCharErrChan				;				[E112]
	jsr	ByteFromChan		; input character from channel	[FFCF]
	bcs	HndlBasIoErr		; if error go handle BASIC I/O error

	rts


;******************************************************************************
;
; open channel for output with error check

OpenChan4OutpA				;				[E118]
	jsr	OpenChan4OutpB		; open channel for output	[E4AD]
	bcs	HndlBasIoErr		; if error go handle BASIC I/O error

	rts


;******************************************************************************
;
; open channel for input with error check

OpenChan4Inp0				;				[E11E]
	jsr	OpenChan4Inp		; open channel for input	[FFC6]
	bcs	HndlBasIoErr		; if error go handle BASIC I/O error

	rts


;******************************************************************************
;
; get character from input device with error check

GetCharFromIO				;				[E124]
	jsr	GetCharInpDev		; get character from input device [FFE4]
	bcs	HndlBasIoErr		; if error go handle BASIC I/O error

	rts


;******************************************************************************
;
; perform SYS

bcSYS					;				[E12A]
	jsr	EvalExpression		; evaluate expression and check is
					; numeric, else do type mismatch [AD8A]
	jsr	FAC1toTmpInt		; convert FAC_1 to integer in temporary
					; integer			[B7F7]
	lda	#>(bcSYS2-1)		; get return address HB
	pha				; push as return address

	lda	#<(bcSYS2-1)		; get return address LB
	pha				; push as return address

	lda	SPREG			; get saved status register
	pha				; put on stack

	lda	SAREG			; get saved A
	ldx	SXREG			; get saved X
	ldy	SYREG			; get saved Y

	plp				; pull processor status

	jmp	(LINNUM)		; call SYS address

; tail end of SYS code
bcSYS2					;				[E147]
	php				; save status

	sta	SAREG			; save returned A
	stx	SXREG			; save returned X
	sty	SYREG			; save returned Y

	pla				; restore saved status
	sta	SPREG			; save status

	rts


;******************************************************************************
;
; perform SAVE

bcSAVE					;				[E156]
	jsr	GetParmLoadSav		; get parameters for LOAD/SAVE	[E1D4]
S_E159
	ldx	VARTAB			; get start of variables LB
	ldy	VARTAB+1		; get start of variables HB
	lda	#TXTTAB			; index to start of program memory
	jsr	SaveRamToDev		; save RAM to device, A = index to start
					; address low/high address, XY = end
					;				[FFD8]
	bcs	HndlBasIoErr		; if error go handle BASIC I/O error

	rts


;******************************************************************************
;
; perform VERIFY

bcVERIFY				;				[E165]
	lda	#$01			; flag verify
.byte	$2C				; makes next line BIT $00A9


;******************************************************************************
;
; perform LOAD

bcLOAD					;				[E168]
	lda	#$00			; flag load
	sta	LoadVerify		; set load/verify flag

	jsr	GetParmLoadSav		; get parameters for LOAD/SAVE	[E1D4]
S_E16F
	lda	LoadVerify		; get load/verify flag
	ldx	TXTTAB			; get start of memory LB
	ldy	TXTTAB+1		; get start of memory HB
	jsr	LoadRamFrmDev		; load RAM from a device	[FFD5]
	bcs	A_E1D1			; if error go handle BASIC I/O error

	lda	LoadVerify		; get load/verify flag
	beq	A_E195			; branch if load

	ldx	#$1C			; error $1C, verify error
	jsr	ReadIoStatus		; read I/O status word		[FFB7]
	and	#$10			; mask for tape read error
	bne	A_E19E			; branch if read error

	lda	TXTPTR			; get the BASIC execute pointer LB
	cmp	#$02			; ??? how is TXTPTR used here?
	beq	A_E194			; if ??, -> skip "OK" prompt

	lda	#<TxtOK			; set "OK" pointer LB
	ldy	#>TxtOK			; set "OK" pointer HB
	jmp	OutputString		; print null terminated string	[AB1E]

A_E194					;				[E194]
	rts


;******************************************************************************
;
; do READY return to BASIC

A_E195					;				[E195]
	jsr	ReadIoStatus		; read I/O status word		[FFB7]
	and	#$BF			; clear read error, error found?
	beq	A_E1A1			; no, ->
S_E19C
	ldx	#$1D			; error $1D, load error
A_E19E					;				[E19E]
	jmp	OutputErrMsg		; do error #X then warm start	[A437]

A_E1A1					;				[E1A1]
	lda	TXTPTR+1		; get BASIC execute pointer HB
	cmp	#$02			; immediate mode?
	bne	A_E1B5			; no, ->

	stx	VARTAB			; set start of variables LB
	sty	VARTAB+1		; set start of variables HB

	lda	#<TxtReady		; set "READY." pointer LB
	ldy	#>TxtReady		; set "READY." pointer HB
	jsr	OutputString		; print null terminated string	[AB1E]

	jmp	J_A52A			; reset execution, clear variables,
					; flush stack, rebuild BASIC chain and
					; do warm start			[A52A]
A_E1B5					;				[E1B5]
	jsr	SetBasExecPtr		; set BASIC execute pointer to start of
					; memory-1			[A68E]
	jsr	BindLine		; rebuild BASIC line chaining	[A533]
	jmp	bcCLR4			; rebuild BASIC line chaining, do
					; RESTORE and return		[A677]


;******************************************************************************
;
; perform OPEN

bcOPEN					;				[E1BE]
	jsr	GetParmOpenClo		; get parameters for OPEN/CLOSE	[E219]

	jsr	OpenLogFile		; open a logical file		[FFC0]
	bcs	A_E1D1			; branch if error

	rts


;******************************************************************************
;
; perform CLOSE

bcCLOSE					;				[E1C7]
	jsr	GetParmOpenClo		; get parameters for OPEN/CLOSE	[E219]

	lda	FORPNT			; get logical file number
	jsr	CloseLogFile		; close a specified logical file [FFC3]
	bcc	A_E194			; exit if no error

A_E1D1					;				[E1D1]
	jmp	HndlBasIoErr		; go handle BASIC I/O error	[E0F9]


;******************************************************************************
;
; get parameters for LOAD/SAVE

GetParmLoadSav				;				[E1D4]
	lda	#$00			; clear filename length
	jsr	SetFileName		; clear the filename		[FFBD]

	ldx	#$01			; set default device number, cassette
	ldy	#$00			; set default command
	jsr	SetAddresses		; set logical, first and second
					; addresses			[FFBA]
	jsr	ExitIfEotColl		; exit function if [EOT] or ":"	[E206]
	jsr	GetFileName		; get filename			[E257]
	jsr	ExitIfEotColl		; exit function if [EOT] or ":"	[E206]
	jsr	GetByte			; scan and get byte, else do syntax
					; error then warm start		[E200]
	ldy	#$00			; clear command

	stx	FORPNT			; save device number

	jsr	SetAddresses		; set logical, first and second
					; addresses			[FFBA]
	jsr	ExitIfEotColl		; exit function if [EOT] or ":"	[E206]

	jsr	GetByte			; scan and get byte, else do syntax
					; error then warm start		[E200]
	txa				; copy command to A
	tay				; copy command to Y

	ldx	FORPNT			; get device number back
	jmp	SetAddresses		; set logical, first and second
					; addresses and return		[FFBA]


;******************************************************************************
;
; scan and get byte, else do syntax error then warm start

GetByte					;				[E200]
	jsr	Chk4ValidByte		; scan for ",byte", else do syntax error
					; then warm start		[E20E]
	jmp	GetByteParm2		; get byte parameter and return	[B79E]


;******************************************************************************
;
; exit function if [EOT] or ":"

ExitIfEotColl				;				[E206]
	jsr	CHRGOT			; scan memory, [EOL] or ":"?	[0079]
	bne	A_E20D			; no, ->

	pla				; dump return address LB
	pla				; dump return address HB
A_E20D					;				[E20D]
	rts


;******************************************************************************
;
; scan for ",valid byte", else do syntax error then warm start

Chk4ValidByte				;				[E20E]
	jsr	Chk4Comma		; scan for ",", else do syntax error
					; then warm start		[AEFD]


;******************************************************************************
;
; scan for valid byte, not [EOL] or ":", else do syntax error then warm start

Chk4ValidByte2				;				[E211]
	jsr	CHRGOT			; scan memory, another char?	[0079]
	bne	A_E20D			; yes, -> OK

	jmp	SyntaxError		; syntax error and warm start	[AF08]


;******************************************************************************
;
; get parameters for OPEN/CLOSE

GetParmOpenClo				;				[E219]
	lda	#$00			; clear the filename length
	jsr	SetFileName		; clear the filename		[FFBD]
	jsr	Chk4ValidByte2		; scan for valid byte, else do syntax
					; error then warm start		[E211]

	jsr	GetByteParm2		; get byte parameter, logical file
					; number			[B79E]
	stx	FORPNT			; save logical file number
	txa				; copy logical file number to A

	ldx	#$01			; set default device number, cassette
	ldy	#$00			; set default command
	jsr	SetAddresses		; set logical, first and second
					; addresses			[FFBA]
	jsr	ExitIfEotColl		; exit function if [EOT] or ":"	[E206]

	jsr	GetByte			; scan and get byte, else do syntax
					; error then warm start		[E200]
	stx	FORPNT+1		; save device number

	ldy	#$00			; clear command
	lda	FORPNT			; get logical file number

	cpx	#$03			; compare device number with screen
	bcc	A_E23F			; branch if less than screen

	dey				; else decrement command
A_E23F					;				[E23F]
	jsr	SetAddresses		; set logical, first and second
					; addresses			[FFBA]
	jsr	ExitIfEotColl		; exit function if [EOT] or ":"	[E206]
	jsr	GetByte			; scan and get byte, else do syntax
					; error then warm start		[E200]
	txa				; copy command to A
	tay				; copy command to Y

	ldx	FORPNT+1		; get device number
	lda	FORPNT			; get logical file number
	jsr	SetAddresses		; set logical, first and second
					; addresses			[FFBA]

	jsr	ExitIfEotColl		; exit function if [EOT] or ":"	[E206]
	jsr	Chk4ValidByte		; scan for ",byte", else do syntax
					; error then warm start		[E20E]


;******************************************************************************
;
; set filename

GetFileName				;				[E257]
	jsr	EvaluateValue		; evaluate expression		[AD9E]
	jsr	EvalString		; evaluate string		[B6A3]

	ldx	INDEX			; get string pointer LB
	ldy	INDEX+1			; get string pointer HB
	jmp	SetFileName		; set the filename and return	[FFBD]


;******************************************************************************
;
; perform COS()

bcCOS					;				[E264]
	lda	#<ConstPIdiv2		; set pi/2 pointer LB
	ldy	#>ConstPIdiv2		; set pi/2 pointer HB
	jsr	AddFORvar2FAC1		; add (AY) to FAC1		[B867]


;******************************************************************************
;
; perform SIN()

bcSIN					;				[E26B]
	jsr	CopyFAC1toFAC2		; round and copy FAC1 to FAC2	[BC0C]

	lda	#<ConstPIx2		; set 2*pi pointer LB
	ldy	#>ConstPIx2		; set 2*pi pointer HB
	ldx	ARGSGN			; get FAC2 sign (b7)
	jsr	FAC1divAY		; divide by (AY) (X=sign)	[BB07]

	jsr	CopyFAC1toFAC2		; round and copy FAC1 to FAC2	[BC0C]
	jsr	bcINT			; perform INT()			[BCCC]

	lda	#$00			; clear byte
	sta	ARISGN			; clear sign compare (FAC1 EOR FAC2)

	jsr	bcMINUS			; perform subtraction, FAC2 from FAC1
					;				[B853]
	lda	#<Const025		; set 0.25 pointer LB
	ldy	#>Const025		; set 0.25 pointer HB
	jsr	AYminusFAC1		; perform subtraction, FAC1 from (AY)
					;				[B850]
	lda	FACSGN			; get FAC1 sign (b7)
	pha				; save FAC1 sign
	bpl	bcSIN2			; branch if +ve

; FAC1 sign was -ve
	jsr	FAC1plus05		; add 0.5 to FAC1 (round FAC1)	[B849]

	lda	FACSGN			; get FAC1 sign (b7), negative?
	bmi	A_E2A0			; yes, ->

	lda	TANSGN			; get the comparison evaluation flag
	eor	#$FF			; toggle flag
	sta	TANSGN			; save the comparison evaluation flag
bcSIN2					;				[E29D]
	jsr	bcGREATER		; do - FAC1			[BFB4]
A_E2A0					;				[E2A0]
	lda	#<Const025		; set 0.25 pointer LB
	ldy	#>Const025		; set 0.25 pointer HB
	jsr	AddFORvar2FAC1		; add (AY) to FAC1		[B867]

	pla				; restore FAC1 sign, positive
	bpl	A_E2AD			; yes, ->

; else correct FAC1
	jsr	bcGREATER		; do - FAC1			[BFB4]
A_E2AD					;				[E2AD]
	lda	#<ConstVCosSin		; set pointer LB to counter
	ldy	#>ConstVCosSin		; set pointer HB to counter
	jmp	Power2			; ^2 then series evaluation and return
					;				[E043]


;******************************************************************************
;
; perform TAN()

bcTAN					;				[E2B4]
	jsr	FAC1toTemp		; pack FAC1 into FacTempStor	[BBCA]

	lda	#$00			; clear A
	sta	TANSGN			; clear the comparison evaluation flag

	jsr	bcSIN			; perform SIN()			[E26B]

	ldx	#<GarbagePtr		; set sin(n) pointer LB
	ldy	#>GarbagePtr		; set sin(n) pointer HB
	jsr	PackFAC1intoXY0		; pack FAC1 into (XY)		[E0F6]

	lda	#<FacTempStor		; set n pointer LB
	ldy	#>FacTempStor		; set n pointer HB
	jsr	UnpackAY2FAC1		; unpack memory (AY) into FAC1	[BBA2]

	lda	#$00			; clear byte
	sta	FACSGN			; clear FAC1 sign (b7)

	lda	TANSGN			; get the comparison evaluation flag
	jsr	bcTAN2			; save flag and go do series evaluation
					;				[E2DC]
	lda	#<GarbagePtr		; set sin(n) pointer LB
	ldy	#>GarbagePtr		; set sin(n) pointer HB
	jmp	AYdivFAC1		; convert AY and do (AY)/FAC1	[BB0F]


;******************************************************************************
;
; save comparison flag and do series evaluation

bcTAN2					;				[E2DC]
	pha				; save comparison flag
	jmp	bcSIN2			; add 0.25, ^2 then series evaluation
					;				[E29D]


;******************************************************************************
;
; constants and series for SIN/COS(n)

ConstPIdiv2				;				[E2E0]
.byte	$81,$49,$0F,$DA,$A2		; 1.570796371, pi/2, as floating number
ConstPIx2				;				[E2E5]
.byte	$83,$49,$0F,$DA,$A2		; 6.28319, 2*pi, as floating number
Const025				;				[E2EA]
.byte	$7F,$00,$00,$00,$00		; 0.25

ConstVCosSin				;				[E2EF]
.byte	$05				; series counter
.byte	$84,$E6,$1A,$2D,$1B		; -14.3813907
.byte	$86,$28,$07,$FB,$F8		;  42.0077971
.byte	$87,$99,$68,$89,$01		; -76.7041703
.byte	$87,$23,$35,$DF,$E1		;  81.6052237
.byte	$86,$A5,$5D,$E7,$28		; -41.3417021
.byte	$83,$49,$0F,$DA,$A2		;  6.28318531


;******************************************************************************
;
; perform ATN()

bcATN					;				[E30E]
	lda	FACSGN			; get FAC1 sign (b7)
	pha				; save sign, positive?
	bpl	A_E316			; yes, ->

	jsr	bcGREATER		; else do - FAC1		[BFB4]
A_E316					;				[E316]
	lda	FACEXP			; get FAC1 exponent
	pha				; push exponent
	cmp	#$81			; smaller than 1 ?
	bcc	A_E324			; yes, ->

	lda	#<Constant1		; pointer to 1 LB
	ldy	#>Constant1		; pointer to 1 HB
	jsr	AYdivFAC1		; convert AY and do (AY)/FAC1	[BB0F]
A_E324					;				[E324]
	lda	#<ConstATN		; pointer to series LB
	ldy	#>ConstATN		; pointer to series HB
	jsr	Power2			; ^2 then series evaluation	[E043]

	pla				; restore old FAC1 exponent
	cmp	#$81			; smaller than 1 ?
	bcc	A_E337			; yes, ->

	lda	#<ConstPIdiv2		; pointer to (pi/2) LB
	ldy	#>ConstPIdiv2		; pointer to (pi/2) LB
	jsr	AYminusFAC1		; perform subtraction, FAC1 from (AY)
					;				[B850]
A_E337					;				[E337]
	pla				; restore FAC1 sign, positive
	bpl	A_E33D			; yes, ->

	jmp	bcGREATER		; else do - FAC1 and return	[BFB4]

A_E33D					;				[E33D]
	rts


;******************************************************************************
;
; series for ATN(n)

ConstATN				;				[E33E]
.byte	$0B				; series counter
.byte	$76,$B3,$83,$BD,$D3		;-6.84793912e-04
.byte	$79,$1E,$F4,$A6,$F5		; 4.85094216e-03
.byte	$7B,$83,$FC,$B0,$10		;-0.0161117015
.byte	$7C,$0C,$1F,$67,$CA		; 0.034209638
.byte	$7C,$DE,$53,$CB,$C1		;-0.054279133
.byte	$7D,$14,$64,$70,$4C		; 0.0724571965
.byte	$7D,$B7,$EA,$51,$7A		;-0.0898019185
.byte	$7D,$63,$30,$88,$7E		; 0.110932413
.byte	$7E,$92,$44,$99,$3A		;-0.142839808
.byte	$7E,$4C,$CC,$91,$C7		; 0.19999912
.byte	$7F,$AA,$AA,$AA,$13		;-0.333333316
.byte	$81,$00,$00,$00,$00		; 1.000000000


;******************************************************************************
;
; BASIC warm start entry point

BasicWarmStart				;				[E37B]
	jsr	CloseIoChannls		; close input and output channels [FFCC]

	lda	#$00			; clear A
	sta	CurIoChan		; set current I/O channel, flag default

	jsr	ClrBasicStack		; flush BASIC stack and clear continue
					; pointer			[A67A]
	cli				; enable the interrupts
BasWarmStart2				;				[E386]
	ldx	#$80			; set -ve error, just do warm start
	jmp	(IERROR)		; go handle error message, normally
					; BasWarmStart3 = $E38b, here below
BasWarmStart3				;				[E38B]
	txa				; copy the error number, negative?
	bmi	A_E391			; yes, -> do warm start

	jmp	OutputErrMsg2		; else do error #X then warm start
					;				[A43A]

A_E391					;				[E391]
	jmp	OutputREADY		; do warm start			[A474]


;******************************************************************************
;
; BASIC cold start entry point

BasicColdStart				;				[E394]
	jsr	InitBasicVec		; initialise the BASIC vector table
					;				[E453]
	jsr	InitBasicRAM		; initialise the BASIC RAM locations
					;				[E3BF]
	jsr	InitMemory		; print the start up message and
					; initialise the memory pointers [E422]
S_E39D
	ldx	#$FB			; value for start stack
	txs				; set stack pointer
	bne	BasWarmStart2		; do "READY." warm start, branch always


;******************************************************************************
;
; character get subroutine for zero page

; the target address for the LDA $EA60 becomes the BASIC execute pointer once
; the block is copied to its destination, any non zero page address will do at
; assembly time, to assemble a three byte instruction. $EA60 is RTS, NOP.

; page 0 initialisation table from CHRGET
; increment and scan memory

DataCHRGET				;				[E3A2]
	inc	TXTPTR			; increment BASIC execute pointer low
					; byte, became zero?
	bne	A_E3A8			; no, ->

	inc	TXTPTR+1		; inc. BASIC execute pointer HB

; page 0 initialisation table from CHRGOT
; scan memory

A_E3A8					;				[E3A8]
	lda	$EA60			; get byte to scan, address set by call
					; routine
	cmp	#':'			; above ":"?
	bcs	A_E3B9			; yes, -> exit

; page 0 initialisation table from P_0080
; clear Cb if numeric

	cmp	#' '			; space?
	beq	DataCHRGET		; yes, ->

	sec				; set carry for SBC
	sbc	#'0'			; subtract "0"

	sec				; set carry for SBC
	sbc	#$D0			; subtract -"0"
; If the character was between "0" and "9", then the Xarry is cleared now.

A_E3B9					;				[E3B9]
	rts


;******************************************************************************
;
; spare bytes, not referenced

;S_E3BA
.byte	$80,$4F,$C7,$52,$58		; 0.811635157


;******************************************************************************
;
; initialise BASIC RAM locations

InitBasicRAM				;				[E3BF]
	lda	#$4C			; opcode for JMP
	sta	Jump0054		; save for functions vector jump
	sta	UserJump		; save for USR() vector jump, set USR()
					; vector to illegal quantity error
	lda	#<IllegalQuant		; set USR() vector LB
	ldy	#>IllegalQuant		; set USR() vector HB
	sta	USRADD			; save USR() vector LB
	sty	USRADD+1		; save USR() vector HB

	lda	#<ConvertAY2FAC1	; set fixed to float vector LB
	ldy	#>ConvertAY2FAC1	; set fixed to float vector HB
	sta	ADRAY2			; save fixed to float vector LB
	sty	ADRAY2+1		; save fixed to float vector HB

	lda	#<Float2Fixed		; set float to fixed vector LB
	ldy	#>Float2Fixed		; set float to fixed vector HB
	sta	ADRAY1			; save float to fixed vector LB
	sty	ADRAY1+1		; save float to fixed vector HB

; copy the character get subroutine from DataCHRGET to CHRGET (= $0073)

	ldx	#$1C			; set the byte count
A_E3E2					;				[E3E2]
	lda	DataCHRGET,X		; get a byte from the table
	sta	CHRGET,X		; save the byte in page zero

	dex				; decrement the count
	bpl	A_E3E2			; loop if not all done

; clear descriptors, strings, program area and mamory pointers

	lda	#$03			; set step size, collecting descriptors
	sta	GarbColStep		; save the garbage collection step size

	lda	#$00			; clear A
	sta	BITS			; clear FAC1 overfLB
	sta	CurIoChan		; clear current I/O chan, flag default
	sta	LASTPT+1		; clear current descriptor stack item
					; pointer HB

	ldx	#$01			; set X
	stx	STACK+$FD		; set the chain link pointer LB
	stx	STACK+$FC		; set the chain link pointer HB

	ldx	#LASTPT+2		; initial the value for descriptor stack
	stx	TEMPPT			; set descriptor stack pointer

	sec				; Carry = 1 to read the bottom of memory
	jsr	BottomOfMem		; read/set the bottom of memory	[FF9C]
	stx	TXTTAB			; save the start of memory LB
	sty	TXTTAB+1		; save the start of memory HB

	sec				; set Cb = 1 to read the top of memory
	jsr	TopOfMem		; read/set the top of memory	[FF99]
	stx	MEMSIZ			; save the end of memory LB
	sty	MEMSIZ+1		; save the end of memory HB
	stx	FRETOP			; set bottom of string space LB
	sty	FRETOP+1		; set bottom of string space HB

	ldy	#$00			; clear the index
	tya				; clear the A
	sta	(TXTTAB),Y		; clear the the first byte of memory

	inc	TXTTAB			; increment the start of memory LB
	bne	A_E421			; if no rollover, skip next INC

	inc	TXTTAB+1		; increment start of memory HB
A_E421					;				[E421]
	rts


;******************************************************************************
;
; print the start up message and initialise the memory pointers

InitMemory				;				[E422]
	lda	TXTTAB			; get the start of memory LB
	ldy	TXTTAB+1		; get the start of memory HB
	jsr	CheckAvailMem		; check available memory, do out of
					; memory error if no room	[A408]

	lda	#<TxtCommodore64	; set text pointer LB
	ldy	#>TxtCommodore64	; set text pointer HB
S_E42D
	jsr	OutputString		; print a null terminated string [AB1E]

	lda	MEMSIZ			; get the end of memory LB
	sec				; set carry for subtract
	sbc	TXTTAB			; subtract the start of memory LB
	tax				; copy the result to X

	lda	MEMSIZ+1		; get the end of memory HB
	sbc	TXTTAB+1		; subtract the start of memory HB
	jsr	PrintXAasInt		; print XA as unsigned integer	[BDCD]

	lda	#<BasicBytesFree	; set " BYTES FREE" pointer LB
	ldy	#>BasicBytesFree	; set " BYTES FREE" pointer HB
	jsr	OutputString		; print a null terminated string [AB1E]

	jmp	bcNEW2			; do NEW, CLEAR, RESTORE and return
					;				[A644]


;******************************************************************************
;
; BASIC vectors, these are copied to RAM from IERROR onwards

TblBasVectors				;				[E447]
.word	BasWarmStart3			; error message			IERROR
.word	MainWaitLoop2			; BASIC warm start		IMAIN
.word	Text2TokenCod2			; crunch BASIC tokens		ICRNCH
.word	TokCode2Text2			; uncrunch BASIC tokens		IQPLOP
.word	InterpretLoop3			; start new BASIC code		IGONE
.word	GetNextParm2			; get arithmetic element	IEVAL


;******************************************************************************
;
; initialise the BASIC vectors

InitBasicVec				;				[E453]
	ldx	#$0B			; set byte count
A_E455					;				[E455]
	lda	TblBasVectors,X		; get byte from table
	sta	IERROR,X		; save byte to RAM

	dex				; decrement index
	bpl	A_E455			; loop if more to do

	rts


;******************************************************************************
;
;S_E45F
.byte	$00				; unused byte ??


;******************************************************************************
;
; BASIC startup messages

BasicBytesFree				;				[E460]
.null	" basic bytes free{cr}"

TxtCommodore64				;				[E473]
.null	"{clr}{cr}    **** commodore 64 basic v2 ****{cr}{cr} 64k ram system  "


;******************************************************************************
;
; unused

E4AC	.byte	$81			; unused byte ??


;******************************************************************************
;
; open channel for output

OpenChan4OutpB				;				[E4AD]
	pha				; save the flag byte

	jsr	OpenChan4Outp		; open channel for output	[FFC9]
	tax				; copy the returned flag byte

	pla				; restore the alling flag byte
	bcc	A_E4B6			; if no error, skip copying error flag

	txa				; else copy the error flag
A_E4B6					;				[E4B6]
	rts


;******************************************************************************
;
; unused bytes

;S_E4B7
.byte	$AA,$AA,$AA,$AA			; unused
.byte	$AA,$AA,$AA,$AA			; unused
.byte	$AA,$AA,$AA,$AA			; unused
.byte	$AA,$AA,$AA,$AA			; unused
.byte	$AA,$AA,$AA,$AA			; unused
.byte	$AA,$AA,$AA,$AA			; unused
.byte	$AA,$AA,$AA,$AA			; unused


;******************************************************************************
;
; flag the RS232 start bit and set the parity

RS232_SaveSet				;				[E4D3]
	sta	RINONE			; save the start bit check flag, set
					; start bit received
	lda	#$01			; set the initial parity state
	sta	RIPRTY			; save the receiver parity bit

	rts


;******************************************************************************
;
; save the current colour to the colour RAM

SaveCurColour				;				[E4DA]
	lda	COLOR			; get the current colour code
	sta	(ColorRamPtr),Y		; save it to the colour RAM

	rts


;******************************************************************************
;
; wait ~8.5 seconds for any key from the STOP key column

Wait8Seconds				;				[E4E0]
	adc	#$02			; set the number of jiffies to wait
A_E4E2					;				[E4E2]
	ldy	StopKey			; read the stop key column
	iny				; test for $FF, no keys pressed
	bne	A_E4EB			; if any keys were pressed just exit

	cmp	TimeBytes+1		; compare the wait time with the jiffy
					; clock mid byte
	bne	A_E4E2			; if not there yet go wait some more

A_E4EB					;				[E4EB]
	rts


;******************************************************************************
;
; baud rate word is calculated from ..
;
; (system clock / baud rate) / 2 - 100
;
;		system clock
;		------------
; PAL		  985248 Hz
; NTSC		 1022727 Hz

; baud rate tables for PAL C64

TblBaudRates				;				[E4EC]
.word	$2619				;   50	 baud	985300
.word	$1944				;   75	 baud	985200
.word	$111A				;  110	 baud	985160
.word	$0DE8				;  134.5 baud	984540
.word	$0C70				;  150	 baud	985200
.word	$0606				;  300	 baud	985200
.word	$02D1				;  600	 baud	985200
.word	$0137				; 1200	 baud	986400
.word	$00AE				; 1800	 baud	986400
.word	$0069				; 2400	 baud	984000


;******************************************************************************
;
; return the base address of the I/O devices

GetAddrIoDevs2				;				[E500]
	ldx	#<CIA1DRA		; get the I/O base address LB
	ldy	#>CIA1DRA		; get the I/O base address HB
	rts


;******************************************************************************
;
; return the x,y organization of the screen

GetSizeScreen2				;				[E505]
	ldx	#$28			; get the x size
	ldy	#$19			; get the y size
	rts


;******************************************************************************
;
; read/set the x,y cursor position

CursorPosXY2				;				[E50A]
	bcs	A_E513			; if Carry set -> do read

; Set the cursor position
	stx	PhysCurRow		; save the cursor row
	sty	LineCurCol		; save the cursor column
	jsr	CalcCursorPos		; set the screen pointers for the
					; cursor row, column		[E56C]
A_E513					;				[E513]
	ldx	PhysCurRow		; get the cursor row
	ldy	LineCurCol		; get the cursor column
	rts


;******************************************************************************
;
; initialise the screen and keyboard

InitScreenKeyb				;				[E518]
	jsr	InitVideoIC		; initialise the vic chip	[E5A0]

	lda	#$00			; clear A
	sta	MODE			; clear the shift mode switch
	sta	BLNON			; clear the cursor blink phase

	lda	#<ShftCtrlCbmKey	; get the keyboard decode logic pointer
					; LB
	sta	KEYLOG			; save the keyboard decode logic pointer
					; LB

	lda	#>ShftCtrlCbmKey	; get the keyboard decode logic pointer
					; HB
	sta	KEYLOG+1		; save the keyboard decode logic pointer
					; HB
	lda	#$0A			; set maximum size of keyboard buffer
	sta	XMAX			; save maximum size of keyboard buffer
	sta	DELAY			; save the repeat delay counter

	lda	#$0E			; set light blue
	sta	COLOR			; save the current colour code

	lda	#$04			; speed 4
	sta	KOUNT			; save the repeat speed counter

	lda	#$0C			; set the cursor flash timing
	sta	BLNCT			; save the cursor timing countdown
	sta	BLNSW			; save cursor enable, $00 = flash cursor


;******************************************************************************
;
; clear the screen

ClearScreen				;				[E544]
	lda	HIBASE			; get the screen memory page
	ora	#$80			; set the high bit, flag every line is
					; a logical line start
	tay				; copy to Y

	lda	#$00			; clear the line start LB
	tax				; clear the index
A_E54D					;				[E54D]
	sty	LDTB1,X			; save start of line X pointer HB

	clc				; clear carry for add
	adc	#$28			; add the line length to the LB
	bcc	A_E555			; if no rollover skip the HB
					; increment
	iny				; else increment the HB
A_E555					;				[E555]
	inx				; increment the line index
	cpx	#$1A			; compare it with number of lines + 1
	bne	A_E54D			; loop if not all done

	lda	#$FF			; set the end of table marker
	sta	LDTB1,X			; mark the end of the table

	ldx	#$18			; set the line count, 25 lines to do,
					; 0 to 24
A_E560					;				[E560]
	jsr	ClearLineX		; clear screen line X		[E9FF]

	dex				; decrement the count
	bpl	A_E560			; loop if more to do


;******************************************************************************
;
; home the cursor

CursorHome				;				[E566]
	ldy	#$00			; clear Y
	sty	LineCurCol		; clear the cursor column
	sty	PhysCurRow		; clear the cursor row


;******************************************************************************
;
; set screen pointers for cursor row, column

CalcCursorPos				;				[E56C]
	ldx	PhysCurRow		; get the cursor row
	lda	LineCurCol		; get the cursor column
A_E570					;				[E570]
	ldy	LDTB1,X			; get start of line X pointer HB
	bmi	A_E57C			; if it is logical line start, continue

	clc				; else clear carry for add
	adc	#$28			; add one line length
	sta	LineCurCol		; save the cursor column

	dex				; decrement the cursor row
	bpl	A_E570			; loop, branch always

A_E57C					;				[E57C]
	jsr	FetchScreenAddr		; fetch a screen address	[E9F0]

	lda	#$27			; set the line length

	inx				; increment the cursor row
A_E582					;				[E582]
	ldy	LDTB1,X			; get the start of line X pointer HB
	bmi	A_E58C			; if logical line start exit

	clc				; else clear carry for add
	adc	#$28			; add one line length to the current
					; line length
	inx				; increment the cursor row
	bpl	A_E582			; loop, branch always

A_E58C					;				[E58C]
	sta	CurLineLeng		; save current screen line length

	jmp	PtrCurLineColRAM	; calculate the pointer to colour RAM
					; and return			[EA24]

SetPtrLogLine				;				[E591]
	cpx	CursorRow		; compare it with the input cursor row
	beq	A_E598			; if there just exit

	jmp	J_E6ED			; else go ??			[E6ED]

A_E598					;				[E598]
	rts


;******************************************************************************
;
; orphan bytes ??

	nop				; huh
	jsr	InitVideoIC		; initialise the vic chip	[E5A0]
	jmp	CursorHome		; home the cursor and return	[E566]


;******************************************************************************
;
; initialise the vic chip

InitVideoIC				;				[E5A0]
	lda	#$03			; set the screen as the output device
	sta	DFLTO			; save the output device number

	lda	#$00			; set the keyboard as the input device
	sta	DFLTN			; save the input device number

	ldx	#$2F			; set the count/index
A_E5AA					;				[E5AA]
	lda	TblValuesVIC-1,X	; get a vic ii chip initialisation value
	sta	VIC_chip-1,X		; save it to the vic ii chip

	dex				; decrement the count/index
	bne	A_E5AA			; loop if more to do

	rts


;******************************************************************************
;
; input from the keyboard buffer

GetCharKeybBuf				;				[E5B4]
	ldy	KeyboardBuf		; get the current character from buffer
	ldx	#$00			; clear the index
A_E5B9					;				[E5B9]
	lda	KeyboardBuf+1,X		; get next character from the buffer
	sta	KeyboardBuf,X		; save it as current character in buffer

	inx				; increment the index
	cpx	NDX			; compare it with keyboard buffer index
	bne	A_E5B9			; loop if more to do

	dec	NDX			; decrement keyboard buffer index

	tya				; copy the key to A

	cli				; enable the interrupts
	clc				; flag got byte

	rts


;******************************************************************************
;
; write character and wait for key

OutCharWaitKey				;				[E5CA]
	jsr	OutputChar		; output character		[E716]


;******************************************************************************
;
; wait for a key from the keyboard

WaitForKey				;				[E5CD]
	lda	NDX			; get the keyboard buffer index
	sta	BLNSW			; cursor enable, $00 = flash cursor,
					; $xx = no flash
	sta	AUTODN			; screen scrolling flag, $00 = scroll,
					; $xx = no scroll. This disables both
					; the cursor flash and the screen scroll
					; while there are characters in the
					; keyboard buffer
	beq	WaitForKey		; loop if the buffer is empty

	sei				; disable the interrupts

	lda	BLNON			; get the cursor blink phase
	beq	A_E5E7			; if cursor phase skip the overwrite

; else it is the character phase
	lda	GDBLN			; get the character under the cursor
	ldx	GDCOL			; get the colour under the cursor

	ldy	#$00			; clear Y
	sty	BLNON			; clear the cursor blink phase

	jsr	PrntCharA_ColX		; print character A and colour X [EA13]
A_E5E7					;				[E5E7]
	jsr	GetCharKeybBuf		; input from the keyboard buffer [E5B4]
	cmp	#'{run}'		; compare with [SHIFT][RUN]
	bne	A_E5FE			; if not [SHIFT][RUN] skip buffer fill

; keys are [SHIFT][RUN] so put "LOAD",$0D,"RUN",$0D into
; the buffer
	ldx	#$09			; set the byte count
	sei				; disable the interrupts
	stx	NDX			; set the keyboard buffer index
A_E5F3					;				[E5F3]
	lda	TblAutoLoadRun-1,X	; get byte from the auto load/run table
	sta	KeyboardBuf-1,X		; save it to the keyboard buffer

	dex				; decrement the count/index
	bne	A_E5F3			; loop while more to do

	beq	WaitForKey		; always -> loop for the next key

; was not [SHIFT][RUN]
A_E5FE					;				[E5FE]
	cmp	#'{cr}'			; compare the key with [CR]
	bne	OutCharWaitKey		; if not [CR] print the character and
					; get the next key
; else it was [CR]
	ldy	CurLineLeng		; get the current screen line length
	sty	CRSW			; input from keyboard or screen,
					; $xx = screen, $00 = keyboard
A_E606					;				[E606]
	lda	(CurScrLine),Y		; get the character from the current
					; screen line
	cmp	#' '			; compare it with [SPACE]
	bne	A_E60F			; if not [SPACE] continue

	dey				; else eliminate the space, decrement
					; end of input line
	bne	A_E606			; loop, branch always

A_E60F					;				[E60F]
	iny				; increment past the last non space
					; character on line
	sty	INDX			; save the input [EOL] pointer

	ldy	#$00			; clear A
	sty	AUTODN			; clear the screen scrolling flag,
					; $00 = scroll
	sty	LineCurCol		; clear the cursor column
	sty	QTSW			; clear the cursor quote flag,
					; $xx = quote, $00 = no quote
	lda	CursorRow		; get the input cursor row
	bmi	A_E63A			;.

	ldx	PhysCurRow		; get the cursor row
	jsr	SetPtrLogLine		; find and set the pointers for the
					; start of logical line		[E591]
	cpx	CursorRow		; compare with input cursor row
	bne	A_E63A			;.

	lda	CursorCol		; get the input cursor column
	sta	LineCurCol		; save the cursor column

	cmp	INDX			; compare the cursor column with input
					; [EOL] pointer
	bcc	A_E63A			; if less, cursor is in line, go ??
	bcs	A_E65D			; alway ->


;******************************************************************************
;
; input from screen or keyboard

InputScrKeyb				;				[E632]
	tya				; copy Y
	pha				; save Y

	txa				; copy X
	pha				; save X

	lda	CRSW			; input from keyboard or screen,
					; $xx = screen, $00 = keyboard
	beq	WaitForKey		; if keyboard go wait for key
A_E63A					;				[E63A]
	ldy	LineCurCol		; get the cursor column
	lda	(CurScrLine),Y		; get character from current screen line
	sta	TEMPD7			; save temporary last character

	and	#$3F			; mask key bits
	asl	TEMPD7			; << temporary last character
	bit	TEMPD7			; test it
	bpl	A_E64A			; branch if not [NO KEY]

	ora	#$80			;.
A_E64A					;				[E64A]
	bcc	A_E650			;.

	ldx	QTSW			; get the cursor quote flag,
					; $xx = quote, $00 = no quote
	bne	A_E654			; if in quote mode go ??

A_E650					;				[E650]
	bvs	A_E654			;.

	ora	#$40			;.
A_E654					;				[E654]
	inc	LineCurCol		; increment the cursor column

	jsr	ToggleCursorFlg		; if open quote toggle cursor quote
					; flag				[E684]
	cpy	INDX			; compare ?? with input [EOL] pointer
	bne	A_E674			; if not at line end go ??

A_E65D					;				[E65D]
	lda	#$00			; clear A
	sta	CRSW			; clear input from keyboard or screen,
					; $xx = screen, $00 = keyboard
	lda	#'{cr}'			; set character [CR]

	ldx	DFLTN			; get the input device number
	cpx	#$03			; compare the input device with screen
	beq	A_E66F			; if screen go ??

	ldx	DFLTO			; get the output device number
	cpx	#$03			; compare the output device with screen
	beq	A_E672			; if screen go ??

A_E66F					;				[E66F]
	jsr	OutputChar		; output the character		[E716]
A_E672					;				[E672]
	lda	#'{cr}'			; set character [CR]
A_E674					;				[E674]
	sta	TEMPD7			; save character

	pla				; pull X
	tax				; restore X

	pla				; pull Y
	tay				; restore Y

	lda	TEMPD7			; restore character
	cmp	#$DE			;.
	bne	A_E682			;.

	lda	#$FF			;.
A_E682					;				[E682]
	clc				; flag ok
	rts


;******************************************************************************
;
; if open quote toggle cursor quote flag

ToggleCursorFlg				;				[E684]
	cmp	#'"'			; compare byte with "
	bne	A_E690			; exit if not "

	lda	QTSW			; get cursor quote flag, $xx = quote,
					; $00 = no quote
	eor	#$01			; toggle it
	sta	QTSW			; save cursor quote flag

	lda	#'"'			; restore the "
A_E690					;				[E690]
	rts


;******************************************************************************
;
; insert uppercase/graphic character

UpcChar2Screen				;				[E691]
	ora	#$40			; change to uppercase/graphic
Char2Screen				;				[E693]
	ldx	RVS			; get the reverse flag
	beq	A_E699			; branch if not reverse

; else ..
; insert reversed character

ReverseChar				;				[E697]
	ora	#$80			; reverse character
A_E699					;				[E699]
	ldx	InsertCount		; get the insert count
	beq	A_E69F			; branch if none

	dec	InsertCount		; else decrement the insert count
A_E69F					;				[E69F]
	ldx	COLOR			; get the current colour code
	jsr	PrntCharA_ColX		; print character A and colour X [EA13]
	jsr	AdvanceCursor		; advance the cursor		[E6B6]

; restore the registers, set the quote flag and exit
RestorRegsQuot				;				[E6A8]
	pla				; pull Y
	tay				; restore Y

	lda	InsertCount		; get the insert count, inserts to do?
	beq	A_E6B0			; no, ->

	lsr	QTSW			; clear cursor quote flag, $xx = quote,
					; $00 = no quote
A_E6B0					;				[E6B0]
	pla				; pull X
	tax				; restore X

	pla				; restore A

	clc				;.
	cli				; enable the interrupts

	rts


;******************************************************************************
;
; advance the cursor

AdvanceCursor				;				[E6B6]
	jsr	Test4LineIncr		; test for line increment	[E8B3]

	inc	LineCurCol		; increment the cursor column

	lda	CurLineLeng		; get current screen line length
	cmp	LineCurCol		; compare ?? with the cursor column
	bcs	A_E700			; exit if line length >= cursor column

	cmp	#$4F			; compare with max length
	beq	A_E6F7			; if at max clear column, back cursor
					; up and do newline
	lda	AUTODN			; get the autoscroll flag
	beq	A_E6CD			; branch if autoscroll on

	jmp	InsertLine2		;.else open space on screen	[E967]

A_E6CD					;				[E6CD]
	ldx	PhysCurRow		; get the cursor row
	cpx	#$19			; compare with max + 1
	bcc	AddRow2CurLine		; if less than max + 1 go add this row
					; to the current logical line

	jsr	ScrollScreen		; else scroll the screen	[E8EA]

	dec	PhysCurRow		; decrement the cursor row
	ldx	PhysCurRow		; get the cursor row

; add this row to the current logical line

AddRow2CurLine				;				[E6DA]
	asl	LDTB1,X			; clear bit 7 of start of line X ...
	lsr	LDTB1,X			;    ... HB back

; make next screen line start of logical line, increment line length and set
; pointers, set b7, start of logical line
	inx				; increment screen row

	lda	LDTB1,X			; get start of line X pointer HB
	ora	#$80			; mark as start of logical line
	sta	LDTB1,X			; set start of line X pointer HB

	dex				; restore screen row

	lda	CurLineLeng		; get current screen line length

; add one line length and set the pointers for the start of the line

	clc				; clear carry for add
	adc	#$28			; add one line length
	sta	CurLineLeng		; save current screen line length
J_E6ED					;				[E6ED]
	lda	LDTB1,X			; get start of line X pointer HB
	bmi	A_E6F4			; exit loop if start of logical line

	dex				; else back up one line
	bne	J_E6ED			; loop if not on first line
A_E6F4					;				[E6F4]
	jmp	FetchScreenAddr		; fetch a screen address	[E9F0]

A_E6F7					;				[E6F7]
	dec	PhysCurRow		; decrement the cursor row
	jsr	NewScreenLine		; do newline			[E87C]
	lda	#$00			; clear A
	sta	LineCurCol		; clear the cursor column
A_E700					;				[E700]
	rts


;******************************************************************************
;
; back onto the previous line if possible

BackToPrevLine				;				[E701]
	ldx	PhysCurRow		; get the cursor row
	bne	A_E70B			; branch if not top row

	stx	LineCurCol		; clear cursor column

	pla				; dump return address LB

	pla				; dump return address HB
	bne	RestorRegsQuot		; restore registers, set quote flag
					; and exit, branch always
A_E70B					;				[E70B]
	dex				; decrement the cursor row
	stx	PhysCurRow		; save the cursor row

	jsr	CalcCursorPos		; set the screen pointers for cursor
					; row, column			[E56C]
	ldy	CurLineLeng		; get current screen line length
	sty	LineCurCol		; save the cursor column

	rts


;******************************************************************************
;
; output a character to the screen

OutputChar				;				[E716]
	pha				; save character
	sta	TEMPD7			; save temporary last character

	txa				; copy X
	pha				; save X

	tya				; copy Y
	pha				; save Y

	lda	#$00			; clear A
	sta	CRSW			; clear input from keyboard or screen,
					; $xx = screen, $00 = keyboard
	ldy	LineCurCol		; get cursor column

	lda	TEMPD7			; restore last character
	bpl	A_E72A			; branch if unshifted

	jmp	ShiftedChars		; do shifted characters and return
					;				[E7D4]
A_E72A					;				[E72A]
	cmp	#'{cr}'			; compare with [CR]
	bne	A_E731			; branch if not [CR]

	jmp	OutputCR		; else output [CR] and return	[E891]

A_E731					;				[E731]
	cmp	#' '			; compare with [SPACE]
	bcc	A_E745			; branch if < [SPACE]

	cmp	#$60			;.
	bcc	A_E73D			; branch if $20 to $5F

; character is $60 or greater
	and	#$DF			;.
	bne	A_E73F			;.

A_E73D					;				[E73D]
	and	#$3F			;.
A_E73F					;				[E73F]
	jsr	ToggleCursorFlg		; if open quote toggle cursor
					; direct/programmed flag	[E684]
	jmp	Char2Screen		;.				[E693]

; character was < [SPACE] so is a control character of some sort
A_E745					;				[E745]
	ldx	InsertCount		; get the insert count
	beq	A_E74C			; if no characters to insert continue

	jmp	ReverseChar		; insert reversed character	[E697]

A_E74C					;				[E74C]
	cmp	#'{del}'		; compare char with [INSERT]/[DELETE]
	bne	A_E77E			; if not [INSERT]/[DELETE] go ??

	tya				;.
	bne	A_E759			;.

	jsr	BackToPrevLine		; back onto previous line if possible
					;				[E701]
	jmp	J_E773			;.				[E773]

A_E759					;				[E759]
	jsr	Test4LineDecr		; test for line decrement	[E8A1]

; now close up the line
	dey				; decrement index to previous character
	sty	LineCurCol		; save the cursor column

	jsr	PtrCurLineColRAM	; calculate pointer to colour RAM [EA24]
A_E762					;				[E762]
	iny				; increment index to next character
	lda	(CurScrLine),Y		; get character from current screen line
	dey				; decrement index to previous character
	sta	(CurScrLine),Y		; save character to current screen line

	iny				; increment index to next character
	lda	(ColorRamPtr),Y		; get colour RAM byte
	dey				; decrement index to previous character
	sta	(ColorRamPtr),Y		; save colour RAM byte

	iny				; increment index to next character
	cpy	CurLineLeng		; comp with current screen line length
	bne	A_E762			; loop if not there yet

J_E773					;				[E773]
	lda	#' '			; set [SPACE]
	sta	(CurScrLine),Y		; clear last char on current screen line

	lda	COLOR			; get the current colour code
	sta	(ColorRamPtr),Y		; save to colour RAM
	bpl	A_E7CB			; branch always

A_E77E					;				[E77E]
	ldx	QTSW			; get cursor quote flag, $xx = quote,
					; $00 = no quote
	beq	A_E785			; branch if not quote mode

	jmp	ReverseChar		; insert reversed character	[E697]

A_E785					;				[E785]
	cmp	#'{rvs on}'		; compare with [RVS ON]
	bne	A_E78B			; if not [RVS ON] skip setting the
					; reverse flag
	sta	RVS			; else set the reverse flag
A_E78B					;				[E78B]
	cmp	#'{home}'		; compare with [CLR HOME]
	bne	A_E792			; if not [CLR HOME] continue

	jsr	CursorHome		; home the cursor		[E566]
A_E792					;				[E792]
	cmp	#'{right}'		; compare with [CURSOR RIGHT]
	bne	A_E7AD			; if not [CURSOR RIGHT] go ??

	iny				; increment the cursor column

	jsr	Test4LineIncr		; test for line increment	[E8B3]
	sty	LineCurCol		; save the cursor column

	dey				; decrement the cursor column
	cpy	CurLineLeng		; compare cursor column with current
					; screen line length
	bcc	A_E7AA			; exit if less

; else the cursor column is >= the current screen line length so back onto the
; current line and do a newline
	dec	PhysCurRow		; decrement the cursor row

	jsr	NewScreenLine		; do newline			[E87C]

	ldy	#$00			; clear cursor column
A_E7A8					;				[E7A8]
	sty	LineCurCol		; save the cursor column
A_E7AA					;				[E7AA]
	jmp	RestorRegsQuot		; restore the registers, set the quote
					; flag and exit			[E6A8]
A_E7AD					;				[E7AD]
	cmp	#'{down}'		; compare with [CURSOR DOWN]
	bne	A_E7CE			; if not [CURSOR DOWN] go ??

	clc				; clear carry for add
	tya				; copy the cursor column
	adc	#$28			; add one line
	tay				; copy back to Y

	inc	PhysCurRow		; increment the cursor row

	cmp	CurLineLeng		; compare cursor column with current
					; screen line length
	bcc	A_E7A8			; if less, save cursor column and exit

	beq	A_E7A8			; if equal, save cursor column and exit

; else the cursor has moved beyond the end of this line so back it up until
; it's on the start of the logical line
	dec	PhysCurRow		; decrement the cursor row
A_E7C0					;				[E7C0]
	sbc	#$28			; subtract one line
	bcc	A_E7C8			; if on previous line exit the loop

	sta	LineCurCol		; else save the cursor column
	bne	A_E7C0			; loop if not at the start of the line

A_E7C8					;				[E7C8]
	jsr	NewScreenLine		; do newline			[E87C]
A_E7CB					;				[E7CB]
	jmp	RestorRegsQuot		; restore the registers, set the quote
					; flag and exit			[E6A8]
A_E7CE					;				[E7CE]
	jsr	SetColourCode		; set the colour code		[E8CB]
	jmp	ChkSpecCodes		; go check for special character codes
					;				[EC44]
ShiftedChars				;				[E7D4]
	and	#$7F			; mask 0xxx, clear b7
	cmp	#$7F			; was it $FF before the mask
	bne	A_E7DC			; branch if not

	lda	#$5E			; else make it $5E
A_E7DC					;				[E7DC]
	cmp	#' '			; compare the character with [SPACE]
	bcc	A_E7E3			; if < [SPACE] go ??

	jmp	UpcChar2Screen		; insert uppercase/graphic character
					; and return			[E691]

; character was $80 to $9F and is now $00 to $1F
A_E7E3					;				[E7E3]
	cmp	#'{cr}'			; compare with [CR]
	bne	A_E7EA			; if not [CR] continue

	jmp	OutputCR		; else output [CR] and return	[E891]

; was not [CR]
A_E7EA					;				[E7EA]
	ldx	QTSW			; get the cursor quote flag,
					; $xx = quote, $00 = no quote
	bne	A_E82D			; branch if quote mode

	cmp	#'{del}'		; compare with [INSERT DELETE]
	bne	A_E829			; if not [INSERT DELETE] go ??

	ldy	CurLineLeng		; get current screen line length
	lda	(CurScrLine),Y		; get character from current screen line
	cmp	#' '			; compare the character with [SPACE]
	bne	A_E7FE			; if not [SPACE] continue

	cpy	LineCurCol		; compare the current column with the
					; cursor column
	bne	A_E805			; if not cursor column go open up space
					; on line
A_E7FE					;				[E7FE]
	cpy	#$4F			; compare current column with max line
					; length
	beq	A_E826			; if at line end just exit

	jsr	InsertLine		; else open up a space on the screen
					; now open up space on the line to
					; insert a character		[E965]
A_E805					;				[E805]
	ldy	CurLineLeng		; get current screen line length
	jsr	PtrCurLineColRAM	; calc the pointer to colour RAM [EA24]
A_E80A					;				[E80A]
	dey				; decrement index to previous character
	lda	(CurScrLine),Y		; get the character from the current
					; screen line
	iny				; increment the index to next character
	sta	(CurScrLine),Y		; save the character to the current
					; screen line
	dey				; decrement index to previous character
	lda	(ColorRamPtr),Y		; get the current screen line colour
					; RAM byte
	iny				; increment the index to next character
	sta	(ColorRamPtr),Y		; save the current screen line colour
					; RAM byte
	dey				; decrement index to the previous char
	cpy	LineCurCol		; compare index with the cursor column
	bne	A_E80A			; loop if not there yet

	lda	#' '			; set [SPACE]
	sta	(CurScrLine),Y		; clear character at cursor position on
					; current screen line
	lda	COLOR			; get current colour code
	sta	(ColorRamPtr),Y		; save to cursor position on current
					; screen line colour RAM
	inc	InsertCount		; increment insert count
A_E826					;				[E826]
	jmp	RestorRegsQuot		; restore the registers, set the quote
					; flag and exit			[E6A8]
A_E829					;				[E829]
	ldx	InsertCount		; get the insert count
	beq	A_E832			; branch if no insert space

A_E82D					;				[E82D]
	ora	#$40			; change to uppercase/graphic
	jmp	ReverseChar		; insert reversed character	[E697]

A_E832					;				[E832]
	cmp	#'{up}' & $7f		; compare with [CURSOR UP]
	bne	A_E84C			; branch if not [CURSOR UP]

	ldx	PhysCurRow		; get the cursor row
	beq	A_E871			; if on the top line go restore the
					; registers, set quote flag and exit
	dec	PhysCurRow		; decrement the cursor row

	lda	LineCurCol		; get the cursor column
	sec				; set carry for subtract
	sbc	#$28			; subtract one line length
	bcc	A_E847			; branch if stepped back to prev line

	sta	LineCurCol		; else save the cursor column ..
	bpl	A_E871			; .. and exit, branch always

A_E847					;				[E847]
	jsr	CalcCursorPos		; set the screen pointers for cursor
					; row, column ..		[E56C]
	bne	A_E871			; .. and exit, branch always

A_E84C					;				[E84C]
	cmp	#'{rvs off}' & $7f	; compare with [RVS OFF]
	bne	A_E854			; if not [RVS OFF] continue

	lda	#$00			; else clear A
	sta	RVS			; clear the reverse flag
A_E854					;				[E854]
	cmp	#'{left}' & $7f		; compare with [CURSOR LEFT]
	bne	A_E86A			; if not [CURSOR LEFT] go ??

	tya				; copy the cursor column
	beq	A_E864			; if at start of line go back onto the
					; previous line
	jsr	Test4LineDecr		; test for line decrement	[E8A1]

	dey				; decrement the cursor column
	sty	LineCurCol		; save the cursor column

	jmp	RestorRegsQuot		; restore the registers, set the quote
					; flag and exit			[E6A8]
A_E864					;				[E864]
	jsr	BackToPrevLine		; back to the previous line if possible
					;				[E701]
	jmp	RestorRegsQuot		; restore the registers, set the quote
					; flag and exit			[E6A8]
A_E86A					;				[E86A]
	cmp	#'{clr}' & $7f		; compare with [CLR]
	bne	A_E874			; if not [CLR] continue

	jsr	ClearScreen		; clear the screen		[E544]
A_E871					;				[E871]
	jmp	RestorRegsQuot		; restore the registers, set the quote
					; flag and exit			[E6A8]
A_E874					;				[E874]
	ora	#$80			; restore b7, colour can only be black,
					; cyan, magenta or yellow
	jsr	SetColourCode		; set the colour code		[E8CB]
	jmp	Chk4SpecChar		; go check for special character codes
					; except for switch to lower case [EC4F]

;******************************************************************************
;
; do newline

NewScreenLine				;				[E87C]
	lsr	CursorRow		; shift >> input cursor row
	ldx	PhysCurRow		; get the cursor row
A_E880					;				[E880]
	inx				; increment the row
	cpx	#$19			; compare it with last row + 1
	bne	A_E888			; if not last row+1 skip screen scroll

	jsr	ScrollScreen		; else scroll the screen	[E8EA]
A_E888					;				[E888]
	lda	LDTB1,X			; get start of line X pointer HB
	bpl	A_E880			; loop if not start of logical line

	stx	PhysCurRow		; save the cursor row

	jmp	CalcCursorPos		; set the screen pointers for cursor
					; row, column and return	[E56C]


;******************************************************************************
;
; output [CR]

OutputCR				;				[E891]
	ldx	#$00			; clear X
	stx	InsertCount		; clear the insert count
	stx	RVS			; clear the reverse flag
	stx	QTSW			; clear the cursor quote flag,
					; $xx = quote, $00 = no quote
	stx	LineCurCol		; save the cursor column

	jsr	NewScreenLine		; do newline			[E87C]
	jmp	RestorRegsQuot		; restore the registers, set the quote
					; flag and exit			[E6A8]


;******************************************************************************
;
; test for line decrement

Test4LineDecr				;				[E8A1]
	ldx	#$02			; set the count
	lda	#$00			; set the column
A_E8A5					;				[E8A5]
	cmp	LineCurCol		; compare column with the cursor column
	beq	A_E8B0			; if at the start of the line, go
					; decrement the cursor row and exit
	clc				; else clear carry for add
	adc	#$28			; increment to next line

	dex				; decrement loop count
	bne	A_E8A5			; loop if more to test

	rts

A_E8B0					;				[E8B0]
	dec	PhysCurRow		; else decrement the cursor row

	rts


;******************************************************************************
;
; test for line increment. if at end of the line, but not at end of the last
; line, increment the cursor row

Test4LineIncr				;				[E8B3]
	ldx	#$02			; set the count
	lda	#$27			; set the column
A_E8B7					;				[E8B7]
	cmp	LineCurCol		; compare column with the cursor column
	beq	A_E8C2			; if at end of line test and possibly
					; increment cursor row
	clc				; else clear carry for add
	adc	#$28			; increment to the next line
	dex				; decrement the loop count
	bne	A_E8B7			; loop if more to test

	rts

; cursor is at end of line
A_E8C2					;				[E8C2]
	ldx	PhysCurRow		; get the cursor row
	cpx	#$19			; compare it with the end of the screen
	beq	A_E8CA			; if at the end of screen just exit

	inc	PhysCurRow		; else increment the cursor row
A_E8CA					;				[E8CA]
	rts


;******************************************************************************
;
; set the colour code. enter with the colour character in A. if A does not
; contain a colour character this routine exits without changing the colour

SetColourCode				;				[E8CB]
	ldx	#D_E8EA-AscColourCodes-1; set the colour code count
A_E8CD					;				[E8CD]
	cmp	AscColourCodes,X	; compare character with a table code
	beq	A_E8D6			; if a match go save colour and exit

	dex				; else decrement the index
	bpl	A_E8CD			; loop if more to do

	rts

A_E8D6					;				[E8D6]
	stx	COLOR			; save the current colour code

	rts


;******************************************************************************
;
; ASCII colour code table
					; CHR$()	colour
AscColourCodes				; ------	------
.text	"{blk}"				;  144		black
.text	"{wht}"				;    5		white
.text	"{red}"				;   28		red
.text	"{cyn}"				;  159		cyan
.text	"{pur}"				;  156		purple
.text	"{grn}"				;   30		green
.text	"{blu}"				;   31		Blue
.text	"{yel}"				;  158		yellow
.text	"{orng}"			;  129		orange
.text	"{brn}"				;  149		brown
.text	"{lred}"			;  150		light red
.text	"{gry1}"			;  151		dark grey
.text	"{gry2}"			;  152		medium grey
.text	"{lgrn}"			;  153		light green
.text	"{lblu}"			;  154		light blue
.text	"{gry3}"			;  155		light grey
D_E8EA					;				[E8EA]


;******************************************************************************
;
; scroll the screen

ScrollScreen				;				[E8EA]
	lda	SAL			; copy the tape buffer start pointer
	pha				; save it

	lda	SAL+1			; copy the tape buffer start pointer
	pha				; save it

	lda	EAL			; copy the tape buffer end pointer
	pha				; save it

	lda	EAL+1			; copy the tape buffer end pointer
	pha				; save it
A_E8F6					;				[E8F6]
	ldx	#$FF			; set to -1 for pre increment loop

	dec	PhysCurRow		; decrement the cursor row
	dec	CursorRow		; decrement the input cursor row
	dec	TmpLineScrl		; decrement the screen row marker
A_E8FF					;				[E8FF]
	inx				; increment the line number

	jsr	FetchScreenAddr		; fetch a screen address, set the start
					; of line X			[E9F0]
	cpx	#$18			; compare with last line
	bcs	A_E913			; branch if >= $16

	lda	TblScrLinesLB+1,X	; get the start of the next line
					; pointer LB
	sta	SAL			; save the next line pointer LB

	lda	LDTB1+1,X		; get the start of the next line
					; pointer HB
	jsr	ShiftLineUpDwn		; shift the screen line up	[E9C8]
	bmi	A_E8FF			; loop, branch always

A_E913					;				[E913]
	jsr	ClearLineX		; clear screen line X		[E9FF]

; now shift up the start of logical line bits
	ldx	#$00			; clear index
A_E918					;				[E918]
	lda	LDTB1,X			; get start of line X pointer HB
	and	#$7F			; clear line X start of logical line bit

	ldy	LDTB1+1,X		; get the start of the next line
					; pointer HB
	bpl	A_E922			; if next line is not a start of line
					; skip the start set
	ora	#$80			; set line X start of logical line bit
A_E922					;				[E922]
	sta	LDTB1,X			; set start of line X pointer HB

	inx				; increment line number
	cpx	#$18			; compare with last line
	bne	A_E918			; loop if not last line

	lda	LDTB1+$18		; start of last line pointer HB
	ora	#$80			; mark as start of logical line
	sta	LDTB1+$18

	lda	LDTB1			; start of first line pointer HB
	bpl	A_E8F6			; if not start of logical line loop back
					; and scroll the screen up another line

	inc	PhysCurRow		; increment the cursor row
	inc	TmpLineScrl		; increment screen row marker

	lda	#$7F			; set keyboard column c7
	sta	CIA1DRA			; save CIA 1 DRA, keyboard column drive

	lda	CIA1DRB			; read CIA 1 DRB, keyboard row port
	cmp	#$FB			; compare with row r2 active, [CTL]

	php				; save status

	lda	#$7F			; set keyboard column c7
	sta	CIA1DRA			; save CIA 1 DRA, keyboard column drive

	plp				; restore status
	bne	A_E956			; skip delay if ??

; first time round the inner loop X will be $16
	ldy	#$00			; clear delay outer loop count, do this
					; 256 times
A_E94D					;				[E94D]
	nop				; waste cycles

	dex				; decrement inner loop count
	bne	A_E94D			; loop if not all done

	dey				; decrement outer loop count
	bne	A_E94D			; loop if not all done

	sty	NDX			; clear the keyboard buffer index
A_E956					;				[E956]
	ldx	PhysCurRow		; get the cursor row

; restore the tape buffer pointers and exit

RestrTapBufPtr				;				[E958]
	pla				; pull tape buffer end pointer
	sta	EAL+1			; restore it

	pla				; pull tape buffer end pointer
	sta	EAL			; restore it

	pla				; pull tape buffer pointer
	sta	SAL+1			; restore it

	pla				; pull tape buffer pointer
	sta	SAL			; restore it

	rts


;******************************************************************************
;
; open up a space on the screen

InsertLine				;				[E965]
	ldx	PhysCurRow		; get the cursor row
InsertLine2				;				[E967]
	inx				; increment the row
	lda	LDTB1,X			; get start of line X pointer HB
	bpl	InsertLine2		; loop if not start of logical line

	stx	TmpLineScrl		; save the screen row marker

	cpx	#$18			; compare it with the last line
	beq	A_E981			; if = last line go ??

	bcc	A_E981			; if < last line go ??

; else it was > last line
	jsr	ScrollScreen		; scroll the screen		[E8EA]

	ldx	TmpLineScrl		; get the screen row marker
	dex				; decrement the screen row marker

	dec	PhysCurRow		; decrement the cursor row

	jmp	AddRow2CurLine		; add this row to the current logical
					; line and return		[E6DA]
A_E981					;				[E981]
	lda	SAL			; copy tape buffer pointer
	pha				; save it

	lda	SAL+1			; copy tape buffer pointer
	pha				; save it

	lda	EAL			; copy tape buffer end pointer
	pha				; save it

	lda	EAL+1			; copy tape buffer end pointer
	pha				; save it

	ldx	#$19			; set to end line + 1 for predecrement
					; loop
A_E98F					;				[E98F]
	dex				; decrement the line number

	jsr	FetchScreenAddr		; fetch a screen address	[E9F0]
	cpx	TmpLineScrl		; compare it with the screen row marker
	bcc	A_E9A6			; if < screen row marker go ??

	beq	A_E9A6			; if = screen row marker go ??

	lda	TblScrLinesLB-1,X	; else get the start of the previous
					; line LB from the ROM table
	sta	SAL			; save previous line pointer LB

	lda	LDTB1-1,X		; get the start of the previous line
					; pointer HB
	jsr	ShiftLineUpDwn		; shift the screen line down	[E9C8]
	bmi	A_E98F			; loop, branch always

A_E9A6					;				[E9A6]
	jsr	ClearLineX		; clear screen line X		[E9FF]

	ldx	#$17			;.
A_E9AB					;				[E9AB]
	cpx	TmpLineScrl		; compare it with the screen row marker
	bcc	A_E9BF			;.

	lda	LDTB1+1,X		;.
	and	#$7F			;.

	ldy	LDTB1,X			; get start of line X pointer HB
	bpl	A_E9BA			;.

	ora	#$80			;.
A_E9BA					;				[E9BA]
	sta	LDTB1+1,X		;.

	dex				;.
	bne	A_E9AB			;.

A_E9BF					;				[E9BF]
	ldx	TmpLineScrl		; get the screen row marker
	jsr	AddRow2CurLine		; add this row to current logical line
					;				[E6DA]
	jmp	RestrTapBufPtr		; restore tape buffer pointers and exit
					;				[E958]

;******************************************************************************
;
; shift screen line up/down

ShiftLineUpDwn				;				[E9C8]
	and	#$03			; mask 0000 00xx, line memory page
	ora	HIBASE			; OR with screen memory page
	sta	SAL+1			; save next/previous line pointer HB

	jsr	PtrLineColRAM		; calculate pointers to screen lines
					; colour RAM			[E9E0]
	ldy	#$27			; set the column count
A_E9D4					;				[E9D4]
	lda	(SAL),Y			; get character from next/previous
					; screen line
	sta	(CurScrLine),Y		; save character to current screen line

	lda	(EAL),Y			; get colour from next/previous screen
					; line colour RAM
	sta	(ColorRamPtr),Y		; save colour to current screen line
					; colour RAM
	dey				; decrement column index/count
	bpl	A_E9D4			; loop if more to do

	rts


;******************************************************************************
;
; calculate pointers to screen lines colour RAM

PtrLineColRAM				;				[E9E0]
	jsr	PtrCurLineColRAM	; calculate the pointer to the current
					; screen line colour RAM	[EA24]
	lda	SAL			; get the next screen line pointer LB
	sta	EAL			; save the next screen line colour RAM
					; pointer LB
	lda	SAL+1			; get the next screen line pointer HB
	and	#$03			; mask 0000 00xx, line memory page
	ora	#>ColourRAM		; set  1101 01xx, colour memory page
	sta	EAL+1			; save the next screen line colour RAM
					; pointer HB
	rts


;******************************************************************************
;
; fetch a screen address

FetchScreenAddr				;				[E9F0]
	lda	TblScrLinesLB,X		; get the start of line LB from
					; the ROM table
	sta	CurScrLine		; set current screen line pointer LB

	lda	LDTB1,X			; get the start of line HB from
					; the RAM table
	and	#$03			; mask 0000 00xx, line memory page
	ora	HIBASE			; OR with the screen memory page
	sta	CurScrLine+1		; save current screen line pointer HB

	rts


;******************************************************************************
;
; clear screen line X

ClearLineX				;				[E9FF]
	ldy	#$27			; set number of columns to clear
	jsr	FetchScreenAddr		; fetch a screen address	[E9F0]

	jsr	PtrCurLineColRAM	; calculate pointer to colour RAM [EA24]
A_EA07					;				[EA07]
	jsr	SaveCurColour		; save current colour to colour RAM
					;				[E4DA]
	lda	#' '			; set [SPACE]
	sta	(CurScrLine),Y		; clear character in current screen line

	dey				; decrement index
	bpl	A_EA07			; loop if more to do

	rts


;******************************************************************************
;
; orphan byte

;S_EA12
	nop				; unused


;******************************************************************************
;
; print character A and colour X

PrntCharA_ColX				;				[EA13]
	tay				; copy the character

	lda	#$02			; set the count to $02, usually $14 ??
	sta	BLNCT			; save the cursor countdown

	jsr	PtrCurLineColRAM	; calculate pointer to colour RAM [EA24]
	tya				; get the character back


;******************************************************************************
;
; save the character and colour to the screen @ the cursor

OutCharCol2Scr				;				[EA1C]
	ldy	LineCurCol		; get the cursor column
	sta	(CurScrLine),Y		; save char from current screen line

	txa				; copy the colour to A
	sta	(ColorRamPtr),Y		; save to colour RAM

	rts


;******************************************************************************
;
; calculate the pointer to colour RAM

PtrCurLineColRAM			;				[EA24]
	lda	CurScrLine		; get current screen line pointer LB
	sta	ColorRamPtr		; save pointer to colour RAM LB

	lda	CurScrLine+1		; get current screen line pointer HB
	and	#$03			; mask 0000 00xx, line memory page
	ora	#>ColourRAM		; set  1101 01xx, colour memory page
	sta	ColorRamPtr+1		; save pointer to colour RAM HB

	rts


;******************************************************************************
;
; update the clock, flash the cursor, control the cassette and scan the
; keyboard

; IRQ vector

IRQ_vector				;				[EA31]
	jsr	IncrClock		; increment the real time clock	[FFEA]

	lda	BLNSW			; get cursor enable, $00 = flash cursor
	bne	A_EA61			; if flash not enabled skip the flash

	dec	BLNCT			; decrement the cursor timing countdown
	bne	A_EA61			; if not counted out skip the flash

	lda	#$14			; set the flash count
	sta	BLNCT			; save the cursor timing countdown

	ldy	LineCurCol		; get the cursor column

	lsr	BLNON			; shift b0 cursor blink phase into carry

	ldx	GDCOL			; get the colour under the cursor

	lda	(CurScrLine),Y		; get character from current screen line
	bcs	A_EA5C			; branch if cursor phase b0 was 1

	inc	BLNON			; set the cursor blink phase to 1

	sta	GDBLN			; save the character under the cursor

	jsr	PtrCurLineColRAM	; calculate the pointer to colour RAM
					;				[EA24]

	lda	(ColorRamPtr),Y		; get the colour RAM byte
	sta	GDCOL			; save the colour under the cursor

	ldx	COLOR			; get the current colour code
	lda	GDBLN			; get the character under the cursor
A_EA5C					;				[EA5C]
	eor	#$80			; toggle b7 of character under cursor
	jsr	OutCharCol2Scr		; save the character and colour to the
					; screen @ the cursor		[EA1C]
A_EA61					;				[EA61]
	lda	P6510			; read the 6510 I/O port
	and	#$10			; mask 000x 0000, cassette switch sense
	beq	A_EA71			; if the cassette sense is low skip the
					; motor stop
; the cassette sense was high, the switch was open, so turn off the motor and
; clear the interlock
	ldy	#$00			; clear Y
	sty	CAS1			; clear the tape motor interlock

	lda	P6510			; read the 6510 I/O port
	ora	#$20			; mask xx1x, turn off
					; the motor
	bne	A_EA79			; go save the port value, branch always

; the cassette sense was low so turn the motor on, perhaps
A_EA71					;				[EA71]
	lda	CAS1			; get the tape motor interlock
	bne	A_EA7B			; if the cassette interlock <> 0 don't
					; turn on motor

	lda	P6510			; read the 6510 I/O port
	and	#$1F			; mask xx0x, turn on
					; the motor
A_EA79					;				[EA79]
	sta	P6510			; save the 6510 I/O port
A_EA7B					;				[EA7B]
	jsr	ScanKeyboard2		; scan the keyboard		[EA87]

	lda	CIA1IRQ			; read CIA 1 ICR, clear the timer
					; interrupt flag

	pla				; pull Y
	tay				; restore Y

	pla				; pull X
	tax				; restore X

	pla				; restore A

	rti


;******************************************************************************
;
; scan keyboard performs the following ..
;
; 1)	check if key pressed, if not then exit the routine
;
; 2)	init I/O ports of CIA ?? for keyboard scan and set pointers to decode
;	table 1. clear the character counter
;
; 3)	set one line of port B low and test for a closed key on port A by
;	shifting the byte read from the port. if the carry is clear then a key
;	is closed so save the	count which is incremented on each shift. check
;	for shift/stop/cbm keys and flag if closed
;
; 4)	repeat step 3 for the whole matrix
;
; 5)	evaluate the SHIFT/CTRL/C= keys, this may change the decode table
;	selected
;
; 6)	use the key count saved in step 3 as an index into the table selected
;	in step 5
; 7)	check for key repeat operation
;
; 8)	save the decoded key to the buffer if first press or repeat

; scan the keyboard

ScanKeyboard2				;				[EA87]
	lda	#$00			; clear A
	sta	SHFLAG			; clear keyboard shift/control/c= flag

	ldy	#$40			; set no key
	sty	SFDX			; save which key

	sta	CIA1DRA			; clear CIA 1 DRA, keyboard column drive

	ldx	CIA1DRB			; read CIA 1 DRB, keyboard row port
	cpx	#$FF			; compare with all bits set
	beq	A_EAFB			; if no key pressed clear current key
					; and exit (does further BEQ to A_EBBA)
	tay				; clear the key count

	lda	#<TblStandardKeys	; get the decode table LB
	sta	KEYTAB			; save the keyboard pointer LB

	lda	#>TblStandardKeys	; get the decode table HB
	sta	KEYTAB+1		; save the keyboard pointer HB

	lda	#$FE			; set column 0 low
	sta	CIA1DRA			; save CIA 1 DRA, keyboard column drive
A_EAA8					;				[EAA8]
	ldx	#$08			; set the row count

	pha				; save the column
A_EAAB					;				[EAAB]
	lda	CIA1DRB			; read CIA 1 DRB, keyboard row port
	cmp	CIA1DRB			; compare it with itself
	bne	A_EAAB			; loop if changing

A_EAB3					;				[EAB3]
	lsr				; shift row to Cb
	bcs	A_EACC			; if no key closed on this row go do
					; next row
	pha				; save row

	lda	(KEYTAB),Y		; get character from decode table
	cmp	#$05			; there is no $05 key but the control
					; keys are all less than $05
	bcs	A_EAC9			; if not shift/control/c=/stop go save
					; key count
; else was shift/control/c=/stop key
	cmp	#$03			; compare with $03, stop
	beq	A_EAC9			; if stop go save key count and continue

; character is $01 - shift, $02 - c= or $04 - control
	ora	SHFLAG			; OR it with the keyboard
					; shift/control/c= flag
	sta	SHFLAG			; save keyboard shift/control/c= flag
	bpl	A_EACB			; skip save key, branch always

A_EAC9					;				[EAC9]
	sty	SFDX			; save key count
A_EACB					;				[EACB]
	pla				; restore row
A_EACC					;				[EACC]
	iny				; increment key count
	cpy	#$41			; compare with max+1
	bcs	A_EADC			; exit loop if >= max+1

; else still in matrix
	dex				; decrement row count
	bne	A_EAB3			; loop if more rows to do

	sec				; set carry for keyboard column shift
	pla				; restore the column
	rol				; shift the keyboard column
	sta	CIA1DRA			; save CIA 1 DRA, keyboard column drive
	bne	A_EAA8			; loop for next column, branch always

A_EADC					;				[EADC]
	pla				; dump the saved column
	jmp	(KEYLOG)		; evaluate the SHIFT/CTRL/C= keys

; key decoding continues here after the SHIFT/CTRL/C= keys are evaluated

DecodeKeys				;				[EAE0]
	ldy	SFDX			; get saved key count
	lda	(KEYTAB),Y		; get character from decode table
	tax				; copy character to X

	cpy	LSTX			; compare key count with last key count
	beq	A_EAF0			; if this key = current key, key held,
					; go test repeat
	ldy	#$10			; set the repeat delay count
	sty	DELAY			; save the repeat delay count
	bne	A_EB26			; branch always

A_EAF0					;				[EAF0]
	and	#$7F			; clear b7
	bit	RPTFLG			; test key repeat
	bmi	A_EB0D			; if repeat all go ??

	bvs	A_EB42			; if repeat none go ??

	cmp	#$7F			; compare with end marker
A_EAFB					;				[EAFB]
	beq	A_EB26			; if $00/end marker go save key to
					; buffer and exit
	cmp	#$14			; compare with [INSERT]/[DELETE]
	beq	A_EB0D			; if equal, go test for repeat

	cmp	#' '			; compare with [SPACE]
	beq	A_EB0D			; if [SPACE] go test for repeat

	cmp	#$1D			; compare with [CURSOR RIGHT]
	beq	A_EB0D			; if [CURSOR RIGHT] go test for repeat

	cmp	#$11			; compare with [CURSOR DOWN]
	bne	A_EB42			; if not [CURSOR DOWN] just exit

; was one of the cursor movement keys, insert/delete key or the space bar so
; always do repeat tests
A_EB0D					;				[EB0D]
	ldy	DELAY			; get the repeat delay counter
	beq	A_EB17			; if delay expired go ??

	dec	DELAY			; else decrement repeat delay counter
	bne	A_EB42			; if delay not expired go ??

; repeat delay counter has expired
A_EB17					;				[EB17]
	dec	KOUNT			; decrement the repeat speed counter
	bne	A_EB42			; branch if not expired

	ldy	#$04			; set for 4/60ths of a second
	sty	KOUNT			; save the repeat speed counter

	ldy	NDX			; get the keyboard buffer index
	dey				; decrement it
	bpl	A_EB42			; if the buffer isn't empty just exit

; else repeat the key immediately

; possibly save the key to the keyboard buffer. if there was no key pressed or
; the key was not found during the scan (possibly due to key bounce) then X
; will be $FF here

A_EB26					;				[EB26]
	ldy	SFDX			; get the key count
	sty	LSTX			; save it as the current key count

	ldy	SHFLAG			; get the keyboard shift/control/c= flag
	sty	LSTSHF			; save it as last keyboard shift pattern

	cpx	#$FF			; compare the character with the table
					; end marker or no key
	beq	A_EB42			; if it was the table end marker or no
					; key, just exit
	txa				; copy the character to A

	ldx	NDX			; get the keyboard buffer index
	cpx	XMAX			; compare it with keyboard buffer size
	bcs	A_EB42			; if the buffer is full just exit

	sta	KeyboardBuf,X		; save character to keyboard buffer

	inx				; increment the index
	stx	NDX			; save the keyboard buffer index
A_EB42					;				[EB42]
	lda	#$7F			; enable column 7 for the stop key
	sta	CIA1DRA			; save CIA 1 DRA, keyboard column drive

	rts


;******************************************************************************
;
; evaluate the SHIFT/CTRL/C= keys

ShftCtrlCbmKey				;				[EB48]
	lda	SHFLAG			; get the keyboard shift/control/c= flag
	cmp	#$03			; compare with [SHIFT][C=]
	bne	A_EB64			; if not [SHIFT][C=] go ??

	cmp	LSTSHF			; compare with last
	beq	A_EB42			; exit if still the same

	lda	MODE			; get the shift mode switch,
					; $00 = enabled, $80 = locked
	bmi	J_EB76			; if locked continue keyboard decode

; toggle text mode
	lda	VICRAM			; get start of character memory address
	eor	#$02			; toggle address b1
	sta	VICRAM			; save start of character memory address

	jmp	J_EB76			; continue the keyboard decode	[EB76]

; select keyboard table

A_EB64					;				[EB64]
	asl				; << 1
	cmp	#$08			; compare with [CTRL]
	bcc	A_EB6B			; if [CTRL] is not pressed skip the
					; index change
	lda	#$06			; else [CTRL] was pressed so make the
					; index = $06
A_EB6B					;				[EB6B]
	tax				; copy the index to X

	lda	D_EB79,X		; get decode table pointer LB
	sta	KEYTAB			; save decode table pointer LB

	lda	D_EB79+1,X		; get decode table pointer HB
	sta	KEYTAB+1		; save decode table pointer HB
J_EB76					;				[EB76]
	jmp	DecodeKeys		; continue the keyboard decode	[EAE0]


;******************************************************************************
;
; table addresses

D_EB79					;				[EB79]
.word	TblStandardKeys			; standard
.word	TblShiftKeys			; shift
.word	TblCbmKeys			; commodore
.word	TblControlKeys			; control


;******************************************************************************
;
; standard keyboard table

TblStandardKeys				;				[EB81]
.byte	$14,$0D,$1D,$88,$85,$86,$87,$11
.byte	$33,$57,$41,$34,$5A,$53,$45,$01
.byte	$35,$52,$44,$36,$43,$46,$54,$58
.byte	$37,$59,$47,$38,$42,$48,$55,$56
.byte	$39,$49,$4A,$30,$4D,$4B,$4F,$4E
.byte	$2B,$50,$4C,$2D,$2E,$3A,$40,$2C
.byte	$5C,$2A,$3B,$13,$01,$3D,$5E,$2F
.byte	$31,$5F,$04,$32,$20,$02,$51,$03
.byte	$FF

;	DEL	RETURN	CRSR RI	F7	F1	F3	F5	CRSR DO
;	3	w	a	4	z	s	e	L SHIFT
;	5	r	d	6	c	f	t	x
;	6	y	g	8	b	h	u	v
;	9	i	j	0	m	k	o	n
;	+	p	l	-	.	:	@	,
;	£	*	;	HOME	R SHIFT	=	^|	/
;	1	<-	CTRL	2	SPACE	CBM	q	STOP


; shifted keyboard table

TblShiftKeys				;				[EBC2]
.byte	$94,$8D,$9D,$8C,$89,$8A,$8B,$91
.byte	$23,$D7,$C1,$24,$DA,$D3,$C5,$01
.byte	$25,$D2,$C4,$26,$C3,$C6,$D4,$D8
.byte	$27,$D9,$C7,$28,$C2,$C8,$D5,$D6
.byte	$29,$C9,$CA,$30,$CD,$CB,$CF,$CE
.byte	$DB,$D0,$CC,$DD,$3E,$5B,$BA,$3C
.byte	$A9,$C0,$5D,$93,$01,$3D,$DE,$3F
.byte	$21,$5F,$04,$22,$A0,$02,$D1,$83
.byte	$FF

;	INST	RRETURN	CRSR LE	F8	F2	F4	F6	CRSR UP
;	#	W	A	$	Z	S	E	LE SHIFT
;	%	R	D	&	C	F	T	X
;	'	Y	G	(	B	H	U	V
;	)	I	J	0	M	K	O	N
;	cbm gr	P	L	cbm gr	>	[	cbm gr	<
;	cbm gr	cbm gr	[	CLR	R SHIFT	=	pi	?
;	!	<-	CTRL	"	SPACE	CBM	Q	RUN


; CBM key keyboard table

TblCbmKeys				;				[EC03]
.byte	$94,$8D,$9D,$8C,$89,$8A,$8B,$91
.byte	$96,$B3,$B0,$97,$AD,$AE,$B1,$01
.byte	$98,$B2,$AC,$99,$BC,$BB,$A3,$BD
.byte	$9A,$B7,$A5,$9B,$BF,$B4,$B8,$BE
.byte	$29,$A2,$B5,$30,$A7,$A1,$B9,$AA
.byte	$A6,$AF,$B6,$DC,$3E,$5B,$A4,$3C
.byte	$A8,$DF,$5D,$93,$01,$3D,$DE,$3F
.byte	$81,$5F,$04,$95,$A0,$02,$AB,$83
.byte	$FF

;	INST	RETURN	CRSR LE	F8	F2	F4	F6	CRSR UP
;	pink	cbm gr	cbm gr	grey 1	cbm gr	cbm gr	cbm gr	LE SHIFT
;	grey 2	cbm gr	cbm gr	ligreen	cbm gr	cbm gr	cbm gr	cbm gr
;	li blue	cbm gr	cbm gr	grey 3	cbm gr	cbm gr	cbm gr	cbm gr
;	)	cbm gr	cbm gr	0	cbm gr	cbm gr	cbm gr	cbm gr
;	cbm gr	cbm gr	cbm gr	cbm gr	>	[	cbm gr	<
;	cbm gr	cbm gr	]	CLR	R SHIFT	=	pi	?
;	orange	<-	CTRL	brown	SPACE	CBM	cbm gr	RUN


;******************************************************************************
;
; check for special character codes

ChkSpecCodes				;				[EC44]
	cmp	#'{swlc}'		; compare with [SWITCH TO LOWER CASE]
	bne	Chk4SpecChar		; if not equal, skip the switch

	lda	VICRAM			; get start of character memory address
	ora	#$02			; mask xx1x, set lower case characters
	bne	A_EC58			; go save the new value, branch always

; check for special character codes except fro switch to lower case

Chk4SpecChar				;				[EC4F]
	cmp	#'{swuc}'		; compare with [SWITCH TO UPPER CASE]
	bne	CheckShiftCbm		; if not [SWITCH TO UPPER CASE] go do
					; the [SHIFT]+[C=] key check
	lda	VICRAM			; get start of character memory address
	and	#$FD			; mask xx0x, set upper case characters
A_EC58					;				[EC58]
	sta	VICRAM			; save start of character memory address
A_EC5B					;				[EC5B]
	jmp	RestorRegsQuot		; restore the registers, set the quote
					; flag and exit	[E6A8]
; do the [SHIFT]+[C=] key check

CheckShiftCbm				;				[EC5E]
	cmp	#'{dish}'		; compare with disable [SHIFT][C=]
	bne	A_EC69			; if not disable [SHIFT][C=], skip set

	lda	#$80			; set to lock shift mode switch
	ora	MODE			; OR it with the shift mode switch
	bmi	A_EC72			; go save the value, branch always
A_EC69					;				[EC69]
	cmp	#'{ensh}'		; compare with enable [SHIFT][C=]
	bne	A_EC5B			; exit if not enable [SHIFT][C=]

	lda	#$7F			; set to unlock shift mode switch
	and	MODE			; AND it with the shift mode switch
A_EC72					;				[EC72]
	sta	MODE			; save the shift mode switch
					; $00 = enabled, $80 = locked
	jmp	RestorRegsQuot		; restore the registers, set the quote
					; flag and exit	[E6A8]

;******************************************************************************
;
; control keyboard table

TblControlKeys				;				[EC78]
.byte	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
.byte	$1C,$17,$01,$9F,$1A,$13,$05,$FF
.byte	$9C,$12,$04,$1E,$03,$06,$14,$18
.byte	$1F,$19,$07,$9E,$02,$08,$15,$16
.byte	$12,$09,$0A,$92,$0D,$0B,$0F,$0E
.byte	$FF,$10,$0C,$FF,$FF,$1B,$00,$FF
.byte	$1C,$FF,$1D,$FF,$FF,$1F,$1E,$FF
.byte	$90,$06,$FF,$05,$FF,$FF,$11,$FF
.byte	$FF


;******************************************************************************
;
; vic ii chip initialisation values

TblValuesVIC				;				[ECB9]
.byte	$00,$00				; sprite 0 x,y
.byte	$00,$00				; sprite 1 x,y
.byte	$00,$00				; sprite 2 x,y
.byte	$00,$00				; sprite 3 x,y
.byte	$00,$00				; sprite 4 x,y
.byte	$00,$00				; sprite 5 x,y
.byte	$00,$00				; sprite 6 x,y
.byte	$00,$00				; sprite 7 x,y
;+$10
.byte	$00				; sprites 0 to 7 x bit 8
.byte	$9B				; enable screen, enable 25 rows
					; vertical fine scroll and control
					; bit	function
					; ---	-------
					;  7	raster compare bit 8
					;  6	1 = enable extended color text
					;	 mode
					;  5	1 = enable bitmap graphics mode
					;  4	1 = enable screen, 0 = blank
					;	 screen
					;  3	1 = 25 row display, 0 = 24 row
					;	 display
					; 2-0	vertical scroll count
.byte	$37				; raster compare
.byte	$00				; light pen x
.byte	$00				; light pen y
.byte	$00				; sprite 0 to 7 enable
.byte	$08				; enable 40 column display
					; horizontal fine scroll and control
					; bit	function
					; ---	-------
					; 7-6	unused
					;  5	1 = vic reset, 0 = vic on
					;  4	1 = enable multicolor mode
					;  3	1 = 40 column display, 0 = 38
					;	 column display
					; 2-0	horizontal scroll count
.byte	$00				; sprite 0 to 7 y expand
.byte	$14				; memory control
					; bit	function
					; ---	-------
					; 7-4	video matrix base address
					; 3-1	character data base address
					;  0	unused
.byte	$0F				; clear all interrupts
					; interrupt flags
					;  7	1 = interrupt
					; 6-4	unused
					;  3	1 = light pen interrupt
					;  2	1 = sprite to sprite collision
					;	 interrupt
					;  1	1 = sprite to foreground
					;	 collision interrupt
					;  0	1 = raster compare interrupt
.byte	$00				; all vic IRQs disabeld
					; IRQ enable
					; bit	function
					; ---	-------
					; 7-4	unused
					;  3	1 = enable light pen
					;  2	1 = enable sprite to sprite
					;	 collision
					;  1	1 = enable sprite to foreground
					;	 collision
					;  0	1 = enable raster compare
.byte	$00				; sprite 0 to 7 foreground priority
.byte	$00				; sprite 0 to 7 multicolour
.byte	$00				; sprite 0 to 7 x expand
.byte	$00				; sprite 0 to 7 sprite collision
.byte	$00				; sprite 0 to 7 foreground collision
;+$20
.byte	$0E				; border colour
.byte	$06				; background colour 0
.byte	$01				; background colour 1
.byte	$02				; background colour 2
.byte	$03				; background colour 3
.byte	$04				; sprite multicolour 0
.byte	$00				; sprite multicolour 1
.byte	$01				; sprite 0 colour
.byte	$02				; sprite 1 colour
.byte	$03				; sprite 2 colour
.byte	$04				; sprite 3 colour
.byte	$05				; sprite 4 colour
.byte	$06				; sprite 5 colour
.byte	$07				; sprite 6 colour
;	.byte	$4C			; sprite 7 colour, actually the first
					; character of "LOAD"


;******************************************************************************
;
; keyboard buffer for auto load/run

TblAutoLoadRun				;				[ECE7]
.text	"load{cr}run{cr}"


;******************************************************************************
;
; LBs of screen line addresses

TblScrLinesLB				;				[ECF0]
.byte	$00,$28,$50,$78,$A0
.byte	$C8,$F0,$18,$40,$68
.byte	$90,$B8,$E0,$08,$30
.byte	$58,$80,$A8,$D0,$F8
.byte	$20,$48,$70,$98,$C0


;******************************************************************************
;
; command serial bus device to TALK

CmdTALK2				;				[ED09]
	ora	#$40			; OR with the TALK command
.byte	$2C				; makes next line BIT $xx20


;******************************************************************************
;
; command devices on the serial bus to LISTEN

CmdLISTEN2				;				[ED0C]
	ora	#$20			; OR with the LISTEN command
	jsr	IsRS232Idle		; check RS232 bus idle		[F0A4]


;******************************************************************************
;
; send a control character

SendCtrlChar				;				[ED11]
	pha				; save device address

	bit	C3PO			; test deferred character flag
	bpl	A_ED20			; if no defered character continue

	sec				; else flag EOI
	ror	TEMPA3			; rotate into EOI flag byte

	jsr	IecByteOut22		; Tx byte on serial bus		[ED40]

	lsr	C3PO			; clear deferred character flag
	lsr	TEMPA3			; clear EOI flag
A_ED20					;				[ED20]
	pla				; restore the device address
	sta	BSOUR			; save as serial defered character

	sei				; disable the interrupts

	jsr	IecDataH		; set the serial data out high	[EE97]
	cmp	#$3F			; compare read byte with $3F
	bne	A_ED2E			; branch if not $3F, this branch will
					; always be taken as after CIA 2's PCR
					; is read it is ANDed with $DF, so the
					; result can never be $3F ??

	jsr	IecClockH		; set the serial clock out high	[EE85]
A_ED2E					;				[ED2E]
	lda	CIA2DRA			; read CIA 2 DRA, serial port and video
					; address
	ora	#$08			; mask 1xxx, set serial ATN low
	sta	CIA2DRA			; save CIA 2 DRA, serial port and video
					; address

; if the code drops through to here the serial clock is low and the serial data
; has been released so the following code will have no effect apart from
; delaying the first byte by 1ms

; set the serial clk/data, wait and Tx byte on the serial bus

PrepareIEC				;				[ED36]
	sei				; disable the interrupts

	jsr	IecClockL		; set the serial clock out low	[EE8E]
	jsr	IecDataH		; set the serial data out high	[EE97]
	jsr	Wait1ms			; 1ms delay			[EEB3]


;******************************************************************************
;
; Tx byte on serial bus

IecByteOut22				;				[ED40]
	sei				; disable the interrupts

	jsr	IecDataH		; set the serial data out high	[EE97]

	jsr	IecData2Carry		; get serial data status in Cb	[EEA9]
	bcs	A_EDAD			; if the serial data is high go do
					;'device not present'
	jsr	IecClockH		; set the serial clock out high	[EE85]

	bit	TEMPA3			; test the EOI flag
	bpl	A_ED5A			; if not EOI go ??

; I think this is the EOI sequence so the serial clock has been released and
; the serial data is being held low by the peripheral. first up wait for the
; serial data to rise

A_ED50					;				[ED50]
	jsr	IecData2Carry		; get serial data status in Cb	[EEA9]
	bcc	A_ED50			; loop if the data is low

; now the data is high, EOI is signalled by waiting for at least 200us without
; pulling the serial clock line low again. the listener should respond by
; pulling the serial data line low

A_ED55					;				[ED55]
	jsr	IecData2Carry		; get serial data status in Cb	[EEA9]
	bcs	A_ED55			; loop if the data is high

; the serial data has gone low ending the EOI sequence, now just wait for the
; serial data line to go high again or, if this isn't an EOI sequence, just
; wait for the serial data to go high the first time

A_ED5A					;				[ED5A]
	jsr	IecData2Carry		; get serial data status in Cb	[EEA9]
	bcc	A_ED5A			; loop if the data is low

; serial data is high now pull the clock low, preferably within 60us

	jsr	IecClockL		; set the serial clock out low	[EE8E]

; now the C64 has to send the eight bits, LSB first. first it sets the serial
; data line to reflect the bit in the byte, then it sets the serial clock to
; high. The serial clock is left high for 26 cycles, 23us on a PAL Vic, before
; it is again pulled low and the serial data is allowed high again

	lda	#$08			; eight bits to do
	sta	CNTDN			; set serial bus bit count
A_ED66					;				[ED66]
	lda	CIA2DRA			; read CIA 2 DRA, serial port and video
					; address
	cmp	CIA2DRA			; compare it with itself
	bne	A_ED66			; if changed go try again

	asl				; shift the serial data into Cb
	bcc	A_EDB0			; if serial data is low, do serial bus
					; timeout
	ror	BSOUR			; rotate the transmit byte
	bcs	A_ED7A			; if the bit = 1 go set the serial data
					; out high
	jsr	IecDataL		; else set serial data out low	[EEA0]
	bne	A_ED7D			; continue, branch always
A_ED7A					;				[ED7A]
	jsr	IecDataH		; set the serial data out high	[EE97]
A_ED7D					;				[ED7D]
	jsr	IecClockH		; set the serial clock out high	[EE85]

	nop				; waste ..
	nop				; .. a ..
	nop				; .. cycle ..
	nop				; .. or two

	lda	CIA2DRA			; read CIA 2 DRA, serial port and video
					; address
	and	#$DF			; mask xx0x, set serial data out high
	ora	#$10			; mask xxx1, set serial clock out low
	sta	CIA2DRA			; save CIA 2 DRA, serial port and video
					; address
	dec	CNTDN			; decrement the serial bus bit count
	bne	A_ED66			; loop if not all done

; now all eight bits have been sent it's up to the peripheral to signal the
; byte was received by pulling the serial data low. this should be done within
; one milisecond

	lda	#$04			; wait for up to about 1ms
	sta	CIA1TI2H		; save CIA 1 timer B HB

	lda	#$19			; load timer B, timer B single shot,
					; start timer B
	sta	CIA1CTR2		; save CIA 1 CRB

	lda	CIA1IRQ			; read CIA 1 ICR
A_ED9F					;				[ED9F]
	lda	CIA1IRQ			; read CIA 1 ICR
	and	#$02			; mask 0000 00x0, timer A interrupt
	bne	A_EDB0			; if timer A interrupt, do serial bus
					; timeout
	jsr	IecData2Carry		; get serial data status in Cb	[EEA9]
	bcs	A_ED9F			; if the serial data is high go wait
					; some more
	cli				; enable the interrupts
	rts

; device not present

A_EDAD					;				[EDAD]
	lda	#$80			; error $80, device not present
.byte	$2C				; makes next line BIT $03A9

; timeout on serial bus

A_EDB0					;				[EDB0]
	lda	#$03			; error $03, read timeout, write timeout
SetIecStatus				;				[EDB2]
	jsr	AorIecStatus		; OR into serial status byte	[FE1C]

	cli				; enable the interrupts

	clc				; clear for branch
	bcc	A_EE03			; branch always


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

SAafterLISTEN2				;				[EDB9]
	sta	BSOUR			; save the defered Tx byte

	jsr	PrepareIEC		; set the serial clk/data, wait and Tx
					; the byte			[ED36]


;******************************************************************************
;
; set serial ATN high

IecAtnH					;				[EDBE]
	lda	CIA2DRA			; read CIA 2 DRA, serial port and video
					; address
	and	#$F7			; mask 0xxx, set serial ATN high
	sta	CIA2DRA			; save CIA 2 DRA, serial port and video
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

SAafterTALK2				;				[EDC7]
	sta	BSOUR			; save the defered Tx byte

	jsr	PrepareIEC		; set the serial clk/data, wait and Tx
					; the byte			[ED36]


;******************************************************************************
;
; wait for the serial bus end after send

Wait4IEC				; return address from patch 6:
	sei				; disable the interrupts

	jsr	IecDataL		; set the serial data out low	[EEA0]
	jsr	IecAtnH			; set serial ATN high		[EDBE]
	jsr	IecClockH		; set the serial clock out high	[EE85]
A_EDD6					;				[EDD6]
	jsr	IecData2Carry		; get serial data status in Cb	[EEA9]
	bmi	A_EDD6			; loop if the clock is high

	cli				; enable the interrupts
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

IecByteOut2				;				[EDDD]
	bit	C3PO			; test the deferred character flag
	bmi	A_EDE6			; if there is a defered character go
					; send it
	sec				; set carry
	ror	C3PO			; shift into the deferred character flag
	bne	A_EDEB			; save the byte and exit, branch always

A_EDE6					;				[EDE6]
	pha				; save the byte

	jsr	IecByteOut22		; Tx byte on serial bus		[ED40]

	pla				; restore the byte
A_EDEB					;				[EDEB]
	sta	BSOUR			; save the defered Tx byte

	clc				; flag ok

	rts


;******************************************************************************
;
; command serial bus to UNTALK

; this routine will transmit an UNTALK command on the serial bus. All devices
; previously set to TALK will stop sending data when this command is received.

IecUNTALK2				;				[EDEF]
	sei				; disable the interrupts

	jsr	IecClockL		; set the serial clock out low	[EE8E]

	lda	CIA2DRA			; read CIA 2 DRA, serial port and video
					; address
	ora	#$08			; mask 1xxx, set the serial ATN low
	sta	CIA2DRA			; save CIA 2 DRA, serial port and video
					; address
	lda	#$5F			; set the UNTALK command
.byte	$2C				; makes next line BIT $3FA9


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

IecUNLISTEN2				;				[EDFE]
	lda	#$3F			; set the UNLISTEN command
	jsr	SendCtrlChar		; send a control character	[ED11]

; ATN high, delay, clock high then data high

A_EE03					;				[EE03]
	jsr	IecAtnH			; set serial ATN high		[EDBE]

; 1ms delay, clock high then data high

ResetIEC				;				[EE06]
	txa				; save the device number
	ldx	#$0A			; short delay
A_EE09					;				[EE09]
	dex				; decrement the count
	bne	A_EE09			; loop if not all done

	tax				; restore the device number

	jsr	IecClockH		; set the serial clock out high	[EE85]
	jmp	IecDataH		; set serial data out high and return
					;				[EE97]

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

IecByteIn2				;				[EE13]
	sei				; disable the interrupts

	lda	#$00			; set 0 bits to do, will flag EOI on
					; timeout
	sta	CNTDN			; save the serial bus bit count

	jsr	IecClockH		; set the serial clock out high	[EE85]
A_EE1B					;				[EE1B]
	jsr	IecData2Carry		; get serial data status in Cb	[EEA9]
	bpl	A_EE1B			; loop if the serial clock is low

A_EE20					;				[EE20]
	lda	#$01			; set the timeout count HB
	sta	CIA1TI2H		; save CIA 1 timer B HB

	lda	#$19			; load timer B, timer B single shot,
					; start timer B
	sta	CIA1CTR2		; save CIA 1 CRB

	jsr	IecDataH		; set the serial data out high	[EE97]

	lda	CIA1IRQ			; read CIA 1 ICR
A_EE30					;				[EE30]
	lda	CIA1IRQ			; read CIA 1 ICR
	and	#$02			; mask 0000 00x0, timer A interrupt
	bne	A_EE3E			; if timer A interrupt go ??

	jsr	IecData2Carry		; get serial data status in Cb	[EEA9]
	bmi	A_EE30			; loop if the serial clock is low

	bpl	A_EE56			; else go set 8 bits to do, branch
					; always
; timer A timed out
A_EE3E					;				[EE3E]
	lda	CNTDN			; get the serial bus bit count
	beq	A_EE47			; if not already EOI then go flag EOI

	lda	#$02			; else error $02, read timeour
	jmp	SetIecStatus		; set the serial status and exit [EDB2]

A_EE47					;				[EE47]
	jsr	IecDataL		; set the serial data out low	[EEA0]
	jsr	IecClockH		; set the serial clock out high	[EE85]

	lda	#$40			; set EOI
	jsr	AorIecStatus		; OR into the serial status byte [FE1C]

	inc	CNTDN			; increment the serial bus bit count,
					; do error on the next timeout
	bne	A_EE20			; go try again, branch always

A_EE56					;				[EE56]
	lda	#$08			; set 8 bits to do
	sta	CNTDN			; save the serial bus bit count
A_EE5A					;				[EE5A]
	lda	CIA2DRA			; read CIA 2 DRA, serial port and video
					; address
	cmp	CIA2DRA			; compare it with itself
	bne	A_EE5A			; if changing go try again

	asl				; shift the serial data into the carry
	bpl	A_EE5A			; loop while the serial clock is low

	ror	TEMPA4			; shift data bit into receive byte
A_EE67					;				[EE67]
	lda	CIA2DRA			; read CIA 2 DRA, serial port and video
					; address
	cmp	CIA2DRA			; compare it with itself
	bne	A_EE67			; if changing go try again

	asl				; shift the serial data into the carry
	bmi	A_EE67			; loop while the serial clock is high

	dec	CNTDN			; decrement the serial bus bit count
	bne	A_EE5A			; loop if not all done

	jsr	IecDataL		; set the serial data out low	[EEA0]

	bit	STATUS			; test the serial status byte
	bvc	A_EE80			; if EOI not set, skip bus end sequence

	jsr	ResetIEC		; 1ms delay, clock high then data high
					;				[EE06]
A_EE80					;				[EE80]
	lda	TEMPA4			; get the receive byte

	cli				; enable the interrupts
	clc				; flag ok

	rts


;******************************************************************************
;
; set the serial clock out high

IecClockH				;				[EE85]
	lda	CIA2DRA			; read CIA 2 DRA, serial port and video
					; address
	and	#$EF			; mask xxx0, set serial clock out high
	sta	CIA2DRA			; save CIA 2 DRA, serial port and video
					; address

	rts


;******************************************************************************
;
; set the serial clock out low

IecClockL				;				[EE8E]
	lda	CIA2DRA			; read CIA 2 DRA, serial port and video
					; address
	ora	#$10			; mask xxx1, set serial clock out low
	sta	CIA2DRA			; save CIA 2 DRA, serial port and video
					; address
	rts


;******************************************************************************
;
; set the serial data out high

IecDataH				;				[EE97]
	lda	CIA2DRA			; read CIA 2 DRA, serial port and video
					; address
	and	#$DF			; mask xx0x, set serial data out high
	sta	CIA2DRA			; save CIA 2 DRA, serial port and video
					; address
	rts


;******************************************************************************
;
; set the serial data out low

IecDataL				;				[EEA0]
	lda	CIA2DRA			; read CIA 2 DRA, serial port and video
					; address
	ora	#$20			; mask xx1x, set serial data out low
	sta	CIA2DRA			; save CIA 2 DRA, serial port and video
					; address
	rts


;******************************************************************************
;
; get serial data status in Cb

IecData2Carry				;				[EEA9]
	lda	CIA2DRA			; read CIA 2 DRA, serial port and video
					; address
	cmp	CIA2DRA			; compare it with itself
	bne	IecData2Carry		; if changing got try again

	asl				; shift the serial data into Cb

	rts


;******************************************************************************
;
; 1ms delay

Wait1ms					;				[EEB3]
	txa				; save X
	ldx	#$B8			; set the loop count
A_EEB6					;				[EEB6]
	dex				; decrement the loop count
	bne	A_EEB6			; loop if more to do

	tax				; restore X

	rts


;******************************************************************************
;
; RS232 Tx NMI routine

RS232_TX_NMI				;				[EEBB]
	lda	BITTS			; get RS232 bit count
	beq	RS232_NextTx		; if zero go setup next RS232 Tx byte
					; and return
	bmi	A_EF00			; if -ve go do stop bit(s)

; else bit count is non zero and +ve
	lsr	RODATA			; shift RS232 output byte buffer

	ldx	#$00			; set $00 for bit = 0
	bcc	A_EEC8			; branch if bit was 0

	dex				; set $FF for bit = 1
A_EEC8					;				[EEC8]
	txa				; copy bit to A
	eor	ROPRTY			; EOR with RS232 parity byte
	sta	ROPRTY			; save RS232 parity byte

	dec	BITTS			; decrement RS232 bit count
	beq	A_EED7			; if RS232 bit count now zero go do
					; parity bit
; save bit and exit
A_EED1					;				[EED1]
	txa				; copy bit to A
	and	#$04			; mask 0000 0x00, RS232 Tx DATA bit
	sta	NXTBIT			; save the next RS232 data bit to send

	rts

; do RS232 parity bit, enters with RS232 bit count = 0

A_EED7					;				[EED7]
	lda	#$20			; mask 00x0 0000, parity enable bit
	bit	M51CDR			; test the pseudo 6551 command register
	beq	A_EEF2			; if parity disabled go ??

	bmi	A_EEFC			; if fixed mark or space parity go ??

	bvs	A_EEF6			; if even parity go ??

; else odd parity
	lda	ROPRTY			; get RS232 parity byte
	bne	A_EEE7			; if not zero leave parity bit = 0

A_EEE6					;				[EEE6]
	dex				; make parity bit = 1
A_EEE7					;				[EEE7]
	dec	BITTS			; decrement RS232 bit count, 1 stop bit

	lda	M51CTR			; get pseudo 6551 control register
	bpl	A_EED1			; if 1 stop bit save parity bit and exit

; else two stop bits ..
	dec	BITTS			; decrement RS232 bit count, 2 stop bits
	bne	A_EED1			; save bit and exit, branch always

; parity is disabled so the parity bit becomes the first, and possibly only,
; stop bit. to do this increment the bit count which effectively decrements the
; stop bit count.
A_EEF2					;				[EEF2]
	inc	BITTS			; increment RS232 bit count, = -1 stop
					; bit
	bne	A_EEE6			; set stop bit = 1 and exit

; do even parity
A_EEF6					;				[EEF6]
	lda	ROPRTY			; get RS232 parity byte
	beq	A_EEE7			; if parity zero leave parity bit = 0

	bne	A_EEE6			; else branch always

; fixed mark or space parity
A_EEFC					;				[EEFC]
	bvs	A_EEE7			; if fixed space parity leave parity
					; bit = 0
	bvc	A_EEE6			; else fixed mark parity make parity
					; bit = 1, branch always

; decrement stop bit count, set stop bit = 1 and exit. $FF is one stop bit, $FE
; is two stop bits

A_EF00					;				[EF00]
	inc	BITTS			; decrement RS232 bit count

	ldx	#$FF			; set stop bit = 1
	bne	A_EED1			; save stop bit and exit, branch always


;******************************************************************************
;
; setup next RS232 Tx byte

RS232_NextTx				;				[EF06]
	lda	M51CDR			; read the 6551 pseudo command register
	lsr				; handshake bit inot Cb
	bcc	A_EF13			; if 3 line interface go ??

	bit	CIA2DRB			; test CIA 2 DRB, RS232 port

	bpl	A_EF2E			; if DSR = 0 set DSR signal not present
					; and exit
	bvc	A_EF31			; if CTS = 0 set CTS signal not present
					; and exit
; was 3 line interface
A_EF13					;				[EF13]
	lda	#$00			; clear A
	sta	ROPRTY			; clear the RS232 parity byte
	sta	NXTBIT			; clear the RS232 next bit to send

	ldx	BITNUM			; get the number of bits to be
					; sent/received
	stx	BITTS			; set the RS232 bit count

	ldy	RODBE			; get the index to the Tx buffer start
	cpy	RODBS			; compare it with index of Tx buffer end
	beq	A_EF39			; if all done go disable T?? interrupt
					; and return
	lda	(ROBUF),Y		; else get a byte from the buffer
	sta	RODATA			; save it to RS232 output byte buffer

	inc	RODBE			; increment index of the Tx buffer start

	rts


;******************************************************************************
;
; set DSR signal not present

A_EF2E					;				[EF2E]
	lda	#$40			; set DSR signal not present
.byte	$2C				; makes next line BIT $10A9


;******************************************************************************
;
; set CTS signal not present

A_EF31					;				[EF31]
	lda	#$10			; set CTS signal not present
	ora	RSSTAT			; OR it with the RS232 status register
	sta	RSSTAT			; save the RS232 status register


;******************************************************************************
;
; disable timer A interrupt

A_EF39					;				[EF39]
	lda	#$01			; disable timer A interrupt


;******************************************************************************
;
; set CIA 2 ICR from A

Set_VIA2_ICR				;				[EF3B]
	sta	CIA2IRQ			; save CIA 2 ICR

	eor	ENABL			; EOR with RS-232 interrupt enable byte
	ora	#$80			; set the interrupts enable bit
	sta	ENABL			; save RS-232 interrupt enable byte
	sta	CIA2IRQ			; save CIA 2 ICR

	rts


;******************************************************************************
;
; compute bit count

CalcBitCounts				;				[EF4A]
	ldx	#$09			; set bit count to 8 data + 1 stop bit

	lda	#$20			; mask for 8/7 data bits
	bit	M51CTR			; test pseudo 6551 control register
	beq	A_EF54			; branch if 8 bits

	dex				; else decrement count for 7 data bits
A_EF54					;				[EF54]
	bvc	A_EF58			; branch if 7 bits

	dex				; else decrement count ..
	dex				; .. for 5 data bits
A_EF58					;				[EF58]
	rts


;******************************************************************************
;
; RS232 Rx NMI

RS232_RX_NMI				;				[EF59]
	ldx	RINONE			; get start bit check flag
	bne	A_EF90			; if no start bit received go ??

	dec	BITCI			; decrement receiver bit count in
	beq	A_EF97			; if the byte is complete go add it to
					; the buffer
	bmi	A_EF70			;.

	lda	INBIT			; get the RS232 received data bit
	eor	RIPRTY			; EOR with the receiver parity bit
	sta	RIPRTY			; save the receiver parity bit

	lsr	INBIT			; shift the RS232 received data bit
	ror	RIDATA			;.
A_EF6D					;				[EF6D]
	rts

A_EF6E					;				[EF6E]
	dec	BITCI			; decrement receiver bit count in
A_EF70					;				[EF70]
	lda	INBIT			; get the RS232 received data bit
	beq	A_EFDB			;.

	lda	M51CTR			; get pseudo 6551 control register
	asl				; shift the stop bit flag to Cb

	lda	#$01			; + 1
	adc	BITCI			; add receiver bit count in
	bne	A_EF6D			; exit, branch always


;******************************************************************************
;
; setup to receive an RS232 bit

SetupRS232_RX				;				[EF7E]
	lda	#$90			; enable FLAG interrupt
	sta	CIA2IRQ			; save CIA 2 ICR

	ora	ENABL			; OR with RS-232 interrupt enable byte
	sta	ENABL			; save RS-232 interrupt enable byte
	sta	RINONE			; set start bit check flag, set no start
					; bit received
	lda	#$02			; disable timer B interrupt
	jmp	Set_VIA2_ICR		; set CIA 2 ICR from A and return [EF3B]


;******************************************************************************
;
; no RS232 start bit received

A_EF90					;				[EF90]
	lda	INBIT			; get the RS232 received data bit
	bne	SetupRS232_RX		; if ?? go setup to receive an RS232
					; bit and return

	jmp	RS232_SaveSet		; flag RS232 start bit and set parity
					;				[E4D3]

;******************************************************************************
;
; received a whole byte, add it to the buffer

A_EF97					;				[EF97]
	ldy	RIDBE			; get index to Rx buffer end
	iny				; increment index
	cpy	RIDBS			; compare with index to Rx buffer start
	beq	A_EFCA			; if buffer full go do Rx overrun error

	sty	RIDBE			; save index to Rx buffer end

	dey				; decrement index

	lda	RIDATA			; get assembled byte

	ldx	BITNUM			; get bit count
A_EFA9					;				[EFA9]
	cpx	#$09			; compare with byte + stop
	beq	A_EFB1			; branch if all nine bits received

	lsr				; else shift byte

	inx				; increment bit count
	bne	A_EFA9			; loop, branch always

A_EFB1					;				[EFB1]
	sta	(RIBUF),Y		; save received byte to Rx buffer

	lda	#$20			; mask 00x0 0000, parity enable bit
	bit	M51CDR			; test the pseudo 6551 command register
	beq	A_EF6E			; branch if parity disabled

	bmi	A_EF6D			; branch if mark or space parity

	lda	INBIT			; get the RS232 received data bit
	eor	RIPRTY			; EOR with the receiver parity bit
	beq	A_EFC5			;.

	bvs	A_EF6D			; if ?? just exit

.byte	$2C				; makes next line BIT $xxxx
A_EFC5					;				[EFC5]
	bvc	A_EF6D			; if ?? just exit

	lda	#$01			; set Rx parity error
.byte	$2C				; makes next line BIT $04A9
A_EFCA					;				[EFCA]
	lda	#$04			; set Rx overrun error
.byte	$2C				; makes next line BIT NumericTestA9
A_EFCD					;				[EFCD]
	lda	#$80			; set Rx break error
.byte	$2C				; makes next line BIT $02A9
A_EFD0					;				[EFD0]
	lda	#$02			; set Rx frame error
	ora	RSSTAT			; OR it with the RS232 status byte
	sta	RSSTAT			; save the RS232 status byte

	jmp	SetupRS232_RX		; setup to receive an RS232 bit and
					; return			[EF7E]

A_EFDB					;				[EFDB]
	lda	RIDATA			;.
	bne	A_EFD0			; if ?? do frame error

	beq	A_EFCD			; else do break error, branch always


;******************************************************************************
;
; open RS232 channel for output

OpenRsChan4Out				;				[EFE1]
	sta	DFLTO			; save the output device number

	lda	M51CDR			; read the pseudo 6551 command register
	lsr				; shift handshake bit to carry
	bcc	A_F012			; if 3 line interface go ??

	lda	#$02			; mask 0000 00x0, RTS out
	bit	CIA2DRB			; test CIA 2 DRB, RS232 port
	bpl	DeactivateDSR		; if DSR=0 set DSR not present and exit

	bne	A_F012			; if RTS = 1 just exit

A_EFF2					;				[EFF2]
	lda	ENABL			; get RS-232 interrupt enable byte
	and	#$02			; mask 0000 00x0, timer B interrupt
	bne	A_EFF2			; loop while timer B interrupt is
					; enebled
A_EFF9					;				[EFF9]
	bit	CIA2DRB			; test CIA 2 DRB, RS232 port
	bvs	A_EFF9			; loop while CTS high

	lda	CIA2DRB			; read CIA 2 DRB, RS232 port
	ora	#$02			; mask xx1x, set RTS high
	sta	CIA2DRB			; save CIA 2 DRB, RS232 port
A_F006					;				[F006]
	bit	CIA2DRB			; test CIA 2 DRB, RS232 port
	bvs	A_F012			; exit if CTS high

	bmi	A_F006			; loop while DSR high

; set no DSR and exit

DeactivateDSR				;				[F00D]
	lda	#$40			; set DSR signal not present
	sta	RSSTAT			; save the RS232 status register
A_F012					;				[F012]
	clc				; flag ok

	rts


;******************************************************************************
;
; send byte to the RS232 buffer

A_F014					;				[F014]
	jsr	SetupRS232_TX		; setup for RS232 transmit	[F028]

; send byte to the RS232 buffer, no setup

Byte2RS232Buf				;				[F017]
	ldy	RODBS			; get index to Tx buffer end
	iny				; + 1
	cpy	RODBE			; compare with index to Tx buffer start
	beq	A_F014			; loop while buffer full

	sty	RODBS			; set index to Tx buffer end

	dey				; index to available buffer byte
	lda	PTR1			; read the RS232 character buffer
	sta	(ROBUF),Y		; save the byte to the buffer


;******************************************************************************
;
; setup for RS232 transmit

SetupRS232_TX				;				[F028]
	lda	ENABL			; get RS-232 interrupt enable byte
	lsr				; shift the enable bit to Cb
	bcs	A_F04C			; if interrupts are enabled just exit

	lda	#$10			; start timer A
	sta	CIA2CTR1		; save CIA 2 CRA

	lda	BAUDOF			; get the baud rate bit time LB
	sta	CIA2TI1L		; save CIA 2 timer A LB

	lda	BAUDOF+1		; get the baud rate bit time HB
	sta	CIA2TI1H		; save CIA 2 timer A HB

	lda	#$81			; enable timer A interrupt
	jsr	Set_VIA2_ICR		; set CIA 2 ICR from A		[EF3B]

	jsr	RS232_NextTx		; setup next RS232 Tx byte	[EF06]

	lda	#$11			; load timer A, start timer A
	sta	CIA2CTR1		; save CIA 2 CRA
A_F04C					;				[F04C]
	rts


;******************************************************************************
;
; input from RS232 buffer

InputRS232Buf				;				[F04D]
	sta	DFLTN			; save the input device number

	lda	M51CDR			; get pseudo 6551 command register
	lsr				; shift the handshake bit to Cb
	bcc	A_F07D			; if 3 line interface go ??

	and	#$08			; mask the duplex bit, pseudo 6551
					; command is >> 1
	beq	A_F07D			; if full duplex go ??

	lda	#$02			; mask 0000 00x0, RTS out
	bit	CIA2DRB			; test CIA 2 DRB, RS232 port
	bpl	DeactivateDSR		; if DSR = 0 set no DSR and exit

	beq	A_F084			; if RTS = 0 just exit

A_F062					;				[F062]
	lda	ENABL			; get RS-232 interrupt enable byte
	lsr				; shift the timer A interrupt enable
					; bit to Cb
	bcs	A_F062			; loop while the timer A interrupt is
					; enabled

	lda	CIA2DRB			; read CIA 2 DRB, RS232 port
	and	#$FD			; mask xx0x, clear RTS out
	sta	CIA2DRB			; save CIA 2 DRB, RS232 port
A_F070					;				[F070]
	lda	CIA2DRB			; read CIA 2 DRB, RS232 port
	and	#$04			; mask x1xx, DTR in
	beq	A_F070			; loop while DTR low

A_F077					;				[F077]
	lda	#$90			; enable the FLAG interrupt
	clc				; flag ok
	jmp	Set_VIA2_ICR		; set CIA 2 ICR from A and return [EF3B]

A_F07D					;				[F07D]
	lda	ENABL			; get RS-232 interrupt enable byte
	and	#$12			; mask 000x 00x0
	beq	A_F077			; if FLAG or timer B bits set go enable
					; the FLAG inetrrupt
A_F084					;				[F084]
	clc				; flag ok

	rts


;******************************************************************************
;
; get byte from RS232 buffer

GetBytRS232Buf				;				[F086]
	lda	RSSTAT			; get the RS232 status register

	ldy	RIDBS			; get index to Rx buffer start
	cpy	RIDBE			; compare with index to Rx buffer end
	beq	A_F09C			; return null if buffer empty

	and	#$F7			; clear the Rx buffer empty bit
	sta	RSSTAT			; save the RS232 status register

	lda	(RIBUF),Y		; get byte from Rx buffer

	inc	RIDBS			; increment index to Rx buffer start

	rts


A_F09C					;				[F09C]
	ora	#$08			; set the Rx buffer empty bit
	sta	RSSTAT			; save the RS232 status register

	lda	#$00			; return null
	rts


;******************************************************************************
;
; check RS232 bus idle

IsRS232Idle				;				[F0A4]
	pha				; save A
	lda	ENABL			; get RS-232 interrupt enable byte
	beq	A_F0BB			; if no interrupts enabled just exit

A_F0AA					;				[F0AA]
	lda	ENABL			; get RS-232 interrupt enable byte
	and	#$03			; mask 0000 00xx, the error bits
	bne	A_F0AA			; if there are errors loop

	lda	#$10			; disable FLAG interrupt
	sta	CIA2IRQ			; save CIA 2 ICR

	lda	#$00			; clear A
	sta	ENABL			; clear RS-232 interrupt enable byte
A_F0BB					;				[F0BB]
	pla				; restore A
	rts


;******************************************************************************
;
; kernel I/O messages

IO_ERROR .logical 0
TxtIO_ERROR				;				[F0BD]
.shift "{cr}i/o error #"

TxtSEARCHING				;				[F0C9]
.shift "{cr}searching "

TxtFOR					;				[F0D4]
.shift "for "

TxtPRESS_PLAY				;				[F0D8]
.shift "{cr}press play on tape"

TxtPRESS_RECO				;				[F0EB]
.shift "press record & play on tape"

TxtLOADING				;				[F106]
.shift "{cr}loading"

TxtSAVING				;				[F10E]
.shift "{cr}saving "

TxtVERIFYING				;				[F116]
.shift "{cr}verifying"

TxtFOUND				;				[F120]
.shift "{cr}found "

TxtOK2					;				[F127]
.shift "{cr}ok{cr}"
.here

;******************************************************************************
;
; display control I/O message if in direct mode

DisplayIoMsg				;				[F12B]
	bit	MSGFLG			; test message mode flag
	bpl	A_F13C			; exit if control messages off

; display kernel I/O message

DisplayIoMsg2				;				[F12F]
	lda	IO_ERROR,Y		; get byte from message table
	php				; save status
	and	#$7F			; clear b7
	jsr	OutByteChan		; output character to channel	[FFD2]

	iny				; increment index

	plp				; restore status
	bpl	DisplayIoMsg2		; loop if not end of message

A_F13C					;				[F13C]
	clc				;.

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

GetByteInpDev				;				[F13E]
	lda	DFLTN			; get the input device number
	bne	A_F14A			; if not the keyboard go handle other
					; devices
; the input device was the keyboard
	lda	NDX			; get the keyboard buffer index
	beq	A_F155			; if the buffer is empty go flag no
					; byte and return
	sei				; disable the interrupts

	jmp	GetCharKeybBuf		; get input from the keyboard buffer
					; and return			[E5B4]

; the input device was not the keyboard
A_F14A					;				[F14A]
	cmp	#$02			; compare device with the RS232 device
	bne	A_F166			; if not the RS232 device, ->

; the input device is the RS232 device
GetByteInpDev2				;				[F14E]
	sty	TEMP97			; save Y

	jsr	GetBytRS232Buf		; get a byte from RS232 buffer	[F086]

	ldy	TEMP97			; restore Y
A_F155					;				[F155]
	clc				; flag no error

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

ByteFromChan2				;				[F157]
	lda	DFLTN			; get the input device number
	bne	A_F166			; if not the keyboard continue

; the input device was the keyboard
	lda	LineCurCol		; get the cursor column
	sta	CursorCol		; set the input cursor column

	lda	PhysCurRow		; get the cursor row
	sta	CursorRow		; set the input cursor row

	jmp	InputScrKeyb		; input from screen or keyboard	[E632]

; the input device was not the keyboard
A_F166					;				[F166]
	cmp	#$03			; compare device number with screen
	bne	A_F173			; if not screen continue

; the input device was the screen
	sta	CRSW			; input from keyboard or screen,
					;$xx = screen,
					; $00 = keyboard
	lda	CurLineLeng		; get current screen line length
	sta	INDX			; save input [EOL] pointer

	jmp	InputScrKeyb		; input from screen or keyboard	[E632]

; the input device was not the screen
A_F173					;				[F173]
	bcs	A_F1AD			; if input device > screen, do IEC
					; devices
; the input device was < screen

	cmp	#$02			; compare device with the RS232 device
	beq	A_F1B8			; if RS232 device, go get a byte from
					; the RS232 device

; only the tape device left ..
	stx	TEMP97			; save X

	jsr	GetByteTape		; get a byte from tape		[F199]
	bcs	A_F196			; if error just exit

	pha				; save the byte

	jsr	GetByteTape		; get the next byte from tape	[F199]
	bcs	A_F193			; if error just exit

	bne	A_F18D			; if end reached ??

	lda	#$40			; set EOI
	jsr	AorIecStatus		; OR into the serial status byte [FE1C]
A_F18D					;				[F18D]
	dec	BUFPNT			; decrement tape buffer index

	ldx	TEMP97			; restore X

	pla				; restore the saved byte
	rts

; error exit from input character

A_F193					;				[F193]
	tax				; copy the error byte

	pla				; dump the saved byte
	txa				; restore error byte
A_F196					;				[F196]
	ldx	TEMP97			; restore X
	rts


;******************************************************************************
;
; get byte from tape

GetByteTape				;				[F199]
	jsr	BumpTapePtr		; bump tape pointer		[F80D]
	bne	A_F1A9			; if not end get next byte and exit

	jsr	InitTapeRead		; initiate tape read		[F841]
	bcs	A_F1B4			; exit if error flagged

	lda	#$00			; clear A
	sta	BUFPNT			; clear tape buffer index
	beq	GetByteTape		; loop, branch always

A_F1A9					;				[F1A9]
	lda	(TapeBufPtr),Y		; get next byte from buffer

	clc				; flag no error

	rts

; input device was serial bus
A_F1AD					;				[F1AD]
	lda	STATUS			; get the serial status byte
	beq	A_F1B5			; if no errors flagged go input byte
					; and return
A_F1B1					;				[F1B1]
	lda	#'{cr}'			; else return [EOL]
A_F1B3					;				[F1B3]
	clc				; flag no error
A_F1B4					;				[F1B4]
	rts

A_F1B5					;				[F1B5]
	jmp	IecByteIn2		; input byte from serial bus and return
					;				[EE13]
; input device was RS232 device
A_F1B8					;				[F1B8]
	jsr	GetByteInpDev2		; get byte from RS232 device	[F14E]
	bcs	A_F1B4			; branch if error, this doesn't get
					; taken as the last instruction in the
					; get byte from RS232 device routine
					; is CLC ??
	cmp	#$00			; compare with null
	bne	A_F1B3			; exit if not null

	lda	RSSTAT			; get the RS232 status register
	and	#$60			; mask 0xx0 0000, DSR detected and ??
	bne	A_F1B1			; if ?? return null

	beq	A_F1B8			; else loop, branch always


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

OutByteChan2				;				[F1CA]
	pha				; save the character to output

	lda	DFLTO			; get the output device number
S_F1CD
	cmp	#$03			; compare the output device with screen
	bne	A_F1D5			; if not the screen go ??

; the output device is the screen
	pla				; else restore the output character
	jmp	OutputChar		; go output the character to the screen
					;				[E716]

; the output device was not the screen
A_F1D5					;				[F1D5]
	bcc	OutByteChan2b		; if < screen go ??

; the output device was > screen so it is a serial bus device
	pla				; else restore the output character
	jmp	IecByteOut2		; go output the character to the serial
					; bus				[EDDD]

; the output device is < screen
OutByteChan2b				;				[F1DB]
	lsr				; shift b0 of the device into Cb

	pla				; restore the output character


;******************************************************************************
;
; output the character to the cassette or RS232 device

OutByteCasRS				;				[F1DD]
	sta	PTR1			; save character to character buffer

	txa				; copy X
	pha				; save X

	tya				; copy Y
	pha				; save Y

	bcc	A_F208			; if Cb is clear it must be RS232 device

; output the character to the cassette

	jsr	BumpTapePtr		; bump the tape pointer		[F80D]
	bne	A_F1F8			; if not end save next byte and exit

	jsr	InitTapeWrite		; initiate tape write		[F864]
	bcs	A_F1FD			; exit if error

	lda	#$02			; set data block type ??
	ldy	#$00			; clear index
	sta	(TapeBufPtr),Y		; save type to buffer ??

	iny				; increment index
	sty	BUFPNT			; save tape buffer index
A_F1F8					;				[F1F8]
	lda	PTR1			; restore char from character buffer
	sta	(TapeBufPtr),Y		; save to buffer
J_F1FC					;				[F1FC]
	clc				; flag no error
A_F1FD					;				[F1FD]
	pla				; pull Y
	tay				; restore Y

	pla				; pull X
	tax				; restore X

	lda	PTR1			; get character from character buffer
	bcc	A_F207			; exit if no error

	lda	#$00			; else clear A
A_F207					;				[F207]
	rts

; output the character to the RS232 device
A_F208					;				[F208]
	jsr	Byte2RS232Buf		; send byte to RS232 buffer, no setup
					;				[F017]
	jmp	J_F1FC			; do no error exit		[F1FC]


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
;	3 : file not open
;	5 : device not present
;	6 : file is not an input file

OpenChanInput				;				[F20E]
	jsr	FindFile		; find a file			[F30F]
	beq	A_F216			; if the file is open continue

	jmp	FileNotOpenErr		; else do 'file not open' error and
					; return			[F701]
A_F216					;				[F216]
	jsr	SetFileDetails		; set file details from table,X	[F31F]
S_F219
	lda	FA			; get the device number
	beq	A_F233			; if the device was the keyboard save
					; the device #, flag ok and exit
	cmp	#$03			; compare device number with screen
	beq	A_F233			; if the device was the screen save the
					; device #, flag ok and exit
	bcs	A_F237			; if device was a serial bus device, ->

	cmp	#$02			; RS232?
	bne	A_F22A			; no, -> tape

	jmp	InputRS232Buf		; else go get input from the RS232
					; buffer and return		[F04D]
; Handle tape
A_F22A					;				[F22A]
	ldx	SA			; get the secondary address
	cpx	#$60			;.
	beq	A_F233			;.

	jmp	NoInputFileErr		; go do 'not input file' error and
					; return			[F70A]

A_F233					;				[F233]
	sta	DFLTN			; save the input device number

	clc				; flag ok

	rts

; the device was a serial bus device
A_F237					;				[F237]
	tax				; copy device number to X
	jsr	CmdTALK2		; command serial device to TALK	[ED09]

	lda	SA			; get the secondary address
	bpl	A_F245			;.

	jsr	Wait4IEC		; wait for the serial bus end after
					; send				[EDCC]
	jmp	A_F248			;				[F248]

A_F245					;				[F245]
	jsr	SAafterTALK2		; send secondary address after TALK
					;				[EDC7]
A_F248					;				[F248]
	txa				; copy device back to A
	bit	STATUS			; test the serial status byte
	bpl	A_F233			; if device present save device number
					; and exit
	jmp	DevNotPresent		; do 'device not present' error and
					; return			[F707]

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
;	3 : file not open
;	5 : device not present
;	7 : file is not an output file

OpenChanOutput				;				[F250]
	jsr	FindFile		; find a file			[F30F]
	beq	A_F258			; if file found continue

	jmp	FileNotOpenErr		; else do 'file not open' error and
					; return			[F701]

A_F258					;				[F258]
	jsr	SetFileDetails		; set file details from table,X	[F31F]
S_F25B
	lda	FA			; get the device number
	bne	A_F262			; if not the keyboard, ->
A_F25F					;				[F25F]
	jmp	NoOutpFileErr		; go do 'not output file' error and
					; return			[F70D]
A_F262					;				[F262]
	cmp	#$03			; compare the device with the screen
	beq	A_F275			; if device is screen go save output
					; device number and exit
	bcs	A_F279			; if > screen then go handle a serial
					; bus device
	cmp	#$02			; RS232?
	bne	A_F26F			; no, -> tape

	jmp	OpenRsChan4Out		; else go open RS232 channel for output
					;				[EFE1]
; open a tape channel for output
A_F26F					;				[F26F]
	ldx	SA			; get the secondary address
	cpx	#$60			;.
	beq	A_F25F			; if ?? do not output file error and
					; return
A_F275					;				[F275]
	sta	DFLTO			; save the output device number

	clc				; flag ok

	rts

; open an IEC channel for output
A_F279					;				[F279]
	tax				; copy the device number
	jsr	CmdLISTEN2		; command devices on the serial bus to
					; LISTEN			[ED0C]

	lda	SA			; get the secondary address
	bpl	A_F286			; if address to send go ??

	jsr	IecAtnH			; else set serial ATN high	[EDBE]
	bne	A_F289			; go ??, branch always
A_F286					;				[F286]
	jsr	SAafterLISTEN2		; send secondary address after LISTEN
					;				[EDB9]
A_F289					;				[F289]
	txa				; copy device number back to A
	bit	STATUS			; test the serial status byte
	bpl	A_F275			; if device is present go save output
					; device number and exit
	jmp	DevNotPresent		; else do 'device not present error'
					; and return			[F707]

;******************************************************************************
;
; close a specified logical file

; this routine is used to close a logical file after all I/O operations have
; been completed on that file. This routine is called after the accumulator is
; loaded with the logical file number to be closed, the same number used when
; the file was opened using the OPEN routine.

CloseLogFile2				;				[F291]
	jsr	FindFileA		; find file A			[F314]
	beq	A_F298			; if file found go close it

	clc				; else file was closed so just flag ok
	rts

; file found so close it
A_F298					;				[F298]
	jsr	SetFileDetails		; set file details from table,X	[F31F]
	txa				; copy file index to A
	pha				; save file index
S_F29D
	lda	FA			; get the device number
	beq	J_F2F1			; if it is keyboard go restore index
					; and close the file
	cmp	#$03			; compare device number with screen
	beq	J_F2F1			; if it is the screen go restore the
					; index and close the file
	bcs	A_F2EE			; if > screen, do serial device close

	cmp	#$02			; compare device with RS232 device
	bne	A_F2C8			; if not the RS232 device go to tape

; else close RS232 device
	pla				; restore file index
	jsr	ClosFileIndxX		; close file index X		[F2F2]

	jsr	InitRS232_TX		; initialise RS232 output	[F483]
	jsr	ReadTopOfMem		; read the top of memory	[FE27]

	lda	RIBUF+1			; get RS232 input buffer pointer HB
	beq	A_F2BA			; if no RS232 input buffer go ??

	iny				; else reclaim RS232 input buffer memory
A_F2BA					;				[F2BA]
	lda	ROBUF+1			; get RS232 output buffer pointer HB
	beq	A_F2BF			; if no RS232 output buffer skip reclaim

	iny				; else reclaim RS232 output buf memory
A_F2BF					;				[F2BF]
	lda	#$00			; clear A
	sta	RIBUF+1			; clear RS232 input buffer pointer HB
	sta	ROBUF+1			; clear RS232 output buffer pointer HB

	jmp	SetTopOfMem		; go set top of memory to F0xx	[F47D]

; is not the RS232 device
A_F2C8					;				[F2C8]
	lda	SA			; get the secondary address
	and	#$0F			; mask the device #
	beq	J_F2F1			; if ?? restore index and close file

	jsr	TapeBufPtr2XY		; get tape buffer start pointer in XY
					;				[F7D0]
	lda	#$00			; character $00
	sec				; flag the tape device
	jsr	OutByteCasRS		; output the character to the cassette
					; or RS232 device		[F1DD]
	jsr	InitTapeWrite		; initiate tape write		[F864]
	bcc	A_F2E0			;.

	pla				;.

	lda	#$00			;.
	rts

A_F2E0					;				[F2E0]
	lda	SA			; get the secondary address
	cmp	#$62			;.
	bne	J_F2F1			; if not ?? restore index and close file

	lda	#$05			; set logical end of the tape
	jsr	WriteTapeHdr		; write tape header		[F76A]

	jmp	J_F2F1			; restore index and close file	[F2F1]


;******************************************************************************
;
; serial bus device close

A_F2EE					;				[F2EE]
	jsr	CloseIecDevice		; close serial bus device	[F642]
J_F2F1					;				[F2F1]
	pla				; restore file index


;******************************************************************************
;
; close file index X

ClosFileIndxX				;				[F2F2]
	tax				; copy index to file to close

	dec	LDTND			; decrement the open file count

	cpx	LDTND			; compare index with open file count
	beq	A_F30D			; exit if equal, last entry was closing
					; file
; else entry was not last in list so copy last table entry file details over
; the details of the closing one
	ldy	LDTND			; get the open file count as index
	lda	LogFileTbl,Y		; get last+1 logical file number from
					; logical file table
	sta	LogFileTbl,X		; save logical file number over closed
					; file
	lda	DevNumTbl,Y		; get last+1 device number from device
					; number table
	sta	DevNumTbl,X		; save device number over closed file

	lda	SecAddrTbl,Y		; get last+1 secondary address from
					; secondary address table
	sta	SecAddrTbl,X		; save secondary address over closed
					; file
A_F30D					;				[F30D]
	clc				; flag ok

	rts


;******************************************************************************
;
; find a file

FindFile				;				[F30F]
	lda	#$00			; clear A
	sta	STATUS			; clear the serial status byte

	txa				; copy the logical file number to A


;******************************************************************************
;
; find file A

FindFileA				;				[F314]
	ldx	LDTND			; get the open file count
A_F316					;				[F316]
	dex				; decrememnt the count to give the index
	bmi	A_F32E			; if no files just exit

	cmp	LogFileTbl,X		; compare the logical file number with
					; the table logical file number
	bne	A_F316			; if no match go try again

	rts


;******************************************************************************
;
; set file details from table,X

SetFileDetails				;				[F31F]
	lda	LogFileTbl,X		; get logical file from logical file
					; table
	sta	LA			; save the logical file

	lda	DevNumTbl,X		; get device number from device number
					; table
	sta	FA			; save the device number

	lda	SecAddrTbl,X		; get secondary address from secondary
					; address table
	sta	SA			; save the secondary address
A_F32E					;				[F32E]
	rts


;******************************************************************************
;
; close all channels and files

; this routine closes all open files. When this routine is called, the pointers
; into the open file table are reset, closing all files. Also the routine
; automatically resets the I/O channels.

ClsAllChnFil				;				[F32F]
	lda	#$00			; clear A
	sta	LDTND			; clear the open file count


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

CloseIoChans				;				[F333]
	ldx	#$03			; set the screen device
	cpx	DFLTO			; compare the screen with the output
					; device number
	bcs	A_F33C			; if <= screen skip serial bus unlisten

	jsr	IecUNLISTEN2		; else command the serial bus to
					; UNLISTEN			[EDFE]
A_F33C					;				[F33C]
	cpx	DFLTN			; compare the screen with the input
					; device number
	bcs	A_F343			; if <= screen skip serial bus untalk

	jsr	IecUNTALK2		; else command the serial bus to
					; UNTALK			[EDEF]
A_F343					;				[F343]
	stx	DFLTO			; save the screen as the output
					; device number
	lda	#$00			; set the keyboard as the input device
	sta	DFLTN			; save the input device number

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

OpenLogFile2				;				[F34A]
	ldx	LA			; get the logical file
	bne	A_F351			; if there is a file continue

	jmp	NoInputFileErr		; else do 'not input file error' and
					; return			[F70A]
A_F351					;				[F351]
	jsr	FindFile		; find a file			[F30F]
	bne	A_F359			; if file not found continue

	jmp	FileAlreadyOpen		; else do 'file already open' error and
					; return			[F6FE]
A_F359					;				[F359]
	ldx	LDTND			; get the open file count
	cpx	#10			; < maximum + 1 ?
	bcc	A_F362			; if less than maximum + 1 go open file

	jmp	TooManyFilesErr		; else do 'too many files error' and
					; return			[F6FB]
A_F362					;				[F362]
	inc	LDTND			; increment the open file count

	lda	LA			; get the logical file
	sta	LogFileTbl,X		; save it to the logical file table

	lda	SA			; get the secondary address
	ora	#$60			; OR with the OPEN CHANNEL command
	sta	SA			; save the secondary address
	sta	SecAddrTbl,X		; save it to the secondary address table

	lda	FA			; get the device number
	sta	DevNumTbl,X		; save it to the device number table
	beq	A_F3D3			; if it is the keyboard, do ok exit
S_F379
	cmp	#$03			; compare device number with screen
	beq	A_F3D3			; if it is the screen go do the ok exit
	bcc	OpenLogFile3		; if tape or RS232 device go ??
					; else it is a serial bus device
; else is serial bus device
	jsr	SndSecAdrFilNm		; send secondary address and filename
					;				[F3D5]
	bcc	A_F3D3			; go do ok exit, branch always

OpenLogFile3				;				[F384]
	cmp	#$02			; RS-232?
	bne	A_F38B			; no, ->

	jmp	OpenRS232Dev		; go open RS232 device and return [F409]

A_F38B					;				[F38B]
	jsr	TapeBufPtr2XY		; get tape buffer start pointer in XY
					;				[F7D0]
	bcs	A_F393			; if >= $0200 go ??

	jmp	IllegalDevNum		; else do 'illegal device number' and
					; return			[F713]
A_F393					;				[F393]
	lda	SA			; get the secondary address
	and	#$0F			;.
	bne	A_F3B8			;.

	jsr	WaitForPlayKey		; wait for PLAY			[F817]
	bcs	A_F3D4			; exit if STOP was pressed

	jsr	PrtSEARCHING		; print "Searching..."		[F5AF]

	lda	FNLEN			; get filename length
	beq	A_F3AF			; if null filename just go find header

	jsr	FindTapeHeader		; find specific tape header	[F7EA]
	bcc	A_F3C2			; branch if no error

	beq	A_F3D4			; exit if ??

A_F3AC					;				[F3AC]
	jmp	FileNotFound		; do file not found error and return
					;	[F704]
A_F3AF					;				[F3AF]
	jsr	FindTapeHdr2		; find tape header, exit with header in
					; buffer			[F72C]
	beq	A_F3D4			; exit if end of tape found

	bcc	A_F3C2			;.

	bcs	A_F3AC			; always ->

A_F3B8					;				[F3B8]
	jsr	WaitForPlayRec		; wait for PLAY/RECORD		[F838]
	bcs	A_F3D4			; exit if STOP was pressed

	lda	#$04			; set data file header
	jsr	WriteTapeHdr		; write tape header		[F76A]
A_F3C2					;				[F3C2]
	lda	#$BF			;.

	ldy	SA			; get the secondary address
	cpy	#$60			;.
	beq	A_F3D1			;.

	ldy	#$00			; clear index
	lda	#$02			;.
	sta	(TapeBufPtr),Y		;.save to tape buffer

	tya				;.clear A
A_F3D1					;				[F3D1]
	sta	BUFPNT			;.save tape buffer index
A_F3D3					;				[F3D3]
	clc				; flag ok
A_F3D4					;				[F3D4]
	rts


;******************************************************************************
;
; send secondary address and filename

SndSecAdrFilNm				;				[F3D5]
	lda	SA			; get the secondary address
	bmi	A_F3D3			; ok exit if -ve

	ldy	FNLEN			; get filename length
	beq	A_F3D3			; ok exit if null

	lda	#$00			; clear A
	sta	STATUS			; clear the serial status byte

	lda	FA			; get the device number
	jsr	CmdLISTEN2		; command devices on the serial bus to
					; LISTEN			[ED0C]
	lda	SA			; get the secondary address
	ora	#$F0			; OR with the OPEN command
	jsr	SAafterLISTEN2		; send secondary address after LISTEN
					;				[EDB9]
	lda	STATUS			; get the serial status byte
	bpl	A_F3F6			; if device present skip the 'device
					; not present' error
S_F3F1
	pla				; else dump calling address LB
	pla				; dump calling address HB

	jmp	DevNotPresent		; do 'device not present' error and
					; return			[F707]
A_F3F6					;				[F3F6]
	lda	FNLEN			; get filename length
	beq	A_F406			; branch if null name

	ldy	#$00			; clear index
A_F3FC					;				[F3FC]
	lda	(FNADR),Y		; get filename byte
	jsr	IecByteOut2		; output byte to serial bus	[EDDD]

	iny				; increment index
	cpy	FNLEN			; compare with filename length
	bne	A_F3FC			; loop if not all done
A_F406					;				[F406]
	jmp	DoUNLISTEN		; command serial bus to UNLISTEN and
					; return			[F654]

;******************************************************************************
;
; open RS232 device

OpenRS232Dev				;				[F409]
	jsr	InitRS232_TX		; initialise RS232 output	[F483]
	sty	RSSTAT			; save the RS232 status register
A_F40F					;				[F40F]
	cpy	FNLEN			; compare with filename length
	beq	A_F41D			; exit loop if done

	lda	(FNADR),Y		; get filename byte
	sta	M51CTR,Y		; copy to 6551 register set

	iny				; increment index
	cpy	#$04			; compare with $04
	bne	A_F40F			; loop if not to 4 yet

A_F41D					;				[F41D]
	jsr	CalcBitCounts		; compute bit count		[EF4A]
	stx	BITNUM			; save bit count

	lda	M51CTR			; get pseudo 6551 control register
	and	#$0F			; mask 0000, baud rate
	beq	A_F446			; if zero skip the baud rate setup

	asl				; * 2 bytes per entry
	tax				; copy to the index

	lda	PALNTSC			; get the PAL/NTSC flag
	bne	A_F43A			; if PAL go set PAL timing

	ldy	TblBaudNTSC-1,X		; get the NTSC baud rate value HB
	lda	TblBaudNTSC-2,X		; get the NTSC baud rate value LB
	jmp	SaveBaudRate		; go save the baud rate values	[F440]

A_F43A					;				[F43A]
	ldy	TblBaudRates-1,X	; get the PAL baud rate value HB
	lda	TblBaudRates-2,X	; get the PAL baud rate value LB
SaveBaudRate				;				[F440]
	sty	M51AJB+1		; save the nonstandard bit timing HB
	sta	M51AJB			; save the nonstandard bit timing LB
A_F446					;				[F446]
	lda	M51AJB			; get the nonstandard bit timing LB
	asl				; * 2
	jsr	SetTimerBaudR		;.				[FF2E]

	lda	M51CDR			; read the pseudo 6551 command register
	lsr				; shift the X line/3 line bit into Cb
	bcc	A_F45C			; if 3 line skip the DRS test

	lda	CIA2DRB			; read CIA 2 DRB, RS232 port
	asl				; shift DSR in into Cb
	bcs	A_F45C			; if DSR present skip the error set

	jsr	DeactivateDSR		; set no DSR			[F00D]
A_F45C					;				[F45C]
	lda	RIDBE			; get index to Rx buffer end
	sta	RIDBS			; set index to Rx buffer start, clear
					; Rx buffer
	lda	RODBS			; get index to Tx buffer end
	sta	RODBE			; set index to Tx buffer start, clear
					; Tx buffer
	jsr	ReadTopOfMem		; read the top of memory	[FE27]

	lda	RIBUF+1			; get RS232 input buffer pointer HB
	bne	A_F474			; if buffer already set skip the save

	dey				; decrement top of memory HB, 256 byte
					; buffer
	sty	RIBUF+1			; save RS232 input buffer pointer HB
	stx	RIBUF			; save RS232 input buffer pointer LB
A_F474					;				[F474]
	lda	ROBUF+1			; get RS232 output buffer pointer HB
	bne	SetTopOfMem		; if > 0 go set the top of memory to
					; $F0xx

	dey				;.
	sty	ROBUF+1			; save RS232 output buffer pointer HB
	stx	ROBUF			; save RS232 output buffer pointer LB


;******************************************************************************
;
; set the top of memory to F0xx

SetTopOfMem				;				[F47D]
	sec				; read the top of memory
	lda	#$F0			; set $F000
	jmp	SetTopOfMem2		; set the top of memory and return
					;				[FE2D]

;******************************************************************************
;
; initialise RS232 output

InitRS232_TX				;				[F483]
	lda	#$7F			; disable all interrupts
	sta	CIA2IRQ			; save CIA 2 ICR

	lda	#$06			; set RS232 DTR output, RS232 RTS output
	sta	CIA2DDRB		; save CIA 2 DDRB, RS232 port
	sta	CIA2DRB			; save CIA 2 DRB, RS232 port

	lda	#$04			; mask x1xx, set RS232 Tx DATA high
	ora	CIA2DRA			; OR it with CIA 2 DRA, serial port and
					; video address
	sta	CIA2DRA			; save CIA 2 DRA, serial port and video
					; address
	ldy	#$00			; clear Y
	sty	ENABL			; clear RS-232 interrupt enable byte

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

LoadRamFrmDev2				;				[F49E]
	stx	MEMUSS			; set kernal setup pointer LB
	sty	MEMUSS+1		; set kernal setup pointer HB

	jmp	(ILOAD)			; do LOAD vector, usually points to
					; LoadRamFrmDev22

;******************************************************************************
;
; load

LoadRamFrmDev22				;				[F4A5]
	sta	LoadVerify2		; save load/verify flag

	lda	#$00			; clear A
	sta	STATUS			; clear the serial status byte
S_F4AB
	lda	FA			; get the device number
	bne	A_F4B2			; if not the keyboard continue

; can't load form keyboard so ..
A_F4AF					;				[F4AF]
	jmp	IllegalDevNum		; else do 'illegal device number' and
					; return			[F713]
A_F4B2					;				[F4B2]
	cmp	#$03			; screen?
	beq	A_F4AF			; yes, ->

	bcc	LoadFromTape		; smaller, -> load from tape

; else is serial bus device
	ldy	FNLEN			; get filename length
	bne	A_F4BF			; if not null name go ??

	jmp	MissingFileNam		; else do 'missing filename' error and
					; return			[F710]
A_F4BF					;				[F4BF]
	ldx	SA			; get the secondary address
	jsr	PrtSEARCHING		; print "Searching..."		[F5AF]

	lda	#$60			;.
	sta	SA			; save the secondary address

	jsr	SndSecAdrFilNm		; send secondary address and filename
					;				[F3D5]
	lda	FA			; get the device number
	jsr	CmdTALK2		; command serial bus device to TALK
					;				[ED09]
	lda	SA			; get the secondary address
	jsr	SAafterTALK2		; send secondary address after TALK
					;				[EDC7]
LoadRamFrmDev22b			;				[F4D5]
	jsr	IecByteIn2		; input byte from serial bus	[EE13]
	sta	EAL			; save program start address LB

	lda	STATUS			; get the serial status byte
	lsr				; shift time out read ..
	lsr				; .. into carry bit
	bcs	A_F530			; if timed out go do file not found
					; error and return
	jsr	IecByteIn2		; input byte from serial bus	[EE13]
	sta	EAL+1			; save program start address HB

	txa				; copy secondary address
	bne	A_F4F0			; load location not set in LOAD call,
					; so continue with the load
	lda	MEMUSS			; get the load address LB
	sta	EAL			; save the program start address LB

	lda	MEMUSS+1		; get the load address HB
	sta	EAL+1			; save the program start address HB

A_F4F0					;				[F4F0]
	jsr	LoadVerifying		;.				[F5D2]
A_F4F3					;				[F4F3]
	lda	#$FD			; mask xx0x, clear time out read bit
	and	STATUS			; mask the serial status byte
	sta	STATUS			; set the serial status byte

	jsr	ScanStopKey		; scan stop key, return Zb = 1 = [STOP]
					;				[FFE1]
	bne	A_F501			; if not [STOP] go ??

	jmp	CloseIecBus		; else close the serial bus device and
					; flag stop			[F633]
A_F501					;				[F501]
	jsr	IecByteIn2		; input byte from serial bus	[EE13]
	tax				; copy byte

	lda	STATUS			; get the serial status byte
	lsr				; shift time out read ..
	lsr				; .. into carry bit
	bcs	A_F4F3			; if timed out go try again

	txa				; copy received byte back

	ldy	LoadVerify2		; get load/verify flag
	beq	A_F51C			; if load go load

; else is verify
	ldy	#$00			; clear index
	cmp	(EAL),Y			; compare byte with previously loaded
					; byte
	beq	A_F51E			; if match go ??

	lda	#$10			; flag read error
	jsr	AorIecStatus		; OR into the serial status byte [FE1C]
.byte	$2C				; makes next line BIT $AE91
A_F51C					;				[F51C]
	sta	(EAL),Y			; save byte to memory
A_F51E					;				[F51E]
	inc	EAL			; increment save pointer LB
	bne	A_F524			; if no rollover go ??

	inc	EAL+1			; else increment save pointer HB
A_F524					;				[F524]
	bit	STATUS			; test the serial status byte
	bvc	A_F4F3			; loop if not end of file

; close file and exit
	jsr	IecUNTALK2		; command serial bus to UNTALK	[EDEF]

	jsr	CloseIecDevice		; close serial device, error?	[F642]
	bcc	A_F5A9			; no, -> exit
A_F530					;				[F530]
	jmp	FileNotFound		; do file not found error and return
					;				[F704]

;******************************************************************************
;
; Load from tape

LoadFromTape				;				[F533]
	lsr				; tape?
	bcs	A_F539			; yes, ->

	jmp	IllegalDevNum		; else do 'illegal device number' and
					; return			[F713]
A_F539					;				[F539]
	jsr	TapeBufPtr2XY		; get tape buffer start pointer in XY
					;				[F7D0]
	bcs	A_F541			; if ??

	jmp	IllegalDevNum		; else do 'illegal device number' and
					; return			[F713]

A_F541					;				[F541]
	jsr	WaitForPlayKey		; wait for PLAY			[F817]
	bcs	A_F5AE			; exit if STOP was pressed

	jsr	PrtSEARCHING		; print "Searching..."		[F5AF]
A_F549					;				[F549]
	lda	FNLEN			; get filename length
	beq	A_F556			;.

	jsr	FindTapeHeader		; find specific tape header	[F7EA]
	bcc	A_F55D			; if no error continue

	beq	A_F5AE			; exit if ??

	bcs	A_F530			; file not found, branch always

A_F556					;				[F556]
	jsr	FindTapeHdr2		; find tape header, exit with header in
					; buffer			[F72C]
	beq	A_F5AE			; exit if ??

	bcs	A_F530			;.
A_F55D					;				[F55D]
	lda	STATUS			; get the serial status byte
	and	#$10			; mask 000x 0000, read error
	sec				; flag fail
	bne	A_F5AE			; if read error just exit

	cpx	#$01			;.
	beq	A_F579			;.

	cpx	#$03			;.
	bne	A_F549			;.

A_F56C					;				[F56C]
	ldy	#$01			;.
	lda	(TapeBufPtr),Y		;.
	sta	MEMUSS			;.

	iny				;.
	lda	(TapeBufPtr),Y		;.
	sta	MEMUSS+1		;.
	bcs	A_F57D			;.

A_F579					;				[F579]
	lda	SA			; get the secondary address
	bne	A_F56C			;.

A_F57D					;				[F57D]
	ldy	#$03			;.
	lda	(TapeBufPtr),Y		;.
	ldy	#$01			;.
	sbc	(TapeBufPtr),Y		;.
	tax				;.

	ldy	#$04			;.
	lda	(TapeBufPtr),Y		;.
	ldy	#$02			;.
	sbc	(TapeBufPtr),Y		;.
	tay				;.

	clc				;.
	txa				;.
	adc	MEMUSS			;.
	sta	EAL			;.

	tya				;.
	adc	MEMUSS+1		;.
	sta	EAL+1			;.

	lda	MEMUSS			;.
	sta	STAL			; set I/O start addresses LB

	lda	MEMUSS+1		;.
	sta	STAL+1			; set I/O start addresses HB

	jsr	LoadVerifying		; display "LOADING" or "VERIFYING"
					;				[F5D2]
	jsr	ReadTape		; do the tape read		[F84A]

.byte	$24				; keep the error flag in Carry
A_F5A9					;				[F5A9]
	clc				; flag ok

	ldx	EAL			; get the LOAD end pointer LB
	ldy	EAL+1			; get the LOAD end pointer HB
A_F5AE					;				[F5AE]
	rts


;******************************************************************************
;
; print "Searching..."

PrtSEARCHING				;				[F5AF]
	lda	MSGFLG			; get message mode flag
	bpl	A_F5D1			; exit if control messages off

	ldy	#TxtSEARCHING		; index to "SEARCHING "
	jsr	DisplayIoMsg2		; display kernel I/O message	[F12F]

	lda	FNLEN			; get filename length
	beq	A_F5D1			; exit if null name

	ldy	#TxtFOR			; else index to "FOR "
	jsr	DisplayIoMsg2		; display kernel I/O message	[F12F]


;******************************************************************************
;
; print filename

PrintFileName				;				[F5C1]
	ldy	FNLEN			; get filename length
	beq	A_F5D1			; exit if null filename

	ldy	#$00			; clear index
A_F5C7					;				[F5C7]
	lda	(FNADR),Y		; get filename byte
	jsr	OutByteChan		; output character to channel	[FFD2]
	iny				; increment index
	cpy	FNLEN			; compare with filename length
	bne	A_F5C7			; loop if more to do

A_F5D1					;				[F5D1]
	rts


;******************************************************************************
;
; display "LOADING" or "VERIFYING"

LoadVerifying				;				[F5D2]
	ldy	#TxtLOADING		; point to "LOADING"

	lda	LoadVerify2		; get load/verify flag
	beq	A_F5DA			; branch if load

	ldy	#TxtVERIFYING		; point to "VERIFYING"
A_F5DA					;				[F5DA]
	jmp	DisplayIoMsg		; display kernel I/O message if in
					; direct mode and return	[F12B]

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

SaveRamToDev2				;				[F5DD]
	stx	EAL			; save end address LB
	sty	EAL+1			; save end address HB

	tax				; copy index to start pointer

	lda	D6510+0,X		; get start address LB
	sta	STAL			; set I/O start addresses LB

	lda	D6510+1,X		; get start address HB
	sta	STAL+1			; set I/O start addresses HB

	jmp	(ISAVE)			; go save, usually points to $F5ED


;******************************************************************************
;
; save

SaveRamToDev22				;				[F5ED]
	lda	FA			; get the device number, keyboard?
	bne	A_F5F4			; no, ->

; else ..
A_F5F1					;				[F5F1]
	jmp	IllegalDevNum		; else do 'illegal device number' and
					; return			[F713]
A_F5F4					;				[F5F4]
	cmp	#$03			; compare device number with screen
	beq	A_F5F1			; if screen do illegal device number
					; and return
	bcc	SaveRamToTape		; branch if < screen

; is greater than screen so is serial bus
	lda	#$61			; set secondary address to $01 when a
					; secondary address is to be sent to a
					; device on the serial bus the address
					; must first be ORed with $60
	sta	SA			; save the secondary address

	ldy	FNLEN			; get the filename length
	bne	A_F605			; if filename not null continue

	jmp	MissingFileNam		; else do 'missing filename' error and
					; return			[F710]
A_F605					;				[F605]
	jsr	SndSecAdrFilNm		; send secondary address and filename
					;				[F3D5]
	jsr	PrtSAVING		; print saving <filename>	[F68F]
SaveRamToDev22b
	lda	FA			; get the device number
	jsr	CmdLISTEN2		; command devices on the serial bus to
					; LISTEN			[ED0C]

	lda	SA			; get the secondary address
	jsr	SAafterLISTEN2		; send secondary address after LISTEN
					;				[EDB9]
	ldy	#$00			; clear index
	jsr	CopyIoAdr2Buf		; copy I/O start address to buffer
					; address			[FB8E]
	lda	SAL			; get buffer address LB
	jsr	IecByteOut2		; output byte to serial bus	[EDDD]

	lda	SAL+1			; get buffer address HB
	jsr	IecByteOut2		; output byte to serial bus	[EDDD]
A_F624					;				[F624]
	jsr	ChkRdWrPtr		; check read/write pointer, return
					; Cb = 1 if pointer >= end	[FCD1]
	bcs	A_F63F			; go do UNLISTEN if at end

	lda	(SAL),Y			; get byte from buffer
	jsr	IecByteOut2		; output byte to serial bus	[EDDD]

	jsr	ScanStopKey		; scan stop key			[FFE1]
	bne	A_F63A			; if stop not pressed go increment
					; pointer and loop for next
; else ..

; close the serial bus device and flag stop

CloseIecBus				;				[F633]
	jsr	CloseIecDevice		; close serial bus device	[F642]

	lda	#$00			;.
	sec				; flag stop
	rts


A_F63A					;				[F63A]
	jsr	IncRdWrPtr		; increment read/write pointer	[FCDB]
	bne	A_F624			; loop, branch always
A_F63F					;				[F63F]
	jsr	IecUNLISTEN2		; command serial bus to UNLISTEN [EDFE]

; close serial bus device

CloseIecDevice				;				[F642]
	bit	SA			; test the secondary address
	bmi	A_F657			; if already closed just exit

	lda	FA			; get the device number
	jsr	CmdLISTEN2		; command devices on the serial bus to
					; LISTEN			[ED0C]

	lda	SA			; get the secondary address
	and	#$EF			; mask the channel number
	ora	#$E0			; OR with the CLOSE command
	jsr	SAafterLISTEN2		; send secondary address after LISTEN
					;				[EDB9]
DoUNLISTEN				;				[F654]
	jsr	IecUNLISTEN2		; command serial bus to UNLISTEN [EDFE]
A_F657					;				[F657]
	clc				; flag ok
	rts

SaveRamToTape				;				[F659]
	lsr				; bit 0 is set, = tape?
	bcs	A_F65F			; yes, -> OK

	jmp	IllegalDevNum		; else do 'illegal device number' and
					; return			[F713]
A_F65F					;				[F65F]
	jsr	TapeBufPtr2XY		; get tape buffer start pointer in XY
					;				[F7D0]
	bcc	A_F5F1			; if < $0200 do illegal device number
					; and return
	jsr	WaitForPlayRec		; wait for PLAY/RECORD		[F838]
	bcs	A_F68E			; exit if STOP was pressed

	jsr	PrtSAVING		; print saving <filename>	[F68F]

	ldx	#$03			; set header for a non relocatable
					; program file
	lda	SA			; get the secondary address
	and	#$01			; mask non relocatable bit
	bne	A_F676			; if non relocatable program go ??

	ldx	#$01			; else set header for a relocatable
					; program file
A_F676					;				[F676]
	txa				; copy header type to A
	jsr	WriteTapeHdr		; write tape header		[F76A]
	bcs	A_F68E			; exit if error

	jsr	WriteTape20Cyc		; do tape write, 20 cycle count	[F867]
	bcs	A_F68E			; exit if error

	lda	SA			; get the secondary address
	and	#$02			; mask end of tape flag
	beq	A_F68D			; if not end of tape go ??

	lda	#$05			; else set logical end of the tape
	jsr	WriteTapeHdr		; write tape header		[F76A]
.byte	$24				; makes next line BIT LASTPT+1 so Cb is
					; not changed
A_F68D					;				[F68D]
	clc				; flag ok
A_F68E					;				[F68E]
	rts


;******************************************************************************
;
; print saving <filename>

PrtSAVING				;				[F68F]
	lda	MSGFLG			; get message mode flag
	bpl	A_F68E			; exit if control messages off

	ldy	#TxtSAVING		; index to "SAVING "
	jsr	DisplayIoMsg2		; display kernel I/O message	[F12F]

	jmp	PrintFileName		; print filename and return	[F5C1]


;******************************************************************************
;
; increment the real time clock

; this routine updates the system clock. Normally this routine is called by the
; normal KERNAL interrupt routine every 1/60th of a second. If the user program
; processes its own interrupts this routine must be called to update the time.
; Also, the STOP key routine must be called if the stop key is to remain
; functional.

IncrClock2				;				[F69B]
	ldx	#$00			; clear X

	inc	TimeBytes+2		; increment the jiffy clock LB
	bne	A_F6A7			; if no rollover ??

	inc	TimeBytes+1		; increment the jiffy clock mid byte
	bne	A_F6A7			; branch if no rollover

	inc	TimeBytes		; increment the jiffy clock HB

; now subtract a days worth of jiffies from current count and remember only the
; Cb result
A_F6A7					;				[F6A7]
	sec				; set carry for subtract
	lda	TimeBytes+2		; get the jiffy clock LB
	sbc	#$01			; subtract $4F1A01 LB

	lda	TimeBytes+1		; get the jiffy clock mid byte
	sbc	#$1A			; subtract $4F1A01 mid byte

	lda	TimeBytes		; get the jiffy clock HB
	sbc	#$4F			; subtract $4F1A01 HB
	bcc	IncrClock22		; if less than $4F1A01 jiffies skip the
					; clock reset
; else ..
	stx	TimeBytes		; clear the jiffy clock HB
	stx	TimeBytes+1		; clear the jiffy clock mid byte
	stx	TimeBytes+2		; clear the jiffy clock LB
					; this is wrong, there are $4F1A00
					; jiffies in a day so the reset to zero
					; should occur when the value reaches
					; $4F1A00 and not $4F1A01. This would
					; give an extra jiffy every day and a
					; possible TI value of 24:00:00
IncrClock22				;				[F6BC]
	lda	CIA1DRB			; read CIA 1 DRB, keyboard row port
	cmp	CIA1DRB			; compare it with itself
	bne	IncrClock22		; loop if changing

	tax				; <STOP> key pressed?
	bmi	A_F6DA			; no, -> skip rest

	ldx	#$BD			; set c6
	stx	CIA1DRA			; save CIA 1 DRA, keyboard column drive

A_F6CC					;				[F6CC]
	ldx	CIA1DRB			; read CIA 1 DRB, keyboard row port
	cpx	CIA1DRB			; compare it with itself
	bne	A_F6CC			; loop if changing

	sta	CIA1DRA			; save CIA 1 DRA, keyboard column drive

	inx				;.
	bne	A_F6DC			;.

A_F6DA					;				[F6DA]
	sta	StopKey			; save the stop key column
A_F6DC					;				[F6DC]
	rts


;******************************************************************************
;
; read the real time clock

; this routine returns the time, in jiffies, in AXY. The accumulator contains
; the most significant byte.

ReadClock2				;				[F6DD]
	sei				; disable the interrupts

	lda	TimeBytes+2		; get the jiffy clock LB
	ldx	TimeBytes+1		; get the jiffy clock mid byte
	ldy	TimeBytes		; get the jiffy clock HB


;******************************************************************************
;
; set the real time clock

; the system clock is maintained by an interrupt routine that updates the clock
; every 1/60th of a second. The clock is three bytes long which gives the
; capability to count from zero up to 5,184,000 jiffies - 24 hours plus one
; jiffy. At that point the clock resets to zero. Before calling this routine to
; set the clock the new time, in jiffies, should be in YXA, the accumulator
; containing the most significant byte.

SetClock2				;				[F6E4]
	sei				; disable the interrupts

	sta	TimeBytes+2		; save the jiffy clock LB
	stx	TimeBytes+1		; save the jiffy clock mid byte
	sty	TimeBytes		; save the jiffy clock HB

	cli				; enable the interrupts

	rts


;******************************************************************************
;
; scan the stop key, return Zb = 1 = [STOP]

; if the STOP key on the keyboard is pressed when this routine is called the Z
; flag will be set. All other flags remain unchanged. If the STOP key is not
; pressed then the accumulator will contain a byte representing the last row of
; the keyboard scan.

; The user can also check for certain other keys this way.

Scan4StopKey				;				[F6ED]
	lda	StopKey			; read the stop key column
	cmp	#$7F			; compare with [STP] down
	bne	A_F6FA			; if not [STOP] or not just [STOP] exit

; just [STOP] was pressed
	php				; save status

	jsr	CloseIoChannls		; close input and output channels [FFCC]
	sta	NDX			; save the keyboard buffer index

	plp				; restore status

A_F6FA					;				[F6FA]
	rts


;******************************************************************************
;
; file error messages

TooManyFilesErr				;				[F6FB]
	lda	#$01			; 'too many files' error
.byte	$2C				; makes next line BIT $02A9

FileAlreadyOpen				;				[F6FE]
	lda	#$02			; 'file already open' error
.byte	$2C				; makes next line BIT $03A9

FileNotOpenErr				;				[F701]
	lda	#$03			; 'file not open' error
.byte	$2C				; makes next line BIT $04A9

FileNotFound				;				[F704]
	lda	#$04			; 'file not found' error
.byte	$2C				; makes next line BIT $05A9

DevNotPresent				;				[F707]
	lda	#$05			; 'device not present' error
.byte	$2C				; makes next line BIT $06A9

NoInputFileErr				;				[F70A]
	lda	#$06			; 'not input file' error
.byte	$2C				; makes next line BIT $07A9

NoOutpFileErr				;				[F70D]
	lda	#$07			; 'not output file' error
.byte	$2C				; makes next line BIT $08A9

MissingFileNam				;				[F710]
	lda	#$08			; 'missing filename' error
.byte	$2C				; makes next line BIT $09A9

IllegalDevNum				;				[F713]
	lda	#$09			; do 'illegal device number'
	pha				; save the error #

	jsr	CloseIoChannls		; close input and output channels [FFCC]

	ldy	#TxtIO_ERROR		; index to "I/O ERROR #"

	bit	MSGFLG			; test message mode flag
	bvc	A_F729			; exit if kernal messages off

	jsr	DisplayIoMsg2		; display kernel I/O message	[F12F]

	pla				; restore error #
	pha				; copy error #

	ora	#'0'			; convert to ASCII
	jsr	OutByteChan		; output character to channel	[FFD2]
A_F729					;				[F729]
	pla				; pull error number
	sec				; flag error

	rts


;******************************************************************************
;
; find the tape header, exit with header in buffer

FindTapeHdr2				;				[F72C]
	lda	LoadVerify2		; get load/verify flag
	pha				; save load/verify flag

	jsr	InitTapeRead		; initiate tape read		[F841]

	pla				; restore load/verify flag
	sta	LoadVerify2		; save load/verify flag
	bcs	A_F769			; exit if error

	ldy	#$00			; clear the index
	lda	(TapeBufPtr),Y		; read first byte from tape buffer
	cmp	#$05			; compare with logical end of the tape
	beq	A_F769			; if end of the tape exit

	cmp	#$01			; compare with header for a relocatable
					; program file
	beq	A_F74B			; if program file header go ??

	cmp	#$03			; compare with header for a non
					; relocatable program file
	beq	A_F74B			; if program file header go  ??

	cmp	#$04			; compare with data file header
	bne	FindTapeHdr2		; if data file loop to find tape header

; was a program file header
A_F74B					;				[F74B]
	tax				; copy header type
	bit	MSGFLG			; get message mode flag
	bpl	A_F767			; exit if control messages off

	ldy	#TxtFOUND		; index to "FOUND "
	jsr	DisplayIoMsg2		; display kernel I/O message	[F12F]

	ldy	#$05			; index to the tape filename
A_F757					;				[F757]
	lda	(TapeBufPtr),Y		; get byte from tape buffer
	jsr	OutByteChan		; output character to channel	[FFD2]

	iny				; increment the index
	cpy	#$15			; compare it with end+1
	bne	A_F757			; loop if more to do

	lda	TimeBytes+1		; get the jiffy clock mid byte
	jsr	Wait8Seconds		; wait ~8.5 seconds for any key from
					; the STOP key column		[E4E0]
	nop				; waste cycles
A_F767					;				[F767]
	clc				; flag no error

	dey				; decrement the index
A_F769					;				[F769]
	rts


;******************************************************************************
;
; write the tape header

WriteTapeHdr				;				[F76A]
	sta	PTR1			; save header type

	jsr	TapeBufPtr2XY		; get tape buffer start pointer in XY
					;				[F7D0]
	bcc	A_F7CF			; if < $0200 just exit ??

	lda	STAL+1			; get I/O start address HB
	pha				; save it

	lda	STAL			; get I/O start address LB
	pha				; save it

	lda	EAL+1			; get tape end address HB
	pha				; save it

	lda	EAL			; get tape end address LB
	pha				; save it

	ldy	#$BF			; index to header end
	lda	#' '			; clear byte, [SPACE]
A_F781					;				[F781]
	sta	(TapeBufPtr),Y		; clear header byte

	dey				; decrement index
	bne	A_F781			; loop if more to do

	lda	PTR1			; get the header type back
	sta	(TapeBufPtr),Y		; write it to header

	iny				; increment the index
	lda	STAL			; get the I/O start address LB
	sta	(TapeBufPtr),Y		; write it to header

	iny				; increment the index
	lda	STAL+1			; get the I/O start address HB
	sta	(TapeBufPtr),Y		; write it to header

	iny				; increment the index
	lda	EAL			; get the tape end address LB
	sta	(TapeBufPtr),Y		; write it to header

	iny				; increment the index
	lda	EAL+1			; get the tape end address HB
	sta	(TapeBufPtr),Y		; write it to header

	iny				; increment the index
	sty	PTR2			; save the index

	ldy	#$00			; clear Y
	sty	PTR1			; clear the name index
A_F7A5					;				[F7A5]
	ldy	PTR1			; get name index
	cpy	FNLEN			; compare with filename length
	beq	A_F7B7			; if all done exit the loop

	lda	(FNADR),Y		; get filename byte
	ldy	PTR2			; get buffer index
	sta	(TapeBufPtr),Y		; save filename byte to buffer

	inc	PTR1			; increment filename index
	inc	PTR2			; increment tape buffer index
	bne	A_F7A5			; loop, branch always

A_F7B7					;				[F7B7]
	jsr	SetTapeBufStart		; set tape buffer start and end
					; pointers			[F7D7]
	lda	#$69			; set write lead cycle count
	sta	RIPRTY			; save write lead cycle count

	jsr	WriteTape20		; do tape write, no cycle count set
					;				[F86B]
	tay				;.

	pla				; pull tape end address LB
	sta	EAL			; restore it

	pla				; pull tape end address HB
	sta	EAL+1			; restore it

	pla				; pull I/O start addresses LB
	sta	STAL			; restore it

	pla				; pull I/O start addresses HB
	sta	STAL+1			; restore it

	tya				;.
A_F7CF					;				[F7CF]
	rts


;******************************************************************************
;
; get the tape buffer start pointer

TapeBufPtr2XY				;				[F7D0]
	ldx	TapeBufPtr		; get tape buffer start pointer LB

	ldy	TapeBufPtr+1		; get tape buffer start pointer HB
	cpy	#$02			; compare HB with $02xx
	rts


;******************************************************************************
;
; set the tape buffer start and end pointers

SetTapeBufStart				;				[F7D7]
	jsr	TapeBufPtr2XY		; get tape buffer start pointer in XY
					;				[F7D0]
	txa				; copy tape buffer start pointer LB
	sta	STAL			; save as I/O address pointer LB

	clc				; clear carry for add
	adc	#$C0			; add buffer length LB
	sta	EAL			; save tape buffer end pointer LB

	tya				; copy tape buffer start pointer HB
	sta	STAL+1			; save as I/O address pointer HB

	adc	#$00			; add buffer length HB
	sta	EAL+1			; save tape buffer end pointer HB

	rts


;******************************************************************************
;
; find specific tape header

FindTapeHeader				;				[F7EA]
	jsr	FindTapeHdr2		; find tape header, exit with header in
					; buffer			[F72C]
	bcs	A_F80C			; just exit if error

	ldy	#$05			; index to name
	sty	PTR2			; save as tape buffer index

	ldy	#$00			; clear Y
	sty	PTR1			; save as name buffer index
A_F7F7					;				[F7F7]
	cpy	FNLEN			; compare with filename length
	beq	A_F80B			; ok exit if match

	lda	(FNADR),Y		; get filename byte
	ldy	PTR2			; get index to tape buffer
	cmp	(TapeBufPtr),Y		; compare with tape header name byte
	bne	FindTapeHeader		; if no match go get next header

	inc	PTR1			; else increment name buffer index
	inc	PTR2			; increment tape buffer index

	ldy	PTR1			; get name buffer index
	bne	A_F7F7			; loop, branch always

A_F80B					;				[F80B]
	clc				; flag ok
A_F80C					;				[F80C]
	rts


;******************************************************************************
;
; bump tape pointer

BumpTapePtr				;				[F80D]
	jsr	TapeBufPtr2XY		; get tape buffer start pointer in XY
					;				[F7D0]
	inc	BUFPNT			; increment tape buffer index

	ldy	BUFPNT			; get tape buffer index
	cpy	#$C0			; compare with buffer length
	rts


;******************************************************************************
;
; wait for PLAY

WaitForPlayKey				;				[F817]
	jsr	ReadTapeSense		; return cassette sense in Zb	[F82E]
	beq	A_F836			; if switch closed just exit

; cassette switch was open
	ldy	#TxtPRESS_PLAY		; index to "PRESS PLAY ON TAPE"
A_F81E					;				[F81E]
	jsr	DisplayIoMsg2		; display kernel I/O message	[F12F]
A_F821					;				[F821]
	jsr	ScanStopKey0		; scan stop key and flag abort if
					; pressed			[F8D0]
					; note if STOP was pressed the return
					; is to the routine that called this
					; one and not here
	jsr	ReadTapeSense		; return cassette sense in Zb	[F82E]
	bne	A_F821			; loop if the cassette switch is open

	ldy	#TxtOK2			; index to "OK"
	jmp	DisplayIoMsg2		; display kernel I/O message and return
					;				[F12F]


;******************************************************************************
;
; return cassette sense in Zb

ReadTapeSense				;				[F82E]
	lda	#$10			; set the mask for the cassette switch
	bit	P6510			; test the 6510 I/O port
	bne	A_F836			; branch if cassette sense high

	bit	P6510			; test the 6510 I/O port
A_F836					;				[F836]
	clc				;.
	rts


;******************************************************************************
;
; wait for PLAY/RECORD

WaitForPlayRec				;				[F838]
	jsr	ReadTapeSense		; return the cassette sense in Zb [F82E]
	beq	A_F836			; exit if switch closed

; cassette switch was open
	ldy	#TxtPRESS_RECO		; index to "PRESS RECORD & PLAY ON
					; TAPE"
	bne	A_F81E			; display message and wait for switch,
					; branch always

;******************************************************************************
;
; initiate a tape read

InitTapeRead				;				[F841]
	lda	#$00			; clear A
	sta	STATUS			; clear serial status byte
	sta	LoadVerify2		; clear the load/verify flag

	jsr	SetTapeBufStart		; set the tape buffer start and end
					; pointers			[F7D7]
ReadTape				;				[F84A]
	jsr	WaitForPlayKey		; wait for PLAY			[F817]
	bcs	A_F86E			; exit if STOP was pressed, uses a
					; further BCS at the target address to
					; reach final target at ClrSavIrqAddr
	sei				; disable interrupts

	lda	#$00			; clear A
	sta	RIDATA			;.
	sta	BITTS			;.
	sta	CMPO			; clear tape timing constant min byte
	sta	PTR1			; clear tape pass 1 error log/char buf
	sta	PTR2			; clear tape pass 2 error log corrected
	sta	DPSW			; clear byte received flag

	lda	#$90			; enable CA1 interrupt ??

	ldx	#$0E			; set index for tape read vector
	bne	A_F875			; go do tape read/write, branch always


;******************************************************************************
;
; initiate a tape write

InitTapeWrite				;				[F864]
	jsr	SetTapeBufStart		; set tape buffer start and end
					; pointers			[F7D7]

; do tape write, 20 cycle count

WriteTape20Cyc				;				[F867]
	lda	#$14			; set write lead cycle count
	sta	RIPRTY			; save write lead cycle count

; do tape write, no cycle count set

WriteTape20				;				[F86B]
	jsr	WaitForPlayRec		; wait for PLAY/RECORD		[F838]
A_F86E					;				[F86E]
	bcs	ClrSavIrqAddr		; if STOPped clear save IRQ address and
					; exit
	sei				; disable interrupts

	lda	#$82			; enable ?? interrupt
	ldx	#$08			; set index for tape write tape leader
					; vector

;******************************************************************************
;
; tape read/write

A_F875					;				[F875]
	ldy	#$7F			; disable all interrupts
	sty	CIA1IRQ			; save CIA 1 ICR, disable all interrupts

	sta	CIA1IRQ			; save CIA 1 ICR, enable interrupts
					; according to A
; check RS232 bus idle

	lda	CIA1CTR1		; read CIA 1 CRA
	ora	#$19			; load timer B, timer B single shot,
					; start timer B
	sta	CIA1CTR2		; save CIA 1 CRB

	and	#$91			; mask x00x 000x, TOD clock, load timer
					; A, start timer A
	sta	Copy6522CRB		; save CIA 1 CRB shadow copy

	jsr	IsRS232Idle		;.				[F0A4]

	lda	VICCTR1			; read the vertical fine scroll and
					; control register
	and	#$EF			; blank the screen
	sta	VICCTR1			; save the vertical fine scroll and
					; control register
	lda	CINV			; get IRQ vector LB
	sta	IRQTMP			; save IRQ vector LB

	lda	CINV+1			; get IRQ vector HB
	sta	IRQTMP+1		; save IRQ vector HB

	jsr	SetTapeVector		; set the tape vector		[FCBD]

	lda	#$02			; set copies count. First copy is load
					; copy, the second copy is verify copy
	sta	FSBLK			; save copies count

	jsr	SetCounter		; new tape byte setup		[FB97]

	lda	P6510			; read the 6510 I/O port
	and	#$1F			; mask 000x, cassette motor on ??
	sta	P6510			; save the 6510 I/O port
	sta	CAS1			; set the tape motor interlock

; 326656 cycle delay, allow tape motor speed to stabilise
	ldx	#$FF			; outer loop count
A_F8B5					;				[F8B5]
	ldy	#$FF			; inner loop count
A_F8B7					;				[F8B7]
	dey				; decrement inner loop count
	bne	A_F8B7			; loop if more to do

	dex				; decrement outer loop count
	bne	A_F8B5			; loop if more to do

	cli				; enable tape interrupts
J_F8BE					;				[F8BE]
	lda	IRQTMP+1		; get saved IRQ HB
	cmp	CINV+1			; compare with the current IRQ HB
	clc				; flag ok
	beq	ClrSavIrqAddr		; if tape write done go clear saved IRQ
					; address and exit
	jsr	ScanStopKey0		; scan stop key and flag abort if
					; pressed			[F8D0]
					; note if STOP was pressed the return
					; is to the routine that called this
					; one and not here
	jsr	IncrClock22		; increment real time clock	[F6BC]
	jmp	J_F8BE			; loop				[F8BE]


;******************************************************************************
;
; scan stop key and flag abort if pressed

ScanStopKey0				;				[F8D0]
	jsr	ScanStopKey		; scan stop key			[FFE1]
	clc				; flag no stop
	bne	A_F8E1			; exit if no stop

	jsr	StopUsingTape		; restore everything for STOP	[FC93]

	sec				; flag stopped

	pla				; dump return address LB
	pla				; dump return address HB


;******************************************************************************
;
; clear saved IRQ address

ClrSavIrqAddr				;				[F8DC]
	lda	#$00			; clear A
	sta	IRQTMP+1		; clear saved IRQ address HB
A_F8E1					;				[F8E1]
	rts


;******************************************************************************
;
;## set timing

InitReadTape				;				[F8E2]
	stx	CMPO+1			; save tape timing constant max byte

	lda	CMPO			; get tape timing constant min byte
	asl				; *2
	asl				; *4
	clc				; clear carry for add
	adc	CMPO			; add tape timing constant min byte *5
	clc				; clear carry for add
	adc	CMPO+1			; add tape timing constant max byte
	sta	CMPO+1			; save tape timing constant max byte

	lda	#$00			;.
	bit	CMPO			; test tape timing constant min byte
	bmi	A_F8F7			; branch if b7 set

	rol				; else shift carry into ??
A_F8F7					;				[F8F7]
	asl	CMPO+1			; shift tape timing constant max byte
	rol				;.
	asl	CMPO+1			; shift tape timing constant max byte
	rol				;.
	tax				;.
A_F8FE					;				[F8FE]
	lda	CIA1TI2L		; get CIA 1 timer B LB
	cmp	#$16			;.compare with ??
	bcc	A_F8FE			; loop if less

	adc	CMPO+1			; add tape timing constant max byte
	sta	CIA1TI1L		; save CIA 1 timer A LB

	txa				;.
	adc	CIA1TI2H		; add CIA 1 timer B HB
	sta	CIA1TI1H		; save CIA 1 timer A HB

	lda	Copy6522CRB		; read CIA 1 CRB shadow copy
	sta	CIA1CTR1		; save CIA 1 CRA
	sta	Copy6522CRA		; save CIA 1 CRA shadow copy

	lda	CIA1IRQ			; read CIA 1 ICR
	and	#$10			; mask 000x 0000, FLAG interrupt
	beq	A_F92A			; if no FLAG interrupt just exit

; else first call the IRQ routine
	lda	#>A_F92A		; set the return address HB
	pha				; push the return address HB

	lda	#<A_F92A		; set the return address LB
	pha				; push the return address LB

	jmp	SaveStatGoIRQ		; save the status and do the IRQ
					; routine			[FF43]

A_F92A					;				[F92A]
	cli				; enable interrupts
	rts


;******************************************************************************
;
;	On Commodore computers, the streams consist of four kinds of symbols
;	that denote different kinds of low-to-high-to-low transitions on the
;	read or write signals of the Commodore cassette interface.
;
;	A	A break in the communications, or a pulse with very long cycle
;		time.
;
;	B	A short pulse, whose cycle time typically ranges from 296 to 424
;		microseconds, depending on the computer model.
;
;	C	A medium-length pulse, whose cycle time typically ranges from
;		440 to 576 microseconds, depending on the computer model.
;
;	D	A long pulse, whose cycle time typically ranges from 600 to 744
;		microseconds, depending on the computer model.
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

TapeRead_IRQ				;				[F92C]
	ldx	CIA1TI2H		; read CIA 1 timer B HB

	ldy	#$FF			;.set $FF
	tya				;.A = $FF

	sbc	CIA1TI2L		; subtract CIA 1 timer B LB

	cpx	CIA1TI2H		; compare it with CIA 1 timer B HB
	bne	TapeRead_IRQ		; if timer LB rolled over loop

	stx	CMPO+1			; save tape timing constant max byte

	tax				;.copy $FF - T2C_l

	sty	CIA1TI2L		; save CIA 1 timer B LB
	sty	CIA1TI2H		; save CIA 1 timer B HB

	lda	#$19			; load timer B, timer B single shot,
					; start timer B
	sta	CIA1CTR2		; save CIA 1 CRB

	lda	CIA1IRQ			; read CIA 1 ICR
	sta	Copy6522ICR		; save CIA 1 ICR shadow copy

	tya				; y = $FF
	sbc	CMPO+1			; subtract tape timing constant max byte
					; A = $FF - T2C_h
	stx	CMPO+1			; save tape timing constant max byte
					; CMPO+1 = $FF - T2C_l
	lsr				;.A = $FF - T2C_h >> 1
	ror	CMPO+1			; shift tape timing constant max byte
					; CMPO+1 = $FF - T2C_l >> 1
	lsr				;.A = $FF - T2C_h >> 1
	ror	CMPO+1			; shift tape timing constant max byte
					; CMPO+1 = $FF - T2C_l >> 1
	lda	CMPO			; get tape timing constant min byte
	clc				; clear carry for add
	adc	#$3C			;.
	cmp	CMPO+1			; compare with tape timing constant max
					; byte compare with ($FFFF - T2C) >> 2
	bcs	A_F9AC			; branch if min+$3C >= ($FFFF-T2C) >> 2

;.min + $3C < ($FFFF - T2C) >> 2
	ldx	DPSW			;.get byte received flag
	beq	A_F969			;. if not byte received ??

	jmp	StoreTapeChar		;.store the tape character	[FA60]

A_F969					;				[F969]
	ldx	TEMPA3			;.get EOI flag byte
	bmi	A_F988			;.

	ldx	#$00			;.

	adc	#$30			;.
	adc	CMPO			; add tape timing constant min byte
	cmp	CMPO+1			; compare with tape timing constant max
					; byte
	bcs	A_F993			;.

	inx				;.

	adc	#$26			;.
	adc	CMPO			; add tape timing constant min byte
	cmp	CMPO+1			; compare with tape timing constant max
					; byte
	bcs	J_F997			;.

	adc	#$2C			;.
	adc	CMPO			; add tape timing constant min byte
	cmp	CMPO+1			; compare with tape timing constant max
					; byte
	bcc	A_F98B			;.

A_F988					;				[F988]
	jmp	J_FA10			;.				[FA10]

A_F98B					;				[F98B]
	lda	BITTS			; get the bit count
	beq	A_F9AC			; if all done go ??

	sta	BITCI			; save receiver bit count in
	bne	A_F9AC			; branch always

A_F993					;				[F993]
	inc	RINONE			; increment ?? start bit check flag
	bcs	A_F999			;.

J_F997					;				[F997]
	dec	RINONE			; decrement ?? start bit check flag
A_F999					;				[F999]
	sec				;.
	sbc	#$13			;.
	sbc	CMPO+1			; subtract tape timing constant max byte
	adc	SVXT			; add timing constant for tape
	sta	SVXT			; save timing constant for tape

	lda	TEMPA4			;.get tape bit cycle phase
	eor	#$01			;.
	sta	TEMPA4			;.save tape bit cycle phase
	beq	A_F9D5			;.

	stx	TEMPD7			;.
A_F9AC					;				[F9AC]
	lda	BITTS			; get the bit count
	beq	A_F9D2			; if all done go ??

	lda	Copy6522ICR		; read CIA 1 ICR shadow copy
	and	#$01			; mask 0000 000x, timer A interrupt
					; enabled
	bne	A_F9BC			; if timer A is enabled go ??

	lda	Copy6522CRA		; read CIA 1 CRA shadow copy
	bne	A_F9D2			; if ?? just exit

A_F9BC					;				[F9BC]
	lda	#$00			; clear A
	sta	TEMPA4			; clear the tape bit cycle phase
	sta	Copy6522CRA		; save CIA 1 CRA shadow copy

	lda	TEMPA3			;.get EOI flag byte
	bpl	A_F9F7			;.

	bmi	A_F988			; always ->

A_F9C9					;				[F9C9]
	ldx	#$A6			; set timimg max byte
	jsr	InitReadTape		; set timing			[F8E2]

	lda	PRTY			;.
	bne	A_F98B			;.
A_F9D2					;				[F9D2]
	jmp	End_RS232_NMI		; restore registers and exit interrupt
					;				[FEBC]
A_F9D5					;				[F9D5]
	lda	SVXT			; get timing constant for tape
	beq	A_F9E0			;.

	bmi	A_F9DE			;.

	dec	CMPO			; decrement tape timing constant min
					; byte
.byte	$2C
A_F9DE					;				[F9DE]
	inc	CMPO			; increment tape timing constant min
					; byte
A_F9E0					;				[F9E0]
	lda	#$00			;.
	sta	SVXT			; clear timing constant for tape

	cpx	TEMPD7			;.
	bne	A_F9F7			;.

	txa				;.
	bne	A_F98B			;.

	lda	RINONE			; get start bit check flag
	bmi	A_F9AC			;.

	cmp	#$10			;.
	bcc	A_F9AC			;.

	sta	SYNO			;.save cassette block synchronization
					; number
	bcs	A_F9AC			;.
A_F9F7					;				[F9F7]
	txa				;.
	eor	PRTY			;.
	sta	PRTY			;.

	lda	BITTS			;.
	beq	A_F9D2			;.

	dec	TEMPA3			;.decrement EOI flag byte
	bmi	A_F9C9			;.

	lsr	TEMPD7			;.
	ror	MYCH			;.parity count

	ldx	#$DA			; set timimg max byte
	jsr	InitReadTape		; set timing			[F8E2]

	jmp	End_RS232_NMI		; restore registers and exit interrupt
					;				[FEBC]
J_FA10					;				[FA10]
	lda	SYNO			; get cassette block synchron. number
	beq	A_FA18			;.

	lda	BITTS			;.
	beq	A_FA1F			;.

A_FA18					;				[FA18]
	lda	TEMPA3			;.get EOI flag byte
	bmi	A_FA1F			;.

	jmp	J_F997			;.				[F997]

A_FA1F					;				[FA1F]
	lsr	CMPO+1			; shift tape timing constant max byte

	lda	#$93			;.
	sec				;.
	sbc	CMPO+1			; subtract tape timing constant max byte
	adc	CMPO			; add tape timing constant min byte
	asl				;.
	tax				; copy timimg HB

	jsr	InitReadTape		; set timing			[F8E2]

	inc	DPSW			;.

	lda	BITTS			;.
	bne	A_FA44			;.

	lda	SYNO			; get cassette block synchron. number
	beq	A_FA5D			;.

	sta	BITCI			; save receiver bit count in

	lda	#$00			; clear A
	sta	SYNO			; clear cassette block synchron. number

	lda	#$81			; enable timer A interrupt
	sta	CIA1IRQ			; save CIA 1 ICR
	sta	BITTS			;.
A_FA44					;				[FA44]
	lda	SYNO			; get cassette block synchron. number
	sta	NXTBIT			;.
	beq	A_FA53			;.

	lda	#$00			;.
	sta	BITTS			;.

	lda	#$01			; disable timer A interrupt
	sta	CIA1IRQ			; save CIA 1 ICR
A_FA53					;				[FA53]
	lda	MYCH			;.parity count
	sta	ROPRTY			;.save RS232 parity byte

	lda	BITCI			; get receiver bit count in
	ora	RINONE			; OR with start bit check flag
	sta	RODATA			;.
A_FA5D					;				[FA5D]
	jmp	End_RS232_NMI		; restore registers and exit interrupt
					;				[FEBC]

;******************************************************************************
;
;## store character

StoreTapeChar				;				[FA60]
	jsr	SetCounter		; new tape byte setup		[FB97]
	sta	DPSW			; clear byte received flag

	ldx	#$DA			; set timimg max byte
	jsr	InitReadTape		; set timing			[F8E2]

	lda	FSBLK			;.get copies count
	beq	A_FA70			;.

	sta	INBIT			; save receiver input bit temporary
					; storage
A_FA70					;				[FA70]
	lda	#$0F			;.
	bit	RIDATA			;.
	bpl	A_FA8D			;.

	lda	NXTBIT			;.
	bne	A_FA86			;.

	ldx	FSBLK			;.get copies count
	dex				;.
	bne	A_FA8A			; if ?? restore registers and exit
					; interrupt
	lda	#$08			; set short block
	jsr	AorIecStatus		; OR into serial status byte	[FE1C]
	bne	A_FA8A			; restore registers and exit interrupt,
					; branch always
A_FA86					;				[FA86]
	lda	#$00			;.
	sta	RIDATA			;.
A_FA8A					;				[FA8A]
	jmp	End_RS232_NMI		; restore registers and exit interrupt
					;				[FEBC]
A_FA8D					;				[FA8D]
	bvs	A_FAC0			;.

	bne	A_FAA9			;.

	lda	NXTBIT			;.
	bne	A_FA8A			;.

	lda	RODATA			;.
	bne	A_FA8A			;.

	lda	INBIT			; get receiver input bit temporary
					; storage
	lsr				;.

	lda	ROPRTY			;.get RS232 parity byte
	bmi	A_FAA3			;.

	bcc	A_FABA			;.

	clc				;.
A_FAA3					;				[FAA3]
	bcs	A_FABA			;.

	and	#$0F			;.
	sta	RIDATA			;.
A_FAA9					;				[FAA9]
	dec	RIDATA			;.
	bne	A_FA8A			;.

	lda	#$40			;.
	sta	RIDATA			;.

	jsr	CopyIoAdr2Buf		; copy I/O start address to buffer
					; address			[FB8E]
	lda	#$00			;.
	sta	RIPRTY			;.
	beq	A_FA8A			;.
A_FABA					;				[FABA]
	lda	#$80			;.
	sta	RIDATA			;.
	bne	A_FA8A			; restore registers and exit interrupt,
					; branch always
A_FAC0					;				[FAC0]
	lda	NXTBIT			;.
	beq	A_FACE			;.

	lda	#$04			;.
	jsr	AorIecStatus		; OR into serial status byte	[FE1C]

	lda	#$00			;.
	jmp	J_FB4A			;.				[FB4A]

A_FACE					;				[FACE]
	jsr	ChkRdWrPtr		; check read/write pointer, return
					;Cb = 1 if pointer >= end	[FCD1]
	bcc	A_FAD6			;.

	jmp	J_FB48			;.				[FB48]

A_FAD6					;				[FAD6]
	ldx	INBIT			; get receiver input bit temporary
					; storage
	dex				;.
	beq	A_FB08			;.

	lda	LoadVerify2		; get load/verify flag
	beq	A_FAEB			; if load go ??

	ldy	#$00			; clear index
	lda	ROPRTY			;.get RS232 parity byte
	cmp	(SAL),Y			;.
	beq	A_FAEB			;.

	lda	#$01			;.
	sta	RODATA			;.
A_FAEB					;				[FAEB]
	lda	RODATA			;.
	beq	J_FB3A			;.

	ldx	#$3D			;.
	cpx	PTR1			;.
	bcc	A_FB33			;.

	ldx	PTR1			;.
	lda	SAL+1			;.
	sta	STACK+1,X		;.

	lda	SAL			;.
	sta	STACK,X			;.

	inx				;.
	inx				;.
	stx	PTR1			;.

	jmp	J_FB3A			;.				[FB3A]

A_FB08					;				[FB08]
	ldx	PTR2			;.
	cpx	PTR1			;.
	beq	A_FB43			;.

	lda	SAL			;.
	cmp	STACK,X			;.
	bne	A_FB43			;.

	lda	SAL+1			;.
	cmp	STACK+1,X		;.
	bne	A_FB43			;.

	inc	PTR2			;.
	inc	PTR2			;.

	lda	LoadVerify2		; get load/verify flag
	beq	A_FB2F			; if load ??

	lda	ROPRTY			;.get RS232 parity byte
	ldy	#$00			;.
	cmp	(SAL),Y			;.
	beq	A_FB43			;.

	iny				;.
	sty	RODATA			;.
A_FB2F					;				[FB2F]
	lda	RODATA			;.
	beq	J_FB3A			;.
A_FB33					;				[FB33]
	lda	#$10			;.
	jsr	AorIecStatus		; OR into serial status byte	[FE1C]
	bne	A_FB43			;.
J_FB3A					;				[FB3A]
	lda	LoadVerify2		; get load/verify flag
	bne	A_FB43			; if verify go ??

	tay				;.
	lda	ROPRTY			;.get RS232 parity byte
	sta	(SAL),Y			;.
A_FB43					;				[FB43]
	jsr	IncRdWrPtr		; increment read/write pointer	[FCDB]
	bne	A_FB8B			; restore registers and exit interrupt,
					; branch always
J_FB48					;				[FB48]
	lda	#$80			;.
J_FB4A					;				[FB4A]
	sta	RIDATA			;.

	sei				;.

	ldx	#$01			; disable timer A interrupt
	stx	CIA1IRQ			; save CIA 1 ICR

	ldx	CIA1IRQ			; read CIA 1 ICR

	ldx	FSBLK			;.get copies count
	dex				;.
	bmi	A_FB5C			;.

	stx	FSBLK			;.save copies count
A_FB5C					;				[FB5C]
	dec	INBIT			; decrement receiver input bit temporary
					; storage
	beq	A_FB68			;.

	lda	PTR1			;.
	bne	A_FB8B			; if ?? restore registers and exit
					; interrupt
	sta	FSBLK			;.save copies count
	beq	A_FB8B			; restore registers and exit interrupt,
					; branch always
A_FB68					;				[FB68]
	jsr	StopUsingTape		; restore everything for STOP	[FC93]
	jsr	CopyIoAdr2Buf		; copy I/O start address to buffer
					; address	[FB8E]

	ldy	#$00			; clear index
	sty	RIPRTY			; clear checksum
A_FB72					;				[FB72]
	lda	(SAL),Y			; get byte from buffer
	eor	RIPRTY			; XOR with checksum
	sta	RIPRTY			; save new checksum

	jsr	IncRdWrPtr		; increment read/write pointer	[FCDB]

	jsr	ChkRdWrPtr		; check read/write pointer, return
					;Cb = 1 if pointer >= end	[FCD1]
	bcc	A_FB72			; loop if not at end

	lda	RIPRTY			; get computed checksum
	eor	ROPRTY			; compare with stored checksum ??
	beq	A_FB8B			; if checksum ok restore registers and
					; exit interrupt
	lda	#$20			; else set checksum error
	jsr	AorIecStatus		; OR into the serial status byte [FE1C]
A_FB8B					;				[FB8B]
	jmp	End_RS232_NMI		; restore registers and exit interrupt
					;				[FEBC]

;******************************************************************************
;
; copy I/O start address to buffer address

CopyIoAdr2Buf				;				[FB8E]
	lda	STAL+1			; get I/O start address HB
	sta	SAL+1			; set buffer address HB

	lda	STAL			; get I/O start address LB
	sta	SAL			; set buffer address LB

	rts


;******************************************************************************
;
; new tape byte setup

SetCounter				;				[FB97]
	lda	#$08			; eight bits to do
	sta	TEMPA3			; set bit count

	lda	#$00			; clear A
	sta	TEMPA4			; clear tape bit cycle phase
	sta	BITCI			; clear start bit first cycle done flag
	sta	PRTY			; clear byte parity
	sta	RINONE			; clear start bit check flag, set no
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

WriteBitToTape				;				[FBA6]
	lda	ROPRTY			; get tape write byte
	lsr				; shift lsb into Cb

	lda	#$60			; set time constant LB for bit = 0
	bcc	SetTimeHByte		; branch if bit was 0

; set time constant for bit = 1 and toggle tape

SetTimeBitIs1				;				[FBAD]
	lda	#$B0			; set time constant LB for bit = 1

; write time constant and toggle tape

SetTimeHByte				;				[FBAF]
	ldx	#$00			; set time constant HB

; write time constant and toggle tape

WrTimeTgglTape				;				[FBB1]
	sta	CIA1TI2L		; save CIA 1 timer B LB
	stx	CIA1TI2H		; save CIA 1 timer B HB

	lda	CIA1IRQ			; read CIA 1 ICR

	lda	#$19			; load timer B, timer B single shot,
					; start timer B
	sta	CIA1CTR2		; save CIA 1 CRB

	lda	P6510			; read the 6510 I/O port
	eor	#$08			; toggle tape out bit
	sta	P6510			; save the 6510 I/O port

	and	#$08			; mask tape out bit
	rts


;******************************************************************************
;
; flag block done and exit interrupt

FlagBlockDone				;				[FBC8]
	sec				; set carry flag
	ror	RODATA			; set buffer address HB negative, flag
					; all sync, data and checksum bytes
					; written
	bmi	A_FC09			; restore registers and exit interrupt,
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

TapeWrite_IRQ				;				[FBCD]
	lda	BITCI			; get start bit first cycle done flag
	bne	A_FBE3			; if first cycle done go do rest of byte

; each byte sent starts with two half cycles of $0110 ststem clocks and the
; whole block ends with two more such half cycles

	lda	#$10			; set first start cycle time constant LB
	ldx	#$01			; set first start cycle time constant HB
	jsr	WrTimeTgglTape		; write time constant and toggle tape
					;				[FBB1]
	bne	A_FC09			; if first half cycle go restore
					; registers and exit interrupt
	inc	BITCI			; set start bit first start cycle done
					; flag
	lda	RODATA			; get buffer address HB
	bpl	A_FC09			; if block not complete go restore
					; registers and exit interrupt. The end
					; of a block is indicated by the tape
					; buffer HB b7 being set to 1
	jmp	J_FC57			; else do tape routine, block complete
					; exit				[FC57]

; continue tape byte write. the first start cycle, both half cycles of it, is
; complete so the routine drops straight through to here

A_FBE3					;				[FBE3]
	lda	RINONE			; get start bit check flag
	bne	A_FBF0			; if start bit is complete, go send byte

; after the two half cycles of $0110 ststem clocks the start bit is completed
; with two half cycles of $00B0 system clocks. this is the same as the first
; part of a 1 bit

	jsr	SetTimeBitIs1		; set time constant for bit = 1 and
					; toggle tape			[FBAD]
	bne	A_FC09			; if first half cycle go restore
					; registers and exit interrupt
	inc	RINONE			; set start bit check flag
	bne	A_FC09			; restore registers and exit interrupt,
					; branch always

; continue tape byte write. the start bit, both cycles of it, is complete so
; the routine drops straight through to here. now the cycle pairs for each bit,
; and the parity bit, are sent

A_FBF0					;				[FBF0]
	jsr	WriteBitToTape		; send lsb from tape write byte to tape
					;				[FBA6]
	bne	A_FC09			; if first half cycle go restore
					; registers and exit interrupt
; else two half cycles have been done
	lda	TEMPA4			; get tape bit cycle phase
	eor	#$01			; toggle b0
	sta	TEMPA4			; save tape bit cycle phase
	beq	A_FC0C			; if bit cycle phase complete go setup
					; for next bit

; each bit is written as two full cycles. a 1 is sent as a full cycle of $0160
; system clocks then a full cycle of $00C0 system clocks. a 0 is sent as a full
; cycle of $00C0 system clocks then a full cycle of $0160 system clocks. to do
; this each bit from the write byte is inverted during the second bit cycle
; phase. as the bit is inverted it is also added to the, one bit, parity count
; for this byte

	lda	ROPRTY			; get tape write byte
	eor	#$01			; invert bit being sent
	sta	ROPRTY			; save tape write byte

	and	#$01			; mask b0
	eor	PRTY			; EOR with tape write byte parity bit
	sta	PRTY			; save tape write byte parity bit
A_FC09					;				[FC09]
	jmp	End_RS232_NMI		; restore registers and exit interrupt
					;				[FEBC]

; the bit cycle phase is complete so shift out the just written bit and test
; for byte end

A_FC0C					;				[FC0C]
	lsr	ROPRTY			; shift bit out of tape write byte

	dec	TEMPA3			; decrement tape write bit count

	lda	TEMPA3			; get tape write bit count
	beq	A_FC4E			; if all data bits have been written, do
					; setup for sending parity bit next and
					; exit the interrupt
	bpl	A_FC09			; if all data bits are not yet sent,
					; just restore registers and exit
					; interrupt
; do next tape byte

; the byte is complete. the start bit, data bits and parity bit have been
; written to the tape so setup for the next byte

A_FC16					;				[FC16]
	jsr	SetCounter		; new tape byte setup		[FB97]

	cli				; enable the interrupts

	lda	CNTDN			; get cassette synchronization character
					; count
	beq	A_FC30			; if synchronisation characters done,
					; do block data

; at the start of each block sent to tape there are a number of synchronisation
; bytes that count down to the actual data. the commodore tape system saves two
; copies of all the tape data, the first is loaded and is indicated by the
; synchronisation bytes having b7 set, and the second copy is indicated by the
; synchronisation bytes having b7 clear. the sequence goes $09, $08, ..... $02,
; $01, data bytes

	ldx	#$00			; clear X
	stx	TEMPD7			; clear checksum byte

	dec	CNTDN			; decrement cassette synchronization
					; byte count
	ldx	FSBLK			; get cassette copies count
	cpx	#$02			; compare with load block indicator
	bne	A_FC2C			; branch if not the load block

	ora	#$80			; this is the load block so make the
					; synchronisation count
					; go $89, $88, ..... $82, $81
A_FC2C					;				[FC2C]
	sta	ROPRTY			; save the synchronisation byte as the
					; tape write byte
	bne	A_FC09			; restore registers and exit interrupt,
					; branch always

; the synchronization bytes have been done so now check and do the actual block
; data

A_FC30					;				[FC30]
	jsr	ChkRdWrPtr		; check read/write pointer, return
					; Cb = 1 if pointer >= end	[FCD1]
	bcc	A_FC3F			; if not all done yet go get the byte
					; to send
	bne	FlagBlockDone		; if pointer > end go flag block done
					; and exit interrupt

; else the block is complete, it only remains to write the checksum byte to the
; tape so setup for that
	inc	SAL+1			; increment buffer pointer HB, this
					; means block done branch will always be
					; taken next time without having to
					; worry about the LB wrapping to zero
	lda	TEMPD7			; get checksum byte
	sta	ROPRTY			; save checksum as tape write byte
	bcs	A_FC09			; restore registers and exit interrupt,
					; branch always

; the block isn't finished so get the next byte to write to tape

A_FC3F					;				[FC3F]
	ldy	#$00			; clear index
	lda	(SAL),Y			; get byte from buffer
	sta	ROPRTY			; save as tape write byte

	eor	TEMPD7			; XOR with checksum byte
	sta	TEMPD7			; save new checksum byte

	jsr	IncRdWrPtr		; increment read/write pointer	[FCDB]
	bne	A_FC09			; restore registers and exit interrupt,
					; branch always

; set parity as next bit and exit interrupt
A_FC4E					;				[FC4E]
	lda	PRTY			; get parity bit
	eor	#$01			; toggle it
	sta	ROPRTY			; save as tape write byte
A_FC54					;				[FC54]
	jmp	End_RS232_NMI		; restore registers and exit interrupt
					;	[FEBC]

; tape routine, block complete exit
J_FC57					;				[FC57]
	dec	FSBLK			; decrement copies remaining to
					; read/write
	bne	A_FC5E			; branch if more to do

	jsr	StopTapeMotor		; stop the cassette motor	[FCCA]
A_FC5E					;				[FC5E]
	lda	#$50			; set tape write leader count
	sta	INBIT			; save tape write leader count

	ldx	#$08			; set index for write tape leader vector

	sei				; disable the interrupts

	jsr	SetTapeVector		; set the tape vector		[FCBD]
	bne	A_FC54			; restore registers and exit interrupt,
					; branch always


;******************************************************************************
;
; write tape leader IRQ routine

TapeLeader_IRQ				;				[FC6A]
	lda	#$78			; set time constant LB for bit = leader
	jsr	SetTimeHByte		; write time constant and toggle tape
					;				[FBAF]
	bne	A_FC54			; if tape bit high restore registers
					; and exit interrupt
	dec	INBIT			; decrement cycle count
	bne	A_FC54			; if not all done restore registers and
					; exit interrupt
	jsr	SetCounter		; new tape byte setup		[FB97]

	dec	RIPRTY			; decrement cassette leader count
	bpl	A_FC54			; if not all done restore registers and
					; exit interrupt
	ldx	#$0A			; set index for tape write vector
	jsr	SetTapeVector		; set the tape vector		[FCBD]

	cli				; enable the interrupts

	inc	RIPRTY			; clear cassette leader counter, was $FF

	lda	FSBLK			; get cassette block count
	beq	A_FCB8			; if all done restore everything for
					; STOP and exit the interrupt
	jsr	CopyIoAdr2Buf		; copy I/O start address to buffer
					; address			[FB8E]
	ldx	#$09			; set nine synchronisation bytes
	stx	CNTDN			; save cassette synchron. byte count
	stx	RODATA			;.
	bne	A_FC16			; go do next tape byte, branch always


;******************************************************************************
;
; restore everything for STOP

StopUsingTape				;				[FC93]
	php				; save status

	sei				; disable the interrupts

	lda	VICCTR1			; read the vertical fine scroll and
					; control register
	ora	#$10			; unblank the screen
	sta	VICCTR1			; save the vertical fine scroll and
					; control register
	jsr	StopTapeMotor		; stop the cassette motor	[FCCA]

	lda	#$7F			; disable all interrupts
	sta	CIA1IRQ			; save CIA 1 ICR

	jsr	TimingPalNtsc		;.				[FDDD]

	lda	IRQTMP+1		; get saved IRQ vector HB
	beq	A_FCB6			; branch if null

	sta	CINV+1			; restore IRQ vector HB

	lda	IRQTMP			; get saved IRQ vector LB
	sta	CINV			; restore IRQ vector LB
A_FCB6					;				[FCB6]
	plp				; restore status

	rts


;******************************************************************************
;
; reset vector

A_FCB8					;				[FCB8]
	jsr	StopUsingTape		; restore everything for STOP	[FC93]
	beq	A_FC54			; restore registers and exit interrupt,
					; branch always

;******************************************************************************
;
; set tape vector

SetTapeVector				;				[FCBD]
	lda	TapeIrqVectors-8,X	; get tape IRQ vector LB
	sta	CINV			; set IRQ vector LB

	lda	TapeIrqVectors-7,X	; get tape IRQ vector HB
	sta	CINV+1			; set IRQ vector HB

	rts


;******************************************************************************
;
; stop the cassette motor

StopTapeMotor				;				[FCCA]
	lda	P6510			; read the 6510 I/O port
	ora	#$20			; mask xx1x, turn the cassette motor off
	sta	P6510			; save the 6510 I/O port

	rts


;******************************************************************************
;
; check read/write pointer
; return Cb = 1 if pointer >= end

ChkRdWrPtr				;				[FCD1]
	sec				; set carry for subtract
	lda	SAL			; get buffer address LB
	sbc	EAL			; subtract buffer end LB

	lda	SAL+1			; get buffer address HB
	sbc	EAL+1			; subtract buffer end HB

	rts


;******************************************************************************
;
; increment read/write pointer

IncRdWrPtr				;				[FCDB]
	inc	SAL			; increment buffer address LB
	bne	A_FCE1			; branch if no overflow

	inc	SAL+1			; increment buffer address LB
A_FCE1					;				[FCE1]
	rts


;******************************************************************************
;
; RESET, hardware reset starts here

RESET_routine				;				[FCE2]
	ldx	#$FF			; set X for stack
	sei				; disable the interrupts
	txs				; clear stack

	cld				; clear decimal mode

	jsr	Chk4Cartridge		; scan for autostart ROM at $8000 [FD02]
	bne	A_FCEF			; if not there continue startup

	jmp	(RomStart)		; else call ROM start code

A_FCEF					;				[FCEF]
	stx	VICCTR2			; read the horizontal fine scroll and
					;control register
	jsr	InitSidCIAIrq2		; initialise SID, CIA and IRQ	[FDA3]
	jsr	TestRAM2		; RAM test and find RAM end	[FD50]
	jsr	SetVectorsIO2		; restore default I/O vectors	[FD15]
	jsr	InitialiseVIC2		; initialise VIC and screen editor
					;				[FF5B]
	cli				; enable the interrupts

	jmp	(BasicCold)		; execute BASIC


;******************************************************************************
;
; scan for autostart ROM at $8000, returns Zb=1 if ROM found

Chk4Cartridge				;				[FD02]
	ldx	#$05			; five characters to test
A_FD04					;				[FD04]
	lda	RomSignature-1,X	; get test character
	cmp	RomIdentStr-1,X		; compare wiith byte in ROM space
	bne	D_FD0F			; exit if no match

	dex				; decrement index
	bne	A_FD04			; loop if not all done

D_FD0F					;				[FD0F]
	rts


;******************************************************************************
;
; autostart ROM signature

RomSignature				;				[FD10]
.text	"CBM80"				; CBM80


;******************************************************************************
;
; restore default I/O vectors

; This routine restores the default values of all system vectors used in KERNAL
; and BASIC routines and interrupts. The KERNAL VECTOR routine is used to read
; and alter individual system vectors.

SetVectorsIO2				;				[FD15]
	ldx	#<TblVectors		; pointer to vector table LB
	ldy	#>TblVectors		; pointer to vector table HB
S_FD19
	clc				; flag set vectors


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

CopyVectorsIO2				;				[FD1A]
	stx	MEMUSS			; save pointer LB
	sty	MEMUSS+1		; save pointer HB
	ldy	#$1F			; set byte count
A_FD20					;				[FD20]
	lda	CINV,Y			; read vector byte from vectors
	bcs	A_FD27			; branch if read vectors

	lda	(MEMUSS),Y		; read vector byte from (XY)
A_FD27					;				[FD27]
	sta	(MEMUSS),Y		; save byte to (XY)
	sta	CINV,Y			; save byte to vector
	dey				; decrement index
	bpl	A_FD20			; loop if more to do

	rts

; The above code works but it tries to write to the ROM. while this is usually
; harmless systems that use flash ROM may suffer. Here is a version that makes
; the extra write to RAM instead but is otherwise identical in function. ##
;
; set/read vectored I/O from (XY), Cb = 1 to read, Cb = 0 to set
;
;CopyVectorsIO2
;	STX	MEMUSS			; save pointer LB
;	STY	MEMUSS+1		; save pointer HB
;	LDY	#$1F			; set byte count
;A_FD20:
;	LDA	(MEMUSS),Y		; read vector byte from (XY)
;	BCC	A_FD29			; branch if set vectors
;
;	LDA	CINV,Y			; else read vector byte from vectors
;	STA	(MEMUSS),Y		; save byte to (XY)
;A_FD29:
;	STA	CINV,Y			; save byte to vector
;	DEY				; decrement index
;	BPL	A_FD20			; loop if more to do
;
;	RTS


;******************************************************************************
;
; kernal vectors

TblVectors				;				[FD30]
.word	IRQ_vector		; CINV	  IRQ vector
.word	BRK_vector		; BINV	  BRK vector
.word	NMI_vector		; NMINV	  NMI vector
.word	OpenLogFile2		; IOPEN	  open a logical file
.word	CloseLogFile2		; ICLOSE  close a specified logical file
.word	OpenChanInput		; ICHKIN  open channel for input
.word	OpenChanOutput		; ICKOUT  open channel for output
.word	CloseIoChans		; ICLRCH  close input and output channels
.word	ByteFromChan2		; IBASIN  input character from channel
.word	OutByteChan2		; IBSOUT  output character to channel
.word	Scan4StopKey		; ISTOP	  scan stop key
.word	GetByteInpDev		; IGETIN  get character from the input device
.word	ClsAllChnFil		; ICLALL  close all channels and files
.word	BRK_vector		; UserFn  user function

; Vector to user defined command, currently points to BRK.

; This appears to be a holdover from PET days, when the built-in machine
; language monitor would jump through the UserFn vector when it encountered a
; command that it did not understand, allowing the user to add new commands to
; the monitor.

; Although this vector is initialized to point to the routine called by
; STOP/RESTORE and the BRK interrupt, and is updated by the kernal vector
; routine at $FD57, it no longer has any function.

.word	LoadRamFrmDev22			; ILOAD	load
.word	SaveRamToDev22			; ISAVE	save


;******************************************************************************
;
; test RAM and find RAM end

TestRAM2				;				[FD50]
	lda	#$00			; clear A
	tay				; clear index
A_FD53					;				[FD53]
	sta	D6510+2,Y		; clear page 0, don't do $0000 or $0001
	sta	CommandBuf,Y		; clear page 2
	sta	IERROR,Y		; clear page 3

	iny				; increment index
	bne	A_FD53			; loop if more to do

	ldx	#<TapeBuffer		; set cassette buffer pointer LB
	ldy	#>TapeBuffer		; set cassette buffer pointer HB
	stx	TapeBufPtr		; save tape buffer start pointer LB
	sty	TapeBufPtr+1		; save tape buffer start pointer HB

	tay				; clear Y

	lda	#$03			; set RAM test pointer HB
	sta	STAL+1			; save RAM test pointer HB
A_FD6C					;				[FD6C]
	inc	STAL+1			; increment RAM test pointer HB
A_FD6E					;				[FD6E]
	lda	(STAL),Y		;.
	tax				;.

	lda	#$55			;.
	sta	(STAL),Y		;.
	cmp	(STAL),Y		;.
	bne	A_FD88			;.

	rol				;.
	sta	(STAL),Y		;.

	cmp	(STAL),Y		;.
	bne	A_FD88			;.

	txa				;.
	sta	(STAL),Y		;.

	iny				;.
	bne	A_FD6E			;.
	beq	A_FD6C			; always ->

A_FD88					;				[FD88]
	tya				;.
	tax				;.

	ldy	STAL+1			;.
	clc				;.
	jsr	SetTopOfMem2		; set the top of memory		[FE2D]

	lda	#$08			;.
	sta	StartOfMem+1		; save the OS start of memory HB

	lda	#$04			;.
	sta	HIBASE			; save the screen memory page

	rts


;******************************************************************************
;
; tape IRQ vectors

TapeIrqVectors				;				[FD9B]
.word	TapeLeader_IRQ			; $08	write tape leader IRQ routine
.word	TapeWrite_IRQ			; $0A	tape write IRQ routine
.word	IRQ_vector			; $0C	normal IRQ vector
.word	TapeRead_IRQ			; $0E	read tape bits IRQ routine


;******************************************************************************
;
; initialise SID, CIA and IRQ

InitSidCIAIrq2				;				[FDA3]
	lda	#$7F			; disable all interrupts
	sta	CIA1IRQ			; save CIA 1 ICR
	sta	CIA2IRQ			; save CIA 2 ICR
	sta	CIA1DRA			; save CIA 1 DRA, keyboard column drive

	lda	#$08			; set timer single shot
	sta	CIA1CTR1		; save CIA 1 CRA
	sta	CIA2CTR1		; save CIA 2 CRA
	sta	CIA1CTR2		; save CIA 1 CRB
	sta	CIA2CTR2		; save CIA 2 CRB

	ldx	#$00			; set all inputs
	stx	CIA1DDRB		; save CIA 1 DDRB, keyboard row
	stx	CIA2DDRB		; save CIA 2 DDRB, RS232 port
	stx	SIDFMVO			; clear the volume and filter select
					; register

	dex				; set X = $FF
	stx	CIA1DDRA		; save CIA 1 DDRA, keyboard column

	lda	#$07			; DATA out high, CLK out high, ATN out
					; high, RE232 Tx DATA, high, video
					; address 15 = 1, video address 14 = 1
	sta	CIA2DRA			; save CIA 2 DRA, serial port and video
					; address
	lda	#$3F			; set serial DATA and serial CLK input
	sta	CIA2DDRA		; save CIA 2 DDRA, serial port and video
					; address
	lda	#$E7			; set 1110 0111, motor off, enable I/O,
					; enable KERNAL, enable BASIC
	sta	P6510			; save the 6510 I/O port

	lda	#$2F			; set 0010 1111, 0 = input, 1 = output
	sta	D6510			; save 6510 I/O port direction register
TimingPalNtsc				;				[FDDD]
	lda	PALNTSC			; get the PAL/NTSC flag
	beq	A_FDEC			; if NTSC go set NTSC timing

; else set PAL timing
	lda	#$25			;.
	sta	CIA1TI1L		; save CIA 1 timer A LB

	lda	#$40			;.
	jmp	J_FDF3			;.				[FDF3]

A_FDEC					;				[FDEC]
	lda	#$95			;.
	sta	CIA1TI1L		; save CIA 1 timer A LB

	lda	#$42			;.
J_FDF3					;				[FDF3]
	sta	CIA1TI1H		; save CIA 1 timer A HB

	jmp	SetTimerIRQ		;.				[FF6E]


;******************************************************************************
;
; set filename

; this routine is used to set up the filename for the OPEN, SAVE, or LOAD
; routines. The accumulator must be loaded with the length of the file and XY
; with the pointer to filename, X being the LB. The address can be any
; valid memory address in the system where a string of characters for the file
; name is stored. If no filename desired the accumulator must be set to 0,
; representing a zero file length, in that case	 XY may be set to any memory
; address.

SetFileName2				;				[FDF9]
	sta	FNLEN			; set filename length
	stx	FNADR			; set filename pointer LB
	sty	FNADR+1			; set filename pointer HB

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

; ADDRESS	DEVICE
; =======	======
;  0		Keyboard
;  1		Cassette #1
;  2		RS-232C device
;  3		CRT display
;  4		Serial bus printer
;  8		CBM Serial bus disk drive

; device numbers of four or greater automatically refer to devices on the
; serial bus.

; a command to the device is sent as a secondary address on the serial bus
; after the device number is sent during the serial attention handshaking
; sequence. If no secondary address is to be sent Y should be set to $FF.

SetAddresses2				;				[FE00]
	sta	LA			; save the logical file
	stx	FA			; save the device number
	sty	SA			; save the secondary address

	rts


;******************************************************************************
;
; read I/O status word

; this routine returns the current status of the I/O device in the accumulator.
; The routine is usually called after new communication to an I/O device. The
; routine will give information about device status, or errors that have
; occurred during the I/O operation.

ReadIoStatus2				;				[FE07]
	lda	FA			; get the device number
	cmp	#$02			; compare device with RS232 device
	bne	A_FE1A			; if not RS232 device go ??

; get RS232 device status
	lda	RSSTAT			; get the RS232 status register
	pha				; save the RS232 status value

	lda	#$00			; clear A
	sta	RSSTAT			; clear the RS232 status register

	pla				; restore the RS232 status value
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

CtrlKernalMsg2				;				[FE18]
	sta	MSGFLG			; set message mode flag
A_FE1A					;				[FE1A]
	lda	STATUS			; read the serial status byte


;******************************************************************************
;
; OR into the serial status byte

AorIecStatus				;				[FE1C]
	ora	STATUS			; OR with the serial status byte
	sta	STATUS			; save the serial status byte

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

IecTimeout2				;				[FE21]
	sta	TIMOUT			; save serial bus timeout flag

	rts


;******************************************************************************
;
; read/set the top of memory, Cb = 1 to read, Cb = 0 to set

; this routine is used to read and set the top of RAM. When this routine is
; called with the carry bit set the pointer to the top of RAM will be loaded
; into XY. When this routine is called with the carry bit clear XY will be
; saved as the top of memory pointer changing the top of memory.

TopOfMem2				;				[FE25]
	bcc	SetTopOfMem2		; if Cb clear go set the top of memory


;******************************************************************************
;
; read the top of memory

ReadTopOfMem				;				[FE27]
	ldx	EndOfMem		; get memory top LB
	ldy	EndOfMem+1		; get memory top HB


;******************************************************************************
;
; set the top of memory

SetTopOfMem2				;				[FE2D]
	stx	EndOfMem		; set memory top LB
	sty	EndOfMem+1		; set memory top HB

	rts


;******************************************************************************
;
; read/set the bottom of memory, Cb = 1 to read, Cb = 0 to set

; this routine is used to read and set the bottom of RAM. When this routine is
; called with the carry bit set the pointer to the bottom of RAM will be loaded
; into XY. When this routine is called with the carry bit clear XY will be
; saved as the bottom of memory pointer changing the bottom of memory.

BottomOfMem2				;				[FE34]
	bcc	A_FE3C			; if Cb clear go set bottom of memory

	ldx	StartOfMem		; get the OS start of memory LB
	ldy	StartOfMem+1		; get the OS start of memory HB

; set the bottom of memory

A_FE3C					;				[FE3C]
	stx	StartOfMem		; save the OS start of memory LB
	sty	StartOfMem+1		; save the OS start of memory HB

	rts


;******************************************************************************
;
; NMI vector

NMI_routine				;				[FE43]
	sei				; disable the interrupts

	jmp	(NMINV)			; do NMI vector


;******************************************************************************
;
; NMI handler

NMI_vector				;				[FE47]
	pha				; save A

	txa				; copy X
	pha				; save X

	tya				; copy Y
	pha				; save Y

	lda	#$7F			; disable all interrupts
	sta	CIA2IRQ			; save CIA 2 ICR

	ldy	CIA2IRQ			; NMI from RS-232 ?
	bmi	RS232_NMI		; yes, ->

	jsr	Chk4Cartridge		; scan for autostart ROM at $8000 [FD02]
	bne	A_FE5E			; branch if no autostart ROM

	jmp	(RomIRQ)		; else do autostart ROM break entry

A_FE5E					;				[FE5E]
	jsr	IncrClock22		; increment real time clock	[F6BC]

	jsr	ScanStopKey		; scan stop key			[FFE1]
	bne	RS232_NMI		; if not [STOP] restore registers and
					; exit interrupt


;******************************************************************************
;
; user function default vector
; BRK handler

BRK_vector				;				[FE66]
	jsr	SetVectorsIO2		; restore default I/O vectors	[FD15]
	jsr	InitSidCIAIrq2		; initialise SID, CIA and IRQ	[FDA3]
	jsr	InitScreenKeyb		; initialise the screen and keyboard
					;				[E518]
	jmp	(BasicNMI)		; do BASIC break entry


;******************************************************************************
;
; RS232 NMI routine

RS232_NMI				;				[FE72]
	tya				;.
	and	ENABL			; AND with RS-232 interrupt enable byte
	tax				;.

	and	#$01			;.
	beq	A_FEA3			;.

	lda	CIA2DRA			; read CIA 2 DRA, serial port and video
					; address
	and	#$FB			; mask x0xx, clear RS232 Tx DATA
	ora	NXTBIT			; OR in the RS232 transmit data bit
	sta	CIA2DRA			; save CIA 2 DRA, serial port and video
					; address
	lda	ENABL			; get RS-232 interrupt enable byte
	sta	CIA2IRQ			; save CIA 2 ICR

	txa				;.
	and	#$12			;.
	beq	J_FE9D			;.

	and	#$02			;.
	beq	A_FE9A			;.

	jsr	ReadFromRS232		;.				[FED6]
	jmp	J_FE9D			;.				[FE9D]

A_FE9A					;				[FE9A]
	jsr	WriteToRS232		;.				[FF07]
J_FE9D					;				[FE9D]
	jsr	RS232_TX_NMI		;.				[EEBB]
	jmp	J_FEB6			;.				[FEB6]

A_FEA3					;				[FEA3]
	txa				; get active interrupts back
	and	#$02			; mask ?? interrupt
	beq	A_FEAE			; branch if not ?? interrupt

; was ?? interrupt
	jsr	ReadFromRS232		;.				[FED6]
	jmp	J_FEB6			;.				[FEB6]

A_FEAE					;				[FEAE]
	txa				; get active interrupts back
	and	#$10			; mask CB1 interrupt, Rx data bit
					; transition
	beq	J_FEB6			; if no bit restore registers and exit
					; interrupt
	jsr	WriteToRS232		;.				[FF07]
J_FEB6					;				[FEB6]
	lda	ENABL			; get RS-232 interrupt enable byte
	sta	CIA2IRQ			; save CIA 2 ICR
End_RS232_NMI				;				[FEBC]
	pla				; pull Y
	tay				; restore Y

	pla				; pull X
	tax				; restore X

	pla				; restore A

	rti


;******************************************************************************
;
; baud rate word is calculated from ..
;
; (system clock / baud rate) / 2 - 100
;
;		system clock
;		------------
; PAL		  985248 Hz
; NTSC		 1022727 Hz

; baud rate tables for NTSC C64

TblBaudNTSC				;				[FEC2]
.word	$27C1				;   50	 baud	1027700
.word	$1A3E				;   75	 baud	1022700
.word	$11C5				;  110	 baud	1022780
.word	$0E74				;  134.5 baud	1022200
.word	$0CED				;  150	 baud	1022700
.word	$0645				;  300	 baud	1023000
.word	$02F0				;  600	 baud	1022400
.word	$0146				; 1200	 baud	1022400
.word	$00B8				; 1800	 baud	1022400
.word	$0071				; 2400	 baud	1022400


;******************************************************************************
;
; Read from RS-232

ReadFromRS232				;				[FED6]
	lda	CIA2DRB			; read CIA 2 DRB, RS232 port
	and	#$01			; mask 0000 000x, RS232 Rx DATA
	sta	INBIT			; save the RS232 received data bit

	lda	CIA2TI2L		; get CIA 2 timer B LB
	sbc	#$1C			;.
	adc	BAUDOF			;.
	sta	CIA2TI2L		; save CIA 2 timer B LB

	lda	CIA2TI2H		; get CIA 2 timer B HB
	adc	BAUDOF+1		;.
	sta	CIA2TI2H		; save CIA 2 timer B HB

	lda	#$11			; set timer B single shot, start timer B
	sta	CIA2CTR2		; save CIA 2 CRB

	lda	ENABL			; get RS-232 interrupt enable byte
	sta	CIA2IRQ			; save CIA 2 ICR

	lda	#$FF			;.
	sta	CIA2TI2L		; save CIA 2 timer B LB
	sta	CIA2TI2H		; save CIA 2 timer B HB

	jmp	RS232_RX_NMI		;.				[EF59]



;******************************************************************************
;
; Write to RS-232

WriteToRS232				;				[FF07]
	lda	M51AJB			; nonstandard bit timing LB
	sta	CIA2TI2L		; save CIA 2 timer B LB

	lda	M51AJB+1		; nonstandard bit timing HB
	sta	CIA2TI2H		; save CIA 2 timer B HB

	lda	#$11			; set timer B single shot, start timer B
	sta	CIA2CTR2		; save CIA 2 CRB

	lda	#$12			;.
	eor	ENABL			; EOR with RS-232 interrupt enable byte
	sta	ENABL			; save RS-232 interrupt enable byte

	lda	#$FF			;.
	sta	CIA2TI2L		; save CIA 2 timer B LB
	sta	CIA2TI2H		; save CIA 2 timer B HB

	ldx	BITNUM			;.
	stx	BITCI			;.

	rts


;******************************************************************************
;
; Set the timer for the Baud rate

SetTimerBaudR				;				[FF2E]
	tax				;.

	lda	M51AJB+1		; nonstandard bit timing HB
	rol				;.
	tay				;.

	txa				;.
	adc	#$C8			;.
	sta	BAUDOF			;.

	tya				;.
	adc	#$00			; add any carry
	sta	BAUDOF+1		;.

	rts


;******************************************************************************
;
; unused bytes

;S_FF41
	nop				; waste cycles
	nop				; waste cycles


;******************************************************************************
;
; save the status and do the IRQ routine

SaveStatGoIRQ				;				[FF43]
	php				; save the processor status

	pla				; pull the processor status
	and	#$EF			; mask xxx0, clear the break bit
	pha				; save the modified processor status


;******************************************************************************
;
; IRQ vector

IRQ_routine				;				[FF48]
	pha				; save A

	txa				; copy X
	pha				; save X

	tya				; copy Y
	pha				; save Y

	tsx				; copy stack pointer
	lda	STACK+4,X		; get stacked status register
	and	#$10			; mask BRK flag
	beq	A_FF58			; branch if not BRK

	jmp	(BINV)			; else do BRK vector (iBRK)

A_FF58					;				[FF58]
	jmp	(CINV)			; do IRQ vector (iIRQ)


;******************************************************************************
;
; initialise VIC and screen editor

InitialiseVIC2				;				[FF5B]
	jsr	InitScreenKeyb		; initialise the screen and keyboard
					;				[E518]
A_FF5E					;				[FF5E]
	lda	VICLINE			; read the raster compare register
	bne	A_FF5E			; loop if not raster line $00

	lda	VICIRQ			; read the vic interrupt flag register
	and	#$01			; mask the raster compare flag
	sta	PALNTSC			; save the PAL/NTSC flag
	jmp	TimingPalNtsc		;.				[FDDD]


;******************************************************************************
;
; Set the timer that generates the interrupts

SetTimerIRQ				;				[FF6E]
	lda	#$81			; enable timer A interrupt
	sta	CIA1IRQ			; save CIA 1 ICR

	lda	CIA1CTR1		; read CIA 1 CRA
	and	#$80			; mask x000 0000, TOD clock
	ora	#$11			; mask xxx1 xxx1, load timer A, start
					; timer A
	sta	CIA1CTR1		; save CIA 1 CRA

	jmp	IecClockL		; set the serial clock out low and
					; return			[EE8E]


;******************************************************************************
;
; unused

;S_FF80
.byte	$03				;.


;******************************************************************************
;
; initialise VIC and screen editor

InitialiseVIC				;				[FF81]
	jmp	InitialiseVIC2		; initialise VIC and screen editor
					;				[FF5B]

;******************************************************************************
;
; initialise SID, CIA and IRQ, unused

InitSidCIAIrq				;				[FF84]
	jmp	InitSidCIAIrq2		; initialise SID, CIA and IRQ	[FDA3]


;******************************************************************************
;
; RAM test and find RAM end

;F_FF87					;				[FF87]
	jmp	TestRAM2		; RAM test and find RAM end	[FD50]


;******************************************************************************
;
; restore default I/O vectors

; this routine restores the default values of all system vectors used in KERNAL
; and BASIC routines and interrupts.

SetVectorsIO				;				[FF8A]
	jmp	SetVectorsIO2		; restore default I/O vectors	[FD15]


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

CopyVectorsIO				;				[FF8D]
	jmp	CopyVectorsIO2		; read/set vectored I/O		[FD1A]


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

CtrlKernalMsg				;				[FF90]
	jmp	CtrlKernalMsg2		; control kernal messages	[FE18]


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

SAafterLISTEN				;				[FF93]
	jmp	SAafterLISTEN2		; send secondary address after LISTEN
					;	[EDB9]

;******************************************************************************
;
; send secondary address after TALK

; this routine transmits a secondary address on the serial bus for a TALK
; device. This routine must be called with a number between 4 and 31 in the
; accumulator. The routine will send this number as a secondary address command
; over the serial bus. This routine can only be called after a call to the TALK
; routine. It will not work after a LISTEN.

SAafterTALK				;				[FF96]
	jmp	SAafterTALK2		; send secondary address after TALK
					;				[EDC7]

;******************************************************************************
;
; read/set the top of memory

; this routine is used to read and set the top of RAM. When this routine is
; called with the carry bit set the pointer to the top of RAM will be loaded
; into XY. When this routine is called with the carry bit clear XY will be
; saved as the top of memory pointer changing the top of memory.

TopOfMem				;				[FF99]
	jmp	TopOfMem2		; read/set the top of memory	[FE25]


;******************************************************************************
;
; read/set the bottom of memory

; this routine is used to read and set the bottom of RAM. When this routine is
; called with the carry bit set the pointer to the bottom of RAM will be loaded
; into XY. When this routine is called with the carry bit clear XY will be
; saved as the bottom of memory pointer changing the bottom of memory.

BottomOfMem				;				[FF9C]
	jmp	BottomOfMem2		; read/set the bottom of memory	[FE34]


;******************************************************************************
;
; scan the keyboard

; this routine will scan the keyboard and check for pressed keys. It is the
; same routine called by the interrupt handler. If a key is down, its ASCII
; value is placed in the keyboard queue.

ScanKeyboard				;				[FF9F]
	jmp	ScanKeyboard2		; scan keyboard			[EA87]


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

IecTimeout				;				[FFA2]
	jmp	IecTimeout2		; set timeout on serial bus	[FE21]


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

IecByteIn				;				[FFA5]
	jmp	IecByteIn2		; input byte from serial bus	[EE13]


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

IecByteOut				;				[FFA8]
	jmp	IecByteOut2		; output byte to serial bus	[EDDD]


;******************************************************************************
;
; command serial bus to UNTALK

; this routine will transmit an UNTALK command on the serial bus. All devices
; previously set to TALK will stop sending data when this command is received.

IecUNTALK				;				[FFAB]
	jmp	IecUNTALK2		; command serial bus to UNTALK	[EDEF]


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

IecUNLISTEN				;				[FFAE]
	jmp	IecUNLISTEN2		; command serial bus to UNLISTEN [EDFE]


;******************************************************************************
;
; command devices on the serial bus to LISTEN

; this routine will command a device on the serial bus to receive data. The
; accumulator must be loaded with a device number between 4 and 31 before
; calling this routine. LISTEN convert this to a listen address then transmit
; this data as a command on the serial bus. The specified device will then go
; into listen mode and be ready to accept information.

CmdLISTEN				;				[FFB1]
	jmp	CmdLISTEN2		; command devices on the serial bus to
					; LISTEN			[ED0C]

;******************************************************************************
;
; command serial bus device to TALK

; to use this routine the accumulator must first be loaded with a device number
; between 4 and 30. When called this routine converts this device number to a
; talk address. Then this data is transmitted as a command on the Serial bus.

CmdTALK					;				[FFB4]
	jmp	CmdTALK2		; command serial bus device to TALK
					;				[ED09]

;******************************************************************************
;
; read I/O status word

; this routine returns the current status of the I/O device in the accumulator.
; The routine is usually called after new communication to an I/O device. The
; routine will give information about device status, or errors that have
; occurred during the I/O operation.

ReadIoStatus				;				[FFB7]
	jmp	ReadIoStatus2		; read I/O status word		[FE07]


;******************************************************************************
;
; set logical, first and second addresses

; this routine will set the logical file number, device address, and secondary
; address, command number, for other KERNAL routines.

; the logical file number is used by the system as a key to the file table
; created by the OPEN file routine. Device addresses can range from 0 to 30.
; The following codes are used by the computer to stand for the following CBM
; devices:

; ADDRESS	DEVICE
; =======	======
;  0		Keyboard
;  1		Cassette #1
;  2		RS-232C device
;  3		CRT display
;  4		Serial bus printer
;  8		CBM Serial bus disk drive

; device numbers of four or greater automatically refer to devices on the
; serial bus.

; a command to the device is sent as a secondary address on the serial bus
; after the device number is sent during the serial attention handshaking
; sequence. If no secondary address is to be sent Y should be set to $FF.

SetAddresses				;				[FFBA]
	jmp	SetAddresses2		; set logical, first and second
					; addresses			[FE00]

;******************************************************************************
;
; set the filename

; this routine is used to set up the filename for the OPEN, SAVE, or LOAD
; routines. The accumulator must be loaded with the length of the file and XY
; with the pointer to filename, X being th LB. The address can be any
; valid memory address in the system where a string of characters for the file
; name is stored. If no filename desired the accumulator must be set to 0,
; representing a zero file length, in that case	 XY may be set to any memory
; address.

SetFileName				;				[FFBD]
	jmp	SetFileName2		; set the filename		[FDF9]


;******************************************************************************
;
; open a logical file

; this routine is used to open a logical file. Once the logical file is set up
; it can be used for input/output operations. Most of the I/O KERNAL routines
; call on this routine to create the logical files to operate on. No arguments
; need to be set up to use this routine, but both the SETLFS, SetAddresses, and
; SETNAM, SetFileName, KERNAL routines must be called before using this routine.

OpenLogFile				;				[FFC0]
	jmp	(IOPEN)			; do open a logical file


;******************************************************************************
;
; close a specified logical file

; this routine is used to close a logical file after all I/O operations have
; been completed on that file. This routine is called after the accumulator is
; loaded with the logical file number to be closed, the same number used when
; the file was opened using the OPEN routine.

CloseLogFile				;				[FFC3]
	jmp	(ICLOSE)		; do close a specified logical file


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
;	3 : file not open
;	5 : device not present
;	6 : file is not an input file

OpenChan4Inp				;				[FFC6]
	jmp	(ICHKIN)		; do open channel for input


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
;	3 : file not open
;	5 : device not present
;	7 : file is not an output file

OpenChan4Outp				;				[FFC9]
	jmp	(ICKOUT)		; do open channel for output


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

CloseIoChannls				;				[FFCC]
	jmp	(ICLRCH)		; do close input and output channels


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

ByteFromChan				;				[FFCF]
	jmp	(IBASIN)		; do input character from channel


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

OutByteChan				;				[FFD2]
	jmp	(IBSOUT)		; do output character to channel


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

LoadRamFrmDev				;				[FFD5]
	jmp	LoadRamFrmDev2		; load RAM from a device	[F49E]


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

SaveRamToDev				;				[FFD8]
	jmp	SaveRamToDev2		; save RAM to device		[F5DD]


;******************************************************************************
;
; set the real time clock

; the system clock is maintained by an interrupt routine that updates the clock
; every 1/60th of a second. The clock is three bytes long which gives the
; capability to count from zero up to 5,184,000 jiffies - 24 hours plus one
; jiffy. At that point the clock resets to zero. Before calling this routine to
; set the clock the new time, in jiffies, should be in YXA, the accumulator
; containing the most significant byte.

SetClock				;				[FFDB]
	jmp	SetClock2		; set real time clock		[F6E4]


;******************************************************************************
;
; read the real time clock

; this routine returns the time, in jiffies, in AXY. The accumulator contains
; the most significant byte.

ReadClock				;				[FFDE]
	jmp	ReadClock2		; read real time clock		[F6DD]


;******************************************************************************
;
; scan the stop key

; if the STOP key on the keyboard is pressed when this routine is called the Z
; flag will be set. All other flags remain unchanged. If the STOP key is not
; pressed then the accumulator will contain a byte representing the last row of
; the keyboard scan.

; The user can also check for certain other keys this way.

ScanStopKey				;				[FFE1]
	jmp	(ISTOP)			; do scan stop key


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

GetCharInpDev				;				[FFE4]
	jmp	(IGETIN)		; do get character from input device


;******************************************************************************
;
; close all channels and files

; this routine closes all open files. When this routine is called, the pointers
; into the open file table are reset, closing all files. Also the routine
; automatically resets the I/O channels.

CloseAllChan				;				[FFE7]
	jmp	(ICLALL)		; do close all channels and files


;******************************************************************************
;
; increment real time clock

; this routine updates the system clock. Normally this routine is called by the
; normal KERNAL interrupt routine every 1/60th of a second. If the user program
; processes its own interrupts this routine must be called to update the time.
; Also, the STOP key routine must be called if the stop key is to remain
; functional.

IncrClock				;				[FFEA]
	jmp	IncrClock2		; increment real time clock	[F69B]


;******************************************************************************
;
; return X,Y organization of screen

; this routine returns the x,y organisation of the screen in X,Y

GetSizeScreen				;				[FFED]
	jmp	GetSizeScreen2		; return X,Y organization of screen
					;				[E505]


;******************************************************************************
;
; read/set X,Y cursor position

; this routine, when called with the carry flag set, loads the current position
; of the cursor on the screen into the X and Y registers. X is the column
; number of the cursor location and Y is the row number of the cursor. A call
; with the carry bit clear moves the cursor to the position determined by the X
; and Y registers.

CursorPosXY				;				[FFF0]
	jmp	CursorPosXY2		; read/set X,Y cursor position	[E50A]


;******************************************************************************
;
; return the base address of the I/O devices

; this routine will set XY to the address of the memory section where the
; memory mapped I/O devices are located. This address can then be used with an
; offset to access the memory mapped I/O devices in the computer.

GetAddrIoDevs				;				[FFF3]
	jmp	GetAddrIoDevs2		; return the base address of the I/O
					; devices			[E500]


;******************************************************************************
;

;S_FFF6
.text	"rrby"

; hardware vectors

;S_FFFA
.word	NMI_routine			; NMI vector			[FE43]
.word	RESET_routine			; RESET vector			[FCE2]
.word	IRQ_routine			; IRQ vector			[FF48]


;******************************************************************************



