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

	OCR0A	=	0xFF;
	OCR0B	=	0xFF;

//---------------------------------------------------------------------------------
Timer1 Settings:

	TCCR1A	=	(0<<COM1A1)	|
				(0<<COM1A0)	|
				(0<<COM1B1)	|
				(0<<COM1B0)	|
				(0<<WGM11)	|
				(0<<WGM10);

	TCCR1B	=	(0<<ICNC1)	|
				(0<<ICES1)	|
				(0<<WGM13)	|
				(0<<WGM12)	|
				(0<<CS12)	|
				(0<<CS11)	|
				(0<<CS10);

	TCCR1C	=	(0<<FOC1A)	|
				(0<<FOC1B);


	TIMSK1	=	(0<<ICIE1)	|
				(0<<OCIE1B)	|
				(0<<OCIE1A)	|
				(0<<TOIE1);

	OCR1A	=	0xffff;
	OCR1B	=	0xffff;


//---------------------------------------------------------------------------------
Timer2 Settings:

	TCCR2A	=	(0<<COM2A1)	|
				(0<<COM2A0)	|
				(0<<COM2B1)	|
				(0<<COM2B0)	|
				(0<<WGM21)	|
				(0<<WGM20);

	TCCR2B	=	(0<<FOC2A)	|
				(0<<FOC2B)	|
				(0<<WGM22)	|
				(0<<CS22)	|
				(0<<CS21)	|
				(0<<CS20);

	TIMSK2	=	(0<<OCIE2B)	|
				(0<<OCIE2A)	|
				(0<<TOIE2);

	OCR2A	=	0xFF;
	OCR2B	=	0xFF;