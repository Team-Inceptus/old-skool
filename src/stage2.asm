bits 32

global stage2__start

stage2__start:
    cli
    hlt

;; Sector padding.
times 510-($-$$) db 0
