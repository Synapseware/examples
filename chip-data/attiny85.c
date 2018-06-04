//---------------------------------------------------------------------------------
// Universal Serial Interface (USI):
function initUSI(void)
{
	USICR	=	(0<<USISIE) |
				(0<<USIOIE) |
				(0<<USIWM1) |
				(0<<USIWM0) |
				(0<<USICS1) |
				(0<<USICS0) |
				(0<<USICLK) |
				(0<<USITC);
}


//---------------------------------------------------------------------------------
// Timer0:
function initTimer0(void)
{
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
}


//---------------------------------------------------------------------------------
//Timer1:
function initTimer1(void)
{
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
}


//---------------------------------------------------------------------------------
// Analog->Digital Converter:
function initADC(void)
{
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
}


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


//-----------------------------------------------------------------------------
// Selects the specified ADC channel
void SelectADCChannel(uint8_t channel)
{
	switch (channel)
	{
		case 0x00:
			// Channel 0
			ADMUX = (ADMUX & 0xF0) | (0<<MUX3) | (0<MUX2) | (0<<MUX1) | (0<<MUX0);
			DIDR0 = (1<<ADC0D);
			DDRB &= ~(1<<PB5);
			break;
		case 0x01:
			// Channel 1
			ADMUX = (ADMUX & 0xF0) | (0<<MUX3) | (0<MUX2) | (0<<MUX1) | (1<<MUX0);
			DIDR0 = (1<<ADC1D);
			DDRB &= ~(1<<PB2);
			break;
		case 0x02:
			// Channel 2
			ADMUX = (ADMUX & 0xF0) | (0<<MUX3) | (0<MUX2) | (1<<MUX1) | (0<<MUX0);
			DIDR0 = (1<<ADC2D);
			DDRB &= ~(1<<PB4);
			break;
		case 0x03:
			// Channel 3
			ADMUX = (ADMUX & 0xF0) | (0<<MUX3) | (0<MUX2) | (1<<MUX1) | (1<<MUX0);
			DIDR0 = (1<<ADC3D);
			DDRB &= ~(1<<PB3);
			break;
		case 0x0C:
			// Band-gap voltage
			ADMUX = (ADMUX & 0xF0) | (1<<MUX3) | (1<MUX2) | (0<<MUX1) | (0<<MUX0);
			break;
		case 0x0D:
			// Ground
			ADMUX = (ADMUX & 0xF0) | (1<<MUX3) | (1<MUX2) | (0<<MUX1) | (1<<MUX0);
			break;
		case 0x0F:
			// Internal temperature sensor
			ADMUX = (ADMUX & 0xF0) | (1<<MUX3) | (1<MUX2) | (1<<MUX1) | (1<<MUX0);
			break;
	}
}




//-----------------------------------------------------------------------------
// ADC values
// ADMUX
#define ADC_VREF_VCC	0
#define ADC_VREF_EXT	((0<<REFS2) | (0<<REFS1) | (1<<REFS0))
#define ADC_VREF_INT11	((0<<REFS2) | (1<<REFS1) | (0<<REFS0))
#define ADC_VREF_256	((1<<REFS2) | (1<<REFS1) | (0<<REFS0))
#define ADC_VREF_256BP	((1<<REFS2) | (1<<REFS1) | (1<<REFS0))
#define ADC_CHANNEL_0	((0<<MUX3) | (0<MUX2) | (0<<MUX1) | (0<<MUX0))
#define ADC_CHANNEL_1	((0<<MUX3) | (0<MUX2) | (0<<MUX1) | (1<<MUX0))
#define ADC_CHANNEL_2	((0<<MUX3) | (0<MUX2) | (1<<MUX1) | (0<<MUX0))
#define ADC_CHANNEL_3	((0<<MUX3) | (0<MUX2) | (1<<MUX1) | (1<<MUX0))
#define ADC_CHANNEL_BGP	((1<<MUX3) | (1<MUX2) | (0<<MUX1) | (0<<MUX0))
#define ADC_CHANNEL_GND	((1<<MUX3) | (1<MUX2) | (0<<MUX1) | (1<<MUX0))
#define ADC_CHANNEL_TMP	((1<<MUX3) | (1<MUX2) | (1<<MUX1) | (1<<MUX0))

#define ADC_CLK_1		((0<<ADPS2) | (0<<ADPS1) | (0<<ADPS0))
#define ADC_CLK_2		((0<<ADPS2) | (0<<ADPS1) | (1<<ADPS0))
#define ADC_CLK_4		((0<<ADPS2) | (1<<ADPS1) | (0<<ADPS0))
#define ADC_CLK_8		((0<<ADPS2) | (1<<ADPS1) | (1<<ADPS0))
#define ADC_CLK_16		((1<<ADPS2) | (0<<ADPS1) | (0<<ADPS0))
#define ADC_CLK_32		((1<<ADPS2) | (0<<ADPS1) | (1<<ADPS0))
#define ADC_CLK_64		((1<<ADPS2) | (1<<ADPS1) | (0<<ADPS0))
#define ADC_CLK_128		((1<<ADPS2) | (1<<ADPS1) | (1<<ADPS0))

// ADCSRA
#define ADC_ENABLE		(1<<ADEN)
#define ADC_NO_INTS		0
#define ADC_INT_EN		(1<<ADIE)
#define ADC_AUTOTRG		(1<<ADATE)

// ADCSRB
#define ADC_TRG_FREE	((0<<ADTS2) | (0<<ADTS1) | (0<<ADTS0))
#define ADC_TRG_COMP	((0<<ADTS2) | (0<<ADTS1) | (1<<ADTS0))
#define ADC_TRG_EI0		((0<<ADTS2) | (1<<ADTS1) | (0<<ADTS0))
#define ADC_TRG_TC0A	((0<<ADTS2) | (1<<ADTS1) | (1<<ADTS0))
#define ADC_TRG_TC0F	((1<<ADTS2) | (0<<ADTS1) | (0<<ADTS0))
#define ADC_TRG_TC0B	((1<<ADTS2) | (0<<ADTS1) | (1<<ADTS0))
#define ADC_TRG_PCIR	((1<<ADTS2) | (1<<ADTS1) | (0<<ADTS0))
#define ADC_LEFTADJ		((1<<ADLAR))
#define ADC_RIGHTADJ	0


//-----------------------------------------------------------------------------
// USI Interrupts
#define USI_NO_INTS		0
#define USI_START_IE	(1<<USISIE)
#define USI_CNT_OVF_IE	(1<<USIOIE)

// USI Mode
#define USI_DISABLED	0
#define USI_THREE_WIRE	((0<<USIWM1) | (1<<USIWM0))
#define USI_TWO_WIRE	((1<<USIWM1) | (0<<USIWM0))
#define USI_TWO_ALT		((1<<USIWM1) | (1<<USIWM0))

// USI clock is bits 3:2:1
#define USI_CLK_OFF		0
#define USI_CLK_SOFT	((0<<USICS1) | (0<<USICS0) | (1<<USICLK))
#define USI_CLK_TC0		((0<<USICS1) | (1<<USICS0) | (0<<USICLK))
#define USI_CLK_EXT_PE	((1<<USICS1) | (0<<USICS0) | (0<<USICLK))
#define USI_CLK_EXT_NE	((1<<USICS1) | (1<<USICS0) | (0<<USICLK))
#define USI_CLK_SOFT_PE	((1<<USICS1) | (0<<USICS0) | (1<<USICLK))
#define USI_CLK_SOFT_NE	((1<<USICS1) | (1<<USICS0) | (1<<USICLK))
