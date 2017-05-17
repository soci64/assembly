
OPER		.block
END		= %10000
MASK		= %1111
ADD:		= 0
SUB:		= 1
MUL:		= 2
DIV:		= 3
HIGH:		= 4
LOW:		= 5
LONG:		= 6
AND:		= 7
OR:		= 8
XOR:		= 9
LPARENT:	= 10
RPARENT:	= 11
		.bend

		*= $8000

z14             = $14
z15             = $15
z37             = $37
z38             = $38
p39             = $39
pmemory_put     = $3b
p3d             = $3d
p3f             = $3f
macro_param_p	= $43
p45             = $45
p47             = $47
p49             = $49
p4b             = $4b
current_address = $4d
memory_bottom	= $4f
p51             = $51
p53             = $53
z91		= $91
z9a             = $9a
z9d             = $9d
pd1		= $d1
print_column	= $d3
pf0             = $f0
zf2             = $f2
pfb             = $fb
zfd             = $fd
zfe             = $fe
t100            = $100
t101            = $101
t102            = $102
m103            = $103
t10a            = $10a
m10c            = $10c
m10d            = $10d
m10e            = $10e
t10f            = $10f
m110            = $110
m120            = $120
m121            = $121
m145            = $145
line_buffer_200 = $200
opcode_buf	= $2c0			; 3 bytes
memory_bottom_default = $7feb
signature       = $7fec
tab_position    = $cb00
source_p	= $cb01
src_current_line_flags           = $cb03
mcb04           = $cb04
mcb05           = $cb05
current_line           = $cb06
destination_line = $cb08
screen_line_start = $cb0a
cursor_x_position = $cb0c
cursor_y_position = $cb0d
cursor_tab      = $cb0e
mcb0f           = $cb0f
insert_char_mode           = $cb10
raw_mode_flag	= $cb11
memory_lines    = $cb12
mcb14           = $cb14
mcb15           = $cb15
currect_color_set = $cb16
mcb17           = $cb17
mcb18           = $cb18
mcb19           = $cb19
mcb1a           = $cb1a
error_count	= $cb1e			; word
mcb23		= $cb23
mcb24           = $cb24
mark_lines	= $cb28
tcb37		= $cb37
tcb3a           = $cb3a
mcb3c           = $cb3c
mcb3d           = $cb3d
mcb3e           = $cb3e
mcb3f           = $cb3f
tcb40           = $cb40
fkey_strings    = $cb5a
tcb96           = $cb96
tcb9a           = $cb9a
tcbb8           = $cbb8
mcbb9           = $cbb9
lines_memory_cc00 = $cc00
label_value_store = $e000
labels_low	= $ec00
labels_high     = $ec30
labels_mem_start = $ec60
clrscr		= $e544

start
		jmp start2

l8006		lda #$37
                sta $01
                rts
					;8003
m800b
		.byte $00
m800c
		.byte $00
m800d
		.byte $ff
m800e
		.byte $0a
m800f
		.byte $18
m8010
		.byte $00
m8011
		.byte $12
m8012
		.byte $27
m8013
		.byte $e6
m8014
		.byte $17
line_color
		.byte $00,$00
m8017
		.byte $ff
m8018
		.byte $00
m8019
		.byte $27
m801a
		.byte $16
m801b
		.byte $00,$00,$00,$00
m801f
		.byte $fc
line_buffer_filled
		.byte $00
m8021
		.byte $06
m8022
		.byte $f8,$00
m8024
		.byte $23,$00
m8026
		.byte $ff,$00,$00,$00,$00
m802b
		.byte $13
m802c
		.byte $00
;---------------
;exit

arrow_excl
                jsr check_ide64
                ldx #11
sds2            lda $e447,x
		bcc nonei2
		lda oldvectors2,x
nonei2          sta $300,x
                dex
                bpl sds2
arrow_1
		jsr pharse_line_if_any
		lda #$37
		sta $1
		jsr reset_vectors_install_334
		lda #$4c		;"L"
		sta p53+1
                jsr clrscr
		lda z37
		cmp mcb14
		lda z38
		sbc mcb15
		blt l805b
		sec
		lda mcb14
		sbc #$64		;100
		sta z37
		lda mcb15
		sbc #0
		sta z38
l805b
		jmp $a474
					;805e
txt_eqdollar
		.null "= $"
txt_labeltab
		.null $8d,$93,"; **** lABELTAB ****",$8d,$8d
txt_end_labeltab
		.null $8d,"; **** eNDLABELTAB ****",$8d
;---------------
print_ay
		sta p39
		sty p39+1
		ldy #0
l8115
		lda (p39),y
		beq l811f_rts
		jsr $ffd2
		iny
		bne l8115
l811f_rts
		rts
					;8120
dollar
		.byte $24
;---------------
check_device_present
		lda #0
		sta $90
                lda #15
		ldx drivenum_at+1
                tay
                jsr $ffba
                lda #0
                sta $b7
                jsr $ffc0
                lda #15
                jsr $ffc3
		lda $90
		rts
;---------------
arrow_star
		jsr pharse_line_if_any
		jsr check_device_present
		beq l972b_rts
		ldx #$1e		;"*"
		jmp l8ee4		;device not present
					;972b
l972b_rts
					;8139
		lda #$0d		;13
		jsr $ffd2
                jsr clrscr
		lda #$37
		sta $1
		lda #4
		ldx $ba
		ldy #$60
		jsr $ffba
                lda #1
		ldx #<dollar
		ldy #>dollar
                jsr $ffbd
                jsr $ffc0
                ldx #4
                jsr $ffc6
		lda #0
		sta $90
		ldy #3
l817a
		sty m800c
		jsr $ffcf               ;cint
		sta m800b
		ldy $90
		bne l81b8
		jsr l8ba0
		ldy $90
		bne l81b8
		ldy m800c
		dey
		bne l817a
		ldx m800b
		jsr $bdcd
		lda #$20		;" "
		jsr $ffd2
l819f
		jsr $ffcf               ;cint
		ldx $90
		bne l81b8
		tax
		beq l81af
		jsr $ffd2
		jmp l819f
					;81af
l81af
		lda #$0d		;13
		jsr $ffd2
		ldy #2
		bne l817a
l81b8
		jsr $ffcc
                lda #4
                jsr $ffc3
l81bb
		lda #<txt_press_any_key2
		ldy #>txt_press_any_key2
		jsr print_ay
-		jsr $ffe4
		beq -
		jmp start
					;81ca
txt_press_any_key2
		.null $12,"      pRESS A KEY       ",$92
					;81e5
;---------------
arrow_colon
		jsr pharse_line_if_any
		lda #$ff		;255
		sta m800b
		lda #<txt_marks_are
		ldy #>txt_marks_are
		jsr print_ay
l81f4
		lda #$0d		;13
		jsr $ffd2
		ldx #7
		sta print_column
		inc m800b
		lda m800b
		cmp #12
		bne +
		lda #$0d		;13
		jsr $ffd2
		jmp l81bb
					;820f
+
		asl
		tay
		lda memory_lines
		cmp mark_lines,y
		lda memory_lines+1
		sbc mark_lines+1,y
		blt +
		lda mark_lines+1,y
		ldx mark_lines,y
		ldy #$37
		sty $1
		jsr $bdcd
		jmp l81f4
					;822f
+
		lda #<txt_not_set
		ldy #>txt_not_set
		jsr print_ay
		jmp l81f4
					;8239
txt_marks_are
		.text $93,$8d,$8d,$12
		.text "*   mARKS ARE :  *",$92,$8d
		.text $8d,"0",$8d,"1",$8d,"2",$8d,"3"
		.text $8d,"4",$8d,"5",$8d,"6",$8d,"7"
		.text $8d,"8",$8d,"9",$8d,"sTA"
		.text "RT",$8d,"eND",$8d,$13
		.null $11,$11,$11
txt_not_set
		.null "nOT SET"
					;8284
;---------------
;l8284
		pha			; dead
		lda #" "
		jsr $ffd2
		pla
;---------------
hex_print
		pha
		lsr
		lsr
		lsr
		lsr
		jsr +
		pla
		and #%1111
+		cmp #10
		blt +
		adc #6
+		adc #"0"
		jmp $ffd2
					;82a1
;---------------
l82a1
		lda #<labels_mem_start		;96
		sta labels_low
		lda #>labels_mem_start		;236
		sta labels_high
		lda #0
		sta mcb04
		sta mcb05
		rts
					;82b4
;---------------
arrow_f1
		ldx #$1b		;27
		jsr print_message
;---------------
reset_f_keys
		ldy #4*16-1
-		lda default_fkey_strings,y
		sta fkey_strings,y
		dey
		bpl -
		rts
					;82c5
default_fkey_strings
		.text $0b,'.TEXT " "',$9d,$9d,$20,$20,$20,$20
		.text $04,$5f,"3RS           ",$0b,".BYTE $00",$9d,$9d,$20,$20,$20,$20
		.text $02,$5f,$14,"             "
turbo_signature
		.text "TURBO"
;---------------
set_default_settings
		ldy #4
l830c
		lda turbo_signature,y
		sta signature,y
		dey
		bpl l830c
		jsr reset_f_keys
		jsr l82a1
		lda #0
		sta mcb19
		sta mcb1a
		lda #0
		sta insert_char_mode
		lda #$ff		;255
		sta mcb0f
		lda #0
		sta cursor_x_position
		lda #0
		sta cursor_y_position
		sta currect_color_set
		lda #9
		sta tab_position
		sta cursor_tab
		ldy #$17		;23
		lda #$ff		;255
l8346
		sta mark_lines,y
		dey
		bpl l8346
		sei
		lda $1
		pha
		lda #$34
		sta $1
		ldy #24
		lda #0
-		sta lines_memory_cc00,y
		dey
		bpl -
		pla
		sta $1
		cli
		lda #0
		sta current_line
		sta current_line+1
		sta screen_line_start
		sta screen_line_start+1
		lda #<memory_bottom_default
		sta source_p
		lda #>memory_bottom_default
		sta source_p+1
		lda #$16		;22
		sta memory_lines
		lda #0
		sta memory_lines+1
		ldy #$17		;23
		lda #$7f		;127
l8388
		sta mark_lines,y
		dey
		bpl l8388
		rts
					;838f
start2
		lda #<$2000
		ldx #>$2000		;" "
		sta current_address
		stx current_address+1

		ldy #$1c		;28
		lda #0
l806e		sta $d400,y
		dey
		bpl l806e
                lda #0
                sta 646
		lda #22
		sta $d018
		jsr clrscr

		lda #$36
		sta $1
first_at      	jsr first
	        jsr reset_vectors_install_334
		ldy #5
l839c
		dey
		bmi l83aa
		lda turbo_signature,y
		cmp signature,y
		beq l839c
l83a7
		jsr set_default_settings
l83aa
		sei
		lda #<irq_normal
		sta $314
		lda #>irq_normal
		sta $315
                cli
		ldx #2
		jsr print_message
l83d0
		jsr l8e07
		lda #0
		sta line_buffer_filled
		sta raw_mode_flag
		ldx currect_color_set
		lda border_colors,x
		sta $d020
		lda paper_colors,x
		sta $d021
		lda #0
		jsr l8a27
                jsr redraw_all_lines_on_screen
		jmp l8737
					;83f5
;---------------
jump_on_line
		lda $1
		pha
		sei
                ldy #$34
		sty $1
		ldy #0
		sec
		lda current_line
		sbc destination_line
		pha
		lda current_line+1
		sbc destination_line+1
		sta m800c
		pla
		tax
		bcs l8428
l8412
		jsr next_line
		inx
		bne l8412
		inc m800c
		bne l8412
l841d
		jsr get_current_line_flags
		sta src_current_line_flags
		pla
		sta $1
		cli
		rts
					;8428
l8428
		inx
l8429
		dex
		bne l8431
		dec m800c
		bmi l841d
l8431
		jsr prev_line
		jmp l8429
					;8437
;---------------
next_line
		inc current_line
		bne +
		inc current_line+1
+		jsr get_current_line_flags
		and #%00111111
		clc
		sbc source_p
		eor #%11111111
		sta source_p
		bcc +
		dec source_p+1
+		rts
					;8453
;---------------
prev_line
		jsr get_current_line_flags
		and #%00111111
		clc
		adc source_p
		sta source_p
		bcc +
		inc source_p+1
+		lda current_line
		bne +
		dec current_line+1
+		dec current_line
		rts
					;8470
;---------------
get_current_line_flags
		clc
		lda current_line
		sta p39
		lda current_line+1
		adc #>lines_memory_cc00		;204
		sta p39+1
		lda (p39),y
		rts
					;8480
t8480
		.byte $00^$80,$20^$20,$40^$00,$60^$40,$80^$c0,$a0^$60,$c0^$40,$e0^$60
paint_line_to_screen
		jsr $e9f0               ;set start of line

		ldy #40-1
-		lda (pmemory_put),y
		cmp #$20		;" "
		beq +
		lsr
		lsr
		lsr
		lsr
		lsr
		tax
		lda (pmemory_put),y
		eor t8480,x
+		sta (pd1),y
		dey
		bpl -

		lda pd1+1
		clc
		adc #$d4
		sta pd1+1

		ldy #40-1
		lda (pd1),y
		and #%00001111
		cmp line_color
		beq +

		lda line_color
-		sta (pd1),y
		dey
		bpl -
+
		rts
;---------------
redraw_all_lines_on_screen
		lda #0
		sta m8014
l8551
		jsr print_this_line_on_screen
		inc m8014
		lda m8014
		cmp #$17		;23
		blt l8551
                rts
					;84c6
;---------------
l8561
		jmp lade0
					;8564
;---------------
prepare_print_line
		clc
		adc screen_line_start
		sta destination_line
		lda screen_line_start+1
		adc #0
		sta destination_line+1
		jsr jump_on_line
		jsr l8561
		ldx currect_color_set
		bcs its_error
		lda current_line
		cmp mcb3c
		lda current_line+1
		sbc mcb3d
		blt its_source
		lda memory_lines+1
		cmp mcb3f
		blt its_source
		lda mcb3e
		cmp current_line
		lda mcb3f
		sbc current_line+1
		blt its_source
		clc
		lda selection_colors,x
		sta line_color
		rts
					;85aa
its_source
		lda source_colors,x
		sta line_color
		rts
					;85b1
its_error
		lda error_colors,x
		sta line_color
		rts
					;85b8
;---------------
print_this_line_on_screen
		pha
		jsr prepare_print_line
		pla
		tax
;---------------
l85be
		lda #<line_buffer_200
		ldy #>line_buffer_200
l85c2
		sta pmemory_put
		sty pmemory_put+1
		jmp paint_line_to_screen
					;85c9
;---------------
l85c9
		lda #1
		ldy #1
		jmp l85c2
					;85d0
;---------------
l85d0
		lda #1
		ldy #1
		sta pmemory_put
		sty pmemory_put+1
		lda #<status_line_txt
		ldy #>status_line_txt
		jsr l86ac
		ldy #$27		;"'"
		bit mcb0f
		bmi +
		jsr l86a0
+		ldy #$22		;"""
		bit insert_char_mode
		bmi +
		jsr l86a0
+		ldx #2
		lda cursor_x_position
		ldy #0
		jsr l864f
		clc
		lda screen_line_start
		adc cursor_y_position
		tax
		lda screen_line_start+1
		adc #0
		tay
		txa
		ldx #$0a		;10
		jsr l864f
		ldx #$13		;19
		lda mcb15
		jsr l862d
		lda mcb14
		jsr l862d
		ldx currect_color_set
		lda text_colors,x
		sta line_color
		ldx #$18		;24
		jmp paint_line_to_screen
					;862d
;---------------
l862d
		pha
		lsr
		lsr
		lsr
		lsr
		jsr +
		pla
		and #%1111
+		cmp #10
		blt +
		adc #6
+		adc #"0"
		sta t101,x
		inx
		rts
					;8645
tens		.word 1, 10, 100, 1000, 10000
;---------------
l864f
		stx m800e
		sta p39
		sty p39+1
		lda #$ff		;255
		sta m800d
		ldx #8
l865d
		ldy #$30		;"0"
l865f
		sec
		lda p39
		sbc tens,x
		sta m8018
		lda p39+1
		sbc tens+1,x
		blt l8679
		sta p39+1
		lda m8018
		sta p39
		iny
		bne l865f
l8679
		tya
		cmp #$30		;"0"
		bne l8683
		bit m800d
		bmi l868f
l8683
		ldy m800e
		sta t101,y
		inc m800e
		sta m800d
l868f
		dex
		dex
		bpl l865d
		bit m800d
		bpl l869f_rts
		tya
		ldx m800e
		sta t101,x
l869f_rts
		rts
					;86a0
;---------------
l86a0
		ldx #4
		lda #" "
-		sta t101,y
		dey
		dex
		bne -
		rts
					;86ac
;---------------
l86ac
		sta p39
		sty p39+1
;---------------
l86b0
		ldy #40-1
		lda #" "
-		sta t101,y
		dey
		bpl -

-		iny
		lda (p39),y
		pha
		and #%01111111
		sta t101,y
		pla
		bpl -
		rts
					;86c7
status_line_txt
		.shift "x:   lINE:     bOT:     iNSERT:CHAR LINE"
;---------------
l86ef
		lda #$28		;"("
		sta $dc05
		jsr $e9f0               ;set start of line
		lda #0
		sta m8018
l86fc
		jsr cursor_flash
		lda #$14		;"F"
		bit raw_mode_flag
		bpl +
		lsr
+		tax
l8708
		lda $d011
ls1		ldy 198
		bne l870e
		cmp $d011
                bpl ls1
		dex
                bne l8708
		geq l86fc
l870e
		lda 198
		beq l8708
		jsr $f142
		tax
		lda m8018
		beq +
		jsr cursor_flash
+		txa
		ldx #$40		;"@"
		stx $dc05
		rts
					;8725
;---------------
cursor_flash
		ldy cursor_x_position
		lda (pd1),y
		eor #%10000000
		sta (pd1),y
		lda m8018
		eor #%11111111
		sta m8018
		rts
					;8737
;---------------
l8737
		ldx #$fa		;250
		txs
		lda #$36
		sta $1
		cli
repeat_at
		lda #$80		;128
		sta 650
		lda line_color
		pha
		jsr l85d0
		pla
		sta line_color
		bit line_buffer_filled
		bpl l8755
		ldx cursor_y_position
		jsr l85be
l8755
		ldx cursor_y_position
		jsr l86ef
		sta m8018
		bit raw_mode_flag
		bmi l876f
		jsr l8807
		jsr l8b68
l8769
		jsr l8779
		jmp l8737
					;876f
l876f
		cmp #$5f		;95
		bne l8769
		sta raw_mode_flag
		jmp l8737
					;8779
;---------------
l8779
		jsr l87a4
		bit insert_char_mode
		bpl l8798
		lda line_buffer_200+39
		cmp #$20		;" "
		bne l87b4_rts
		ldx #$27		;"'"
l878a
		lda line_buffer_200-1,x
		sta line_buffer_200,x
		dex
		beq l8798
		cpx cursor_x_position
		bge l878a
l8798
		lda m8018
		ldx cursor_x_position
		sta line_buffer_200,x
		jmp l88c9
					;87a4
;---------------
l87a4
		lda line_buffer_filled
		bne l87b4_rts
;---------------
arrow_z
		lda cursor_y_position
		jsr prepare_print_line
		lda #$ff		;255
		sta line_buffer_filled
l87b4_rts
		rts
					;87b5
key_commands	.byte $91,$11,$1d,$9d,$8d,$0d,$14,$94,$85,$88,$89,$8c,$86,$8a,$87,$8b,$13

key_tabl	.rta key_up
		.rta key_down
		.rta key_right
		.rta key_left
		.rta key_shreturn
		.rta key_return
		.rta key_delete
		.rta key_insert
		.rta key_f1
		.rta key_f7
		.rta key_f2
		.rta key_f8
		.rta key_f3
		.rta key_f4
		.rta key_f5
		.rta key_f6
		.rta key_home
;---------------
key_f3
		ldx #0
		.byte $2c		;bit
;---------------
key_f4                                  ;accessed parameter
		ldx #$10		;16
		.byte $2c		;bit
;---------------
key_f5                                  ;accessed parameter
		ldx #$20		;" "
		.byte $2c		;bit
;---------------
key_f6                                  ;accessed parameter
		ldx #$30		;"0"
		lda fkey_strings,x
		beq l8805_rts
		sta 198
		ldy #0
l87f9
		inx
		lda fkey_strings,x
		sta 631,y
		iny
		cpy 198
		blt l87f9
l8805_rts
		rts
					;8806
l8806_rts
		rts
					;8807
;---------------
l8807
		ldx #size(key_commands)
l8809
		dex
		bmi l8806_rts
		cmp key_commands,x
		bne l8809
		jsr l8817
		jmp l8737
					;8817
;---------------
l8817
		txa
		asl
		tax
		lda key_tabl+1,x
		pha			;stackjump attempt
		lda key_tabl,x
		pha			;stackjump attempt
		rts
					;8823
;---------------
key_home
		jsr pharse_line_if_any
		lda #0
		sta cursor_y_position
		sta cursor_x_position
		rts
