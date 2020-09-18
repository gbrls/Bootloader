org 0x7e00
jmp 0x0000:start

data:
	;vetor TIMES 10 DW 0
    str1 db 'Digite o tamanho do vetor: ', 13, 10, 0
    str2 db 'Digite o vetor: ', 13, 10, 0
    v TIMES 100 db 0
    n db 0
    i db 0
    j db 0
    aux db 0
	;Dados do projeto...

init_video:
    mov ah, 00h ;escolhe modo video
    mov al, 13h ;modo VGA
    int 10h

    ret

delay1:
    pusha

    ; http://www.techhelpmanual.com/221-int_15h_86h__wait.html

    mov ah, 86h
    mov cx, 00
    mov dx, 00

    int 15h

    popa

    ret

delay:
    pusha

    mov cl, 30
    .loop:
        dec cl
        call delay1
        cmp cl, 0
        jne .loop

    popa
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

print_char:
    pusha

    
    mov ah, 0xe
    int 10h

    popa
    ret

jmp_line:
    mov ah, 02h            
    mov bh, 0
    add dh, 1
    mov dl, 0
    int 10h
    ret

newline:
    pusha
    mov al, 13 ; mover o cursor para o inicio da linha
    call print_char
    ;mov al, 10 ; descer o cursor uma linha
    ;call print_char
    popa
    ret

print_str:

    lodsb

    cmp al, 13
    je done

    mov ah,0xe
    mov bl, 2
    int 10h

    jmp print_str

    done:
        ret

print_array:
    pusha

    mov si, v
    mov cl, [n]

    .loop:
        call delay

        lodsb

        call print_num
        mov al, ' '
        call print_char

    dec cl
    cmp cl, 0
    jg .loop
    
    call newline

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
        call jmp_line
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

    cmp al, 13
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
        ret

get_array:

    mov si, str2
    call print_str
    call jmp_line

    mov si, v
    mov cl, [n]

    .loop:

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

start:
    xor ax, ax
    mov ds, ax
    mov es, ax

    call init_video
    call entradas
    call jmp_line
    call sort

jmp $
