
    .include "p30F4013.inc"

    #pragma config __FOSC, CSW_FSCM_OFF & FRC
    
    #pragma config __FWDT, WDT_OFF 
    
    #pragma config __FBORPOR, PBOR_ON & BORV27 & PWRT_16 & MCLR_EN
    
    #pragma config __FGS, CODE_PROT_OFF & GWRP_OFF

    .equ SAMPLES, 64        ;Number of samples

    .global _wreg_init      ;Provide global scope to _wreg_init routine
                            ;In order to call this routine from a C file,
                            ;place "wreg_init" in an "extern" declaration
                            ;in the C file.

    .global __reset         ;The label for the first line of code.

    .section .myconstbuffer, code
    .palign 2               ;Align next word stored in Program space to an
                            ;address that is a multiple of 2
ps_coeff:
    .hword   0x0002, 0x0003, 0x0005, 0x000A

;RLEDS de +1 (2) hasta 0x0000
;LEDS de +13 (8192) hasta 0x0000 (--)
;CTREE +15 (32768) hasta 0x00000 (++) y reiniciar en +15
WLEDS:
.WORD 0x0000, 0X0001, 0X0002, 0X0004, 0X0008, 0X0010, 0X0020, 0X0040, 0X0080, 0X0100, 0X0200, 0X0400, 0X0800, 0X1000, 0X0000, 0x0040, 0x00A0, 0x0110, 0x0208, 0x0404, 0x0802, 0x1001, 0x0000


;0, 1, 2, 3, 4, 5, 6, 7, 8, 9
DIGITS:
    .WORD 0xC00, 0xF90, 0xA40, 0xB00, 0x990, 0x920, 0x820, 0xF80, 0x800, 0x900
    
    .section .xbss, bss, xmemory
x_input: .space 2*SAMPLES        ;Allocating space (in bytes) to variable.

    .section .ybss, bss, ymemory
y_input:  .space 2*SAMPLES


    .section .nbss, bss, near
var1:     .space 2              ;Example of allocating 1 word of space for
                                ;variable "var1".

.text
__reset:
    MOV #__SP_init, W15       ;Initalize the Stack Pointer
    MOV #__SPLIM_init, W0     ;Initialize the Stack Pointer Limit Register
    MOV W0, SPLIM
    NOP                       ;Add NOP to follow SPLIM initialization

    CALL _wreg_init           ;Call _wreg_init subroutine
                              ;Optionally use RCALL instead of CALL

    CALL INI_PERIPHERALS
    CALL CONF_INT0


;A<2:0> y B<2:0>
;0 --> Knight Rider con delay de 100 ms
;1 --> Blink all con delay de 200 ms
;2 --> Blink all con delay de 500 ms
;3 --> Desplazar a la izquierda con un delay de 100 ms
;4 --> Desplazar a la derecha con un delay de 100 ms
;5 --> Desplazar desde el centro hasta los lados (mantener repetido) con un delay de 350 ms
;6 --> Prod 2 numeros
;7 --> DIV de 2 numeros

;W0 Es la paginacion de memoria para la palabra
;W1 Contiene las direcciones de memoria de dicha palabra
;W2 Valor de primer numero
;W3 Es un contador para el delay
;W4 Valor de segundo numero
;W5 es el valor para el delay
;W6 Va a contener el valor de la palabra W0 en el indice W1 (direccion u offset)
;W7 Selector principal
;W8 Offset para cada caso
    
done:
    ;Cargar la palabra en la memoria
    MOV #tblpage(WLEDS), W0
    MOV W0, TBLPAG
    MOV #0xFFFF, W10
    
    RESET_WORD:
	MOV #tbloffset(WLEDS), W1 ; load address LS word
	MOV #tbloffset(WLEDS), W8 ;
	COM W10, W10
    	
    start:
	CLRWDT
	;MOV PORTD, W7
	;AND #7, W7
	MOV PORTD, W2 ; Primer numero  
	MOV PORTF, W4 ; Segundo numero 
	;MOV #59, W2 
	;MOV #59, W4
	;AND #56, W2 
	;LSR W2, #3, W2 
	AND #15, W2
	AND #15, W4
	;MOV #7, W7
	
	CP0 W7
	BRA Z, KRIDER
	CP W7, #1
	BRA Z, BLINK_200
	CP W7, #2
	BRA Z, BLINK_500
	CP W7, #3
	BRA Z, ROTATE_IZQ
	CP W7, #4
	BRA Z, ROTATE_DER
	CP W7, #5
	BRA Z, CTREE
	CP W7, #6
	BRA Z, PRODUCTO
	CP W7, #7
	BRA Z, DIVISION
	BRA start
    	
ROTATE_IZQ:
    CP W1, W8
    BRA Z, PAD_IZQ
    
    START_IZQ:
    MOV	#100, W5
    CALL DELAY_G_ms
    
    TBLRDL  [W1--], W6
    CP0	    W6
    BRA	    Z, RESET_WORD
    MOV	    W6, PORTB
    
    BRA	    start

PAD_IZQ:
    MOV #0x00, W12
    CPSNE W12, W6
    ADD #0x1A, W1
    BRA START_IZQ
    
ROTATE_DER:
    CP W1, W8
    BRA Z, PAD_DER
    
    START_DER:
    MOV	#100, W5
    CALL DELAY_G_ms
    
    TBLRDL  [W1++], W6
    CP0	    W6
    BRA	    Z, RESET_WORD
    MOV	    W6, PORTB
    
    BRA	    start    

PAD_DER:
    ADD #0x02, W1
    BRA START_DER

KRIDER:
    CP0 W10
    BRA Z, ROTATE_DER
    CP0 W10
    BRA NZ, ROTATE_IZQ
    
    BRA start
    
