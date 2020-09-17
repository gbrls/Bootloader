org 0x7e00
jmp 0x0000:start

data:
	;vetor TIMES 10 DW 0
    v db 3, 4, 1, 7, 6, 2, 9
    n db 7
    i db 0
    j db 0
	;Dados do projeto...

init_video:
    mov ah, 00h ;escolhe modo video
    mov al, 13h ;modo VGA
    int 10h

    ret

delay:
    pusha

    ; http://www.techhelpmanual.com/221-int_15h_86h__wait.html

    mov ah, 86h
    mov cx, 01
    mov bx, 100

    int 15h

    popa

    ret

;TODO: implementar uma função para printar números até 99
print_num:
    call print_char
    ret

print_char:
    pusha

    ;mov bl, 2 ; qual cor

    mov ah, 0xe
    int 10h

    popa
    ret

newline:
    pusha
    mov al, 13 ; mover o cursor para o inicio da linha
    call print_char
    ;mov al, 10 ; descer o cursor uma linha
    ;call print_char
    popa
    ret

print_array:
    pusha

    mov si, v
    mov cl, [n]

    .loop:
        call delay

        lodsb
        add al, '0'

        call print_num

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

start:
    xor ax, ax
    mov ds, ax
    mov es, ax

    call init_video
    call sort

jmp $
