;16-bit Real-Time FFT Demo on an 8bit AVR (ATMega88) (As On Youtube http://www.youtube.com/watch?v=tCmaOb-VAEo )
;Craig Webster (IXIBA)
;Ver 30/11/2013

;Found this usefull?
;BTC 1LqDCrj8QAUjACnjRNEw8vq3T9p2R5k5RW


;Set TAB space = 7
;^^^^^^^^^^^^^^^^^

.nolist
.include "m88def.inc"
.list


;OLED interface
.equ	OLED_SDIN	=PD0	;Serial Data
.equ	OLED_SCLK	=PD1	;Serial Clock, Clock on rising
.equ	OLED_Dat_Cnt	=PD2	;Data or Control registers, 1=Data 0=Control
.equ	OLED_RES	=PD3	;Reset, 0=Reset
.equ	OLED_SCE	=PD4	;Chip Enable, 0=Active

.equ	OLED_12V	=PD5	;Enable 12 Power to OLED, 0=On (If Used)

.equ	Diag_LED	=PB7
.equ	Diag_Sync	=PB6


;.def	MultL			=r0
;.def	MultH			=r1
;.def	=r2
;.def	=r3
;.def	=r4
;.def	=r5
;.def	=r6
;.def	=r7
;.def	=r8
;.def	=r9
;.def	=r10
;.def	=r11
;.def	=r12
;.def	=r13
.def	Curent_Buffer_H	=r14	;MSB of current Buffer
.def	Column_Count		=r15
.def	temp			=r16
.def	flags			=r17	;Global, Don't reuse
.def	Loop_Count		=r18
.def	temp1			=r19
;.def	=r20
;.def	=r21
;.def	=r22
;.def	=r23
;.def	=r24
;.def	=r25
;r27,r26 Xh:Xl
;r29,r28 Yh:Yl
;r31,r30 Zh:Zl


;General Flags
;.equ	=0
;.equ	=1
;.equ	=2
;.equ	=3
.equ	Toggle_Buf		=4
.equ	AFull			=5		;1=A Buffer Full, will block ADC till 0 (Data proccesed)
.equ	BFull			=6		;1=B Buffer Full, will block ADC till 0 (Data proccesed)
.equ	ADCFillAorB		=7		;1=ADC to fill A

.equ	FFT_Size		=64		;8, 16, 32, 64 (Any larger requires 16 bit numbers in parts of routine)

.equ	N_Wave			=64		;Size of full sine table (Table actualy 3/4 of this size)
.equ	Log2_NW		=7		;Log2 of N_Wave
.equ	ND2			=(FFT_Size*4)/2	;Odd/Even Decomp

.equ	Peak_Drop		=2		;Peak drop (fall) per update cycle


.equ	Del_15ms		=120		;Value for 15ms delay, 1Mhz=15, 2Mhz=30, 4Mhz=60, 8Mhz=120, 16Mhz=240
.equ	Contrast		=0x80		;0<>0xff
.equ	OLED_Right_Edge	=63		;Set right edge if not all display used 0<>127
.equ	Y_Max			=63		;OLED Max Y


;
;******************************************
;*                                        *
;*            Start/Init                  *
;*                                        *
;******************************************
;


.CSEG
	.org	0000
	rjmp	Reset

	.org	INT0addr	; External Interrupt Request 0
	reti

	.org	INT1addr	; External Interrupt Request 1
	reti

	.org	PCI0addr	; Pin Change Interrupt Request 0
	reti

	.org	PCI1addr	; Pin Change Interrupt Request 0
	reti

	.org	PCI2addr	; Pin Change Interrupt Request 1
	reti

	.org	WDTaddr	; Watchdog Time-out Interrupt
	reti

	.org	OC2Aaddr	; Timer/Counter2 Compare Match A
	reti

	.org	OC2Baddr	; Timer/Counter2 Compare Match A
	reti

	.org	OVF2addr	; Timer/Counter2 Overflow
	reti

	.org	ICP1addr	; Timer/Counter1 Capture Event
	reti

	.org	OC1Aaddr	; Timer/Counter1 Compare Match A
	reti

	.org	OC1Baddr	; Timer/Counter1 Compare Match B
	reti

	.org	OVF1addr	; Timer/Counter1 Overflow
	reti

	.org	OC0Aaddr	; TimerCounter0 Compare Match A
	reti

	.org	OC0Baddr	; TimerCounter0 Compare Match B
	reti

	.org	OVF0addr	; Timer/Couner0 Overflow
	reti

	.org	SPIaddr	; SPI Serial Transfer Complete
	reti

	.org	URXCaddr	; USART Rx Complete
	reti

	.org	UDREaddr	; USART, Data Register Empty
	reti

	.org	UTXCaddr	; USART Tx Complete
	reti

	.org	ADCCaddr	; ADC Conversion Complete
	rjmp	ADC_Int

	.org	ERDYaddr	; EEPROM Ready
	reti

	.org	ACIaddr	; Analog Comparator
	reti

	.org	TWIaddr	; Two-wire Serial Interface
	reti

	.org	SPMRaddr	; Store Program Memory Read
	reti




Reset:	ldi	temp,high(RAMEND)	;Set stack pointer
	out	SPH,temp
	ldi	temp,low(RAMEND)
	out	SPL,temp

;Watchdog
	cli				;Disabe Watdog to prevent endless reset cycle (Code from data sheet)
	wdr
	in	temp,MCUSR
	cbr	temp,1<<WDRF
	out	MCUSR,temp
	lds	temp,WDTCSR
	sbr	temp,(1<<WDCE | 1<<WDE)
	sts	WDTCSR,temp
	ldi	temp,0<<WDE
	sts	WDTCSR,temp

;CPU Clock
	ldi	temp,1<<CLKPCE	;Set clock prescaler
	sts	CLKPR,temp

;	ldi	temp,( 0<<CLKPCE | 0<<CLKPS3 | 0<<CLKPS2 | 1<<CLKPS1 | 1<<CLKPS0)
;	sts	CLKPR,temp	;8Mhz/8=1Mhz

;	ldi	temp,( 0<<CLKPCE | 0<<CLKPS3 | 0<<CLKPS2 | 1<<CLKPS1 | 0<<CLKPS0)
;	sts	CLKPR,temp	;8Mhz/4=2Mhz

;	ldi	temp,( 0<<CLKPCE | 0<<CLKPS3 | 0<<CLKPS2 | 0<<CLKPS1 | 1<<CLKPS0)
;	sts	CLKPR,temp	;8Mhz/2=4Mhz

	ldi	temp,( 0<<CLKPCE | 0<<CLKPS3 | 0<<CLKPS2 | 0<<CLKPS1 | 0<<CLKPS0)
	sts	CLKPR,temp	;8Mhz/1=8Mhz


;
;D Port
	ldi	temp,(1<<OLED_SDIN | 1<<OLED_SCLK | 1<<OLED_Dat_Cnt | 1<<OLED_SCE | 1<<OLED_RES | 1<<OLED_12V)
	out	ddrd,temp	;Set OLED interface pins to output
	ldi	temp,(0<<OLED_RES | 1<<OLED_SCE | 1<<OLED_12V)
	out	portd,temp	;Keep reset and disabled till ready

;
;B Port
	ldi	temp,(1<<Diag_LED | 1<<Diag_Sync)
	out	ddrb,temp

;
;ADC
	ldi	temp,(0<<REFS1 | 1<<REFS0 | 0<<ADLAR | 0<<MUX3 | 0<<MUX2 | 0<<MUX1 | 0<<MUX0)
	sts	ADMUX,temp	;Right adjust (10)bit,Ref=Vcc, ADC0

	ldi	temp,(0<<ADC5D | 0<<ADC4D | 0<<ADC3D | 0<<ADC2D | 0<<ADC1D | 1<<ADC0D)
	sts	DIDR0,temp	;Disable digital input on ADC0

	ldi	temp,(0<<ACME | 0<<ADTS2 | 0<<ADTS1 | 0<<ADTS0)
	sts	ADCSRB,temp	;Comparitor off, Free running

	ldi	temp,(1<<ADEN | 0<<ADSC | 1<<ADATE | 0<<ADIF | 1<<ADIE | 1<<ADPS2 | 1<<ADPS1 | 0<<ADPS0)
	sts	ADCSRA,temp	;Clk= (8Mhz/64)/13 = 9.615Ks/s


;
;Initialize Hardware
	rcall	OLED_Initialize_SSD1306
	rcall	Clear_Display

;
;Defaults
	clr	flags

	rcall	OLED_Zero_Pos


	ldi	temp,high(FFT_Data_IRB)
	mov	Curent_Buffer_H,temp

	rcall	Initialize_FFT_Buffer

	ldi	temp,high(FFT_Data_IRA)
	mov	Curent_Buffer_H,temp

	rcall	Initialize_FFT_Buffer

	clr	temp
	sts	Fill_Offset,temp

	sbr	flags,(1<<ADCFillAorB)
	cbr	flags,(1<<AFull | 1<<BFull | 1<<ADCFillAorB)

	cbi	portb,Diag_LED

	rcall	Fill_Peaks

	lds	temp,ADCSRA	;Start conversion to start freerun ADC
	ori	temp,1<<ADSC
	sts	ADCSRA,temp


	sei			;Global Int enable

;
;*****************************************
;
;  Main program
;
;*****************************************
;
FFT_Cycle:
	clr	Column_Count
	ldi	Loop_Count,4

Buffer_WaitT:
	sbrc	flags,Toggle_Buf	;Alternate which buffer to do 'Full' test on 1st
	rjmp	BW_tryB

Buffer_Wait:
	sbrc	flags,Afull		;Use whatever buffer is full (To guard against a lock cycle)
	rjmp	FFT_Use_A		;But should still follow ABABAB.. cycle

BW_tryB:
	sbrs	flags,Bfull
	rjmp	Buffer_Wait

FFT_Use_B:
	ldi	temp,high(FFT_Data_IRB)
	mov	Curent_Buffer_H,temp

	rcall	FFT_Fixed64OE
	rcall	Convert_RItoR
	rcall	Initialize_FFT_Buffer
	cbr	flags,(1<<Bfull | 1<<Toggle_Buf)
	rjmp	FFT_Cnt
	

FFT_Use_A:
	ldi	temp,high(FFT_Data_IRA)
	mov	Curent_Buffer_H,temp


	rcall	FFT_Fixed64OE
	rcall	Convert_RItoR
	rcall	Initialize_FFT_Buffer
	cbr	flags,1<<Afull
	sbr	flags,1<<Toggle_Buf

FFT_Cnt:
	rcall	Update_OLED_8

	dec	Loop_Count
	brne	Buffer_WaitT

	rcall	Process_Average
	rjmp	FFT_Cycle

;
;*****************************************
;
;  FFT test
;
;*****************************************
;
;
Fill_Peaks:				;Prefill Peak values in FFT_Data_Display
					;In:
					;Out: FFT_Data_Display
	push	Zh
	push	Zl
	push	Loop_Count
	push	temp

	ldi	Zh,high(FFT_Data_Display+1)
	ldi	Zl,low(FFT_Data_Display+1)

	ldi	temp,65		;Default peak + 1 to compensate for Drop
	ldi	Loop_Count,(FFT_Size/2)

FP_Pfil:
	st	Z+,temp
	adiw	Zh:Zl,1
	dec	Loop_Count
	brne	FP_Pfil

FP_X:	pop	temp
	pop	Loop_Count
	pop	Zl
	pop	Zh
	ret
;
;
Initialize_FFT_Buffer:		;Do whats needed to get buffer ready to recieve data
					;In:Curent_Buffer_H
					;Out: FFT Index,Count (DSEG)
	push	Zh
	push	Zl
	push	Xh
	push	Xl
	push	temp
	push	Loop_Count

	ldi	Zh,high(Bit_Flip_OffsetsOE << 1)
	ldi	Zl,low(Bit_Flip_OffsetsOE << 1)

	mov	Xh,Curent_Buffer_H
	ldi	Xl,0			;on 0x0100 boundery

	clr	Loop_Count		;zero
	
IFBA_lp:
	lpm	temp,Z+		;Store value of next index in MSB for conveniance
	st	X+,temp
	st	X+,Loop_Count

	tst	temp			;then end of table is coneniantly 0x00
	brne	IFBA_lp

	pop	Loop_Count
	pop	temp
	pop	Xl
	pop	Xh
	pop	Zl
	pop	Zh
	ret
;
;
Convert_RItoR:		;Covert FFT output (1 > 30)Complex (RI) to  Real, Add to Real buffer for averaging
				;32 bins - DC & last = 30 bins
				;Bins 1 > 30, Bin 0=DC, 30= ((FFT/2)-1)-1  2nd -1 because bins start at 0 not 1
				;In:  FFT_Data_IR, Curent_Buffer_H
				;Out: FFT_Data_Real_AV
	push	Zh
	push	Zl
	push	Yh
	push	Yl

	push	r23		;H	Mutiply n*n		
	push	r22		;L

	push	r15		;H	Multiply result R*R
	push	r14
	push	r13
	push	r12		;L

	push	r11		;H	Multiply result I*I
	push	r10
	push	r9
	push	r8		;L

	push	r1
	push	r0

	push	temp
	push	Loop_Count

	ldi	temp,0

;Real = Sqtr((R*R) + (I*I))

	mov	Zh,Curent_Buffer_H		;0n 0x100 boundery
	ldi	Zl,4				;+4 to skip DC RI

	ldi	Yh,high(FFT_Data_Real_AV+2)	;+2 to skip DC
	ldi	Yl,low(FFT_Data_Real_AV+2)

	ldi	Loop_Count,(FFT_Size/2)-2	;(32-1)-1 (Skipped DC & last)


CR_Lp:
	ld	r23,Z+				;R * R
	ld	r22,Z+

;R * R = r23:r22 * r23:r22 = r15:r14:r13:r12
	muls	r23,r23
	movw	r15:r14,r1:r0

	mul	r22,r22
	movw	r13:r12,r1:r0

	mulsu	r23,r22
	sbc	r15,temp
	add	r13,r0
	adc	r14,r1
	adc	r15,temp

	mulsu	r23,r22
	sbc	r15,temp
	add	r13,r0
	adc	r14,r1
	adc	r15,temp

	ld	r23,Z+				;I * I
	ld	r22,Z+

;I * I = r23:r22 * r23:r22 = r11:r10:r9:r8
	muls	r23,r23
	movw	r11:r10,r1:r0

	mul	r22,r22
	movw	r9:r8,r1:r0

	mulsu	r23,r22
	sbc	r11,temp
	add	r9,r0
	adc	r10,r1
	adc	r11,temp

	mulsu	r23,r22
	sbc	r11,temp
	add	r9,r0
	adc	r10,r1
	adc	r11,temp

	add	r12,r8				; R*R + I*I
	adc	r13,r9				; r15:r14:r13:r12 + r11:r10:r9:r8
	adc	r14,r10
	adc	r15,r11

	rcall	Sqrt				;Sqr(r15:r14:r13:r12) = r13:r12

	ld	r23,Y
	ldd	r22,Y+1

	add	r12,r22			;Add to previouse sample for averaging
	adc	r13,r23

	st	Y+,r13
	st	Y+,r12

	dec	Loop_Count
	brne	CR_Lp

CR_X:	pop	Loop_Count
	pop	temp
	pop	r0
	pop	r1
	pop	r8
	pop	r9
	pop	r10
	pop	r11
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	pop	r22
	pop	r23
	pop	Yl
	pop	Yh
	pop	Zl
	pop	Zh
	ret

;
;
Process_Average:			;Convert Average data to Display Data & Clear Averaging Buffer
					;In: FFT_Data_Real_AV
					;Out:FFT_Data_Display
	push	Xh
	push	Xl
	push	Yh
	push	Yl
	push	Zh
	push	Zl
	push	Loop_Count
	push	temp

	clr	temp

	ldi	Zh,high(FFT_Data_Real_AV)
	ldi	Zl,low(FFT_Data_Real_AV)

	ldi	Yh,high(FFT_Data_Display)
	ldi	Yl,low(FFT_Data_Display)

	st	Z+,temp			;Not using DC data but clear anyhow
	st	Z+,temp

	st	Y+,temp
	st	Y+,temp

	ldi	Loop_Count,(FFT_Size/2)-2	;32 - DC & last
PA_Lp:
	ld	Xh,Z				;Average Data /4
	st	Z+,temp			;Clear Buffer as used
	ld	Xl,Z
	st	Z+,temp

	lsr	Xh				;All positive numbers, no sighn
	ror	Xl
	lsr	Xh
	ror	Xl

	tst	Xh				;if Xh:Xl > 0xff then Xl=0xff
	breq	PA_OK
	ldi	Xl,0xff
PA_OK:
	st	Y+,Xl
	adiw	Yh:Yl,1			;Skip Peak holding byte


	dec	Loop_Count
	brne	PA_Lp

PA_X:	pop	temp
	pop	Loop_Count
	pop	Zl
	pop	Zh
	pop	Yl
	pop	Yh
	pop	Xl
	pop	Xh
	ret
;
;*****************************************
;
;  FFT
;
;*****************************************
;
FFT_Fixed64OE:		;FFT 64 Fixpoint, Odd Even Decomposition (Ver 26/5/2013)
				;By Craig Webster (IXIBA)
				;Derived from
				;Numerical Recipes, The Art of Scientific Computing. Teukolsky
				;Digital Signal Processing, A Practical Guide for Engineers & Scientists. Smith
				;http://arduino-integer-fft.googlecode.com/files/fix_fft.cpp
				;
				;In:  FFT_Data_RI[] (DSEG), Curent_Buffer_H
				;Out: FFT_Data_RI[] (DSEG)

	push	Zh
	push	Zl		;Ver j
	push	Yh
	push	Yl		;Ver i

	push	Xh		;Ver l	

	push	Xl		;Ver m

	push	r25		;Ver k

	push	r24		;FFT_Size for C loop

	push	r23		;H  Wr
	push	r22		;L

	push	r21		;H  Wi
	push	r20		;L  

	push	r19		;Repl X for Mulsu
	push	r18

;	push	r17 ;Flags, Global

	push	temp

	push	r15		;H  Tr
	push	r14		;L

	push	r13		;H  Ti
	push	r12		;L

	push	r11		;H  Qr
	push	r10		;L

	push	r9		;H  Qi
	push	r8		;L

	push	r7		;H  Temp16A
	push	r6		;L

	push	r5		;H  Temp16B
	push	r4		;L

	push	r3		;Ver istep

	push	r2		;Ver idx

	push	r1		;Mul
	push	r0


	ldi	temp,0				;0 for maths
	ldi	r25,N_Wave			;k = Size of full Sin table

;	ldi	Yh,high(FFT_Data_IR)		;(i) Pointer int IR data, high byte should not need changing
	mov	Yh,Curent_Buffer_H


;Setup for Half FFT (32)
	ldi	r24,(32*4)-1			;(FFT_Size*4)-1
	sts	OE_FFT_Size,r24
	ldi	r24,FFT_Size*2		;For C Loop, 32 first run (32*2)
	ldi	Xh,4				;l = 4;

	rcall	FFT64_LoopA

	rcall	OE_Decomp

;Setup for last cycle of FFT64
	ldi	r24,(FFT_Size*4)-1		;(FFT_Size*4)-1
	sts	OE_FFT_Size,r24
	ldi	r25,2				;K=2 (one loop of A)
	ldi	Xh,0x80			;l=0x80
	ldi	r24,0xff

	rcall	FFT64_LoopA
	rjmp	FFT_X

FFT64_LoopA:
	mov	r3,Xh				;istep = l<<1
	lsl	r3

	clr	r2				;idx = 0
	clr	Xl				;m = 0

FFT64_LoopB:
	ldi	Zh,high(SineWave64<<1)	;High byte of sine table
	mov	Zl,r2				;wi = -Sintable(idx)

	lpm	r20,Z+
	lpm	r21,Z+

	com	r20				;make -ve
	com	r21
	subi	r20,-1
	sbci	r21,-1


	subi	Zl,-((N_Wave/2)-2)		;wr = Sinetable(idx + N_Wave/2)
	lpm	r22,Z+
	lpm	r23,Z

	mov	Zh,Yh				;FFT_Dat_RI(j), aligned to 0x100 boundry

	mov	Yl,Xl				;i = m, i is also lower adress of (i) offset YH:Yl

FFT64_LoopC:
	mov	Zl,Yl				;j = i + L
	add	Zl,Xh

	ld	r19,Z				;=R(j)
	ldd	r18,Z+1

;wr * R(j) = Tr:Temp16B,  r23:r22 * r19:r18 = r15:r14:r5:r4
	muls	r23,r19
	movw	r15:r14,r1:r0

	mul	r22,r18
	movw	r5:r4,r1:r0

	mulsu	r23,r18
	sbc	r15,temp
	add	r5,r0
	adc	r14,r1
	adc	r15,temp

	mulsu	r19,r22
	sbc	r15,temp
	add	r5,r0
	adc	r14,r1
	adc	r15,temp


;wi * R(j) = Ti:Qi,  r21:r20 * r19:r18 = r13:r12:r9:r8
	muls	r21,r19
	movw	r13:r12,r1:r0

	mul	r20,r18
	movw	r9:r8,r1:r0

	mulsu	r21,r18
	sbc	r13,temp
	add	r9,r0
	adc	r12,r1
	adc	r13,temp

	mulsu	r19,r20
	sbc	r13,temp
	add	r9,r0
	adc	r12,r1
	adc	r13,temp


	ldd	r19,Z+2		;=I(j)
	ldd	r18,Z+3

;wi * I(j) = Qr:Temp16,  r21:r20 * r19:r18 = r11:r10:r7:r6
	muls	r21,r19
	movw	r11:r10,r1:r0

	mul	r20,r18
	movw	r7:r6,r1:r0

	mulsu	r21,r18
	sbc	r11,temp
	add	r7,r0
	adc	r10,r1
	adc	r11,temp

	mulsu	r19,r20
	sbc	r11,temp
	add	r7,r0
	adc	r10,r1
	adc	r11,temp

	
	sub	r5,r7	
	sbc	r14,r10		;Tr = (wr * R[j]) - (wi * I[j])
	sbc	r15,r11		;   = ( Tr:T16BH  -   Qr:T16AH) << 1
	lsl	r5
	rol	r14
	rol	r15

;wr * I(j) = Qr:Temp16,  r23:r22 * r19:r18 = r11:r10:r7:r6
	muls	r23,r19
	movw	r11:r10,r1:r0

	mul	r22,r18
	movw	r7:r6,r1:r0

	mulsu	r23,r18
	sbc	r11,temp
	add	r7,r0
	adc	r10,r1
	adc	r11,temp

	mulsu	r19,r22
	sbc	r11,temp
	add	r7,r0
	adc	r10,r1
	adc	r11,temp

	add	r9,r7
	adc	r12,r10		;Ti = (wi * R[j]) + (wr * I[j])
	adc	r13,r11		;   = ( Ti:QiH    +   Qr:T16AH) <<1
	lsl	r9
	rol	r12
	rol	r13

	
	ld	r11,Y			;Qr = R[i]
	ldd	r10,Y+1

	ldd	r9,Y+2			;Qi = I[i]
	ldd	r8,Y+3

	asr	r11			;Qr >> 1
	ror	r10

	asr	r9			;Qi >> 1
	ror	r8

	movw	r7:r6,r11:r10		;temp16A = Qr

	sub	r10,r14		;Qr - Tr
	sbc	r11,r15

	add	r6,r14			;(Temp16A) Qr + Tr
	adc	r7,r15

	std	Z+0,r11		;R[j] = Qr - Tr
	std	Z+1,r10

	std	Y+0,r7			;R[i] = Qr + Tr
	std	Y+1,r6

	movw	r7:r6,r9:r8		;temp16A = Qi

	sub	r8,r12			;Qi - Ti
	sbc	r9,r13

	add	r6,r12			;(Temp16A) Qi + Ti
	adc	r7,r13

	std	Z+2,r9			;I[j] = Qi - Ti
	std	Z+3,r8
		
	std	Y+2,r7			;I[i] = Qi + Ti
	std	Y+3,r6

;Loop Control CCCCCCCCCCCC
	add	Yl,r3			;i += istep
	brcs	FFT64_LoopB_Cont	;This is for FFT64
	breq	FFT64_LoopB_Fix	;Detect one off situatiom when istep = 0 (0x100) and i = 0 (FFT64)
	cp	Yl,r24			;This is for FFT32 (or less)
	brsh	FFT64_LoopB_Cont

	rjmp	FFT64_LoopC

FFT64_LoopB_Fix:			;Fix problem of istep (8bit) needing to be 0x0100 during last loop cycle
	com	r3			;istep = 0xff

;Loop Control BBBBBBBBBBBBB
FFT64_LoopB_Cont:
	subi	Xl,-4			;m += 4

	cp	Xl,Xh			;Loop if m<l
	brsh	FFT64_LoopA_Cont

	add	r2,r25			;idx += k
	rjmp	FFT64_LoopB

;Loop Control AAAAAAAAAAAAA
FFT64_LoopA_Cont:


	lds	Xh,OE_FFT_Size	;Current running FFT Size
	cp	r3,Xh			;while (n*4 > l)
	brsh	FFT_Done

	mov	Xh,r3			;l = istep
	lsr	r25			;k >>= 1
	rjmp	FFT64_LoopA
FFT_Done:
	ret	



FFT_X:	pop	r0
	pop	r1
	pop	r2
	pop	r3
	pop	r4
	pop	r5
	pop	r6
	pop	r7
	pop	r8
	pop	r9
	pop	r10
	pop	r11
	pop	r12
	pop	r13
	pop	r14
	pop	r15
	pop	temp
;	pop	r17
	pop	r18
	pop	r19
	pop	r20
	pop	r21
	pop	r22
	pop	r23
	pop	r24
	pop	r25
	pop	Xl
	pop	Xh
	pop	Yl
	pop	Yh
	pop	Zl
	pop	Zh
	ret

OE_Decomp:
;Zh:Zl		Base [i]
;Yh:Yl		Base [-]
;r25:Xh:Xl	nA
;r24:r23:r22	nB
;r21		IM
;r20		IP2
;r19		IPM

	mov	Zh,Yh

	ldi	Zl,FFT_Size-4		;x[i]

OD_Lp:

;IM = ND2-i
	ldi	r21,ND2
	sub	r21,Zl
	
;IP2 = ND2+i
	ldi	r20,ND2
	add	r20,Zl
	
;IPM = ND2+IM
	ldi	r19,ND2
	add	r19,r21
	
;R[IP2] = (I[i] + I[IM])/2
;R[IPM] =
	mov	Yl,r21			;x[IM]

	clr	r24			;nB = I[IM]
	ldd	r23,Y+2		;R24:R23:R22
	ldd	r22,Y+3
	sbrc	r23,7
	com	r24

	clr	r25			;nA = I[i]
	ldd	Xh,Z+2			;R25:Xh:Xl
	ldd	Xl,Z+3
	sbrc	Xh,7
	com	r25

	add	Xl,r22			;nA + nB
	adc	Xh,r23
	adc	r25,r24

	ror	r25			;/2
	ror	Xh
	ror	Xl

	mov	Yl,r20			;x[IP2]
	st	Y+,Xh			;R[IP2] =
	st	Y,Xl

	mov	Yl,r19			;x[IPM]
	st	Y+,Xh			;R[IPM] =
	st	Y,Xl

;I[IP2] = -((R[i] - R[IM])/2)
;I[IPM] = +
	mov	Yl,r21			;x[IM]

	ld	r23,Y+			;nB = R[IM]
	ld	r22,Y			;R23:R22

	ld	Xh,Z			;nA = R[i]
	ldd	Xl,Z+1			;Xh:Xl

	sub	Xl,r22			;nA - nB
	sbc	Xh,r23

	asr	Xh			;/2
	ror	Xl

	mov	Yl,r19			;x[IPM]
	std	Y+2,Xh			;I[IPM] = +Ve
	std	Y+3,Xl

	com	Xl			;-ve
	com	Xh
	subi	Xl,-1
	sbci	Xh,-1

	mov	Yl,r20			;x[IP2]
	std	Y+2,Xh			;I[IP2] = -Ve
	std	Y+3,Xl

;R[i]  = (R[i] + R[IM])/2
;R[IM] = 
	mov	Yl,r21			;x[IM]

	clr	r24
	ld	r23,Y			;nB = R[IM]
	ldd	r22,Y+1		;R24:R23:R22
	sbrc	r23,7
	com	r24


	clr	r25			;nA = R[i]
	ld	Xh,Z			;R25:Xh:Xl
	ldd	Xl,Z+1
	sbrc	Xh,7
	com	r25

	add	Xl,r22			;nA + nB
	adc	Xh,r23
	adc	r25,r24

	ror	r25			;/2
	ror	Xh
	ror	Xl

	st	Z,Xh			;R[i] =
	std	Z+1,Xl

	st	Y,Xh			;R[IM] =
	std	Y+1,Xl

;I[i]  = (I[i] - I[IM])/2
;I[IM] = -

	ldd	r23,Y+2		;nB = I[IM]
	ldd	r22,Y+3

	ldd	Xh,Z+2			;nA = I[i]
	ldd	Xl,Z+3

	sub	Xl,r22			;nA - nB
	sbc	Xh,r23

	asr	Xh			;/2
	ror	Xl

	std	Z+2,Xh			;I[i] =
	std	Z+3,Xl

	com	Xl			;-ve
	com	Xh
	subi	Xl,-1
	sbci	Xh,-1

	std	Y+2,Xh			;I[IM] =
	std	Y+3,Xl

	subi	Zl,4			;i - 4
	breq	OD_Final
	rjmp	OD_Lp

OD_Final:
	ldi	r25,0			;for =0

;R[N*3/4] = I[N/4]
;I[N*3/4] = 0
;I[N/4]   = 0
	ldi	Zl,(FFT_Size * 12)/4	;((FFT_Size * 4) * 3)/4
	ldi	Yl,FFT_Size + 2	;(FFT_Size * 4)/4

	ld	Xh,Y			;= I[N/4]
	ldd	Xl,Y+1

	st	Z+,Xh			;R[N*3/4] =
	st	Z+,Xl

	st	Z+,r25			;I[N*3/4] = 0
	st	Z,r25

	st	Y+,r25			;I[N/4]   = 0
	st	Y,r25

;R[ND2] = I[0]
;I[ND2] = 0
;I[0]   = 0
	ldi	Zl,ND2			;R[ND2]
	ldi	Yl,2			;I[0]

	ld	Xh,Y			;= I[0]
	ldd	Xl,Y+1

	st	Z+,Xh			;R[ND2] =
	st	Z+,Xl

	st	Z+,r25			;I[ND2] = 0
	st	Z,r25

	st	Y+,r25			;I[0]   = 0
	st	Y,r25

	ret
;
;*****************************************
;
;  Maths
;
;*****************************************
;
Sqrt:			;PIC/Normal Hybrid Sqroot N32 to N16 V3 (IXIBA Ver 18/9/2013)
			;From PIC App Note TB040, Wikipedia
			;In: r15:r14:r13:r12
			;Out: r13:r12

	push	r0			;mul
	push	r1

	push	r24			;L Squared Result
	push	r25
	push	Xl
	push	Xh			;H

	push	Yl			;Result
	push	Yh

	push	Zl			;Rotating Bit
	push	Zh

	push	temp

	clr	temp			;0 for additions

	clr	Yl			;Build Result
	clr	Yh

;Split Pre_Guess into bytes Upper to Lower
;If upper byte != to 0 then guess in upper byte only
;Else try nextlower
	ldi	Xh,0x40		;Rotating test bit

	tst	r15			;Is 1st byte = 0
	brne	Sqr_G1
	tst	r14
	brne	Sqr_G2
	tst	r13
	brne	Sqr_G3

Sqr_G4:				;Lowest byte test
	clr	Zh
	ldi	Zl,0x08		;Zh:Zl = 0x0008, Rotating bit
Sqr_G4lp:
	cp	r12,Xh			;Is (Rotest<=Num_InB1)
	brsh	Sqr_Lp

	lsr	Xh			;Rotest >> 2
	lsr	Xh
	lsr	Zl			;Rotating Bit >> 1
	brcc	Sqr_G4lp
	rjmp	Sqr_Done
;
Sqr_G3:				;Byte 2 test
	clr	Zh
	ldi	Zl,0x80		;Zh:Zl = 0x0080, Rotating bit
Sqr_G3lp:
	cp	r13,Xh			;Is (Rotest<=Num_InB2)
	brsh	Sqr_Lp

	lsr	Xh			;Rotest >> 2
	lsr	Xh
	lsr	Zl			;Rotating Bit >> 1
	rjmp	Sqr_G3lp
;
Sqr_G2:				;Byte 3 test
	ldi	Zh,0x08
	clr	Zl			;Zh:Zl = 0x0800, Rotating bit
Sqr_G2lp:
	cp	r14,Xh			;Is (Rotest<=Num_InB3)
	brsh	Sqr_Lp

	lsr	Xh			;Rotest >> 2
	lsr	Xh
	lsr	Zh			;Rotating Bit >> 1
	rjmp	Sqr_G2lp
;
Sqr_G1:				;Byte 3 test
	ldi	Zh,0x80
	clr	Zl			;Zh:Zl = 0x8000, Rotating bit
Sqr_G1lp:
	cp	r15,Xh			;Is (Rotest<=Num_InB4)
	brsh	Sqr_Lp

	lsr	Xh			;Rotest >> 2
	lsr	Xh
	lsr	Zh			;Rotating Bit >> 1
	rjmp	Sqr_G1lp
;
Sqr_Lp:
	or	Yh,Zh			;Result |= Rotbit
	or	Yl,Zl

;Squar Result Yh:Yl * Yh:Yl = Xh:Xl:r25:r24

	mul	Yh,Yh			;ah * bh > Xh:Xl
	movw	Xh:Xl,r1:r0

	mul	Yl,Yl			;al * bl > r25:r24
	movw	r25:r24,r1:r0

	mul	Yh,Yl			;Will do as ah * bl & al * bh

	add	r25,r0		
	adc	Xl,r1
	adc	Xh,temp

	add	r25,r0
	adc	Xl,r1
	adc	Xh,temp

	cp	r12,r24
	cpc	r13,r25
	cpc	r14,Xl
	cpc	r15,Xh
	brsh	Sqr32_KeepBit

	eor	Yl,Zl			;Remove Bit
	eor	Yh,Zh


Sqr32_KeepBit:
	lsr	Zh
	ror	Zl
	brcc	Sqr_Lp

Sqr_Done:
	movw	r13:r12,Yh:Yl		;Transfer Result

	pop	temp
	pop	Zh
	pop	Zl
	pop	Yh
	pop	Yl
	pop	Xh
	pop	Xl
	pop	r25
	pop	r24
	pop	r1
	pop	r0
	ret

;
;*****************************************
;
;  Oled Stuff
;
;*****************************************
;
/*
Set_Active_Display:			;Set righthand edge (Column) of active region (lefthand will be 0 column)
					;In:
					;Out: OLED
	push	temp

	ldi	temp,0x21		;Set Active width of Disply
	rcall	OLED_cnt
	ldi	temp,0x00		;Left Column
	rcall	OLED_cnt
	ldi	temp,OLED_Right_Edge		;Right Column
	rcall	OLED_cnt

	sbi	portd,OLED_SCE	;Chip Enable, Disable
	pop	temp
	ret
*/
;
;
Clear_Display:			;Clear (Fill with 0's) Display, work for full screen Horizontal or Vertical Addresing Mode
					;In:
					;Out: OLED
	push	temp
	push	Xh
	push	Xl

	rcall	OLED_Zero_Pos

	ldi	Xh,high(1024)		;(Frame_Buffer_Size)	;((X_Max+1) * (Y_Max+1))/8
	ldi	Xl,low(1024)		;(Frame_Buffer_Size)

CD_L1:	clr	temp
	rcall	OLED_dat

	sbiw	Xh:Xl,1
	brne	CD_L1

CD_X:	pop	Xl
	pop	Xh
	pop	temp
	ret
;

OLED_Zero_Pos:			;Set Colmum & Page to Zero
					;In:
					;Out: OLED
	push	temp

	ldi	temp,0x10		;X, Set Column counter to 0 (0x0100)
	rcall	OLED_cnt
	ldi	temp,0x00
	rcall	OLED_cnt

	ldi	temp,0xb0		;Y, Page 0
	rcall	OLED_cnt

	sbi	portd,OLED_SCE	;Chip Enable, Disable
	pop	temp
	ret
;
;
Update_Oled_8:				;Update 1/4 of display with FFT results
						;In: FFT_Data_Real (DSEG),Column_Count
						;Out: OLED,Column_Count
	push	Xh
	push	Xl
	push	Yh
	push	Yl
	push	Zh
	push	Loop_Count
	push	temp

;Because of supretion of 0 bar on first block all other block (2,3,4) need to be shifted left one bar (4)
	mov	Zh,Column_Count		;OLED Column = 4 * Column_Count
	lsl	Zh


	clr	Loop_Count

	ldi	Yh,high(FFT_Data_Display)	;+ 2 *	Column_Count
	ldi	Yl,low(FFT_Data_Display)
	add	Yl,Zh
	adc	Yh,Loop_Count

;	add	Zh,Column_Count		;Finish off the 3*
	lsl	Zh				;Finish off the 4*


;Shouldnt be necisary to constanly set Y
	ldi	temp,0xb0			;Y, Page 0
	rcall	OLED_cnt

	ldi	Loop_Count,8			;8 bars

	mov	temp,Column_Count

	cpi	temp,0				;If first 8 then skip 0 (DC) so just 7 bars
	brne	UO_Last8

	adiw	Yh:Yl,2			;Skip first 16
	inc	Column_Count
	dec	Loop_Count			;only 7
	rjmp	UO_lp

UO_Last8:
	cpi	temp,24			;Last 8 so skip last bar, just display 7
	brne	UO_Let_1_Bar
	dec	Loop_Count

UO_Let_1_Bar:
	subi	Zh,4				;to compensate for removal of bar 0

UO_lp:

	ld	Xl,Y+				;Bar Hight
;	lsr	Xl	;reduce level
	ld	Xh,Y				;Peak

	subi	Xh,Peak_Drop			;Drop peak down N per cycle
	brcs	UO_NewPeak			;If peak goes negative just make the same as current hight

	cp	Xl,Xh
	brlo	UO_Drop

UO_NewPeak:
	mov	Xh,Xl				;Set peak to current hight
	cpi	Xh,65
	brlo	UO_Drop
	ldi	Xh,64				;Peak max 64

UO_Drop:
	st	Y+,Xh

;Set OLED colum position (bar 2 wide + gap =3)

	ldi	temp,0x0f
	and	temp,Zh			;X, Set Column, 0000LLLL
	rcall	OLED_cnt

	ldi	temp,0xf0
	and	temp,Zh
	swap	temp
	ori	temp,0x10
	rcall	OLED_cnt			;X, Set Column, 0001HHHH

	subi	Zh,-4				;+ 4 to next position


	rcall	OLED_Put_Bar
;subi	Xl,-2

	inc	Column_Count
	dec	Loop_Count
	brne	UO_lp

UO_X:	sbi	portd,OLED_SCE		;Chip Enable, Disable

	pop	temp
	pop	Loop_Count
	pop	Zh
	pop	Yl
	pop	Yh
	pop	Xl
	pop	Xh
	ret
;
;
OLED_Put_Bar:				;Put one bar onto OLED at current possition
					;In: Xh (Peak), Xl (Length)
					;Out: OLED
	push	Zh
	push	Zl
	push	Yh
	push	Yl
	push	Xh
	push	Xl	
	push	Loop_Count
	push	temp

	ldi	Yh,high(OLED_Line_Buffer)
	ldi	Yl,low(OLED_Line_Buffer)

	ldi	temp,0
	ldi	Loop_Count,(7*8)	;56

	cpi	Xl,Y_Max+1		;Range Check, >=64 then full bar
	brlo	OPB_Blank_lp
	ldi	Xl,0xff
	rjmp	OPB_Full_Bar	

OPB_Blank_lp:
	cp	Xl,Loop_Count
	brsh	OPB_Fill

	st	Y+,temp

	subi	Loop_Count,8
	brne	OPB_Blank_lp


OPB_Fill:				;Start filling with set bits
	sub	Xl,Loop_Count
	ldi	Zh,high(Num_To_Bits<<1)	;Part byte filled
	ldi	Zl,low(Num_To_Bits<<1)
	add	Zl,Xl
	adc	Zh,temp

	lpm	Xl,Z
OPB_Full_Bar:
	st	Y+,Xl
	
	ldi	temp,0xff		;fill remainder with bits
	rjmp	OPB_Fill_Tst
OPB_Fill_lp:
	st	Y+,temp
OPB_Fill_Tst:
	subi	Loop_Count,8
	brcc	OPB_Fill_lp

	subi	Xh,1			;shits 64<>0 to 63<>-1 for simpler proccesing
	brcs	OPB_Send_Bar		;Gone negative so was zero lenth, skip peak

	mov	temp,Xh		;Setup buffer address of peak --AA A---
	lsl	temp			;-AAA ---
	swap	temp			;---- -AAA
	andi	temp,0x07		;0000 0AAA

	inc	temp			;Y should already be pointing 1 past end of buffer (Spillover) so +1 to compensate
	sub	Yl,temp
	sbci	Yh,0

	mov	Loop_Count,Xh		;Rotate peak bits
	
	ldi	Xh,0x80		; rotating bits 0000 0001  1000 0000
	ldi	Xl,0x01

	andi	Loop_Count,0x07	;0000 0nnn
	breq	OPB_NoRot		;Zero rotation so already in correct position
	lsr	Xl			;Only ever need to roatal Xl once  (0x80 <<1)
OPB_PeakRot:
	ror	Xh			;Carry only 1 on first loop
	dec	Loop_Count
	brne	OPB_PeakRot

OPB_NoRot:
	ld	temp,Y			;or rotating bit with Line buffer
	or	temp,Xh
	st	Y+,temp
	ld	temp,Y			;Could be spillover byte if peak 1 high
	or	temp,Xl
	st	Y,temp



OPB_Send_Bar:
	ldi	Yh,high(OLED_Line_Buffer)	;Send pattern to OLED twice at current postion
	ldi	Yl,low(OLED_Line_Buffer)
	ldi	Loop_Count,8
OPB_LineA_lp:
	ld	temp,Y+
	rcall	OLED_dat
	dec	Loop_Count
	brne	OPB_LineA_lp

	ldi	Yh,high(OLED_Line_Buffer)
	ldi	Yl,low(OLED_Line_Buffer)
	ldi	Loop_Count,8
OPB_LineB_lp:
	ld	temp,Y+
	rcall	OLED_dat
	dec	Loop_Count
	brne	OPB_LineB_lp


	pop	temp
	pop	Loop_Count
	pop	Xl
	pop	Xh
	pop	Yl
	pop	Yh
	pop	Zl
	pop	Zh
	ret

;
;
;*****************************************
;
;  OLED Interface
;
;*****************************************
;
/*
OLED_Initialize_SSD1308:		;Inicialize OLED

	push	temp
	cbi	portd,OLED_RES	;Reset
	rcall	Delay15ms
	sbi	portd,OLED_RES
	rcall	Delay15ms

	;Derived from intilization sequence in data sheet
	ldi	temp,0xae		;Display Off (1010 111x)
	rcall	OLED_cnt

	ldi	temp,0xa1		;(Hardware) Segment Remap (1010 000x)
	rcall	OLED_cnt

	ldi	temp,0xda		;(Hardware) Set COM Pins Hardware Config (1101 1010)
	rcall	OLED_cnt
	ldi	temp,0x12		;2nd byte (00xx 0010)
	rcall	OLED_cnt

	ldi	temp,0xc8		;(Harware) Set COM Output Scan Direction
	rcall	OLED_cnt

	ldi	temp,0xa8		;Multiplex Ratio Mode (1010 1000)
	rcall	OLED_cnt
	ldi	temp,0x3f		;2nd byte (--xx xxxx) 63 (Default)
	rcall	OLED_cnt

	ldi	temp,0xd5		;Display Divide Ratio/Osc (1101 0011)
	rcall	OLED_cnt
	ldi	temp,0x80		;2nd Byte (xxxx xxxx) Ratio
	rcall	OLED_cnt

	ldi	temp,0x81		;Contrast Control (1000 0001)
	rcall	OLED_cnt
	ldi	temp,Contrast		;2nd byte (xxxx xxxx)
	rcall	OLED_cnt

	ldi	temp,0xd9		;Set Precharge Period (1101 1001)
	rcall	OLED_cnt
	ldi	temp,0x21		;2nd byte (xxxx xxxx)
	rcall	OLED_cnt

	ldi	temp,0x20		;Memory Addressing Mode (0010 0000)
	rcall	OLED_cnt
	ldi	temp,0x01		;2nd byte (0000 00xx), Vertical Mode
	rcall	OLED_cnt

	ldi	temp,0xdb		;VCOM Deselect Level Mode (1101 1011)
	rcall	OLED_cnt
	ldi	temp,0x30		;2nd byte (0xxx 0000), 0.83v x Vcc
	rcall	OLED_cnt

	ldi	temp,0xad		;I Ref Selection (1010 1101)
	rcall	OLED_cnt
	ldi	temp,0x00		;2nd byte (000x 0000), External
	rcall	OLED_cnt

	ldi	temp,0xa4		;Entire Display On (1010 010x) ???
	rcall	OLED_cnt

	ldi	temp,0xa6		;Set Normal/Inverse (1010 011x), Normal
	rcall	OLED_cnt

	ldi	temp,0xaf		;Display On (101011x)
	rcall	OLED_cnt



	sbi	portd,OLED_SCE	;Chip Enable, Disable

	pop	temp
	ret
*/
;
;
;** The 1.3" OLED mounted upside down
OLED_Initialize_SSD1306:			;Inicialize OLED
	push	temp
	sbi	portd,OLED_12V	;12v (VCC) off

	cbi	portd,OLED_RES	;Reset
	rcall	Delay15ms
	sbi	portd,OLED_RES
	rcall	Delay15ms

	;Derived from intilization sequence in data sheet
	ldi	temp,0xae		;Display Off (1010 111x)
	rcall	OLED_cnt

	ldi	temp,0xd5		;Display Divide Ratio/Osc (1101 0011)
	rcall	OLED_cnt
	ldi	temp,0x80		;2nd Byte (xxxx xxxx) Ratio
	rcall	OLED_cnt

	ldi	temp,0xa8		;Multiplex Ratio Mode (1010 1000)
	rcall	OLED_cnt
	ldi	temp,0x3f		;2nd byte (--xx xxxx) 63 (Default)
	rcall	OLED_cnt

	ldi	temp,0xd3		;Set Display Offset (11010011)
	rcall	OLED_cnt
	ldi	temp,0x00		;2nd byte (--xx xxxx) Defualt 00
	rcall	OLED_cnt

	ldi	temp,0x40		;Set Start Line (01xx xxxx)
	rcall	OLED_cnt

	ldi	temp,0x8d		;Set Charge Pump ?Not In Datasheet?
	rcall	OLED_cnt
	ldi	temp,0x10		;2nd byte ?0x10=off 0x14=On?
	rcall	OLED_cnt

	ldi	temp,0xa0		;(Hardware) Segment Remap (1010 000x) (0xA1=Normal, 0xA0=Flip X)
	rcall	OLED_cnt

	ldi	temp,0xc0		;(Harware) Set COM Output Scan Direction (0xc8=Normal, 0xc0=Flip Y)
	rcall	OLED_cnt

	ldi	temp,0xda		;(Hardware) Set COM Pins Hardware Config (1101 1010)
	rcall	OLED_cnt
	ldi	temp,0x12		;2nd byte (00xx 0010)
	rcall	OLED_cnt

	ldi	temp,0x81		;Contrast Control (1000 0001)
	rcall	OLED_cnt
	ldi	temp,Contrast		;2nd byte (xxxx xxxx)
	rcall	OLED_cnt

	ldi	temp,0xd9		;Set Precharge Period (1101 1001)
	rcall	OLED_cnt
	ldi	temp,0x22		;2nd byte (xxxx xxxx)
	rcall	OLED_cnt

	ldi	temp,0xdb		;VCOM Deselect Level Mode (1101 1011)
	rcall	OLED_cnt
	ldi	temp,0x40		;2nd byte (0xxx 0000) ?0x40 This value not valid in data sheet?
	rcall	OLED_cnt

	ldi	temp,0xa4		;Entire Display On (1010 010x) ???
	rcall	OLED_cnt

	ldi	temp,0xa6		;Set Normal/Inverse (1010 011x), Normal
	rcall	OLED_cnt

	ldi	temp,0x20		;Memory Addressing Mode (0010 0000)
	rcall	OLED_cnt
	ldi	temp,0x01		;2nd byte (0000 00xx),  Vertical Mode
	rcall	OLED_cnt

	cbi	portd,OLED_12V	;12v (VCC) on
	rcall	Delay15ms

	ldi	temp,0xaf		;Display On (101011x)
	rcall	OLED_cnt



	sbi	portd,OLED_SCE	;Chip Enable

	pop	temp
	ret
;
;
OLED_cnt:				;Sent byte to OLED
					;In: temp
					;Out: OLED
	cbi	portd,OLED_Dat_Cnt
	rjmp	OLED_Send
OLED_dat:
	sbi	portd,OLED_Dat_Cnt
OLED_Send:
	push	Loop_Count

	cbi	portd,OLED_SCE	;Be sure Chip enable is active

	ldi	Loop_Count,8		;Do 8 bits first  (MSB first)

OLED_L1:
	lsl	temp			;Transfer bit (C) to port
	brcs	OLED_H
	cbi	portd,OLED_SDIN
	rjmp	OLED_Clock
OLED_H:
	sbi	portd,OLED_SDIN
OLED_Clock:
	cbi	portd,OLED_SCLK
	nop
	nop
	sbi	portd,OLED_SCLK	;Tansfer on rising edge
	dec	Loop_Count
	brne	OLED_L1

OLED_X:
	pop	Loop_Count
	ret
;
;
Delay15ms:
	push	temp
	push	temp1

	ldi	temp1,Del_15ms
Del_L1:clr	temp
Del_L2:dec	temp
	nop
	brne	Del_L2
	dec	temp1
	brne	Del_L1

	pop	temp1
	pop	temp
	ret	
;
;
;*****************************************
;
;  Interupts
;
;*****************************************
;	
ADC_Int:
	sbrs	flags,ADCFillAorB	;Data to A or B buffer
	rjmp	ADC_FillB

	sbrc	flags,Afull		;If A full (Still not proccesed) then exit
	reti

;Buffer A
	push	temp
	in	temp,SREG

	push	Yh
	push	Yl
	push	Xh
	push	Xl
		
	ldi	Yh,high(FFT_Data_IRA)
	lds	Yl,Fill_Offset

	ld	Xl,Y
	sts	Fill_Offset,Xl

	tst	Xl
	brne	AI_AMore

	sbr	flags,1<<Afull		;Block ADC access until processed
	cbr	flags,1<<ADCFillAorB		;Switch to B buffer

AI_AMore:
	lds	Xl,ADCL
	lds	Xh,ADCH
		
	st	Y+,Xh			;R
	st	Y,Xl

AI_AX:	pop	Xl
	pop	Xh
	pop	Yl
	pop	Yh
	out	SREG,temp
	pop	temp
	reti
;
;
ADC_Diag_Toggle:
	sbi	pinb,Diag_Sync		;A diag to show dropped samples (toggle Sync)
	reti
;
;
ADC_FillB:
	sbrc	flags,Bfull			;If A full (Still not proccesed) then exit
;	rjmp	ADC_Diag_Toggle
	reti


;Buffer B
	push	temp
	in	temp,SREG

	push	Yh
	push	Yl
	push	Xh
	push	Xl
		
	ldi	Yh,high(FFT_Data_IRB)
	lds	Yl,Fill_Offset

	ld	Xl,Y
	sts	Fill_Offset,Xl

	tst	Xl
	brne	AI_BMore

	sbr	flags,(1<<Bfull| 1<<ADCFillAorB)		;Block ADC access until processed, Switch to A buffer

AI_BMore:
	lds	Xl,ADCL
	lds	Xh,ADCH
		
	st	Y+,Xh			;R
	st	Y,Xl

AI_BX:	pop	Xl
	pop	Xh
	pop	Yl
	pop	Yh
	out	SREG,temp
	pop	temp
	reti
	
		
end:

	.org	(end & 0xff00) + 0x100
tables:

//48 (3/4) of a 64 sample sinewave
SineWave64: 	.dw	      0,   1606,   3196,   4756,   6270,   7723,   9102,  10394	;Must be 0x100 boundery
		.dw	  11585,  12665,  13622,  14449,  15136,  15678,  16069,  16305
		.dw	  16384,  16305,  16069,  15678,  15136,  14449,  13622,  12665
		.dw	  11585,  10394,   9102,   7723,   6270,   4756,   3196,   1606
		.dw	      0,  -1606,  -3196,  -4756,  -6270,  -7723,  -9102, -10394
		.dw	 -11585, -12665, -13622, -14449, -15136, -15678, -16069, -16305

Num_To_Bits:	.db	0x00,0x80,0xc0,0xe0,0xf0,0xf8,0xfc,0xfe,0xff,0xff

Bit_Flip_OffsetsOE:

		.db	2, 64,  6, 68, 10, 72, 14, 76, 18, 80, 22, 84, 26, 88, 30, 92
		.db   34, 96, 38,100, 42,104, 46,108, 50,112, 54,116, 58,120, 62,124
		.db   66, 32, 70, 36, 74, 40, 78, 44, 82, 48, 86, 52, 90, 56, 94, 60
		.db   98, 16,102, 20,106, 24,110, 28,114,  8,118, 12,122,  4,126,  0


.DSEG

FFT_Data_IRA:			;Buffer A
	.byte	FFT_Size*4	;Must be alighned to 0x100 boundry
				;N16S:N16S

FFT_Data_IRB:			;Buffer B
	.byte	FFT_Size*4	;N16S:N16S

FFT_Data_Real_AV:		;Averaging buffer for real samples
	.byte FFT_Size	;RI to R, N16 (First 16 and last 16 wont be used)

FFT_Data_Display:		;Data ready for display
	.byte FFT_Size	;Value:Peak, 16bit per sample  

OLED_Line_Buffer:		;Buffer of one column, 8 bytes
	.byte 8+1		;+ 1 to make things simpler for peak by allowin a spillover

Fill_Offset:			;pointer to next ADC store pos in FFT_Data
	.byte	1

OE_FFT_Size:			;OE FFT runs same fft with diferent FFT_Size's
	.byte	1


