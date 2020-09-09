org 0x7e00
jmp 0x0000:start

data:
	
    screen db 10000 DUP(0)
    sz dd 100

    w dd 320
    h dd 200

clear: ; modo gráfico 640x350
	mov ah, 0
	mov al, 0Dh
	int 10h

    ret

bgcolor:

    mov ah, 0Bh
    mov bh, 00h

    mov bl, 44h

    int 10h

    ret

pixel: ; pixel em cx, dx

    push ebp
    mov ebp, esp

	mov ah, 0ch
	mov bh, 0

	mov al, 14

	int 10h

    pop ebp

    ret


pixelc: ; pixel em cx, dx

    push ebp
    mov ebp, esp

	mov bh, 0
	mov ah, 0ch
	int 10h

    pop ebp

    ret

clear_screen:

    push bp
    mov bp, sp

    mov ax, [w]

    .loop:
        dec ax
        mov cx, ax
        push ax

        mov ax, [h]

        .loop2:

            dec ax
            mov dx, ax
            push ax

            mov al, 14 ; qual cor usar
            call pixelc

            pop ax

            cmp ax, 0
        jne .loop2


        pop ax
        cmp ax, 0
    jne .loop

    pop bp

    ret

start:
    xor ax, ax
    mov ds, ax
    mov es, ax

    call clear
    call bgcolor
    call clear_screen


jmp $
