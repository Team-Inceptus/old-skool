.PHONY: all
all:
	nasm -f bin src/stage1.asm -o ./stage1.bin
	nasm -f bin src/stage2.asm -o ./stage2.bin
	cat stage1.bin stage2.bin > old_skool.bin
	rm stage1.bin stage2.bin
	@ # Prepare the image.
	sudo dd if=/dev/zero of=old-skool.img bs=1024 count=1440
	@ # Put the OS stuff in the image.
	sudo dd if=old_skool.bin of=old-skool.img
	rm *.bin

run:
	sudo qemu-system-x86_64 -drive file=old-skool.img -monitor stdio -d int -no-reboot -D logfile.txt -M smm=off
