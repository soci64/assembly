
		.cpu "6502i"

TALK		= %01000000
LISTEN		= %00100000
LOCK_FLAG	= %01000000
DISABLED	= $12
WRITE_PROTECT	= %00010000
STEPPER_MASK	= %00000011
CLOCK_OUT	= %00001000
CLOCK_IN	= %00000100
DATA_OUT	= %00000010
DATA_IN		= %00000001

ALL_OK		= 1
NO_HEADER	= 2
NO_SYNC		= 3
BLOCK_NOT_FOUND = 4
CHECKSUM_ERROR	= 5
VERIFY_ERROR	= 7

ERROR_MASK	= %00001111

p0		= $0
p2		= $2
job_tr		= $6
job_sc		= $7
diskid		= $12
z14		= $14
z15		= $15
id		= $16
track		= $18
sector		= $19
hchksum		= $1a
temp		= $1b
z1c		= $1c
z20		= $20
z22		= $22
z24		= $24
z25		= $25
z26		= $26
z27		= $27
z28		= $28
z29		= $29
z2a		= $2a
z2b		= $2b
z2e		= $2e
buffp		= $30
p32		= $32
z34		= $34
z36		= $36
z38		= $38
chksum		= $3a
z3d		= $3d
z3e		= $3e
z3f		= $3f
z41		= $41
max_sectors	= $43
z45		= $45
z47		= $47
z48		= $48
head_step_count = $4a
z4b		= $4b
z50		= $50
z51		= $51
z52		= $52
z53		= $53
z54		= $54
z55		= $55
z5e		= $5e
z61		= $61
z62		= $62
z64		= $64
z6d		= $6d
z6f		= $6f
z75		= $75
z76		= $76
listen_address	= $77
talk_address	= $78
listen_active	= $79
talk_active	= $7a
z7f		= $7f
current_track	= $80
current_sector	= $81
z82		= $82
z83		= $83
z84		= $84
z85		= $85
p86		= $86
p88		= $88
p8a		= $8a
p8c		= $8c
p94		= $94
z99		= $99
errp		= $a5
za7		= $a7
zae		= $ae
zb5		= $b5
zbb		= $bb
zec		= $ec
tf2		= $f2
zf7		= $f7
zf8		= $f8
zff		= $ff
t100		= $100
input		= $200
m22a		= $22a
t22b		= $22b
t23e		= $23e
m243		= $243
t244		= $244
m24a		= $24a
m254		= $254
t25b		= $25b
input_length	= $274
m280		= $280
m2f9		= $2f9
t500		= $500
t600		= $600
m620		= $620
format_retry	= $623
m624		= $624
m625		= $625
m626		= $626
format_sector	= $628
via1		.block
prb		= $1800
ddrb		= $1802
ddra		= $1803
t1ch		= $1805
pran		= $180f
		.bend
via2		.block
prb		= $1c00
pra		= $1c01
ddrb		= $1c02
ddra		= $1c03
pcr		= $1c0c
		.bend

pia		.block
DDRN		= %00000100
pra		= $5000
cra		= $5001
		.bend

flags		= $6000
ram_flag	= $6000
fast_flag	= $6001
verify_flag	= $6002
cable_flag	= $6003
extend_flag	= $6004
m6006		= $6006
m6007		= $6007
m6008		= $6008
m6009		= $6009
cable_ok	= $600a
m600b		= $600b
tc_flags	= $600c
p6021		= $6021
max_track	= $6023			; last track
cached_track	= $6024
track0_flag	= $6025
zp_backup	= $6026
ram_backup	= $7000
t7800		= $7800
t79d7		= $79d7

lc194		= $c194			; prepare message
lc1a3		= $c1a3			; prepare message 2
lc1c8		= $c1c8			; message,00,00
lc1ee		= $c1ee			; check input line
lc823		= $c823			; scratch
lc8a7		= $c8a7			; erase end
lc8b9		= $c8b9			; set filetype
lc8c1		= $c8c1			; old backup
lcfe8		= $cfe8
lcff8		= $cff8
ld075		= $d075
ld07d		= $d07d
ld125		= $d125
ld12f		= $d12f
ld159		= $d159
ld1a3		= $d1a3
ld1e2		= $d1e2
ld227		= $d227
ld307		= $d307
ld373		= $d373
ld3c0		= $d3c0
ld3e8		= $d3e8
ld3fa		= $d3fa
ld400		= $d400
ld403		= $d403
ld40e		= $d40e
ld414		= $d414
ld421		= $d421
ld4e8		= $d4e8
ld554		= $d554
check_ts	= $d55f
ld599		= $d599
ld63f		= $d63f
ld6d3		= $d6d3
ld852		= $d852
ld8eb		= $d8eb
ld8f0		= $d8f0
ldac0		= $dac0
ldcb6		= $dcb6
lddb7		= $ddb7
ldf93		= $df93
le0ab		= $e0ab
le120		= $e120
le60a		= $e60a
le645		= $e645
le6aa		= $e6aa
le6c7		= $e6c7
le85b		= $e85b
le8d7		= $e8d7
le90f		= $e90f
le995		= $e995
le9a5		= $e9a5
le9ae		= $e9ae
le9b7		= $e9b7
le9c9		= $e9c9
le9df		= $e9df
lea2e		= $ea2e
lea6e		= $ea6e
leb1f		= $eb1f
lef5f		= $ef5f
lef90		= $ef90
lf0df		= $f0df
lf119		= $f119
lf121		= $f121
lf259		= $f259
lf390		= $f390
lf395		= $f395
xf505		= $f505
lf556		= $f556
lf581		= $f581
lf5e9		= $f5e9
lf78f		= $f78f
lf7e8		= $f7e8
lf934		= $f934
lf961		= $f961
lf969		= $f969			; disk controller error
lf982		= $f982
lf991		= $f991			; motor off
lf99c		= $f99c			; job loop
lf9fa		= $f9fa
lfaa5		= $faa5			; prepare head move
lfabe		= $fabe
lfda3		= $fda3			; track erase (sync)
lfddb		= $fddb			; format end
lfe00		= $fe00			; switch to read
lfe0e		= $fe0e			; track erase
directory_track = $fe85			; directory track

		*= $8000
		.binary "1541-II.355640-01.bin"

		*= $a000
;---------------
la000_la34b	jmp la34b

la003		jmp command_x

la006_la024	jmp la024

la009_la313	jmp la313

la00c_la117	jmp la117

la00f_la81f	jmp la81f

la012_la9ce	jmp la9ce

la015_la902	jmp la902

xa018_la4a8	jmp la4a8

		jmp la3a3

		jmp la467
;---------------
la021_ladbe	jmp ladbe

la024		sta via2.prb
		lda ram_flag
		eor #DISABLED
		bne +
		sta cached_track
		geq la04e

+		lda z22
		beq la063_lf35f
		ldx z45
		cpx #$30
		beq la05e
		blt la066
		cmp cached_track
		bne la04e
		lda m600b
		cmp #%00110000
		bne la04e
		jsr la12b
la04e		lda input
		cmp #"x"
		bne la063_lf35f
		lda z45
		cmp #$60
		bne la063_lf35f
		jmp (p6021)

la05e		lda #0
		sta cached_track
la063_lf35f	jmp lf35f

la066		cmp cached_track
		beq +
		jsr la07f
+		lda z45
		cmp #$10
		blt la07c_la52f
		beq la079_la61b
		jmp la6aa

la079_la61b	jmp la61b

la07c_la52f	jmp la52f
;---------------
la07f		ldx max_sectors
		stx m6007
		lda #$c2
-		sta tc_flags-1,x
		dex
		bne -
		jsr save_zp
		jsr la467
la092		lda #90
		sta m6006
		jsr la3a3
		beq la102
		tay
		lda id
		jsr setup_pointers2
		jsr la48d
		ldy #65-1
la0a7		bvc la0a7
		clv
		lax via2.pra
		and #%00000111
		sta z14
		lda tb800,x
		sta temp
		bvc *

		lda via2.pra
		lsr
		sta z15
		and #%01100000
		ora z14
		tax
		lda tbd00,x
		ora temp
		sta (id),y
		ldx z15
		lda tb900,x
		sta temp
		clv
		lda via2.pra
		sta (p8a),y
		ror
		tax
		bvc *

		clv
		lda via2.pra
		sta (p88),y
		lda tba00,x
		ora temp
		sta (p86),y
		bvc *

		clv
		lda via2.pra
		sta (p8c),y
		dey
		bpl la0a7
		ldx sector
		lda #%00000001
		sta tc_flags,x
		dec m6007
		beq la102
		jmp la092

la102		lda z22
		sta cached_track
;---------------
restore_zp	ldx #8-1
-		lda zp_backup,x
		sta z14,x
		lda zp_backup+8,x
		sta p86,x
		dex
		bpl -
		rts

la117		lda m600b
		cmp #%00110000
		bne +
		sty z3f
		jsr la12b
+		ldy z41
		jsr lf395
		jmp lf30f
;---------------
la12b		lda via2.prb
		and #WRITE_PROTECT
		bne +
		jmp lf581

+		jsr save_zp
		jsr la467
		lda #5
		sta m6008
la140		lda #0
		sta m6007
		jsr la442
la148		lda #90
		sta m6006
		dec m6007
		bpl +
		jmp la24c

+		jsr la3a3
		bne la15f
		lda #NO_HEADER
		jmp la613

la15f		bvc la15f
		clv
		inc id+1
		ldy #1
		lda (id),y
		sta z15
		dey
		bvc *

		clv
		lda (id),y
		sta z14
		dec id+1
		ldx #5
		lda id
		ldy id+1
la17a		bvc *

		clc
		adc #64
		clv
		bcc +
		iny
+		sty p86,x
		dex
		sta p86,x
		dex
		bpl la17a
		bvc *

		clv
		bvc *

		clv
		lda #$ff
		sta via2.ddra
		lda via2.pcr
		and #%00011111
		ora #%11000000
		sta via2.pcr
		lda #$ff
		ldx #5
		sta via2.pra
		clv
-		bvc *

		clv
		dex
		bne -
		ldy #64-1
