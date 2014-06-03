/*
 * atmega_asm.asm
 *
 *  Created: 7/7/2011 6:11:33 PM
 *   Author: matthew
 */ 

; ================================================================================================
; Included header file for target AVR type
; ================================================================================================
.NOLIST
.INCLUDE "m328Pdef.inc" ; Header for ATMEGA328P
.LIST
.LISTMAC


; ================================================================================================
.EQU	F_CPU	= 20000000
; ================================================================================================

;
; ================================================================================================
;   H A R D W A R E   I N F O R M A T I O N   
; ================================================================================================
;
; [Add all hardware information here]
;
; ================================================================================================
;      P O R T S   A N D   P I N S 
; ================================================================================================
;
; [Add names for hardware ports and pins here]
; Format: .EQU Controlportout = PORTA
;         .EQU Controlportin = PINA
;         .EQU LedOutputPin = PORTA2
;
; ================================================================================================
;    C O N S T A N T S
; ================================================================================================
; Format: .EQU const = $ABCD
.EQU	FIXED_DELAY		= 39
.EQU	TIMER0A_DELAY	= 250
.EQU	EEPROM_ADDRESS	= 0

.EQU	SND_FLAG		= 0

; ================================================================================================
;   R E G I S T E R   D E F I N I T I O N S
; ================================================================================================
; Format: .DEF rmp = R16
.DEF rmp	= R16 ; Multipurpose register
.DEF rclk	= R17
.DEF rcnt	= R18


; ================================================================================================
;       S R A M   D E F I N I T I O N S
; ================================================================================================
; Format: Label: .BYTE N ; reserve N Bytes from Label:
.DSEG
.ORG	SRAM_START
MISC_BUFF:		.byte		1
SWINT_FLAGS:	.byte		1



; ================================================================================================
; Debug Macros
; ================================================================================================
.macro	blue_en
	sbi		ddrd, PD7
.endmacro
.macro	blue_on
	sbi		portd, PD7
.endmacro
.macro	blue_off
	cbi		portd, PD7
.endmacro
.macro	snd_on
	sbi		ddrd, PD3
.endmacro
.macro	snd_off
	cbi		ddrd, PD3
.endmacro


; ================================================================================================
;   R E S E T   A N D   I N T   V E C T O R S
; ================================================================================================
.CSEG
.ORG $0000
	jmp Main ; Int vector 1		RESET
	reti ; Int vector 2			INT0
	nop
	reti ; Int vector 3			INT1
	nop
	reti ; Int vector 4			PCINT0
	nop
	reti ; Int vector 5			PCINT1
	nop
	reti ; Int vector 6			PCINT2
	nop
	reti ; Int vector 7			WDT
	nop
	reti ; Int vector 8			TIMER2 COMPA
	nop
	reti ; Int vector 9			TIMER2 COMPB
	nop
	reti ; Int vector 10		TIMER2 OVF
	nop
	reti ; Int vector 11		TIMER1 CAPT
	nop
	jmp Timer1CompareAHandler ; Int vector 12		TIMER1 COMPA
	reti ; Int vector 13		TIMER1 COMPB
	nop
	reti ; Int vector 14		TIMER1 OVF
	nop
	jmp Timer0CompareAHandler ; Int vector 15	TIMER0 COMPA
	reti ; Int vector 16		TIMER0 COMPB
	nop
	reti ; Int vector 17		TIMER0 OVF
	nop
	reti ; Int vector 18		SPI, STS
	nop
	reti ; Int vector 19		USART, RX
	nop
	reti ; Int vector 20		USART, UDRE
	nop
	reti ; Int vector 21		USART, TX
	nop
	reti ; Int vector 22		ADC
	nop
	reti ; Int vector 23		EE READY
	nop
	reti ; Int vector 24		ANALOG COMP
	nop
	reti ; Int vector 25		TWI
	nop
	reti ; Int vector 26		SPM READY
	nop


; ================================================================================================
; Timer 0 Compare A Interrupt Handler
; ================================================================================================
Timer0CompareAHandler:
	push	rmp
	in		rmp, sreg
	push	rmp

	; clock is running at 78Hz
	cpi		rclk, FIXED_DELAY			; rclk is used to delay the LED (set at about 39)
	brlo	_tca1						; skip if we haven't reached the delay period

	; delay counter needs to be reset
	ldi		rclk, 0						; clear delay counter

	inc		rcnt						; increment our random counter
	in		rmp, portb					; get the current LED status
	sbrc	rmp, pb0					; so that the bit can be toggled
	rjmp	_tca_off

	sbi		portb, pb0
	rjmp	_tca_done
_tca_off:
	ldi		r19, 0
	cbi		portb, pb0
	rjmp	_tca_done

