#ifndef __AT25DF321__H_
#define __AT25DF321__H_



#include <stdio.h>
#include <stdlib.h>



class Flash4MBit
{
public:
	Flash4MBit(uint8_t cs_pin);

	int valid(void);
	void unprotect(void);
	void protect(void);
	void unprotect(uint8_t sector);
	void protect(uint8_t sector);

	int erase(void);

	int write(uint32_t address, int length, const uint8_t * pbuff);
	int read(uint32_t address, int length, uint8_t* pbuff);

private:
	uint8_t read_status_register(void);
	uint8_t device_is_ready(void);
	uint8_t write_succeeded(void);
	void write_enable(void);

	void erase_block(uint8_t mode, uint32_t address);
	void erase_block_4k(uint32_t address);
	int erase_block_32k(uint32_t address);
	int erase_block_64k(uint32_t address);

	void read_page(uint32_t address);

	selectChip(void)
	{
		PORTB &= ~_chip_cs;
	}
	unselectChip(void)
	{
		PORTB |= _chip_cs;
	}

	uint8_t		_chip_cs;
	uint8_t		_data_in;
	uint8_t		_data_out;
	uint8_t		_spi_clock;

	uint8_t		buffer[256];
};




#endif
