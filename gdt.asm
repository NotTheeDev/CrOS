gdt_start:
gdt_null:
    dd 0x0
    dd 0x0

gdt_code:
    dw 0xffff   ; Limit
    dw 0x0      ; Base
    db 0x0      ; Base
    db 10011010b; 1st flags, type flags
    db 11001111b; 2nd flags, Limit
    db 0x0

gdt_data:
    dw 0xffff   ; Limit
    dw 0x0      ; Base
    db 0x0      ; Base
    db 10010010b; 1st flags, type flags
    db 11001111b; 2nd flags, Limit
    db 0x0      ; Base

gdt_end:
gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start