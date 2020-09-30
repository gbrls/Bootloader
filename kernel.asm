org 0x7e00
jmp 0x0000:start

data:
	;vetor TIMES 10 DW 0
    str1 db 'Digite o tamanho do vetor: ', 13, 10, 0
    str2 db 'Digite o vetor: ',13,10,0
    str3 db 'General Kenobi',13,10,0
    str_test db 'Pressione qualquer tecla', 13, 10, 0
    comandos db 'ls - Lista os comandos disponiveis.',13,10,'bubble - Veja o bubble sort em acao.',13,10,'selection - Veja o selection em acao.',13,10,'about - Informacoes sobre o sistema.',13,10,'maze - Gere um quase labirinto',13,10,'quadrado - Screensaver com um quadrado',13,10,'vaquinha - Uma vaca reproduzindo uma mensagem.',13,10,'inverter - Exibe uma mensagem ao contrario.',13,10,'clear - Limpar a tela',13,10,'echo - Printa os argumentos',13,10,0

    mensagemi db 'CInstema operacional X - Ver 0.1',13,10,'Empresa de software Ltda. (1984)',13,10,13,10,'Digite ls para ajuda.',13,10,0

    erro_msg db 'Comando nao reconhecido (o_o)',13,10,0
    about_msg db 'Este sistema foi desenvolvido por alie- ligenas do passado.',13,10,0
    sprompt db 'MY-PC>',0

    arg TIMES 64 db 0

    cowCmd db 'Digite uma mensagem para a vaca exibir:',13,10,0
    
    blkS db '                             ',13,10,0
    cow1 db '        \   ^__^             ',13,10,0
    cow2 db '         \  (oo)\_______     ',13,10,0
    cow3 db '            (__)\       )\/\ ',13,10,0
    cow4 db '                ||----w |    ',13,10,0
    cow5 db '                ||     ||    ',13,10,0

    reverseCmd db 'Digite uma mensagem para ser exibida ao contrario:',13,10,0
    reverseMsg db '',13,10,0

    msg_max_len    equ 40
    msg:   resb    msg_max_len+1
    ; array com o comando para cada char
    
    ;      a            b        c   d ...
    ctable dw about_fn, sort_fn, clear, ef, echo, ef, ef, hello_there, reverse_fn, ef, ef, ls_fn, maze_fn, ef, ef, ef, screensaver, ef, s_sort, ef, ef, cow_fn, ef, ef, ef, ef

    v TIMES 100 db 0
    n db 0
    i db 0
    j db 0
    aux db 0
    cor db 3
    state dw 1
	;Dados do projeto...

init_video:
    mov ah, 00h ;escolhe modo video
    mov al, 13h ;modo VGA
    int 10h     ;chama interrupt

    ret

_put_pixel: ; (x, y, color)

    mov bp, sp          ; we can't index the sp, so we use bp

    mov ax, 0a000h      ; VGA VIDEO RAM segment adress
    mov es, ax          ; set the es with the VGA VIDEO RAM segment adress.
  
    mov ax, [bp+2]      ; get y position from stack
    mov cx, 320         ; width in pixels of the screen
    mul cx              ; update ax (and dx?) with the result
    add ax, [bp+4]      ; add x position to result   
    
    mov bx, ax          ; mov x position from ax to bx (al is needed below)
    mov al, [bp+6]      ; get color from stack
    es mov [bx], al     ; TODO: explain     

    ret

%macro put_pixel 3
    pusha

    push %3
    push %1
    push %2
    
    call _put_pixel

    add sp, 6
    popa
%endmacro

_draw_horizontal_line: ; (y, x1, x2, color)

    mov bp, sp      ; we can't index the sp, so we use bp

    mov ax, [bp+2]  ; y
    mov bx, [bp+4]  ; x1
    mov cx, [bp+6]  ; x2
    mov dx, [bp+8]  ; color

    .draw_horizontal_line_loop:
    put_pixel bx, ax, dx
    inc bx          ; increases the pixel's x position
    cmp bx, cx      ; until it reaches x2
    jl .draw_horizontal_line_loop

    ret

%macro draw_horizontal_line 4
    pusha

    push %4
    push %3
    push %2
    push %1

    call _draw_horizontal_line

    add sp, 8
    popa
%endmacro

