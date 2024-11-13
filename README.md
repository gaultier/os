# Bootloader, OS?


## Build

```sh
$ make run
```

Disassemble:

```sh
$ objdump -M intel,data16  -b binary -D -m i386 boot.bin
```