;---------------
key_up
		jsr pharse_line_if_any
;---------------
l8826
		lda cursor_y_position
		cmp #5
		bge l8869
		ldy screen_line_start
		tya
		ora screen_line_start+1
		beq l8864
		dec screen_line_start
		tya
		bne +
		dec screen_line_start+1
+		lda #4
		jsr l884e
		lda #$d8		;216
		jsr l884e
		lda #0
		jmp print_this_line_on_screen
					;884e
;---------------
l884e
		ldx #0
		stx p3d
		sta p3d+1
		ldx #$70		;112
		stx m800f
		clc
		adc #3
		sta m8010
		lda #$28		;"("
		jmp l9255
					;8864
l8864
		lda cursor_y_position
		beq +
l8869
		dec cursor_y_position
+		rts
					;886d
;---------------
key_down
		jsr pharse_line_if_any
;---------------
l8870
		lda cursor_y_position
		cmp #$12		;18
		blt l88aa
		lda #1
		jsr l8a27
		bcs l88a3
		lda #4
		jsr l888d
		lda #$d8		;216
		jsr l888d
		lda #$16		;22
		jmp print_this_line_on_screen
					;888d
;---------------
l888d
		ldx #$28		;"("
		stx p3d
		sta p3d+1
		ldx #$98		;152
		stx m800f
		clc
		adc #3
		sta m8010
		lda #$28		;"("
		jmp l91f7
					;88a3
l88a3
		lda cursor_y_position
		cmp #$16		;22
		bge l88ad_rts
l88aa
		inc cursor_y_position
l88ad_rts
		rts
					;88ae
;---------------
key_left
		dec cursor_x_position
		bpl l88ad_rts
		jsr pharse_line_if_any
		lda #$27		;"'"
		sta cursor_x_position
		jmp key_up
					;88be
;---------------
key_right
		lda cursor_x_position
		cmp #$27		;"'"
		lda #0
		bcc l88d0
		bcs l88dd
l88c9
		lda cursor_x_position
		cmp #$27		;"'"
		bge key_shreturn
l88d0
		inc cursor_x_position
		rts
					;88d4
;---------------
key_shreturn
		lda cursor_tab
l88dd
		sta cursor_x_position
		jmp key_down
					;88e3
;---------------
key_delete
		lda cursor_x_position
		beq l88fe
		jsr l87a4
		ldx cursor_x_position
l88ee
		lda line_buffer_200,x
		sta line_buffer_200-1,x
		inx
		cpx #$28		;"("
		blt l88ee
		lda #$20		;" "
		sta line_buffer_200+39
l88fe
		jmp key_left
					;8901
;---------------
l8901
		jsr l8cf4
		jsr l892a
		inc screen_line_start
		bne +
		inc screen_line_start+1
+		rts
					;8910
;---------------
key_return
		lda cursor_tab
		bit mcb0f
		bpl l88dd
		sta cursor_x_position
		jsr l87a4
;---------------
l891e
		jsr pharse_line_if_any
		jsr l892a
		jsr l8870
                jmp redraw_all_lines_on_screen
					;892a
;---------------
l892a
		lda #$fc		;252
		cmp memory_lines
		lda #$13		;19
		sbc memory_lines+1
		blt l89a4
		lda #1
		ldx #0
		jsr l9be3
		clc
		lda current_line
		adc #<(lines_memory_cc00+1)
		sta p3d
		sta m8011
		lda current_line+1
		adc #>(lines_memory_cc00+1)		;204
		sta p3d+1
		sta m8012
		clc
		lda memory_lines
		adc #<(lines_memory_cc00+1)
		sta m800f
		lda memory_lines+1
		adc #>(lines_memory_cc00+1)		;204
		sta m8010
		lda $1
		pha
		sei
		lda #$34
		sta $1
		lda current_line
		cmp memory_lines
		bne l897b
		lda current_line+1
		cmp memory_lines+1
		beq l8980
l897b
		lda #1
		jsr l9255
l8980
		lda m8011
		sta p3d
		lda m8012
		sta p3d+1
		ldy #0
		tya
		sta (p3d),y
		pla
		sta $1
		cli
		inc memory_lines
		bne +
		inc memory_lines+1
+		inc current_line
		bne +
		inc current_line+1
+		rts
					;89a4
l89a4
		ldx #1
		jmp l8ee4
					;89a9
;---------------
key_insert
		lda insert_char_mode
		eor #%11111111
		sta insert_char_mode
		rts
					;89b2
;---------------
l89b2
		jsr pharse_line_if_any
		clc
		lda screen_line_start
		adc cursor_y_position
		tax
		lda screen_line_start+1
		adc #0
		tay
		rts
					;89c4
;---------------
key_f1
		lda #20
		.byte $2c		;bit
;---------------
arrow_up
		lda #200
		sta m8024
		jsr l89b2
		sec
		txa
		sbc m8024
		sta destination_line
		tya
		sbc #0
		sta destination_line+1
		bcs l89e7
l89df
		lda #0
		sta destination_line
		sta destination_line+1
l89e7
		jmp l9591
					;89ea
;---------------
key_f2
		jsr pharse_line_if_any
		jmp l89df
					;89f0
;---------------
key_f7
		lda #20
		.byte $2c		;bit
;---------------
arrow_down
		lda #200
		sta m8024
		jsr l89b2
		txa
		clc
		adc m8024
		sta destination_line
		tya
		adc #0
		sta destination_line+1
		lda destination_line
		cmp memory_lines
		lda destination_line+1
		sbc memory_lines+1
		blt l89e7
		bge l8a1c
;---------------
key_f8
		jsr pharse_line_if_any
l8a1c
		jsr l8a4a
		lda #$16		;22
		sta cursor_y_position
                jmp redraw_all_lines_on_screen
					;8a27
;---------------
l8a27
		clc
		adc screen_line_start
		sta screen_line_start
		bcc +
		inc screen_line_start+1
+		clc
		lda screen_line_start
		adc #$15		;21
		pha
		lda screen_line_start+1
		adc #0
		tax
		pla
		cmp memory_lines
		txa
		sbc memory_lines+1
		blt l8a5c_rts
;---------------
l8a4a
		sec
		lda memory_lines
		sbc #$16		;22
		sta screen_line_start
		lda memory_lines+1
		sbc #0
		sta screen_line_start+1
		sec
l8a5c_rts
		rts
					;8a5d
arrow_commands
		.text $94,"A",$5f,"12Z",$14,"CEW345MGFHKBSL*@DNQ78O",$91,$11,"RTY:;",$0d,"^",$5C,"=/U",$85,"I",$c4,' "!',$d2
arrow_tabl
		.rta arrow_insert
		.rta arrow_a
		.rta arrow_arrow
		.rta arrow_1
		.rta arrow_2
		.rta arrow_z
		.rta arrow_del
		.rta arrow_c
		.rta arrow_e
		.rta arrow_w
		.rta arrow_3
		.rta arrow_4
		.rta arrow_5
		.rta arrow_m
		.rta arrow_g
		.rta arrow_f
		.rta arrow_h
		.rta arrow_k
		.rta arrow_b
		.rta arrow_s
		.rta arrow_l
		.rta arrow_star
		.rta arrow_at
		.rta arrow_d
		.rta arrow_n
		.rta arrow_q
		.rta arrow_7
		.rta arrow_8
		.rta arrow_o
		.rta arrow_up
		.rta arrow_down
		.rta arrow_r
		.rta arrow_t
		.rta arrow_y
		.rta arrow_colon
		.rta arrow_semicolon
		.rta arrow_return
		.rta arrow_uparrow
		.rta arrow_font
		.rta arrow_equ
		.rta arrow_per
		.rta arrow_u
		.rta arrow_f1
		.rta arrow_i
		.rta arrow_shift_d
		.rta arrow_space
                .rta arrow_shift2
                .rta arrow_excl
                .rta arrow_shift_r
;---------------
arrow_7
		lda cursor_x_position
		sta cursor_tab
l8af4_rts
		rts
					;8af5
;---------------
arrow_8
		jsr pharse_line_if_any
		lda cursor_x_position
		cmp #$0c		;12
		bge l8af4_rts
		sta tab_position
                jmp redraw_all_lines_on_screen
					;8b05
;---------------
arrow_3
		jsr pharse_line_if_any
		lda #0
l8b0a
		sta mcb23
		lda #0
		sta mcb24
l8b12
		jsr reset_vectors_install_334
		jmp lb47c
					;8b18
;---------------
arrow_4
		jsr pharse_line_if_any
		ldx #$16		;22
		jsr print_message
		lda #$0c		;12
		ldy #$23		;"#"
		jsr input
		lda m10d
		cmp #"?"
		beq l8b35
		cmp #"*"
		bne l8b4b
		ldx #3
		.byte $2c		;bit
l8b35
		ldx #4
		lda #1
		ldy #7
		jsr $ffba
		lda #0
		jsr $ffbd
		jsr $ffc0
l8b46
		lda #$ff		;255
		jmp l8b0a
					;8b4b
l8b4b
		lda #$0c		;12
		jsr open_seq_write
		jmp l8b46
					;8b53
;---------------
arrow_c
		jsr pharse_line_if_any
		ldx #3
		jsr print_message
		lda #$12		;18
		jsr l9316
		cmp #$59		;"Y"
		bne l8b67_rts
		jmp l83a7
					;8b67
l8b67_rts
		rts
					;8b68
;---------------
l8b68
		cmp #$5f		;95
		bne l8b67_rts
		jmp l8bec
					;8b6f
					;8b82
;---------------
l8ba0
		lda 198
		ora $90
		bne l8baa
		jsr $ffcf               ;cint
		rts
					;8baa
l8baa
		lda #0
		sta 198
		jmp l81b8
					;8bb1
l8bec
		cli
-		jsr $ffe4
		beq -
		ldx #$31
l8bf4
		dex
		bmi l8bff
		cmp arrow_commands,x
		bne l8bf4
		jsr l8c02
l8bff
		jmp l8737
					;8c02
;---------------
l8c02
		txa
		asl
		tax
		lda arrow_tabl+1,x
		pha			;stackjump attempt
		lda arrow_tabl,x
		pha			;stackjump attempt
		rts
					;8c0e
;---------------
arrow_insert
		lda mcb0f
		eor #%11111111
		sta mcb0f
		rts
					;8c17
;---------------
;all input

arrow_a
		lda #$ff		;255
		sta raw_mode_flag
		rts
					;8c1d
;---------------
;put arrow

arrow_arrow
		lda #$5f		;95
		sta m8018
		jmp l8779
					;8c25
;---------------
l8c25
		jsr l87a4
		ldy #$27		;"'"
		lda #$20		;" "
l8c2c
		sta line_buffer_200,y
		dey
		bpl l8c2c
		rts
					;8c33
;---------------
arrow_del
		jsr l8c25
		jsr pharse_line_if_any
		lda current_line+1
		cmp memory_lines+1
		bne l8c5e
		lda current_line
		cmp memory_lines
		bne l8c4f
		jsr l9642
		jmp l967c
					;8c4f
l8c4f
		lda memory_lines+1
		bne l8c5e
		lda memory_lines
		cmp #$17		;23
		bge l8c5e
		jmp l8cc9
					;8c5e
l8c5e
		lda #$ff		;255
		tax
		jsr l9be3
		clc
		lda current_line
		adc #<(lines_memory_cc00+1)
		sta p3d
		lda current_line+1
		adc #>(lines_memory_cc00+1)
		sta p3d+1
		clc
		lda memory_lines
		adc #<(lines_memory_cc00+1)
		sta m800f
		lda memory_lines+1
		adc #>(lines_memory_cc00+1)
		sta m8010
		lda $1
		pha
		sei
		lda #$34
		sta $1
		lda #1
		jsr l91f7
		jsr get_current_line_flags
		and #%00111111
		sta m8010
		sec
		lda source_p
		sbc m8010
		sta source_p
		bcs +
		dec source_p+1
+		pla
		sta $1
		cli
		lda memory_lines
		bne +
		dec memory_lines+1
+		dec memory_lines
		lda screen_line_start
		pha
		lda #0
		jsr l8a27
		pla
		cmp screen_line_start
		beq l8cc9
		inc cursor_y_position
l8cc9
		jmp redraw_all_lines_on_screen
					;8ccc
l8ccc_rts
		rts
					;8ccd
;---------------
pharse_line_if_any
		lda line_buffer_filled
		beq l8ccc_rts
		lda current_line
		sta m802b
		lda current_line+1
		sta m802c
		lda $1
		pha
		lda #$36
		sta $1
		jsr l8cf4
		pla
		sta $1
		lda cursor_y_position
		jsr print_this_line_on_screen
		jmp l8f06
					;8cf4
;---------------
l8cf4
		lda #0
		sta raw_mode_flag
		lda src_current_line_flags
		and #%00111111
		sta m801f
		jsr l8e45
		lda current_line
		sta m8011
		lda current_line+1
		sta m8012
		lda source_p
		sta m8013
		lda source_p+1
		sta m8014
		lda src_current_line_flags
		and #%00111111
		sta m8021
		sec
		lda m801f
		sbc m8021
		sta m801f
		bne +
		jmp l8d9a
+					;8d33
		bcs l8d6d
		jsr l8ecd
		lda m801f
		eor #%11111111
		clc
		adc #1
		sta line_color
		sec
		lda mcb14
		sbc line_color
		sta mcb14
		bcs +
		dec mcb15
+		lda line_color
		jsr l91f7
		sec
		lda m8013
		sbc line_color
		sta source_p
		lda m8014
		sbc #0
		sta source_p+1
		jmp l8d9a
					;8d6d
l8d6d
		jsr l8ecd
		lda m801f
		sta line_color
		clc
		adc mcb14
		sta mcb14
		bcc +
		inc mcb15
+		lda line_color
		jsr l9255
		clc
		lda m8013
		adc line_color
		sta source_p
		lda m8014
		adc #0
		sta source_p+1
l8d9a
		lda m8011
		sta current_line
		sta p39
		lda m8012
		sta current_line+1
		clc
		adc #>lines_memory_cc00
		sta p39+1
		lda $1
		pha
		sei
		lda #$34
		sta $1
		ldy #0
		lda src_current_line_flags
		sta (p39),y
		pla
		sta $1
		cli
		lda source_p
		sta p39
		lda source_p+1
		sta p39+1
		lda src_current_line_flags
		and #%00111111
		tax
		ldy #0
l8dd2
		dex
		bmi l8ddd
		lda line_buffer_200+41,y
		sta (p39),y
		iny
		bne l8dd2
l8ddd
		lda #0
		sta line_buffer_filled
		lda mcb05
		cmp #5
		bne l8df0
		lda mcb04
		cmp #$e0		;224
		bge l8e02
l8df0
		lda mcb19
		cmp #$f0		;240
		lda mcb1a
		sbc #$fc		;252
		bge +
		rts
+					;8dfd
		ldx #$1d		;29
		jmp l8ee4
					;8e02
l8e02
		ldx #$1c		;28
		jmp l8ee4
					;8e07
;---------------
l8e07
		lda #<memory_bottom_default
		ldy #>memory_bottom_default
		sta source_p
		sty source_p+1
		lda #$ff		;255
		sta current_line
		sta current_line+1
		sei
		ldy #$34
		sty $1
                ldy #0
		jsr next_line
		lda #$36
		sta $1
		cli
		lda memory_lines
		sta destination_line
		lda memory_lines+1
		sta destination_line+1
		jsr jump_on_line
		lda source_p
		sta mcb14
		lda source_p+1
		sta mcb15
		rts
					;8e45
;---------------
l8e45
		jsr la452
		sta m800b
		cli
		rts
					;8ecd
;---------------
l8ecd
		lda source_p
		sta m800f
		lda source_p+1
		sta m8010
		lda mcb14
		sta p3d
		lda mcb15
		sta p3d+1
		rts
					;8ee4
l8ee4
		jsr print_message
l8ee7
		jsr $ffcc
		lda #1
		jsr $ffc3
		ldx #0
		stx 198
                jsr redraw_all_lines_on_screen
		lda #0
		sta line_buffer_filled
		jmp l8737
					;8efe
;---------------
print_message
		txa
		clc
		adc #13
		tax
		jmp +
					;8f06
l8f06
		ldx m800b
+
		lda #<error_messages
		ldy #>error_messages
		sta p39
		sty p39+1
l8f11
		dex
		bmi +
		ldy #$ff		;255
-		iny
		lda (p39),y
		bpl -
		sec
		tya
		adc p39
		sta p39
		bcc l8f11
		inc p39+1
		bne l8f11
+
		jsr l86b0
;---------------
l8f2a
		ldx currect_color_set
		lda message_colors,x
		sta line_color
		ldx #$17		;23
		jmp l85c9
					;8f38
error_messages
		.shift " "
		.shift "lABEL TOO LONG"
		.shift "iLLEGAL MNEMONIC"
		.shift "uNKNOWN PSEUDO-OP"
		.shift "qUOTATION MARK MISSING"
		.shift "iLLEGAL OPERATOR"
		.shift "mISSING OPERAND"
		.shift "cLOSE BRACKETS"
		.shift "iLLEGAL QUANTITY"
		.shift "cOMMA EXPECTED"
		.shift "iLLEGAL ADDRESS MODE"
		.shift "lABEL MISSING"
		.shift "nO LABEL!"
		.shift "oUT OF MEMORY"
		.shift "tOO MANY LINES"
		.shift "tURBO aSS mAC++ ide64 BY sOCI/sINGULAR"
		.shift "cOLD START (Y/N)? "
		.shift "eNTER FILE :"
		.shift "sTOPPED"
		.shift "wRITE FILE:"
		.shift "sET MARK (0-9,S,E) #"
		.shift "gO TO MARK #"
		.shift "mARK NOT SET"
		.shift "fIND :"
		.shift "dISK STATUS:"
		.shift "oBJECT-FILE :"
		.shift "kEY (","f","3-6) :"
		.shift "sEQUENCE ?"
		.shift "bLOCK UNDEFINED"
		.shift "bLOCK COMMAND: WRITE,KILL,COPY ?"
		.shift "sAVE FILE :"
		.shift "lOAD FILE :"
		.shift "dISK COMMAND :"
		.shift "gO NUMBER #"
		.shift "kILL BLOCK Y/N ?"
		.shift "pRINT-FILE :"
		.shift "rEPLACE :"
		.shift "bY :"
		.shift "kILL MARK #"
		.shift "lIST LABELS :"
		.shift "f-KEY RESET"
		.shift "tOO MANY LABELS:TRY WRITE AND REENTER!"
		.shift "lABELNAMES OVERFLOW:TRY WRITE AND REENTER!"
		.shift "dEVICE NOT PRESENT"
		.shift "fIND SUBROUTINE :"
		.shift "eNTER LABEL!"
		.shift "dISK DRIVE :"
		.shift "kEY REPEAT ON"

					;91f7
;---------------
l91f7
		ldy #0
;---------------
l91f9
		sta m800d
		sty m800e
		sec
		lda m800f
		sbc p3d
		eor #%11111111
		tay
		iny
		sty p39
		lda m8010
		sbc p3d+1
		sta p39+1
		lda p3d
		sbc p39
		sta pmemory_put
		lda p3d+1
		sbc #0
		sta pmemory_put+1
		sec
		lda p3d
		sbc m800d
		sta p3d
		lda p3d+1
		sbc m800e
		sta p3d+1
		sec
		lda p3d
		sbc p39
		sta p3f
		lda p3d+1
		sbc #0
		sta p3f+1
		ldx p39+1
		inx
		ldy p39
		tya
		bne l924a
		dex
		bne l924a
		rts
					;9246
l9246
		inc pmemory_put+1
		inc p3f+1
l924a
		lda (pmemory_put),y
		sta (p3f),y
		iny
		bne l924a
		dex
		bne l9246
		rts
					;9255
;---------------
l9255
		ldy #0
;---------------
l9257
		sta m800d
		sty m800e
		sec
		lda m800f
		sbc p3d
		sta p39
		lda m8010
		sbc p3d+1
		sta p39+1
		clc
		adc p3d+1
		sta pmemory_put+1
		lda p3d
		sta pmemory_put
		adc m800d
		sta p3f
		lda p3d+1
		adc m800e
		adc p39+1
		sta p3f+1
		ldx p39+1
		inx
		ldy p39
		bne l9295
		beq l929c
l928c
		dey
		dec pmemory_put+1
		dec p3f+1
l9291
		lda (pmemory_put),y
		sta (p3f),y
l9295
		dey
		bne l9291
		lda (pmemory_put),y
		sta (p3f),y
l929c
		dex
		bne l928c
		rts
					;92a0
;---------------
l92a0
		ldx 198
		beq l92b7_rts
		lda #0
		sta 198
		lda 631-1,x
		cmp #3
		bne l92b7_rts
		jsr l9591
		ldx #5
		jmp l8ee4
					;92b7
l92b7_rts
		rts
					;92b8
;---------------
arrow_e
		jsr pharse_line_if_any
		ldx #4
		jsr print_message
		lda #$0c		;12
		ldy #$21		;"!"
		jsr input
		lda #$0c		;12
		jsr open_seq_read
		ldx #1
		jsr $ffc6
		lda #0
		sta cursor_x_position