_draw_square:       ;(x, y, width, color)
    mov bp, sp

    ;get parameters from stack
    mov ax, [bp+2]      ; x position       
    mov bx, [bp+4]      ; y position 
    mov si, [bp+6]      ; width
    add si, ax          ; add x position (left up corner) to the square width
    mov dx, [bp+8]      ; color
    mov cx, 0           ; counter (will loop until cx == square_width)

    .square_loop:
    
    draw_horizontal_line bx, ax, si, dx 

    inc bx               ; increase y, for the next line (below the one printed now)
    inc cx               ; increase coutner (to check if width was reached)

    cmp cx, [bp+6]       ; compare counter with square width 
    jl .square_loop

    ret

%macro draw_square 4
    pusha

    push %4
    push %3
    push %2
    push %1
    call _draw_square

    add sp, 8
    popa
%endmacro

_delay:             ;(interval_in_microsecond_high_word,  interval_in_microsecond_low_word)
    push ax         ; to preserve ax value before calling this function

    ; http://www.techhelpmanual.com/221-int_15h_86h__wait.html

    mov ah, 86h     ; interrupt parameter for delay 
    int 15h         ; interrupt that will wait the given amount of microsseconds (in the macro parameters)

    pop ax      
    ret

%macro DELAY 2
    push cx
    push dx

    mov cx, %1
    mov dx, %2

    call _delay

    pop dx
    pop cx

%endmacro

getc:
    xor ah, ah
    int 16h
    ret

;TODO: implementar uma função para printar números até 99
print_num:
    pusha

    xor ah, ah
    mov bl, 10
    div bl

    ;al = quociente
    ;ah = resto

    cmp al, 0
    je flag

    add al, '0'
    call print_char

    flag:

        mov al ,ah
        add al, '0'
        call print_char

    popa
    ret


putc:
    call print_char
    ret

print_char:
    pusha

    mov bl, [cor]
    
    mov ah, 0xe
    int 10h

    popa
    ret

endl:
    mov al, 13
    call putc
    mov al, 10
    call putc

    ret

; printa uma string  terminada com '0'

print_str_color:

    DELAY 0, 0x4000 ; fiquei sem paciencia
    
    lodsb

    cmp al, 0
    je .done

    mov ah,0xe
    int 10h

    jmp print_str_color

    .done:
        call cursor
        ret
print_str:

    mov bl, 56
    call print_str_color

    ret

print_array:
    pusha

    mov si, v
    mov cl, [n]

    .loop:
        lodsb

        call print_num
        mov al, ' '
        call print_char

    dec cl
    cmp cl, 0
    jg .loop
    
    mov al, 13 ; mover o cursor para o inicio da linha
    call putc

    popa
    ret

swap:
    pusha

    mov al, [si]
    mov bl, [si+1]
    mov [si+1], al
    mov [si], bl

    popa
    ret

selec_swap:

    mov al, [bp]
    mov bl, [di]
    mov [di], al
    mov [bp], bl

    dec di

    
    ret

selection:

    mov bh, [n]
    mov di, v
    mov ax, [n]
    dec ax
    add di, ax

    .outer_loop:

        mov si, v
        mov bl, bh

        mov bp, si  


        .inner_loop:
            
            push cx
            push dx
            mov cx, 0Fh
            mov dx, 0

            DELAY 0x2, 0x0

            pop dx
            pop cx

            inc bh
            mov [cor], bh
            dec bh

            call print_array

            mov al, [si]
            mov cl, [bp]
            cmp cl, al

            jg .end_inner_loop

            mov bp, si    ;Salva o index onde o maior elemento se encontra
            


    .end_inner_loop:

        inc si
        dec bl

    cmp bl, 0
    jg .inner_loop

    call selec_swap  
    dec bh
    cmp bh, 0
    jg .outer_loop

    ret 

s_sort:
    mov al, 3
    mov [cor], al

    call entradas
    call selection

    mov al, 10
    mov [cor], al

    call endl
    call cursor
    call getc ; esperar o usuario digitar
    ;call clear_screen
    call exit_to_shell

    ret
    
sort:
    push ebp
    mov ebp, esp

    mov bh, [n]

    ; Vamos chamar o outer loop n vezes
    ; e dentro deste loop vamos percorrer o array
    ; até arr[n-2] e sempre trocando arr[i] com arr[i+1]
    ; se arr[i] > arr[i+1]

    .outer_loop:

    mov si, v
    mov bl, [n]

    .inner_loop:
        
        push cx
        push dx
        mov cx, 0Fh
        mov dx, 0

        DELAY 0x2, 0x0

        pop dx
        pop cx

        inc bh
        mov [cor], bh
        dec bh

        call print_array
        mov al, [si]
        mov cl, [si+1]
        cmp al, cl

        ; se for menor ou igual, não precisa trocar
        jle .end_inner_loop 

        call swap
    .end_inner_loop:

        inc si
        dec bl

    cmp bl, 1 ; não comparamos com 0 pq queremos chegar só até n-2
    jg .inner_loop

    dec bh

    cmp bh, 0
    jg .outer_loop

    pop ebp

    ret

