; Варинта 14

; Lab4
; Написать программу, заменяющую все десятичные цифры  в ис­ходной строке на заданный символ, Z-string;
; Z-string - строка, завершающаяся нулем. Признак конца строки - символ с кодом 0. Длина строки нигде специально не хранится. 
; После нуля в буфере, выделенном под строку, может располагаться "мусор", который игнорируется при обработке.

; Lab6
; Авторекурсия (вызов процедурой "самой себя").

.model small
.stack 100h

NEW_LINE_CHAR EQU 0Ah
TERMINATION_CHAR EQU 00h
ENTER_KEY_CODE EQU 0Dh

.data
    enter_string db 'Please enter character: $'
    initial_string dw (?) ; 't', 'h', '1', 's', ' ', '1', 's', ' ', 's', 't', 'r', '1', 'n', 'g', TERMINATION_CHAR

.code
; 0 - 30h
; 1 - 31h
; ...
; 9 - 39h
org 00h
jmp start
final_string dw (?)

org 100h
start:
    mov ax, @data
    mov ds, ax ; ds:si - lodsw
    mov si, offset initial_string

    mov es, ax
    mov di, si

    cld ; -> all string operations go this (->) way DF = 0

    ; enter string from stdin
    call get_string
    mov ax, TERMINATION_CHAR
    stosw

    ; set di to final_string
    mov di, offset final_string

    ; load dx with offset of string we want to print
    mov dx, offset enter_string
    ; print string
    call print_string

    ; get char from stdin
    call get_char
    push ax
    ; print new line char after echoing STDIN
    mov dl, NEW_LINE_CHAR
    call print_char
    pop ax

    xor bx, bx
    mov bl, al ; store character

call check

check proc
    pop ax ; recursion pushes return point every time call is called,
           ; but we don't need to return anywhere, so just pop it every time
    lodsw
    call check_if_number
    stosw
    cmp ax, TERMINATION_CHAR
    jne $+5
    call print
    call check
check endp

check_if_number proc
    cmp al, 30h
    jl return
    cmp al, 39h
    jg return
    mov al, bl
    return:
        ret
check_if_number endp

get_string proc
    call get_next
    get_next proc
        pop ax
        xor ax, ax
        call get_char
        cmp al, ENTER_KEY_CODE
        jne $+3
        ret
        stosw
        call get_next
    get_next endp
get_string endp

print proc
    pop ax
    mov si, offset final_string
    call print_next
    print_next proc
        pop ax
        lodsw
        cmp ax, TERMINATION_CHAR
        jne $ + 5
        call end_e
        mov dx, ax
        call print_char
        call print_next
    print_next endp
print endp

print_char proc
    mov ah, 06h ; print char
    int 21h
    ret
print_char endp

print_string proc
    mov ah, 09h ; print array [start DX all the way to $]
    int 21h
    ret
print_string endp

get_char proc
    mov ah, 01h ; stdin with echo
    int 21h
    ret
get_char endp

end_e proc
    pop ax
    mov ax, 4C00h ; al = exit code
    int 21h
end_e endp

end
