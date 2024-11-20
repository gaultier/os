bits 16	
org 0x7C00	; Origin, tell the assembler that where the code will
	; be in memory after it is been loaded

%define FREE_SPACE 0x9000

start:
	; Detect upper memory.
	mov sp, start

  ; Copy kernel.bin right after the boot sector.
	mov ah, 2h    ; int13h function 2
	mov al, 2    ; we want to read 2 sectors (sector size = 512).
	mov ch, 0     ; from cylinder number 0
	mov cl, 2     ; the sector number 2 - second sector (starts from 1, not 0)
	mov dh, 0     ; head number 0
	xor bx, bx    
	mov es, bx    ; es should be 0
	mov bx, 7e00h ; 512bytes from origin address 7c00h
	int 13h


	xor ebx, ebx ; Clear bx.

get_upper_mem:
	mov di, FREE_SPACE
	mov edx, 0x534D4150 ; Magic number: SMAP.
	mov ecx, 24 ; sizeof(entry) (could be 20 if no ACPI3).
	mov eax, 0xe820
	int 0x15
	jc .upper_mem_err
	cmp eax, edx ; On success, eax must have been reset to "SMAP".
	jne .upper_mem_err

	test ebx, ebx ; End of list (only one entry?)
	je .end
	mov ebp, ebx; Preserve `ebx` for next call.

	mov ebx, ebp ; Restore bx.
	jmp get_upper_mem ; Loop to read next entry.

	xor ebp, ebp

.end:
	jmp switch_to_long_mode

.upper_mem_err:
	hlt
	jmp .upper_mem_err

%include "long_mode_directly.s"
bits 16

; Pad out file.
times 510 - ($-$$) db 0
dw 0xAA55

kernel:
incbin "kernel.bin"
