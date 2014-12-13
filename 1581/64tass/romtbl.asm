; command tables and information
cmdtbb   .word    fstrd          ; fast read drv #0             -  0000
	 .word    ndkrd          ; fast read drv #1             -  0001
	 .word    fstwrt         ; fast write drv #0            -  0010
	 .word    ndkwrt         ; fast write drv #1            -  0011
	 .word    fstsek         ; seek disk drv #0             -  0100
	 .word    ndkrd          ; seek disk drv #1             -  0101
	 .word    fstfmt         ; format disk drv #0           -  0110
	 .word    fstfmt         ; format disk drv #1           -  0111
	 .word    cpmint         ; interleave disk drv #0       -  1000
	 .word    cpmint         ; interleave disk drv #1       -  1001
	 .word    querdk         ; query disk format            -  1010
	 .word    ndkrd          ; seek disk drv #1             -  1011
	 .word    inqst          ; return disk status           -  1100
	 .word    ndkrd          ; return disk status           -  1101
	 .word    duplc1         ; backup drv0 to drv1          -  1110
	 .word    duplc1         ; backup drv1 to drv0          -  1111
	 .word    fstrd          ; fast read drv #0             -1 0000
	 .word    ndkrd          ; fast read drv #1             -1 0001
	 .word    fstwrt         ; fast write drv #0            -1 0010
	 .word    ndkwrt         ; fast write drv #1            -1 0011
	 .word    fstsek         ; seek disk drv #0             -1 0100
	 .word    ndkrd          ; seek disk drv #1             -1 0101
	 .word    fstfmt         ; format disk drv #0           -1 0110
	 .word    fstfmt         ; format disk drv #1           -1 0111
	 .word    unused
	 .word    unused
	 .word    querdk         ; query disk format            -1 1010
	 .word    ndkrd          ; seek disk drv #1             -1 1011
	 .word    dumpbuf        ; dump track cache buffer      -1 1100
	 .word    dumpbuf        ; dump track cache buffer      -1 1101
	 .word    chgutl         ; utility                      -1 1110
	 .word    fstload        ; fast load utility            -1 1111
bamsiz   .byte  6        ; # bytes/track in bam
dsknam   .byte  4        ; offset of dsk name in bam sec
;   command search table
cmdtbl   .text  'VI/MBUP&CRSN'
; validate-dir init-drive duplicate
; memory-op block-op user
; position dskcpy utlodr rename scratch new
ncmds    =*-cmdtbl
;  jump table low
cjumpl  .byte     <jverdir,<jintdrv,<jpart
	.byte     <jmem,<jblock,<juser
	.byte     <jrecord
	.byte     <jutlodr
	.byte     <jdskcpy
	.byte     <jrename,<jscrtch,<jnew
cjumph  .byte     >jverdir,>jintdrv,>jpart
	.byte     >jmem,>jblock,>juser
	.byte     >jrecord
	.byte     >jutlodr
	.byte     >jdskcpy
	.byte     >jrename,>jscrtch,>jnew
val=0                           ; validate (verify) cmd #
pcmd     =9                     ; images for cmds
	.byte     %01010001      ; dskcpy
struct   =*-pcmd                ; cmds not parsed
	.byte     %11011101      ; rename
	.byte     %00011100      ; scratch
	.byte     %10011110      ; new
ldcmd    =*-struct              ; load cmd image
	.byte     %00011100      ; load
;            pgdrpgdr
;            fs1 fs2
;   bit reps:  not pattern
;              not greater than one file
;              not default drive(s)
;              required filename
modlst   .text  'RWAM'           ; mode table
nmodes   =*-modlst
tplst    .text  'DSPULC'         ; file type table
typlst   .text  'DSPURC'         ; del,seq,prog,user,rel,cbm
ntypes   =*-typlst
tp1lst   .text  'EERSEB'
tp2lst   .text  'LQGRLM'
er00     .byte  0                ; err flg vars for bit
er0      .byte  $3f
er1      .byte  $7f
er2      .byte  $bf
er3      .byte  $ff
offset   .byte  1,$ff,$ff,1,0    ; for recovery
