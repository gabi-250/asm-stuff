BOOT := bootloader

.PHONY: all clean qemu

all: clean $(BOOT).bin

$(BOOT).bin: $(BOOT).o
	$(LD) -T linker.ld --oformat=binary -o $@ $<

qemu: $(BOOT).bin
	qemu-system-x86_64 -drive format=raw,file=./$<

clean:
	rm -f $(BOOT).o $(BOOT).bin
