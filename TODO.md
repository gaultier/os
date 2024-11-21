- [x] Embed kernel.exe in boot.bin somehow (at build time)
- [x] Copy in bootloader kernel.exe to the right location in memory (at run time)
- [x] Jump at the end of bootloader to `kmain` (parse entrypoint in ELF or the code is in raw binary format)
- [ ] Setup idt
- [x] Setup stack properly before jumping to `kmain`
- [x] Make debugger work
- [ ] Read from kmain the memory mapping information (maybe?)


## Debug

```sh
$ qemu-system-x86_64 -fda boot.bin -s -S
$ gdb kernel.elf -ex 'target remote localhost:1234' -ex 'b kmain' -ex 'c'
``` 

