boot.o : boot.asm
	nasm boot.asm -o boot.o

kernel_entry.o : kernel_entry.asm
	nasm kernel_entry.asm -f elf32 -o kernel_entry.o

kernel.o : kernel.c
	gcc -m32 -c kernel.c -o kernel.o -ffreestanding -nostdlib -nostdinc

kernel.tmp : kernel.o kernel_entry.o
	ld -m i386pe -o kernel.tmp -Ttext 0x1000 kernel_entry.o kernel.o

kernel.bin : kernel.tmp
	objcopy -O binary -j .text kernel.tmp kernel.bin

boot.bin : boot.o kernel.bin
	type boot.o,kernel.bin > boot.bin

kernel.dis : kernel.bin
	ndisasm -b 32 $< > $@

boot.dis : boot.bin
	ndisasm -b 32 $< > $@

all: boot.bin
clean:
	rm -r *.bin,*.dis,*.o,*.tmp

run: boot.bin
	qemu-system-x86_64 boot.bin