l92d6
		ldx $90
		bne l92fd
		jsr l87a4
		jsr $ffe4
		cmp #$0d		;13
		bne l9306
		jsr l8901
		lda line_color
		pha
		jsr l85d0
		pla
		sta line_color
		jsr l92a0
		lda #0
		sta cursor_x_position
		jmp l92d6
					;92fd
l92fd
		jsr arrow_at
		jsr l963c
		jmp l8ee7
					;9306
l9306
		ldx $90
		bne l92fd
		ldx cursor_x_position
		sta line_buffer_200,x
		inc cursor_x_position
		jmp l92d6
					;9316
;---------------
l9316
		ldx #$ff		;255
		.byte $2c		;bit
;---------------
input
		ldx #0
		stx m8017
		ldx #0
		stx raw_mode_flag
		sta m8011
		sty m8012
		ldy cursor_x_position
		sty m8010
		sta cursor_x_position
l9332
		jsr l8f2a
		ldx #$27		;"'"
l9337
		lda t101,x
		sta line_buffer_200,x
		dex
		bpl l9337
		jsr l85d0
		ldx #$27		;"'"
l9345
		lda line_buffer_200,x
		sta t101,x
		dex
		bpl l9345
		ldx #$17		;23
		jsr l86ef
		sta m8018
		bit m8017
		bmi l9389
		bit raw_mode_flag
		bpl +
		jmp l9410
+					;9363
		cmp #$0d		;13
		bne l9397
		lda #$20		;" "
		ldy m8011
l936c
		cmp t101,y
		bne l937d
		iny
		cpy m8012
		blt l936c
		jsr l937d
		jmp l8737
					;937d
;---------------
l937d
		ldx m8010
		stx cursor_x_position
		ldx #0
		stx raw_mode_flag
		rts
					;9389
l9389
		ldx cursor_x_position
		sta t101,x
		pha
		jsr l8f2a
		pla
		jmp l937d
					;9397
l9397
		cmp #$1d		;29
		bne l93af
l939b
		inc cursor_x_position
		lda cursor_x_position
		cmp m8012
		blt l9332
		lda m8011
		sta cursor_x_position
		jmp l9332
					;93af
l93af
		cmp #$9d		;157
		bne l93c8
l93b3
		dec cursor_x_position
		lda cursor_x_position
		cmp m8011
		bge l93f3
l93be
		ldx m8012
		dex
		stx cursor_x_position
		jmp l9332
					;93c8
l93c8
		cmp #$14		;20
		bne l93ec
		ldx cursor_x_position
		cpx m8011
		beq l93be
		dex
l93d5
		inx
		lda t101,x
		sta t100,x
		cpx m8012
		blt l93d5
		lda #$20		;" "
		ldx m8012
		sta t101,x
		jmp l93b3
					;93ec
l93ec
		cmp #$94		;148
		bne l93f6
		jsr key_insert
l93f3
		jmp l9332
					;93f6
l93f6
		cmp #$5f		;95
		bne l941b
-		jsr $ffe4
		beq -
		cmp #"A"
		bne +
		lda #$ff		;255
		sta raw_mode_flag
		bne l93f3
+
		cmp #$5f		;95
		bne l93f3
		geq l941b

l9410
		cmp #$5f		;95
		bne l941b
		lda #0
		sta raw_mode_flag
		beq l93f3
l941b
		bit insert_char_mode
		bpl l9437
		ldx m8012
		dex
		lda t101,x
		cmp #$20		;" "
		bne l93f3
l942b
		lda t100,x
		sta t101,x
		dex
		cpx cursor_x_position
		bge l942b
l9437
		lda m8018
		ldx cursor_x_position
		sta t101,x
		jmp l939b
					;9443
l9443
		ldx #4
		lda #1
		ldy #7
		jsr $ffba
		lda #0
		sta $b7
		jsr $ffc0
		ldx #1
		jsr $ffc9
		lda #$0d		;13
		jsr $ffd2
		jmp l9498
					;9461
;---------------
arrow_w
		jsr pharse_line_if_any
		jsr l963c
		lda #0
		sta destination_line
		sta destination_line+1
		lda memory_lines
		sta m801a
		lda memory_lines+1
		sta m801b
l947b
		ldx #6
		jsr print_message
		lda #$0b		;11
		ldy #$21		;"!"
		jsr input
		lda m10c
		cmp #$3f		;"?"
		beq l9443
		lda #$0b		;11
		jsr open_seq_write
		ldx #1
		jsr $ffc9
l9498
		jsr jump_on_line
		jsr l8561
		lda #$20		;" "
		ldy #$29		;")"
l94a2
		dey
		beq l94bb
		cmp line_buffer_200-1,y
		beq l94a2
		sty m8014
		ldy #0
l94af
		lda line_buffer_200,y
		jsr $ffd2
		iny
		cpy m8014
		bne l94af
l94bb
		lda #$0d		;13
		jsr $ffd2
		lda $90
		bne l94dd
		lda current_line
		cmp m801a
		lda current_line+1
		sbc m801b
		bge l94dd
		inc destination_line
		bne +
		inc destination_line+1
+		jmp l9498
					;94dd
l94dd
		lda #$0d		;13
		jsr $ffd2
		jsr $ffcc
		lda #1
		jsr $ffc3
		jsr arrow_at
		jmp l8737
					;94f0
;---------------
arrow_semicolon
		jsr pharse_line_if_any
		ldx #$19		;25
		jsr print_message
		lda #$0b		;11
		jsr l9316
		jsr which_mark
		lda #$7f		;127
		sta mark_lines+1,y
                jmp redraw_all_lines_on_screen
					;9508
;---------------
arrow_m
		jsr pharse_line_if_any
		ldx #7
		jsr print_message
		lda #$14		;20
		jsr l9316
		jsr which_mark
		bcc +
		jmp l8737
+					;9523
		lda screen_line_start
		adc cursor_y_position
		sta mark_lines,y
		lda screen_line_start+1
		adc #0
		sta mark_lines+1,y
                jmp redraw_all_lines_on_screen
					;9537
;---------------
which_mark
		cmp #"S"
		beq l9549
		cmp #"E"
		beq l954c
		sec
		sbc #"0"
		cmp #10
		bge l954f_rts
		asl
		tay
		.byte $2c		;bit
l9549
		ldy #10*2
		.byte $2c		;bit
l954c
		ldy #11*2
		clc
l954f_rts
		rts
					;9550
;---------------
arrow_shift_d
		ldx #$21		;"+"
		jsr print_message
drivenum_at
		ldx #12
		inx
		cpx #20
		bne +
		ldx #8
+		txa
		sta drivenum_at+1
		cmp #$0a		;10
		blt la290
		clc
		adc #$26		;38
		sta $7a5
		lda #$31		;"1"
la290
		ora #%00110000
		sta $7a4
		rts
;---------------
arrow_g
		jsr pharse_line_if_any
		ldx #8
		jsr print_message
		lda #$0c		;12
		jsr l9316
		cmp #$5f		;95
		beq l9585
		jsr which_mark
		bcs l954f_rts
		lda mark_lines+1,y
		sta destination_line+1
		lda mark_lines,y
		sta destination_line
		lda memory_lines
		cmp destination_line
		lda memory_lines+1
		sbc destination_line+1
		bge l9591
		ldx #9
		jmp l8ee4
					;9585
l9585
		lda m802b
		sta destination_line
		lda m802c
		sta destination_line+1
;---------------
l9591
		lda #$0c		;12
		sta cursor_y_position
		sec
		lda destination_line
		sbc cursor_y_position
		sta screen_line_start
		lda destination_line+1
		sbc #0
		sta screen_line_start+1
		bcs l95bb
		lda #0
		sta screen_line_start
		sta screen_line_start+1
		lda destination_line
		sta cursor_y_position
                jmp redraw_all_lines_on_screen
					;95bb
l95bb
		lda #0
		jsr l8a27
		sec
		lda destination_line
		sbc screen_line_start
		sta cursor_y_position
                jmp redraw_all_lines_on_screen
					;95cd
;---------------
arrow_h
		jsr pharse_line_if_any
		jmp l95fe
					;95d3
;---------------
arrow_f
		jsr pharse_line_if_any
		ldx #$0a		;10
		jsr print_message
		lda #6
		ldy #$1e		;30
		jsr input
		ldy #$20		;" "
		lda #" "
l95e6
		dey
		cmp t100,y
		beq l95e6
		tya
		sec
		sbc #6
		sta mcb17
l95f3
		lda t101,y
		sta tcb3a,y
		dey
		cpy #5
		bne l95f3
l95fe
		jsr find
l9601
		jsr l9591
		lda #0
		sta line_buffer_filled
		jmp l8737
					;960c
;---------------
arrow_at
		ldx #$0b		;11
		jsr print_message
                jsr check_device_present
                lda #0
                sta $b7
arrow_at_in	lda #15
		ldx $ba
                tay
		jsr $ffba
		jsr $ffc0
                ldx #15
                jsr $ffc6
		lda #0
		sta m800d
l9624
		jsr $ffcf               ;cint
		cmp #$0d		;13
		beq l9636
		ldx m800d
		sta t101,x
		inc m800d
		bne l9624
l9636
		jsr l8f2a
                jsr $ffcc
                lda #15
		jmp $ffc3
					;963c
;---------------
l963c
		jsr l9642
		bcs l963c
		rts
					;9642
;---------------
l9642
		lda memory_lines+1
		bne l964e
		lda memory_lines
		cmp #$17		;23
		blt l967c
l964e
		lda memory_lines
		sta pmemory_put
		lda memory_lines+1
		clc
		adc #>lines_memory_cc00
		sta pmemory_put+1
		lda $1
		pha
		sei
		lda #$34
		sta $1
		ldy #0
		lda (pmemory_put),y
		tay
		pla
		sta $1
		cli
		tya
		bne l967c
		lda memory_lines
		bne +
		dec memory_lines+1
+		dec memory_lines
		sec
		rts
					;967c
l967c
		lda #0
		jsr l8a27
                jsr redraw_all_lines_on_screen
		clc
		rts
					;9686
;---------------
arrow_5
		jsr pharse_line_if_any
		ldx #$0c		;12
		jsr print_message
		lda #$0d		;13
		ldy #$1e		;30
		jsr input
		lda #$0d		;13
                ldx #17
		jsr open_prg_write
		lda #0
		sta mcb23
		lda #$ff		;255
		sta mcb24
		jmp l8b12
					;96a7
t96a7
		.text ",SEQ,TSM,PRG"
;---------------
open_seq_read
		ldx #0
		.byte $2c		;bit
;---------------
open_seq_write
		ldx #1
		.byte $2c		;bit
;---------------
open_asm_write
		ldx #9
		.byte $2c		;bit
;---------------
open_asm_read
		ldx #8
open_prg_write
		pha
		ldy #40+1
-		dey
		lda t100,y
		cmp #" "
		beq -

                txa
                lsr
                tax
                php
-		lda t96a7,x
		sta t101,y
		inx
		iny
                txa
                and #3
		bne -

                sty m8014
		jsr $ffe7
                jsr check_device_present
		lda #1
		ldx $ba
                tay
                plp
		bcs +
                dey
+		jsr $ffba
		pla
                pha
		clc
		adc #1
		tax
		ldy #1
		bcc +
		iny
+		pla
		eor #$ff
                sec
                adc m8014
		jsr $ffbd
		jmp $ffc0
					;9712
;---------------
arrow_k
		jsr pharse_line_if_any
		ldx #$0d		;13
		jsr print_message
		lda #$0d		;13
		jsr l9316
		ldy #0
		cmp #$86		;134
		beq l9734
		iny
		cmp #$8a		;138
		beq l9734
		iny
		cmp #$87		;135
		beq l9734
		iny
		cmp #$8b		;139
		bne l9791
l9734
		tya
		asl
		asl
		asl
		asl
		sta m800b
		ldx #$0e		;14
		jsr print_message
		ldx m800b
		lda fkey_strings,x
		beq l9764
		tay
		clc
		adc m800b
		tax
l974f
		lda fkey_strings,x
		sta t10a,y
		dex
		dey
		bne l974f
		ldx m800b
		lda #0
		sta fkey_strings,x
		jsr l8f2a
l9764
		lda #$0a		;10
		ldy #$19		;25
		jsr input
		ldy #$27		;"'"
		lda #$20		;" "
l976f
		dey
		cmp t100,y
		beq l976f
		sec
		tya
		sbc #$0a		;10
		ldx m800b
		sta m800b
		sta fkey_strings,x
		ldy #$0a		;10
l9784
		inx
		lda t101,y
		sta fkey_strings,x
		iny
		dec m800b
		bne l9784
l9791
		jmp l8737
					;9794
l9794
		lda mcb3c
		sta m8024
		lda mcb3d
		sta mcb23
l97a0
		lda m8024
		sta destination_line
		lda mcb23
		sta destination_line+1
		jsr jump_on_line
		jsr l8561
		clc
		lda screen_line_start
		adc cursor_y_position
		sta destination_line
		lda screen_line_start+1
		adc #0
		sta destination_line+1
		lda destination_line
		cmp m8024
		lda destination_line+1
		sbc mcb23
		bge +
		jsr l97fd
+		jsr jump_on_line
		lda #$ff		;255
		sta line_buffer_filled
		jsr l8901
		jsr l85d0
		jsr l92a0
		jsr l97fd
		lda mcb3e
		cmp m8024
		lda mcb3f
		sbc mcb23
		bge l97a0
                jsr redraw_all_lines_on_screen
		jmp l8737
					;97fd
;---------------
l97fd
		inc m8024
		bne +
		inc mcb23
+		rts
					;9806
l9806
		ldx #$0f		;15
		jmp l8ee4
					;980b
;---------------
arrow_b
		jsr pharse_line_if_any
		ldx #2
l9810
		lda memory_lines
		cmp mcb3c,x
		lda memory_lines+1
		sbc mcb3d,x
		blt l9806
		dex
		dex
		beq l9810
		lda mcb3e
		cmp mcb3c
		lda mcb3f
		sbc mcb3d
		blt l9806
		ldx #$10		;16
		jsr print_message
		lda #$20		;" "
		jsr l9316
		cmp #"W"
		beq write_block
		cmp #"K"
		beq kill_block
		cmp #"C"
		bne l9849
		jmp l9794
					;9849
l9849
		jmp l8737
					;984c
write_block
		lda mcb3c
		sta destination_line
		lda mcb3d
		sta destination_line+1
		lda mcb3e
		sta m801a
		lda mcb3f
		sta m801b
		jmp l947b
					;9867
kill_block
		ldx #$15		;21
		jsr print_message
		lda #$10		;16
		jsr l9316
		cmp #"Y"
		bne l9849
		sec
		lda mcb3e
		sta destination_line
		lda mcb3f
		sta destination_line+1
		jsr jump_on_line
		sec
		lda source_p
		sta m800f
		lda source_p+1
		sta m8010
		lda mcb3c
		sbc #1
		sta destination_line
		lda mcb3d
		sbc #0
		sta destination_line+1
		jsr jump_on_line
		sec
		lda source_p
		sbc m800f
		tax
		lda source_p+1
		sbc m8010
		tay
		sec
		lda mcb14
		sbc #$14		;20
		sta p3d
		lda mcb15
		sbc #0
		sta p3d+1
		txa
		jsr l9257
		lda #0
		sta destination_line
		sta destination_line+1
		jsr jump_on_line
		clc
		lda mcb3e
		adc #<(lines_memory_cc00+1)
		sta p3d
		lda mcb3f
		adc #>(lines_memory_cc00+1)
		sta p3d+1
		clc
		lda memory_lines
		adc #<(lines_memory_cc00+3)
		sta m800f
		lda memory_lines+1
		adc #>(lines_memory_cc00+3)
		sta m8010
		sec
		lda mcb3e
		sbc mcb3c
		tax
		lda mcb3f
		sbc mcb3d
		tay
		clc
		txa
		adc #1
		tax
		tya
		adc #0
		tay
		sei
		lda $1
		pha
		sei
		lda #$34
		sta $1
		txa
		jsr l91f9
		pla
		sta $1
		cli
		lda mcb3c
		sta destination_line
		lda mcb3d
		sta destination_line+1
		jsr jump_on_line
		clc
		lda mcb3c
		sbc mcb3e
		tay
		lda mcb3d
		sbc mcb3f
		tax
		clc
		tya
		adc memory_lines
		sta memory_lines
		txa
		adc memory_lines+1
		sta memory_lines+1
		tya
		jsr l9be3
		jsr l995e
		lda #0
		jsr l8a27
                jsr redraw_all_lines_on_screen
		jsr l8e07
		jmp l8737
					;995d
l995d_rts
		rts
					;995e
;---------------
l995e
		lda memory_lines+1
		bne l995d_rts
		lda memory_lines
		cmp #$16		;22
		bge l995d_rts
		inc memory_lines
		ldy memory_lines
		lda $1
		pha
		sei
		lda #$34
		sta $1
                lda #0
		sta lines_memory_cc00,y
		pla
		sta $1
		cli
		jmp l995e
					;9982
;---------------
arrow_s
		jsr pharse_line_if_any
		ldx #$11		;17
		jsr print_message
		lda #$0b		;11
		ldy #$1f		;31
		jsr input
		lda #$0b		;11
		jsr open_asm_write
		ldx #1
		jsr $ffc9
		lda #0
		sta m8021
l99a6
		ldy m8021
		lda tab_position,y
		jsr l9a56
		inc m8021
		bne l99a6
		lda mcb14
		sta p39
		lda mcb15
		sta p39+1

                jsr check_ide64
		bcc l99be
                lda #<(signature+5)
                sbc p39
                tax
                lda #>(signature+5)
                sbc p39+1
                tay
		lda #p39
		jsr $def1
                bcc ok_s1

                ldx #1
                jsr $ffc9
l99be
		ldy #0
		lda (p39),y
		jsr l9a4c
		lda #<(signature+4)
		cmp p39
		lda #>(signature+4)
		sbc p39+1
		bge l99be

ok_s1		lda #<lines_memory_cc00
		sta p39
		lda #>lines_memory_cc00
		sta p39+1
l99d7
		sei
		ldy #$34
		sty $1
                ldy #0
		lda (p39),y
		ldy #$36
		sty $1
		cli
		jsr l9a4c
		lda memory_lines
		cmp p39
		php
		lda memory_lines+1
		clc
		adc #>lines_memory_cc00
		plp
		sbc p39+1
		bge l99d7
		lda mcb04
		sta m8021
		lda mcb05
		ldx #3
l9a02
		asl m8021
		rol
		dex
		bne l9a02
		tax
		sei
		lda #$35
		sta $1
		lda labels_low,x
		sta m8021
		lda labels_high,x
		clc
		adc #2
		sta m8022
		lda #<labels_low
		sta p39
		lda #>labels_low		;236
		sta p39+1
l9a26
		sei
		lda #$35
		sta $1
		ldy #0
		lda (p39),y
		ldy #$36
		sty $1
		cli
		jsr l9a4c
		lda m8021
		cmp p39
		lda m8022
		sbc p39+1
		bge l9a26
                jsr redraw_all_lines_on_screen
		jsr arrow_at
		jmp l8ee7
					;9a4c
;---------------
l9a4c
		jsr l9a56
;---------------
l9a4f
		inc p39
		bne +
		inc p39+1
+		rts
					;9a56
;---------------
l9a56
		jsr $ffd2
		lda $90
		bne +
		rts
+					;9a5e
		jsr arrow_at
		jmp l8ee7
					;9a64
l9a64
		jmp l92fd
					;9a67
;---------------
arrow_l
		jsr pharse_line_if_any
		ldx #$12		;18
		jsr print_message
		lda #$0b		;11
		ldy #$1f		;31
		jsr input
		lda #$0b		;11
		jsr open_asm_read
		ldx #1
		jsr $ffc6
		lda #0
		sta m8021
l9a85
		jsr $ffcf               ;cint
		ldx $90
		bne l9a64
		ldy m8021
		sta tab_position,y
		inc m8021
		bne l9a85
		jsr l85d0
		lda mcb14
		sta p39
		lda mcb15
		sta p39+1

                jsr check_ide64
		bcc l9aa4
                lda #<(signature+5)
                sbc p39
                tax
                lda #>(signature+5)
                sbc p39+1
                tay
		lda #p39
		jsr $def4
                bcc ok_s2

                ldx #1
                jsr $ffc6
l9aa4
		jsr $ffcf               ;cint
		ldy #0
		sta (p39),y
		jsr l9a4f
		lda #<(signature+4)
		cmp p39
		lda #>(signature+4)
		sbc p39+1
		bge l9aa4
ok_s2		lda #<lines_memory_cc00
		sta p39
		lda #>lines_memory_cc00
		sta p39+1
l9ac0
		jsr $ffcf               ;cint
		sei
		ldy #$34
		sty $1
                ldy #0
		sta (p39),y
		lda #$36
		sta $1
		cli
		jsr l9a4f
		lda memory_lines
		cmp p39
		php
		lda memory_lines+1
		clc
		adc #>lines_memory_cc00
		plp
		sbc p39+1
		bge l9ac0
		lda #<labels_low
		sta p39
		lda #>labels_low		;236
		sta p39+1
                jsr check_ide64
		bcc l9aeb
                ldx #<($10000-labels_low)
                ldy #>($10000-labels_low)
		lda #p39
		jsr $def4
                lda $90
                and #$bf
                bcc ok_s3

                ldx #1
                jsr $ffc6

