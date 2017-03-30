all: build clean kernel osiris.flp

build:
	mkdir build

clean:
	rm -f build/*

boot.bin:
	nasm -f bin -o build/boot.bin boot/boot.asm

osiris.flp: boot.bin
	dd if=/dev/zero of=build/osiris.flp bs=512 count=2880
	dd conv=notrunc if=build/boot.bin of=build/osiris.flp

kernel: init.o syscall.o io.o
	ld -m elf_i386 -o build/kernel build/init.o build/syscall.o build/io.o

io.o:
	nasm -g -f elf -o build/io.o kernel/io.asm

syscall.o:
	nasm -g -f elf -o build/syscall.o kernel/syscall.asm

init.o:
	nasm -g -f elf -o build/init.o kernel/init.asm
