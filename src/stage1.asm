;; BIOS loads our code here.
org 0x7C00

_start:
    mov si, hello
    call print
    cli
    hlt


print:
    mov ah, 0xE
    lodsb
    int 0x10
    or al, al
    jnz print

done:
    ret


hello: db "Hello, World!", 0


;; Some sector padding.
times 510-($-$$) db 0
dd 0xAA55