l9aeb
		jsr $ffcf               ;cint
		ldy #0
		sta (p39),y
		jsr l9a4f
		lda $90
ok_s3		beq l9aeb
                jsr redraw_all_lines_on_screen
		jsr arrow_at
		jsr $ffcc
		lda #1
		jsr $ffc3
		jmp l83d0
					;9b0a
;---------------
arrow_d
		jsr pharse_line_if_any
                jsr check_device_present
		ldx #$13		;19
		jsr print_message
		lda #$0e		;14
		ldy #$27		;"'"
		jsr input
		ldy #$29		;")"
l9b1b
		dey
		lda t100,y
		cmp #$20		;" "
		beq l9b1b
		tya
		sec
		sbc #$0e		;14
		ldx #$0f		;15
		ldy #1
		jsr $ffbd
		jsr arrow_at_in
		jmp l8ee7
					;9b42
;---------------
arrow_n
		jsr pharse_line_if_any
		ldx #$14		;20
		jsr print_message
		lda #$0b		;11
		ldy #$0f		;15
		jsr input
		ldy #0
		sty destination_line
		sty destination_line+1
		sty m800b
		sty m800c
l9b5f
		lda m10c,y
		sec
		sbc #"0"
		cmp #10
		bge l9b7c
		asl
		asl
		asl
		asl
		ldx #4
-		asl a
		rol m800b
		rol m800c
		dex
		bne -
		iny
		bne l9b5f
l9b7c
		ldx #4
l9b7e
		lda #0
		sta m800d
		ldy #4
l9b85
		asl m800b
		rol m800c
		rol m800d
		dey
		bne l9b85
		jsr l9bdc
		clc
		lda destination_line
		adc m800d
		sta m800f
		lda destination_line+1
		adc #0
		sta m8010
		jsr l9bdc
		jsr l9bdc
		clc
		lda destination_line
		adc m800f
		sta destination_line
		lda destination_line+1
		adc m8010
		sta destination_line+1
		dex
		bne l9b7e
		lda memory_lines
		cmp destination_line
		lda memory_lines+1
		sbc destination_line+1
		blt l9bd9
		jsr l9591
                jsr redraw_all_lines_on_screen
		jmp l8737
					;9bd9
l9bd9
		jmp l8a1c
					;9bdc
;---------------
l9bdc
		asl destination_line
		rol destination_line+1
		rts
					;9be3
;---------------
l9be3
		sta p39
		stx p39+1
		ldy #$16		;22
l9be9
		lda current_line
		cmp mark_lines,y
		lda current_line+1
		sbc mark_lines+1,y
		bge l9c08
		lda mark_lines,y
		clc
		adc p39
		sta mark_lines,y
		lda mark_lines+1,y
		adc p39+1
		sta mark_lines+1,y
l9c08
		dey
		dey
		bpl l9be9
		rts
					;9c0d
source_colors
		.byte $00
text_colors
		.byte $09
border_colors
		.byte $0b
paper_colors
		.byte $0e
error_colors
		.byte $01
message_colors
		.byte $01
selection_colors
		.byte $0b,$01,$09,$08,$0c,$00,$06,$0b
		.byte $01,$0b,$05,$0e,$00,$06,$0b,$05
		.byte $06,$0b,$00,$0f,$0f,$09,$01,$04
		.byte $08,$06,$00,$0d,$0e,$00,$0a,$06
		.byte $0f,$0c,$01,$02
;---------------
arrow_o
		jsr pharse_line_if_any
		lda currect_color_set
		clc
		adc #7
		cmp #$2a		;"*"
		blt +
		lda #0
+		sta currect_color_set
		jmp start
					;9c4c
;---------------
arrow_r
		jsr pharse_line_if_any
		ldx #$17		;23
		jsr print_message
		lda #9
		ldy #$1e		;30
		jsr input
		ldy #$20		;" "
		lda #$20		;" "
l9c5f
		dey
		cmp t100,y
		beq l9c5f
		tya
		sec
		sbc #9
		sta mcb17
l9c6c
		lda t101,y
		sta tcb37,y
		dey
		cpy #8
		bne l9c6c
		ldx #$18		;24
		jsr print_message
		lda #4
		ldy #$1e		;30
		jsr input
		ldy #$20		;" "
		lda #$20		;" "
l9c87
		dey
		cmp t100,y
		beq l9c87
		tya
		sec
		sbc #4
		sta mcb18
l9c94
		lda t101,y
		sta tcb96,y
		dey
		cpy #3
		bne l9c94
		jmp l95fe
					;9ca2
;---------------
find
		sec
		lda #$29		;")"
		sbc mcb17
		sta m8019
		jsr l87a4
		inc cursor_x_position
l9cb1
		jsr l8561
		jsr l92a0
		dec cursor_x_position
l9cba
		inc cursor_x_position
		ldx cursor_x_position
		cpx m8019
		bge l9cda
		ldy #0
l9cc7
		lda line_buffer_200,x
		cmp tcb40,y
		bne l9cba
		inx
		iny
		cpy mcb17
		bne l9cc7
		rts
					;9cd7
l9cd7
		jmp l9601
					;9cda
l9cda
		lda #0
		sta cursor_x_position
		lda current_line
		cmp memory_lines
		bne l9cef
		lda current_line+1
		cmp memory_lines+1
		beq l9cd7
l9cef
		inc destination_line
		bne +
		inc destination_line+1
+		jsr jump_on_line
		jmp l9cb1
					;9cfd
;---------------
arrow_y
		lda #$ff		;255
		.byte $2c		;bit
;---------------
arrow_t                                 ;accessed parameter
		lda #0
		sta m8026
		jsr pharse_line_if_any
		dec cursor_x_position
l9d0b
		jsr find
		clc
		lda cursor_x_position
		tay
		adc mcb17
		tax
l9d17
		cpx #$28		;"("
		beq l9d25
		lda line_buffer_200,x
		sta line_buffer_200,y
		inx
		iny
		bne l9d17
l9d25
		lda #$20		;" "
l9d27
		sta line_buffer_200,y
		iny
		cpy #$28		;"("
		blt l9d27
		sec
		lda #$27		;"'"
		tay
		sbc mcb18
		tax
l9d37
		lda line_buffer_200,x
		sta line_buffer_200,y
		cpx cursor_x_position
		beq l9d46
		dex
		dey
		bne l9d37
l9d46
		ldy #0
l9d48
		lda tcb9a,y
		sta line_buffer_200,x
		inx
		iny
		cpy mcb18
		bne l9d48
		lda #$ff		;255
		sta line_buffer_filled
		lda destination_line
		pha
		lda destination_line+1
		pha
		jsr pharse_line_if_any
		pla
		sta destination_line+1
		pla
		sta destination_line
		jsr l9591
		jsr l85d0
		lda #0
		sta line_buffer_filled
		inc cursor_x_position
		bit m8026
		bmi l9d0b
		jsr find
		jsr l9591
		lda #0
		sta line_buffer_filled
		jmp l8737
;---------------
arrow_uparrow
		jsr l87a4
		ldy #$27		;"'"
l9df4
		lda line_buffer_200,y
		sta tcbb8,y
		dey
		bpl l9df4
		rts
					;9dfe
;---------------
arrow_font
		jsr l87a4
		ldy #$27		;"'"
l9e03
		lda tcbb8,y
		sta line_buffer_200,y
		dey
		bpl l9e03
		rts
					;9e0d
;---------------
;insert commentline

arrow_2
		jsr l87a4
		lda #";"
		sta line_buffer_200
line_filler_at	lda #"-"
		ldx #1
                gne l9e15

arrow_shift2
		jsr l87a4
		ldx cursor_x_position
		lda line_buffer_200,x
		sta line_filler_at+1
		rts
;---------------
arrow_space
		jsr l87a4
                ldx #0
                geq arrow_per_in
;---------------
arrow_per
		jsr l87a4
		ldx cursor_x_position
arrow_per_in  	lda #$20		;" "
l9e15
		sta line_buffer_200,x
		inx
		cpx #$28		;"("
		bne l9e15
		rts
					;9e1e
;---------------
arrow_return
		jsr arrow_uparrow
		jsr arrow_per
		jsr l891e
l9e27
		jsr l87a4
		ldx cursor_x_position
l9e2d
		lda tcbb8,x
		sta line_buffer_200,x
		inx
		cpx #$28		;"("
		bne l9e2d
		rts
					;9e39
;---------------
arrow_equ
		jsr arrow_uparrow
		jsr arrow_del
		jsr l8826
		jmp l9e27
					;9e48
;---------------
arrow_shift_r
		ldx #$22		;":"
		jsr print_message
		lda repeat_at+1
		eor #%10000000
		sta repeat_at+1
		bne l97ff_rts
		lda #6
		sta $79f+5
		sta $7a0+5
l97ff_rts
		rts
;---------------
arrow_u
		jsr pharse_line_if_any
		lda #$ff		;255
		sta m8024
		ldx #$1a		;26
		jsr print_message
		lda #$0d		;13
		ldy #$23		;"#"
		jsr input
		lda #<txt_labeltab		;220
		ldy #>txt_labeltab	;128
		jsr print_ay
		lda m10e
		cmp #$3f		;"?"
		beq l9e76
		cmp #$2a		;"*"
		bne l9e8a
		lda #0
		sta m8024
		ldx #3
		.byte $2c		;bit
l9e76
		ldx #4
		lda #1
		ldy #7
		jsr $ffba
		lda #0
		jsr $ffbd
		jsr $ffc0
		jmp l9e8f
					;9e8a
l9e8a
		lda #$0d		;13
		jsr open_seq_write
l9e8f
		ldx #1
		jsr $ffc9
		lda #$30		;"0"
		sta tcbb8
		lda #0
		sta mcbb9
		lda #0
		sta p3d
		lda #$e0		;224
		sta p3d+1
		lda #2
		sta src_current_line_flags
		lda #$b8		;184
		ldy #$cb		;203
		sta source_p
		sty source_p+1
		lda m8024
		beq l9ecb
l9eba
		lda m8024
		bne l9ed0
		jsr $ffe4
		beq l9ed0
		cmp #3
		bne l9ecb
		jmp start
					;9ecb
l9ecb
		jsr $ffe4
		beq l9ecb
l9ed0
		jsr lade0
		sei
		lda #$35
		sta $1
		ldy #0
		lda (p3d),y
		sta p3f
		iny
		lda (p3d),y
		sta p3f+1
		lda #$36
		sta $1
		cli
		lda p3f
		and p3f+1
		cmp #$ff		;255
		beq l9f2d
		ldx #$ff		;255
l9ef2
		inx
		lda line_buffer_200,x
		jsr $ffd2
		bit m8024
		bpl +
		jsr $e716               ;output to screen
+		cmp #$20		;" "
		bne l9ef2
l9f05
		jsr $ffd2
		inx
		cpx #$0a		;10
		blt l9f05
		lda #<txt_eqdollar		;216
		ldy #>txt_eqdollar		;128
		jsr print_ay
		lda p3f+1
		jsr hex_print
		lda p3f
		jsr hex_print
		lda #$0d		;13
		jsr $ffd2
		lda m8024
		beq l9f2d
		lda #$0d		;13
		jsr $e716               ;output to screen
l9f2d
		inc mcbb9
		bne +
		inc tcbb8
+		clc
		lda p3d
		adc #2
		sta p3d
		bcc +
		inc p3d+1
+		lda mcbb9
		cmp mcb04
		lda tcbb8
		and #%00000111
		sbc mcb05
		bge +
		jmp l9eba
+					;9f53
		jsr $ffcc
		lda #1
		jsr $ffc3
		lda #<txt_end_labeltab
		ldy #>txt_end_labeltab
		jsr print_ay
		jmp l81bb
;---------------
arrow_i
		jsr pharse_line_if_any
		ldx #$1f		;31
		jsr print_message
		lda #$11		;17
		ldy #$20		;" "
		jsr input
		ldy #$27		;"'"
		lda #$20		;" "
la014
		sta line_buffer_200,y
		dey
		bpl la014
		ldy #$20		;" "
la01c
		lda t101,y
		sta line_buffer_200-17,y
		dey
		cpy #$10		;16
		bne la01c
		jsr l8e45
		lda #0
		sta line_buffer_filled
		lda line_buffer_200+41
		and #%11110000
		cmp #$30		;"0"
		beq la03d
		ldx #$20		;" "
		jmp l8ee4
					;a03d
la03d
		lda #0
		sta destination_line
		sta destination_line+1
la045
		jsr jump_on_line
		lda source_p
		sta p39
		lda source_p+1
		sta p39+1
		ldy #0
		lda line_buffer_200+41
		cmp (p39),y
		bne la063
		iny
		lda line_buffer_200+42
		cmp (p39),y
		beq la07e
la063
		lda destination_line
		cmp memory_lines
		bne la073
		lda destination_line+1
		cmp memory_lines+1
		beq la07e
la073
		inc destination_line
		bne la045
		inc destination_line+1
		jmp la045
					;a07e
la07e
		lda #0
		sta cursor_x_position
		jmp l9591
					;a086
;---------------
arrow_q
		lda mcb14
		sec
		sbc #1
		sta pfb
		lda mcb15
		sbc #0
		sta pfb+1
		jsr la0f2
		sta ma1c5
		lda pfb+1
		jsr la0f6
		sta ma1c6
		lda pfb
		jsr la0f2
		sta ma1c7
		lda pfb
		jsr la0f6
		sta ma1c8
		ldx #0
		jmp la103
					;a0f2
;---------------
la0f2
		lsr
		lsr
		lsr
		lsr
;---------------
la0f6
		and #%00001111
		clc
		adc #$30		;48
		cmp #$3a		;":"
		blt la102_rts
		clc
		adc #7
la102_rts
		rts
					;a103
la103
		ldx #0
la105
		lda ta1aa,x
		sta t101,x
		inx
		cpx #$28		;"("
		bne la105
		lda #$12		;18
		ldy #$16		;22
		jsr input
		lda #$1b		;27
		ldy #$1f		;31
		jsr input
		lda #$26		;"&"
		ldy #$28		;"("
		jsr input
		lda #$13		;19
		jsr la160
		sty pfb
		sta pfb+1
		lda #$1c		;28
		jsr la160
		sty zfd
		sta zfe
		lda #$27		;"'"
		jsr la160
		sta la157+1
		ldy #0
la142
		jsr la157
		inc pfb
		bne +
		inc pfb+1
+		lda pfb+1
		cmp zfe
		blt la142
		lda pfb
		cmp zfd
		blt la142
;---------------
la157                                   ;accessed parameter
		lda #0
		sta (pfb),y
		rts
;---------------
la160
		tax
		lda pf0
		pha
		lda pf0+1
		pha
		lda zf2
		pha
		stx pf0
		lda #1
		sta pf0+1
		lda #4
		sta zf2
		lda #0
		sta z14
		lda #0
		sta z15
		ldy #0
la17e
		lda (pf0),y
		cmp #$41		;"A"
		blt +
		sbc #7
+		sec
		sbc #$30		;48
		asl
		asl
		asl
		asl
		ldx #4
la18f
		asl
		rol z14
		rol z15
		dex
		bne la18f
		iny
		dec zf2
		bne la17e
		pla
		sta zf2
		pla
		sta pf0+1
		pla
		sta pf0
		ldy z14
		lda z15
		rts
					;a1aa
ta1aa
		.text "fILL MEMORY FROM $07E8 TO $"
ma1c5
		.text "7"
ma1c6
		.text "F"
ma1c7
		.text "E"
ma1c8
		.text "A WITH $00   "

		.cerror *>$9fe0

                *=$a001
mnemonics	.block
		.text "BCC", "BCS", "BEQ", "BMI", "BNE", "BPL", "BVC", "BVS", "BRK", "CLC", "CLD"
		.text "CLI", "CLV", "DEX", "DEY", "INX", "INY", "NOP", "PHA", "PHP", "PLA", "PLP"
		.text "RTI", "RTS", "TAX", "TAY", "TSX", "TXA", "TXS", "TYA", "SEC", "SED", "JSR"
		.text "SEI", "OAL", "ANA", "ANB", "XMA", "AXS", "LAS", "ASR", "ARR", "USB", "TEA"
		.text "TEX", "TEY", "AXM", "CRP", "UNP", "SKB", "SKW"

		.text "EOR", "STA", "SBC", "ROL", "ORA", "LSR", "LDY", "LDX", "LDA", "CMP", "ASL"
		.text "AND", "ADC", "JMP", "STY", "STX", "ROR", "INC", "DEC", "CPX", "CPY", "BIT"
		.text "AAX", "DCP", "INS", "RLA", "LAX", "SLO", "RRA", "SRE"
		.bend
ma40c
		.byte $00
ma40d
		.byte $00
line_buffer_wp
		.byte ?
ma40f
		.byte $30

xtmp		.byte ?
address_mode	.byte ?
opcode_index	.byte ?

ma413
		.byte $08
ma414
		.byte $ed
decparse_tmp
		.byte ?
ma416
		.byte $ff
ma417
		.byte $00

parent_depth	.byte ?

ma419
		.byte $03
ma41a
		.byte $10
ma41b
		.byte $8d
ma41c
		.byte $21
ma41d
		.byte $00
ma41e
		.byte $02
ma41f
		.byte $0c,$00,$00
ma422
		.byte $00

source_linelen	.byte ?

ma424
		.byte $00,$00,$00,$00,$00,$00,$00
line_buffer_rp
		.byte ?
ma42c
		.byte $00
ma42d
		.byte $20
;---------------
get_from_line_buffer
		lda line_buffer_rp
		sta (+)+1
+		lda line_buffer_200
		beq +
		inc line_buffer_rp
+		rts
					;a442
;---------------
put_to_line_buffer
		stx xtmp
la445
		ldx line_buffer_wp
		inc line_buffer_wp
		sta line_buffer_200+41,x
		ldx xtmp
		rts
					;a452
la452
		tsx
		stx ma414
		lda #0
		sta ma40c
		sta ma422
		sta source_linelen
		sta ma424
		sta line_buffer_wp
		sta line_buffer_rp
		sta opcode_buf
		sta ma417
		lda #" "
		ldx #40+1
-		dex
		beq la4c0
		cmp line_buffer_200-1,x
		beq -
		lda #0
		sta line_buffer_200,x
		jsr la6f0
		jsr la51c
		lda #$0d		;13
		sta m145
		lda t100
		cmp #$20		;" "
		beq la49b
		dec ma422
		ldx #0
		jsr la6af
la49b
		lda t10f
		cmp #$20		;" "
		beq la4b3
		jsr la785
		lda ma41c
		bpl +
		jmp la816
+					;a4ad
		dec source_linelen
		jmp labc7
					;a4b3
la4b3
		ldy #0
la4b5
		lda opcode_buf,y
		beq la4c0
		jsr put_to_line_buffer
		iny
		bne la4b5
la4c0
		clc
la4c1
		ldx ma414
		txs
		lda #0
		bit ma424
		bmi la4da
		bit source_linelen
		bpl la4da
		lda #$80		;128
		bit ma422
		bpl la4da
		ora #%01000000
la4da
		ora line_buffer_wp
		sta src_current_line_flags
		lda ma40c
		rts
					;a4e4
;---------------
la4e4
		stx ma40c
		dec ma424
		lda #0
		sta line_buffer_rp
		sta line_buffer_wp
		ldx ma41a
		lda ma41d
		sta line_buffer_200+1,x

-		jsr get_from_line_buffer
		cmp #" "
		beq -
		pha
		ldx line_buffer_rp
		dex
		txa
		ora #%11000000
		jsr put_to_line_buffer
		pla
la50e
		sec
		beq la4c1
		jsr put_to_line_buffer
		jsr get_from_line_buffer
		jmp la50e
					;a51a
la51a
		sec
		rts
					;a51c
;---------------
la51c
		ldy #$46		;"F"
		lda #$20		;" "
la520
		sta t100,y
		dey
		bpl la520
		ldx #0
		stx ma416
		dex
		stx ma41c
		jsr la5b4
		beq la51a
		jsr la57c
		dec line_buffer_rp
		bcs la56b
		ldy #0
		jsr la5be
		php
		lda m103
		cmp #$30		;"0"
		bge la568
		ldy #0
		jsr opcode_search
		bit ma41c
		bmi la568
		ldy #2
la555
		lda t100,y
		sta t10f,y
		lda #$20		;" "
		sta t100,y
		dey
		bpl la555
		plp
		bcs la57a
		bcc la572
la568
		plp
		bcs la57a
la56b
		ldy #$0f		;15
		jsr la5be
		bcs la57a
la572
		dec ma416
		ldy #$20		;" "
		jsr la5be
la57a
		clc
		rts
					;a57c
;---------------
la57c
		cmp #$41		;"A"
		blt la583
		cmp #$5b		;"["
		rts
					;a583
la583
		sec
		rts
					;a585
