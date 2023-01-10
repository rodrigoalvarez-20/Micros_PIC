   .include "p30F4013.inc"
;---------------------------------------------------------------------------    
    #pragma config __FOSC, CSW_FSCM_OFF & FRC   
;---------------------------------------------------------------------------    
    #pragma config __FWDT, WDT_OFF 
;---------------------------------------------------------------------------    
    #pragma config __FBORPOR, PBOR_ON & BORV27 & PWRT_16 & MCLR_EN
;---------------------------------------------------------------------------      
    #pragma config __FGS, CODE_PROT_OFF & GWRP_OFF
;..............................................................................
;Program Specific Constants (literals used in code)
;..............................................................................

    .equ SAMPLES, 64         ;Number of samples
;..............................................................................
;Global Declarations:
;..............................................................................

    .global _wreg_init       

    .global __reset          

;..............................................................................
;Constants stored in Program space
;..............................................................................

    .section .myconstbuffer, code
    .palign 2                
ps_coeff:
    .hword   0x0002, 0x0003, 0x0005, 0x000A

;..............................................................................
;Uninitialized variables in X-space in data memory
;..............................................................................

    .section .xbss, bss, xmemory
x_input: .space 2*SAMPLES        ;Allocating space (in bytes) to variable.



;..............................................................................
;Uninitialized variables in Y-space in data memory
;..............................................................................

    .section .ybss, bss, ymemory
y_input:  .space 2*SAMPLES

;..............................................................................
;Uninitialized variables in Near data memory (Lower 8Kb of RAM)
;..............................................................................

    .section .nbss, bss, near
var1:     .space 2               
;..............................................................................
;Code Section in Program Memory
;..............................................................................

.text                         ;Start of Code section
__reset:
    MOV #__SP_init, W15       ;Initalize the Stack Pointer
    MOV #__SPLIM_init, W0     ;Initialize the Stack Pointer Limit Register
    MOV W0, SPLIM
    NOP                       ;Add NOP to follow SPLIM initialization

    CALL _wreg_init           ;Call _wreg_init subroutine
                                  ;Optionally use RCALL instead of CALL




        ;<<insert more user code here>>

    CALL INI_PERIPHERALS	

MENU:
    
    MOV PORTF, W1 ; PARA OPCIONES DE MENU
    
    CP W1, #1
    BRA Z, KNIGHT_RIDER
    
    CP W1, #2
    BRA Z, BLINK_200MS
    
    CP W1, #3
    BRA Z, BLINK_500MS
    
    CP W1, #4
    BRA Z, LEFT_SHIFT
    
    CP W1, #5
    BRA Z, RIGHT_SHIFT
    
    CP W1, #6
    BRA Z, CENTER_SHIFT
    
    CP W1, #7
    BRA Z, DIV
    
    CP W1, #8
    BRA Z, PRODUCT
    
    BRA     MENU              ;Place holder for last line of executed code


;..............................................................................
;BLINKS Y DELAYS
;..............................................................................    
    
BLINK_200MS:
    PUSH   W5
    COM    PORTB
    MOV    #200,    W5
    CALL   DELAY_MS
    POP    W0
    BRA    MENU
    
BLINK_500MS:
    PUSH   W5
    COM    PORTB
    MOV    #500,    W5
    CALL   DELAY_MS
    POP    W5
    BRA    MENU
    
DELAY_100MS:
    PUSH   W5
    MOV    #100,    W5
    CALL   DELAY_MS
    POP    W5
    Return
      
DELAY_350MS:
    PUSH   W5
    MOV    #350,    W5
    CALL   DELAY_MS
    POP    W5
    Return
    
DELAY_MS: ;Funcion general de ms
    PUSH    W2
    CYCLE2:
    CLR	    W2			    
    MOV     #614, W2
    CYCLE1:		
    DEC	    W2,   W2
    BRA	    NZ,	  CYCLE1

    DEC	    W5,	  W5
    BRA	    NZ,	  CYCLE2

    POP	    W2
    RETURN
 
    
;..............................................................................
;ANIMACIONES CON LEDS
;..............................................................................

LEFT_SHIFT:  
    
    MOV #0X0000, W4 ;Todos los LED's apagados = inicio de subrutina 
    MOV W4, PORTB   
    CALL DELAY_100MS
    
    MOV #0X0001, W4
    MOV W4, PORTB 
    CALL DELAY_100MS
    
    MOV #0X0003, W4
    MOV W4, PORTB 
    CALL DELAY_100MS
    
    MOV #0X0006, W4
    MOV W4, PORTB 
    CALL DELAY_100MS
    
    MOV #0X000C, W4
    MOV W4, PORTB 
    CALL DELAY_100MS
    
    MOV #0X0018, W4
    MOV W4, PORTB 
    CALL DELAY_100MS
    
    MOV #0X0030, W4
    MOV W4, PORTB 
    CALL DELAY_100MS

    MOV #0X0060, W4
    MOV W4, PORTB 
    CALL DELAY_100MS
    
    MOV #0X00C0, W4
    MOV W4, PORTB
    CALL DELAY_100MS

    MOV #0X0180, W4
    MOV W4, PORTB
    CALL DELAY_100MS
    
    MOV #0X0300, W4
    MOV W4, PORTB
    CALL DELAY_100MS
    
    MOV #0X0600, W4
    MOV W4, PORTB
    CALL DELAY_100MS
    
    MOV #0X0C00, W4
    MOV W4, PORTB
    CALL DELAY_100MS
    
    MOV #0X1800, W4
    MOV W4, PORTB
    CALL DELAY_100MS
    
    MOV #0X1000, W4
    MOV W4, PORTB
    
    BRA MENU
 
    
    
