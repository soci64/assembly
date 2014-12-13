scrub   jsr  gaflgs     ; wr out buf if dirty
        bvc  scr1       ; not dirty

        jsr  wrtout
        jsr  watjob
scr1    rts

setlnk  jsr  set00      ; put trk,sec in buffer
        lda  track
        sta  (dirbuf),y
        iny
        lda  sector
        sta  (dirbuf),y
        jmp  sdirty

getlnk  jsr  set00      ; get link from buffer
        lda  (dirbuf),y ; into trk and sec
        sta  track
        iny
        lda  (dirbuf),y
        sta  sector
        rts

nullnk  jsr  set00      ; set trk link=0 and
        lda  #0         ; link=last non-zero char.
        sta  (dirbuf),y
        iny
        ldx  lindx
        lda  nr,x
        tax
        dex
        txa
        sta  (dirbuf),y
        rts

set00   jsr  getact     ; set pntr to buffer
        asl  a
        tax
        lda  buftab+1,x
        sta  dirbuf+1
        lda  #0
        sta  dirbuf
        ldy  #0
        rts

curblk  jsr  fndrch     ; rd trk,sec from header
gethdr  jsr  getact
        sta  jobnum
        asl  a
        tay
        lda  hdrs,y     ; 4/12
        sta  track
        lda  hdrs+1,y   ; 4/12
        sta  sector
        rts
wrtab   lda  #write     ; wrtab/rdab
        sta  cmd        ; wrtout/rdin
        bne  sj10       ; wrtss/rdss

rdab    lda  #read
        sta  cmd
        bne  sj10

wrtout  lda  #write
        sta  cmd
        bne  sj20

        lda  #read
        sta  cmd
        bne  sj20

wrtss   lda  #write
        sta  cmd
        bne  rds5

rdss    lda  #read
rds5    sta  cmd
        ldx  lindx
        lda  ss,x
        tax
        bpl  sj30

sj10    jsr  sethdr
        jsr  getact
        tax
        lda  drvnum
        sta  lstjob,x
sj20    jsr  cdirty
        jsr  getact
        tax
sj30    jmp  setljb

rdlnk   lda  #0         ; rdlnk
        jsr  setpnt
        jsr  getbyt
        sta  track
        jsr  getbyt
        sta  sector
        rts
