//---------------------------------------------------------------------------------
Universal Serial Interface (USI):
	USICR	=	(0<<USISIE) |
				(0<<USIOIE) |
				(0<<USIWM1) |
				(0<<USIWM0) |
				(0<<USICS1) |
				(0<<USICS0) |
				(0<<USICLK) |
				(0<<USITC);

//---------------------------------------------------------------------------------
Timer0:
	GTCCR	=	(0<<TSM)	|
				(0<<PSR0);

	TCCR0A	=	(0<<COM0A1)	|
				(0<<COM0A0)	|
				(0<<COM0B1)	|
				(0<<COM0B0)	|
				(0<<WGM01)	|
				(0<<WGM00);

	TCCR0B	=	(0<<FOC0A)	|
				(0<<FOC0B)	|
				(0<<WGM02)	|
				(0<<CS02)	|
				(0<<CS01)	|
				(0<<CS00);

	TIMSK	=	(0<<OCIE0A)	|
				(0<<OCIE0B)	|
				(0<<TOIE0);


//---------------------------------------------------------------------------------
Timer1:

	TCCR1	=	(0<<CTC1)	|
				(0<<PWM1A)	|
				(0<<COM1A1)	|
				(0<<COM1A0)	|
				(0<<CS13)	|
				(0<<CS12)	|
				(0<<CS11)	|
				(0<<CS10);

	GTCCR	|=	(0<<PWM1B)	|
				(0<<COM1B1)	|
				(0<<COM1B0)	|
				(0<<FOC1B)	|
				(0<<FOC1A)	|
				(0<<PSR1);

	TIMSK	=	(0<<OCIE1A)	|
				(0<<OCIE1B)	|
				(0<<TOIE1);

	PLLCSR	=	(0<<LSM)	|
				(0<<PCKE)	|
				(0<<PLLE)	|
				(0<<PLOCK);



//---------------------------------------------------------------------------------
Analog->Digital Converter:

	ADMUX	=	(0<<REFS1)	|
				(0<<REFS0)	|
				(0<<ADLAR)	|
				(0<<REFS2)	|
				(0<<MUX3)	|
				(0<<MUX2)	|
				(0<<MUX1)	|
				(0<<MUX0);

	ADCSRA	=	(0<<ADEN)	|
				(0<<ADSC)	|
				(0<<ADATE)	|
				(0<<ADIF)	|
				(0<<ADIE)	|
				(0<<ADPS2)	|
				(0<<ADPS1)	|
				(0<<ADPS0);

	ADCSRB	=	(0<<BIN)	|
				(0<<IPR)	|
				(0<<ADTS2)	|
				(0<<ADTS1)	|
				(0<<ADTS0);

	DIDR0	=	(1<<PB1);


//---------------------------------------------------------------------------------
// Timer1 - PWM Output on OC1A
void initTimer1PWMA(void)
{
	// Setup PLLCSR - note: PLL is enabled via fuses because we are driving uC clock from the PLL! (pg 97)
	PLLCSR	=	(0<<LSM)	|		// disable low-speed mode (assuming two 1.2NiMh batteries)
				(1<<PCKE);			// enable high speed PLL clock

	// setup timer1, 500kHz, PWM, OCR1A
	GTCCR	=	(0<<PWM1B)	|		// disable PWM, channel B
				(0<<TSM)	|		// disable counter/timer sync mode
				(1<<COM1A1);		// we want to toggle OC1B with our PWM signal

	TCCR1	=	(0<<CTC1)	|
				(1<<COM1A1)	|
				(0<<COM1A0)	|
				(1<<PWM1A)	|		// enable PWM, channel A
				(0<<CS13)	|		// PCK/1
				(0<<CS12)	|		// 
				(0<<CS11)	|		// 
				(1<<CS10);			// 

	OCR1C	=	127;				// 500KHz (64MHz / 128 = 500KHz)
	OCR1A	=	63;					// default duty cycle
	OCR1B	=	0;					// could also setup PWM on channel B with alternate duty cycle (stereo sound output?)

	DDRB	|=	(1<<PWM_OUTPUT);	// set as output
	PORTB	&=	~(1<<PWM_OUTPUT);	// start PWM low
}
