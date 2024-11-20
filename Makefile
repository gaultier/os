AS=nasm

boot.bin: boot.s kernel.bin
	$(AS) $< -f bin -o $@

kernel.bin: kmain.c linker.ld
	clang --target=x86_64-unknown -ffreestanding -mno-red-zone -g -nostdlib $< -o $@ -e kmain  -T linker.ld -static -Wl,--oformat=binary -O0

run: boot.bin
	qemu-system-x86_64 -fda boot.bin -d int -M smm=off

.PHONY: run
