
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

    
KRIDER_M:
.WORD 0X0001, 0X0002, 0X0004, 0X0008, 0X0010, 0X0020, 0X0040, 0X0080, 0X0100, 0X0200, 0X0400, 0X0800, 0X1000, 0x0800, 0x0400, 0x0200, 0x0100, 0x0080,0x0040, 0x0020, 0x0010, 0x0008, 0x0004, 0x0002, 0X0000
    
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

;A<2:0> y B<2:0>
;0 --> Knight Rider con delay de 100 ms
;1 --> Blink all con delay de 200 ms
;2 --> Blink all con delay de 500 ms
;3 --> Desplazar a la izquierda con un delay de 100 ms
;4 --> Desplazar a la derecha con un delay de 100 ms
;5 --> Desplazar desde el centro hasta los lados (mantener repetido) con un delay de 350 ms
;6 -> Dividir 2 numeros
;7 --> Producto de 2 numeros
;Salida: Puerto B
; D y F como entrada. D serán A y B, F el selector
; PORTD --> 6 BITS 111111
; W2 --> 6
; W1 --> 3
    
done:
    MOV PORTD, W7
    MOV PORTF, W2
    MOV PORTF, W4
    ;MOV #51, W2 ;Descomentar aqui para utilizar el Debugger
    ;MOV #51, W4 ;Descomentar aqui para utilizar el Debugger
    AND #56, W2 ; BITWISE para unicamente mantener las posiciones 5:3
    LSR W2, #3, W2 ; Corrimiento a la derecha en 3 posiciones 110000 --> 000110: 48 --> 6
    AND #7, W4 ; BITWISE para unicamente mantener las posiciones 2:0 --> 000011: 3 --> 3
    
    CP0 W7
    BRA Z, KRIDER
    CP W7, #1
    BRA Z, BLINK_200
    CP W7, #2
    BRA Z, BLINK_500
    CP W7, #3
    BRA Z, ROT_IZQ
    CP W7, #4
    BRA Z, ROT_DER
    CP W7, #5
    BRA Z, CTREE
    CP W7, #6
    BRA Z, DIVISION
    CP W7, #7
    BRA Z, PRODUCTO
    BRA done

KRIDER:
    MOV	    #tblpage(KRIDER_M), W0
    MOV	    W0,	TBLPAG  ;load TBLPAG register
    
    A1:
    MOV	    #tbloffset(KRIDER_M),    W1	    ; load address LS word
    
    A2:
    MOV	#350, W5
    CALL DELAY_G_ms
    
    TBLRDL  [W1++],		    W8   ; Read low word to W4 16 bits
    ;TBLRDL.B  [W1++],		    W4	    ; Read low word to W4 just 8 bits
    CP0	    W8
    BRA	    Z,			    A1
    MOV	    W8,			    PORTB
    NOP
    ;BRA	    A2
    
    BRA done

RRIDER:
    
    MOV #4096,W5
    
    CPSNE W1,W5
    MOV #1, W8
    
    CPSEQ W1,W5
    BRA ROT_DER
    
    BRA done
    
LRIDER:
    MOV #1,W3
	
    CPSNE W1,W3
    MOV #0, W8
    
    CPSEQ W1,W3
    BRA ROT_IZQ
    
    
    BRA done    
    
ROT_DER:
    MOV	#100, W5
    CALL DELAY_G_ms ; Llamo al delay
    ;Regreso del delay
    ;Actualizo los valores del W1
    MOV #0, W3
    MOV #2048, W5
   
    CPSNE W0, W3
    CALL RESET_DER
    
    CPSEQ W1, W3
    SL W1, #1, W1
    
    CPSNE W1, W3
    MOV #1, W1
    
    MOV W1, PORTB
    BRA done   

RESET_DER:
    CPSNE W1, W5
    MOV #0, W1
    RETURN
    
ROT_IZQ:
    MOV	#100, W5
    CALL DELAY_G_ms ; Llamo al delay
    
    MOV #0, W3
    MOV #4096, W5
    
    CPSNE W1, W3
    MOV #0, W0
    
    CPSEQ W1, W3
    LSR W1, #1, W1
    
    MOV #1, W6
    
    CPSEQ W0, W6
    CALL RESET_IZQ
    
    MOV W1, PORTB
    BRA done
    
RESET_IZQ:
    CPSNE W1, W3
    MOV #4096, W1
    RETURN
    
    
BLINK_200:
    MOV #200, W5
    CALL DELAY_G_ms
    COM PORTB
    BRA done

BLINK_500:
    MOV #500, W5
    CALL DELAY_G_ms
    COM PORTB
    BRA done
    
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
   
PRODUCTO:
    MUL.UU W2, W4, W2
    MOV W2, W1
    MOV W1, PORTB
    BRA done

DIVISION:
    REPEAT #17
    DIV.U W2, W4
    MOV W0, W1
    MOV W1, PORTB
    BRA done
    
LIMPIAR:
    MOV #0, W1
    MOV W1, PORTB
    BRA done

CTREE:
    MOV	#350, W5
    CALL DELAY_G_ms
    
    CP0 W6
    MOV #0, W1
    BRA Z, CTREE_OUT
    CP W6, #1
    MOV #64, W1
    BRA Z, CTREE_OUT
    CP W6, #2
    MOV #160, W1
    BRA Z, CTREE_OUT
    CP W6, #3
    MOV #272, W1
    BRA Z, CTREE_OUT
    CP W6, #4
    MOV #520, W1
    BRA Z, CTREE_OUT
    CP W6, #5
    MOV #1028, W1
    BRA Z, CTREE_OUT
    CP W6, #6
    MOV #2050, W1
    BRA Z, CTREE_OUT
    CP W6, #7
    MOV #4097, W1
    BRA Z, CTREE_OUT
    CP W6, #8
    MOV #0, W6
    BRA Z, CTREE_OUT
   
    MOV #0, W6
    BRA done
    
CTREE_OUT:
    INC W6, W6
    MOV W1, PORTB
    BRA done
    
_wreg_init:
    CLR W0
    CLR W1
    CLR W2
    CLR W3
    CLR W4
    CLR W5
    CLR W6
    CLR W7
    MOV W7, W14
    REPEAT #12
    MOV W7, [++W14]
    CLR W14
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
