
1571-rom.310654-05.bin: out.bin crc.py
	./crc.py $< $@

out.bin: serlib.asm addfil.asm addrel.asm bamutl.asm block.asm close.asm \
 copall.asm copset.asm copy.asm dskintsf.asm duplct.asm equate.asm \
 erproc.asm fndrel.asm frets.asm getact.asm idlesf.asm iodef.asm irq.asm \
 jobssf.asm lccbingc.asm lcccntrl.asm lccconhd.asm lccend.asm \
 lccfmt1.asm lccfmt2.asm lccfmt3.asm lccfmt4.asm lccgcrbi.asm \
 lccinit.asm lccio.asm lccread.asm lccutil.asm lccwrt.asm lccseek.asm \
 leds.asm lookup.asm lstdir.asm map.asm memrw.asm new.asm newss.asm \
 nulbuf.asm open.asm opnchnl.asm parsex.asm patch.asm ramvar.asm \
 record.asm rel1.asm rel2.asm rel3.asm rel4.asm rename.asm romsf.asm \
 romtblsf.asm scrtch.asm setdrv.asm sieee.asm ssend.asm sstest.asm \
 ssutil.asm system.asm trnsfr.asm tst2.asm tst3.asm tst4.asm tstflg.asm \
 tstfnd.asm tsutil.asm utlodr.asm vects.asm verdir.asm 
	64tass -b $< -o $@ -L $@.dasm

.PHONY: clean

clean:
	-$(RM) 1571-rom.310654-05.bin out.bin
