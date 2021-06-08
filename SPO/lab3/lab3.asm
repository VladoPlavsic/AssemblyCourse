;14. Задан массив указателей на двухбайтовые числа со знаком. Заменить все указатели на числа меньше 10 на нулевые указатели.
.model small
.stack 100h
.data
len equ 10
raw_data dw 10d, 20d, 85d, 15d, -9d, 5d, 75d, 85d, 9d, 50d
pointers dw len dup(0)
NULL dw 00000000b
.code
start:

    mov ax, @data
    
    mov ds, ax
    mov es, ax
    
    mov di, offset raw_data
    mov si, offset pointers

    xor cx, cx
    mov cx, len
load_pointers:
    
    mov ax, di       ; load pointer to raw_data offset to ax
    mov [si], ax     ; load value of ax to address si 

    inc di
    inc di
    inc si
    inc si

    dec cx
    jnz load_pointers
    xor cx, cx
    mov cx, len
    mov si, offset pointers
    jmp check

check:
    mov bx, [si]          ; load bx with value from si [address of integer]
    mov ax, word ptr [bx] ; load value from addres [bx]
    cmp ax, 00001010b     ; compare against 10
    jl swap               ; if comaration resulted in AX < 10, AX = 0ptr
    jmp next

swap:
    mov ax, offset NULL ; AX = 0ptr
    mov [si], ax        ; load 0ptr to that address
    jmp next

next:
    inc si
    inc si
    dec cx
    jnz check
    jmp print_numbers
 
print_numbers:
    mov bx, len               ; outer loop (loop for each number)
    mov si, offset pointers
    load_value: 
        mov cx, 0d            ; inner loop
        push bx
        mov bx, [si]
        mov ax, word ptr [bx] ; load value to ax
        pop bx
        inc si
        inc si
        loop1:
            call dividebyten    ; devide by 10, get reminder
            push dx             ; push reminder to stack (e.g.) 255 / 10 => AX = 25 DX = 5 -> 25 / 10 => AX = 2 DX = 5 -> 2 / 10 => AX = 0 DX = 2 -> stack [2, 5, 5]
            inc cx              ; increment number digit count
            cmp ax, 0           ; check if result in AX is 0 -> if not repeat
            jne loop1           
        loop2:
            pop dx              ; get next digit for printing
            add dl, '0'         ; add 0 termination character
            call print          ; print character
            dec cx              ; decrement counter
            jne loop2           
            call print_new_line ; print new line
            mov cx, bx          ; load outer loop value
            dec cx              ; decrement outer loop value
            jz exit             ; if outer loop == 0 exit   
            mov bx, cx          ; save outer loop value into bx
            jmp load_value      ; load new value and print it 

dividebyten:
    xor dx, dx
    push bx                     ; store outer loop counter value for a moment
    mov bx, 00001010b;          ; add 10 to BX
    div bx                      ; devide by 10 AX = int result, DX = reminder
    pop bx                      ; retrive outer loop counter value
    ret                         ; return

print:
    mov ah, 2
    int 21h
    ret

print_new_line:
    mov dl, 10
    mov ah, 2
    int 21h
    ret

exit:
    mov ax, 4C00h
    int 21h
    end