get_n: 

    mov si, str1
    call print_str

    xor ah, ah
    int 16h

    call print_char

    sub al, '0'
    mov [n], al

    xor ah, ah
    int 16h
    
    call print_char

    cmp al, 13
    je .end

    sub al, '0'
    mov [aux], al

    mov al, [n]
    mov cl, 10
    mul cl

    add al, [aux]
    mov [n], al

    xor ah, ah
    int 16h
    
    call print_char

    .end:
        call endl
        ret

get_string:
    mov di, msg
    lea si, [di+msg_max_len]
    .for:
        cmp di, si
        jae .fim
        call getc
        call print_char 
        cmp al, 13
        je .fim
        
        mov [di], al
        inc di
        jmp .for
    .fim:
        mov [di], byte 0
        ret

get_reverseString:
    ;mov si, msg
    mov si, arg
    mov di, reverseMsg

	mov cl,0
	.for:
		lodsb
		cmp al, 0
		je .end

		push ax 
		inc cl
		jmp .for

	.end:
	.for1:
		cmp cl,0
		je .end1
		dec cl
		pop ax
		stosb
		jmp .for1
	.end1:

    mov al,0
    stosb

	ret

getValue:

    xor ah, ah
    int 16h

    call print_char

    sub al, '0'
    mov dl, al

    xor ah, ah
    int 16h
    
    call print_char

    cmp al, 13 ; Pressionou enter?
    je .end

    sub al, '0'
    mov [aux], al

    mov al, dl
    mov bl, 10
    mul bl

    add al, [aux]
    mov dl, al

    xor ah, ah
    int 16h
    
    call print_char

    .end:
        mov al, 13
        call print_char

        mov al, ' '
        call print_char
        mov al, ' '
        call print_char

        mov al, 13
        call print_char
        ret

get_array:

    mov si, str2
    call print_str

    mov si, v
    mov cl, [n]

    .loop:
        call cursor
        call getValue

        mov [si], dl

        inc si

        dec cl
        cmp cl, 0
        jg .loop
    ret

entradas:
    call get_n
    call get_array
    ret

clear_screen: 
    pusha

    mov ah, 02h
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 10h

    mov bx, 0 ; y
    .clear_screen_line_loop:
    draw_horizontal_line bx, 0, 320, 0
    inc bx
    cmp bx, 200
    jl .clear_screen_line_loop   
    popa
    ret

sort_fn:
    mov al, 3
    mov [cor], al

    call entradas
    call sort

    mov al, 10
    mov [cor], al

    call endl
    call cursor
    call getc ; esperar o usuario digitar
    ;call clear_screen
    call exit_to_shell

    ret

test_fn:
    mov si, str_test
    call print_str

    call getc

    mov al, 13
    call print_char

    mov ax, sort_fn
    mov [state], ax
    
    ret

homescreen_fn:
    mov si, mensagemi
    call print_str
    call exit_to_shell
    
    ret

cursor:
    pusha

    mov bl, 10
    mov bh, 0
    mov cx, 1
    mov al, '_'
    mov ah, 09h
    int 10h

    popa

    ret

ls_fn:
    mov si, comandos
    call print_str
    call exit_to_shell

    ret

; funcao para msg de erro
ef:
    mov si, erro_msg
    call print_str
    call exit_to_shell

    ret

about_fn:
    mov si, about_msg
    call print_str
    call exit_to_shell

    ret

; programa de shell
shell_fn:
    mov si, sprompt
    mov bl, 14
    call print_str_color

    xor dl, dl
    mov di, 0

    .input:
        call getc

        cmp dl, 0
        jne .notsave

        mov dl, al
    .notsave:
        mov bl, 15
        mov [cor], bl
        call putc

        cmp al, 13
        je .notsavearg

        cmp al, 32
        jne .notspace

        cmp di, 0
        jne .notspace

        mov di, arg
        jmp .notsavearg


    .notspace:

        cmp di, 0
        je .notsavearg

        stosb

    .notsavearg:

        cmp al, 13
    jne .input

    call endl

    mov al, dl ; a primeira letra ficou guardada em dl
    mov bl, 'a'

    sub al, bl ; pegamos o offset da letra em relacao a 'a'
    mov ah, 0
    mov bx, 2
    mul bx ; posicao do vetor

    mov bx, ctable
    add ax, bx
    mov bx, [eax]
    mov [state], bx

    cmp di, 0
    je .end

    ;mov al, 13
    ;stosb
    ;mov al, 10
    ;stosb
    mov al, 0
    stosb

    .end:
    ret

