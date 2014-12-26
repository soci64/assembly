;******************************************************************************
;******************************************************************************
;
; The almost completely commented C64 ROM disassembly. V1.01 Lee Davison 2012
;
; Changed by Ruud Baltissen 2014
; - I splitted the original file in four parts so one can use only those parts 
;   (s)he can use for her/his projects
; - addapted to his own assembler, MP-ASM
; - changed names of routines and variables, LAzB_xx and LAzB_xxxx, 
;   into more logical ones
; - length of lines < 81 (if possible)
; - combined low and high bytes to one variable

; Many references were used to complete this disassembly including, but not
; limited to, "Mapping the Vic 20", "Mapping the C64", "C64 Programmers
; reference", "C64 user guide", "The complete Commodore inner space anthology",
; "VIC Revealed" and various text files, pictures and other documents.


.include "C64-var.asm"
.include "C64-bas.asm"
.include "C64-ker.asm"



