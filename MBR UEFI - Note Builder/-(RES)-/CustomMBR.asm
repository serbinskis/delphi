cpu 386
bits 16
org 0h

;=====================================================================================================================

load_prog:
    cld
    xor ax, ax
    mov ss, ax
    mov sp, 7c00h             ;Setup stack

    mov ax, 8000h
    mov es, ax                ;Initialize es w/ 8000h
    mov ds, ax                ;Initialize ds w/ 8000h

;=====================================================================================================================

load_1:
    mov ax, 0206h             ;Function/# of sec to read
    mov cx, 0001h             ;0-5 sec # (counts from one), 6-7 hi cyl bits

    mov dh, 00h               ;Dh=head dl=drive (bit 7=hdd)
    mov bx, 0h                ;Data buffer, points to es:0
    int 13h
    cmp ah, 0
    jne load_1                ;This is allowable because it is relative

    push es
    mov ax, prog_continue
    push ax
    retf

;=====================================================================================================================    

prog_continue:
    mov cx, 2607h             ;Invisible cursor
    mov ah, 01h               ;Set text-mode cursor shape
    mov bh, 0                 ;Display page number
    int 10h                   ;Call interrupt

    mov ax, 0x1003
    mov bl, 0
    int 10h

    mov ah, 07h               ;Function to call with interrupt
    mov al, 0x00              ;Scroll whole window
    mov bh, 0x0F              ;Black background with white text
    mov cx, 0x0000            ;Row 0,col 0
    mov dx, 0x184f
    int 10h

    mov dh, 0                 ;Cursor position row
    mov dl, 0                 ;Cursor position column
    mov ah, 02h               ;Set cursor position
    mov bh, 0                 ;Display page number
    int 10h                   ;Call interrupt

    mov bp, 0200h             ;Address from where start reading
    mov ah, 0eh
    mov si, 0ffffh

;=====================================================================================================================

write_char:
    inc si
    cmp byte [ds:bp + si], 0  ;Keep writing until there is a null byte
    jz done
    push bp

    mov al, [byte ds:bp + si]
    mov bx, 07h
    int 10h                   ;Teletype the character
    pop bp
    jmp write_char

;=====================================================================================================================

done:
    hlt
    jmp done

;=====================================================================================================================

MBR_Signature:
    times 510-($-$$) db 0
    db 55h, 0aah
    db 'TEXT HERE'
    times 4096-($-$$) db 0