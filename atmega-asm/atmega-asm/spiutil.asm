/*
 * spiutil.asm
 *
 *  Created: 7/12/2011 8:30:31 PM
 *   Author: matthew
 *	
 *	SPI Interface library, in assembly for ATMega328
 */ 

; ================================================================================================
; SPI constants, ports & pins
; ================================================================================================
.EQU	SPI_PINS	= PINB
.EQU	SPI_DDR		= DDRB
.EQU	SPI_PORT	= PORTB
.EQU	SPI_SCK		= PB5
.EQU	SPI_MISO	= PB4
.EQU	SPI_MOSI	= PB3
.EQU	SPI_SS		= PB2


; ================================================================================================
; DATA segment for SPI
; ================================================================================================
.DSEG
SPI_BUFF:		.byte	1		; size of buffer


.CSEG
; ================================================================================================
; Initializes the SPI interface.
; SPCR:
;	SPIE = ?	SPI Interrupt: 1 = enable, 0 = disable
;	SPE = 1
;	DORD = ?	Data order: 1 = LSB first, 0 = MSB first
;	MSTR = 1	Master bit: 1 = master, 0 = slave
;	CPOL = 0	Clock polarity:	0 = rising, 1 = falling
;	CPHA = 0	Clock phase: 0 = leading edge - sample; trailing edge - setup, 1 = leading edge setup; trailing edge sample
;	SPR1 = 1	Fosc/128 (20mHz/128 = 156.250kHz) - see table on page 175
;	SPR0 = 1
; SPCR (SPI status register)
;	SPI2X = 0	Double speed SPI bit
; SPDR (SPI data register)
;	
; ================================================================================================
SPI_MasterInit:
	push	rmp
	in		rmp, SREG
	push	rmp

	; enable the SPI in the power-reduction-register
	lds		rmp, PRR
	andi	rmp, ~(1<<PRSPI)
	sts		PRR, rmp

	; setup SPI output pins
	in		rmp, SPI_DDR
	ori		rmp, (1<<SPI_SCK) | (1<<SPI_MOSI) | (1<<SPI_SS)
	out		SPI_DDR, rmp

	; set SPI flags
	; master mode, SPI enable, fosc/16
	; 20mHz / 16 = 1.25mHz SPI clock.  Speedy.
	ldi		rmp, (1<<SPE) | (1<<MSTR) | (1<<SPR0)
	out		SPCR, rmp

	; done
	pop		rmp
	out		SREG, rmp
	pop		rmp

	ret


; ================================================================================================
; Setup SPI for slave operation
; ================================================================================================
SPI_SlaveInit:
	push	rmp

	; Set MISO output, all others input
	in		rmp, SPI_DDR
	ori		rmp, (1<<SPI_MISO)
	andi	rmp, ~(1<<SPI_SCK) & ~(1<<SPI_MOSI) & ~(1<<SPI_SS)
	out		SPI_DDR, rmp

	; Enable SPI
	ldi		rmp, (1<<SPE)
	out		SPCR, rmp

	; done
	pop		rmp

	ret


; ================================================================================================
; Sends a byte of data from the SPI_BUFF SRAM location
;	Parameters:
;		r24	= Data to transmit
; ================================================================================================
SPI_SendByte:
	push	rmp
	in		rmp, SREG
	push	rmp

	; copy byte to send over SPI to SPDR
	out		SPDR, r24

	; wait for last send to complete
_spi_sb_wait:
	in		rmp, SPSR
	sbrs	rmp, SPIF
	rjmp	_spi_sb_wait

	; done
	pop		rmp
	out		SREG, rmp
	pop		rmp
	ret


; ================================================================================================
; Sends a byte of data from the SPI_BUFF SRAM location
; ================================================================================================
SPI_SendNoWait:
	push	rmp

	; copy byte to send over SPI to SPDR
	lds		rmp, SPI_BUFF
	out		SPDR, rmp

	; done
	pop		rmp
	ret


; ================================================================================================
; Gets a byte of data from the SPI interface and returns it in r24
; ================================================================================================
SPI_SlaveReceive:
	push	rmp
	in		rmp, SREG
	push	rmp

	; Wait for reception complete
	in		r16, SPSR
	sbrs	r16, SPIF
	rjmp	pc-3

	; Read received data and return
	in		r24, SPDR

	; done
	pop		rmp
	out		SREG, rmp
	pop		rmp
	ret
