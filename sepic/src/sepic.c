#include <avr/io.h>
#include <avr/interrupt.h>
#include <inttypes.h>
#include <avr/sleep.h>


#define F_MAX	127

//----------------------------------------------------------------
// Fast PWM on OC1A/PB1
void initPWM(void)
{
	TCCR1	=	(1<<CTC1)	|
				(1<<PWM1A)	|
				(1<<COM1A1)	|		// enable OC1A
				(0<<COM1A0)	|
				(0<<CS13)	|		// clk/1
				(0<<CS12)	|
				(0<<CS11)	|
				(1<<CS10);

	GTCCR	|=	(0<<PWM1B)	|
				(0<<COM1B1)	|
				(0<<COM1B0)	|
				(0<<FOC1B)	|
				(0<<FOC1A)	|
				(0<<PSR1);

	PLLCSR	=	(0<<LSM)	|
				(1<<PCKE)	|		// use 64MHz PLL click for clock source :)
				(1<<PLLE)	|
				(0<<PLOCK);

	OCR1C	=	F_MAX-1;
	OCR1A	=	1;

	DDRB	|=	(1<<PB1);			// enable OC1A I/O
}


//----------------------------------------------------------------
// Setup ADC to read trimpot on ADC2/PB4
void initADC(void)
{
	ADMUX	=	(0<<REFS1)	|	// Vcc is AREF
				(0<<REFS0)	|
				(1<<ADLAR)	|	// Left adjust so we can read ADCH only
				(0<<REFS2)	|
				(0<<MUX3)	|	// MUX3:0 = 0010 => ADC2 (PB4)
				(0<<MUX2)	|
				(1<<MUX1)	|	
				(0<<MUX0);

	ADCSRA	=	(1<<ADEN)	|	// Enable ADC
				(0<<ADSC)	|
				(0<<ADATE)	|
				(1<<ADIF)	|
				(1<<ADIE)	|
				(1<<ADPS2)	|	// Max prescaler for fast CPU clock
				(1<<ADPS1)	|
				(1<<ADPS0);

	ADCSRB	=	(0<<BIN)	|
				(0<<IPR)	|
				(0<<ADTS2)	|
				(0<<ADTS1)	|
				(0<<ADTS0);

	DIDR0	=	(1<<ADC2D);

	DDRB	&=	~(1<<PB4);

	//sleep_enable();
	//set_sleep_mode(SLEEP_MODE_ADC);
}


//----------------------------------------------------------------
// 
void init(void)
{
	initPWM();

	initADC();

	sei();
}


//----------------------------------------------------------------
// 
int main(void)
{
	init();

	while(1)
	{
		// wait for conversion to complete before triggering another one
		if ((ADCSRA & (1<<ADSC)) == 0)
			ADCSRA |= (1<<ADSC);

		//sleep_cpu();
	}

	return 0;
}


//----------------------------------------------------------------
// ADC interrupt complete handler
const float		SCALE	= (float)(F_MAX/255.0);
const uint8_t	MAX		= (uint8_t)(F_MAX * 0.90);
ISR(ADC_vect)
{
	uint8_t sample	= ADCH;

	uint8_t result = (uint8_t) (sample * SCALE);

	// set bounds
	if (result > MAX)
		result = MAX;
	if (result < 1)
		result = 1;

	// take ADC reading and set PWM output to that value
	OCR1A = result;
}
