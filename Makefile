ASMFILES = $(wildcard src/*.asm)

stage1.bin: $(ASMFILES)
	nasm $^ -fbin -o $@

run:
	bochs -f bsrc.txt
