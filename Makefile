.PHONY: all
all:
	nasm -f bin src/stage1.asm -o ./stage1.bin
	nasm -f bin src/stage2.asm -o ./stage2.bin
	cat stage1.bin stage2.bin > old_skool.bin
	rm stage1.bin stage2.bin

run:
	bochs -f bsrc.txt
