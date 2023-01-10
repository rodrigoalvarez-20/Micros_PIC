
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
    .global __U1RXInterrupt

    .section .myconstbuffer, code
    .palign 2               ;Align next word stored in Program space to an
                            ;address that is a multiple of 2
ps_coeff:
    .hword   0x0002, 0x0003, 0x0005, 0x000A

; Paso 1, 2, 3, 4 --> 1.8° por paso * 4 = 7.2° por vuelta a palabra
WROTATE:
.WORD 0x0000, 0x0006, 0x000A, 0x0009, 0x0005, 0x0000

    
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
    CALL CONF_UART1


;
    
done:
    ;Cargar la palabra en la memoria
    MOV #tblpage(WROTATE), W0
    MOV W0, TBLPAG
    ;MOV #0xFFFF, W10
    ;MOV #0x0, W7
    CALL RESET_WORD
    
    start:
	CLRWDT
	
	
	BRA start
    
ROTATE_MOTOR_FORWARD:
    
    TBLRDL  [W1++], W4
    
    MOV #0, W8
    
    CPSNE W4, W8
    CALL RESET_WORD
    
    CPSNE W4, W8
    CALL PAD_DER
    
    CPSNE W4, W8
    TBLRDL  [W1++], W4
    
    MOV W4, PORTB
    
    MOV #500, W5
    CALL DELAY_G_ms
    
    DEC W6, W6
    CP W6, W8
    BRA NZ, ROTATE_MOTOR_FORWARD
    
    RETURN

ROTATE_MOTOR_BACKWARDS:
    MOV #0, W8
    
    CPSNE W4, W8
    CALL RESET_WORD
    
    CPSNE W1, W10
    CALL PAD_IZQ
    
    TBLRDL  [W1--], W4
        
    CPSNE W4, W8
    TBLRDL  [W1--], W4
    
    MOV W4, PORTB
    
    MOV #500, W5
    CALL DELAY_G_ms
    
    DEC W6, W6
    CP W6, W8
    BRA NZ, ROTATE_MOTOR_BACKWARDS
    
    RETURN
    
PAD_DER:
    ADD #0x02, W1
    RETURN

PAD_IZQ:
    ADD #0x0A, W1
    RETURN
    
RESET_WORD:
    MOV #tbloffset(WROTATE), W1 ; load address LS word
    MOV #tbloffset(WROTATE), W10 ; load address LS word
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

CONF_UART1:
    MOV #11, W0 ; Set Baudrate
    MOV W0, U1BRG

    BSET IPC2,#U1TXIP2 ; Set UART TX interrupt priority
    BCLR IPC2,#U1TXIP1 ;
    BCLR IPC2,#U1TXIP0 ;
    
    BSET IPC2,#U1RXIP2 ; Set UART RX interrupt priority
    BCLR IPC2,#U1RXIP1 ;
    BCLR IPC2,#U1RXIP0 ;
    
    CLR U1STA
    MOV #0x8830, W0
    
    MOV W0,U1MODE
    BSET U1STA, #UTXEN ; Enable transmit
    BSET IEC0, #U1RXIE ; Enable receive interrupts
    BCLR  IFS0, #U1TXIF	    ;the user must clear the interrupt flag
    
    CLR W0
    
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

__U1RXInterrupt:
    ; Recepcion del valor entero de numero de veces que se tiene que girar
    ; Recibo 8 bits
    ; El bit de la izquierda es el sentido, los 7 bits de la derecha es el valor de rotacion
    MOV U1RXREG, W9
    MOV W9, W6
    MOV W9, W7
    AND #127, W6 ; W6 Valor de rotacion
    AND #128, W7 ; W7 Sentido --> 0 para ++, 1 para --
    LSR W7, #7, W7
    MOV #0, W3
    
    PUSH W6
    
    CPSNE W7, W3
    CALL ROTATE_MOTOR_FORWARD
    
    MOV #1, W3
    
    CPSNE W7, W3
    CALL ROTATE_MOTOR_BACKWARDS
    
    POP W6
    
    MOV W6, U1TXREG
    
    BCLR  IFS0, #U1RXIF	    ;the user must clear the interrupt flag
    BCLR  IFS0, #U1TXIF	    ;the user must clear the interrupt flag
    
    RETFIE
    
.end                               ;End of program code in this file
