BOOT := bootloader

.PHONY: all clean qemu

all: clean $(BOOT).bin

$(BOOT).bin: $(BOOT).o
	$(LD) -Ttext=0x7c00 -e _boot --oformat=binary -o $@ $<

qemu: $(BOOT).bin
	qemu-system-x86_64 -drive format=raw,file=./$<

clean:
	rm -f $(BOOT).o $(BOOT).bin
