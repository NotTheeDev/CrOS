[bits 16]
disk_load:
    pusha
    push dx

    mov ah, 0x02
    mov al, dh
    mov ch, 0x00
    mov dh, 0x00
    mov cl, 0x02

    int 0x13

    jc disk_error

    pop dx
    cmp dh, al
    jne sectors_error
    popa
    ret

disk_error:
    mov bx, DISK_ERROR_MSG
    call print_string
    mov dh, ah
    call print_hex
    jmp $

sectors_error:
    mov bx, SECTORS_ERROR
    call print_string

DISK_ERROR_MSG: db "Disk read error!", 0
SECTORS_ERROR: db "Incorrect number of sectors read", 0