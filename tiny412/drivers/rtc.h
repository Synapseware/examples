

#define RTC_RTC0_CLOCK_1KHZ	RTC_CLKSEL_INT1K_gc


//-----------------------------------------------------------------------------
// Configures the RTC
static void RTC_Initialize(uint16_t period, uint16_t compare)
{
	// Wait for the 32kHz OSC to be stable
	while ((CLKCTRL.MCLKSTATUS & CLKCTRL_OSC32KS_bm));

	// Wait for RTC not to be busy
	while (RTC.STATUS);

	// Disable the RTC completely
	RTC.CTRLA = 0;

	// Set the period and compare ranges of the RTC
	RTC.PER		= period;
	RTC.CMP		= compare;

	// Enable compare and overflow interrupts on the RTC
	RTC.INTCTRL	= RTC_CMP_bm | RTC_OVF_bm;
}


// Configure RTC to use 1kHz clock
static void RTC_SelectClock(void)
{

	// Select the internal 32kHz ULP Oscillation with
	// a 1kHz output
	RTC.CLKSEL	= RTC_CLKSEL_INT1K_gc;
}

// Enable the RTC with a 
static void RTC_Enable(void)
{
	// Wait for RTC not to be busy - can't set CTRLA until it's clear
	while (RTC.STATUS);

	// Set the prescaler but don't enable the RTC yet
	RTC.CTRLA	= RTC_RUNSTDBY_bm | RTC_PRESCALER_DIV1_gc | RTC_RTCEN_bm;	
}
