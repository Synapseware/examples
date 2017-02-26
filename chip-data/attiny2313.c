
/*--------------------------------------------------------------
Timer/Counter 0 (8bit)
*/

	/* Timer/Counter Control Register A - TCCR0A */
	TCCR0A	=	(0<<COM0A1)	|
				(0<<COM0A0)	|
				(0<<COM0B1)	|
				(0<<COM0B0)	|
				(0<<WGM01)	|
				(0<<WGM00);

	/* Timer/Counter Control Register B - TCCR0B */
	TCCR0B	=	(0<<FOC0A)	|
				(0<<FOC0B)	|
				(0<<WGM02)	|
				(0<<CS02)	|
				(0<<CS01)	|
				(0<<CS00);

	/* Timer/Counter 0 Interrupt Mask Register - TIMSK */
	TIMSK	=	(TOIE1 OCIE1A OCIE1B – ICIE1 OCIE0B TOIE0 OCIE0A)

	/* Timer/Counter 0 Interrupt Flag Register - TIFR */
	TIFR    = 0;

	/* Timer/Counter Register 0 - TCNT0 */
	TCNT0	= 0;

	/* Output Compare Register A */
	OCR0A   = 0;

	/* Output Compare Register A */
	OCR0B   = 0;

/*--------------------------------------------------------------
Timer/Counter 1 (16bit)
*/

	/* Control Register A - TCCR1A */
	TCCR1A	=	(0<<COM1A1)	|
				(0<<COM1A0)	|
				(0<<COM1B1)	|
				(0<<COM1B0)	|
				(0<<WGM11)	|
				(0<<WGM10);

	/* Timer/Counter1 Control Register B – TCCR1B */
	TCCR1B	=	(0<<ICNC1)	|
				(0<<ICES1)	|
				(0<<WGM13)	|
				(0<<WGM12)	|
				(0<<CS12)	|
				(0<<CS11)	|
				(0<<CS10);

	/* Timer/Counter1 Control Register C – TCCR1C */
	TCCR1C	=	(0<<FOC1A)	|
				(0<<FOC1B);

	/* Timer/Counter1 – TCNT1H and TCNT1L, or TCNT1 */
	TCNT1H	= 0;
	TCNT1L	= 0;
	TCNT1	= 0;	// 16bit access

	/* Output Compare Register 1 A – OCR1AH and OCR1AL */
	OCR1AH	= 0;
	OCR1AL	= 0;
	OCR1A	= 0;	// 16bit access

	/* Output Compare Register 1 B - OCR1BH and OCR1BL */
	OCR1BH	= 0;
	OCR1BL	= 0;
	OCR1B	= 0;	// 16bit access

	/* Input Capture Register 1 – ICR1H and ICR1L */
	ICR1H	= 0;
	ICR1L	= 0;
	ICR1	= 0;	// 16bit access

	/* Timer/Counter Interrupt Mask Register – TIMSK */
	TIMSK	|=	(0<<TOIE1)	|
				(0<<OCIE1A)	|
				(0<<OCIE1B)	|
				(0<<ICIE1);

	/* Timer/Counter Interrupt Flag Register – TIFR */
	TIFR	|=	(0<<TOV1)	|
				(0<<OCF1A)	|
				(0<<OCF1B)	|
				(0<<ICF1);


