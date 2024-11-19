AS=nasm

boot.bin: boot.s long_mode_directly.s kernel.exe
	$(AS) $< -f bin -o $@

kernel.exe: kmain.c
	clang --target=x86_64-unknown -ffreestanding -mno-red-zone -g -nostdlib $^ -o $@ -e kmain -fuse-ld=lld -T linker.ld -static -Wl,--oformat=binary

run: boot.bin
	qemu-system-x86_64 -fda boot.bin

.PHONY: run


# gdb-remote 1234
# br s -a 0x7c00+0x26
