; комментарий с указанием:
; - фамилии и группы студента
; - варианта
; - краткой формулировки задания
.model small ; один сегмент кода, данных и стека
.stack 100h  ; отвести под стек 256 байт
.data   ; начало сегмента данных
S db 'Hello, World!$'
.code   ; начало сегмента кода
 ; Начальная инициализация
 mov ax,@data
 mov ds,ax  ; настройка DS на начало сегмента данных

 ;-------------------------------------------------
 ; Здесь – код в соответствии с заданием, например

 ;14.* DOS  Int 21h, func.40h (вывод строки символов на экран.  
 ;Указание: Дескриптор устройства-Дисплей  равен 1, т.е. BX=1 ).


 mov ah,40h  ; номер функции DOS
 mov BX, 1 ;display as descriptor
 mov cx, 13 
 mov dx, offset S
 int  21h  ; Вывод строки на экран в текущей позиции курсора
 ;--------------------------------------------------

 ; Стандартное завершение программы
 mov ax,4C00h ; ah = N функции, al = код возврата
 int 21h  ; снять программу с выполнения

 end  ; конец текста программы
