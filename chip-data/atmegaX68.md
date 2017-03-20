//---------------------------------------------------------------------------
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

//---------------------------------------------------------------------------
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


//---------------------------------------------------------------------------
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


//---------------------------------------------------------------------------
ADC Settings:

	ADMUX	=	(0<<REFS1)	|	// 
				(0<<REFS0)	|	// 
				(0<<ADLAR)	|	// 
				(0<<MUX3)	|	// 
				(0<<MUX2)	|	// 
				(0<<MUX1)	|	// 
				(0<<MUX0);		// 

	ADCSRA	=	(0<<ADEN)	|	// Bit 7 – ADEN: ADC Enable
				(0<<ADSC)	|	// Bit 6 – ADSC: ADC Start Conversion
				(0<<ADATE)	|	// Bit 5 – ADATE: ADC Auto Trigger Enable
				(0<<ADIF)	|	// Bit 4 – ADIF: ADC Interrupt Flag
				(0<<ADIE)	|	// Bit 3 – ADIE: ADC Interrupt Enable
				(0<<ADPS2)	|	// Bit 2 – ADPS2: ADC Prescaler Select Bit
				(0<<ADPS1)	|	// Bit 1 – ADPS1: ADC Prescaler Select Bit
				(0<<ADPS0);		// Bit 0 – ADPS0: ADC Prescaler Select Bit

	ADCL and ADCH – The ADC Data Register

	ADCSRB	=	(0<<ACME)	|	// 
				(0<<ADTS2)	|	// 
				(0<<ADTS1)	|	// 
				(0<<ADTS0);		// 

	DIDR0	=	(0<<ADC5D)	|	// 
				(0<<ADC4D)	|	// 
				(0<<ADC3D)	|	// 
				(0<<ADC2D)	|	// 
				(0<<ADC1D)	|	// 
				(0<<ADC0D);		// 


//---------------------------------------------------------------------------
Analog Comparator

	// Bit 6 – ACME: Analog Comparator Multiplexer Enable
	ADCSRB	=	(0<<ACME);

	ACSR	=	(0<<ACD)	|	// Bit 7 – ACD: Comparator Disable
				(0<<ACBG)	|	// Bit 6 – ACBG: Bandgap Select
				(0<<ACO)	|	// Bit 5 – ACO: Comparator Output
				(0<<ACI)	|	// Bit 4 – ACI: Interrupt Flag
				(0<<ACIE)	|	// Bit 3 – ACIE: Interrupt Enable
				(0<<ACIC)	|	// Bit 2 – ACIC: Input Capture Enable
				(0<<ACIS1)	|	// Bit 1 – ACIS1: Interrupt Mode Select
				(0<<ACIS0);		// Bit 0 – ACIS0: Interrupt Mode Select

	DIDR1	=	(0<<AIN1D)	|	// Bit 1 – AIN1D: AIN1 Digital Input Disable
				(0<<AIN0D);		// Bit 0 – AIN0D: AIN0 Digital Input Disable


//---------------------------------------------------------------------------
SPI Settings:

	SPCR	=	(0<<SPIE)	|	// Bit 7 – SPIE: SPI Interrupt Enable
				(0<<SPE)	|	// Bit 6 – SPE: SPI Enable
				(0<<DORD)	|	// Bit 5 – DORD: Data Order
				(0<<MSTR)	|	// Bit 4 – MSTR: Master/Slave Select
				(0<<CPOL)	|	// Bit 3 – CPOL: Clock Polarity
				(0<<CPHA)	|	// Bit 2 – CPHA: Clock Phase
				(0<<SPR1)	|	// Bits 1, 0 – SPR1: SPI Clock Rate
				(0<<SPR0);		// Bits 1, 0 – SPR0: SPI Clock Rate

	SPSR	=	(0<<SPIF)	|	// Bit 7 – SPIF: SPI Interrupt Flag
				(0<<WCOL)	|	// Bit 6 – WCOL: Write COLlision Flag
				(0<<SPI2X);		// Bit 0 – SPI2X: Double SPI Speed Bit

	SPDR – SPI Data Register


//----------------------------------------------------------------
UART Settings:

	UCSR0A	=	(0<<U2X0)	|	// No double speed
				(0<<MPCM0);		// No multi-proc mode

	UCSR0B	=	(0<<RXCIE0)	|	// RX Complete Interrupt Enable
				(0<<TXCIE0)	|	// TX Complete Interrupt Enable
				(0<<UDRIE0)	|	// USART Data Register Empty Interrupt Enable
				(0<<RXEN0)	|	// Receiver Enable
				(0<<TXEN0)	|	// Transmitter Enable
				(0<<UCSZ02)	|	// Character Size
				(0<<RXB80)	|	// Receive Data Bit 8
				(0<<TXB80);		// Transmit Data Bit 8

	UCSR0C	=	(0<<UMSEL01)|	// USART Mode Select
				(0<<UMSEL00)|	// ...
				(0<<UPM01)	|	// Parity Mode
				(0<<UPM00)	|	// ...
				(0<<USBS0)	|	// Stop Bit Select
				(0<<UCSZ01)	|	// Character Size
				(0<<UCSZ00)	|	// ..
				(0<<UCPOL0);	// Clock Polarity

//----------------------------------------------------------------
// Gets the MUX configuration bits for the specified channel
static void ConfigureADCChannel(uint8_t channel)
{
	channel		&=	0x0F;
	uint8_t mux =	(ADMUX & 0xF0) |	// mask out the channel bits
					(channel);			// set the channel

	if (channel < 8)
	{
		// disable digital input on the selected channel
		DIDR0 = (1<<channel);

		// set the pin as input
		DDRC &= ~(1<<channel);
	}
	else if (0x08 == channel) // 8
	{
		// internal temperature sensor
	}
	else if (0x0E == channel) // 14
	{
		// internal 1.1v band gap reference
	}
	else if (0x0F == channel) // 15
	{
		// ground
	}
	else
	{
		// invalid channel selection
		return;
	}

	// set the MUX register
	ADMUX = mux;
}

