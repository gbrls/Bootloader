org 0x7e00
jmp 0x0000:start

data:

img db 7, 7, 7, 7, 7, 7, 7, 7, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 4, 4, 4, 4, 4, 4, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 4, 4, 4, 4, 4, 4, 4, 0, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 4, 4, 4, 4, 4, 4, 4, 4, 4, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 4, 4, 4, 4, 4, 4, 6, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 6, 4, 4, 4, 4, 6, 6, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 6, 4, 4, 4, 4, 4, 6, 8, 8, 8, 7, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 6, 4, 4, 4, 4, 4, 6, 8, 8, 8, 8, 0, 7, 8, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 8, 4, 4, 4, 4, 12, 6, 6, 6, 6, 12, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 6, 4, 4, 4, 12, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 6, 4, 4, 6, 12, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 8, 7, 7, 7, 7, 7, 7, 7, 7, 12, 4, 4, 4, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 6, 4, 4, 6, 12, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 6, 6, 4, 12, 7, 12, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 8, 8, 8, 8, 4, 6, 4, 7, 7, 7, 7, 6, 6, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 2, 8, 0, 6, 6, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 2, 2, 2, 2, 8, 6, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 2, 2, 2, 2, 8, 8, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 2, 2, 2, 2, 2, 2, 8, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 2, 2, 2, 2, 2, 2, 2, 2, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 2, 2, 2, 2, 2, 2, 2, 2, 2, 8, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 8, 8, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7

readpixel:

    mov cx,25 ; image height
    mul cx; 
    add ax,bx 
    mov di,ax
    mov al, [img+di]

    ret

; this function has as parameters AX=coordY, BX=coordX, and the color that will be pushed onto the stack
putpixel:

    push ebp
    mov ebp, esp

    mov cx,320 ; image width
    mul cx
    add ax,bx 
    mov di,ax
    mov dx, [ebp+6]
    mov [es:di],dl

    pop ebp

    ret

; the image width and height must be stacked in 2 bytes
print_img:

    push ebp
    mov ebp, esp


    mov ax,[ebp+6] ; Y coord

    .loop:

    dec ax
    mov bx, [ebp+8] ; X coord

    .loop1:

    dec bx

    push ax
    push bx
    call readpixel
    mov dl, al
    pop bx
    pop ax

    ;mov dl, 8;
    add ax, [ebp+10]
    add bx, [ebp+12]

    push ax
    push bx
    push dx
    call putpixel
    pop dx
    pop bx
    pop ax


    sub bx, [ebp+12]
    sub ax, [ebp+10]


    cmp bx, 0
    jne .loop1


    cmp ax, 0
    jne .loop

    pop ebp

    ret

clear_screen:
    mov ax, 200 ; Y coord
    .loop:

    mov bx, 320 ; X coord
    .loop1:

    mov dl, 8;

    push ax
    push bx
    push dx
    call putpixel
    pop dx
    pop bx
    pop ax

    dec bx

    cmp bx, 0
    jge .loop1

    dec ax

    cmp ax, 0
    jge .loop

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

    mov ax, 100
    mov bx, 100

    call clear_screen

    .loop:
    push ax
    push bx
    pop bx
    pop ax

    and ax, 0xffff
    and bx, 0xffff

    ;mov ax, 100 ; dest x 
    push ax

    sar ax, 8

    push ax
    ;mov ax, bx ; dest y 
    push ax
    mov ax, 26 ; img W
    push ax
    mov ax, 26 ; img H
    push ax
    call print_img
    pop ax
    pop ax
    pop bx
    pop ax
    pop ax

    add ax, 1
    add bx, 1


    jmp .loop


jmp $