la1b0		lax (id),y
		lda togcr0,x
		bvc *

		clv
		sta via2.pra
		lda togcr1,x
		sta temp
		lax (p86),y
		lda togcr2,x
		ora temp
		bvc *

		sta via2.pra
		clv
		lda togcr3,x
		sta temp
		lax (p88),y
		lda temp
		ora togcr4,x
		bvc *

		sta via2.pra
		clv
		lda togcr5,x
		sta temp
		lax (p8a),y
		lda temp
		ora togcr6,x
		bvc *

		sta via2.pra
		clv
		lda togcr7,x
		bvc *

		clv
		sta via2.pra
		dey
		bpl la1b0
		ldx z14
		lda togcr0,x
		bvc *

		clv
		sta via2.pra
		lda togcr1,x
		ldx z15
		ora togcr2,x
		bvc *

		clv
		sta via2.pra
		lda togcr3,x
		ora togcr4,x
		bvc *

		clv
		sta via2.pra
		bvc *

		clv
		bvc *

		clv
		jsr lfe00
		ldx sector
		lda verify_flag
		cmp #DISABLED
		bne +
		lda #%00100000
		.byte $2c		;bit
+		lda #%00110000
		sta tc_flags,x
		jmp la148

la23f		dec m6008
		beq +
		jmp la140

+		lda #VERIFY_ERROR
		jmp la613

la24c		lda #0
		sta m6007
		jsr la442
la254		lda #90
		sta m6006
		dec m6007
		bpl +
		lda #0
		sta m600b
		jmp restore_zp

+		jsr la3a3
		bne +
		lda #NO_HEADER
		jmp la613

+		inc id+1
		ldy #1
		lda (id),y
		sta z15
		dey
		lda (id),y
		sta z14
		dec id+1
		lda id
		ldy id+1
		jsr setup_pointers
		jsr la48d
		sec
		ldy #64-1
la28c		lax (id),y
		lda togcr0,x
		bvc *

		sbc via2.pra
		bne la23f
		lda togcr1,x
		sta temp
		lax (p86),y
		lda togcr2,x
		bvc *

		ora temp
		sbc via2.pra
		bne la23f
		lda togcr3,x
		sta temp
		lax (p88),y
		lda temp
		bvc *

		ora togcr4,x
		sbc via2.pra
		bne la23f
		lda togcr5,x
		sta temp
		lax (p8a),y
		lda temp
		bvc *

		ora togcr6,x
		sbc via2.pra
		bne la310_la23f
		lda togcr7,x
		bvc *

		sbc via2.pra
		bne la310_la23f
		dey
		bpl la28c
		ldx z14
		lda togcr0,x
		bvc *

		sbc via2.pra
		bne la310_la23f
		lda togcr1,x
		ldx z15
		ora togcr2,x
		bvc *

		sbc via2.pra
		bne la310_la23f
		lda togcr3,x
		ora togcr4,x
		bvc *

		sbc via2.pra
		bne la310_la23f
		ldx sector
		lda #%00100000
		sta tc_flags,x
		jmp la254

la310_la23f	jmp la23f

la313		tya
		and #%00010000
		beq +
		lda z48
		cmp #$f0
		bne +
		lda m600b
		cmp #%00110000
		bne +
		lda #0
		sta m600b
		ror
		sta m6009
		lda z1c
		lsr
		bcs +
		lda #$d7
		sta z48
		jsr la12b
		lda #0
		sta m6009
+		ldy z20
		dec z48
		bne la348_lf9fa
		jmp lf9dd

la348_lf9fa	jmp lf9fa

la34b		jsr lf259
		lda #0
		sta track0_flag
		geq la38c

		.byte $00
		lda #DISABLED
		sta track0_flag
		cli
-		lda p0
		bmi -
		lda #<xf505
		sta p6021
		lda #>xf505
		sta p6021+1
		lda #"x"
		sta input
		lda #4
		sta job_tr
		ldx #$e0
		stx p0
-		lda p0
		bmi -
		lda via1.pran
		and #%00000001
		php
		lda #1
		sta job_tr
		stx p0
-		lda p0
		bmi -
		sei
la38c		jsr lff10
		lda #0
		sta m600b
		sta m6009
		sta input
		nop
		bne la3a2_rts
		sta z22
		sta track0_flag
la3a2_rts	rts
;---------------
la3a3		jsr la48d
		bvc *

		clv
		lda via2.pra
		eor z24
		beq la3b6
la3b0		dec m6006
		bne la3a3
		rts

la3b6		bvc *

		clv
		lda via2.pra
		lsr
		tax
		and #%01100000
		eor z25
		bne la3b0
		lda tb900,x
		sta hchksum
		bvc *

		clv
		lda via2.pra
		tay
		ror
		tax
		lda tba00,x
		ora hchksum
		sta hchksum
		bvc *

		clv
		lda via2.pra
		asl
		tax
		and #%00000110
		eor z27
		bne la3b0
		bvc *

		clv
		lda via2.pra
		eor z28
		bne la3b0
		lda tba00,x
		sta sector
		bvc *

		clv
		lda via2.pra
		eor z29
		bne la3b0
		tya
		rol
		tax
		bvc *

		clv
		lda via2.pra
		eor z2a
		bne la3b0
		lda tb900,x
		ora sector
		bvc *

		clv
		ldy via2.pra
		cpy z2b
		bne la3b0
		cmp max_sectors
		bge la3b0
		tax
		bvc *

		clv
		ldy tc_flags,x
		bpl la3b0
		eor track
		eor hchksum
		bne la3b0
		txa
		asl
		bvc *

		clv
		tay
		lda sector_address,y
		sta id
		stx sector
		lda sector_address+1,y
		sta id+1
		rts
;---------------
la442		ldx max_sectors
-		lda tc_flags-1,x
		and #%00010000
		beq +
		inc m6007
		lda #%10110000
		sta tc_flags-1,x
+		dex
		bne -
		rts
;---------------
save_zp		ldx #8-1
-		lda z14,x
		sta zp_backup,x
		lda p86,x
		sta zp_backup+8,x
		dex
		bpl -
		rts
;---------------
la467		lda diskid
		sta id
		lda diskid+1
		sta id+1
		lda z22
		sta track
		jsr lf934
		lda z25
		and #%11000000
		lsr
		sta z25
		lda z27
		and #%00000011
		asl
		sta z27
		lda id
		eor id+1
		eor track
		sta track
		rts
;---------------
la48d		lda #208
		sta via1.t1ch
-		bit via1.t1ch
		bpl +
		bit via2.prb
		bmi -
		lda via2.pra
		clv
		ldy #0
		rts

+		lda #NO_SYNC
		jmp la613

la4a8		ldx max_sectors
		stx m6007
-		lda tc_flags-1,x
		ora #%10000000
		sta tc_flags-1,x
		dex
		bne -
		jsr save_zp
		jsr la467
		lda #<p86
		sta buffp
		lda #>p86
		sta buffp+1
		lda z22
		asl
		tax
		lda tbd80-2,x
		sta p8c
		lda tbd80-1,x
		sta p8c+1
		lda #5
		sta z85
la4d8		lda #192
		sta m6006
		jsr la3a3
		beq la522
		sty id
		jsr la48d
-		bvc *

		clv
		lda via2.pra
		sta p86,y
		iny
		cpy #5
		bne -
		ldy #0
		jsr lf7e8
		lda z52
		cmp z47
		bne la527
		ldy id
		lda z53
		sta (p8c),y
		iny
		lda z54
		sta (p8c),y
		ldx sector
		lda tc_flags,x
		and #%01111111
		sta tc_flags,x
		dec m6007
		bne la4d8
		ldx z22
		lda #ALL_OK
		sta t79d7,x
		.byte $2c		;bit
la522		lda #NO_HEADER
la524_la613	jmp la613

la527		lda #BLOCK_NOT_FOUND
		dec z85
		bne la4d8
		geq la524_la613

;---------------
;Read track cache
;
la52f		jsr la7e7
		beq +
la534_lf35f	jmp lf35f

+		sty z2e
		sty z36
		sty chksum
		lda buffp+1
		sta z2e+1
		lda sector_address,x
		sta buffp
		ldy sector_address+1,x
		sty buffp+1
		jsr save_zp
		ldx sector
		lda tc_flags,x
		and #%00100000
		beq la5a1
		lda buffp
		jsr setup_pointers
		ldy #64-1
		ldx #0
		lda (buffp),y
		sta z38
		jmp +

-		lda (buffp),y
		sta (z2e,x)
		inc z2e
+		lda (p86),y
		sta (z2e,x)
		inc z2e
		lda (p88),y
		sta (z2e,x)
		inc z2e
		lda (p8a),y
		sta (z2e,x)
		inc z2e
		dey
		bpl -
		iny
		inc buffp+1
		lda (buffp),y
		sta (z2e,x)
		iny
		lda (buffp),y
		sta chksum
		ldy z2e+1
		sty buffp+1
		ldy #0
		sty buffp
		lda z38
		cmp z47
		bne la534_lf35f
		lda #ALL_OK
		jmp la613

la5a1		lda buffp
		jsr setup_pointers2
		ldy #$40
		sty z34
		jsr la793
		lda z52
		sta z38
		ldy z36
		jmp +

-		sty z36
		dec z34
		jsr la793
		ldy z36
		lda z52
		sta (z2e),y
		eor chksum
		sta chksum
		iny
		beq la5e7
+		lda z53
		sta (z2e),y
		eor chksum
		sta chksum
		iny
		lda z54
		sta (z2e),y
		eor chksum
		sta chksum
		iny
		lda z55
		sta (z2e),y
		eor chksum
		sta chksum
		iny
		bne -
la5e7		ldy z2e+1
		sty buffp+1
		ldy #0
		sty buffp
		lda z53
		cmp chksum
		sta chksum
		bne +
		lda #%00000001
		.byte $2c		;bit
+		lda #%01000101
		ldx z47
		cpx z38
		beq +
		lda #%01000100
+		ldx sector
		sta tc_flags,x
		cmp #ALL_OK
		beq la613
		jsr restore_zp
		jmp lf35f

la613		pha
		jsr restore_zp
		pla
		jmp lf969
;---------------
;Write track cache
;
la61b		lda via2.prb
		and #WRITE_PROTECT
		bne +
-		jmp lf35f

