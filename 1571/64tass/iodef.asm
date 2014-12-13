;i/o definitions

unlsn    =$3f   ; unlisten command
untlk    =$5f   ; untalk command
notrdy   =$0    ; not ready
eoiout   =$80   ; talk with eoi
eoi	 =$08	; eoi
eoisnd   =$08   ; not(eoi) to send
rdytlk   =$88   ; talk no eoi
rdylst   =$1    ; ready to listen
; random chnrdy
rndrdy   =rdytlk+rdylst

; random w/ eoi
rndeoi   =eoiout+rdylst


*=$4000
.comment
; 8520a CIA (Complex Interface Adaptor)

pa	*=*+1          	; port a
side_sel	=bit0	; out
_drv_rdy	=bit1	; in
mtr_on 		=bit2	; out
dev_sel1	=bit3	; in
dev_sel2	=bit4	; in
pwr_led		=bit5	; out
act_led		=bit6	; out
disk_change	=bit7	; in

init_dd_pa	=%01100101
init_prt_pa	=%11111110
.endc
pb	=$1800		; port b
datin		=bit0	; in
datout		=bit1	; out
clkin		=bit2	; in
clkout		=bit3	; out
atna		=bit4	; out
fsdir		=bit1	; out
.comment
wpin		=bit6	; out
atnrd		=bit7	; in

init_dd_pb	=%00111010
init_prt_pb	=%11010101

ddpa	*=*+1		; dd port a
ddpb	*=*+1		; dd port b
tima_l	*=*+1		; timer a used for the baud rate generator
tima_h	*=*+1		; *
timb_l	*=*+1		; timer b used for controller irqs
timb_h	*=*+1		; *

todlsb	*=*+1		; event lsb, used for disk change detector
tod8_15 *=*+1		; event 8-15
todmsb	*=*+1		; event msb
	*=*+1		; unused
.endc
sdr	=$400c		; serial data register
icr     =$400d		; interrupt control register
cra	=$400e		; control register a
.comment
crb	*=*+1		; control register b
.endc
*=$2000
; WD177X MFM Disk Controller Chip

wdcmd
wdstat	*=*+1		; command and status register
wdtrk   *=*+1		; dd port a
wdsec	*=*+1		; sector register
wddat	*=*+1		; data register

ledprt = $1c00
ifr1 = $180d
pa1 = $1801
tima_h = $4005
tima_l = $4004
pota1 = $180f
t1lc1 = $1804
pcr1 = $180c
t1hl1 = $1807
ier1 = $180e
byt_clr = $1c00
acr1 = $180b
ddrb1 = $1802
t1ll1 = $1806
t1hc1 = $1805
ddra1 = $1803