exit_to_shell:
    mov ax, shell_fn
    mov [state], ax

    ret

maze_fn:
    call clear_screen

    mov bx, 1200
    mov ax, 3
    .loop:

    inc ax
    add ax, bx
    dec bx

    push ax

    shr ax, 5
    and ax, 1
    cmp ax, 0
    je .b

    .a:
    mov al, '/'
    jmp .c
    .b:
    mov al, '\'
    jmp .c
    .c:
    call putc
    pop ax

    cmp bx, 0
    jne .loop

    call getc
    call clear_screen
    call exit_to_shell

    ret

screensaver:
    ; a screensaver with a square the bounces around changing colors
    pusha               ; save registers before function
    
    call clear_screen

    mov ax, 1           ; x position at start
    mov bx, 1           ; y position at start
    mov cx, 1           ; color at start
    mov dx, 0           ; moving state -> 0(right down), 1(right up), 2(left up), 3(left down) 
    

    .screensaver_animation_loop:    ; main animation loop 
    push ax                         ; save ax so we can use it as a
    mov ah, 01h                     ; int 16h parameter (get the state of the keybord buffer: 0 if there's nothing on it, non zero if there's something on it)
    int 16h                         ; checks if a key was pressed
    jz .screensaver_dont_exit       ; if no key was pressed, continue program (jump to .screensaver_dont_exit) 
                                    ; if a key was pressed, popa
    pop ax                          ; popa the saved registers before keyboad state check
    mov ah, 00h                     ; int 16h parameter (read key press: this is for clearing the buffer, especially critial if ENTER key was pressed)
    int 16h                         ; clears the buffer (reads the char on it)
    popa                            ; popa saved registers for this whole function
    call clear                      ; clear screen and exit to shell
    ret


    .screensaver_dont_exit:
    pop ax                            ; popa the saved registers before keyboard state check

    push 30                         ; square width

    mov bp, sp                      ; since sp can't be indexed, we use bp instead. bp now points to the square width

    call clear_screen
    cmp cx, 16                      ; checks if color value is equal to 16 (were considering the 15 BIOS colors. there is not a 16h color or grater.) 
    jne .scrensaver_continue        ; if the color value is not equal to 16, keep current color value and continue execution.
    mov cx, 1                       ; if the color valie is equal to 16, change it to 1 again.
    .scrensaver_continue:
    push dx                         ; save dx(moving state) so we can use it as an aux "variable" here.
    mov dx, [bp]                    ; bp is pointing to the square width
    draw_square ax, bx, dx, cx      ; draw the square given the parameters
    pop dx                          ; pop bp to it's original value (which is the moving state)

    ; inertia                       ; makes the square move accordingly to its moving state.
        ; check moving state (on dx) and update x and y accordingly

        ; right down inertia
    cmp dx, 0                        
    jne .screensaver_dont_right_down 
    inc ax              ; increase x
    inc bx              ; increase y
    .screensaver_dont_right_down:
        ; right up inertia
    cmp dx, 1
    jne .screensaver_dont_right_up 
    inc ax              ; increase x
    dec bx              ; decrease y
    .screensaver_dont_right_up:
        ; left up inertia
    cmp dx, 2 
    jne .screensaver_dont_left_up 
    dec ax              ; decrease x
    dec bx              ; decrease y
    .screensaver_dont_left_up:
        ; left down inertia
    cmp dx, 3
    jne .screensaver_dont_left_down     ; decrease x
    dec ax
    inc bx              ; increase y
    .screensaver_dont_left_down:

    ; moving state change (if the square touches one of the screen limits, changes the moving state accordingly to its current moving state and to what screen limit whas hit)
        ; if hits bottom ##################
    push ax                 ; pushes the registers to be used as aux
    push dx
    push bp
    mov ax, [bp]            ; ax = square width
    mov dx, 199             ; dx = bottom screen limit
    sub dx, ax              ; dx - width = leftmost upper pixel of the square when it hits the bottom screen limit
    cmp bx, dx              ; compare the x position of leftmost upper pixel of the square with its position if the square is hitting the bottom screen limit
    pop bp                  ; recover the registers
    pop dx
    pop ax
    jne .screensaver_dont_go_up ; (conditional) if leftmost upper pixel is not where it would be if the square hit the bottom screen limit, don't change mode to go up, jumps to next test 
    inc cx  ; increase color
            ; if moving state is right down, change to right up
    cmp dx, 0
    jne .screensaver_change_left_up
    mov dx, 1
    jmp .screensaver_end_func
            ; if moving state is left down, change to left up
    .screensaver_change_left_up:
    mov dx, 2
    jmp .screensaver_end_func
    .screensaver_dont_go_up:

        ; if hits up #################
    cmp bx, 0                           ; to check if the square hit the top screen limit is easy, just check if the leftmost (or any horizontal) uppermost pixel is = 0.
    jne .screensaver_dont_go_down       ; conditional
    inc cx  ; increase color
            ; if moving state is left up, change to left down
    cmp dx, 2
    jne .screensaver_change_left_down
    mov dx, 3
    jmp .screensaver_end_func
            ; if moving state is right up, change to right down
    .screensaver_change_left_down:
    mov dx, 0
    jmp .screensaver_end_func
    .screensaver_dont_go_down:

        ; if hits right ##################
    push bx                             ; save registers to use as aux
    push dx
    push bp
    mov bx, [bp]                        ; gets square width from stack
    mov dx, 319                         ; the screen is 320 pixels wide
    sub dx, bx                          ; subtracts the last horizonal pixel position with de square width
    cmp ax, dx                          ; compares the square leftmost pixels x position with the last x position possible (for a 320 pixels wide screen)
    pop bp                              ; restores the registers
    pop dx
    pop bx
    jne .screensaver_dont_go_left       ; conditional (if it )
    inc cx  ; increase color
            ; if moving state is up right 
    cmp dx, 1
    jne .screensaver_change_left_down_2         ; conditional
    mov dx, 2
    jmp .screensaver_end_func
            ;if moving state is down right
    .screensaver_change_left_down_2:
    mov dx, 3
    jmp .screensaver_end_func
    .screensaver_dont_go_left:

        ; if hits left ##################
    cmp ax, 0                                                               
    jne .screensaver_dont_go_right              ; conditional
    inc cx  ; increase color
            ; if moving state is left down
    cmp dx, 3
    jne .screensaver_change_right_up
    mov dx, 0
    jmp .screensaver_end_func
            ; if moving state is up left
    .screensaver_change_right_up:
    mov dx, 1
    jmp .screensaver_end_func
    .screensaver_dont_go_right:

    .screensaver_end_func:                      ; when all the update has been done,
    add sp, 2                                   ; cleans square width from stack
    DELAY 0, 10000                               ; applies a delay of 1000 low-word of a microsecond

    jmp .screensaver_animation_loop             ; jump to next animation frame