;---------------
opcode_search
		ldx #0
		stx ma41c
la58a
		lda mnemonics,x
		cmp t100,y
		beq la5a2
la592
		inc ma41c
		inx
		inx
		inx
		cpx #size(mnemonics)
		blt la58a
		ldx #$ff		;255
		stx ma41c
la5a1_rts
		rts
					;a5a2
la5a2
		lda mnemonics+1,x
		cmp t101,y
		bne la592
		lda mnemonics+2,x
		cmp t102,y
		bne la592
		beq la5a1_rts
;---------------
la5b4
		jsr get_from_line_buffer
		beq la5bd_rts
		cmp #$20		;" "
		beq la5b4
la5bd_rts
		rts
					;a5be
;---------------
la5be
		sty ma42d
		ldy #$46		;"F"
		lda #$20		;" "
la5c5
		dey
		sta t100,y
		cpy ma42d
		bne la5c5
		jsr la5b4
		bne la5e2
la5d3
		beq la5f1
		bit ma416
		bmi la5e2
		cmp #$3d		;"="
		beq la5ec
		cmp #$30		;"0"
		blt la5ec
la5e2
		sta t100,y
		iny
		jsr get_from_line_buffer
		jmp la5d3
					;a5ec
la5ec
		dec line_buffer_rp
		clc
		rts
					;a5f1
la5f1
		sec
		rts
					;a5f3
;---------------
la5f3
		lda $1
		pha
		sei
		lda #$35
		sta $1
		lda #0
		sta ma40d
		sta ma40f
		lda labels_low
		sta pmemory_put
		lda labels_high
		sta pmemory_put+1
la60d
		ldy #0
		sty ma40c
		ldx #0
		lda ma40d
		cmp mcb05
		bne la624
		lda ma40f
		cmp mcb04
		beq la659
la624
		lda (pmemory_put),y
		pha
		and #%01111111
		cmp t100,x
		beq +
		dec ma40c
+		inx
		iny
		pla
		bpl la624
		bit ma40c
		bmi la640
		cpx ma41b
		beq la6aa
la640
		clc
		tya
		adc pmemory_put
		sta pmemory_put
		bcc +
		inc pmemory_put+1
+		inc ma40f
		bne +
		inc ma40d
+		jmp la60d
					;a655
la655
		sta (pmemory_put),y
		iny
		inx
la659
		lda t100,x
		cpx ma41b
		bne la655
		dey
		lda #$80		;128
		ora (pmemory_put),y
		sta (pmemory_put),y
		lda pmemory_put
		sta mcb19
		lda pmemory_put+1
		sta mcb1a
		dec ma417
		inc mcb04
		lda mcb04
		and #%00011111
		bne la6aa
		lda mcb04
		bne +
		inc mcb05
+		lda mcb04
		sta p3f
		lda mcb05
		sta p3f+1
		ldx #3
la693
		asl p3f
		rol p3f+1
		dex
		bne la693
		ldx p3f+1
		tya
		sec
		adc pmemory_put
		sta labels_low,x
		lda pmemory_put+1
		adc #0
		sta labels_high,x
la6aa
		pla
		sta $1
		cli
		rts
					;a6af
;---------------
la6af
		ldy #0
la6b1
		lda t100,x
		cmp #$a4		;164
		bne la6bc
		lda #$5b		;"["
		bne la6cc
la6bc
		cmp #"0"
		blt la6d6
		cmp #"Z"+1
		bge la6d6
		cmp #"9"+1
		blt la6cc
		cmp #"A"
		blt la6d6
la6cc
		sta t100,y
		inc line_buffer_rp
		inx
		iny
		bne la6b1
la6d6
		cpy #$10		;16
		blt +
		ldy #$0f		;15
+		sty ma41b
		jsr la5f3
		lda #$30		;"0"
		ora ma40d
		jsr lab98
		lda ma40f
		jmp put_to_line_buffer
					;a6f0
;---------------
la6f0
		jsr get_from_line_buffer
		beq la734
		cmp #"@"
		bne +
		ldx line_buffer_rp
		lda line_buffer_200,x
		sbc #"0"
		cmp #10
		bge la714
		jmp la75b
					;a708
+
		cmp #'"'
		bne la714
		lda line_buffer_wp
		eor #%11111111
		sta line_buffer_wp
la714
		ldy line_buffer_wp
		bmi la6f0
		cmp #";"
		bne la6f0
		ldx line_buffer_rp
		dex
		txa
		ora #%10000000
		sta opcode_buf
		ldy #1

-		jsr get_from_line_buffer
		sta opcode_buf,y
		beq la737
		iny
		bne -
la734
		ldx line_buffer_rp
la737
		dex
		bmi la758
		lda line_buffer_200,x
		cmp #" "
		beq la737
		stx ma41a
		lda line_buffer_200+1,x
		sta ma41d
		lda #0
		sta line_buffer_200+1,x
		lda #0
		sta line_buffer_wp
		sta line_buffer_rp
		rts
					;a758
la758
		jmp la4b3
					;a75b
la75b
		lda #0
		sta line_buffer_rp
		sta line_buffer_wp
-
		jsr get_from_line_buffer
		cmp #" "
		beq -
		pha
		ldx line_buffer_rp
		dex
		txa
		ora #%01000000
		jsr put_to_line_buffer
		pla

-		sec
		beq +
		jsr put_to_line_buffer
		jsr get_from_line_buffer
		jmp -
					;a782
+
		jmp la4c1
					;a785
;---------------
la785
		lda t10f
		jsr la57c
		bcs la7a1_rts
		lda ma41c
		bpl la7a1_rts
		ldy #$0f		;15
		jsr opcode_search
		bit ma41c
		bpl la7a1_rts
		ldx #2
		jmp la4e4
					;a7a1
la7a1_rts
		rts
					;a7a2
directive_abbrev
		.shift ".OF"
		.shift ".TE"
		.shift ".BY"
		.shift ".WO"
		.shift "="
		.shift "*"
		.shift ".MA"
		.shift ".ENDM"
		.shift "#"
		.shift ".IFNE"
		.shift ".ENDIF"
		.shift ".BL"
		.shift ".BE"
		.shift ".PRON"
		.shift ".PROF"
		.shift ".IN"
		.shift ".END"
		.shift ".EO"
		.shift ".LB"
		.shift ".VA"
		.shift ".HI"
		.shift ".SHO"
		.shift ".SHI"
		.shift ".IFPL"
		.shift ".IFMI"
		.shift ".IFEQ"
		.shift ".IF"
		.shift ".RT"
		.shift ".NU"
		.shift ".SE"
		.shift ".GO"
		.byte 0
		;.shift ".PA"
		;.byte 0
la811
		ldx #3
		jmp la4e4
					;a816
la816
		ldx #0
		lda #1
		sta ma41c
la81d
		ldy #0
		sty ma40c
-
		lda directive_abbrev,x
		beq la811
		pha
		and #%01111111
		cmp t10f,y
		beq +
		dec ma40c
+		iny
		inx
		pla
		bpl -
		inc ma41c
		bit ma40c
		bmi la81d
		ldx ma41c
		dex
		txa
		jsr put_to_line_buffer
		txa
		asl
		tax
		lda directive_decode-1,x
		pha
		lda directive_decode-2,x
		pha
		rts
					;a853
directive_decode
		.rta decode_offs
		.rta decode_text
		.rta decode_byte
		.rta decode_byte
		.rta decode_equal
		.rta decode_star
		.rta decode_macro
		.rta decode_endm
		.rta decode_hash
		.rta decode_if
		.rta decode_endif
		.rta decode_endm
		.rta decode_endm
		.rta decode_endm
		.rta decode_endm
		.rta decode_text
		.rta decode_endm
		.rta decode_eor
		.rta decode_macro
		.rta decode_var
		.rta decode_endm
		.rta decode_endm
		.rta decode_text
		.rta decode_if
		.rta decode_if
		.rta decode_if
		.rta decode_if
		.rta decode_byte
		.rta decode_text
		.rta decode_macro
		.rta decode_if
		.rta decode_page
;---------------
decode_if				;accessed parameter
		jsr la91c
;---------------
decode_offs
		jmp la8f4
					;a899
;---------------
decode_text
		lda m120
		cmp #$22		;"""
		beq la8a5
la8a0
		ldx #4
		jmp la4e4
					;a8a5
la8a5
		ldy #0
		ldx line_buffer_wp
		inc line_buffer_wp
-
		lda m121,y
		cmp #'"'
		beq la8be
		jsr put_to_line_buffer
		iny
		cpy #40
		blt -
		gge la8a0
la8be
		tya
		beq la8a0
		sta line_buffer_200+41,x
		jmp la4b3
					;a8c7
;---------------
decode_byte
		ldy #$20		;" "
		sty line_buffer_rp
la8cc
		jsr la9d6
		jsr laba4
		cmp #$2c		;","
		beq la8cc
		cmp #$0d		;13
		bne +
		jmp la4b3
+					;a8dd
		ldx #9
		jmp la4e4
					;a8e2
;---------------
decode_var
		jsr la8ff
;---------------
decode_eor
		jmp la8f4
					;a8e8
;---------------
decode_equal
		jsr la8ff
		lda m110
		ldy #$10		;16
		cmp #$20		;" "
		bne la8f6
la8f4
		ldy #$20		;" "
la8f6
		sty line_buffer_rp
		jsr la9d6
		jmp la4b3
					;a8ff
;---------------
la8ff
		lda t100
		cmp #$20		;" "
		bne la90b_rts
		ldx #$0b		;11
		jmp la4e4
					;a90b
la90b_rts
		rts
					;a90c
;---------------
decode_star
		ldy #$21		;"!"
		bne la8f6
decode_endif
		jsr la91c
		jmp la4b3
					;a916
;---------------
decode_macro
		jsr la8ff
;---------------
decode_endm
		jmp la4b3
					;a91c
;---------------
la91c
		lda t100
		cmp #$20		;" "
		beq la928_rts
		ldx #$0c		;12
		jmp la4e4
					;a928
la928_rts
		rts
decode_page
					;a929
		ldy #$20		;" "
		sty line_buffer_rp
		jmp la952
					;a931
;---------------
decode_hash
		lda m110
		ldy #$10		;16
		cmp #$20		;" "
		bne +
		ldy #$20		;" "
+		sty line_buffer_rp
		ldx line_buffer_rp
		lda t100,x
		jsr la57c
		bcc la94f
		ldx #$0b		;11
		jmp la4e4
					;a94f
la94f
		jsr la6af
la952
		jsr lab7d
		inc line_buffer_rp
		jsr laba4
		cmp #$0d		;13
		beq decode_endm
		dec line_buffer_rp
la962
		jsr labb8
		dec line_buffer_rp
		cmp #$22		;"""
		bne la9b4
		ldy line_buffer_rp
		lda t102,y
		cmp #$22		;"""
		beq la9b4
		lda #$4f		;"O"
		jsr put_to_line_buffer
		lda line_buffer_wp
		pha
		jsr put_to_line_buffer
		jsr labb8
		lda #0
		sta ma42c
		ldy line_buffer_rp
la98d
		lda t100,y
		iny
		inc line_buffer_rp
		cmp #$0d		;13
		beq la9a4
		cmp #$22		;"""
		beq la9a9
		jsr put_to_line_buffer
		inc ma42c
		bne la98d
la9a4
		ldx #4
		jmp la4e4
					;a9a9
la9a9
		pla
		tay
		lda ma42c
		sta line_buffer_200+41,y
		jmp la9b7
					;a9b4
la9b4
		jsr la9d6
la9b7
		jsr laba4
		cmp #$2c		;","
		beq la962
		cmp #$0d		;13
		bne +
		jmp la4b3
+					;a9c5
		ldx #9
		jmp la4e4
					;a9ca
operator_txts	.text "+-*/",$be,$bc,$a1,"&.:()"
;---------------
la9d6
		lda #0
		sta parent_depth
		jsr labb8
		bcs laa08
		ora #%10000000
		ldx #size(operator_txts)-1

-		cmp operator_txts,x
		bne +
		jmp lab5b
+					;a9ec
		dex
		bpl -
		and #%01111111
		jmp la9f9
					;a9f4
la9f4
		jsr labb8
		bcs laa08
la9f9
		cmp #"("
		bne laa0d
		inc parent_depth
		lda #$4a		;"J"
		jsr lab98
		jmp la9f4
					;aa08
laa08
		ldx #6
		jmp la4e4
					;aa0d
laa0d
		cmp #"*"
		bne +
		lda #$25		;"%"
		jsr lab98
		jmp lab47
					;aa19
+
		cmp #$5c		;"\"
		bne laa38
		lda #$27		;"'"
		jsr lab98
		jsr laba4
		cmp #"0"
		blt laa2d
		cmp #"9"+1
		blt laa32
laa2d
		ldx #6
		jsr la4e4
laa32
		jsr put_to_line_buffer
		jmp lab47
					;aa38
laa38
		jsr la57c
		bcs +
		dec line_buffer_rp
		ldx line_buffer_rp
		jsr la6af
		jmp lab47
					;aa49
+
		cmp #"0"
		blt +
		jmp parse_dec
+					;aa50
		cmp #"$"
		bne +
		jmp parse_hex
+					;aa57
		cmp #"%"
		bne +
		jmp parse_bin
+					;aa5e
		cmp #'"'
		bne laa08
		jmp parse_char
					;aa65
laa65
		ldx #8
		jmp la4e4
					;aa6a
parse_dec
		ldx #0
		stx p39
		stx p39+1
laa70
		sec
		sbc #"0"
		blt laab3
		cmp #10
		bge laab3
		sta decparse_tmp
		lda p39
		pha
		lda p39+1
		sta ma416
		ldx #3
-
		rol p39
		rol p39+1
		bcs laa65
		dex
		bne -
		pla
		asl
		php
		clc
		adc decparse_tmp
		php
		adc p39
		sta p39
		lda ma416
		rol
		bcs laa65
		plp
		adc #0
		bcs laa65
		plp
		adc p39+1
		bcs laa65
		sta p39+1
		jsr labb8
		jmp laa70
					;aab3
laab3
		lda #$22		;"""
laab5
		ldx p39+1
		beq +
		ora #%00000001
+		jsr lab98
		lda p39
		jsr put_to_line_buffer
		lda p39+1
		beq +
laac7
		jsr put_to_line_buffer
+		dec line_buffer_rp
		jmp lab47
					;aad0
laad0
		lda #$20		;" "
		bne laab5
parse_hex
		lda #0
		sta p39
		sta p39+1
laada
		jsr labb8
		cmp #"F"+1
		bge laad0
		cmp #"0"
		blt laad0
		cmp #"9"+1
		blt laaed
		cmp #"A"
		blt laad0
laaed
		cmp #"9"+1
		blt +
		adc #8
+		asl a
		asl
		asl
		asl
		ldx #4
-		asl a
		rol p39
		rol p39+1
		bcc +
		jmp laa65
+					;ab03
		dex
		bne -
		beq laada
parse_bin
		lda #0
		sta p39
		sta p39+1
-
		jsr labb8
		cmp #"0"
		blt lab24
		cmp #"1"+1
		bge lab24
		ror
		rol p39
		bcc -
		jmp laa65
					;ab21
lab21
		jmp la8a0
					;ab24
lab24
		lda #$24		;"$"
		jmp laab5
					;ab29
parse_char
		lda #$26		;"&"
		jsr lab98
		ldx line_buffer_rp
		inc line_buffer_rp
		inc line_buffer_rp
		inc line_buffer_rp
		lda t101,x
		cmp #'"'
		bne lab21
		lda t100,x
		jmp laac7
					;ab47
lab47
		jsr labb8
		bcs lab78
		ldx #size(operator_txts)-1

-		cmp operator_txts,x
		beq lab5b
		dex
		bpl -
		ldx #5
		jmp la4e4
					;ab5b
lab5b
		cpx #OPER.RPARENT	;11
		bne lab6f
		dec parent_depth
		bpl +
		jmp lab7d
+					;ab67
		lda #$4b		;"K"
		jsr lab98
		jmp lab47
					;ab6f
lab6f
		txa
		ora #%01000000
		jsr lab98
		jmp la9f4
					;ab78
lab78
		lda parent_depth
		bne lab93
;---------------
lab7d
		ldx ma419
		dec line_buffer_rp
		lda line_buffer_200+41,x
		cmp #$4b		;"K"
		bne lab8d
		ora #%00010000
		.byte $2c		;bit
lab8d
		ora #%00001000
		sta line_buffer_200+41,x
		rts
					;ab93
lab93
		ldx #7
		jmp la4e4
					;ab98
;---------------
lab98
		stx xtmp
		ldx line_buffer_wp
		stx ma419
		jmp la445
					;aba4
;---------------
laba4
		stx xtmp
-
		ldx line_buffer_rp
		inc line_buffer_rp
		lda t100,x
		ldx xtmp
		cmp #" "
		beq -
		rts
					;abb8
;---------------
labb8
		jsr laba4
		cmp #$0d		;13
		beq labc5
		cmp #","
		beq labc5
		clc
		rts
					;abc5
labc5
		sec
		rts
					;abc7
labc7
		ldy #0
		sty ma41f
		ldx #$20		;" "
		lda m120
		cmp #"#"
		bne labdd
		lda #8
		sta ma41f
labda
		inx
		bne labfc
labdd
		cmp #"("
		beq labda
		cmp #"A"
		bne labf4
		lda m121
		cmp #$20		;" "
		bne labfc
		lda #3
labee
		dey
		sta ma41f
		bne labfc
labf4
		cmp #" "
		bne labfc
		lda #1
		bne labee
labfc
		stx line_buffer_rp
		lda line_buffer_wp
		sta ma41e
		inc line_buffer_wp
		iny
		beq +
		jsr la9d6
+		jsr lac53
		stx ma41f
		jsr lac85
		bcc lac42
		lda ma41f
		tax
		and #%00000100
		beq lac37
		txa
		and #%00000111
		sta ma41f
		jsr lac85
		bcc lac42
		lda ma41f
		cmp #4
		bne lac4e
		ldx #9
		bne lac3a
lac37
		txa
		ldx #3
lac3a
		stx ma41f
		jsr lac85
		bcs lac4e
lac42
		ldx ma41e
		lda ma41b
		sta line_buffer_200+41,x
		jmp la4b3
					;ac4e
lac4e
		ldx #$0a		;10
		jmp la4e4
					;ac53
;---------------
lac53
		ldx ma41f
		bne lac84_rts
		jsr laba4
		cmp #","
		bne lac74
		lda m120
		ldx #2
		cmp #"("
		beq lac84_rts
		jsr laba4
		ldx #14
		cmp #"Y"
		beq lac84_rts
		dex
		bne lac84_rts
lac74
		ldx #12
		cmp #")"
		bne lac84_rts
		jsr laba4
		ldx #10
		cmp #","
		beq lac84_rts
		inx
lac84_rts
		rts
					;ac85
;---------------
lac85
		lda #0
		sta ma41b
lac8a
		lda ma41b
		jsr get_opcode_length
		cpx ma41f
		bne laca3
		lda ma41b
		jsr lb1f2
		lda ma41c
		cmp opcode_index
		beq lacaa
laca3
		inc ma41b
		bne lac8a
		sec
		rts
					;acaa
lacaa
		clc
		rts
					;acac
;---------------
put_into_line_buffer
		stx xtmp
		ldx line_buffer_rp
		cpx #40
		bge lad76
		inc line_buffer_rp
		sta line_buffer_200,x
		ldx xtmp
		rts
					;ad68
;---------------
get_next_byte_from_source
		ldy line_buffer_wp
		cpy source_linelen
		beq lad75_rts
		inc line_buffer_wp
		lda (p39),y
lad75_rts
		rts
					;ad76
lad76
		jmp laf6f
					;ad79
lad79
		lda #$36
		sta $1
		jmp laf6f
					;ad80
;---------------
put_label
		lda $1
		pha
		sei
		lda #$35
		sta $1
		lda ma40f
		and #%00000111
		sta p3f+1
		jsr get_next_byte_from_source
		sta p3f
		and #%00011111
		tax
		ldy #3
lad99
		asl p3f
		rol p3f+1
		dey
		bne lad99
		ldy p3f+1
		lda labels_low,y
		sta pmemory_put
		lda labels_high,y
		sta pmemory_put+1
		inx
ladad
		ldy #$ff		;255
		dex
		beq ladc5
ladb2
		iny
		bmi lad79
		lda (pmemory_put),y
		bpl ladb2
		sec
		tya
		adc pmemory_put
		sta pmemory_put
		bcc ladad
		inc pmemory_put+1
		bcs ladad
ladc5
		ldy #$ff		;255
ladc7
		iny
		bmi lad79
		lda (pmemory_put),y
		pha
		and #%01111111
		cmp #$5b		;"["
		bne +
		lda #$a4		;164
+		jsr put_into_line_buffer
		pla
		bpl ladc7
		pla
		sta $1
		cli
		rts
					;ade0
lade0
		tsx
		stx ma414
		lda src_current_line_flags
		tax
		and #%11000000
		sta ma422
		txa
		and #%00111111
		sta source_linelen
		lda #" "
		ldx #40-1
