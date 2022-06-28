;; BIOS loads our code here.
org 0x7C00

%define NEWLINE 0xD, 0xA

_start:
    mov [BOOT_DRIVE], dl

    ;; Clear screen (set to text mode 80x25 16 bit colors).
    xor ah, ah
    mov al, 0x03
    int 0x10

    mov ah, 0x6             ;; Scroll up.
    xor al, al              ;; Clear entire screen.
    xor cx, cx              ;; Upper left corner.
    mov dx, 0x184F          ;; Lower right corner.
    mov bh, 0x17            ;; White on blue.
    int 0x10

    mov si, boot_msg
    call print

    mov dl, [BOOT_DRIVE]
    call disk_load

    mov si, disk_loaded_msg
    call print

    cli

    ;; Load our GDT into GDT register.
    lgdt [gdt_desc]

    ;; Set protected mode bit.
    mov eax, cr0
    or eax, 1 << 0
    mov cr0, eax

    jmp CODE_SEG:protected_mode

    hlt


BOOT_DRIVE: db 0

print:
    mov ah, 0xE             ;; BIOS print char function.
    lodsb                   ;; Pseudo C for this: al = *si++
    int 0x10                ;; BIOS video interrupt.
    or al, al               ;; Sets zero flag if al is null terminator (zero).
    jnz print               ;; Continue looping if al is not zero.

done:
    ret

disk_load:
    mov ah, 0x42
    mov si, dap
    int 0x13
    jc disk_err
    ret

disk_err:
     ;; Clear screen (set to text mode 80x25 16 bit colors).
    xor ah, ah
    mov al, 0x03
    int 0x10

    mov ah, 0x6             ;; Scroll up.
    xor al, al              ;; Clear entire screen.
    xor cx, cx              ;; Upper left corner.
    mov dx, 0x184F          ;; Lower right corner.
    mov bh, 0x47            ;; White on red.
    int 0x10

    mov si, disk_err_msg
    call print

    cli
    hlt



dap:
    db 0x10     ; DAP structure size.
    db 0x0      ; Unused.
    dw 0x1      ; Sectors to read.
    dw 0x1000   ; Dest address.
    dw 0x0      ; Dest segment.
    dq 0x1      ; Start sector.


boot_msg: db "Booting..", NEWLINE, NEWLINE, 0
disk_loaded_msg: db 0xD, "Loaded stage2 from disk!", NEWLINE, 0
disk_err_msg: db "FATAL: Failed to load from disk!", 0

gdt_start:
    gdt_null:
        dd 0x0
        dd 0x0
    gdt_code:
        ;; Type flags:
        ;; Present: 1 since we are using code.
        ;; Privilege: 00 higest privilige.
        ;; Descriptor type: 1 for code/data.
        ;; Code: 1.
        ;; Conforming: 0 so segments with a lower privilege may not call code in this segment.
        ;; Readable: 1.
        ;; Accessed: 0.

        ;; Other flags:
        ;; Granularity: 1 so we can reach father into memory.
        ;; 32-bit default: 1 since our segment will have 32-bit code.
        ;; 64-bit code segment: 0.
        ;; AVL 0.
        ;; Limit: 1111.

        dw 0xFFFF        ;; Limit.
        dw 0x0           ;; Base.
        db 0x0           ;; Base.
        db 0b10011010    ;; 1st flags, type flags.
        db 0b11001111    ;; 2nd flags, type flags.
        db 0x0
    gdt_data:
        ;; Type flags:
        ;; Code: 0.
        ;; Expand down: 0.
        ;; Writable: 0.
        ;; Accessed: 0.

        dw 0xFFFF        ;; Limit.
        dw 0x0           ;; Base.
        db 0x0           ;; Base.
        db 0b10010010    ;; 1st flags, type flags.
        db 0b11001111    ;; 2nd flags, type flags.
        db 0x0
gdt_end:


gdt_desc:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

bits 32
protected_mode:
    ;; Set segment registers.
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ;; Update stack so it points to top
    ;; of our free space.
    mov ebp, 0x90000
    mov esp, ebp                ;; Point top of stack to base.

    cli
    hlt

;; Some sector padding.
times 510-($-$$) db 0
dd 0xAA55
