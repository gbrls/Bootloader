org 0x7e00
jmp 0x0000:start

data:
	;vetor TIMES 10 DW 0
    str1 db 'Digite o tamanho do vetor: ', 13, 10, 0
    str2 db 'Digite o vetor: ',13,10,0
    str_test db 'Pressione qualquer tecla', 13, 10, 0
    comandos db 'ls - Lista os comandos disponiveis.',13,10,'bubble - Veja o bubble sort em acao.',13,10,'about - Informacoes sobre o sistema.',13,10,'maze - Gere um quase labirinto',13,10,0

    mensagemi db 'Sistema operacional X - Ver 0.0.1',13,10,'Empresa de software Ltda. (1984)',13,10,0

    erro_msg db 'Comando nao reconhecido (o_o)',13,10,0
    about_msg db 'Esse sistema foi desenvolvido por ...',13,10,0
    sprompt db 'MY-PC>',0

    ; array com o comando para cada char
    
    ;      a            b   c   c ...
    ctable dw about_fn, bubble_fn, ef, ef, ef, ef, ef, ef, ef, ef, ef, ls_fn, maze_fn, ef, ef, ef, ef, ef, ef, ef, ef, ef, ef, ef, ef, ef

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

_delay:
    push ax
    ; http://www.techhelpmanual.com/221-int_15h_86h__wait.html

    mov ah, 86h

    int 15h

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
print_str:

    DELAY 0, 0x4000
    
    lodsb

    cmp al, 0
    je .done

    mov ah,0xe
    mov bl, 10
    int 10h

    jmp print_str

    .done:
        call cursor
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
    
bubble_sort:
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

getValue:

    xor ah, ah
    int 16h

    call print_char

    sub al, '0'
    mov dl, al

    xor ah, ah
    int 16h
    
    call print_char

    cmp al, 13 ; Pressinou espaço?
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

bubble_fn:
    mov al, 3
    mov [cor], al

    call entradas
    call bubble_sort

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

    mov ax, bubble_fn
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
    call print_str

    xor dl, dl

    .input:
        call getc

        cmp dl, 0
        jne .notsave

        mov dl, al
    .notsave:
        call putc

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

start:
    xor ax, ax
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
