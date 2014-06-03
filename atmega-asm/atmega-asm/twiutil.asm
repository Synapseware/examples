/*
 * twiutil.asm
 *
 *  Created: 7/12/2011 6:07:17 PM
 *   Author: matthew
 *	
 *	TWI Interface library, in assembly for ATMega328
 */ 
.LISTMAC

; ================================================================================================
; Port constants
; ================================================================================================
.EQU	TW_PINS			= PINC
.EQU	TW_DDR			= DDRC
.EQU	TW_PORT			= PORTC
.EQU	TW_SCL			= PC5
.EQU	TW_SDA			= PC4


; ================================================================================================
; TW Constants
; ================================================================================================
.EQU	TW_RW			= 0
.EQU	TW_BUFF_SIZE	= 256

; ================================================================================================
; SRAM reservations
; ================================================================================================
.DSEG
TW_BUFF:		.byte	256			; size of buffer

.CSEG

; ================================================================================================
; TWI Constants
; ================================================================================================
.EQU	TW_START					 = 0x08
.EQU	TW_REP_START				 = 0x10

; Master Transmitter
.EQU	TW_MT_SLA_ACK				 = 0x18
.EQU	TW_MT_SLA_NACK				 = 0x20
.EQU	TW_MT_DATA_ACK				 = 0x28
.EQU	TW_MT_DATA_NACK				 = 0x30
.EQU	TW_MT_ARB_LOST				 = 0x38

; Master Receiver
.EQU	TW_MR_ARB_LOST				 = 0x38
.EQU	TW_MR_SLA_ACK				 = 0x40
.EQU	TW_MR_SLA_NACK				 = 0x48
.EQU	TW_MR_DATA_ACK				 = 0x50
.EQU	TW_MR_DATA_NACK				 = 0x58

; Slave Transmitter
.EQU	TW_ST_SLA_ACK				 = 0xA8
.EQU	TW_ST_ARB_LOST_SLA_ACK		 = 0xB0
.EQU	TW_ST_DATA_ACK				 = 0xB8
.EQU	TW_ST_DATA_NACK				 = 0xC0
.EQU	TW_ST_LAST_DATA				 = 0xC8

; Slave Receiver
.EQU	TW_SR_SLA_ACK				 = 0x60
.EQU	TW_SR_ARB_LOST_SLA_ACK		 = 0x68
.EQU	TW_SR_GCALL_ACK				 = 0x70
.EQU	TW_SR_ARB_LOST_GCALL_ACK	 = 0x78
.EQU	TW_SR_DATA_ACK				 = 0x80
.EQU	TW_SR_DATA_NACK				 = 0x88
.EQU	TW_SR_GCALL_DATA_ACK		 = 0x90
.EQU	TW_SR_GCALL_DATA_NACK		 = 0x98
.EQU	TW_SR_STOP					 = 0xA0

; Misc
.EQU	TW_NO_INFO					 = 0xF8
.EQU	TW_BUS_ERROR				 = 0x00

; defines and constants
.EQU	TWCR_CMD_MASK		 		 = 0x0F
.EQU	TWSR_STATUS_MASK	 		 = 0xF8

; return values
.EQU	I2C_OK				 		 = 0x00
.EQU	I2C_ERROR_NODEV				 = 0x01


.EQU	TW_FSCL						 = 400000	; 200kHz, 0.2mHz


; ================================================================================================
; Sets a START condition
; ================================================================================================
.macro twstart
	ldi		rmp, (1<<TWINT) | (1<<TWEN) | (1<<TWSTA)
	sts		TWCR, rmp
.endmacro


; ================================================================================================
; Sets a STOP condition
; ================================================================================================
.macro twstop
	ldi		rmp, (1<<TWINT) | (1<<TWEN) | (1<<TWSTO)
	sts		TWCR, rmp
.endmacro


; ================================================================================================
; Waits for the previous operation to complete
; ================================================================================================
.macro twwait
	lds		rmp, TWCR
	sbrs	rmp, TWINT
	rjmp	pc-3
.endmacro


; ================================================================================================
; Sends the byte value currently loaded in r16
; r16 is NOT preserved
; ================================================================================================
.macro twsend
	sts		TWDR, @0
	ldi		rmp, (1<<TWINT) | (1<<TWEN)
	sts		TWCR, rmp
.endmacro


; ================================================================================================
; Ack the last transfer
; ================================================================================================
.macro twack
	lds		rmp, TWCR
	andi	rmp, TWCR_CMD_MASK
	ori		rmp, (1<<TWINT) | (1<<TWEA)
	sts		TWCR, rmp
.endmacro


; ================================================================================================
; NAck the last transfer
; ================================================================================================
.macro twnack
	lds		rmp, TWCR
	andi	rmp, TWCR_CMD_MASK
	ori		rmp, (1<<TWINT)
	sts		TWCR, rmp
.endmacro


; ================================================================================================
; Fetches the TW Status value
; ================================================================================================
.macro twstat
	lds		@0, TWSR
	andi	@0, TWSR_STATUS_MASK
.endmacro


; ================================================================================================
; Opens communication with a TW device by sending the device address out
;	Parameters (registers):
;	@0	= the TW slave address byte
;	@1	= return error code
; ================================================================================================
.macro twopen
	; set default status code
	ldi		@1, I2C_OK

	; send start
	twstart							; send start signal
	twwait							; wait for ACK

	; check status
	twstat	rmp						; get status
	cpi		rmp, TW_START			; check for error
	brne	_twopen_err

	; send SLA+R/W
	twsend	@0						; send device address
	twwait							; wait for ACK

	; check for device
	twstat	rmp						; get status
	cpi		rmp, TW_MT_SLA_ACK		; check for error - should be 0x18, could be 0x18, 0x20, 0x38
	brne	_twopen_err				; quit on error
	rjmp	_twopen_done			; skip over error block