+		jsr la7e7
		bne -
		lda sector_address,x
		sta z2e
		ldy sector_address+1,x
		sty z2e+1
		jsr save_zp
		lda z2e
		jsr setup_pointers
		ldy #64-1
		ldx #0
		stx z34
		lda z47
		sta (z2e),y
		jmp +

-		lda (buffp,x)
		sta (z2e),y
		eor z34
		sta z34
		inc buffp
+		lda (buffp,x)
		sta (p86),y
		eor z34
		sta z34
		inc buffp
		lda (buffp,x)
		sta (p88),y
		eor z34
		sta z34
		inc buffp
		lda (buffp,x)
		sta (p8a),y
		eor z34
		sta z34
		inc buffp
		dey
		bpl -
		iny
		inc z2e+1
		lda (buffp,x)
		sta (z2e),y
		eor z34
		iny
		sta (z2e),y
		ldy z2e+1
		sty buffp+1
		ldy #0
		sty buffp
		ldx sector
		lda cached_track
		cmp directory_track
		beq +
		lda #%00110000
		sta tc_flags,x
		sta m600b
		lda #ALL_OK
		jmp la613

+		lda #%00100000
		sta tc_flags,x
		jsr restore_zp
		jmp lf35f
;---------------
;Verify track cache
;
la6aa		lda cached_track
		cmp directory_track
		beq la6b7_lf35f
		jsr la7e7
		beq +
la6b7_lf35f	jmp lf35f

+		sty z2e
		sty z36
		sty chksum
		lda buffp+1
		sta z2e+1
		lda sector_address,x
		sta buffp
		ldy sector_address+1,x
		sty buffp+1
		jsr save_zp
		ldx sector
		lda tc_flags,x
		and #%00100000
		beq la72d
		lda buffp
		jsr setup_pointers
		ldy #64-1
		ldx #0
		lda (buffp),y
		cmp z38
		bne la72a_la78e
		jmp +

-		lda (buffp),y
		cmp (z2e,x)
		bne la72a_la78e
		inc z2e
+		lda (p86),y
		cmp (z2e,x)
		bne la72a_la78e
		inc z2e
		lda (p88),y
		cmp (z2e,x)
		bne la72a_la78e
		inc z2e
		lda (p8a),y
		cmp (z2e,x)
		bne la72a_la78e
		inc z2e
		dey
		bpl -
		iny
		inc buffp+1
		lda (buffp),y
		cmp (z2e,x)
		bne la72a_la78e
		iny
		lda chksum
		cmp (buffp),y
		bne la72a_la78e
		ldy z2e+1
		sty buffp+1
		ldy #0
		sty buffp
		jmp la78b

la72a_la78e	jmp la78e

la72d		lda buffp
		jsr setup_pointers2
		ldy #$40
		sty z34
		jsr la793
		lda z52
		cmp z47
		bne la72a_la78e
		ldy z36
		jmp +

-		sty z36
		dec z34
		jsr la793
		ldy z36
		lda z52
		cmp (z2e),y
		bne la72a_la78e
		eor chksum
		sta chksum
		iny
		beq la77d
+		lda z53
		cmp (z2e),y
		bne la72a_la78e
		eor chksum
		sta chksum
		iny
		lda z54
		cmp (z2e),y
		bne la78e
		eor chksum
		sta chksum
		iny
		lda z55
		cmp (z2e),y
		bne la78e
		eor chksum
		sta chksum
		iny
		bne -
la77d		ldy z2e+1
		sty buffp+1
		ldy #0
		sty buffp
		lda z53
		cmp chksum
		bne la78e
la78b		lda #ALL_OK
		.byte $2c		;bit
la78e		lda #VERIFY_ERROR
		jmp la613
;---------------
la793		ldy z34
		lda (buffp),y
		sta z52
		lda (p86),y
		sta z53
		lda (p88),y
		asl
		tax
		and #%00000110
		sta z55
		lda tba00,x
		sta z54
		lda (p8a),y
		rol
		tax
		lda tb900,x
		ora z54
		sta z54
		lax (p8c),y
		and #%11100000
		ora z55
		tay
		lda tbb00,y
		ora tbc00,x
		sta z55
		rts
;---------------
setup_pointers2 ldx #7
-		clc
		adc #65
		bcc +
		iny
+		sty p86,x
		dex
		sta p86,x
		dex
		bpl -
		rts
;---------------
setup_pointers	ldx #5
-		clc
		adc #64
		bcc +
		iny
+		sty p86,x
		dex
		sta p86,x
		dex
		bpl -
		rts
;---------------
la7e7		ldy #0
		lda (p32),y
		cmp cached_track
		bne la81e_rts
		sta track
		lda diskid
		sta id
		lda diskid+1
		sta id+1
		iny
		lda (p32),y
		sta sector
		cmp max_sectors
		bne la805
		tax
la804_rts	rts

la805		bge la804_rts
		tax
		lda tc_flags,x
		and #%01000000
		bne la81e_rts
		txa
		asl
		tax
		lda id
		eor id+1
		eor track
		eor sector
		sta hchksum
		ldy #0
la81e_rts	rts

la81f		lda #0
		sta cable_ok
		lda listen_active
		ora talk_active
		beq la86e
		lda cable_flag
		eor #DISABLED
		beq la86e
		bit pia.pra
la834		bit via1.prb
		bpl la873_le8d7
		bit pia.cra
		bpl la834
		bit pia.pra
		lda #$2c
		ldx #3
-		dex
		beq la834
		bit pia.cra
		bpl -
		sta pia.cra
		bit pia.pra
		lda #%10000000
		sta cable_ok
		lda #0
		sta pia.cra
		sta pia.pra
		lda listen_active
		bne +
		lda #$ff
		sta pia.pra
+		lda #pia.DDRN
		sta pia.cra
la86e		bit via1.prb
		bmi la86e
la873_le8d7	jmp le8d7
;---------------
la876		lda #CLOCK_IN
-		bit via1.prb
		bmi la8c3_le85b
		bne -
		lda via1.prb
		and #~DATA_OUT
		sta via1.prb
		ldy #7
		lda #CLOCK_IN
-		bit via1.prb
		bmi la8c3_le85b
		bne la8b4
		dey
		bne -
		lda via1.prb
		ora #DATA_OUT
		sta via1.prb
		ldy #10
-		dey
		bne -
		and #~DATA_OUT
		sta via1.prb
		lda #CLOCK_IN
-		bit via1.prb
		bmi la8c3_le85b
		beq -
		lda #0
		sta zf8
la8b4		ldy pia.pra
		lda via1.prb
		ora #DATA_OUT
		sta via1.prb
		tya
		sta z85
		rts

la8c3_le85b	jmp le85b
;---------------
la8c6		lda via1.prb
		and #~CLOCK_OUT
		sta via1.prb
		lda #DATA_IN
-		bit via1.prb
		bmi la8c3_le85b
		bne -
		txa
		bne la8ea
		lda #DATA_IN
-		bit via1.prb
		bmi la8c3_le85b
		beq -
-		bit via1.prb
		bmi la8c3_le85b
		bne -
la8ea		lda t23e,y
		sta pia.pra
		lda via1.prb
		ora #CLOCK_OUT
		sta via1.prb
		lda #DATA_IN
-		bit via1.prb
		bmi la8c3_le85b
		beq -
		rts

la902		bit cable_ok
		bpl la97a
		jsr la876
		cli
		lda z84
		and #%10001111
		cmp #$0f
		bge la92e
		jsr ld125
		bcs la954
		jsr la986
		jmp la921

la91e		jsr la876
la921		sta (z99,x)
		inc z99,x
		bne la91e
		cli
		jsr ld1a3
		jmp lea2e

la92e		lda #4
		sta z82
		jsr ld4e8
		cmp #$2a
		beq la94d
		sei
		lda z85
-		sta (z99,x)
		inc z99,x
		lda zf8
		beq la94d
		jsr la876
		ldy z99,x
		cpy #$2a
		bne -
la94d		cli
		jsr lcfe8
		jmp lea2e

la954		beq la980
		jsr la986
		ldy z82
		jmp la961

la95e		jsr la876
la961		sta (z99,x)
		inc z99,x
		ldy z82
		lda (z99,x)
		sta t23e,y
		lda z99,x
		cmp t244,y
		bne la95e
		cli
		jsr ld3fa
		jmp lea2e

la97a		jsr le9c9
		jmp lea47

la980		jsr le0ab
		jmp lea2e
;---------------
la986		jsr ldf93
		bmi la991_lcff8
		asl
		tax
		lda z85
		sei
la990_rts	rts

la991_lcff8	jmp lcff8

la994		jsr ld3c0
		jmp le995

la99a		jsr ld12f
		lda z99,x
		cmp t244,y
		sei
		bne la9b1
		cli
		jsr ld3e8
		jmp le995

la9ac		inx
		jsr la8c6
		dex
la9b1		inc z99,x
		lda (z99,x)
		sta t23e,y
		lda z99,x
		cmp t244,y
		bne la9ac
		cli
		lda #$81
		sta tf2,y
		jmp le995

la9c8		jsr ld400
		jmp le995

la9ce		lda tf2,x
		bpl la990_rts
		bit cable_ok
		bpl laa2d_le916
		and #%00001000
		tax
		ldy z82
		jsr la8c6
		cli
		ldx z82
		jsr ld125
		beq laa30
		lda z83
		cmp #$0f
		beq laa36
		lda tf2,x
		and #%00001000
		beq la994
		lda z83
		beq laa0a
		jsr ld125
		cmp #4
		bge la99a
la9fe		jsr ld12f
		lda t244,y
		bne la9c8
		sei
		jmp laa1d

laa0a		lda m254
		beq la9fe
		jsr ld40e
		jmp le995

laa15		sta t23e,y
		inx
		jsr la8c6
		dex
laa1d		lda (z99,x)
		inc z99,x
		bne laa15
		cli
		jsr ld159
		jsr ld403
		jmp le995

laa2d_le916	jmp le916

laa30		jsr le120
		jmp le995

laa36		jsr ld4e8
		cmp #$d4
		bne +
		lda p94+1
		cmp #2
		bne +
		jsr ld421
		jmp le995

