org 0x7e00
jmp 0x0000:start

data:

init:
    xor ax, ax
    mov ds, ax
    mov es, ax
    ; Go into mode 13h: 320x200x256
    mov ah, 0
    mov al, 13h
    int 10h
    ret	

_put_pixel: ; (x, y, color)

    mov bp, sp          ; we can't index the sp, so we use bp

    mov ax, 0a000h      
    mov es, ax          ; set the es with the VGA VIDEO RAM segment adress.
  
    mov ax, [bp+2]         ; y position
    mov cx, 320         ; width in pixels of the screen
    mul cx              ; update ax (and dx?) with the result
    add ax, [bp+4]         ; add x position to result   
    
    mov bx, ax
    mov al, [bp+6]
    es mov [bx], al 

    ret

%macro put_pixel 3
    push ax
    push bx
    push cx
    push dx
    push bp
    push es

    push %3
    push %1
    push %2
    
    call _put_pixel

    add sp, 6
    pop es
    pop bp
    pop dx
    pop cx
    pop bx    
    pop ax
%endmacro

_draw_vertical_line: ; (x, y1, y2, color)
    mov bp, sp 

    mov ax, [bp+2]  ; x
    mov bx, [bp+4]  ; y1
    mov cx, [bp+6]  ; y2
    mov dx, [bp+8]  ; color

    .draw_vertical_line_loop:
    put_pixel ax, bx, dx
    add bx, 1
    cmp bx, cx
    jl .draw_vertical_line_loop

    ret

%macro draw_vertical_line 4
    push ax
    push bx
    push cx
    push dx
    push bp
    push es

    push %4
    push %3
    push %2
    push %1

    call _draw_vertical_line

    add sp, 8
    pop es
    pop bp
    pop dx
    pop cx
    pop bx    
    pop ax
%endmacro

_draw_horizontal_line: ; (y, x1, x2, color)
    mov bp, sp 

    mov ax, [bp+2]  ; y
    mov bx, [bp+4]  ; x1
    mov cx, [bp+6]  ; x2
    mov dx, [bp+8]  ; color

    .draw_horizontal_line_loop:
    put_pixel bx, ax, dx
    add bx, 1
    cmp bx, cx
    jl .draw_horizontal_line_loop

    ret

%macro draw_horizontal_line 4
    push ax
    push bx
    push cx
    push dx
    push bp
    push es

    push %4
    push %3
    push %2
    push %1

    call _draw_horizontal_line

    add sp, 8
    pop es
    pop bp
    pop dx
    pop cx
    pop bx    
    pop ax
%endmacro

; TODO: finish implementation of this function
; _draw_square: ; (x, y, width, color)

;     mov bp, sp

;     .draw_square_loop:
    
;     jl .draw_square_loop
    
;     ret

; %macro draw_square 4
;     push ax
;     push bx
;     push cx
;     push dx
;     push bp
;     push es

;     push %4
;     push %3
;     push %2
;     push %1

;     call _draw_square

;     add sp, 8
;     pop es
;     pop bp
;     pop dx
;     pop cx
;     pop bx    
;     pop ax
; %endmacro



start:
    call init 

    ; Everything under this is to draw the hi message (just a test, you can delet this.)

    .start_over_color_loop:
    mov ax, 1
    mov bx, 2
    mov cx, 3

    .start_color_loop:
    inc ax
    inc bx
    inc cx


    ;H
    draw_horizontal_line 50, 40, 80, ax
    draw_horizontal_line 100, 80, 120, ax
    draw_horizontal_line 50, 120, 160, ax
    draw_horizontal_line 198, 40, 80, ax
    draw_horizontal_line 150, 80, 120, ax
    draw_horizontal_line 198, 120, 160, ax

    draw_vertical_line 40, 50, 199, ax
    draw_vertical_line 80, 50, 100, ax
    draw_vertical_line 80, 150, 199, ax
    draw_vertical_line 119, 50, 100, ax
    draw_vertical_line 120, 150, 199, ax
    draw_vertical_line 160, 50, 199, ax

    ;I

    draw_horizontal_line 13, 200, 240, bx
    draw_horizontal_line 39, 200, 240, bx
    draw_horizontal_line 50, 200, 240, bx
    draw_horizontal_line 199, 200, 240, bx


    draw_vertical_line 200, 13, 39, bx
    draw_vertical_line 200, 50, 199, bx
    draw_vertical_line 239, 13, 39, bx
    draw_vertical_line 239, 50, 199, bx

    ;!
    draw_horizontal_line 25, 280, 315, cx
    draw_horizontal_line 150, 280, 315, cx
    draw_horizontal_line 175, 280, 315, cx 
    draw_horizontal_line 199, 280, 315, cx


    draw_vertical_line 280, 25, 150, cx
    draw_vertical_line 280, 175, 199, cx
    draw_vertical_line 314, 25, 150, cx
    draw_vertical_line 314, 175, 199, cx

    cmp cx, 15
    jl .start_color_loop
    je .start_over_color_loop

end:

jmp $
