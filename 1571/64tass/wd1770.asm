WDTEST  .macro
	.ifeq * & $03	; lower two bits cannot be zero
	nop		; fill address error
	.endif
	.endm

NODRRD  .macro		; read nodrv,x absolute
	.byte $bd,$ff,$00
	.endm

NODRWR  .macro		; write nodrv,x absolute
	.byte $9d,$ff,$00
	.endm
