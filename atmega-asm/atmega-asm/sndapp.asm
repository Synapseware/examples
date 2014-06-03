/*
 * sndapp.asm
 *
 *  Created: 7/19/2011 8:32:04 PM
 *   Author: matthew
 *
 * Sound App Support
 * Can read EEPROM header and interpret sound files
 */

; ================================================================================================
; Sound App Constants
; ================================================================================================
.EQU	SND_ENTRY_SZ			= 10		; each record takes 10 bytes
.EQU	SND_ENTRY_CNT			= 25		; there are max 25 entries
.EQU	SND_HEADER_PAGE_ADDR	= 0x0000	; page address where sound header is located (0-511)
.EQU	SND_HEADER_BYTE_ADDR	= 0x00		; byte address where sound header is located (0-255)
.EQU	SND_HEADER_SZ			= (2+(SND_ENTRY_SZ*SND_ENTRY_CNT)+4)

.EQU	SND_HDR_SIGNATURE		= 0		; 2 chars
.EQU	SND_HDR_START_PAGE		= 2		; 16 bit
.EQU	SND_HDR_TOTAL_PAGES		= 4		; 16 bit
.EQU	SND_HDR_LAST_PAGE_SZ	= 6		; 8 bit
.EQU	SND_HDR_SAMPLE_RATE		= 8		; 16 bit

; ================================================================================================
; Sound App SRAM reservations
; ================================================================================================
.DSEG
SND_HEADER:		.byte		SND_HEADER_SZ	; number of samples (0-255)

SND_SAMPLE:		.byte		3				; current sound sample info

.CSEG

; ================================================================================================
; Initialize the sound app
; ================================================================================================
SND_Init:
/*
	ldi			ZH, HIGH(TEST_HEADER*2)
	ldi			ZL, LOW(TEST_HEADER*2)
	ldi			XH, HIGH(SND_HEADER)
	ldi			XL, LOW(SND_HEADER)
	ldi			r17, 0
_snd_init_loop:
	lpm			rmp, Z+
	st			X+, rmp
	dec			r17
	brne		_snd_init_loop
*/
	ret


; ================================================================================================
; Loads the sound header from the EEPROM
; ================================================================================================
SND_GetHeader:

	; prepare for page load
	ldi		YH, HIGH(SND_HEADER)			; load sound header
	ldi		YL, LOW(SND_HEADER)
	ldi		XH, HIGH(SND_HEADER_PAGE_ADDR)	; load sound header page
	ldi		XL, LOW(SND_HEADER_PAGE_ADDR)
	ldi		r25, SND_HEADER_BYTE_ADDR		; byte address
	ldi		r24, EEPROM_ADDRESS				; EEPROM address
	ldi		r22, SND_HEADER_SZ-1			; size of sound header
	rcall	AT24C1M_ReadPage

	ret


; ================================================================================================
; Setups up the EEPROM for a sequential read, starting at the first sound byte
; Size of sample is returned in ___ register
; Parameters:
;		r20	= Which sample to setup playback for (0-24)
; Returns:
;		r24 = First byte of sound data
; ================================================================================================
SND_StartSample:

;	blue_on

	; prepare for page load, starting at sound sample address __
	ldi		YH, HIGH(SND_HEADER)			; load sound header address
	ldi		YL, LOW(SND_HEADER)
	adiw	YH:YL, 2						; skip past record count + reserved byte
	add		YL, r20							; add record index

	; find start page
	ldd		XL, Y+SND_HDR_START_PAGE		; load the page address into X register
	ldd		XH, Y+SND_HDR_START_PAGE+1

	; load the first byte of sound data
	ldi		r25, 0							; byte 0 in our selected page
	ldi		r24, EEPROM_ADDRESS				; logical address
	rcall	AT24C1M_ReadByte

	; save sound byte
	mov		r20, r24

	; load sample size data
	; correct for bad data layout in file :(
	ldd		rmp, Y+SND_HDR_LAST_PAGE_SZ		; load last page size
	sts		SND_SAMPLE+0, rmp
	ldd		rmp, Y+SND_HDR_TOTAL_PAGES		; load page size low order byte
	sts		SND_SAMPLE+1, rmp
	ldd		rmp, Y+SND_HDR_TOTAL_PAGES+1	; load page size high order byte
	sts		SND_SAMPLE+2, rmp

	lds		XL, SND_SAMPLE+0
	lds		XH, SND_SAMPLE+1

	ldi		r25, 0x9b
	cp		XL, r25
	ldi		r25, 0x32
	cpc		XH, r25
	brne	_snd_ss1
	blue_on
_snd_ss1:


	ret


; ================================================================================================
; Gets the next sample byte
; Returns:
;		r24 = Sound data (1-254)
;				=0: No more data
;				>0: Sound data
; ================================================================================================
SND_NextSampleByte:

	; load the current play position
	lds		XL, SND_SAMPLE+0
	lds		XH, SND_SAMPLE+1

	; decrement playback counter
	sbiw	XH:XL, 1
	sts		SND_SAMPLE+0, XL
	sts		SND_SAMPLE+1, XH

	; if playcounter is @ 0, then we are done with playback
	brne	_snd_nxt1				; if X is not 0
	ldi		r24, 0					; return a 0
	rjmp	_snd_done

_snd_nxt1:

	; get the next byte
	ldi		r24, EEPROM_ADDRESS
	rcall	AT24C1M_CurrentRead

_snd_done:
	ret


; ================================================================================================
; Sample header for testing :)
; ================================================================================================
TEST_HEADER:		.db		0x30, 0x00, 0x70, 0x64, 0x01, 0x00, 0x32, 0x00,\
							0x9b, 0x00, 0x40, 0x1f, 0x70, 0x75, 0x33, 0x00,\
							0x3c, 0x00, 0x74, 0x00, 0x40, 0x1f, 0x72, 0x61,\
							0x6f, 0x00, 0x1f, 0x00, 0xfc, 0x00, 0x40, 0x1f


