/*
 * AT24C1M1024b_util.asm
 *
 *  Created: 7/14/2011 9:30:26 PM
 *   Author: matthew
 *	AT24C1M1024B Device driver utility
 *	Requires TWI functionality.
 */ 


; ================================================================================================
; DATA segment for ATC1024 EEPROM
; ================================================================================================
.DSEG

.CSEG
; ================================================================================================
; AT24C1M1024B Constants
; ================================================================================================
.EQU	AT24C1M_ADDR			= 0b10100000
.EQU	AT24C1M_P0_MASK			= 0x00010000
.EQU	AT24C1M_PAGE_SIZE		= 256
.EQU	AT24C1M_PAGE_COUNT		= 512
.EQU	AT24C1M_PAGE_MASK		= 0x01FF

.EQU	AT24C1M_P0				= 1
.EQU	AT24C1M_A1				= 2
.EQU	AT24C1M_A2				= 3

.EQU	AT24C1M_DEVICE_ADDR		= 0b10100000
.EQU	AT24C1M_ADDR_MASK		= 0b10101111
.EQU	AT24C1M_MAX_SPEED		= 400000



; ================================================================================================
; Converts a logical device address to a TW address.  Simple conversion only - does not set
; P0 or RW bits.
; ================================================================================================
.macro at24c1m_twsla
	andi	@0, 0x03					; clear out all but bits 1:0
	lsl		@0							; shift left
	lsl		@0							; shift left
	ori		@0, AT24C1M_DEVICE_ADDR		; device address bits
.endmacro


; ================================================================================================
; Converts the logical address to a TW device address for the EEPROM
;	Parameters:
;	@0	= logical device address
;	@1	= 16 bit page register (X, Y, Z)
; ================================================================================================
.macro at24c1m_twaddr
	; apply page mask to page registers
	andi	@1L, LOW(AT24C1M_PAGE_MASK)
	andi	@1H, HIGH(AT24C1M_PAGE_MASK)

	; setup device address bits
	at24c1m_twsla @0
	sbrc	@1H, AT24C1M_P0				; set P0 bit (if XH is 1)
	ori		@0, (1<<AT24C1M_P0)	
	andi	@0, AT24C1M_ADDR_MASK		; make sure address is correct
.endmacro


; ================================================================================================
; Initializes the AT24C1024B device and sets the TW speed to AT24C1M_MAX_SPEED
; ================================================================================================
AT24C1M_Init:
	push	rmp

	; compute new TWBR value	
	ldi		rmp, (((F_CPU/AT24C1M_MAX_SPEED)-16)/2)
	sts		TWBR, rmp

	pop		rmp
	ret


; ================================================================================================
; Writes the desired page address to the EEPROM device.  Does not relinquish control of the bus.
;	Note: This means that pages 0-511 are selected.
;	Give desired page in X register
;		X	= Desired page
;		r25 = Byte address within the page (0-255)
;		r24	= Device address (0, 1, 2, or 3)
;	Returns
;		r23 = TW status
;		r24	= TW device address
; ================================================================================================
AT24C1M_SetAddress:
	push	rmp
	in		rmp, SREG
	push	rmp
	push	YL
	push	YH
	
	; setup device address bits
	at24c1m_twaddr r24, X				; convert logical address to TW address
	andi	r24, ~(1<<TW_RW)			; clear RW bit
	push	r24							; save device address byte

	; put the data in the TW buffer, TW_BUFF
	sts		TW_BUFF+0, XL				; save the page address high byte
	sts		TW_BUFF+1, r25				; save the page address low byte

	; prepare the call to TW_Open	
	ldi		XH, HIGH(TW_BUFF)			; load the buffer address into X
	ldi		XL, LOW(TW_BUFF)
	ldi		r25, 0x02					; load the header size
	rcall	TW_Open

	pop		r24							; restore device address byte

	; done
	pop		YH
	pop		YL
	pop		rmp
	out		SREG, rmp
	pop		rmp
	ret
	

; ================================================================================================
; Reads a page of data from the device and stores it in the buffer pointed to by X.  Releases the
; TW bus when the transfer is complete.
;		Y	= Address of buffer which will receive the data
;		X	= Desired page (0-511)
;		r25 = Byte address (0-255)
;		r24 = Device address
;		r22 = Number of bytes to read
;	Returns
;		None
; ================================================================================================
AT24C1M_ReadPage:
	; set the read address
	ldi		r25, 0					; set byte address to 0
	rcall	AT24C1M_SetAddress		; select our device and load the requested address

	ldi		YH, HIGH(TW_BUFF_SIZE)	; load the buffer size
	ldi		YL, LOW(TW_BUFF_SIZE)
	ldi		XH, HIGH(TW_BUFF)		; load the buffer address
	ldi		XL, LOW(TW_BUFF)
	rcall	TW_GetBlock			; get a block of data from the EEPROM

	ret


; ================================================================================================
; Reads a byte of data from the EEPROM and returns it.  Releases the TW bus when the transfer is
; complete.
;	Parameters:
;		X	= Desired page (0-511)
;		r25 = Byte address (0-255)
;		r24 = Device address
;	Returns:
;		r24 = Data returned by device
;	Preserves:
;		SREG, Y, rmp
; ================================================================================================
AT24C1M_ReadByte:
	; preserve registers
	push	rmp
	in		rmp, SREG
	push	rmp
	push	YL
	push	YH

	; set the read address
	rcall	AT24C1M_SetAddress		; select our device and load the requested address

	; initiate a chunk'd transfer for 1 byte
	ldi		YH, 0					; load the buffer size
	ldi		YL, 1
	ldi		XH, HIGH(TW_BUFF)		; load the buffer address
	ldi		XL, LOW(TW_BUFF)
	rcall	TW_GetBlock				; get a block of data from the EEPROM

	; load our return data
	lds		r24, TW_BUFF

	; restore registers
	pop		YH
	pop		YL
	pop		rmp
	out		SREG, rmp
	pop		rmp
	ret


; ================================================================================================
; Current address read
;	Reads a byte of data from the device and returns it in a register.  The device address used
;	is retrieved from AT24C1M_LAST_ADDRESS+0
;	Parameters:
;		r24	= Device address
;	Returns
;		r24 = Data returned by device
; ================================================================================================
AT24C1M_CurrentRead:
	; convert the device address to a TW address
	at24c1m_twsla r24
	ori		r24, (1<<TW_RW)			; set bit 0 (read operation)

	twstart							; start
	twwait

	twsend	r24						; send SLA+R
	twwait

	twack							; ack the transfer
	twwait

	lds		r24, TWDR				; load the received byte

	twnack							; nack the transfer
	twwait							; wait for device

	; stop the transfer
	twstop

_atcr_done:
	ret

