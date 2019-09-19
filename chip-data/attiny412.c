static inline void XMEGACLK_CCP_Write(volatile void* Address, const uint8_t Value)
{
	__asm__ __volatile__ (
		"movw r30, %0"         "\n\t" /* Copy address to Z register pair */
		"out %1, %2"           "\n\t" /* Write key to CCP register */
		"st Z, %3"             "\n\t" /* Indirectly write value to address */
		: /* No output operands */
		: /* Input operands: */ "e" (Address), "m" (CCP), "r" (CCP_IOREG_gc), "r" (Value)
		: /* Clobbered registers: */ "r30", "r31"
	);
}


static void ConfigureCore(void)
{
	// Enable the 16/20MHz clock with no division
	XMEGACLK_CCP_Write(&CLKCTRL.MCLKCTRLA, CLKCTRL_CLKSEL_OSC20M_gc);

	// No clock pre-scaler
	XMEGACLK_CCP_Write(&CLKCTRL.MCLKCTRLB, 0);
}


static void ConfigureADC(void)
{
	// Set pins as input
	ADC_PORT.DIRCLR = (ADC_VBATT | ADC_VCONV);

	// Disable ADC0 completely
	ADC0.CTRLA = 0;

	// Accumulate 4 samples
	ADC0.CTRLB = ADC_SAMPNUM_ACC1_gc;

	// Set sample cap, reference voltage, and prescaler
	ADC0.CTRLC = ADC_SAMPCAP_bm | ADC_REFSEL_VDDREF_gc | ADC_PRESC_DIV256_gc;

	// Delay the first sample to ensure peripheral stability
	ADC0.CTRLD = ADC_INITDLY_DLY256_gc;

	ADC0.SAMPCTRL = 0;
	ADC0.MUXPOS = ADC_VBATT_MUX;

	// Configure interrupt on conversion complete
	ADC0.INTCTRL = ADC_RESRDY_bm;

	// Enable the ADC
	ADC0.CTRLA = ADC_ENABLE_bm; // | ADC_FREERUN_bm;
}



static void ConfigureRTC(void)
{
	// Wait for the 32kHz OSC to be stable
	while ((CLKCTRL.MCLKSTATUS & CLKCTRL_OSC32KS_bm));

	// Wait for RTC not to be busy
	while (RTC.STATUS);

	// Disable the RTC completely
	RTC.CTRLA = 0;

	// Set the period and compare ranges of the RTC
	RTC.PER		= RTC_PER;
	RTC.CMP		= RTC_PER / 2;

	// Select the internal 32kHz ULP Oscillation with
	// a 1kHz output
	RTC.CLKSEL	= RTC_CLK;

	// Enable compare and overflow interrupts on the RTC
	RTC.INTCTRL	= RTC_CMP_bm | RTC_OVF_bm;

	// Wait for RTC not to be busy - can't set CTRLA until it's clear
	while (RTC.STATUS);

	// Set the prescaler but don't enable the RTC yet
	RTC.CTRLA	= RTC_RUNSTDBY_bm | RTC_PRESCALER_DIV1_gc | RTC_RTCEN_bm;	
}
