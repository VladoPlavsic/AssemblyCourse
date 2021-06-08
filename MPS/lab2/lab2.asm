; interrupt: 70h
; timer offset: 2b0h
; keyboard offset: 180h
; 
; PIC 8259A 
; 
; The IBM PC’s PIC is configured by using regular port-mapped I/O. The four port numbers are:
; Master 8259
; 
;     IRQ0 – Intel 8253 or Intel 8254 Programmable Interval Timer, aka the system timer or PIT
;     IRQ1 – Intel 8042 keyboard controller
;     IRQ2 – not assigned in PC/XT; cascaded to slave 8259 INT line in PC/AT
;     IRQ3 – 8250 UART serial port COM2 and COM4
;     IRQ4 – 8250 UART serial port COM1 and COM3
;     IRQ5 – hard disk controller in PC/XT; Intel 8255 parallel port LPT2 in PC/AT
;     IRQ6 – Intel 82072A floppy disk controller
;     IRQ7 – Intel 8255 parallel port LPT1 / spurious interrupt
; 
; Configuring:
; 
;     0x20, the master PIC’s port A
;     0x21, the master PIC’s port B
; 
; Initialization:
;   
;   ICW1
;     The first ICW sets a few parameters controlling the PIC’s mode of operation. ICW1 has to be sent to port A of each PIC.
; 
;     0 0 0 1 x 0 x x -> Bit positions:
; 
;                 0. ICW4 present (set) or not (clear)
;                 1. single controller (set) or cascade mode (clear)
;                 3. level triggered mode (set) or edge triggered mode (clear)
; 
;   ICW2
;     The second ICW informs the PIC about the base offset in the interrupt descriptor table (IDT) to use when transmitting an IRQ from a device to the CPU.
;     The base offset must be a multiple of 8 (hence the three last zeroes in the following scheme). ICW2 has to be sent to port B of each PIC.  
; 
;     x x x x x 0 0 0 -> Interrupt vector base address
; 


.model small
.data 
SCAN db 'v'

ICW1 EQU 00010011b      ; edge-trigger mode, 8-byte int vector, single 8259, ICW4 not needed
ICW2 EQU 70h

ESC_SCAN EQU 01h

PIC_ADDRESS EQU 20h

TIMER_OFFSET EQU 02b0h
KEYBOARD_OFFSET EQU 0180h


.code

    mov ax, @data
    mov ds, ax

    cli                 ; Disable intrrupts until interrupt controller updated and vector update is complete

    ; ICW1
    mov al, ICW1        ; edge-trigger mode, 8-byte int vector, single 8259, ICW4 needed
    out 20h, al

    ; ICW2
    mov al, ICW2        ; map master (in our case only) 8259 to use interrupt 70h
    out 21h, al         ; acctualy map it

    ; ICW4
    mov al,  01
    out 21h, al

    ; disable timer and keyboard IRQs
    in al, 21h
    or al, 00000011b
    out 21h, al
    
    push es
    xor ax, ax
    mov es, ax

    mov es:[4 * ICW2], TIMER_OFFSET
    mov es:[4 * ICW2 + 2], cs

    mov es:[4 * ICW2 + 4], KEYBOARD_OFFSET
    mov es:[4 * ICW2 + 6], cs

    pop es
    sti               ; enable interrupts


    in  al, 21h       ; load maks
    and al, 11111101b ; IRQ0 = 0 and IRQ1 = 0 -> 
    out 21h, al       ; -> Only timer and keyboar interrupts allowed

    lea si, SCAN
    hlt               ; this one does something ????
    hlt               ; this one waits for key to be pressed
    mov cx, 300       ; interrupt coutner
    mov di, 0         ; display offset 320x240 (real 160 * 25)
    in  al, 21h       ; load maks
    and al, 11111100b ; IRQ0 = 0 and IRQ1 = 0 -> 
    out 21h, al       ; -> Only timer and keyboar interrupts allowed

    m1: hlt           ; wait for interrupt
        loop m1

jmp skip_interrupts

    org KEYBOARD_OFFSET  ; Keyboard interrupt handler offset
        push ax
        in al, 60h    ; IOP - PA (Get scancode)
        test al, 80h  ; KeyPress or KeyRelese
        jnz KeyRelese

        cmp al, ESC_SCAN
        jne continue
        mov cx, 1
        mov al, 20h
        out 20h, al ; EOI command to 8259 PIC (re-enable interrupts)

        pop ax
        iret

        continue: 
        mov [si], al
        mov bh, al

        KeyRelese:
            mov bl, al
            in  al, 61h ; IOP - PB0-PB7 (Get current)
            or  al, 80h ; Set PB7 = 1
            out 61h, al
            and al, 7Fh ; SET PB7 = 0
            mov al, 20h
            out 20h, al ; EOI command to 8259 PIC (re-enable interrupts)

            pop ax
            iret

    org TIMER_OFFSET  ; Timer interrupt handler offset
        push ax
        
        mov ax, 0B800h ; Video memory
        mov es, ax

        mov al, [si]
        mov ah, 14h    ; blue on red background 

        mov es:[di], ax
        add di, 2
        mov al, 20h
        out 20h, al    ; EOI command to 8259 PIC (re-enable interrupts)
        
        pop ax
        iret

skip_interrupts:
    nop

end_m:

    cli 

    ; ICW1
    mov al, ICW1 ; edge-trigger mode, 8-byte int vector, single 8259, ICW4 not needed
    out 20h, al

    ; ICW2
    mov al, 08h ; map master (in our case only) 8259 to use interrupt 70h
    out 21h, al ; acctualy map it

    ; ICW4
    mov al,  01 ; processor = i8086 
    out 21h, al

    ; return IRQs the way they were
    mov al, 01h
    out 21h, al

    sti

    mov ax, 4C00h
    int 21h


end