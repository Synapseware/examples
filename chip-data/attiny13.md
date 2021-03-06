//---------------------------------------------------------------------------------
Timer0 Settings:

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

	TIMSK0	=	(0<<OCIE0B)	|
				(0<<OCIE0A)	|
				(0<<TOIE0);


//---------------------------------------------------------------------------------
Analog->Digital Converter:

	ADMUX	=	(0<<REFS0)	|
				(0<<ADLAR)	|
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

	ADCSRB	=	(0<<ADTS2)	|
				(0<<ADTS1)	|
				(0<<ADTS0);

	DIDR0	=	(0<<ADC2D);

	DDRB	&=	~(1<<PB4);


//---------------------------------------------------------------------------------
void WDT_off(void)
{
	cli();
	wdt_reset();
	MCUSR &= ~(1<<WDRF);
	WDTCR |= (1<<WDCE) | (1<<WDE);
	WDTCR = 0x00;
	sei();
}

//------------------------------------------------------------------------------------------
// Enable WDT for periodic sleep wakeup at 500ms intervals
void WDT_sleepWakupMode(void)
{
	cli();
	wdt_reset();
	WDTCR |= (1<<WDCE) | (1<<WDE);
	WDTCR = (1<<WDTIE) | (0<<WDP3) | (1<<WDP2) | (0<<WDP1) | (1<<WDP0);
	sei();
}


//------------------------------------------------------------------------------------------
// Enable WDT for system reset mode at 500ms intervals
void WDT_systemResetMode(void)
{
	cli();
	wdt_reset();
	WDTCR |= (1<<WDCE) | (1<<WDE);
	WDTCR = (1<<WDE) | (0<<WDP3) | (1<<WDP2) | (0<<WDP1) | (1<<WDP0);
	sei();
}
