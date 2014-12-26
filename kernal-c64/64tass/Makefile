
SRC = C64-Lee.asm C64-bas.asm C64-ker.asm C64-var.asm
TARGET = 901226-01.bin 901227-01.bin 901227-02.bin 901227-03.bin
AFLAGS = -b
AS = ./64tass

all: $(TARGET)

901226-01.bin: out1.bin
	dd if=$< of=$@ bs=4096 skip=0 count=2 status=none

901227-01.bin: out1.bin
	dd if=$< of=$@ bs=4096 skip=4 count=2 status=none

901227-02.bin: out2.bin
	dd if=$< of=$@ bs=4096 skip=4 count=2 status=none

901227-03.bin: out3.bin
	dd if=$< of=$@ bs=4096 skip=4 count=2 status=none

.INTERMEDIATE: out1.bin out2.bin out3.bin

out1.bin: $(SRC)
	$(AS) $(AFLAGS) $< -o $@ -DVersion=1

out2.bin: $(SRC)
	$(AS) $(AFLAGS) $< -o $@ -DVersion=2

out3.bin: $(SRC)
	$(AS) $(AFLAGS) $< -o $@ -DVersion=3

.PHONY: clean

clean:
	-$(RM) $(TARGET)
