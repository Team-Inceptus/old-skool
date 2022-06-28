;; BIOS loads our code here.
org 0x7C00

_start:
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