+		sei
		jsr ld12f
		lda #$88
		sta zf7
		jmp laa57

laa54		jsr la8c6
laa57		lda (z99,x)
		sta t23e,y
		lda z99,x
		cmp t244,y
		beq +
		inc z99,x
		bne laa54
		dec z99,x
+		cli
		jsr ld414
		jmp le995

;---------------
;Command X
;
command_x	lda input_length
		cmp #1
		beq laab9
		lda input+1
		cmp #"+"
		bne +
;---------------
;Command X+
;
		lda #0
		ldx #5
-		sta flags-1,x
		dex
		bne -
		inx
		stx z1c
		gne laab9
;---------------
;Command XQ
;
+		cmp #"q"
		bne +
		jmp command_xq
;---------------
;Command XZ
;
+		cmp #"z"
		bne +
		jmp command_xz
;---------------
;Command XV+/XV-
;
+		cmp #"v"
		bne +
		lda #<verify_flag
		gne laaa9
;---------------
;Command XR+/XR-
;
+		cmp #"r"
		bne lab11
		lda #<ram_flag
laaa9		sta input
		lda #0
		ldx #DISABLED
		jsr ladab
		ldy input
		sta flags,y
laab9		lda extend_flag
		cmp #DISABLED
		beq +
		ldx #0
		lda z1c
		ora zff
		bne laacc
+		ldx max_track
		dex
laacc		stx current_track
		lda listen_address
		and #%00001111
		sta current_sector
		lda #$32
		jsr le6c7
		ldx #0
		ldy #1
		lda #$30
		sta m243
laae2		iny
		lda flag_names,x
		sta (errp),y
		iny
		lda flags,x
		cmp #DISABLED
		beq +
		lda #"+"
		.byte $2c		;bit
+		lda #"-"
		sta (errp),y
		iny
		lda #":"
		sta (errp),y
		inx
		cpx #4
		bne laae2
		lda extend_flag
		cmp #DISABLED
		bne lab0c_rts
		lda #"!"
		sta (errp),y
lab0c_rts	rts

flag_names	.text "rfvp"

;---------------
;Command XF+/XF-
;
lab11		cmp #"f"
		bne +
		lda #<fast_flag
		gne laaa9
;---------------
;Command XP+/XP-
;
+		cmp #"p"
		bne +
		lda #<cable_flag
		gne laaa9
;---------------
;Command XT/XT+/XT-
;
+		cmp #"t"
		bne lab46
		lda input_length
		eor #2
		beq lab3c
		lda #40+1
		ldx input+2
		cpx #"-"
		bne lab37
lab35		lda #35+1
lab37		sta max_track
		lda #DISABLED
lab3c		sta extend_flag
		lda #1
		sta z1c
lab43_laab9	jmp laab9
;---------------
;Command X-
;
lab46		cmp #"-"
		bne +
		lda #DISABLED
		sta ram_flag
		sta cable_flag
		gne lab35
;---------------
;Command XL:/XU:
;
+		cmp #"l"
		bne lab63
-		lda #$0a
		sta m22a
		jsr lc1ee
		jmp lc823
lab63		cmp #"u"
		beq -
;---------------
;Command X9
;
		cmp #"9"+1
		bge lab7b
		cmp #"4"
		blt lab7b
lab6f		sbc #"0"
		ora #TALK
		sta talk_address
		eor #LISTEN^TALK
		sta listen_address
		bne lab43_laab9
lab7b		cmp #"1"
		bne +
		lda input+2
		cmp #"0"
		blt labc7_lc8c1
		cmp #"4"+1
		bge labc7_lc8c1
		adc #10
		sec
		gcs lab6f
;---------------
;Command X(C)
;
+		cmp #"("
		bne labc7_lc8c1
		lda input+2
		cmp #"c"
		bne labc7_lc8c1
		lda input+3
		cmp #")"
		bne labc7_lc8c1
		lda #19 ^ $c5
		eor #$c5
		sta current_track
		lda #86 ^ $c6
		eor #$c6
		sta current_sector
		lda #$66
		jsr le6c7
		lda #$30
		sta m243
		ldy #2
-		lda togcr7-2,y
		eor tb800-2,y
		sta (errp),y
		iny
		cpy #size(tb800)+2
		bne -
		rts

labc7_lc8c1	jmp lc8c1

;---------------
;Command XQ (bulk read)
;
command_xq	sei
		lda #0
		sta pia.cra
		lda #$ff
		sta pia.pra
		lda #pia.DDRN
		sta pia.cra
		jsr le9ae
		lda #1
		sta talk_active
		lsr
		sta z85
		sta z83
		jsr lad95
		tax
		ldy #2
-		dey
		bmi +
		lda flags,y
		cmp #DISABLED
		bne -
		lda #%10000000
		sta cable_ok
		jmp le90f

+		lda #$2c
		sta pia.cra
		bit pia.pra
		lda #<xac62
		sta p6021
		lda #>xac62
		sta p6021+1
		cli
		jsr ladb4
		bne lac2a
		bit z85
		bpl lac40
		txa
		jsr ld554
		bit z85
		bvs +
		lda #$66
		.byte $2c		;bit
+		lda #$23
		jmp le645

lac2a		txa
		asl
		tax
		lda #1
		sta z99,x
		lda (z99,x)
		tay
-		inc z99,x
		lda (z99,x)
		jsr lad74
		tya
		cmp z99,x
		bne -
lac40		jsr le9b7
		lda #DATA_IN
-		bit via1.prb
		bne -
		bit pia.pra
		lda #0
		sta z83
		sta pia.cra
		sta pia.pra
		lda #pia.DDRN
		sta pia.cra
		jsr ldac0
		jmp lc194

xac62		lda buffp+1
		sta z2e+1
		lda cached_track
		cmp z22
		beq lac70
lac6d		jsr la07f
lac70		ldy #1
		lda (p32),y
		cmp max_sectors
		bge lacc5
		tay
		asl
		tax
		lda tc_flags,y
		bpl lac8a
		and #ERROR_MASK
lac82		ldx #0
		stx cached_track
		jmp la613

lac8a		and #%00100000
		bne lac6d
		lda sector_address,x
		sta buffp
		ldy sector_address+1,x
		sty buffp+1
		jsr setup_pointers2
		ldy #$40
		sty z34
		jsr la793
		lda z52
		cmp z47
		beq lacd7
		lda #4
		gne lac82

lacac		jsr lad7a
		lda (p86),y
		eor chksum
		bne +
		lda (p32),y
		cmp cached_track
		beq lac70
		jsr restore_zp
		jmp lffe0_lfb1e

+		ldx #$c0
		.byte $2c		;bit
lacc5		ldx #$80
		stx z85
lacc9		lda #0
laccb_la613	jmp la613

lacce		ldx z3f
		lda #$80
		sta t25b,x
		gne laccb_la613

lacd7		ldy #0
		lda z53
		beq lacce
		sta (p32),y
		cmp max_track
		bge lacc5
		eor z54
		sta chksum
		iny
		lda z54
		sta (p32),y
		lda z55
		tax
		eor chksum
		sta chksum
		stx pia.pra
		ldx pia.pra
		lda via1.prb
		lsr
		bcc lacc9
		ldy z34
		dey
		jsr lad7a
lad06		lda (buffp),y
		sta pia.pra
		lda pia.pra
		eor chksum
		sta chksum
		tya
		beq lacac
-		bit pia.cra
		bpl -
		lda (p86),y
		sta pia.pra
		lda pia.pra
		eor chksum
		sta chksum
		lda (p88),y
		asl
		tax
		and #%00000110
		sta z53
		lda tba00,x
		sta z54
		lda (p8a),y
		rol
		tax
-		bit pia.cra
		bpl -
		lda tb900,x
		ora z54
		sta pia.pra
		lda pia.pra
		eor chksum
		sta chksum
		lax (p8c),y
		sty z34
		and #%11100000
		ora z53
		tay
-		bit pia.cra
		bpl -
		lda tbb00,y
		ora tbc00,x
		sta pia.pra
		lda pia.pra
		eor chksum
		sta chksum
		ldy z34
		dey
-		bit pia.cra
		bpl -
		jmp lad06
;---------------
lad74		sta pia.pra
		lda pia.pra
;---------------
lad7a		bit pia.cra
		bpl lad7a
		rts
;---------------
lad80		cli
		ldx #$0d
		jsr lf0df
		sei
		lda m2f9
		ora #%01000000
		sta m2f9
		lda #1
		sta listen_active
		sta z83
;---------------
lad95		tax
		ora #%01100000
		sta z84
		lda t22b,x
		and #%00001111
		sta z82
		tax
		lda za7,x
		bpl +
		lda zae,x
+		and #%10111111
		rts
;---------------
ladab		ldy input+2
		cpy #"-"
		bne +
		txa
+		rts
;---------------
ladb4		lda #$e0
		sta p0,x
		sta t25b,x
		jmp ld599

ladbe		bvc ladbe
		clv
		lda format_sector
		eor diskid
		eor diskid+1
		eor z22
		bvc *

		clv
		tax
		lda togcr2,x
		ora #%01000000
		sta z25
		bvc *

		clv
		lda togcr3,x
		ldx format_sector
		ora togcr4,x
		sta z26
		bvc *

		clv
		lda togcr5,x
		ldx z22
		ora togcr6,x
		sta z27
		bvc *

		clv
		lda togcr7,x
		sta z28
		rts
;---------------
;Command XZ (bulk write)
;
command_xz	sei
		jsr le9a5
		ldy #2
-		dey
		bmi +
		lda flags,y
		cmp #DISABLED
		bne -
		jsr lad80
		lda #%10000000
		sta cable_ok
		jmp lea2e

+		lda #$2c
		sta pia.cra
		bit pia.pra
		jsr lad80
		sta z85
		asl
		tax
		lda job_tr,x
		sta current_track
		lda job_sc,x
		sta current_sector
		lda #<xf505
		sta p6021
		lda #>xf505
		sta p6021+1
		lda #0
		sta cached_track
		jmp lae61

lae3d		lda pia.pra
		sta (p8a),y
		sty chksum
		sec
		lda #$3f
		sbc chksum
		asl
		asl
		adc #3
		jmp laf71

