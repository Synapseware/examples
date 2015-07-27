#ifndef __SEPIC_H__
#define __SEPIC_H__


#include <avr/io.h>
#include <avr/interrupt.h>
#include <inttypes.h>
#include <avr/sleep.h>


#define F_MAX    127

const float      SCALE      = (float)(F_MAX/255.0);
const uint8_t    MAX        = (uint8_t)(F_MAX * 0.90);



#endif
