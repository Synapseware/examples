#ifndef __EXAMPLE_H__
#define __EXAMPLE_H__



#include <stdlib.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/power.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include <avr/sleep.h>
#include <util/delay.h>


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



// LED pin info
#define LED_PORT		PORTA
#define LED_PIN			PIN1_bm


#endif