-		sta line_buffer_200,x
		dex
		bpl -
		ldy #0
		sty line_buffer_wp
		sty line_buffer_rp
		lda source_p
		sta p39
		lda source_p+1
		sta p39+1
		bit ma422
		bmi theres_code
		lda (p39),y
		and #%11000000
		cmp #$40		;"@"
		bne lae29
		lda #$ff		;255
		sta ma413
		jsr get_next_byte_from_source
		jmp laf37
					;ae29
lae29
		jsr laf5a
		and #%01110000
		cmp #$30		;"0"
		bne lae3b
		jsr put_label
		inc line_buffer_rp
		jsr laf5a
lae3b
		lda tab_position
		cmp line_buffer_rp
		blt +
		sta line_buffer_rp
+		ldx ma40f
		jmp laeab
					;ae4c
theres_code    	bvc no_label
		jsr laf5a
		jsr put_label
		inc line_buffer_rp
no_label
		lda tab_position
		cmp line_buffer_rp
		blt +
		sta line_buffer_rp
+		jsr decode_code
		jmp laf2d
					;ae6b
check_table
		.rta check_offs
		.rta check_text
		.rta check_byte
		.rta check_byte
		.rta check_offs
		.rta check_offs
		.rta check_macro
		.rta check_macro
		.rta check_hash
		.rta check_offs
		.rta check_macro
		.rta check_macro
		.rta check_macro
		.rta check_macro
		.rta check_macro
		.rta check_text
		.rta check_macro
		.rta check_offs
		.rta check_macro
		.rta check_offs
		.rta check_macro
		.rta check_macro
		.rta check_text
		.rta check_offs
		.rta check_offs
		.rta check_offs
		.rta check_offs
		.rta check_byte
		.rta check_text
		.rta check_macro
		.rta check_offs
;		.rta check_page
laeab
		jsr lb13b
		lda ma40f
		cmp #$20		;"!"
		blt +
		jmp laf6f
+					;aeb8
		asl
		tax
		lda check_table-1,x
		pha			;stackjump attempt
		lda check_table-2,x
		pha			;stackjump attempt
		rts
					;aec3
;---------------
check_text
		jsr lb159
		jmp laf2d
					;aec9
;---------------
check_byte
		jsr lb023
		jsr laf5a
		lda #","
		jsr put_into_line_buffer
		dec line_buffer_wp
		jmp check_byte
					;aeda
;---------------
check_offs
		jsr lb023
		jmp laf2d
					;aee0
;---------------
check_macro
		dec line_buffer_rp
		jmp laf2d
					;aee6
;---------------
;check_page
;		jmp laef2
					;aee9
;---------------
check_hash
		dec line_buffer_rp
		jsr lb023
		inc line_buffer_rp
laef2
		ldy line_buffer_wp
		lda (p39),y
		cmp #$4f		;"O"
		bne laf1c
		jsr get_next_byte_from_source
		jsr get_next_byte_from_source
		sta ma42c
		lda #'"'
		jsr put_into_line_buffer

-		jsr get_next_byte_from_source
		jsr put_into_line_buffer
		dec ma42c
		bne -
		lda #'"'
		jsr put_into_line_buffer
		jmp laf1f
					;af1c
laf1c
		jsr lb023
laf1f
		jsr laf5a
		lda #$2c		;","
		jsr put_into_line_buffer
		dec line_buffer_wp
		jmp laef2
					;af2d
laf2d
		jsr get_next_byte_from_source
		beq laf6d
laf32
		ldy #0
		sty ma413
laf37
		tax
		and #%00111111
		cmp line_buffer_rp
		blt laf47
		sta line_buffer_rp
		txa
		and #%01000000
		bne laf4f
laf47
		lda #";"
		jsr put_into_line_buffer
		dec ma413
laf4f
		jsr get_next_byte_from_source
		beq laf68
		jsr put_into_line_buffer
		jmp laf4f
					;af5a
;---------------
laf5a
		jsr get_next_byte_from_source
		beq laf6d
		bmi laf65
		sta ma40f
		rts
					;af65
laf65
		jmp laf32
					;af68
laf68
		bit ma413
		bpl laf6f
laf6d
		clc
		.byte $24		;bit
laf6f
		sec
		ldx ma414
		txs
		rts
					;af75
taf75		.word put_hex
		.word put_dec
		.word put_binary
		.word put_char

put_prefix	.text '$',0,'%','"'

put_operator	.text "+-*/><!&.:()"

put_binary	sta opcode_index
		ldx #8
-
		asl opcode_index
		lda #"0" >> 1
		rol a
		jsr put_into_line_buffer
		dex
		bne -
lafa9_rts
		rts
					;afaa
put_dec
		sta pmemory_put
		lda #$ff		;255
		sta ma40f
		lda #0
		ldx opcode_index
		beq +
		jsr get_next_byte_from_source
+		sta pmemory_put+1
		ldx #8
lafbf
		ldy #"0"
lafc1
		sec
		lda pmemory_put
		sbc tens,x
		sta opcode_index
		lda pmemory_put+1
		sbc tens+1,x
		blt lafdb
		sta pmemory_put+1
		lda opcode_index
		sta pmemory_put
		iny
		bne lafc1
lafdb
		tya
		cmp #"0"
		bne lafe5
		bit ma40f
		bmi lafeb
lafe5
		jsr put_into_line_buffer
		sta ma40f
lafeb
		dex
		dex
		bpl lafbf
		bit ma40f
		bpl lafa9_rts
		tya
		jmp put_into_line_buffer
					;aff8
put_hex
		ldx opcode_index
		beq +
		tax
		jsr get_next_byte_from_source
		jsr +
		txa
+		pha
		lsr
		lsr
		lsr
		lsr
		jsr +
		pla
		and #%1111
+		cmp #10
		blt +
		adc #6
+		adc #"0"
		jmp put_into_line_buffer
					;b01b
put_char
		jsr put_into_line_buffer
		lda #'"'
		jmp put_into_line_buffer
					;b023
;---------------
lb023
		jsr laf5a
		and #%01100000
		cmp #$20		;" "
		bne +
		jsr lb04c
		jmp lb046
					;b032
+
		lda ma40f
		and #OPER.END
		sta ma413
		lda ma40f
		and #OPER.MASK
		tax
		lda put_operator,x
		jsr put_into_line_buffer
lb046
		lda ma413
		beq lb023
		rts
					;b04c
;---------------
lb04c
		lda ma40f
		tax
		and #%00001000
		sta ma413
		txa
		and #%00010000
		bne lb099
		txa
		and #%00000111
		cmp #5
		bne lb066
		lda #$2a		;"*"
		jmp put_into_line_buffer
					;b066
lb066
		cmp #7
		bne lb075
		lda #$5c		;"\"
		jsr put_into_line_buffer
		jsr get_next_byte_from_source
		jmp put_into_line_buffer
					;b075
lb075
		and #%00000001
		sta opcode_index
		txa
		and #%00000110
		tax
		lda taf75,x
		sta pmemory_put
		lda taf75+1,x
		sta pmemory_put+1
		txa
		lsr
		tax
		lda put_prefix,x
		beq +
		jsr put_into_line_buffer
+		jsr get_next_byte_from_source
		jmp (pmemory_put)
					;b099
lb099
		jmp put_label
					;b09c
directive_text
		.shift ".OFFS"
		.shift ".TEXT"
		.shift ".BYTE"
		.shift ".WORD"
		.shift "="
		.shift "*="
		.shift ".MACRO"
		.shift ".ENDM"
		.shift "#"
		.shift ".IFNE"
		.shift ".ENDIF"
		.shift ".BLOCK"
		.shift ".BEND"
		.shift ".PRON"
		.shift ".PROFF"
		.shift ".INCLUDE"
		.shift ".END"
		.shift ".EOR"
		.shift ".LBL"
		.shift ".VAR"
		.shift ".HIDEMAC"
		.shift ".SHOWMAC"
		.shift ".SHIFT"
		.shift ".IFPL"
		.shift ".IFMI"
		.shift ".IFEQ"
		.shift ".IF"
		.shift ".RTA"
		.shift ".NULL"
		.shift ".SEGMENT"
		.shift ".GOTO"
		;.shift ".PAGE"
;---------------
lb13b
		ldy #$ff		;255
lb13d
		dex
		beq lb148
lb140
		iny
		lda directive_text,y
		bpl lb140
		bmi lb13d
lb148
		iny
		lda directive_text,y
		pha
		and #%01111111
		jsr put_into_line_buffer
		pla
		bpl lb148
		inc line_buffer_rp
		rts
					;b159
;---------------
lb159
		jsr get_next_byte_from_source
		tax
		lda #$22		;"""
		jsr put_into_line_buffer
lb162
		jsr get_next_byte_from_source
		jsr put_into_line_buffer
		dex
		bne lb162
		lda #$22		;"""
		jmp put_into_line_buffer
					;b170
;---------------
decode_code
		jsr get_next_byte_from_source
		jsr lb1f2
		bcc +
		jmp laf6f
+					;b17b
		lda opcode_index
		asl
		adc opcode_index
		tax
		ldy #3
-		lda mnemonics,x
		jsr put_into_line_buffer
		inx
		dey
		bne -
		ldx address_mode
		cpx #1
		beq lb1ca_rts
		inc line_buffer_rp
		lda addr_prefix-2,x
		beq +
		jsr put_into_line_buffer
+		lda ma413
		cmp #1
		beq lb1ca_rts
		jsr lb023
		lda address_mode
		cmp #5
		beq lb1d9
		cmp #6
		beq lb1d6
		cmp #2
		beq lb1cb
		cmp #10
		beq lb1d3
		cmp #13
		beq lb1d9
		cmp #14
		beq lb1d6
		cmp #11
		beq lb1ce
lb1ca_rts
		rts
					;b1cb
lb1cb
		jsr lb1d9
;---------------
lb1ce
		lda #")"
		jmp put_into_line_buffer
					;b1d3
lb1d3
		jsr lb1ce
lb1d6
		lda #"Y"
		.byte $2c		;bit
;---------------
lb1d9
		lda #"X"
		pha
		lda #","
		jsr put_into_line_buffer
		pla
		jmp put_into_line_buffer
					;b1e5
addr_prefix	.byte "(","A",$00,$00,$00,$00,"#",$00,"(","(",$00,$00,$00
;---------------
lb1f2
		pha
		jsr get_opcode_length
		sta ma413
		stx address_mode
		pla
		cpx #0
		beq lb222
		tay

		ldx #size(unique_opcodes)-1
-		cmp unique_opcodes,x
		beq lb21d
		dex
		bpl -

		ldx #size(group_opcodes)
-		dex
		tya
		and group_masks,x
		cmp group_opcodes,x
		bne -
		txa
		clc
		adc #size(unique_opcodes)
		tax
lb21d
		stx opcode_index
		clc
		.byte $24		;bit
lb222
		sec
		rts
					;b224
;---------------
get_opcode_length
		lsr
		tax
		lda opcode_addressing_modes,x
		bcs +
		lsr
		lsr
		lsr
		lsr
+
		and #%1111
		tax
		lda opcode_lens,x
		rts
					;b236
opcode_lens	.byte 1,1,2,1,2,2,2,0,2,2,2,3,3,3,3

opcode_addressing_modes
		.byte $12,$02,$04,$44,$18,$38,$0c,$cc
		.byte $9a,$0a,$05,$55,$1e,$0e,$0d,$dd
		.byte $c2,$02,$44,$44,$18,$38,$cc,$cc
		.byte $9a,$0a,$05,$55,$1e,$0e,$0d,$dd
		.byte $12,$02,$04,$44,$18,$38,$cc,$cc
		.byte $9a,$0a,$05,$55,$1e,$0e,$0d,$dd
		.byte $12,$02,$04,$44,$18,$38,$bc,$cc
		.byte $9a,$0a,$05,$55,$1e,$0e,$0d,$dd
		.byte $02,$02,$44,$44,$10,$18,$cc,$cc
		.byte $9a,$0a,$55,$66,$1e,$1e,$dd,$ee
		.byte $82,$82,$44,$44,$18,$18,$cc,$cc
		.byte $9a,$0a,$55,$66,$1e,$1e,$dd,$ee
		.byte $82,$02,$44,$44,$18,$18,$cc,$cc
		.byte $9a,$0a,$05,$55,$1e,$0e,$0d,$dd
		.byte $82,$02,$44,$44,$18,$18,$cc,$cc
		.byte $9a,$1a,$15,$55,$1e,$1e,$1d,$dd
					;b403
somestuff
		.fill 40,0
offset
		.byte $00,$00
mb42d
		.byte $f8
mb42e
		.byte $00
mb42f
		.byte $00
mode_include
		.byte $00
start_address
		.byte $00,$20
;mb433
;		.byte $00
;mb434
;		.byte $00
mb435
		.byte $00
mb436
		.byte $00
mb437
		.byte $00
mode_compile_to_file
		.byte $ff
mode_print_on
		.byte $00
label_on_this_line_flag
		.byte $00
skip_compile_of_code_flag
		.byte $00
mb43c
		.byte $e3
mb43d
		.byte $7c
skip_because_of_macro_flag
		.byte $00
src_current_line_length
		.byte $00
malloc_length
		.byte ?
malloc_p
		.byte $06
mode_macro
		.byte $00
mb443
		.byte $00
mb444
		.byte $00
mb445
		.byte $00
mb446
		.byte $ed
mb447
		.byte $4a
macro_paramlen
		.byte ?
mb449
		.byte $01

showmac_flag	.byte ?

macro_type
		.byte $c0
block_level
		.byte $00
number_of_blocks
		.byte $00
actual_block
		.byte $00
mb44f
		.byte $00
undefined_statement_flag
		.byte $00
label_lookup
		.word ?
mb453
		.byte $01
label_number
		.word $0001
label_value
		.word $00ff
fatal_flag
		.byte $00
error_number
		.byte ?
mb45a
		.byte $00
mb45b
		.byte $c3
mb45c
		.byte $00
mb45d
		.byte $01
end_of_expr_flag
		.byte $08
length_of_comp_instr
		.byte $00
opcode_length
		.byte ?
opcode_mode
		.byte $08,$00
opcode
		.byte ?
long_flag
		.byte ?
result
		.byte $00,$00
argument
		.byte $26,$00

muldiv_tmp	.word ?

current_operator
		.byte $41
pass
		.byte $00
start_noted_flag
		.byte ?
mb46f
		.byte $01
mb470
		.byte $00
mb471
		.byte $00

decbuf		.word ?
dectmp		.byte ?

decflag
		.byte $35
mb476
		.byte $00
first_pass_end
		.word $00ff
mb479
		.byte $00
mb47a
		.byte $00
lb47c
		lda #$36
		sta $1
		jsr lb7d2
		lda #0
		sta z9d
		lda mcb23
		sta mb437
		lda mcb24
		sta mode_compile_to_file
		lda #0
		sta mode_print_on
		lda #$ff		;255
		sta showmac_flag
compile_loop
		ldx #$fa		;250
		txs
		lda #0
		sta mb42e
		lda z91
		cmp #$7f		;127
		bne +
		jmp lb60b
+					;b4b4
		jsr prepare_next_line_to_compile
		jsr lbbf9
		bit pass
		bmi lb4cc
		lda mode_print_on
		beq lb4cc
		bit mb42e
		bmi lb4cc
		jsr print_line
lb4cc
		jsr write_opcode
		lda mb42f
		bne lb4e5
		lda current_line
		cmp memory_lines
		lda current_line+1
		sbc memory_lines+1
		blt compile_loop
					;b4e5
lb4e5
		lda mb437
		sta mode_print_on
		jsr $ffcc
		jsr print_immediate
		.null $8d,"         ***** eND OF PASS "
		lda pass
		clc
		adc #$32		;50
		jsr print_to_screen_and_other
		jsr print_immediate
		.null $8d,"         fIRST ADRESS : "
		lda start_address+1
		jsr print_hex_to_screen_and_other
		lda start_address
		jsr print_hex_to_screen_and_other
		jsr print_immediate
		.null $8d,"         lAST  ADRESS : "
		lda current_address
		bne +
		dec current_address+1
+		dec current_address
		lda current_address+1
		jsr print_hex_to_screen_and_other
		lda current_address
		jsr print_hex_to_screen_and_other
		lda #$0d		;13
		jsr print_to_screen_and_other
		jsr lb936
		inc pass
		bne lb5ed
		lda current_address
		sta first_pass_end
		lda current_address+1
		sta first_pass_end+1
		lda start_address
		sta current_address
		lda start_address+1
		sta current_address+1
		lda mode_compile_to_file
		beq lb5ac
		ldx #1
		jsr $ffc9
		lda start_address
		jsr $ffd2
		lda start_address+1
		jsr $ffd2
		jsr $ffcc
lb5ac
		jmp compile_loop
					;b5af
lb5af
		lda #15
		ldx $ba
                tay
		jsr $ffba               ;talk
                lda #0
                sta $b7
		jsr $ffc0
                ldx #15
		jsr $ffc6               ;tksa
lb5bd
		jsr $ffcf               ;cint
		jsr $ffd2
		cmp #$0d		;13
		bne lb5bd
                jsr $ffcc
                lda #15
		jmp $ffc3

;---------------
print_to_screen_and_other
		jsr $e716               ;output to screen
		pha
		lda z9a
		cmp #3
		bne +
		pla
		rts
					;b5e9
+
		pla
		jmp $ffd2
					;b5ed
lb5ed
		lda current_address
		cmp first_pass_end
		beq lb601
-
		lda error_count
		ora error_count+1
		bne +
		ldx #ERROR.PHASE_ERROR
		jmp fatal_error		;phase error
					;b601
lb601
		lda current_address+1
		cmp first_pass_end+1
		bne -
+
		jmp lb61d
					;b60b
lb60b
		lda #0
		sta 198
		jsr lb71d
		jsr print_immediate
		.null "sTOPPED"
lb61d
		jsr lb71d
		jsr print_immediate
		.null $8d,"    -> mEMORY USED DOWN TO $"
		lda memory_bottom+1
		jsr print_hex_to_screen_and_other
		lda memory_bottom
		jsr print_hex_to_screen_and_other
		jsr print_immediate
		.null $8d,"         eRRORS : "
		lda error_count
		ldy error_count+1
		jsr print_dec
		lda mcb23
		ora mcb24
		ora error_count
		ora error_count+1
		beq lb6a5
		jsr print_immediate
		.null $8d,$8d,"       ***** pRESS ANY KEY *****"
		jsr get_key
		jmp start
					;b6a5
lb6a5
		jsr print_immediate
		.null $8d,$8d,"      -> pRESS 'S' TO START",$8d,"         OR OTHER KEY TO EDIT"
		jsr get_key
		cmp #"S"
		beq +
		jmp start
+					;b6ee
		jsr print_immediate
		.null $93,$11,$11,"   sTARTED :",$8d

		jsr reset_vectors_install_334
		lda #>($a474-1)
		pha
		lda #<($a474-1)
		pha
		sec
		lda start_address
		sbc #1
		tay
		lda start_address+1
		sbc #0
		pha			;stackjump attempt
		tya
		pha			;stackjump attempt
                jmp l8006
					;b71d
;---------------
lb71d
		lda #1
		jsr $ffc3
		jmp $ffcc
					;b725
;---------------
write_opcode
		lda length_of_comp_instr
		beq lb78e_rts
		bit pass
		bmi write_firstpass
		ldx length_of_comp_instr

-		lda opcode_buf,x
eor_char_at   	eor #0
		sta opcode_buf,x
		dex
		bpl -
		bit mb437
		bmi lb782
		lda mode_compile_to_file
		beq +
		ldx #1
		jsr $ffc9

		ldy #0
-		lda opcode_buf,y
		jsr $ffd2               ;ciout
		iny
		cpy length_of_comp_instr
		bne -
		jsr $ffcc
		jmp lb782
					;b767
+
		ldy length_of_comp_instr
		dey
		clc
		lda current_address
		adc offset
		sta pmemory_put
		lda current_address+1
		adc offset+1
		sta pmemory_put+1
-		lda opcode_buf,y
		sta (pmemory_put),y
		dey
		bpl -
lb782
		lda current_address
		clc
		adc length_of_comp_instr
		sta current_address
		bcc lb78e_rts
		inc current_address+1
lb78e_rts
		rts

					;b78f
write_firstpass
		bit start_noted_flag
		bmi lb782
		dec start_noted_flag
		lda current_address
		sta start_address
		lda current_address+1
		sta start_address+1
		jmp lb782
					;b7a4
;---------------
compile_add_byte
		ldy length_of_comp_instr
		sta opcode_buf,y
		inc length_of_comp_instr
		rts
					;b7ae
;---------------
get_byte_from_compile_buff
		sty temp_y_at+1
		ldy mb45c
		cpy src_current_line_length
		beq lb7c6
		lda somestuff,y
		sta mb45d
temp_y_at      	ldy #0
		inc mb45c
		rts
					;b7c6
lb7c6
		jmp lbd93
					;b7c9
;---------------
next_or_exit
		ldy mb45c
		lda somestuff,y
		bmi lb7c6
		rts
					;b7d2
