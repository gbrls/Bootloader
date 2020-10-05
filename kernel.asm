org 0x7e00
jmp 0x0000:start

data:
	;vetor TIMES 10 DW 0
    str1 db 'Digite o tamanho do vetor: ', 13, 10, 0
    str2 db 'Digite o vetor: ',13,10,0
    str3 db 'General Kenobi',13,10,0
    str_test db 'Pressione qualquer tecla', 13, 10, 0
    comandos db 'ls - Lista os comandos disponiveis.',13,10,'bubble - Veja o bubble sort em acao.',13,10,'selection - Veja o selection em acao.',13,10,'about - Informacoes sobre o sistema.',13,10,'maze - Gere um quase labirinto',13,10,'quadrado - Screensaver com um quadrado',13,10,'vaquinha - Veja uma vaca falar.',13,10,'inverter - Exibe uma mensagem invertida',13,10,'clear - Limpar a tela',13,10,'echo - Printa os argumentos',13,10,'planetas - Veja os planetas rochosos',13,10,0

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
    ctable dw about_fn, sort_fn, clear, ef, echo, ef, ef, hello_there, reverse_fn, ef, ef, ls_fn, maze_fn, ef, ef, planets_fn, screensaver, ef, s_sort, ef, ef, cow_fn, ef, ef, ef, ef


    life_on_mars db 'Is there life on mars?',13,10,0

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
    push es
    mov es, ax          ; set the es with the VGA VIDEO RAM segment adress.
  
    mov ax, [bp+2]      ; get y position from stack
    mov cx, 320         ; width in pixels of the screen
    mul cx              ; update ax (and dx?) with the result
    add ax, [bp+4]      ; add x position to result   
    
    mov bx, ax          ; mov x position from ax to bx (al is needed below)
    mov al, [bp+6]      ; get color from stack
    es mov [bx], al     ; TODO: explain     
    pop es

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

    mov si, v ; moves to si the beginning of the array
    mov cl, [n] ; moves to cl the size of the array

    .loop:
        lodsb ; loads on ah the element which si is pointing and inc si

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

; Bubble sort's swap procedure
swap: 
    pusha

    mov al, [si]
    mov bl, [si+1]
    mov [si+1], al
    mov [si], bl

    popa
    ret

selec_swap: ; Selection sort's swap procedure

    mov al, [bp]
    mov bl, [di]
    mov [di], al
    mov [bp], bl

    dec di ; di initially points to the end of the array, but after each iteration greatest element is saved there and di decrements 

    ret

selection: ; selection sort

    mov bh, [n] ; save on bh the size of the array, used on the outer_loop
    mov di, v ; move to di the beginning of the array

    ;we need a pointer to the end of the array , so we move to ax (n-1) and adds it to di, so that the final position pointed by di is the end of the array
    mov ax, [n] 
    dec ax 
    add di, ax 

    .outer_loop:

        mov si, v ; pointer to the beginning of the array
        mov bl, bh ; inner_loop counter initial value = outer_loop counter

        mov bp, si ; another pointer to the array which will be used on the swap procedure, bp intially points to the first element of the array and at the 
                   ; end it will be pointing to the greatest element in the interval


        .inner_loop:
            
            push cx
            push dx
            mov cx, 0Fh
            mov dx, 0

            DELAY 0x2, 0x0 ; delay to help visualize the algorithm

            pop dx
            pop cx

            inc bh
            mov [cor], bh ; the value on bh sets the color of the char printed on the screen, by changing it every iteration the array will be printed in another
                          ; color and by doing so we can more easily show what happens in each step of the algorithm 
            dec bh

            call print_array

            mov al, [si]
            mov cl, [bp]
            cmp cl, al ; compares the greatest value so far with the value on si 

            jg .end_inner_loop ; if the value on si is not bigger we don't need to swap

            mov bp, si    ; otherwise saves on bp the index of the greatest element so far
            


    .end_inner_loop:

        inc si ; moves to the next element of the array
        dec bl

    cmp bl, 0 
    jg .inner_loop ; inner_loop counter > 0

    ; end of the inner_loop
    call selec_swap  ; swap the element stored on bp with the element saved on di which in the beginning of the sort points to the end of the array
    dec bh
    cmp bh, 0
    jg .outer_loop 

    ret 

