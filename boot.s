; Calling convention: 
;   - Functions preserve: bx, si, di, bp, sp
;   - Scratch registers: ax, cx, dx


[bits 16]	; Tells the assembler that its a 16 bit code
[org 0x7C00]	; Origin, tell the assembler that where the code will
	; be in memory after it is been loaded

mov ax, 0
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00
;mv bp, sp

;mov bx, hello_world
;mov si, [hello_world_len]
;call puts

mov bx, 98
call put_u16

jmp $ 		;Infinite loop, hang it here.


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
		or si, si
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
hello_world db "hello, world!"
hello_world_len dw 13

scratch: db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 

times 510 - ($ - $$) db 0	; Fill the rest of sector with 0
dw 0xAA55			; Add boot signature at the end of bootloader

