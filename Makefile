AS=nasm

boot.bin: boot.s
	$(AS) $^ -f bin -o $@
