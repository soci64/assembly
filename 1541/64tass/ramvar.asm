
*=$0000                 ; zero page
jobs     *=*+6          ; job que=8 last 2 for bams
hdrs     *=*+12         ; job headers
dskid    *=*+4          ; master copy of disk id
header   *=*+6          ; image of last header
wpsw     =$1c;*=*+1          ; write protect change flag
lwpt     =$1e
drvst    =$20;*=*+1          ; lcc var's
                        ; bits 7 6 5 4  3 2 1 0
                        ;
                        ;         -- timeout
                        ;        ---- running
                        ;       ------ stepping
                        ;      -------- accelerating
                        ;
                        ;ie:
                        ;       $00 = no drive active
                        ;       $20 = running
                        ;       $30 = running and timeout
                        ;       $50 = stepping and running
                        ;       $80 = accelerating

drvtrk   =$22;*=*+1
slflag   =$23
stab     =$24
savpnt   =$2e
bufpnt   =$30;*=*+2          ; buffer pointer
hdrpnt   =$32
gcrpnt   =$34
bytcnt   =$36
bid      =$38
hbid     =$39
chksum   =$3a
drive    =$3d
cdrive   =$3e
jobn     =$3f
tracc    =$40
nxtjob   =$41
nxtrk    =$42
sectr    =$43
work     =$44
job      =$45
dbid     =$47
acltim   =$48;*=*+2          ; acceleration/decceleration time delay
savsp    =$49;*=*+1          ; save stack pointer
steps    =$4a
tmp      =$4b;*=*+7
csect    =$4c
nexts    =$4d
nxtbf    =$4e
nxtpnt   =$4f
gcrflg   =$50
ftnum    =$51;*=*+1
btab     =$52
gtab     =$56
as       =$5e
af       =$5f
aclstp   =$60
rsteps   =$61
nxtst    =$62
minstp   =$64
vnmi     =$65;*=*+2          ; indirect for nmi
nmiflg   =$67
autofg   =$68;*=*+1          ; auto init flag
secinc   =$69;*=*+1          ; sector inc for seq
revcnt   =$6a;*=*+1          ; error recovery count
bmpnt    =$6d;*=*+2          ; bit map pointer
usrjmp   =$6b;*=*+2          ; user jmp table ptr
temp     =$6f;*=*+6          ; work space
t0       =temp
t1       =temp+1
t2       =temp+2
t3       =temp+3
t4       =temp+4
ip       =$75;*=*+6          ; indirect ptr variable
lsnadr   =$77;*=*+1          ; listen address
tlkadr   =$78;*=*+1          ; talker address
lsnact   =$79
tlkact   =$7a
adrsed   =$7b
atnpnd   =$7c
prgtrk   =$7e;*=*+1          ; last prog accessed
atnact   =$7d
drvnum   =$7f
track    =$80;*=*+1          ; current track
sector   =$81;*=*+1          ; current sector
lindx    =$82;*=*+1          ; logical index
sa       =$83;*=*+1          ; secondary address
orgsa    =$84;*=*+1          ; original sa
data     =$85;*=*+1          ; temp data byte
r0       =$86;*=*+1
r1       =$87;*=*+1
r2       =$88;*=*+1
r3       =$89;*=*+1
r4       =$8a;*=*+1
result   =$8b;*=*+4
accum    =$8f;*=*+5
dirbuf   =$94;*=*+2
cont     =$98;*=*+1          ; bit counter for ser
buftab   =$99;*=*+cbptr+4    ; buffer byte pntrs
cb       =buftab+cbptr
buf0     =$a7;*=*+mxchns
buf1     =$ae;*=*+mxchns
nbkl     =$b5
recl     =$b5;*=*+mxchns
nbkh     =$bb
rech     =$bb;*=*+mxchns
nr       =$c1;*=*+mxchns
rs       =$c7;*=*+mxchns
ss       =$cd;*=*+mxchns
f1ptr    =$d3;*=*+1          ; file stream 1 pointer
recptr   =$d4;*=*+1
ssnum    =$d5;*=*+1
ssind    =$d6;*=*+1
relptr   =$d7;*=*+1
entsec   =$d8;*=*+mxfils     ; sector of directory entry
entind   =$dd;*=*+mxfils     ; index of directory entry
fildrv   =$e2;*=*+mxfils     ; default flag, drive #
pattyp   =$e7;*=*+mxfils     ; pattern,replace,closed-flags,type
filtyp   =$ec;*=*+mxchns     ; channel file type
chnrdy   =$f2;*=*+mxchns     ; channel status
eoiflg   =$f8;*=*+1          ; temp eoi
jobnum   =$f9;*=*+1          ; current job #
lrutbl   =$fa;*=*+mxchns-1   ; least recently used table
nodrv    =$ff;*=*+1          ; no drive flag
ovrbuf   =$100
dskver   =$101;*=*+1          ; disk version

