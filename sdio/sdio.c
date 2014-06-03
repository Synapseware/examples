/*
 * sdio.c
 *
 * Created: 9/2/2012 6:55:13 PM
 *  Author: Matthew
 */ 

#include "sdio.h"


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void blinkLed(eventState_t state)
{
	PINB |= (1<<PINB0);
}


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void init(void)
{
	// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	// establish event timer & handler
	// timer1, event timer
	// Set CTC mode (Clear Timer on Compare Match) (p.133)
	// Have to set OCR1A *before anything else*, otherwise it gets reset to 0!
	OCR1A	=	(F_CPU / EVENT_BASE);
	TCCR1A	=	0;
	TCCR1B	=	(1<<WGM12) |	// CTC
				(1<<CS10);
	TIMSK1	=	(1<<OCIE1A);

	setTimeBase(EVENT_BASE);

	// setup timer0 for PWM audio output :)
	TCCR0A	=	(1<<COM0A1) |	// set OC0A on BOTTOM, clear on MATCH
				(0<<COM0A0) |
				(0<<COM0B1) |
				(0<<COM0B0) |
				(1<<WGM01) |	// fast PWM
				(1<<WGM00);

	TCCR0B	=	(0<<FOC0A) |
				(0<<FOC0B) |
				(0<<WGM02) |
				(0<<CS02) |		// no prescaling of timer (run @ fCPU)
				(0<<CS01) |
				(1<<CS01);

	TCNT0	= 0;
	OCR0A	= 0;
	OCR0B	= 0;

	TIMSK0	=	(0<<OCIE0B) |	// no interrupt handling needed
				(0<<OCIE0A) |
				(0<<TOIE0);

	DDRD	|=	(1<<PORTD6);

	// setup LED output pin
	DDRB |= (1<<PB0);

	sei();
}


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
int main(void)
{
	init();

	registerEvent(blinkLed, EVENT_BASE / 2, 0);

    while(1)
    {
		eventsDoEvents();
    }
}


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  - -
// times the events
ISR(TIMER1_COMPA_vect)
{
	eventSync();
}
