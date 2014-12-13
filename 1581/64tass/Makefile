
1581-rom.318045-01.bin: out.bin crc.py
	./crc.py $< $@

out.bin: serlib.asm addfil.asm addrel.asm bamutl.asm blk.asm burstc.asm close.asm \
 common.asm copy.asm crc.asm dskint.asm dversion.asm equate.asm erproc.asm \
 fastld.asm fndrel.asm formatd.asm frets.asm getact.asm idle.asm iodef.asm \
 irq.asm job.asm lookitup.asm lstdir.asm mapit.asm mcntl.asm memrw.asm \
 mfmmacro.asm mrout.asm msub1.asm msub.asm newdsk.asm newss.asm nulbuf.asm \
 opchnl.asm open.asm parsex.asm part.asm patch.asm ram.asm record.asm \
 rel1.asm rel2.asm rel3.asm rel4.asm relnotes.asm rename.asm romtbl.asm \
 scrtch.asm setdrv.asm sieee.asm signature.asm ssend.asm sstest.asm \
 ssutil.asm system.asm trnsfr.asm tst2.asm tst3.asm tst4.asm tst5.asm \
 tstflg.asm tstfnd.asm tsutil.asm utl.asm utlodr.asm vects.asm verdir.asm
	64tass -b $< -o $@

.PHONY: clean

clean:
	-$(RM) 1581-rom.318045-01.bin out.bin
