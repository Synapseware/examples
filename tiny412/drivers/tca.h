#ifndef __TCA_H__
#define __TCA_H__


// ---------------------------------------------------------------------------
// Sets pin PA? as the output for WO0
static void TCA_SetTCA0_Output(uint8_t defaultOut)
{
	PORTA.DIRSET = PIN3_bm;

	// set a default output vaule
	if (defaultOut)
		PORTA.OUTSET = PIN3_bm;
	else
		PORTA.OUTCLR = PIN3_bm;
}


// ---------------------------------------------------------------------------
// Sets pin PA7 as the output for WO0
static void TCA_Set_TCA00_AlternateOutput(uint8_t defaultOut)
{
	// mark the pin as output
	PORTA.DIRSET = PIN7_bm;

	// set a default output vaule
	if (defaultOut)
		PORTA.OUTSET = PIN7_bm;
	else
		PORTA.OUTCLR = PIN7_bm;

	// toggle the alternate function for PA7
	PORTMUX.CTRLC |= PORTMUX_TCA00_bm;
}



#endif
