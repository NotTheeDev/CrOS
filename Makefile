#boot.o : boot.asm
#	nasm boot.asm -o boot.o
#
#kernel_entry.o : kernel_entry.asm
#	nasm kernel_entry.asm -f elf32 -o kernel_entry.o
#
#kernel.o : kernel.c
#	gcc -m32 -c kernel.c -o kernel.o -ffreestanding -nostdlib -nostdinc
#
#kernel.tmp : kernel.o kernel_entry.o
#	ld -m i386pe -o kernel.tmp -Ttext 0x1000 kernel_entry.o kernel.o
#
#kernel.bin : kernel.tmp
#	objcopy -O binary -j .text kernel.tmp kernel.bin
#
#boot.bin : boot.o kernel.bin
#	type boot.o,kernel.bin > boot.bin
#
#kernel.dis : kernel.bin
#	ndisasm -b 32 $< > $@
#
#boot.dis : boot.bin
#	ndisasm -b 32 $< > $@
#

C_SOURCES = $(wildcard kernel/*.c drivers/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h)

OBJ = ${C_SOURCES:.c=.o}

boot.bin : boot/boot.bin kernel.bin
	type boot\boot.bin,kernel.bin > boot.bin 

kernel.bin : kernel/kernel_entry.o ${OBJ}
	ld -m i386pe -o kernel.tmp -Ttext 0x1000 $^
	objcopy -O binary -j .text kernel.tmp kernel.bin

%.o : %.c ${HEADERS}
	gcc -ffreestanding -c $< -o $@

%.o : %.asm
	nasm $< -f elf -o $@

%.bin : %.asm
	nasm $< -f bin -I '../../16bit/' -o $@

clean:
	del *.bin,*.dis,*.tmp
	del kernel\*.o,drivers\*.o
	del boot\*.bin

fresh_run: clean boot.bin
	qemu-system-i386 boot.bin

all: boot.bin
run: boot.bin
	qemu-system-i386 boot.bin