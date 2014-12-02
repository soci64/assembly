
all: kernal.bin basic.bin

basic.bin: out.bin
	dd if=$< of=$@ bs=4096 skip=0 count=2 status=none

kernal.bin: out.bin
	dd if=$< of=$@ bs=4096 skip=2 count=2 status=none

.INTERMEDIATE: out.bin

out.bin: C64-xa.a65
	xa -M $< -o $@

.PHONY: clean

clean:
	-$(RM) kernal.bin basic.bin out.bin
