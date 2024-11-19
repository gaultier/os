%define PAGE_PRESENT    (1 << 0)
%define PAGE_WRITE      (1 << 1)
%define CODE_SEG     0x0008
%define DATA_SEG     0x0010

ALIGN 4
IDT:
    .length       dw 0
    .base         dd 0

GDT:
.null:
    dq 0x0000000000000000             ; Null Descriptor - should be present.
.code:
    dq 0x00209A0000000000             ; 64-bit code descriptor (exec/read).
    dq 0x0000920000000000             ; 64-bit data descriptor (read/write).
align 4
    dw 0                              ; Padding to make the "address of the GDT" field aligned on a 4-byte boundary.
.pointer:
    dw $ - GDT - 1                    ; 16-bit Size (Limit) of GDT.
    dd GDT                            ; 32-bit Base Address of GDT. (CPU will zero extend to 64-bit)


switch_to_long_mode:
    ; Zero out the 16KiB buffer.
    ; Since we are doing a rep stosd, count should be bytes/4.   
    push di                           ; REP STOSD alters DI.
    mov ecx, 0x1000
    xor eax, eax
    cld
    rep stosd
    pop di                            ; Get DI back.

    ; Build the Page Map Level 4.
    ; es:di points to the Page Map Level 4 table.
    lea eax, [es:di + 0x1000]         ; Put the address of the Page Directory Pointer Table in to EAX.
    or eax, PAGE_PRESENT | PAGE_WRITE ; Or EAX with the flags - present flag, writable flag.
    mov [es:di], eax                  ; Store the value of EAX as the first PML4E.


    ; Build the Page Directory Pointer Table.
    lea eax, [es:di + 0x2000]         ; Put the address of the Page Directory in to EAX.
    or eax, PAGE_PRESENT | PAGE_WRITE ; Or EAX with the flags - present flag, writable flag.
    mov [es:di + 0x1000], eax         ; Store the value of EAX as the first PDPTE.

    
    ; Build the Page Directory.
    lea eax, [es:di + 0x3000]         ; Put the address of the Page Table in to EAX.
    or eax, PAGE_PRESENT | PAGE_WRITE ; Or EAX with the flags - present flag, writeable flag.
    mov [es:di + 0x2000], eax         ; Store to value of EAX as the first PDE.
    
    
    push di                           ; Save DI for the time being.
    lea di, [di + 0x3000]             ; Point DI to the page table.
    mov eax, PAGE_PRESENT | PAGE_WRITE    ; Move the flags into EAX - and point it to 0x0000.


    ; Build the Page Table.
.LoopPageTable:
    mov [es:di], eax
    add eax, 0x1000
    add di, 8
    cmp eax, 0x200000                 ; If we did all 2MiB, end.
    jb .LoopPageTable

    pop di                            ; Restore DI.
    
    ; Disable IRQs
    mov al, 0xFF                      ; Out 0xFF to 0xA1 and 0x21 to disable all IRQs.
    out 0xA1, al
    out 0x21, al
    
    nop
    nop

    lidt [IDT]                        ; Load a zero length IDT so that any NMI causes a triple fault.

    ; Enter long mode.
    mov eax, 10100000b                ; Set the PAE and PGE bit.
    mov cr4, eax
      
    mov edx, edi                      ; Point CR3 at the PML4.
    mov cr3, edx
      
    mov ecx, 0xC0000080               ; Read from the EFER MSR. 
    rdmsr    

    or eax, 0x00000100                ; Set the LME bit.
    wrmsr
      
    mov ebx, cr0                      ; Activate long mode -
    or ebx,0x80000001                 ; - by enabling paging and protection simultaneously.
    mov cr0, ebx                    

    lgdt [GDT.pointer]                ; Load GDT.Pointer defined below.
      
    jmp CODE_SEG:LongMode             ; Load CS with 64 bit segment and flush the instruction cache


[BITS 64]      
LongMode:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Blank out the screen to a blue color.
    mov edi, 0xB8000
    mov rcx, 500                      ; Since we are clearing uint64_t over here, we put the count as Count/4.
    mov rax, 0x1F201F201F201F20       ; Set the value to set the screen to: Blue background, white foreground, blank spaces.
    rep stosq                         ; Clear the entire screen. 
 
mov	byte  [0xb8000], 0x68
mov	byte  [0xb8001], 0x1f
mov	byte  [0xb8002], 0x65
mov	byte  [0xb8003], 0x1f
mov	byte  [0xb8004], 0x6c
mov	byte  [0xb8005], 0x1f
mov	byte  [0xb8006], 0x6c
mov	byte  [0xb8007], 0x1f
mov	byte  [0xb8008], 0x6f
mov	byte  [0xb8009], 0x1f
mov	byte  [0xb800a], 0x20
mov	byte  [0xb800b], 0x1f

.loop:
    hlt
		jmp .loop