CTREE:
    CP W1, W8
    BRA Z, PAD_TREE
    
    START_TREE:
    MOV	#350, W5
    CALL DELAY_G_ms
    
    TBLRDL  [W1++], W6
    CP0	    W6
    BRA	    Z, RESET_WORD
    MOV	    W6, PORTB
    
    BRA	    start
    
PAD_TREE:
    ADD #0x1E, W1
    BRA START_TREE

BLINK_200:
    MOV #200, W5
    CALL DELAY_G_ms
    COM PORTB
    BRA start

BLINK_500:
    MOV #500, W5
    CALL DELAY_G_ms
    COM PORTB
    BRA start   

PRODUCTO:
    MUL.UU W2, W4, W2
    CALL SHOW_IN_DISPLAY
    BRA done

DIVISION:
    REPEAT #17
    DIV.U W2, W4
    MOV W0, W2
    CALL SHOW_IN_DISPLAY
    BRA done

    
SHOW_IN_DISPLAY:
    MOV #1000, W11
    
    REPEAT #17
    DIV.U W2, W11
    MOV W1, W12 ;num % 1000
    
    MOV #100, W11
    
    REPEAT #17
    DIV.U W2, W11
    MOV W1, W13 ; num % 100
    
    SUB W12, W13, W12
    REPEAT #17
    DIV.U W12, W11
    MOV W0, W12 ; Valor de las Centenas
    
    MOV #10, W11
    
    REPEAT #17
    DIV.U W2, W11 
    MOV W1, W14 ; num %10 --> unidades 8 
    
    SUB W13, W14, W13 ; W13 Decenas 4
    REPEAT #17
    DIV.U W13, W11
    MOV W0, W13
    
    ; W12 Centenas
    ; W13 Decenas
    ; W14 Unidades
    
    ; Cargar la paginacion 
    MOV #tblpage(DIGITS), W0
    MOV W0, TBLPAG
    MOV #tbloffset(DIGITS), W1
    MUL.UU W12, #2, W10
    
    ADD W10, W1, W1
    
    TBLRDL  [W1], W6 ; --> Valor listo de las centenas
    ADD #0x0001, W6
    MOV W6, PORTB
    NOP
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    MOV #tbloffset(DIGITS), W1
    MOV W13, W12
    MUL.UU W12, #2, W12
    ADD W12, W1, W1
    TBLRDL  [W1], W6 ; --> Valor listo de las decenas
    ADD #0x0002, W6
    MOV W6, PORTB
    NOP
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    MOV #tbloffset(DIGITS), W1
    MOV W14, W12
    MUL.UU W12, #2, W12
    ADD W12, W1, W1
    TBLRDL  [W1], W6 ; --> Valor listo de las unidades
    ; Para centenas, sumar un 8
    ADD #0x0004, W6
    MOV W6, PORTB
    NOP
    
    RETURN
    
    
DELAY_G_ms:
    PUSH    W3
    PUSH    W5

CYCLE_G_2:
    MOV	#620, W3

CYCLE_G_1:		
    DEC	W3, W3
    BRA	NZ, CYCLE_G_1

    DEC	W5, W5
    BRA	NZ, CYCLE_G_2

    POP	W3
    POP	W5
    RETURN	
	
_wreg_init:
    CLR W0
    CLR W1
    CLR W2
    CLR W3
    CLR W4
    CLR W5
    CLR W6
    CLR W7
    CLR W8
    CLR W9
    MOV W7, W14
    REPEAT #12
    MOV W7, [++W14]
    CLR W14
    RETURN

CONF_INT0:
    BSET    INTCON1,	#NSTDIS
    
    BCLR    IPC0,	#INT0IP0
    BCLR    IPC0,	#INT0IP1
    BSET    IPC0,	#INT0IP2
    
    BCLR    IFS0,	#INT0IF
    
    BCLR    INTCON2,	#INT0EP	    ;0 = Interrupt on positive edge
    ;BSET    INTCON2,	#INT0EP	    ;1 = Interrupt on negative edge
    
    BSET    IEC0,	#INT0IE
    
    RETURN
    
INI_PERIPHERALS:
    CLR         PORTB		    ;Limpia o inicializa el PORTB
    NOP				    ; No operation
    CLR         LATB		    ; Limpia/Inicializa el puerto LATB
    NOP
    CLR         TRISB		    ; Define el PORTB como salida
    NOP       			
    SETM	ADPCFG		    ; SETM Convierte los valores a 1, por lo que el puerto ADPCFG se convierte a '1' y se deshabilita
				    ; ADPCFG --> 0 = Analogo, 1 = Digital --> Deshabilita el comportamiento analogico
	
    CLR         PORTC
    NOP
    CLR         LATC
    NOP
    SETM        TRISC		    ; Define PORTC como salida
    NOP       
    
    CLR         PORTD
    NOP
    CLR         LATD
    NOP 
    SETM        TRISD		    ; Define PORTD como entrada
    NOP

    CLR         PORTF
    NOP
    CLR         LATF
    NOP
    SETM        TRISF		    ; Define PORTF como entrada
    NOP
    
    RETURN    

;--------End of All Code Sections ---------------------------------------------   

; --- Declaracion de interrupciones -------------------------------------------

__INT0Interrupt:
    
    MOV #200, W5
    CALL DELAY_G_ms
    
    INC W7, W7
    
    ;PUSH W0
    
    MOV #8, W0
    CPSNE W7, W0
    MOV #0, W7
    
    BCLR    IFS0,	#INT0IF	    ;the user must clear the interrupt flag
    
    ;POP W0
    
    RETFIE
    
.end                               ;End of program code in this file
