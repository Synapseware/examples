#include "example.h"



// Configures the CPU
void ConfigureCpu(void)
{
	// default clock speed is either 16Mhz or 20Mhz divided by 6 (unless set otherwise by fuses)
	// Reset the system clock to 16MHz with a division factor of 1
	//

	// Enable the 16/20MHz clock
	XMEGACLK_CCP_Write(&CLKCTRL.MCLKCTRLA, CLKCTRL_CLKSEL_OSC20M_gc);

	// No clock pre-scaler
	XMEGACLK_CCP_Write(&CLKCTRL.MCLKCTRLB, 0);
}


// Configures TCA0
void SetupLedTimer(void)
{
	// Configure TCA0, which will be used for the LED timer
	// 16Mhz / 1024 = 15625Hz
	TCA0.SINGLE.CTRLA = 0;
	TCA0.SINGLE.CTRLB = TCA_SINGLE_WGMODE_NORMAL_gc | TCA_SINGLE_CMP0EN_bm;
	TCA0.SINGLE.CTRLC = 0;
	TCA0.SINGLE.CTRLD = 0;
	TCA0.SINGLE.PER = F_CPU / 1024;

	TCA0.SINGLE.CMP0 = 1000;
	TCA0.SINGLE.CMP1 = 0;
	TCA0.SINGLE.CMP2 = 0;
	TCA0.SINGLE.INTCTRL = TCA_SINGLE_CMP0_bm | TCA_SINGLE_OVF_bm;

  	TCA0.SINGLE.CTRLA = TCA_SINGLE_ENABLE_bm | TCA_SINGLE_CLKSEL_DIV1024_gc;

  	// enable the LED pin
  	LED_PORT.DIRSET = LED_PIN;
  	LED_PORT.OUTCLR = LED_PIN;
}


void setup(void)
{
	cli();

	ConfigureCpu();
	SetupLedTimer();

	sei();
}


int main(void)
{
	setup();

	// Main program loop
	while(1)
	{
		// no-op
	}

	return 0;
}


// TCA0 Compare 0 Interrupt Handler
ISR(TCA0_CMP0_vect)
{
	// toggle the LED pin
	LED_PORT.OUTCLR = LED_PIN;

	// Clear the interrupt flag
	TCA0.SINGLE.INTFLAGS = TCA_SINGLE_CMP0_bm;
}


/// TCA0 Overflow Interrupt Handler
ISR(TCA0_OVF_vect)
{
	// toggle the LED pin
	LED_PORT.OUTSET = LED_PIN;

	// Clear the interrupt flag
	TCA0.SINGLE.INTFLAGS = TCA_SINGLE_OVF_bm;
}