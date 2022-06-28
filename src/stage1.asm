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

;; Some sector padding.
times 510-($-$$) db 0
dd 0xAA55
