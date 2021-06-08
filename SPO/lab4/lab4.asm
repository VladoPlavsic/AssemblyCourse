; 14. Написать программу, заменяющую все десятичные цифры  в ис­ходной строке на заданный символ, Z-string;
; Z-string - строка, завершающаяся нулем. Признак конца строки - символ с кодом 0. Длина строки нигде специально не хранится. 
; После нуля в буфере, выделенном под строку, может располагаться "мусор", который игнорируется при обработке.

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

check:
    lodsw
    call check_if_number
    stosw
    ; -- or -- ;
    ; dec si
    ; dec si
    ; movsw
    ; -------- ;
    cmp ax, TERMINATION_CHAR
    je print
    jmp check


jmp pass ; if you get to here, jump over next set of instructions
check_if_number:
    cmp al, 30h
    jl return
    cmp al, 39h
    jg return
    mov al, bl
    return:
        ret

get_string:
    get_next:
        xor ax, ax
        call get_char
        cmp al, ENTER_KEY_CODE
        je return
        stosw
        jmp get_next

print:
    mov si, offset final_string
    print_next:
        lodsw
        cmp ax, TERMINATION_CHAR
        je end_e
        mov dx, ax
        call print_char
        jmp print_next

print_char:
    mov ah, 06h ; print char
    int 21h
    ret

print_string:
    mov ah, 09h ; print array [start DX all the way to $]
    int 21h
    ret

get_char:
    mov ah, 01h ; stdin with echo
    int 21h
    ret

pass: ; all the way here
    nop

end_e:
    mov ax, 4C00h ; al = exit code
    int 21h

end
