
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

done:
    MOV PORTD, W0;
    ;MOV #6, W0
    CP0 W0
    BRA Z, START_DELAY_1s
    CP W0, #1
    BRA Z, START_DELAY_10us
    CP W0, #2
    BRA Z, START_DELAY_100us
    CP W0, #3
    BRA Z, START_DELAY_10ms
    CP W0, #4
    BRA Z, START_DELAY_200ms
    CP W0, #5
    BRA Z, START_DELAY_G_10us
    CP W0, #6
    BRA Z, START_DELAY_G_ms
    BRA done

_wreg_init:
    CLR W0
    CLR W1
    CLR W2
    CLR W3
    MOV W0, W14
    REPEAT #12
    MOV W0, [++W14]
    CLR W14
    RETURN

;"CYCLE1" will repeat 2^16 times = 65536 times
;DEC(1) + BRA(2) = 3 pulses in total
;(BRA uses 2 CLK pulses when it jumps and just one if it does not)

;65536 * 3 cycles * 542 ns = 0.1066s
;Thus, "CYCLE1" must be repeated 10 times to delay 1s

; 542.53x10^-9 (Instrucciones de CYCLE_1) (Decremento) (No Veces CYCLE_2)

START_DELAY_1s:
    COM PORTB
    CALL DELAY_1s
    BRA done

START_DELAY_10us:
    COM PORTB
    CALL DELAY_10us
    BRA done

START_DELAY_100us:
    COM PORTB
    CALL DELAY_100us
    BRA done

START_DELAY_10ms:
    COM PORTB
    CALL DELAY_10ms
    BRA done

START_DELAY_200ms:
    COM PORTB
    CALL DELAY_200ms
    BRA done
    
START_DELAY_G_10us:
    COM PORTB
    CALL DELAY_G_10us
    BRA done
    
START_DELAY_G_ms:
    COM PORTB
    CALL DELAY_G_ms
    BRA done
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
DELAY_1s:
    PUSH    W1
    PUSH    W2
    MOV	    #10, W2
    
CYCLE_1s_2:	
    CLR	    W1
	
CYCLE_1s_1:		
    DEC	    W1,	    W1
    BRA	    NZ,	    CYCLE_1s_1
    DEC	    W2,	    W2
    BRA	    NZ,	    CYCLE_1s_2
	
    POP	    W2
    POP	    W1
    RETURN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DELAY_10us:
    REPEAT #5
    CLR W0
    RETURN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DELAY_100us:
    PUSH	W1
    PUSH	W2

    MOV	#2, W2

CYCLE_100us_2:

    MOV	#27, W1

CYCLE_100us_1:		
    DEC	W1, W1
    BRA	NZ, CYCLE_100us_1

    DEC	W2, W2
    BRA	NZ, CYCLE_100us_2

    POP	W2
    POP	W1
    RETURN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DELAY_10ms:
    PUSH	W1
    MOV	#4096,	W1

CYCLE_10ms_1:		
    DEC	W1, W1
    NOP
    NOP
    BRA	NZ, CYCLE_10ms_1

    POP	W1
    RETURN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
DELAY_200ms:
    PUSH	W1
    PUSH	W2
    MOV	#2, W2

CYCLE_200ms_2:
    CLR W1

CYCLE_200ms_1:		
    DEC	W1, W1
    BRA	NZ, CYCLE_200ms_1

    DEC	W2, W2
    BRA	NZ, CYCLE_200ms_2

    POP	W2
    POP	W1
    RETURN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DELAY_G_10us:
    PUSH W1
    PUSH W3
    MOV #40000, W3 ; 10 ms

CYCLE_G_10us_2:
    MOV #28, W1

CYCLE_G_10us_1:
    DEC W1, W1
    BRA NZ, CYCLE_G_10us_1
    
    REPEAT #99
    DEC W3, W3
    BRA NZ, CYCLE_G_10us_2
    POP W3
    POP W1
    RETURN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DELAY_G_ms:
    PUSH    W1
    PUSH    W3
    MOV	#100, W3

CYCLE_G_2:
    MOV	#620, W1

CYCLE_G_1:		
    DEC	W1, W1
    BRA	NZ, CYCLE_G_1

    DEC	W3, W3
    BRA	NZ, CYCLE_G_2

    POP	W3
    POP	W1
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

.end                               ;End of program code in this file
