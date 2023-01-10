.include "p30F4013.inc"

#pragma config __FOSC, CSW_FSCM_OFF & FRC
    
#pragma config __FWDT, WDT_OFF 
    
#pragma config __FBORPOR, PBOR_ON & BORV27 & PWRT_16 & MCLR_EN

#pragma config __FGS, CODE_PROT_OFF & GWRP_OFF

.equ SAMPLES, 64

.global _wreg_init

.global __reset

.section .myconstbuffer, code
.palign 2
ps_coeff:
    .hword   0x0002, 0x0003, 0x0005, 0x000A

    
    .section .xbss, bss, xmemory
x_input: .space 2*SAMPLES

 
    .section .ybss, bss, ymemory
y_input:  .space 2*SAMPLES


    .section .nbss, bss, near
var1:     .space 2  
     
.text
__reset:
    MOV #__SP_init, W15
    MOV #__SPLIM_init, W0
    MOV W0, SPLIM
    NOP

    CALL _wreg_init

    CALL INI_PERIPHERALS	

done:
    COM	    PORTB
    CALL    DELAY_10us
    BRA     done

_wreg_init:
    CLR W0
    MOV W0, W14
    REPEAT #12
    MOV W0, [++W14]
    CLR W14
    RETURN

DELAY_10us:
    PUSH W1
    PUSH W0
    MOV #35000, W0 ; 10 ms

CYCLE_2:
    MOV #19, W1

CYCLE_1:
    DEC W1, W1
    BRA NZ, CYCLE_1
    
    REPEAT #99
    DEC W0, W0
    BRA NZ, CYCLE_2
    POP W0
    POP W1
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