;---------------
lb7d2
		jsr print_immediate
		.text $8d,$93,$0e," "
		.fill 38,"*"
		.text $8d," * ",$12,$05," ",$d4
		.text "URBO-aSS"
		.text " mAC++ EXTENDED vERSION ",$90,$92," *",$8d," "
		.fill 38,"*"
		.text $8d,$8d,$90,"         20090614 ",$05,"sOCI/","sINGULAR",$8d,$8d
		.text $90,"      cOPYRIGHT : ",$05,"oMIKRON gERMANY",$90,$8d,$8d,$00
		lda memory_lines
		sta result
		lda memory_lines+1
		sta result+1
		lda #$26		;"&"
		sta argument
		lda #0
		sta argument+1
		jsr lc30a
		ldy result
		iny
		sty mb46f
		lda mcb14
		sta mb43c
		sta memory_bottom
		sta macro_param_p
		sta p47
		sta p45
		sec
		lda mcb15
		sbc #1
		sta macro_param_p+1
		sbc #1
		sta p45+1
		sbc #1
		sta p47+1
		sta mb43d
		sta memory_bottom+1
		lda #0
		sta error_count
		sta error_count+1
		sta skip_because_of_macro_flag
		sta mode_macro
		sta mb443
		sta start_noted_flag
		lda #$ff		;255
		sta pass
		lda #<labels_low
		sta p39
		lda #>labels_low		;236
		sta p39+1
		ldy #0
		ldx #$0c		;12
		lda #$ff		;255
lb92c
		dec p39+1
lb92e
		sta (p39),y
		iny
		bne lb92e
		dex
		bne lb92c
;---------------
lb936
		lda #<memory_bottom_default
		ldy #>memory_bottom_default
		sta source_p
		sty source_p+1
		lda #$ff		;255
		sta current_line
		sta current_line+1
		lda #0
		sta mb42f
		sta mode_include
		sta block_level
		sta number_of_blocks
		sta actual_block
		sta skip_compile_of_code_flag
		sta eor_char_at+1
		lda $d020
		lda #$0f		;15
		sta $d021
		lda #0
		sta mb470
		sta mb471
		lda #0
		sta offset
		sta offset+1
;---------------
lb97a
		lda #0
		tay
lb97d
		sta (p45),y
		dey
		bne lb97d
		rts
					;b983
;---------------
prepare_next_line_to_compile
		lda mode_macro
		beq +
		jmp lba62
+					;b98b
		lda mode_include
		bne lb9fc
		sei
		lda #$34
		sta $1
		inc current_line
		bne +
		inc current_line+1
+		lda current_line
		sta p39
		clc
		lda current_line+1
		adc #>lines_memory_cc00
		sta p39+1
		ldy #0
		lda (p39),y
		sta src_current_line_flags
		and #%00111111
		sta src_current_line_length
                tay
		eor #%11111111
		sec
		adc source_p
		sta source_p
		sta p39
		lda source_p+1
		sbc #0
		sta source_p+1
		sta p39+1
		tya
                beq lb9dd
                dey
lb9d0           lda (p39),y
		sta somestuff,y
		dey
		bpl lb9d0
lb9dd
		lda #$36
		sta $1
		cli
		dec mb470
		bne lb9fb_rts
		lda mb46f
		sta mb470
		inc mb471
		ldy mb471
		lda pass
		clc
		adc #1
		sta $d82a,y
lb9fb_rts
		rts
					;b9fc
lb9fc
		ldx #6
		jsr $ffc6
		ldx #$27		;"'"
		lda #$20		;" "
lba05
		sta line_buffer_200,x
		dex
		bpl lba05
		ldx #0
lba10
		jsr $ffcf
		cmp #$0d		;13
		beq lba43
		sta line_buffer_200,x
                inx
		lda $90
		beq lba10
		lda #0
		sta mode_include
		sta src_current_line_flags
                jsr $ffcc
		lda #6
		jsr $ffc3
                jsr lb5af
		lda mb435
		sta source_p
		lda mb436
		sta source_p+1
		rts
					;ba43
lba43
		jsr $ffcc
lba46
		jsr la452
		lda src_current_line_flags
		and #%00111111
		sta src_current_line_length
                tay
                beq lba61_rts
                dey
lba53           lda line_buffer_200+41,y
		sta somestuff,y
		dey
		bpl lba53
lba61_rts
		rts
					;ba62
lba62
		lda showmac_flag
		bne +
		dec mb42e
+		ldx mb447
		dex
		stx p39+1
		lda mb446
		sta p39
		ldy #$ff		;255
		lda (p39),y
		sta src_current_line_flags
		and #%00111111
		sta src_current_line_length
		sec
		lda #$fe		;254
		sbc src_current_line_length
		tay
		lda (p39),y
		sta mb45b
		iny
		ldx #0
lba90
		lda (p39),y
		sta somestuff,x
		inx
		iny
		cpx src_current_line_length
		bne lba90
		lda mb45a
		beq lbaae
		lda #0
		sta mb45a
		bit mb45b
		bvs lbaae
		jsr dir_block
lbaae
		sec
		lda mb446
		sbc src_current_line_length
		sta mb446
		bcs +
		dec mb447
+		sec
		lda mb446
		sbc #2
		sta mb446
		bcs +
		dec mb447
+		bit src_current_line_flags
		bmi lbad9_rts
		lda somestuff
		and #%11000000
		cmp #$40		;"@"
		beq +
lbad9_rts
		rts
+					;bada
		ldx #1
lbadc
		lda somestuff,x
		inx
		cmp #$40		;"@"
		beq lbaea
		sta line_buffer_200-2,x
		jmp lbadc
					;baea
lbaea
		stx mb479
		lda somestuff,x
		jsr lc3eb
		lda argument+1
		sta p51+1
		lda argument
		sta p51
		ldy #0
		lda (p51),y
		and #%00111111
		sta mb47a
		ldx mb479
		iny
lbb0a
		lda (p51),y
		sta line_buffer_200-2,x
		inx
		iny
		cpy mb47a
		blt lbb0a
		ldy mb479
lbb19
		iny
		cpy src_current_line_length
		bge lbb29
		lda somestuff,y
		sta line_buffer_200-2,x
		inx
		jmp lbb19
					;bb29
lbb29
		lda #0
		sta line_buffer_200-2,x
		jmp lba46
					;bb31
;---------------
get_key
		jsr $ffe4
		beq get_key
		rts
					;bb37
;---------------
print_hex_to_screen_and_other
		pha
		lsr
		lsr
		lsr
		lsr
		jsr +
		pla
		and #%1111
+		cmp #10
		blt +
		adc #6
+		adc #"0"
		jmp print_to_screen_and_other
					;bb54
;---------------
print_immediate
		pla			;stack parameters?
		sta p49
		pla			;stack parameters?
		sta p49+1
lbb5a
		inc p49
		bne +
		inc p49+1
+		ldy #0
		lda (p49),y
		beq lbb6c
		jsr print_to_screen_and_other
		jmp lbb5a
					;bb6c
lbb6c
		lda p49+1
		pha
		lda p49
		pha
		rts
					;bb73
;---------------
print_line
		lda mode_print_on
		beq lbb7d
		ldx #1
		jsr $ffc9
lbb7d
		lda length_of_comp_instr
		beq lbba1
		lda current_address+1
		jsr print_hex_to_screen_and_other
		lda current_address
		jsr print_hex_to_screen_and_other
		ldy #0
lbb8e
		cpy length_of_comp_instr
		beq lbba1
		lda #$20		;" "
		jsr print_to_screen_and_other
		lda opcode_buf,y
		jsr print_hex_to_screen_and_other
		iny
		bne lbb8e
lbba1
		lda source_p
		pha
		lda source_p+1
		pha
		lda #<somestuff
		sta source_p
		lda #>somestuff		;180
		sta source_p+1
		jsr lade0
		pla
		sta source_p+1
		pla
		sta source_p
		ldy #40+1
-		dey
		beq lbbf1
		lda line_buffer_200-1,y
		cmp #" "
		beq -
		sty mb45c
		lda print_column
		cmp #15
		blt lbbd8
		lda #$0d		;13
		jsr print_to_screen_and_other
lbbd8
		lda #" "
		jsr print_to_screen_and_other
		lda print_column
		cmp #15
		blt lbbd8
		ldy #0
lbbe5
		lda line_buffer_200,y
		jsr print_to_screen_and_other
		iny
		cpy mb45c
		bne lbbe5
lbbf1
		lda #$0d		;13
		jsr print_to_screen_and_other
		jmp $ffcc
					;bbf9
;---------------
lbbf9
		tsx
		stx mb42d
		lda #0
		sta mb45c
		sta label_on_this_line_flag
		sta length_of_comp_instr
		lda skip_compile_of_code_flag
		beq lbc4e
		lda src_current_line_flags
		bmi lbc46
		beq lbc46
		lda somestuff
		cmp #$0b		;11
		bne lbc21
		dec skip_compile_of_code_flag
		jmp lbd96
					;bc21
lbc21
		cmp #$0a		;10
		beq lbc43
                cmp #$1c
                bge ksk
		cmp #$18		;24
		bge lbc43
ksk		cmp #8
		bne lbc46
		lda mode_macro
		beq lbc46
		ldx #ERROR.UNSOLVED
		jmp fatal_error		;condition unsolved
					;bc43
lbc43
		inc skip_compile_of_code_flag
lbc46
		lda #$ff		;255
		sta mb42e
		jmp lbd96
					;bc4e
lbc4e
		lda skip_because_of_macro_flag
		beq lbc9e
		bit src_current_line_flags
		bmi lbc76
		jsr get_byte_from_compile_buff
		dec mb45c
		and #%11110000
		cmp #$30		;"0"
		bne lbc6a
		lda somestuff+2
		jmp lbc6d
					;bc6a
lbc6a
		lda somestuff
lbc6d
		cmp #8
		bne lbc76
		lda #0
		sta skip_because_of_macro_flag
lbc76
		lda pass
		beq lbc9b
		clc
		lda src_current_line_length
		adc #2
		jsr malloc

		ldx #0
-		cpx src_current_line_length
		beq +
		lda somestuff,x
		jsr malloc_push
		inx
		jmp -
+
		lda src_current_line_flags
		jsr malloc_push
lbc9b
		jmp lbd96
					;bc9e
lbc9e
		lda src_current_line_length
		bne +
lbca3
		jmp lbd96
+					;bca6
		bit src_current_line_flags
		bpl +
		bvc lbcea
+		bit somestuff
		bpl lbcb9
		bvc lbca3
		ldx #ERROR.BAD_LINE
		jmp normal_error	;bad line
					;bcb9
lbcb9
		jsr get_byte_from_compile_buff
		and #%01110000
		cmp #$30		;"0"
		bne lbcdb
		dec label_on_this_line_flag
		lda mb45d
		and #%00000111
		sta label_number+1
		jsr get_byte_from_compile_buff
		sta label_number
		bit src_current_line_flags
		bmi lbcea
		jmp lbcde
					;bcdb
lbcdb
		dec mb45c
lbcde
		jsr get_byte_from_compile_buff
		tax
		bmi +
		jsr lbfc6
+		jmp lbd93
					;bcea
lbcea
		jsr get_byte_from_compile_buff
		sta opcode
		jsr get_opcode_length
		sta opcode_length
		cmp #1
		beq lbd6d
		stx opcode_mode
		cmp #2
		bne lbd06
		bit pass
		bmi lbd6d
lbd06
		jsr evaluate_undefined
		lda opcode_length
		cmp #2
		bne lbd49
		lda opcode_mode
		cmp #9
		beq +
		lda result+1
		beq lbd6d
		jmp lc168
					;bd1f
+
		bit pass
		bmi lbd6d
		lda result
		sec
		sbc current_address
		pha
		lda result+1
		sbc current_address+1
		tay
		clc
		pla
		adc #$7e		;126
		bcs +
		dey
+		iny
		bne lbd44
		sec
		sbc #$80		;128
		sta result
		jmp lbd6d
					;bd44
lbd44
		ldx #ERROR.BRANCH_RANGE
		jmp normal_error	;branch out of range
					;bd49
lbd49
		lda result+1
		bne lbd6d
		lda opcode
		and #%00000100
		beq lbd6d
		lda opcode
		cmp #$4c		;jmp
		beq lbd6d
		cmp #$6c		;jmp ()
		beq lbd6d
		bit long_flag
		bmi lbd6d
		and #%11110111
		sta opcode
		dec opcode_length
lbd6d
		ldx opcode_length
		stx length_of_comp_instr
		bit pass
		bmi lbd93
		lda opcode
		sta opcode_buf
		dex
		beq lbd93
		lda result
		sta opcode_buf+1
		dex
		beq lbd93
		lda result+1
		sta opcode_buf+2
		jmp lbd96
					;bd93
lbd93
		jsr update_label_on_this_line
lbd96
		ldx mb42d
		txs
		rts
					;bd9b
;---------------
update_label_on_this_line
		bit label_on_this_line_flag
		bpl lbdf1_rts
		lda current_address
		ldx current_address+1
;---------------
update_label_ax
		bit pass
		bpl lbdf1_rts
		sta label_value
		stx label_value+1
		lda #0
		sta label_on_this_line_flag
		lda block_level
		beq +
		jmp lc8b5
+					;bdbc
		lda $1
		pha
		sei
		lda #$35
		sta $1
		lda label_number
		asl
		sta pmemory_put
		lda label_number+1
		rol
		adc #>label_value_store
		sta pmemory_put+1
		ldy #0
		lda (pmemory_put),y
		iny
		and (pmemory_put),y
		cmp #$ff		;255
		pla
		sta $1
		cli
		bcc lbdf2
		txa
		sta (pmemory_put),y
		dey
		lda label_value
		sta (pmemory_put),y
lbdf1_rts
		rts
					;bdf2
lbdf2		ldx #ERROR.DOUBLE_DEFINED
		gne normal_error	;double defined
					;bdfb
fatal_error
		lda #$ff		;255
		.byte $2c		;bit
;---------------
normal_error
		lda #0
		sta fatal_flag
		stx error_number
		inc error_count
		bne +
		inc error_count+1
+		lda #0
		sta length_of_comp_instr
		jsr compile_add_byte
		jsr print_stars
		lda #<compile_errors
		ldy #>compile_errors
		sta p39
		sty p39+1
lbe21
		ldy #$ff		;255
		dec error_number
		beq lbe3a
lbe28
		iny
		lda (p39),y
		bpl lbe28
		sec
		tya
		adc p39
		sta p39
		bcc +
		inc p39+1
+		jmp lbe21
					;be3a
lbe3a
		ldy #0
lbe3c
		lda (p39),y
		iny
		pha
		and #%01111111
		jsr print_to_screen_and_other
		pla
		bpl lbe3c
		jsr print_stars
		lda #$0d		;13
		jsr print_to_screen_and_other
		lda fatal_flag
		beq lbe5f
		jsr print_immediate
		.null "fATAL "
lbe5f
		jsr print_immediate
		.null "ERROR IN LINE "
		lda current_line
		ldy current_line+1
		jsr print_dec
		jsr print_immediate
		.null ":",$8d
		jsr print_line
		dec mb42e
		lda fatal_flag
		bne +
		jmp lbd96
+					;be8e
		jmp lb61d
					;be91
;---------------
print_stars
		jsr print_immediate
		.null " *** "
		rts

ERROR		.block
DOUBLE_DEFINED	= 1
UNDEFINED	= 2
TOO_LARGE	= 3
BRANCH_RANGE	= 4
BAD_LINE	= 5
NO_DEVICE	= 6
NOT_ON_INCLUDE	= 7
ILLEGAL_CODES	= 8
MACROS_FULL	= 9
ILLEGAL_PARAM	= 10
ENDM_NO_MACRO	= 11
TOO_MANY_BLOCKS = 12
BEND_NO_BLOCK	= 13
BLOCK_OPEN	= 14
NOT_ON_CALL	= 15
LABEL_TYPE	= 16
PHASE_ERROR	= 17
GOTO_FORWARD	= 18
UNSOLVED	= 19
		.bend
					;be9b
compile_errors
		.shift "dOUBLE DEFINED"	;1
		.shift "uNDEFINED STATEMENT";2
		.shift "iLLEGAL QUANTITY";3
		.shift "bRANCH OUT OF RANGE";4
		.shift "bAD LINE"	;5
		.shift "dEVICE NOT PRESENT";6
		.shift "iLLEGAL WHILE INCLUDING";7
		.shift "iLLEGAL CODES"	;8
		.shift "mACROSTACK FULL" ;9
		.shift "iLLEGAL PARAMETER CALL";10
		.shift "eNDM WITHOUT MACRO";11
		.shift "tOO MANY BLOCKS" ;12
		.shift "bEND WITHOUT BLOCK";13
		.shift "bLOCK OPEN"	;14
		.shift "iLLEGAL WHILE CALLING";15
		.shift "lABEL TYPE"	;16
		.shift "pHASE ERROR"	;17
		.shift "gOTO FORWARD"	;18
		.shift "cONDITION UNSOLVED";19
;---------------
lbfc6
		cmp #$20		;" "
		blt lbfcf
		ldx #ERROR.ILLEGAL_CODES
		jmp fatal_error		;illegal code
					;bfcf
lbfcf
		asl
		tax
		lda dir_table-1,x
		pha
		lda dir_table-2,x
		pha
		rts
					;bfda
dir_table	.rta dir_offs
		.rta dir_text
		.rta dir_byte
		.rta dir_word
		.rta dir_equal
		.rta dir_star
		.rta dir_macro
		.rta dir_endm
		.rta dir_hash
		.rta dir_ifne
		.rta dir_endif
		.rta dir_block
		.rta dir_bend
		.rta dir_pron
		.rta dir_proff
		.rta dir_include
		.rta dir_end
		.rta dir_eor
		.rta dir_lbl
		.rta dir_var
		.rta dir_hidemac
		.rta dir_showmac
		.rta dir_shift
		.rta dir_ifpl
		.rta dir_ifmi
		.rta dir_ifeq
		.rta dir_ifne
		.rta dir_rta
		.rta dir_null
		.rta dir_segment
		.rta dir_goto
;---------------
dir_hidemac
		lda #0
                .byte $2c
;---------------
dir_showmac
		lda #$ff		;255
		sta showmac_flag
		rts
					;c024
;---------------
dir_ifmi
		jsr lc053
		lda result+1
		bpl lc04d
		rts
					;c02d
;---------------
dir_ifpl
		jsr lc053
		lda result+1
		bmi lc04d
		rts
					;c036
;---------------
dir_ifeq
		jsr lc053
		lda result
		ora result+1
		bne lc04d
		rts
					;c042
;---------------
dir_ifne
		jsr lc053
		lda result
		ora result+1
		bne lc052_rts
lc04d
		lda #1
		sta skip_compile_of_code_flag
lc052_rts
		rts
					;c053
;---------------
lc053
		jsr evaluate_expression
		bit undefined_statement_flag
		bpl dir_endif
		ldx #ERROR.UNDEFINED
		jmp fatal_error		;undefined statement
					;c060
dir_endif
		rts
					;c061
;---------------
dir_pron
		lda mb437
                .byte $2c
;---------------
dir_proff
		lda #0
		sta mode_print_on
		rts
					;c06e
tc06e
		.text ",SEQ"
;---------------
dir_include
		lda mode_include
		beq lc07c
		ldx #ERROR.NOT_ON_INCLUDE
		jmp fatal_error		;illegal while including
					;c07c
lc07c
		dec mode_include
		jsr check_device_present
		beq +
		ldx #ERROR.NO_DEVICE
		jmp fatal_error

+		jsr get_byte_from_compile_buff
		clc
		adc mb45c
		tax
		ldy #0
lc08c
		lda tc06e,y
		sta somestuff,x
		inx
		iny
		cpy #4
		bne lc08c
		lda #6
		ldx $ba
		ldy #0
		jsr $ffba
		clc
		lda #<somestuff
		adc mb45c
		tax
		lda #>somestuff		;180
		adc #0
		tay
		lda mb45d
		adc #4
		jsr $ffbd
		jsr $ffc0
		jsr print_line
		lda source_p
		sta mb435
		lda source_p+1
		sta mb436
		lda #$29		;")"
		sta source_p
		lda #2
		sta source_p+1
                .comment
		jmp lc0f4
					;c0d4
		ldx #6
		jsr $ffc6
lc0d9
		jsr $ffcf
		ldx $90
		stx mb433
		jsr $ffd2
		lda mb433
		beq lc0d9
		lda #6
		jsr $ffc3
		jsr $ffcc
                jsr lb5af
lc0f4
		.endc
		dec mb42e
		rts
					;c0f8
;---------------
dir_end
		lda mode_include
		beq lc102
		ldx #ERROR.NOT_ON_INCLUDE
		jmp fatal_error		;illegal while including
					;c102
lc102
		dec mb42f
		rts
					;c106
;---------------
dir_offs
		jsr evaluate_undefined
		lda result
		sta offset
		lda result+1
		sta offset+1
		rts
					;c116
;---------------
dir_text
		jsr get_byte_from_compile_buff
		tax
lc11a
		jsr get_byte_from_compile_buff
		jsr compile_add_byte
		dex
		bne lc11a
		rts
					;c124
;---------------
dir_null
		jsr get_byte_from_compile_buff
		tax
