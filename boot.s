; Calling convention: 
;   - Functions preserve: bx, si, di, bp, sp
;   - Scratch registers: ax, cx, dx

[bits 16]	; Tells the assembler that its a 16 bit code
[org 0x7C00]	; Origin, tell the assembler that where the code will
	; be in memory after it is been loaded

mov bx, hello_world
mov si, [hello_world_len]
call puts

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
; - bx:s
; - si: len(s)
puts:
	; Save.
	mov ax, bx
	mov cx, si
	mov dx, bx ; Incrementing pointer.

	.loop:
		or si, si
		jz .end

		; > Valid 16-bit addresses consist of an optional offset, an optional base register (bx or bp), and an optional index register (si or di). That's it! "[sp]" is not on that list.
		mov bx, dx
		mov bx, [bx]
		call putc
		inc dx
	  dec si

	jmp .loop


.end:
	mov bx, ax
	mov si, cx
	ret

; Data.
hello_world db "hello, world!"
hello_world_len dw 13

times 510 - ($ - $$) db 0	; Fill the rest of sector with 0
dw 0xAA55			; Add boot signature at the end of bootloader

