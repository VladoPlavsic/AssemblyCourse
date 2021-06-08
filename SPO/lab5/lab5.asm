; ЗАДАНИЕ:
;   Разработать индивидуальную программу для .COM-файла. 
;   Допускается взять в качестве прототипа свою программу Лаб. #1  ( Ввод-Вывод в TASM ). 
;   В программе иметь секции Данных и явно работать со Cтеком. 
;   Использовать Отладчик для выявления начальной установки регистров и определения типов адресов.


; Создать "собственный" Стек в области кодов программы.

.model tiny

.code
    org 100h
begin:
    jmp start

    ; offset для стека
    ; org 0EFFDh
    ; my_sp label dw

    org 0EFFFh
start:

; assume es:my_stack
; mov ax, my_stack
; mov ss, ax
; mov ax, 0FFFFh
; mov sp, ax

    cli

    ; --- .EXE ---
    mov ax, cs

    mov ss, ax
    mov ds, ax
    mov es, ax
    ; ------------

    mov ax, 0EFFDh
    mov sp, ax

    sti

    push ax
    push ax
    push ax

    pop ax
    pop bx
    pop cx

    ; --- .EXE ---
    mov ah, 62h
    int 21h
    mov ds, bx
    ; ------------

    xor bx, bx
    mov bl, ds:[80h]
    cmp bl, 07Eh
    ja exit

    mov byte ptr ds:[bx+81h], '$'

    mov ah, 09h
    mov dx, 82h
    int 21h

; my_stack SEGMENT at SOMEWHERE
; org FFFFh
; my_stack ENDS


exit:
    mov ax, 4C00h
    int 21h

end begin
