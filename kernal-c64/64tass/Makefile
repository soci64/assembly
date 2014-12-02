
all: kernal.bin basic.bin

basic.bin: out.bin
	dd if=$< of=$@ bs=4096 skip=0 count=2 status=none

kernal.bin: out.bin
	dd if=$< of=$@ bs=4096 skip=4 count=2 status=none

.INTERMEDIATE: out.bin

out.bin: C64-tass.asm
	64tass -b -a $< -o $@

.PHONY: clean

clean:
	-$(RM) kernal.bin basic.bin out.bin
