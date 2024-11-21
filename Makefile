AS=nasm

boot.bin: boot.s kernel.bin kernel.elf
	$(AS) $< -f bin -o $@

kernel.o: kmain.c
	clang --target=x86_64-unknown -ffreestanding -mno-red-zone -g -gsplit-dwarf -nostdlib $< -c -o $@ -O0 

kernel.elf: kernel.o linker.ld
	$(LD) -T linker.ld $< -o $@

kernel.bin: kernel.o linker.ld
	$(LD) -T linker.ld $< -o $@ --strip-all --oformat=binary

run: boot.bin
	qemu-system-x86_64 -fda boot.bin -d int -M smm=off

.PHONY: run
