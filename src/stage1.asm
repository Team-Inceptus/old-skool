;; BIOS loads our code here.
org 0x7C00

_start:
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

    mov si, hello
    call print
    cli
    hlt


print:
    mov ah, 0xE             ;; BIOS print char function.
    lodsb                   ;; Pseudo C for this: al = *si++
    int 0x10                ;; BIOS video interrupt.
    or al, al               ;; Sets zero flag if al is null terminator (zero).
    jnz print               ;; Continue looping if al is not zero.

done:
    ret


hello: db "Hello, World!", 0


;; Some sector padding.
times 510-($-$$) db 0
dd 0xAA55
