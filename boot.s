; Calling convention: 
;   - Functions preserve: bx, si, di, bp, sp
;   - Scratch registers: ax, cx, dx
[bits 16]	; Tells the assembler that its a 16 bit code
[org 0x7C00]	; Origin, tell the assembler that where the code will
	; be in memory after it is been loaded

%macro print_newline 0
	mov bx, 0x0d
	call print_c
	mov bx, 0x0a
	call print_c
%endmacro

%macro print_upper_mem_entry_u64 0
	%rep 4
		mov bx, [es:di]
		call print_num
		mov bx, '_'
		call print_c
		
		add di, 2
	%endrep

	mov bx, ' '
	call print_c
%endmacro

%macro print_upper_mem_entry_u32 0
	%rep 2
		mov bx, [es:di]
		call print_num
		mov bx, '_'
		call print_c
		
		add di, 2
	%endrep

	mov bx, ' '
	call print_c
%endmacro

%define FREE_SPACE 0x9000


start:
	; Detect upper memory.
	clc
	mov ax, 0
	mov sp, start
	mov ss, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	cld ; TODO

	mov di, FREE_SPACE

	xor ebx, ebx ; Clear bx.

get_upper_mem:
	mov edx, 0x534D4150 ; Magic number: SMAP.
	mov ecx, 24 ; sizeof(entry) (could be 20 if no ACPI3).
	mov eax, 0xe820
	int 0x15
	jc upper_mem_err
	cmp eax, edx ; On success, eax must have been reset to "SMAP".
	jne upper_mem_err

	test ebx, ebx ; End of list (only one entry?)
	je .end
	mov ebp, ebx; Preserve `ebx` for next call.

	; Print real sizeof(entry): probably 20.
	;mov bl, cl
	;call print_num
	;mov bx, ' '
	;call print_c

	;print_upper_mem_entry_u64 ; Address.
	;print_upper_mem_entry_u64 ; Length.
	;print_upper_mem_entry_u32 ; Type.
	;print_newline

	; Next entry for upper memory.
	mov ebx, ebp ; Restore bx.
	jmp get_upper_mem ; Loop.


.end:
	jmp switch_to_long_mode


%include "long_mode_directly.s"
bits 16


; Utilities.

upper_mem_err:
	hlt
	jmp upper_mem_err

; IN: 
; - bx: c
print_c:	; Procedure to print character on screen
	mov al, bl; Save.

	mov ah, 0x0E	; Tell BIOS that we need to print one charater on screen.
	mov bh, 0x00	; Page no.
	mov bl, 0x07	; Text attribute 0x07 is lightgrey font on black background

	int 0x10	; Call video interrupt

	mov bl, al ; Restore.
	ret

; IN:
; - bx: s
; - si: len(s)
print_s:
	.loop:
		cmp si, 0
		jz .end
	  

		; > Valid 16-bit addresses consist of an optional offset, an optional base register (bx or bp), and an optional index register (si or di). That's it! "[sp]" is not on that list.
		mov dx, bx
		mov bx, [bx]
		call print_c
	  mov bx, dx
		inc bx
	  dec si

	jmp .loop

.end:
	ret

; IN:
; - bx: n
print_num:
	mov ax, bx
	; bp ---- bx --- bp-16
	; bx = bp - len 
	; len = bp - bx
	mov bx, scratch ; buf
	add bx, 16

	.loop:
		xor dx, dx ; Reset dx (remainder).
		mov cx, 10 ; Divisor.
		div cx; / n/=10, dx = remainder.

		add dx, '0' ; Convert to ASCII code.
		
		dec bx
		mov [bx], dl

		cmp ax, 0 ; `do {...} while (n!=0)`
		jne .loop

.end:
	; len
	mov si, scratch
	add si, 16
	sub si, bx

	call print_s

	ret


scratch: db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 

; Pad out file.
times 510 - ($-$$) db 0
dw 0xAA55