lae50		lda pia.pra
		sta (buffp),y
		sty chksum
		sec
		lda #$3f
		sbc chksum
		asl
		asl
		jmp laf71

lae61		ldx z85
		cli
		jsr ladb4
		sei
lae68		lda current_sector
		asl
		tay
		lda sector_address,y
		sta buffp
		lda sector_address+1,y
		sta buffp+1
		tay
		lda buffp
		jsr setup_pointers
		ldy #64-1
		lda z47
		sta (buffp),y
-		bit pia.cra
		bpl -
		lda #CLOCK_IN
		bit via1.prb
lae8c		beq lae3d
		lda pia.pra
		sta (p8a),y
		sta chksum
		dey
lae96		bit pia.cra
		bpl lae96
		lda #CLOCK_IN
		bit via1.prb
		beq lae50
		lda pia.pra
		sta (buffp),y
		eor chksum
		sta chksum
-		bit pia.cra
		bpl -
		lda #CLOCK_IN
		bit via1.prb
		beq laef1
		lda pia.pra
		sta (p86),y
		eor chksum
		sta chksum
-		bit pia.cra
		bpl -
		lda #CLOCK_IN
		bit via1.prb
		beq laf02
		lda pia.pra
		sta (p88),y
		sta (p88),y
		eor chksum
		sta chksum
-		bit pia.cra
		bpl -
		lda #CLOCK_IN
		bit via1.prb
		beq lae8c
		lda pia.pra
		sta (p8a),y
		eor chksum
		sta chksum
		dey
		bpl lae96
		gmi laf12

laef1		lda pia.pra
		sta (p86),y
		sty chksum
		sec
		lda #$3f
		sbc chksum
		asl
		sec
		rol
		gne laf71

laf02		lda pia.pra
		sta (p88),y
		sty chksum
		sec
		lda #$3f
		sbc chksum
		rol
		asl
		bne laf71
laf12		inc buffp+1
		iny
-		bit pia.cra
		bpl -
		lda #CLOCK_IN
		bit via1.prb
		beq laf69
		lda pia.pra
		sta (buffp),y
		eor chksum
		sta chksum
		ldx current_sector
		lda #%00110000
		sta tc_flags,x
		jsr lf121
		lda z85
		asl
		tax
		ldy #63
		lda current_sector
		sta (p88),y
		sta job_sc,x
		eor chksum
		sta chksum
		lda current_track
		sta (p86),y
		cmp job_tr,x
		php
		sta job_tr,x
		eor chksum
		ldy #1
		sta (buffp),y
		ldx z82
		inc zb5,x
		bne +
		inc zbb,x
+		plp
		bne +
		jmp lae68

+		lda #%00110000
		sta m600b
		jmp lae61

laf69		lda pia.pra
		pha
		lda #0
		dec buffp+1
laf71		tax
		lda z85
		asl
		stx z85
		tax
		lda #2
		sta z99,x
		ldy #64-1
		lda (p8a),y
		sta (z99,x)
		inc z99,x
		lda z99,x
		cmp z85
		beq lafc3
		dey
-		lda (buffp),y
		sta (z99,x)
		inc z99,x
		lda z99,x
		cmp z85
		beq lafc3
		lda (p86),y
		sta (z99,x)
		inc z99,x
		lda z99,x
		cmp z85
		beq lafc3
		lda (p88),y
		sta (z99,x)
		inc z99,x
		lda z99,x
		cmp z85
		beq lafc3
		lda (p8a),y
		sta (z99,x)
		inc z99,x
		lda z99,x
		cmp z85
		beq lafc3
		dey
		bpl -
		pla
		sta (z99,x)
		inc z99,x
lafc3		lda z22
		sta cached_track
		lda #%00110000
		sta m600b
		lda #pia.DDRN
		sta pia.cra
		jmp lc194

		*= $afff
		.byte $9e
togcr0		.byte $52,$52,$54,$54,$53,$53,$55,$55
		.byte $52,$56,$56,$56,$53,$57,$57,$55
		.byte $5a,$5a,$5c,$5c,$5b,$5b,$5d,$5d
		.byte $5a,$5e,$5e,$5e,$5b,$5f,$5f,$5d
		.byte $92,$92,$94,$94,$93,$93,$95,$95
		.byte $92,$96,$96,$96,$93,$97,$97,$95
		.byte $9a,$9a,$9c,$9c,$9b,$9b,$9d,$9d
		.byte $9a,$9e,$9e,$9e,$9b,$9f,$9f,$9d
		.byte $72,$72,$74,$74,$73,$73,$75,$75
		.byte $72,$76,$76,$76,$73,$77,$77,$75
		.byte $7a,$7a,$7c,$7c,$7b,$7b,$7d,$7d
		.byte $7a,$7e,$7e,$7e,$7b,$7f,$7f,$7d
		.byte $b2,$b2,$b4,$b4,$b3,$b3,$b5,$b5
		.byte $b2,$b6,$b6,$b6,$b3,$b7,$b7,$b5
		.byte $ba,$ba,$bc,$bc,$bb,$bb,$bd,$bd
		.byte $ba,$be,$be,$be,$bb,$bf,$bf,$bd
		.byte $4a,$4a,$4c,$4c,$4b,$4b,$4d,$4d
		.byte $4a,$4e,$4e,$4e,$4b,$4f,$4f,$4d
		.byte $ca,$ca,$cc,$cc,$cb,$cb,$cd,$cd
		.byte $ca,$ce,$ce,$ce,$cb,$cf,$cf,$cd
		.byte $d2,$d2,$d4,$d4,$d3,$d3,$d5,$d5
		.byte $d2,$d6,$d6,$d6,$d3,$d7,$d7,$d5
		.byte $da,$da,$dc,$dc,$db,$db,$dd,$dd
		.byte $da,$de,$de,$de,$db,$df,$df,$dd
		.byte $6a,$6a,$6c,$6c,$6b,$6b,$6d,$6d
		.byte $6a,$6e,$6e,$6e,$6b,$6f,$6f,$6d
		.byte $ea,$ea,$ec,$ec,$eb,$eb,$ed,$ed
		.byte $ea,$ee,$ee,$ee,$eb,$ef,$ef,$ed
		.byte $f2,$f2,$f4,$f4,$f3,$f3,$f5,$f5
		.byte $f2,$f6,$f6,$f6,$f3,$f7,$f7,$f5
		.byte $aa,$aa,$ac,$ac,$ab,$ab,$ad,$ad
		.byte $aa,$ae,$ae,$ae,$ab,$af,$af,$ad
togcr1		.rept 16
		.byte $80,$c0,$80,$c0,$80,$c0,$80,$c0
		.byte $40,$40,$80,$c0,$40,$40,$80,$40
		.next
togcr2		.byte $14,$14,$15,$15,$14,$14,$15,$15
		.byte $14,$15,$15,$15,$14,$15,$15,$15
		.byte $16,$16,$17,$17,$16,$16,$17,$17
		.byte $16,$17,$17,$17,$16,$17,$17,$17
		.byte $24,$24,$25,$25,$24,$24,$25,$25
		.byte $24,$25,$25,$25,$24,$25,$25,$25
		.byte $26,$26,$27,$27,$26,$26,$27,$27
		.byte $26,$27,$27,$27,$26,$27,$27,$27
		.byte $1c,$1c,$1d,$1d,$1c,$1c,$1d,$1d
		.byte $1c,$1d,$1d,$1d,$1c,$1d,$1d,$1d
		.byte $1e,$1e,$1f,$1f,$1e,$1e,$1f,$1f
		.byte $1e,$1f,$1f,$1f,$1e,$1f,$1f,$1f
		.byte $2c,$2c,$2d,$2d,$2c,$2c,$2d,$2d
		.byte $2c,$2d,$2d,$2d,$2c,$2d,$2d,$2d
		.byte $2e,$2e,$2f,$2f,$2e,$2e,$2f,$2f
		.byte $2e,$2f,$2f,$2f,$2e,$2f,$2f,$2f
		.byte $12,$12,$13,$13,$12,$12,$13,$13
		.byte $12,$13,$13,$13,$12,$13,$13,$13
		.byte $32,$32,$33,$33,$32,$32,$33,$33
		.byte $32,$33,$33,$33,$32,$33,$33,$33
		.byte $34,$34,$35,$35,$34,$34,$35,$35
		.byte $34,$35,$35,$35,$34,$35,$35,$35
		.byte $36,$36,$37,$37,$36,$36,$37,$37
		.byte $36,$37,$37,$37,$36,$37,$37,$37
		.byte $1a,$1a,$1b,$1b,$1a,$1a,$1b,$1b
		.byte $1a,$1b,$1b,$1b,$1a,$1b,$1b,$1b
		.byte $3a,$3a,$3b,$3b,$3a,$3a,$3b,$3b
		.byte $3a,$3b,$3b,$3b,$3a,$3b,$3b,$3b
		.byte $3c,$3c,$3d,$3d,$3c,$3c,$3d,$3d
		.byte $3c,$3d,$3d,$3d,$3c,$3d,$3d,$3d
		.byte $2a,$2a,$2b,$2b,$2a,$2a,$2b,$2b
		.byte $2a,$2b,$2b,$2b,$2a,$2b,$2b,$2b
togcr3		.rept 16
		.byte $a0,$b0,$20,$30,$e0,$f0,$60,$70
		.byte $90,$90,$a0,$b0,$d0,$d0,$e0,$50
		.next
togcr4		.fill 32,$05
		.fill 32,$09
		.fill 32,$07
		.fill 32,$0b
		.fill 16,$04
		.fill 16,$0c
		.fill 32,$0d
		.fill 16,$06
		.fill 16,$0e
		.fill 16,$0f
		.fill 16,$0a
