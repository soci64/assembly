WDTEST	.macro
	.ifeq * & $03
	nop
	.endif
	.endm
