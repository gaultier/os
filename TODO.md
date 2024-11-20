- [x] Embed kernel.exe in boot.bin somehow (at build time)
- [x] Copy in bootloader kernel.exe to the right location in memory (at run time)
- [x] Jump at the end of bootloader to `kmain` (parse entrypoint in ELF or the code is in raw binary format)
- [ ] Setup idt
- [ ] Setup stack properly before jumping to `kmain`
- [ ] Read from kmain the memory mapping information (maybe?)


## Debug

```
kill
gdb-remote 1234
br s -a 0x7e00+512
continue
``` 

