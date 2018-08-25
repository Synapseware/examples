#include "example.h"


void SetupLedTimer(void)
{
	// Configure TCA0, which will be used for the LED timer
	// 16Mhz / 1024 = 15625Hz
	TCA0.SINGLE.CTRLA = TCA_SINGLE_CLKSEL_DIV1024_gc;
	TCA0.SINGLE.CTRLB = TCA_SINGLE_WGMODE_NORMAL_gc | TCA_SINGLE_CMP0EN_bm;
	TCA0.SINGLE.CTRLC = 0;
	TCA0.SINGLE.CTRLD = 0;
	TCA0.SINGLE.PER = F_CPU / 1024;

	TCA0.SINGLE.CMP0 = F_CPU / 1024 / 2;
	TCA0.SINGLE.CMP1 = 0;
	TCA0.SINGLE.CMP2 = 0;
	TCA0.SINGLE.INTCTRL = TCA_SINGLE_CMP0_bm;
	/*
						  TCA_SINGLE_OVF_bm |
						  TCA_SINGLE_CMP0_bm |
						  TCA_SINGLE_CMP1_bm |
						  TCA_SINGLE_CMP2_bm;
  	*/

  	// enable the LED pin
  	LED_PORT.DIRSET = LED_PIN;
}


void setup(void)
{
	cli();

	SetupLedTimer();

	sei();
}


int main(void)
{
	setup();

	while(1)
	{
		// main loop
	}

	return 0;
}


ISR(TCA0_CMP0_vect)
{
	// toggle the LED pin
	LED_PORT.OUTTGL = LED_PIN;
}