togcr5		.byte $28,$2c,$48,$4c,$38,$3c,$58,$5c
		.byte $24,$64,$68,$6c,$34,$74,$78,$54
		.byte $a8,$ac,$c8,$cc,$b8,$bc,$d8,$dc
		.byte $a4,$e4,$e8,$ec,$b4,$f4,$f8,$d4
		.byte $28,$2c,$48,$4c,$38,$3c,$58,$5c
		.byte $24,$64,$68,$6c,$34,$74,$78,$54
		.byte $a8,$ac,$c8,$cc,$b8,$bc,$d8,$dc
		.byte $a4,$e4,$e8,$ec,$b4,$f4,$f8,$d4
		.byte $28,$2c,$48,$4c,$38,$3c,$58,$5c
		.byte $24,$64,$68,$6c,$34,$74,$78,$54
		.byte $a8,$ac,$c8,$cc,$b8,$bc,$d8,$dc
		.byte $a4,$e4,$e8,$ec,$b4,$f4,$f8,$d4
		.byte $28,$2c,$48,$4c,$38,$3c,$58,$5c
		.byte $24,$64,$68,$6c,$34,$74,$78,$54
		.byte $a8,$ac,$c8,$cc,$b8,$bc,$d8,$dc
		.byte $a4,$e4,$e8,$ec,$b4,$f4,$f8,$d4
		.byte $a8,$ac,$c8,$cc,$b8,$bc,$d8,$dc
		.byte $a4,$e4,$e8,$ec,$b4,$f4,$f8,$d4
		.byte $a8,$ac,$c8,$cc,$b8,$bc,$d8,$dc
		.byte $a4,$e4,$e8,$ec,$b4,$f4,$f8,$d4
		.byte $28,$2c,$48,$4c,$38,$3c,$58,$5c
		.byte $24,$64,$68,$6c,$34,$74,$78,$54
		.byte $a8,$ac,$c8,$cc,$b8,$bc,$d8,$dc
		.byte $a4,$e4,$e8,$ec,$b4,$f4,$f8,$d4
		.byte $a8,$ac,$c8,$cc,$b8,$bc,$d8,$dc
		.byte $a4,$e4,$e8,$ec,$b4,$f4,$f8,$d4
		.byte $a8,$ac,$c8,$cc,$b8,$bc,$d8,$dc
		.byte $a4,$e4,$e8,$ec,$b4,$f4,$f8,$d4
		.byte $28,$2c,$48,$4c,$38,$3c,$58,$5c
		.byte $24,$64,$68,$6c,$34,$74,$78,$54
		.byte $a8,$ac,$c8,$cc,$b8,$bc,$d8,$dc
		.byte $a4,$e4,$e8,$ec,$b4,$f4,$f8,$d4
togcr6		.fill 32,$01
		.fill 32,$02
		.fill 32,$01
		.fill 32,$02
		.fill 16,$01
		.fill 48,$03
		.fill 16,$01
		.fill 32,$03
		.fill 16,$02
togcr7		.byte $4a,$4b,$52,$53,$4e,$4f,$56,$57
		.byte $49,$59,$5a,$5b,$4d,$5d,$5e,$55
		.byte $6a,$6b,$72,$73,$6e,$6f,$76,$77
		.byte $69,$79,$7a,$7b,$6d,$7d,$7e,$75
		.byte $4a,$4b,$52,$53,$4e,$4f,$56,$57
		.byte $49,$59,$5a,$5b,$4d,$5d,$5e,$55
		.byte $6a,$6b,$72,$73,$6e,$6f,$76,$77
		.byte $69,$79,$7a,$7b,$6d,$7d,$7e,$75
		.byte $ca,$cb,$d2,$d3,$ce,$cf,$d6,$d7
		.byte $c9,$d9,$da,$db,$cd,$dd,$de,$d5
		.byte $ea,$eb,$f2,$f3,$ee,$ef,$f6,$f7
		.byte $e9,$f9,$fa,$fb,$ed,$fd,$fe,$f5
		.byte $ca,$cb,$d2,$d3,$ce,$cf,$d6,$d7
		.byte $c9,$d9,$da,$db,$cd,$dd,$de,$d5
		.byte $ea,$eb,$f2,$f3,$ee,$ef,$f6,$f7
		.byte $e9,$f9,$fa,$fb,$ed,$fd,$fe,$f5
		.byte $2a,$2b,$32,$33,$2e,$2f,$36,$37
		.byte $29,$39,$3a,$3b,$2d,$3d,$3e,$35
		.byte $2a,$2b,$32,$33,$2e,$2f,$36,$37
		.byte $29,$39,$3a,$3b,$2d,$3d,$3e,$35
		.byte $4a,$4b,$52,$53,$4e,$4f,$56,$57
		.byte $49,$59,$5a,$5b,$4d,$5d,$5e,$55
		.byte $6a,$6b,$72,$73,$6e,$6f,$76,$77
		.byte $69,$79,$7a,$7b,$6d,$7d,$7e,$75
		.byte $aa,$ab,$b2,$b3,$ae,$af,$b6,$b7
		.byte $a9,$b9,$ba,$bb,$ad,$bd,$be,$b5
		.byte $aa,$ab,$b2,$b3,$ae,$af,$b6,$b7
		.byte $a9,$b9,$ba,$bb,$ad,$bd,$be,$b5
		.byte $ca,$cb,$d2,$d3,$ce,$cf,$d6,$d7
		.byte $c9,$d9,$da,$db,$cd,$dd,$de,$d5
		.byte $aa,$ab,$b2,$b3,$ae,$af,$b6,$b7
		.byte $a9,$b9,$ba,$bb,$ad,$bd,$be,$b5
tb800		.text "j.bubela & g.jilg =>tds"^$766f6e73726b6a555e5d4d5b5a594957564f4e53524b4a
		.fill 49,$ff
		.byte $80,$80,$80,$80,$80,$80,$80,$80
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $10,$10,$10,$10,$10,$10,$10,$10
		.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		.byte $c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
		.byte $40,$40,$40,$40,$40,$40,$40,$40
		.byte $50,$50,$50,$50,$50,$50,$50,$50
		.fill 16,$ff
		.byte $20,$20,$20,$20,$20,$20,$20,$20
		.byte $30,$30,$30,$30,$30,$30,$30,$30
		.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		.byte $f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0
		.byte $60,$60,$60,$60,$60,$60,$60,$60
		.byte $70,$70,$70,$70,$70,$70,$70,$70
		.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		.byte $90,$90,$90,$90,$90,$90,$90,$90
		.byte $a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0
		.byte $b0,$b0,$b0,$b0,$b0,$b0,$b0,$b0
		.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		.byte $d0,$d0,$d0,$d0,$d0,$d0,$d0,$d0
		.byte $e0,$e0,$e0,$e0,$e0,$e0,$e0,$e0
		.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
tb900		.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		.byte $ff,$80,$00,$10,$3e,$c0,$40,$50
		.byte $ff,$ff,$20,$30,$ff,$f0,$60,$70
		.byte $ff,$90,$a0,$b0,$ff,$d0,$e0,$ff
		.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		.byte $ff,$80,$00,$10,$2e,$c0,$40,$50
		.byte $ff,$ff,$20,$30,$ff,$f0,$60,$70
		.byte $ff,$90,$a0,$b0,$ff,$d0,$e0,$ff
		.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		.byte $ff,$80,$00,$10,$39,$c0,$40,$50
		.byte $ff,$ff,$20,$30,$ff,$f0,$60,$70
		.byte $ff,$90,$a0,$b0,$ff,$d0,$e0,$ff
		.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		.byte $ff,$80,$00,$10,$52,$c0,$40,$50
		.byte $ff,$ff,$20,$30,$ff,$f0,$60,$70
		.byte $ff,$90,$a0,$b0,$ff,$d0,$e0,$ff
		.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		.byte $ff,$80,$00,$10,$5c,$c0,$40,$50
		.byte $ff,$ff,$20,$30,$ff,$f0,$60,$70
		.byte $ff,$90,$a0,$b0,$ff,$d0,$e0,$ff
		.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		.byte $ff,$80,$00,$10,$12,$c0,$40,$50
		.byte $ff,$ff,$20,$30,$ff,$f0,$60,$70
		.byte $ff,$90,$a0,$b0,$ff,$d0,$e0,$ff
		.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		.byte $ff,$80,$00,$10,$20,$c0,$40,$50
		.byte $ff,$ff,$20,$30,$ff,$f0,$60,$70
		.byte $ff,$90,$a0,$b0,$ff,$d0,$e0,$ff
		.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		.byte $ff,$80,$00,$10,$60,$c0,$40,$50
		.byte $ff,$ff,$20,$30,$ff,$f0,$60,$70
		.byte $ff,$90,$a0,$b0,$ff,$d0,$e0,$ff
tba00		.fill 72,$ff
		.byte $08,$08,$08,$08,$08,$08,$08,$08
		.byte $00,$00,$00,$00,$00,$00,$00,$00
		.byte $01,$01,$01,$01,$01,$01,$01,$01
		.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		.byte $0c,$0c,$0c,$0c,$0c,$0c,$0c,$0c
		.byte $04,$04,$04,$04,$04,$04,$04,$04
		.byte $05,$05,$05,$05,$05,$05,$05,$05
		.fill 16,$ff
		.byte $02,$02,$02,$02,$02,$02,$02,$02
		.byte $03,$03,$03,$03,$03,$03,$03,$03
		.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		.byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
		.byte $06,$06,$06,$06,$06,$06,$06,$06
		.byte $07,$07,$07,$07,$07,$07,$07,$07
		.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		.byte $09,$09,$09,$09,$09,$09,$09,$09
		.byte $0a,$0a,$0a,$0a,$0a,$0a,$0a,$0a
		.byte $0b,$0b,$0b,$0b,$0b,$0b,$0b,$0b
		.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		.byte $0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d
		.byte $0e,$0e,$0e,$0e,$0e,$0e,$0e,$0e
		.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
