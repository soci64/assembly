
1571-rom.310654-05.bin: out.bin crc.py
	./crc.py $< $@

out.bin: serlib.asm addfil.asm addrel.asm bamutl.asm block.asm burst.asm close.asm \
 com.asm copall.asm copset.asm copy.asm dskintsf.asm duplct1.asm \
 duplct.asm equate.asm erproc.asm fastld.asm fastutl.asm fndrel.asm \
 frets.asm gcr10.asm gcr7.asm gcr8.asm gcr9.asm gcrtable.asm getact.asm \
 idlesf.asm iodef.asm irq1541.asm irq1571.asm irq.asm jobssf.asm \
 lccbingc.asm lcccntrl1.asm lcccntrl.asm lccconhd.asm lccend.asm \
 lccfmt1.asm lccfmt2a.asm lccfmt2.asm lccfmt3a.asm lccfmt3.asm \
 lccfmt4a.asm lccfmt4.asm lccgcrbi.asm lccgcrbn.asm lccinit.asm lccio.asm \
 lccread1.asm lccread.asm lccutil1.asm lccutil.asm lccwrt1.asm lccwrt.asm \
 lccseek1.asm lccseek.asm leds.asm lookup.asm lstdir.asm map.asm \
 master.asm memrw.asm mfmcntrl.asm mfmsubr1.asm mfmsubr2.asm mfmsubr3.asm \
 mfmsubr.asm new.asm newss.asm newvec.asm notes.asm nulbuf.asm open.asm \
 opnchnl.asm parsex.asm patch.asm patchn.asm ramvar.asm record.asm \
 rel1.asm rel2.asm rel3.asm rel4.asm rename.asm romsf.asm romtblsf.asm \
 scrtch.asm setdrv.asm sieee1.asm sieee.asm signature.asm ssend.asm \
 sstest.asm ssutil.asm system.asm trnsfr.asm tst2.asm tst3.asm tst4.asm \
 tstflg.asm tstfnd.asm tsutil.asm utl.asm utlodr.asm vects.asm verdir.asm \
 wd1770.asm
	64tass -b $< -o $@

.PHONY: clean

clean:
	-$(RM) 1571-rom.310654-05.bin out.bin

