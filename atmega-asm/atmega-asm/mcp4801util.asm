/*
 * mcp4801util.asm
 *
 *  Created: 7/12/2011 10:03:10 PM
 *   Author: matthew
 *	
 *	MCP4801 Device driver utility
 *	Requires SPI functionality.
 */ 


; ================================================================================================
; MCP4801 DATA Segment
; ================================================================================================
.DSEG

MCP_COMMAND:	.byte	1
MCP_DATA:		.byte	1


.CSEG
; ================================================================================================
; MCP4801 Constants
; ================================================================================================
.EQU	MCP_CMD_MASK	= 0b00111111
.EQU	MCP_DAT_MASK	= 0b11110000

.EQU	MCP_SEL_PORT	= PORTD
.EQU	MCP_SEL_DDR		= DDRD
.EQU	MCP_SEL_PIN		= PD2

.EQU	MCP_GAIN		= 5
.EQU	MCP_SHDN		= 4

; ================================================================================================
; Initializes the MCP
;	This just test the default command and data values
; ================================================================================================
MCP_Init:
	push	rmp
	in		rmp, sreg
	push	rmp

	; setup default command byte
	ldi		rmp, 0
	sts		MCP_COMMAND, rmp

	; setup default data byte
	ldi		rmp, 0
	sts		MCP_DATA, rmp

	; setup chip select pins
	; set MCP_SEL_PIN as output, high
	sbi		MCP_SEL_PORT, MCP_SEL_PIN
	sbi		MCP_SEL_DDR, MCP_SEL_PIN

	pop		rmp
	out		sreg, rmp
	pop		rmp
	ret


; ================================================================================================
; MCP Output
; Writes the command and data values to the MCP4801
; ================================================================================================
MCP_Output:
	; begin critical section
	cli

	push	rmp
	in		rmp, sreg
	push	rmp
	push	r20		; MCP data register
	push	r21		; MCP command register

	; setup the data values
	lds		r20, MCP_DATA
	mov		r21, r20

	; shift data into position for data register
	lsl		r20
	lsl		r20
	lsl		r20
	lsl		r20

	; shift data into position for command register
	lsr		r21
	lsr		r21
	lsr		r21
	lsr		r21

	; apply transmit mask to command and data values
	andi	r21, MCP_CMD_MASK
	andi	r20, MCP_DAT_MASK

	; apply command bits to command
	ori		r21, (1<<MCP_SHDN)				; disable shutdown bit = 1 (disabled)
	andi	r21, ~(1<<MCP_GAIN)				; clear gain bit (for 2x gain)

	; send data to MCP4801!
	cbi		portd, pd7 ;debug
	cbi		MCP_SEL_PORT, MCP_SEL_PIN		; drive chip select low

	; send command byte to chip
	mov		r24, r21
	rcall	SPI_SendByte

	; send data byte to chip
	sts		SPI_BUFF, r20
	rcall	SPI_SendByte

	sbi		MCP_SEL_PORT, MCP_SEL_PIN		; deselect chip

	sbi		portd, pd7 ;debug

	; done	
	pop		r21
	pop		r20
	pop		rmp
	out		sreg, rmp
	pop		rmp

	; end critical section	
	sei

	ret