tbb00		.fill 32,$ff
		.byte $ff,$ff,$80,$80,$ff,$ff,$90,$90
		.byte $ff,$ff,$80,$80,$ff,$ff,$90,$90
		.byte $ff,$ff,$80,$80,$ff,$ff,$90,$90
		.byte $ff,$ff,$80,$80,$ff,$ff,$90,$90
		.byte $ff,$ff,$00,$00,$20,$20,$a0,$a0
		.byte $ff,$ff,$00,$00,$20,$20,$a0,$a0
		.byte $ff,$ff,$00,$00,$20,$20,$a0,$a0
		.byte $ff,$ff,$00,$00,$20,$20,$a0,$a0
		.byte $ff,$ff,$10,$10,$30,$30,$b0,$b0
		.byte $ff,$ff,$10,$10,$30,$30,$b0,$b0
		.byte $ff,$ff,$10,$10,$30,$30,$b0,$b0
		.byte $ff,$ff,$10,$10,$30,$30,$b0,$b0
		.fill 32,$ff
		.byte $ff,$ff,$c0,$c0,$f0,$f0,$d0,$d0
		.byte $ff,$ff,$c0,$c0,$f0,$f0,$d0,$d0
		.byte $ff,$ff,$c0,$c0,$f0,$f0,$d0,$d0
		.byte $ff,$ff,$c0,$c0,$f0,$f0,$d0,$d0
		.byte $ff,$ff,$40,$40,$60,$60,$e0,$e0
		.byte $ff,$ff,$40,$40,$60,$60,$e0,$e0
		.byte $ff,$ff,$40,$40,$60,$60,$e0,$e0
		.byte $ff,$ff,$40,$40,$60,$60,$e0,$e0
		.byte $ff,$ff,$50,$50,$70,$70,$ff,$ff
		.byte $ff,$ff,$50,$50,$70,$70,$ff,$ff
		.byte $ff,$ff,$50,$50,$70,$70,$ff,$ff
		.byte $ff,$ff,$50,$50,$70,$70,$ff,$ff
tbc00		.rept 8
		.byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
		.byte $ff,$08,$00,$01,$ff,$0c,$04,$05
		.byte $ff,$ff,$02,$03,$ff,$0f,$06,$07
		.byte $ff,$09,$0a,$0b,$ff,$0d,$0e,$ff
		.next
tbd00		.fill 32,$ff
		.byte $ff,$ff,$08,$0c,$ff,$0f,$09,$0d
		.byte $ff,$ff,$08,$0c,$ff,$0f,$09,$0d
		.byte $ff,$ff,$08,$0c,$ff,$0f,$09,$0d
		.byte $ff,$ff,$08,$0c,$ff,$0f,$09,$0d
		.byte $ff,$ff,$00,$04,$02,$06,$0a,$0e
		.byte $ff,$ff,$00,$04,$02,$06,$0a,$0e
		.byte $ff,$ff,$00,$04,$02,$06,$0a,$0e
		.byte $ff,$ff,$00,$04,$02,$06,$0a,$0e
		.byte $ff,$ff,$01,$05,$03,$07,$0b,$ff
		.byte $ff,$ff,$01,$05,$03,$07,$0b,$ff
		.byte $ff,$ff,$01,$05,$03,$07,$0b,$ff
		.byte $ff,$ff,$01,$05,$03,$07,$0b,$ff
tbd80		.word $7a00+42*range(18)
		.word $7cf0+38*range(7)
		.word $7df8+36*range(6)
		.word $7ece+34*range(9)
sector_address	.word $6100+325*range(21)

		*= $bdff
		.byte $c8
lbe00_lbe09	jmp lbe09

track0_patch2	jmp track0_patch

lbe06_lc1a3	jmp lc1a3

lbe09		ldx input
		cpx #"x"
		bne lbe06_lc1a3
		ldx input+1
		cpx #"u"
		beq lbe3a
		lda #$30
		jsr lc1a3
		lda #$30
		sta m243
		ldy #size(locked_txt)-1
-		lda locked_txt,y
		sta (errp),y
		dey
		bpl -
		rts

locked_txt	.text "8,files locked"

lbe3a		lda #$39
		jsr lc1a3
		lda #$30
		sta m243
		ldy #15
-		lda unlocked_txt-7,y
		sta (errp),y
		dey
		cpy #6
		bne -
		rts

unlocked_txt	.text "s unlocke"
;---------------
; Track 0 sensor head stop
;
track0_patch	lda track0_flag
		eor #DISABLED
		bne lbe8f
		ldx #100
-		lda via1.pran
		cmp via1.pran
		bne lbe8f
		dex
		bne -
		and #%00000001
		beq lbe8f
		lda via2.prb
		and #STEPPER_MASK
		bne lbe8f
		lda #0
		sta head_step_count
		sta z61
		lda z62
		cmp #$97
		beq +
		lda #$3b
		sta z62
		jmp lfabe

+		jmp lfaa5

lbe8f		inc head_step_count
		ldx via2.prb
		dex
		jmp track0_return

		*= $c001
;---------------
; Scratch patch for locking/unlocking
;
scratch_patch	jsr lddb7
		bcc lc031_rts
		lda input
		cmp #"s"
		beq lc031_rts
		ldy #0
		lda (p94),y
		pha
		ldx input+1
		cpx #"l"
		bne +
		and #LOCK_FLAG
		bne lc02f
		pla
		ora #LOCK_FLAG
		gne lc029

+		and #LOCK_FLAG
		beq lc02f
		pla
		and #~LOCK_FLAG
lc029		jsr lc8b9
		inc p86
		.byte $24		;bit
lc02f		pla
		clc
lc031_rts	rts

erase_patch	lda ram_flag
		cmp #DISABLED
		bne lc04c
		jsr lef5f
		jmp erase_return

bam_allocate_patch lda ram_flag
		cmp #DISABLED
		bne lc04c
		jsr check_ts
		jmp bam_allocate_return

lc04c		bit m6009
		bvs lc06c
		ldx #40+1
		lda #0
-		sta t79d7-1,x
		dex
		bne -
		stx p86
		lda #%01000000
		sta m6009
		lda #<xa018_la4a8
		sta p6021
		lda #>xa018_la4a8
		sta p6021+1
lc06c		lda input
		pha
		lda #"x"
		sta input
		lda #$11
		sta z83
		lda #1
		sta m24a
		jsr ld1e2
		jsr ldcb6
		lda #%00000010
		ora z7f
		sta zec,x
		lda #$88
		sta tf2,x
		jsr lf119
		lda za7,x
		cmp #$ff
		beq +
		lda m2f9
		ora #%01000000
		sta m2f9
+		jsr ldf93
		sta z85
lc0a4		jsr check_ts
		pla
		pha
		cmp #"v"
		bne +
		jsr lef90
		jmp lc0b6

+		jsr lef5f
lc0b6		lda z85
		asl
		tax
		lda current_track
		sta job_tr,x
		tax
		ldy t79d7,x
		bne +
		ldx z85
		lda #$e0
		sta p0,x
		sta t25b,x
		jsr ld599
		lda current_track
+		asl
		tax
		lda tbd80-2,x
		sta buffp
		lda tbd80-1,x
		sta buffp+1
		lda current_sector
		asl
		tay
		lda (buffp),y
		sta current_track
		pha
		iny
		lda (buffp),y
		sta current_sector
		pla
		bne lc0a4
		pla
		sta input
		cmp #"v"
		bne lc0fa_lc8a7
		jmp ld227

lc0fa_lc8a7	jmp lc8a7

		*= $c0ff
		.byte $fa

		*= $c835
		jsr scratch_patch

		*= $c87a
		jmp lbe00_lbe09
;---------------
;Erase patch
;
erase		jmp erase_patch
erase_return

;---------------
;Format
		*= $c8c6
		ldx #size(jump_code)-1
-		lda jump_code,x
		sta t600,x
		dex
		bpl -
		stx z51
		lda #3
		jsr ld6d3
		ldx #3

		*= $c8e8
		jmp le60a

jump_code	jmp lfac7
		nop


;---------------
;Block allocate patch
;
		*= $cd22
		cmp max_track

		*= $d08d
		jmp lfb60
ld090
		*= $d367
		jmp lffa7
		.byte ?
ld36b
		*= $d51d
		cmp max_track

		*= $d563
		cmp max_track

		*= $d8cb
		bne ld8f0

		*= $d902
		ldy #0
		lda (p94),y
		and #%01000000
		bne ld8eb
		jsr lc8b9
		ldy #1
		lda (p94),y
		sta current_track
		iny
		lda (p94),y
		sta current_sector
		jsr erase
		lda #0
		sta m280
		jmp ld852
;---------------
ld923		txa
		and #STEPPER_MASK
		sta z4b
		lda via2.prb
		and #~STEPPER_MASK
		ora z4b
		sta via2.prb
		ldx #4
		stx z4b
-		inx
		bne -
		dec z4b
		bne -
		rts

		*= $e5b7
		.text "Dolphindos.3"

		*= $e69c
		jmp bin_bcd_patch

		*= $e781
le781		lda extend_flag
		cmp #DISABLED
		beq le795
		ldx #35+1
		lda z54
		cmp #$0d
		bne +
		ldx #40+1
+		stx max_track
le795		lda id
		sta diskid
		jmp lf414

		*= $e902
		jmp la00f_la81f

		*= $e911
		jmp la012_la9ce
		nop
		rts
le916

		*= $ea44
		jmp la015_la902
lea47

;---------------
;ROM test patch
;
		*= $eaa2
		lda #2
		sta via1.prb
		lda #$10 | DATA_OUT | CLOCK_OUT
		sta via1.ddrb
		ldx #0
		stx pia.cra
		lda #$68
		sta via2.prb
		ora #%00001111
		jmp lff2f

leabb		lda #$ff
-		sta p0,x
		cmp p0,x
		bne lea6e
		inc p0,x
		bne lea6e
		inx
		bne -
		txa
		sta z75
-		inc z6f
		stx z76

;---------------
;Check extra ROM as well
;
		*= $eae2
		eor z76
		bne leb1f
		cpx #>$a000
		bne -

		*= $eb2a
		jmp lfb99
leb2d
		*= $ebc2
		jsr la000_la34b

		*= $ebe4
		jsr lf381

		*= $ec5c
		jsr lff78
		bit m6009
		stx m6009
		bpl +
		ldx z3f
		jmp ld63f
		nop
+
		*= $ecc1
		lda #8

		*= $ede5
		jmp bam_allocate_patch
bam_allocate_return

		*= $ee36
		jsr format_40tr_patch

		*= $eecf
		jmp lfbad
leed2

		*= $eeed
		cpy #$c0

		*= $ef25
		jmp lff87
lef28
		*= $ef2f
		cmp max_track

		*= $f01f
		jsr le645

		*= $f077
		jsr lfb8f

		*= $f0b7
		jsr lfb8f

		*= $f147
		cmp max_track

		*= $f1d5
		cmp max_track
		blt +
		lda #$72
		jmp lc1c8
