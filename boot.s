; Calling convention: 
;   - Functions preserve: bx, si, di, bp, sp
;   - Scratch registers: ax, cx, dx


[bits 16]	; Tells the assembler that its a 16 bit code
[org 0x7C00]	; Origin, tell the assembler that where the code will
	; be in memory after it is been loaded

; Enable A20 gate.
in al, 0x92
or al, 2
out 0x92, al


mov bx, msg_a20_enabled
mov si, msg_a20_enabled_len
call puts

; Detect low memory.
clc
int 0x12
jc low_mem_err
; ax contains the amount of low memory.
mov bx, ax
call put_u16

mov bx, '.'
call putc

; Detect upper memory.
clc
mov ax, 0
mov es, ax
mov ebx, 0 ; Clear.
mov edx, 0x534D4150 ; Magic number.
mov ecx, 24 ; Magic number.
%define START_KERNEL_MEM 0x7c00+512
mov di, START_KERNEL_MEM
mov eax, 0xe820
int 0x15
jc upper_mem_err

mov bx, [es:di]
call put_u16
mov bx, '-'
call putc

add di, 16
mov bx, [es:di]
call put_u16
mov bx, '-'
call putc

add di, 16
mov bx, [es:di]
call put_u16
mov bx, '-'
call putc

add di, 16
mov bx, [es:di]
call put_u16

mov bx, '_'
call putc

add di, 16
mov bx, [es:di]
call put_u16
mov bx, '-'
call putc

add di, 16
mov bx, [es:di]
call put_u16
mov bx, '-'
call putc

add di, 16
mov bx, [es:di]
call put_u16
mov bx, '-'
call putc

add di, 16
mov bx, [es:di]
call put_u16

jmp $ 		;Infinite loop, hang it here.


low_mem_err:
	mov bx, msg_low_mem_err
	mov si, msg_low_mem_err_len
	hlt

upper_mem_err:
	mov bx, msg_upper_mem_err
	mov si, msg_upper_mem_err_len
	hlt

; IN: 
; - bx: c
putc:	; Procedure to print character on screen
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
puts:
	.loop:
		cmp si, 0
		jz .end
	  

		; > Valid 16-bit addresses consist of an optional offset, an optional base register (bx or bp), and an optional index register (si or di). That's it! "[sp]" is not on that list.
		mov dx, bx
		mov bx, [bx]
		call putc
	  mov bx, dx
		inc bx
	  dec si

	jmp .loop

.end:
	ret

; IN:
; - bx: n
put_u16:
	mov ax, bx
	; bp ---- bx --- bp-16
	; bx = bp - len 
	; len = bp - bx
	mov bx, scratch ; buf
	add bx, 16

	.loop:
		cmp ax, 0 ; `while (n!=0) {...}`
		jz .end

		xor dx, dx ; Reset dx (remainder).
		mov cx, 10 ; Divisor.
		div cx; / n/=10, dx = remainder.

		add dx, '0' ; Convert to ASCII code.
		
		dec bx
		mov [bx], dl

		jmp .loop

.end:
	; len
	mov si, scratch
	add si, 16
	sub si, bx

	call puts

	ret


; Data.
msg_a20_enabled db "A20 enabled."
msg_a20_enabled_len equ $ - msg_a20_enabled

msg_low_mem_err db "Error detecting low memory."
msg_low_mem_err_len equ $ - msg_low_mem_err

msg_upper_mem_err db "Error detecting upper memory."
msg_upper_mem_err_len equ $ - msg_upper_mem_err

scratch: db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 

times 510 - ($ - $$) db 0	; Fill the rest of sector with 0
dw 0xAA55			; Add boot signature at the end of bootloader
