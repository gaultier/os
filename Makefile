AS=nasm

boot.bin: boot.s
	$(AS) $^ -f bin -o $@

run: boot.bin
	qemu-system-x86_64 -fda boot.bin

.PHONY: run