+

		*= $f2a4
		lda #4
		sta z64
		lda #1
		sta z5e
		lda #37

		*= $f30c
		jmp la00c_la117
lf30f

		*= $f35c
		jmp la006_la024
lf35f

		*= $f37c
		jsr lfad7
		bne lf390
;---------------
lf381		bit via1.prb
		bmi lf387_le85b
		rts

lf387_le85b	jmp le85b

		*= $f3d1
		cpx #9

		*= $f410
		jmp le781
		nop
lf414

;---------------
;Patch for spin up speed
;
		*= $f98a
		lda #30

		*= $f9ad
		jmp lfbc5
		nop
lf9b1
		*= $f9d9
		jmp la009_la313
		nop
lf9dd
;---------------
;Patch head out move
;
		*= $fa32
		jmp track0_patch2
		nop
		nop
		nop
track0_return

;---------------
;Patch head movement speed
;
		*= $fa47
		lda #1
;---------------
;Patch head movement speed
;
		*= $faba
		lda #1

		*= $fac7
lfac7		lda z51
		bpl lfaf5
		ldx z3d
		stx zff
		jsr lfad7
		sta z51
		jmp lf99c
;---------------
lfad7		lda #$60
		sta z20,x
		lda z22,x
		bne +
		lda #$2c
+		asl
		eor #%11111111
		sbc #0
		sta head_step_count
		lda via2.prb
		and #~STEPPER_MASK
		sta via2.prb
		lda #1
		sta z22,x
		rts

lfaf5		ldy #0
		cmp (p32),y
		beq +
		sta (p32),y
		jmp lfb1e

+		lda #WRITE_PROTECT
		bit via2.prb
		beq lfb17
		lda #5
		sta m620
lfb0c		jsr lfbda
		bcc lfb1b_lfc67
lfb11		dec m620
		bne lfb0c
		.byte $24		;bit
lfb17		lsr
		jmp lfddb

lfb1b_lfc67	jmp lfc67

lfb1e		ldy #0
		lda z22
		sec
		sbc (p32),y
		beq lfb4d_lf99c
		eor #%11111111
		sta head_step_count
		inc head_step_count
		asl head_step_count
		bpl lfb3e
-		ldx via2.prb
		dex
		jsr ld923
		inc head_step_count
		bne -
		geq +

lfb3e		ldx via2.prb
		inx
		jsr ld923
		dec head_step_count
		bne lfb3e
+		lda (p32),y
		sta z22
lfb4d_lf99c	jmp lf99c
;---------------
lfb50		lda via2.pcr
		and #%00011111
		ora #%11000000
		sta via2.pcr
		lda #$ff
		sta via2.ddra
		rts

lfb60		pha
		bne lfb70
		lda max_track
		cmp #40+1
		bne lfb74_ld090
		ldy #$ac
lfb6c		pla
		jmp ld07d

lfb70		cpy #$c0
		bne lfb6c
lfb74_ld090	jmp ld090
;---------------
;Format 40 track if there's a "+" after ID
;
format_40tr_patch lda extend_flag
		cmp #DISABLED
		beq lfb8c_ld307
		ldx #35+1
		lda input+2,y
		cmp #"+"
		bne +
		ldx #40+1
+		stx max_track
lfb8c_ld307	jmp ld307
;---------------
lfb8f		asl a
		cmp #$90
		blt +
		adc #$1b
+		sta z99,x
		rts

lfb99		sta via2.prb
		lda #DISABLED
		cmp extend_flag
		beq lfba8_leb2d
		lda #35+1
		sta max_track
lfba8_leb2d	jmp leb2d

-		ldy #$ac
lfbad		tya
		lsr
		lsr
		cpy #$90
		beq -
		blt +
		ldx max_track
		cpx #40+1
		bne lfbc2_ld075
		sbc #7
+		jmp leed2

lfbc2_ld075	jmp ld075

lfbc5		bcs +
		sta z3e
		jsr lf982
		jsr lf991
+		lda #1
		sta z1c
		lsr
		sta cached_track
		jmp lf9b1
;---------------
lfbda		ldx #4
		lda z51
-		cmp tfed7,x
		beq lfbf4
		dex
		bpl -
		lsr
		beq +
		clc
		rts

+		jsr lfda3
		jsr lfe00
		jsr lf556
lfbf4		jsr lfe0e
		lda #$ff
		sta via2.pra
-		bvc *

		clv
		inx
		cpx #5
		bne -
		jsr lfe00
-		lda via2.prb
		bpl lfc1f
		bvc -
		clv
		inx
		bne -
		iny
		bne -
		lda #NO_SYNC
		.byte $2c		;bit
lfc18		lda #BLOCK_NOT_FOUND
		.byte $2c		;bit
lfc1b		lda #CHECKSUM_ERROR
		sec
		rts

lfc1f		sty m624
		stx m625
		ldx max_sectors
		ldy #0
		tya
lfc2a		clc
		adc #$63
		bcc +
		iny
+		iny
		dex
		bne lfc2a
		eor #%11111111
		sec
		adc #0
		clc
		adc m625
		bcs +
		dec m624
+		tax
		tya
		eor #%11111111
		sec
		adc #0
		clc
		adc m624
		bmi lfc18
		tay
		txa
		ldx #0
lfc53		sec
		sbc max_sectors
		bge +
		dey
		bmi lfc5e
+		inx
		bne lfc53
lfc5e		stx m626
		cpx #4
		blt lfc1b
		clc
		rts

lfc67		jsr lfb50
		lda #$55
		sta via2.pra
		lda z50
		bne lfcb4
		jsr lf934
		lda #0
		sta buffp+1
		lda #$29
		sta z34
		lda diskid+1
		sta z52
		lda diskid
		sta z53
		lda #$0f
		ldx max_track
		cpx #40+1
		bne +
		lda #$0d
+		sta z54
		lda #$0f
		sta z55
		jsr lf961
		lda #"k"
		sta t500
		ldx #1
		txa
-		sta t500,x
		inx
		bne -
		lda #>t500
		sta buffp+1
		jsr lf5e9
		sta chksum
		jsr lf78f
lfcb4		ldx #0
		stx format_sector
-		bvc *

		clv
		inx
		bpl -
lfcbf		lda #$ff
		sta via2.pra
		jsr la021_ladbe
		ldx #0
-		bvc *

		clv
		lda z24,x
		sta via2.pra
		inx
		cpx #10
		bne -
		dex
-		bvc *

		clv
		ldy #$55
		sty via2.pra
		dex
		bne -
		lda #$ff
		ldx #5
-		bvc *

		clv
		sta via2.pra
		dex
		bne -
		ldx #<$1bb
-		bvc *

		clv
		lda t100,x
		sta via2.pra
		inx
		bne -
-		bvc *

		clv
		lda t500,x
		sta via2.pra
		inx
		bne -
		ldx m626
-		bvc *

		clv
		sty via2.pra
		dex
		bne -
		inc format_sector
		lda format_sector
		cmp max_sectors
		bne lfcbf
		bvc *

		clv
		bvc *

		clv
		jsr lfe00
		lda verify_flag
		cmp #DISABLED
		beq lfd80
		lda #200
		sta format_retry
lfd34		lda #0
		sta format_sector
		jsr la021_ladbe
lfd3c		jsr lf556
		ldx #0
-		bvc *

		clv
		lda via2.pra
		cmp z24,x
		bne lfd8c
		inx
		cpx #10
		bne -
		inc format_sector
		jsr la021_ladbe
		jsr lf556
		ldx #<$1bb
-		bvc *

		clv
		lda via2.pra
		cmp t100,x
		bne lfd8c
		inx
		bne -
-		bvc *

		clv
		lda via2.pra
		cmp t500,x
		bne lfd8c
		inx
		cpx #252
		bne -
		lda format_sector
		cmp max_sectors
		bne lfd3c
lfd80		inc z51
		lda z51
		cmp max_track
		bge lfd96
		jmp lf99c

lfd8c		dec format_retry
		bne lfd34
		lda #6
		jmp lfb11
lfd96

;---------------
;Shorter erase for format
;
		*= $fdb5
		ldx #33
;---------------
;Shorter erase for format
;
		*= $fe22
		ldx #33
;---------------
;Patches for command x
;
		*= $fe8b
		.text "x"

		*= $fe97
		.byte <la003

		*= $fea3
		.byte >la003
;---------------
;Up to 40 tracks
;
		*= $fed7
tfed7		.byte 40+1

		*= $ff10
;---------------
lff10		lda #<lf35f
		sta p6021
		lda #>lf35f
		sta p6021+1
		rts

		.byte $ad, $bd, $aa, $c1, $cf

-		lda via1.prb
		and #%00000001
		bne -
		lda #1
		sta via1.t1ch
		jmp le9df

lff2f		sta via2.ddrb
		stx pia.pra
		stx via1.ddra
		lda #pia.DDRN
		sta pia.cra
		lda via2.prb
		and #WRITE_PROTECT
		bne +
		ldx #4-1
-		lda p0,x
		sta ram_backup,x
		dex
		bpl -
		lda #0
		sta p0
		sta p0+1
		sta p2
		lda #>ram_backup
		sta p2+1
		ldx #8
		ldy #4
-		lda (p0),y
		sta (p2),y
		iny
		bne -
		inc p0+1
		inc p2+1
		dex
		bne -
-		lda flags,x
		sta t7800,x
		inx
		bne -
+		jmp leabb
;---------------
lff78		ldx #0
		stx pia.cra
		stx pia.pra
		ldx #pia.DDRN
		stx pia.cra
		gne lff10

lff87		asl
		cmp #$90
		blt +
		adc #$1b
+		sta z6d
		jmp lef28
;---------------
; Patch BIN/BCD conversion for IRQ
;
bin_bcd_patch	php
		sei
		lda #0
		sed
-		cpx #0
		beq +
		clc
		adc #1
		dex
		jmp -

+		plp
		jmp le6aa
;---------------
lffa7		cmp #2
		blt +
		cmp #15
		beq +
		jmp ld36b

+		jmp ld373

		.byte $63

		*= $ffe0
lffe0_lfb1e	jmp lfb1e

		jmp lfbda


