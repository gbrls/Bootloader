org 0x7e00
jmp 0x0000:start

data:

img db 25, 25, 7, 7, 7, 7, 7, 7, 7, 7, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 4, 4, 4, 4, 4, 4, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 4, 4, 4, 4, 4, 4, 4, 0, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 4, 4, 4, 4, 4, 4, 4, 4, 4, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 4, 4, 4, 4, 4, 4, 6, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 6, 4, 4, 4, 4, 6, 6, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 6, 4, 4, 4, 4, 4, 6, 8, 8, 8, 7, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 6, 4, 4, 4, 4, 4, 6, 8, 8, 8, 8, 0, 7, 8, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 8, 4, 4, 4, 4, 12, 6, 6, 6, 6, 12, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 6, 4, 4, 4, 12, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 6, 4, 4, 6, 12, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 8, 7, 7, 7, 7, 7, 7, 7, 7, 12, 4, 4, 4, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 6, 4, 4, 6, 12, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 6, 6, 4, 12, 7, 12, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 4, 6, 4, 7, 7, 7, 7, 6, 6, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 2, 8, 0, 6, 6, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 2, 2, 2, 2, 8, 6, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 2, 2, 2, 2, 8, 8, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 2, 2, 2, 2, 2, 2, 8, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 2, 2, 2, 2, 2, 2, 2, 2, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 2, 2, 2, 2, 2, 2, 2, 2, 2, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7

readpixel:

    mov cx,25
    mul cx; multiply AX by 320 (cx value)
    add ax,bx ; and add X
    mov di,ax
    mov al, [img+di]

    ret

; esta função tem como argumentos AX=coordY, BX=coordX, e a cor que será pushada na pilha
putpixel:

    push ebp
    mov ebp, esp

    mov cx,320
    mul cx; multiply AX by 320 (cx value)
    add ax,bx ; and add X
    mov di,ax
    mov dx, [ebp+6]
    mov [es:di],dl

    pop ebp

    ret

init:
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov ax, 13h ; AH=0 (Change video mode), AL=13h (Mode)
    int 10h ; Video BIOS interrupt

    mov ax, 0A000h ; The offset to video memory
    mov es, ax ; We load it to ES through AX, becouse immediate operation is not allowed on ES

    ret
	
start:
    call init

    mov ax,25 ; Y coord
    mov bx,5 ; X coord

    loop:

    mov bx, 25

    loop1:

    push ax
    push bx
    call readpixel
    mov dl, al
    pop bx
    pop ax

    ;mov dl, 8;
    push ax
    push bx
    push dx
    call putpixel
    pop dx
    pop bx
    pop ax

    dec bx

    cmp bx, 0
    jne loop1

    dec ax

    cmp ax, 0
    jne loop

jmp $
