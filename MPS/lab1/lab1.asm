; комментарий с указанием:
; - фамилии и группы студента
; - варианта
; - краткой формулировки задания
.model small	; один сегмент кода, данных и стека
.stack 100h		; отвести под стек 256 байт
.data
freqs dw 0FFFAh, 3619, 2711, 2280, 2280, 2031, 2280, 2415, 0FFFAh, 2031, 2280, 2415, 0FFFAh, 0FFFFh ;1 193 182 / frequency of our signal
times dw 12, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 12, 12
    

.code	
		mov 	ax, @data
		mov 	ds, ax
		
		xor		di, di
		xor		si, si
		
		mov		dx, offset freqs
		mov		dx, offset times
		
		mov		si, dx
		       	
       	mov     al,  0B6h       ; Prepare the speaker for the 1011 0110 -> [10]-channel 2, [11]- , [011]-mode = square wave, [0]-binary count format 
        out     43h, al         ; note.	

.play: 
		mov		ax, [di]
		cmp		ax, 0FFFAh
		je		.nosound
		cmp		ax, 0FFFFh
		je		.end
		
		out		42h, al			;first least significant byte
		mov		al, ah
		out		42h, al			;then most significant byte
		in		al, 61h			;load state of 61h
		jmp 	.sound

.nosound:
		in		al, 61h			;load state of 61h
		
		and		al, 11111110b	;set bits 1 and 0 to 0 (stop counter, turn of speaker)
		out		61h, al			;turn of speaker and stop counter
		mov 	bx, [si]		; pause for duration of pause
		jmp		.pause1

.sound:               
        or      al, 00000011b   ; Set bits 1 and 0. (bit 0 starts counter, bit 1 must be 1 for and gate to work)
        out     61h, al         ; Send new value (start counter and play sound).
        mov     bx, [si]        ; Pause for duration of note.
       
.pause1:
		mov 	cx, 0FFFFh		; 65 535 * bx (e.g. 65 535 * 25 = 1 638 375 * 3(clock cycles) = 4 915 125 (Hz) ~ 5 MHz (i8086 clock frequency)
		
.pause2:
		dec 	cx				; 1 clock cycle
		jnz		.pause2			; 2 clock cycles
        dec     bx
        jnz     .pause1

		inc		di
		inc 	di
        
        inc 	si
        inc 	si
        
        jmp		.play
 

.end:
        in      al, 61h         ; Turn off note (get value from
                                ;  port 61h).
        and     al,  11111110b  ; Reset bits 1 and 0.
        out     61h, al         ; Send new value.
        mov		ax,  4C00h		; ah = N функции, al = код возврата
		int	21h					; снять программу с выполнения
end