_tca1:
	inc		rclk

_tca_done:
	pop		rmp
	out		sreg, rmp
	pop		rmp

	reti


; ================================================================================================
; Timer 2 Compare A Interrupt Handler
; ================================================================================================
Timer1CompareAHandler:
	push	rmp
	in		rmp, SREG
	push	rmp

	; update the output compare register
	lds		rmp, MCP_DATA
	sts		OCR2B, rmp

	; set SND_FLAG for SW INT feature
	lds		rmp, SWINT_FLAGS
	ori		rmp, (1<<SND_FLAG)
	sts		SWINT_FLAGS, rmp

	pop		rmp
	out		sreg, rmp
	pop		rmp
	reti


; ================================================================================================
;     M A I N    P R O G R A M    I N I T
; ================================================================================================
Main:
	; Init stack
	ldi		rmp, HIGH(RAMEND)				; Init MSB stack
	out		SPH,rmp
	ldi		rmp, LOW(RAMEND)				; Init LSB stack
	out		SPL,rmp

	ldi		rmp, 1<<SE						; enable sleep
	out		MCUCR,rmp

	ldi		rmp, 0
	mov		r7, rmp

	; setup timer0 for debug/clock outout
	ldi		rmp, (1<<WGM01)					; ctc
	out		TCCR0A, rmp
	ldi		rmp, (1<<CS02) | (1<<CS00)		; clk/1024
	out		TCCR0B, rmp
	ldi		rmp, TIMER0A_DELAY				; 20mHz/1024/250 = 78Hz
	out		OCR0A, rmp
	ldi		rmp, (1<<OCIE0A)				; enable int on compare A
	sts		TIMSK0, rmp

	; setup timer1 for 8kHz interrupt
	; timer1 is used to drive "next sample" function
	ldi		rmp, (1<<WGM12) | (1<<CS10)		; ctc, clk/1
	sts		TCCR1B, rmp
	ldi		rmp, HIGH(2500)					; 20mHz/2500 = 8kHz
	sts		OCR1AH, rmp
	ldi		rmp, LOW(2500)
	sts		OCR1AL, rmp
	ldi		rmp, (1<<OCIE1A)				; enable int on compare A
	sts		TIMSK1, rmp

	; setup timer2 for PWM output
	; Fast PWM, clk/256 (78kHz carrier)
	; OC2B (PortD3/pin 5)
	ldi		rmp, (1<<COM2B1) | (1<<COM2B0) | (1<<WGM21) | (1<<WGM20)
	sts		TCCR2A, rmp
	ldi		rmp, (1<<CS22) | (1<<CS21)
	sts		TCCR2B, rmp
	snd_on

	; initialize hardware interfaces
	rcall	SPI_MasterInit					; setup SPI
	rcall	MCP_Init						; setup MCP4801 (8 bit SPI DAC)
	rcall	TW_Init							; setup TW
	rcall	AT24C1M_Init					; setup AT24C1024B (1Mbit TW EEPROM)

	; setup sound app
	rcall	SND_Init
	rcall	SND_GetHeader					; get the sound header record

	; start the sample playback
	ldi		r20, 0
	rcall	SND_StartSample
	sts		OCR2B, r24
	sts		MCP_DATA, r24					; write first sample byte to DAC

	; write the first sound byte to the DAC
;	rcall	MCP_Output

	; setup debug led
	cbi		PORTB, PB0
	sbi		DDRB, PB0
	blue_off
	blue_en

	sei


; ================================================================================================
; Program Loop
; ================================================================================================
Loop:
	; check for software int flag
	lds		r18, SWINT_FLAGS				; load software flags byte
	andi	r18, (1<<SND_FLAG)				; mask out all bits but sound flag
	breq	Loop							; return to loop if 0: flag is not set

	; flag was set - get next sound byte and store it at our MCP
	; mark flag as processed
	lds		r18, SWINT_FLAGS				; load software flags byte
	andi	r18, ~(1<<SND_FLAG)
	sts		SWINT_FLAGS, r18

	; get our next sample byte
	rcall	SND_NextSampleByte
	cpi		r24, 0
	breq	_snd_off

	; save sample byte
	sts		MCP_DATA, r24
;	rcall	MCP_Output
	rjmp	Loop

_snd_off:
	; disable playback interrupt
	blue_off
	snd_off
	lds		rmp, TCCR1B
	andi	rmp, ~(1<<CS10)
	sts		TCCR1B, rmp
	rjmp	Loop

; ================================================================================================
; Includes
; ================================================================================================
.INCLUDE "spiutil.asm"
.INCLUDE "twiutil.asm"
.INCLUDE "mcp4801util.asm"
.INCLUDE "at24c1024butil.asm"
.INCLUDE "sndapp.asm"
