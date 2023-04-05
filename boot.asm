[org 0x7c00]
KERNEL_OFFSET equ 0x1000

    mov [BOOT_DRIVE], dl

    mov bp, 0x9000
    mov sp, bp

    call load_kernel
    call switch_to_pm

    jmp $

; Remember to put include here, or it will do bads stuff :)
%include "print.asm"
%include "gdt.asm"
%include "switch_pm.asm"
%include "disk.asm"
%include "printpm.asm"

[bits 16]
load_kernel:
    mov bx, MSG_LOAD_KERNEL
    call print_string

    mov bx, KERNEL_OFFSET
    mov dh, 1
    mov dl, [BOOT_DRIVE]

    call disk_load

    ret

[bits 32]
BEGIN_PM:
    mov ebx, MSG_PROT_MODE
    call print_string_pm

    call KERNEL_OFFSET
    jmp $               ; Lock kernel :D

BOOT_DRIVE db 0
MSG_REAL_MODE db "Started in 16-bit Real Mode", 0
MSG_PROT_MODE db "Successfully landed in 32-bit Protected Mode", 0
MSG_LOAD_KERNEL db "Booting kernel", 0

times 510-($-$$) db 0
dw 0xaa55