s_sort: ; function used to call the selection_sort
    mov al, 3
    mov [cor], al

    call entradas ; gets the size of the array and its elements
    call selection ; calls the sort

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

    mov bh, [n] ; saves the size of the array on bh, used on the outer_loop

    ; Vamos chamar o outer loop n vezes
    ; e dentro deste loop vamos percorrer o array
    ; até arr[n-2] e sempre trocando arr[i] com arr[i+1]
    ; se arr[i] > arr[i+1]

    .outer_loop:

    mov si, v ; pointer to the beginning of the array
    mov bl, [n] ; saves the size of the array on bl, used on the inner_loop

    .inner_loop:
        
        push cx
        push dx
        mov cx, 0Fh
        mov dx, 0

        DELAY 0x2, 0x0 ; call a delay to help visualize how the algorithm works

        pop dx
        pop cx

        inc bh
        mov [cor], bh ; the value on bh sets the color of the char printed on the screen, by changing it every iteration the array will be printed in another
                      ; color and by doing so we can more easily show what happens in each step of the algorithm 
        dec bh

        call print_array
        mov al, [si]
        mov cl, [si+1]
        cmp al, cl ; compares v[i] with v[i+1] to check if a swap is needed 

        ; if v[i] is less or equal to v[i+1] we don't need to swap
        jle .end_inner_loop 

        call swap ; call the swap function
    .end_inner_loop:

        inc si ; next element of the array 
        dec bl ; 

    cmp bl, 1 ; no need to compare to 0 because we're only aiming to get to n-2
    jg .inner_loop ; if greater than 1 -> next iteration of the inner_loop

    dec bh ; outer_loop counter --

    cmp bh, 0 ; if we reached the end of the array -> bubble sort is finished
    jg .outer_loop

    pop ebp

    ret

get_n: 

    mov si, str1
    call print_str ; Enter the size N of the array

    xor ah, ah
    int 16h  ; gets the first char

    call print_char

    sub al, '0' ; char -> int
    mov [n], al ; saves it on the variable n

    xor ah, ah
    int 16h ; gets the second char
    
    call print_char

    cmp al, 13 ; is it equal to '\n'
    je .end 

    sub al, '0' ; char -> int
    mov [aux], al

    mov al, [n]
    mov cl, 10
    mul cl ; multiplies the first number by 10 

    add al, [aux] ; adds first*10 + second 
    mov [n], al ; saves it on N

    xor ah, ah
    int 16h ; finally gets the '\n'
    
    call print_char

    .end:
        call endl
        ret

