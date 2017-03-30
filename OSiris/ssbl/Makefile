FILES=parser common hashtable

compile_asm=nasm -g -f elf -o build/$(1).o $(1).asm

all: clean compile link

clean:
	rm -f build/*

build:
	mkdir build

compile: build
	$(foreach file,$(FILES),$(call compile_asm,$(file)); )

link:
	ld -m elf_i386 -o parser $(addprefix build/,$(addsuffix .o,$(FILES)))
	chmod +x parser