*=$200
cmdbuf   *=*+cmdlen+1   ; command buffer
cmdnum   *=*+1          ; command #
lintab   =$22b;*=*+maxsa+1    ; sa:lindx table
chndat   =$23e;*=*+mxchns     ; channel data byte
lstchr   =$244;*=*+mxchns     ; channel last char ptr
type     =$24a;*=*+1          ; active file type
strsiz   =$24b;*=*+1
tempsa   =$24c;*=*+1          ; temporary sa
cmd      =$24d;*=*+1          ; temp job command
lstsec   =$24e
bufuse   =$24f;*=*+1          ; buffer allocation
mdirty   =$251
entfnd   =$253;*=*+1          ; dir-entry found flag
dirlst   =$254;*=*+1          ; dir listing flag
cmdwat   =$255;*=*+1          ; command waiting flag
linuse   =$256;*=*+1          ; lindx use word
lbused   =$257;*=*+1          ; last buffer used
rec      =$258;*=*+1
trkss    =$259;*=*+1
secss    =$25a;*=*+1
lstjob   =$25b;*=*+bfcnt+4    ; last job
dsec     =$260;*=*+mxchns     ; sec of dir entry
dind     =$266;*=*+mxchns     ; index of dir entry
erword   =$26c;*=*+1          ; error word for recovery
erled    =$26d
prgdrv   =$26e
prgsec   =$26f;*=*+1          ; last program sector
wlindx   =$270;*=*+1          ; write lindx
nbtemp   =$272;*=*+2          ; # blocks temp
char     =$275;*=*+1          ; char under parser
cmdsiz   =$274;*=*+1          ; command string size
limit    =$276;*=*+1          ; ptr limit in compar
f1cnt    =$277;*=*+1          ; file stream 1 count
f2cnt    =$278;*=*+1          ; file stream 2 count
f2ptr    =$279;*=*+1          ; file stream 2 pointer
filtbl   =$27a;*=*+mxfils+1   ; filename pointer
filtrk   =$280;*=*+mxfils     ; 1st link/track
filsec   =$285;*=*+mxfils     ;    /sector
patflg   =$28a;*=*+1          ; pattern presence flag
image    =$28b;*=*+1          ; file stream image
drvcnt   =$28c;*=*+1          ; number of drv searches
drvflg   =$28d;*=*+1          ; drive search flag
lstdrv   =$28e
found    =$28f;*=*+1          ; found flag in dir searches
dirsec   =$290;*=*+1          ; directory sector
delsec   =$291;*=*+1          ; sector of 1st avail entry
delind   =$292;*=*+1          ; index "
lstbuf   =$293;*=*+1          ; =0 if last block
filcnt   =$295;*=*+1          ; counter, file entries
index    =$294;*=*+1          ; current index in buffer
typflg   =$296;*=*+1          ; match by type flag
mode     =$297;*=*+1          ; active file mode (r,w)
jobrtn   =$298;*=*+1          ; job return flag
eptr     =$299
toff     =$29a
bamis    =$29d
bamlu    =$29b
bami     =$2a1
nambuf   =$2b1;*=*+36         ; directory buffer
errbuf   =$2d5;*=*+36         ; error msg buffer
wbam     =$2f9;*=*+1          ; bam status (0=clean)
ndbl     =$2fa;*=*+1          ; # of disk blocks free
ndbh     =$2fc;*=*+1
phase    =$2fe

bufs     =$300