get_reverseString:
    mov si, arg
    mov di, reverseMsg

	mov cl,0
	.for:                ;O primeiro loop pega todos os caracteres da string apontada por SI.
		lodsb            ;A cada iteração, ele pega o próximo caractere com a função lodsb (que
		cmp al, 0        ;carrega o caractere apontado por SI e joga em AL, depois disso incrementa SI
		je .end          ;e coloca esse caractere na pilha. Após acabar todos os caracteres, eles estarão
		push ax          ;na pilha, agora quando formos remover esses caracteres da pilha, já iremos obter a
		inc cl           ;string invertida. O segundo loop está aqui exatamente por isso, ele pega cada
		jmp .for         ;caractere do topo da pilha e carrega na posição que DI está apontando, usando a função
	.end:                ;stosb (coloca o valor de AL na posição que DI aponta e depois incrementa DI).
	.for1:               ;Para sabermos quantas vezes precisamos tirar o elemento da pilha, usamos o registrador CX, que
		cmp cl,0         ;é incrementado no primeiro loop e decrementado no segundo, portanto quando CX == 0, signifca
		je .end1         ;que você deve parar de pegar os valores da pilha, ou seja, já obtemos a nossa string invertida
		dec cl           ;e ela está salva em reverseMsg, que foi onde DI estava apontando.
		pop ax
		stosb
		jmp .for1
	.end1:

    mov al,0
    stosb

	ret

getValue:

    xor ah, ah
    int 16h ; gets the first char

    call print_char

    sub al, '0' ; char -> int
    mov dl, al 

    xor ah, ah ; gets the second char
    int 16h
    
    call print_char

    cmp al, 13 ; is it '\n' or another number?
    je .end ; == '\n', only 1 digit

    sub al, '0' ; second digit - char -> int
    mov [aux], al

    mov al, dl
    mov bl, 10
    mul bl ; multiplies the first digit by 10

    add al, [aux] ; adds the two numbers and saves it on dl
    mov dl, al

    xor ah, ah ; finally gets the '\n'
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
    call print_str ; "Enter the elements of the array: "

    mov si, v ; mov to si the beginning of the array
    mov cl, [n] ; mov to cl the size of the array

    .loop:
        call cursor
        call getValue ; gets each value of the array and saves it on dl

        mov [si], dl ; puts the value on the array

        inc si ; next position of the array

        dec cl ; i--
        cmp cl, 0 ; if equals to 0 we alredy went through the whole array
        jg .loop ; if not, get the next element
    ret

entradas:
    call get_n ; gets the size N of the array
    call get_array ; gets N elements and saves it on the array
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

; A wrapper around the sort that was implemented before the shell
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

; not used
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

; Procedure to print a error
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

; shell procedure
shell_fn:
    ; Print prompt
    mov si, sprompt
    mov bl, 14 ; yellow
    call print_str_color

    ; dl is used as an auxiliary varible to store whether a key has been pressed yet.
    ; We only use the command's first character to call it's procedure.
    xor dx, dx 
    xor ax, ax
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

        ; Here we have to check some stuff in order to be able to distinguish betweeen the command and the argument
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

    mov al, dl ; the first character is stored in dl 
    mov bl, 'a'

    sub al, bl  ; calculating the character's position on the alphabet (kind of)
    mov ah, 0
    mov bx, 2
    mul bx ; calculationg it's position in the commands's jump table

    ; this is like a deferred jump because in the main loop we will jump to [state]
    mov bx, ctable
    add ax, bx
    mov bx, [eax]
    mov [state], bx

    cmp di, 0
    je .end

    ; Appending a '\0' to the argument's string (it works like a C string)
    mov al, 0
    stosb

    .end:
    ret

; Simple helper procedure to abstract the default state transition.
; This is the only requirement that a prodecure have to satisfy in order to be able to be called by the shell.
exit_to_shell:
    mov ax, shell_fn
    mov [state], ax

    ret

; This program is really simple, we just print / or \ randomly.
; The only problem is how to select a number randomly...
; I saw some methods on the internet but they required too many variables or operations that'd be hard to implement in assembly
; So I basically sum some numbers together and shift the result to print / or \ based on the last bit.
; It isn't any close to a random number generator but it does generate a nice pattern.
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
    push ax                         ; save ax so we can use it as aux
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


; Resets the cursor and video memory
clear:
    call clear_screen
    call exit_to_shell
    ret

; A small program/procedure to show how to use command line arguments.
; hint: the string is stored in arg and that's it.
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

; x, y, rad, color, inner radius
draw_circle:

    push bp
    mov bp, sp

    mov dx, 320
    .w:
        mov cx, 200
        .h:

        push dx
        push cx

        mov ax, [bp+6]
        sub cx, ax

        mov ax, cx
        imul cl

        mov bx, ax

        mov ax, [bp+4]
        sub dx, ax

        mov ax, dx
        imul dl
        add ax, bx
        ;mul ax ; ax = dx * dx

        ;add ax, bx ; ax = dx * dx  + bx * bx

        pop cx
        pop dx

        mov bx, ax
        mov ax, [bp+10]
        cmp bx, ax
        jg .notprint
        mov ax, [bp+12]
        cmp bx, ax
        jl .notprint

        mov ax, [bp+8]
        put_pixel dx, cx, ax

        .notprint:

        dec cx
        cmp cx, 0
        jg .h

    dec dx
    cmp dx, 0
    jg .w

    pop bp

    ret

%macro PLANET 5
    pusha

    push %5
    push %4
    push %3
    push %2
    push %1
    
    call draw_circle

    add sp, 10
    popa
%endmacro

planets_fn:
    call clear_screen

    ; The Sun
    PLANET 160, 100, 0eh, 800, 0


     Mercury
    PLANET 160, 100, 0fh, 1225, 1150
    PLANET 125, 100, 16h, 10, 0

    ; Venus
    PLANET 160, 100, 0fh, 2025, 1920
    PLANET 115, 100, 2ah, 12, 0

    ; Earth
    PLANET 160, 100, 0fh, 4225, 4100
    PLANET 95, 100, 37h, 13, 0

    ; Moon
    PLANET 95, 100, 0fh, 90, 80
    PLANET 86, 100, 1bh, 8, 0

    ; Mars
    PLANET 160, 100, 0fh, 8100, 8000
    PLANET 70, 100, 28h, 13, 0
    
    call getc

    mov si, life_on_mars
    mov bl, 28h
    call print_str_color

    call getc

    ;call clear_screen
    call exit_to_shell
    ret

cow_fn:
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
    mov si, cow4         ;Basicamente essa função exibe o argumento passado pelo usuário na tela no
    call print_str       ;seguinte formato: "<argumento>" e logo após isso, exibe 5 strings que compõe
    mov si, cow5         ;a vaca (strings essas que foram declaradas no data do código) utilizando a
    call print_str       ;função print_str. Logo após isso, a função exit_to_shell é chamada para o continuação
                         ;do código.
    call exit_to_shell

    ret

reverse_fn:
    call get_reverseString
    
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
    call putc            ;Basicamente a função capta o argumento passado pelo usuário
                         ;e exibe o argumento ao inverso. Primeiro é impresso na tela os
    call endl            ;seguintes caracteres: "-> ", após isso pegamos a saída da função get_reverseString
                         ;(no caso é a string reverseMsg) que basicamente é o argumento passado pelo usuário
    call exit_to_shell   ;invertido. Após isso imprimimos na tela com a função print_str a string reverseMsg
                         ;e finalizamos imprimindo na tela os seguintes caracteres: " <-". Após isso uma quebra
    ret                  ;de linha é feita e a função exit_to_shell é chamada para a continuação do código.

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

    ; Main loop:
    ; Each procedure stores in [state] which state it is going to transition to, so it works like a deferred jump.
    ; Why is it like this and not made with regular calls or jumps?
    ; If it were with direct calls, the stack would grow indefinitely. 
    ; If it were implemented with direct jumps at the end of each procedure we wouldn't have control over what happens when a procedure exits.
    ; Also, jumps are scary, if we abstract them in a nice state machine things behave nicely :)
    .loop: 
    
    mov ax, [state]
    call eax ; using the "program's" label to call it like a normal procedure

    jmp .loop

jmp $