RIGHT_SHIFT:
    
    MOV #0X0000, W4 ;Todos los LED's apagados = inicio de subrutina
    MOV W4, PORTB 
    CALL DELAY_100MS
    
    MOV #0X1000, W4
    MOV W4, PORTB 
    CALL DELAY_100MS
    
    MOV #0X1800, W4
    MOV W4, PORTB 
    CALL DELAY_100MS
    
    MOV #0X0C00, W4
    MOV W4, PORTB 
    CALL DELAY_100MS
    
    MOV #0X0600, W4
    MOV W4, PORTB 
    CALL DELAY_100MS
    
    MOV #0X0300, W4
    MOV W4, PORTB 
    CALL DELAY_100MS
    
    MOV #0X0180, W4
    MOV W4, PORTB 
    CALL DELAY_100MS
    
    MOV #0X00C0, W4
    MOV W4, PORTB 
    CALL DELAY_100MS
    
    MOV #0X0060, W4
    MOV W4, PORTB 
    CALL DELAY_100MS
    
    MOV #0X0030, W4
    MOV W4, PORTB 
    CALL DELAY_100MS
    
    MOV #0X0018, W4
    MOV W4, PORTB 
    CALL DELAY_100MS
    
    MOV #0X000C, W4
    MOV W4, PORTB 
    CALL DELAY_100MS

    MOV #0X0006, W4
    MOV W4, PORTB 
    CALL DELAY_100MS
    
    MOV #0X0003, W4
    MOV W4, PORTB 
    CALL DELAY_100MS
    
    MOV #0X0001, W4
    MOV W4, PORTB 
    
    BRA MENU
    
CENTER_SHIFT:
    
    MOV #0X00E0, W4
    MOV W4, PORTB 
    CALL DELAY_350MS
    
    MOV #0X0110, W4
    MOV W4, PORTB 
    CALL DELAY_350MS
    
    MOV	 #0x0208, W4
    MOV	 W4,	PORTB
    CALL DELAY_350MS
    
    MOV	 #0x0404, W4
    MOV	 W4,	PORTB
    CALL DELAY_350MS
    
    MOV	 #0x0802, W4
    MOV	 W4,	PORTB
    CALL DELAY_350MS
    
    MOV	 #0x1001, W4
    MOV	 W4,	PORTB
    CALL DELAY_350MS
    
    NOP
    BRA MENU
    
KNIGHT_RIDER:
    CALL DELAY_100MS
    BTSC    W6,	    #1	    ;Revisa la dirección del shift 0
    BRA	    NZ,	    GO_RIGHT
    BRA	    GO_LEFT
    
    GO_LEFT:
    MOV	    PORTB,  W4
    MOV	    #0x1000, W3	   ;Limite izquierdo
    CP	    W9,	    #1	    ;Si la dirección es derecha
    BRA	    Z,	    GO_RIGHT
    
    CP	    W4,	    W3	    ;Compara PORTB y limite izquierdo
    BRA	    NZ,	    CONTINUE_LEFT
    MOV     #1,	    W6
    BRA	    GO_RIGHT
    
    CONTINUE_LEFT:
    SL	PORTB
    NOP
    BRA	KNIGHT_RIDER
    
    GO_RIGHT:
    MOV	    PORTB,  W4
    CP	    W4,	    #0x0001
    BRA	    NZ,	    CONTINUE_RIGHT
    MOV	    #0	 ,   W9
    BRA	    GO_LEFT
    
    CONTINUE_RIGHT:
    LSR	    PORTB
    NOP
    BRA	    MENU

;..............................................................................
;OPERACIONES ARITMETICAS
;..............................................................................

DIV:
    CLR W8
    CLR W9
    MOV PORTD, W7 ;ENTRADAS DE OPERACIONES
    
    PUSH W0
    AND W7, #3, W8 ;NUM 1
    AND W7, #12, W9 
    LSR W9, #2, W9 ;NUM 2
    
    DIV.U W8, W9
    MOV W0, PORTB
    NOP
    NOP
    POP W0
    
    BRA MENU
    
PRODUCT:
    CLR W8
    CLR W9
    MOV PORTD, W7 ;ENTRADAS DE OPERACIONES
    
    PUSH W0
    AND W7, #3, W8 ;NUM 1
    AND W7, #12, W9 
    LSR W9, #2, W9 ;NUM 2
    
    MUL.UU W8, W9, W0
    MOV W0, PORTB
    NOP
    NOP
    POP W0
    
    BRA MENU
    
;..............................................................................
;Subroutine: Initialization of W registers to 0x0000
;..............................................................................

_wreg_init:
    CLR W0
    MOV W0, W14
    REPEAT #12
    MOV W0, [++W14]
    CLR W14
    RETURN
;******************************************************************************
;DESCRIPTION:	Initialize peripherals and determine whether each pin associated
		;with the I/O port is an input or an output
;PARAMETER: 	NINGUNO
;RETURN: 	NINGUNO
;******************************************************************************		
INI_PERIPHERALS:
    CLR         PORTB
    NOP
    CLR         LATB
    NOP
    CLR         TRISB		    ;PORTB AS OUTPUT
    NOP       			
    SETM	ADPCFG		    ;Disable analogic inputs
	
    CLR         PORTC
    NOP
    CLR         LATC
    NOP
    SETM        TRISC		    ;PORTC AS INPUT
    NOP       
	
    CLR         PORTD
    NOP
    CLR         LATD
    NOP 
    SETM        TRISD		    ;PORTD AS INPUT
    NOP

    CLR         PORTF
    NOP
    CLR         LATF
    NOP
    SETM        TRISF		    ;PORTF AS INPUT
    NOP       		
    
    RETURN    

;--------End of All Code Sections ---------------------------------------------   

.end                               ;End of program code in this file
