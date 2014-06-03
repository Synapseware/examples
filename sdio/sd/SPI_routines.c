//**************************************************************
// ****** FUNCTIONS FOR SPI COMMUNICATION *******
//**************************************************************
//Controller: ATmega32 (8 Mhz internal)
//Compiler: AVR-GCC
//Author: CC Dharmani, Chennai (India)
// www.dharmanitech.com
//Date: 18 April 2009
//**************************************************************

//**************************************************
// ***** SOURCE FILE : SPI_routines.c ******
//**************************************************
#include <avr/io.h>
#include "SPI_routines.h"

//SPI initialize for SD card
//clock rate: 125Khz
void spi_init(void)
{
	SPCR = 0x52; //setup SPI: Master mode, MSB first, SCK phase low, SCK idle low
	SPSR = 0x00;
}

unsigned char SPI_transmit(unsigned char data)
{
	// Start transmission
	SPDR = data;

	// Wait for transmission complete
	while(!(SPSR & (1<<SPIF)));
	data = SPDR;

	return(data);
}

unsigned char SPI_receive(void)
{
	unsigned char data;
	// Wait for reception complete

	SPDR = 0xff;
	while(!(SPSR & (1<<SPIF)));
	data = SPDR;

	// Return data register
	return data;
}

//******** END ****** www.dharmanitech.com *****
