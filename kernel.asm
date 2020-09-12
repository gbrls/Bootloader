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

;TODO: finish implementation of this function
; _draw_square: 

;     mov bp, sp

;     .draw_square_loop:

    
;     jl .draw_square_loop
    
;     ret

; %macro draw_square 2
;     push ax
;     push bx
;     push cx
;     push dx
;     push bp
;     push es

;     ;push %4
;     ;push %3
;     push %2
;     push %1

;     call _draw_square

;     add sp, 4
;     pop es
;     pop bp
;     pop dx
;     pop cx
;     pop bx    
;     pop ax
; %endmacro

_clear_screen: 
    mov bx, 0 ; y
    .clear_screen_line_loop:
    draw_horizontal_line bx, 0, 320, 0
    inc bx
    cmp bx, 200
    jl .clear_screen_line_loop   
    ret

%macro clear_screen 0
    push ax
    push bx
    push cx
    push dx
    push bp
    push es

    call _clear_screen 

    pop es
    pop bp
    pop dx
    pop cx
    pop bx    
    pop ax
%endmacro


; I know that the code below in this macro is dumb. I'm just testing something really quick, don't judge me Ò_Ó, in the final version, we should use loops.
%macro dumb_macro_to_draw_square 1
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    draw_horizontal_line bx, ax, cx, %1
    inc bx
    sub bx, 30 

%endmacro


start:
    call init 

    ;############# The moving square ###############
    mov bx, 1 ; y
    mov ax, 1 ; x1
    mov cx, 30 ; x2
    mov dx, 0 ; dx==0 [down, right], dx==1 [down, left], dx==2 [up, right], dx==3 [up, left]
    jmp .draw_loop

    .keep_inertia: ; keep inertia start
    cmp dx, 0
    je .dx_0 
    cmp dx, 1
    je .dx_1 
    cmp dx, 2
    je .dx_2 
    cmp dx, 3
    je .dx_3 

    .dx_0:
    dumb_macro_to_draw_square  2
    ; update x and y values
    inc bx
    inc ax
    inc cx   
    jmp .draw_loop
    
    .dx_1:
    dumb_macro_to_draw_square 3
    ; update x and y values
    inc bx
    dec ax
    dec cx
    jmp .draw_loop

    .dx_2:
    dumb_macro_to_draw_square 4
    dec bx
    inc ax
    inc cx
    jmp .draw_loop

    .dx_3:
    dumb_macro_to_draw_square 5
    dec bx
    dec ax
    dec cx
    jmp .draw_loop

    .bateu_embaixo:
    cmp dx, 1 
    je .embaixo_3_1
    cmp dx, 0 
    je .embaixo_3_2
    .embaixo_3_1:
    mov dx, 3
    jmp .embaixo_3_end
    .embaixo_3_2:
    mov dx, 2    
    jmp .embaixo_3_end
    .embaixo_3_end: 
    jmp .keep_inertia 
    jmp .draw_loop
    
    .bateu_na_direita:
    cmp dx, 0
    je .direita_1
    cmp dx, 2
    je .direita_2
    .direita_1:
    mov dx, 1
    jmp .direita_end
    .direita_2: 
    mov dx, 3
    jmp .direita_end
    .direita_end: 
    jmp .keep_inertia 
    jmp .draw_loop


    .bateu_na_esquerda:
    cmp dx, 3 
    je .esquerda_3_1
    cmp dx, 1 
    je .esquerda_3_2
    .esquerda_3_1:
    mov dx, 2
    jmp .esquerda_3_end
    .esquerda_3_2:
    mov dx, 0  
    jmp .esquerda_3_end
    .esquerda_3_end
    jmp .keep_inertia 
    jmp .draw_loop


    .bateu_em_cima:
    cmp dx, 2
    je .cima_1
    cmp dx, 3
    je .cima_2
    .cima_1 
    mov dx, 0
    jmp .cima_end
    .cima_2
    mov dx, 1
    jmp .cima_end
    .cima_end:
    jmp .keep_inertia 
    jmp .draw_loop

    .draw_loop:
    ; delay (note: push and pop are to preserve the values of those registers.)
    ; cx = 1 makes the dealay too long, how can it be shorter???
    push cx
    push dx
    push ax
    mov cx, 0     ;high word -> somehow, that I don't yet understand, cx and dx are combined to represent the amount of milissecods of the wait interrupt.
    mov dx, 0    ;low word
    mov ah, 86h    ;wait mode
    int 15h
    pop ax
    pop dx
    pop cx
    clear_screen
    cmp bx, 200
    jl .a1 
    .a1:
    cmp bx, 170
    jg .bateu_embaixo
    cmp bx, 0
    je .bateu_em_cima
    cmp ax, 0
    je .bateu_na_esquerda
    cmp cx, 319
    je .bateu_na_direita
    jmp .keep_inertia


    ;############# The HI! message ###############
    ; Everything under this is to draw the hi message (just a test, you can delete this.)
    ; .start_over_color_loop:
    ; mov ax, 1
    ; mov bx, 2
    ; mov cx, 3
    ; .start_color_loop:
    ; inc ax
    ; inc bx
    ; inc cx
    ; ;H
    ; draw_horizontal_line 50, 40, 80, ax
    ; draw_horizontal_line 100, 80, 120, ax
    ; draw_horizontal_line 50, 120, 160, ax
    ; draw_horizontal_line 198, 40, 80, ax
    ; draw_horizontal_line 150, 80, 120, ax
    ; draw_horizontal_line 198, 120, 160, ax
    ; draw_vertical_line 40, 50, 199, ax
    ; draw_vertical_line 80, 50, 100, ax
    ; draw_vertical_line 80, 150, 199, ax
    ; draw_vertical_line 119, 50, 100, ax
    ; draw_vertical_line 120, 150, 199, ax
    ; draw_vertical_line 160, 50, 199, ax
    ; ;I
    ; draw_horizontal_line 13, 200, 240, bx
    ; draw_horizontal_line 39, 200, 240, bx
    ; draw_horizontal_line 50, 200, 240, bx
    ; draw_horizontal_line 199, 200, 240, bx
    ; draw_vertical_line 200, 13, 39, bx
    ; draw_vertical_line 200, 50, 199, bx
    ; draw_vertical_line 239, 13, 39, bx
    ; draw_vertical_line 239, 50, 199, bx
    ; ;!
    ; draw_horizontal_line 25, 280, 315, cx
    ; draw_horizontal_line 150, 280, 315, cx
    ; draw_horizontal_line 175, 280, 315, cx 
    ; draw_horizontal_line 199, 280, 315, cx
    ; draw_vertical_line 280, 25, 150, cx
    ; draw_vertical_line 280, 175, 199, cx
    ; draw_vertical_line 314, 25, 150, cx
    ; draw_vertical_line 314, 175, 199, cx

    ; ;delay
    ; push cx
    ; push dx
    ; push ax
    ; mov cx, 0x5     ;HIGH WORD.
    ; mov dx, 0x0  ;LOW WORD.
    ; mov ah, 86h    ;WAIT.
    ; int 15h
    ; pop ax
    ; pop dx
    ; pop cx

    ; cmp cx, 15
    ; je .start_ov
    ; jmp .start_color_loop


end:

jmp $
