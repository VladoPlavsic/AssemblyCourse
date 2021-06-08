.model small
.stack 100h
.data

port_address dw ? ; базовый адрес порта
text_out db '01234567',0Dh,'$' ; передаваема¤ строка
text_in db 50 dup(?) ; буфер дл¤ считывани¤ строки
error_flag db ? ; признак ошибки приема

.code
; инициализаци¤ сегментных регистров
mov ax,@data
mov ds,ax
xor ax,ax
mov es,ax

; чтение базового адресного порта COM1
mov dx,es:[400h]
mov port_address,dx

; разрешение доступа к регистрам DLL и DLM (установка DLAB=1)
; –егистры DLL и DLM используютс¤ дл¤ установки скорости передачи/приема. ¬ них заноситс¤ делитель D
; ”правление битом DLAB производитс¤ в регистре LCR.
; Ќазначение бит регистра LCR:
; Ч Ѕит 7 Ц DLAB =1, доступ к регистрам DLL,DLM.
mov dx,port_address
add dx,3 ; адрес регистра LCR
in al,dx ; ввод содержимого регистра LCR в AL
or al,10000000b ; в старшем разр¤де AL - единица
out dx,al

; установка скорости передачи
mov dx,port_address ; смещение регистра DLL = 0
mov al,192 ; делитель D = 115200/V (V=600 bps)
out dx,al
add dx,1 ; адрес регистра DLM
mov al,0 ; старший байт делител¤
out dx,al

; запрет доступа к регистрам DLL и DLM, установка битов данных и стоповых битов
mov dx,port_address
add dx,3
mov al,00011111b ;
out dx,al ;

;запрет режима FIFO
mov dx,port_address
add dx,2
in al,dx
and al,0FEh ; устанавливаем нулевой бит в 0
out dx,al

;========== передача ======================
; настройка SI на передаваемую строку
mov si,offset text_out

output:
; опрос готовности передатчика
mov dx,port_address
add dx,5 ; dx -> LSR
in al,dx
; Ќазначение бит регистра LSR
; Ч Ѕит7 = 0, если запрещен режим FIFO.
; Ч Ѕит6 Ц TEMPT =0, если регистр передатчика пуст.
; Ч Ѕит5 Ц готовность записи данных в регистр передатчика. (1 - rdy , 0 - not rdy)
test al,00100000b
jz output

; ѕередача символа
mov dx,port_address
mov al,[si]
out dx,al

inc si ; к следующему символу

cmp al,'$'
jnz output ; продолжаем, пока не встретим '$'

;============= прием =============

; настройка SI на приемный буфер
mov si,offset text_in

input:
mov dx,port_address
add dx,5 ; адрес регистра LSR
in al,dx
test al,1h ; провер¤ем значение 0-го бита (готовность к передаче)
jz input ; если в нЄм 0 - повтор¤ем проверку (ждем), иначе идЄм дальше

and al,00000100b ; оставл¤ем только значение 2-го бита LSR
mov error_flag,al ; error_flag=0 если ошибок нет

; в любом случае считываем символ и запоминаем в буфере
mov dx,port_address ; адрес регистра RBR
in al,dx
mov [si],al

cmp error_flag,0
je no_error
mov al,'#' ; в случае ошибки будем выводить решетку вместо символа
no_error:
mov dl,al ; символ будет выводитьс¤ из dl

; вывод символа, лежащего в DL
mov ah,06h
int 21h


inc si ; к следующей позиции в буфере

cmp byte ptr [si-1],0Dh
jnz input ; продолжить ввод, если не прин¤т признак конца сообщени¤ 0Dh

;========== конец программы ==============

mov ax,4C00h
int 21h

end