clear:
    call clear_screen
    call exit_to_shell
    ret

echo:
    mov si, arg
    mov al, '<'
    call putc
    call print_str
    mov al, '>'
    call putc
    mov al, 32
    call putc
    call endl
    call exit_to_shell

    ret

cow_fn:
    ;mov si, cowCmd
    ;call print_str

    ;call get_string
    ;call endl
    ;call endl

    mov al, '<'
    call putc
    mov si, arg
    call print_str
    mov al, '>'
    call putc

    mov si, blkS
    call print_str

    mov si, cow1
    call print_str
    mov si, cow2
    call print_str
    mov si, cow3
    call print_str
    mov si, cow4
    call print_str
    mov si, cow5
    call print_str

    call exit_to_shell

    ret

reverse_fn:
    ;mov si, reverseCmd
    ;call print_str

    ;call get_string
    call get_reverseString
    ;call endl   
    ;call endl 

    mov al, '-'
    call putc
    mov al, '>'
    call putc
    mov al, ' '
    call putc
    mov si, reverseMsg
    call print_str
    mov al, ' '
    call putc
    mov al, '<'
    call putc
    mov al, '-'
    call putc

    call endl

    call exit_to_shell

    ret

hello_there:
    mov si, str3
    call print_str
    call exit_to_shell
    ret

start:
    xor ax, ax      ; just cleaning up some registers
    mov ds, ax
    mov es, ax

    call init_video

    mov ax, homescreen_fn
    ;mov ax, shell_fn
    mov [state], ax

    ; Loop para mudar de estados
    ; Cada estado precisa ter uma função que modifica o valor de state para
    ; a label do próximo estado
    .loop: 
    
    mov ax, [state]
    call eax

    jmp .loop

jmp $