_twopen_err:
	mov		@1, rmp					; return error code
	rjmp	_twopen_done

_twopen_done:

.endmacro


; ================================================================================================
; Initialize the TW interface
; ================================================================================================
TW_Init:
	push	rmp
	in		rmp, SREG
	push	rmp

	; make sure the TW is not disabled in PRR
	lds		rmp, PRR
	andi	rmp, ~(1<<PRTWI)
	sts		PRR, rmp

	; set TW pins as outputs
	in		rmp, TW_DDR
	ori		rmp, (1<<TW_SCL) | (1<<TW_SDA)
	out		TW_DDR, rmp

	; enable the TW interface
	ldi		rmp, (1<<TWEN)
	sts		TWCR, rmp

	; clear out the TWSR + the prescaler bits (we like a fast TW interface)
	ldi		rmp, 0
	sts		TWSR, rmp

	; compute TWBR register value
	ldi		rmp, ((F_CPU/TW_FSCL)-16)/2
	sts		TWBR, rmp

	; done
	pop		rmp
	out		SREG, rmp
	pop		rmp

	ret


; ================================================================================================
; Opens communication with a TW device, and optionally sends up to 256 bytes of header data.
;	Parameters:
;		X	= Header data buffer
;		r25	= Header size
;		r24	= Device address
;	
; ================================================================================================
TW_Open:
	push	rmp
	in		rmp, SREG
	push	rmp
	push	r23

	; open communications to TW device
	twopen	r24, r23
	tst		r23
	brne	_twopen_done
	
_twopen_loop:
	; send header
	tst		r25
	breq	_twopen_done
	
	ld		rmp, X+
	twsend	rmp
	twwait
	dec		r25
	rjmp	_twopen_loop

_twopen_done:
	; done
	pop		r23
	pop		rmp
	out		SREG, rmp
	pop		rmp
	ret


; ================================================================================================
; Receives a block of data over the TW interface.  Device must already be "opened" and ready.
;	Called with the following parameters:
;		X	= Starting address of storage buffer
;		Y	= Number of bytes to receive (literal value, not count value)
;		r24 = TW Device address
;	Returns:
;		r25 = TW status code
;
;	Preserves:
;		sreg, rmp, r17
; ================================================================================================
TW_GetBlock:
	push	rmp
	in		rmp, SREG
	push	rmp
	push	r17

	; send start condition
	twstart
	twwait

	; send device address with read bit (bit 0 set)
	ori		r24, 0x01				; set RW bit
	mov		rmp, r24
	twsend rmp
	twwait

	; check if device is present & alive
	twstat	rmp
	cpi		rmp, TW_MR_SLA_ACK
	brne	_tw_mrni_nodev

	; receive loop
	ldi		r24, 0					; used for 16-bit compares
_tw_mrni_loop:
	sbiw	YH:YL, 1				; subtract 1 from our counter
	cpi		YL, 0x01				; compare low byte
	cpc		YH, r24					; compare high byte with carry
	brlo	_tw_mrni_rc				; branch if lower
	twack							; send ACK
	twwait
	lds		rmp, TWDR				; get the byte from the TWDR
	st		X+, rmp					; store received byte in buffer
	rjmp	_tw_mrni_loop

	; receive last byte and nack it
_tw_mrni_rc:
	twnack							; send NACK
	twwait
	lds		rmp, TWDR				; get last byte
	st		X+, rmp
	rjmp	_tw_mrni_done
_tw_mrni_nodev:
	ldi		r25, I2C_ERROR_NODEV	; error, no device!
_tw_mrni_done:
	twstop							; we are done, send stop

	; done
	pop		r17						; return registers
	pop		rmp
	out		SREG, rmp
	pop		rmp

	; end critical section
	ret


; ================================================================================================
; Sends a block of data over the TW interface.  Device must already be "opened" and ready.
;	Called with the following parameters:
;		X	= Starting address of storage buffer
;		r24 = TW Device address
;	Returns:
;		r25 = TW status code
;
;	Preserves:
;		sreg, rmp, r17
; ================================================================================================
TW_PutPage:
	push	rmp
	in		rmp, SREG
	push	rmp
	push	r17

	; send loop
	ldi		r17, 0xFF				; used for 16-bit compares
_tw_pb_loop:
	dec		r17						; subtract 1 from our counter
	cpi		r17, 0x01				; compare page counter
	brlo	_tw_pb_last				; branch if lower
	ld		rmp, X+
	twsend	rmp
	twwait
	rjmp	_tw_pb_loop

	; put the last byte and nack it
_tw_pb_last:
	ld		rmp, X+
	st		X+, rmp
	rjmp	_tw_pb_done
_tw_pb_nodev:
	ldi		r25, I2C_ERROR_NODEV	; error, no device!
_tw_pb_done:
	twstop							; we are done, send stop

	; wait for page write to complete before returning
_tw_pb_wait:
	twstart							; send start
	twsend	r24						; send device address
	twwait							; wait for ack
	twstop							; we are done, send stop

	; done
	pop		r17						; return registers
	pop		rmp
	out		SREG, rmp
	pop		rmp

	ret