lc128
		jsr get_byte_from_compile_buff
		jsr compile_add_byte
		dex
		bne lc128
		lda #0
		jmp compile_add_byte
					;c136
;---------------
dir_shift
		jsr get_byte_from_compile_buff
		tax
		dex
		beq lc146
lc13d
		jsr get_byte_from_compile_buff
                and #$7f
		jsr compile_add_byte
		dex
		bne lc13d
lc146
		jsr get_byte_from_compile_buff
		ora #%10000000
		jmp compile_add_byte
					;c14f
;---------------
dir_byte
		jsr evaluate_undefined
		lda result+1
		bne lc163
		lda result
lc15a
		jsr compile_add_byte
		jsr next_or_exit
		jmp dir_byte
					;c163
lc163
		bit undefined_statement_flag
		bmi lc15a
lc168
		ldx #ERROR.TOO_LARGE
		jmp normal_error	;illegal quantity
					;c16d
;---------------
dir_word
		jsr evaluate_undefined
		lda result
		jsr compile_add_byte
		lda result+1
		jsr compile_add_byte
		jsr next_or_exit
		jmp dir_word
					;c182
;---------------
dir_rta
		jsr evaluate_undefined
		sec
		lda result
		sbc #1
		php
		jsr compile_add_byte
		plp
		lda result+1
		sbc #0
		jsr compile_add_byte
		jsr next_or_exit
		jmp dir_rta
					;c19e
;---------------
dir_equal
		lda pass
		beq lc1af_rts
		jsr lc053
		lda result
		ldx result+1
		jmp update_label_ax
					;c1af
lc1af_rts
		rts
					;c1b0
;---------------
dir_star
		jsr update_label_on_this_line
		jsr evaluate_expression
		lda pass
		bne lc1e4
		lda mode_compile_to_file
		beq lc1e4
		ldx #1
		jsr $ffc9
dir_star_lp
		lda current_address
		cmp result
		lda current_address+1
		sbc result+1
		bge ses

		lda #0
		jsr $ffd2               ;ciout
		inc current_address
		bne dir_star_lp
		inc current_address+1
		jmp dir_star_lp

ses     	jsr $ffcc
					;c1e4
lc1e4
		lda result
		sta current_address
		lda result+1
		sta current_address+1
		rts
					;c1ef
;---------------
lc1ef
		ldx #ERROR.UNDEFINED
		jmp normal_error	;undefined statement
					;c1f4
;---------------
evaluate_undefined
		jsr evaluate_expression
		bit undefined_statement_flag
		bmi +
-		rts

+		lda #$44		;"D"
		sta result+1
		bit pass
		bmi -
		gpl lc1ef
					;c20a
;---------------
evaluate_expression
		lda #0
		sta long_flag
		sta undefined_statement_flag
		jsr get_byte_from_compile_buff
		cmp #$44		;> operator
		beq lc21d
		cmp #$45		;< operator
		bne lc223
lc21d
		sta long_flag
		gcs lc22a
					;c223
lc223
		cmp #$46		;! operator
		bne lc22d
		dec long_flag		;for long
lc22a
		inc mb45c
lc22d
		dec mb45c
		jsr lc261
		lda long_flag
		beq lc250_rts
		bmi lc250_rts
		cmp #$45		;< operator
		beq +
		lda result+1
		sta result
+		lda #0
		sta result+1
lc250_rts
		rts

					;c251
lc251
		dec end_of_expr_flag
lc254
		lda result
		sta argument
		lda result+1
		sta argument+1
		rts
					;c261
;---------------
lc261
		jsr get_argument
		lda argument
		sta result
		lda argument+1
		sta result+1
		lda end_of_expr_flag
		bne lc250_rts
lc275
		jsr get_byte_from_compile_buff
		cmp #$4b		;) operator
		beq lc254
		cmp #$5b		;) operator
		beq lc251
		sta current_operator
		jsr get_argument
		jsr expr_add
		lda end_of_expr_flag
		bne lc250_rts
		geq lc275
					;c291
;---------------

expr_add	lda current_operator
		and #%1111
		tax
		bne expr_sub
		clc
		lda result
		adc argument
		sta result
		lda result+1
		adc argument+1
		sta result+1
		rts

expr_sub	dex
		bne expr_mul
		sec
		lda result
		sbc argument
		sta result
		lda result+1
		sbc argument+1
		sta result+1
		rts

expr_mul	dex
		bne expr_div
		lda result
		sta muldiv_tmp
		lda result+1
		sta muldiv_tmp+1
		lda #0
		sta result
		sta result+1

		ldx #16
-		lsr argument+1
		ror argument
		bcc +
		clc
		lda muldiv_tmp
		adc result
		sta result
		lda muldiv_tmp+1
		adc result+1
		sta result+1
		bcc +
		jmp lc168
+
		asl muldiv_tmp
		rol muldiv_tmp+1
		dex
		bne -
lc306_rts
		rts

expr_div
		dex
		bne expr_and
;---------------
lc30a
		lda #0
		sta muldiv_tmp
		sta muldiv_tmp+1
		ldx #16
		clc
-
		rol result
		rol result+1
		dex
		bmi lc306_rts
		rol muldiv_tmp
		rol muldiv_tmp+1
		sec
		lda muldiv_tmp
		sbc argument
		tay
		lda muldiv_tmp+1
		sbc argument+1
		blt -
		sta muldiv_tmp+1
		sty muldiv_tmp
		gcs -

expr_and	lda result
		dex
		dex
		dex
		dex
		bne expr_or
		and argument
		sta result
		lda result+1
		and argument+1
		sta result+1
		rts

expr_or		dex
		bne expr_xor
		ora argument
		sta result
		lda result+1
		ora argument+1
		sta result+1
		rts

expr_xor	eor argument
		sta result
		lda result+1
		eor argument+1
		sta result+1
		rts

get_label
		txa
		and #%00000111
		sta label_lookup+1
		jsr get_byte_from_compile_buff
		sta label_lookup
		lda block_level
		beq lc398
		jsr lc7b2
		lda mb453
		beq lc398
		rts
					;c398
;---------------
lc398
		lda label_lookup+1
		and #%00000111
		asl
		adc #>label_value_store
		sta p39+1
		lda label_lookup
		asl
		sta p39
		bcc +
		inc p39+1
+		lda $1
		pha
		sei
		lda #$35
		sta $1
		ldy #0
		lda (p39),y
		sta argument
		iny
		lda (p39),y
		sta argument+1
		pla
		sta $1
		cli
		lda argument
		and argument+1
		cmp #$ff		;255
		bne lc3dc_rts
		jsr lc7b2
		lda mb453
		cmp #$ff		;255
		beq lc3dc_rts
		dec undefined_statement_flag
lc3dc_rts
		rts
					;c3dd
get_star
		lda current_address
		sta argument
		lda current_address+1
		sta argument+1
		rts
					;c3e8
get_macroparam
		jsr get_byte_from_compile_buff
;---------------
lc3eb
		sec
		sbc #"0"
		cmp macro_paramlen
		beq +
		blt +
		ldx #ERROR.ILLEGAL_PARAM
		jmp normal_error	;illegal parameter call
					;c3fa
+
		asl
		clc
		adc mb445
		tay
		lda (macro_param_p),y
		sta argument+1
		iny
		lda (macro_param_p),y
		sta argument
		rts
					;c40c
;---------------
get_argument
		jsr get_byte_from_compile_buff
		cmp #$4a		;"J"
		beq sub_expr
		tax
		and #%00001000
		sta end_of_expr_flag
		txa
		and #%00010000
		beq +
		jmp get_label
+					;c421
		txa
		and #%00000111
		cmp #5
		beq get_star
		cmp #7
		beq get_macroparam
		lda #0
		sta argument+1
		jsr get_byte_from_compile_buff
		sta argument
		txa
		and #%00000001
		beq lc442_rts
		jsr get_byte_from_compile_buff
		sta argument+1
lc442_rts
		rts
					;c443
sub_expr
		lda current_operator
		pha
		lda result
		pha
		lda result+1
		pha
		jsr lc261
		pla
		sta result+1
		pla
		sta result
		pla
		sta current_operator
		rts
					;c45f
;---------------
print_dec	.proc
		sta decbuf
		sty decbuf+1
		lda #$ff		;255
		sta decflag
		ldx #size(tens)-2
lp
		ldy #"0"
-
		sec
		lda decbuf
		sbc tens,x
		sta dectmp
		lda decbuf+1
		sbc tens+1,x
		blt +
		sta decbuf+1
		lda dectmp
		sta decbuf
		iny
		bne -
+
		tya
		cmp #"0"
		bne lc496
		bit decflag
		bmi +
lc496
		jsr $ffd2
		sta decflag
+
		dex
		dex
		bpl lp
		bit decflag
		bpl +
		tya
		jmp $ffd2
					;c4a9
+		rts
		.pend
					;c4aa
unique_opcodes	.block
		.byte $90,$b0,$f0,$30,$d0,$10,$50,$70
		.byte $00,$18,$d8,$58,$b8,$ca,$88,$e8
		.byte $c8,$ea,$48,$08,$68,$28,$40,$60
		.byte $aa,$a8,$ba,$8a,$9a,$98,$38,$f8
		.byte $20,$78,$ab,$0b,$2b,$cb,$9b,$bb
		.byte $4b,$6b,$eb,$9f,$9e,$9c,$8b,$f2
		.byte $fa,$f4,$fc
		.bend

group_opcodes	.block
		.byte $41,$81,$e1,$22,$01,$42,$a0,$a2
		.byte $a1,$c1,$02,$21,$61,$4c,$84,$86
		.byte $62,$e6,$c6,$e0,$c0,$24,$83,$c3
		.byte $e3,$23,$a3,$03,$63,$43
		.bend

group_masks	.block
		.byte $e3,$e3,$e3,$e3,$e3,$e3,$e3,$e3
		.byte $e3,$e3,$e3,$e3,$e3,$df,$e7,$e7
		.byte $e3,$e7,$e7,$f3,$f3,$f7,$e3,$e3
		.byte $e3,$e3,$e3,$e3,$e3,$e3
		.bend
;---------------
dir_segment
		lda #$c0		;192
		.byte $2c		;bit
;---------------
dir_macro                                   ;accessed parameter
		lda #$80		;128
		sta macro_type
		lda block_level
		beq lc5a3
		ldx #ERROR.BLOCK_OPEN
		jmp fatal_error		;block open
					;c5a3
lc5a3
		lda mode_macro
		beq lc5ad
		ldx #ERROR.NOT_ON_CALL
		jmp fatal_error		;illegal while calling
					;c5ad
lc5ad
		lda memory_bottom
		ldx memory_bottom+1
		jsr update_label_ax
		dec skip_because_of_macro_flag
		rts
					;c5b8
;---------------
malloc
		sta malloc_length
		sec
		lda memory_bottom
		sbc malloc_length
		sta memory_bottom
		lda memory_bottom+1
		sbc #0
		sta memory_bottom+1
		ldy #0
		lda malloc_length
		ora macro_type
		sta (memory_bottom),y
		iny
		sty malloc_p
		rts
					;c5d8
;---------------
malloc_push
		ldy malloc_p
		inc malloc_p
		sta (memory_bottom),y
		rts
					;c5e1
;---------------
dir_hash
		jsr update_label_on_this_line
		lda #$ff		;255
		sta mb45a
		lda mb443
		sta mb444
		inc mode_macro
		lda mb447
		jsr lc66e
		lda mb446
		jsr lc66e
		jsr lc053
		lda result+1
		sta mb447
		lda result
		sta mb446
		lda #0
		sta mb449
lc612
		ldy mb45c
		cpy src_current_line_length
		beq lc662
		lda somestuff,y
		bmi lc662
		cmp #$4f		;"O"
		bne lc64d
		jsr get_byte_from_compile_buff
		jsr get_byte_from_compile_buff
		ldy #$80		;128
		sty macro_type
		clc
		pha
		adc #1
		jsr malloc
		pla
		tax
lc637
		jsr get_byte_from_compile_buff
		jsr malloc_push
		dex
		bne lc637
		lda memory_bottom+1
		jsr lc66e
		lda memory_bottom
		jsr lc66e
		jmp lc65c
					;c64d
lc64d
		jsr evaluate_undefined
		lda result+1
		jsr lc66e
		lda result
		jsr lc66e
lc65c
		inc mb449
		jmp lc612
					;c662
lc662
		lda mb444
		sta mb445
		lda mb449
		sta macro_paramlen
;---------------
lc66e
		ldy mb443
		sta (macro_param_p),y
		inc mb443
		bne lc67d_rts
		ldx #ERROR.MACROS_FULL
		jmp fatal_error		;macro stack full
					;c67d
lc67d_rts
		rts
					;c67e
;---------------
dir_endm
		lda mode_macro
		bne lc688
		ldx #ERROR.ENDM_NO_MACRO
		jmp fatal_error		;endm without macro
					;c688
lc688
		jsr update_label_on_this_line
		dec mode_macro
		bne lc6a4
		lda #0
		sta mb443
		sta mb444
		sta macro_paramlen
lc69b
		bit mb45b
		bvs +
		jmp dir_bend
+					;c6a3
		rts
					;c6a4
lc6a4
		ldy mb444
		sty mb443
		lda (macro_param_p),y
		sta mb447
		iny
		lda (macro_param_p),y
		sta mb446
		ldy mb443
		dey
		lda (macro_param_p),y
		sta macro_paramlen
		asl
		eor #%11111111
		clc
		adc mb443
		adc #$fd		;253
		sta mb444
		sta mb445
		jmp lc69b
					;c6d0
;---------------
dir_block
		ldy number_of_blocks
		inc number_of_blocks
		bne lc6dd
		ldx #ERROR.TOO_MANY_BLOCKS
		jmp fatal_error		;too many blocks
					;c6dd
lc6dd
		lda number_of_blocks
		sta actual_block
		inc block_level
		lda block_level
		sta (p47),y
		lda #$ff		;255
		sta (p45),y
		rts
					;c6f0
;---------------
dir_bend
		lda block_level
		bne lc776
		ldx #ERROR.BEND_NO_BLOCK
		jmp fatal_error		;bend without block
					;c776
lc776
		jsr update_label_on_this_line
		dec block_level
		beq lc7ac
		lda block_level
		sta mb44f
		jsr lb97a
		lda #0
		sta actual_block
		ldy number_of_blocks
lc78f
		dey
		lda (p47),y
		cmp mb44f
		bne lc7a8
		cpy actual_block
		blt lc7a1
		iny
		sty actual_block
		dey
lc7a1
		lda #$ff		;255
		sta (p45),y
		dec mb44f
lc7a8
		tya
		bne lc78f
		rts
					;c7ac
lc7ac
		jmp lb97a
					;c7af
;---------------
lc7b2
		lda #0
		sta mb476
		lda #0
		sta mb453
		lda memory_bottom+1
		sta p4b+1
		lda memory_bottom
		sta p4b
lc7c4
		ldy #0
		lda (p4b),y
		cmp #6
		bne lc81a
		ldy #2
		lda (p4b),y
		cmp label_lookup
		bne lc81a
		iny
		lda (p4b),y
		cmp label_lookup+1
		bne lc81a
		ldy #1
		lda (p4b),y
		cmp #$ff		;255
		beq lc802
		bit mb476
		bpl lc7ef
		ldx #ERROR.LABEL_TYPE
		jmp normal_error	;label type
					;c7ef
lc7ef
		tay
		dey
		lda (p45),y
		beq lc81a
		lda (p47),y
		cmp mb453
		blt lc81a
		sta mb453
		jmp lc805
					;c802
lc802
		sta mb453
lc805
		ldy #4
		lda (p4b),y
		sta argument
		iny
		lda (p4b),y
		sta argument+1
		lda mb453
		cmp block_level
		bge lc822_rts
lc81a
		jsr lc823
		bcs lc822_rts
		jmp lc7c4
					;c822
lc822_rts
		rts
					;c823
;---------------
lc823
		ldy #0
		lda (p4b),y
		and #%00111111
		clc
		adc p4b
		sta p4b
		bcc +
		inc p4b+1
+		cmp p47
		lda p4b+1
		sbc p47+1
		rts
					;c839
lc8b5
		lda label_number
		sta label_lookup
		lda label_number+1
		sta label_lookup+1
		jsr lc7b2
		lda mb453
		cmp block_level
		bne lc8d1
		ldx #ERROR.DOUBLE_DEFINED
		jmp normal_error	;double defined
					;c8d1
lc8d1
		lda #0
		sta macro_type
		lda #6
		jsr malloc
		lda actual_block
		jsr malloc_push
		lda label_number
		jsr malloc_push
		lda label_number+1
		jsr malloc_push
		lda label_value
		jsr malloc_push
		lda label_value+1
		jmp malloc_push
					;c8f9
;---------------
dir_var
		jsr lc053
		lda #0
		sta label_on_this_line_flag
		sta mb453
		lda label_number
		sta label_lookup
		lda label_number+1
		sta label_lookup+1
		jsr lc398
		lda undefined_statement_flag
		bne lc932
		lda mb453
		cmp #$ff		;255
		beq lc924
		ldx #ERROR.LABEL_TYPE
		jmp fatal_error		;label type
					;c924
lc924
		ldy #4
		lda result
		sta (p4b),y
		iny
		lda result+1
		sta (p4b),y
		rts
					;c932
lc932
		lda #0
		sta macro_type
		lda #6
		jsr malloc
		lda #$ff		;255
		jsr malloc_push
		lda label_number
		jsr malloc_push
		lda label_number+1
		jsr malloc_push
		lda result
		jsr malloc_push
		lda result+1
		jmp malloc_push
					;c959
;---------------
dir_lbl
		lda mode_macro
		beq lc963
		ldx #ERROR.NOT_ON_CALL
		jmp fatal_error		;illegal while calling
					;c963
lc963
		lda mode_include
		beq lc96d
		ldx #ERROR.NOT_ON_INCLUDE
		jmp normal_error	;illegal while including
					;c96d
lc96d
		lda pass
		beq lc97c_rts
		lda current_line
		ldx current_line+1
		jmp update_label_ax
					;c97b
lc97c_rts
		rts
					;c97d
;---------------
dir_goto
		jsr lc053
		lda result+1
		sta destination_line+1
		lda result
		sta destination_line
		cmp current_line
		lda result+1
		sbc current_line+1
		blt lc99c
		ldx #ERROR.GOTO_FORWARD
		jmp fatal_error		;goto forward
					;c99c
lc99c
		jmp jump_on_line
					;c99f
;---------------
dir_eor
		bit pass
		bmi lc9b7_rts
		jsr evaluate_undefined
		lda result+1
		beq lc9b1
		ldx #ERROR.TOO_LARGE
		jsr normal_error	;illegal quantity
lc9b1
		lda result
		sta eor_char_at+1
lc9b7_rts
		rts
;---------------
first           lda $ba
		cmp #8
                bcc nk
                cmp #30
                bcc jo
nk		lda #8
jo		sta drivenum_at+1
		ldx #29
sd              lda $316,x
                sta oldvectors,x
                dex
                bpl sd
		ldx #11
sd2             lda $300,x
                sta oldvectors2,x
                dex
                bpl sd2
		ldx currect_color_set
		lda border_colors,x
		sta $d020
		lda paper_colors,x
		sta $d021
		lda #<clrtxt		;206
		sta p39
		lda #>clrtxt		;202
		sta p39+1
		jsr l86b0
		ldx currect_color_set
		lda message_colors,x
		sta line_color
		ldx #$17		;23
		jsr l85c9
		lda #$14		;20
		jsr l9316
		cmp #$59		;"Y"
		bne lcab3
		lda #$4c		;"L"
		sta mcacb
		lda #8
		sta lcaa2+2
		sei
		ldy #0
		tya
lcaa2                                   ;accessed parameter
		sta $800,y
		iny
		bne lcaa2
		inc lcaa2+2
		bpl lcaa2
		cli
lcab3
		lda #$2c
                sta first_at
mcacb
		rts
					;cacc
		.word l83a7
clrtxt
		.text $63,"LEAR MEMORY (Y/N)?",$a0

reset_vectors_install_334
		php
		sei
                jsr check_ide64
		lda #<$ea31
                sta $314
		lda #>$ea31
                sta $315
                ldx #29
sds             lda $fd32,x
		bcc nonei
		lda oldvectors,x
nonei           sta $316,x
                dex
                bpl sds
		lda drivenum_at+1
		sta $ba
		plp
		rts

check_ide64     lda $df09
                cmp $df09
                bne good
		cmp #$78
                beq none

good            lda $de60
                cmp #"I"
                bne none
                lda $de61
                cmp #"D"
                bne none
                lda $de62
                cmp #"E"
                bne none
                rts
none		clc
		rts

;---------------
irq_normal
		lda #0
		sta $d418
		ldy $28b
		cpy #3
		blt +
		dec $28b
+		lda 198
		pha
		jsr $ea87
		pla
		cmp 198
		beq l808e
		lda #$0f		;15
		sta $d418
l808e
		jmp $ea7e
					;80d8

oldvectors	.fill 30
oldvectors2	.fill 12

		.if *>$cb00
                .error
                .fi
