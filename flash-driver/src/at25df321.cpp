#include "at25df321.h"


// -------------------------------------------------------------------------------------------------------------------------
// Constructor
Flash4MBit::Flash4MBit(uint8_t cs_pin)
{
	// need to map arduino pin #'s to ports
	_chip_cs = cs_pin;
}


// -------------------------------------------------------------------------------------------------------------------------
// Returns 1 if the driver detects an AT25DF321 chip on the given port
int Flash4MBit::valid(void)
{
	selectChip();

	uint8_t
		mfgid	= 0,
		devid1	= 0;

	SPI.transfer(0x9f);
	mfgid	= SPI.transfer(0);
	devid1	= SPI.transfer(0);
	SPI.transfer(0);
	SPI.transfer(0);

	unselectChip();

	return mfgid == 0x1F && devid1 == 0x47;
}


// -------------------------------------------------------------------------------------------------------------------------
// Enable writes by setting the write enable bit
void Flash4MBit::unprotect(void)
{
	write_enable();

	selectChip();

	SPI.transfer(0x01);				// allow setting of the SPRL bit and the global protect/unprotect flags
	SPI.transfer
	(
		(0<<7) |					// SPRL bit.  0 = unlocked (default), 1 = locked
		(0<<5) |					// bits 5:2 must be cleared
		(0<<4) |
		(0<<3) |
		(0<<2)
	);

	unselectChip();
}


// -------------------------------------------------------------------------------------------------------------------------
void Flash4MBit::protect(void)
{
	write_enable();

	selectChip();

	SPI.transfer(0x01);				// allow setting of the SPRL bit and the global protect/unprotect flags
	SPI.transfer
	(
		(1<<7) |					// SPRL bit.  0 = unlocked (default), 1 = locked
		(1<<5) |					// bits 5:2 must be set
		(1<<4) |
		(1<<3) |
		(1<<2)
	);

	unselectChip();
}


// -------------------------------------------------------------------------------------------------------------------------
void Flash4MBit::unprotect(uint8_t sector)
{
	write_enable();

	selectChip();
	SPI.transfer(0x39);
	SPI.transfer(sector & 0x3F);
	SPI.transfer(0);
	SPI.transfer(0);
	unselectChip();
}


// -------------------------------------------------------------------------------------------------------------------------
void Flash4MBit::protect(uint8_t sector)
{
	write_enable();

	selectChip();
	SPI.transfer(0x36);
	SPI.transfer(sector & 0x3F);
	SPI.transfer(0);
	SPI.transfer(0);
	unselectChip();
}


// -------------------------------------------------------------------------------------------------------------------------
int Flash4MBit::erase(void)
{
	write_enable();

	selectChip();
	SPI.transfer(0x60);
	unselectChip();

	return write_succeeded();
}


// -------------------------------------------------------------------------------------------------------------------------
int Flash4MBit::write(uint32_t address, int length, const uint8_t * buffer)
{
	write_enable();

	selectChip();
	SPI.transfer(0x02);
	SPI.transfer((address >> 16) & 0x3F);
	SPI.transfer(address >> 8);
	SPI.transfer(address & 0xff);

	int index = 0;
	while(index < count)
	{
		SPI.transfer(pbuff[index++]);
	}

	unselectChip();

	write_disable();

	return write_succeeded();
}


// -------------------------------------------------------------------------------------------------------------------------
int Flash4MBit::read(uint32_t address, int length, uint8_t * buffer)
{
	write_enable();

	selectChip();
	SPI.transfer(0x02);
	SPI.transfer((address >> 16) & 0x3F);
	SPI.transfer(address >> 8);
	SPI.transfer(address & 0xff);

	int index = 0;
	while(index < count)
	{
		SPI.transfer(pbuff[index++]);
	}

	unselectChip();

	write_disable();

	return write_succeeded();
}


// ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****
// PRIVATE METHODS
// ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** ***** *****


// -------------------------------------------------------------------------------------------------------------------------
uint8_t Flash4MBit::read_status_register(void)
{
	selectChip();
	SPI.transfer(0x05);
	uint8_t status = SPI.transfer(0);	// write a dummy byte so we can clock in the data from the device
	unselectChip();

	return status;
}


// -------------------------------------------------------------------------------------------------------------------------
uint8_t Flash4MBit::device_is_ready(void)
{
	// if bit 0 is cleared then the device is ready
	if ((read_status_register(chip_cs_pin) & 0x01) == 0)
		return 1;

	// device is not ready
	return 0;
}


// -------------------------------------------------------------------------------------------------------------------------
uint8_t Flash4MBit::write_succeeded(void)
{
	// if bit 5 is clear, no error was detected so return true
	if ((read_status_register(chip_cs_pin) & (1<<5)) == 0)
		return 1;

	// return false to indicate an error
	return 0;
}


// -------------------------------------------------------------------------------------------------------------------------
void Flash4MBit::write_enable(void)
{
	// write 06h to the chip to enable the write mode
	selectChip();
	SPI.transfer(0x06);
	unselectChip();
}


// -------------------------------------------------------------------------------------------------------------------------
void Flash4MBit::write_disable(void)
{
	// write 04h to the chip to disable the write mode
	selectChip();
	SPI.transfer(0x04);
	unselectChip();
}


// -------------------------------------------------------------------------------------------------------------------------
// helper function which performs the actual erase operation
void Flash4MBit::erase_block(uint8_t mode, uint32_t address)
{
	write_enable();
	selectChip();

	SPI.transfer(mode);
	SPI.transfer((address >> 16) & 0x3F);
	SPI.transfer(address >> 8);
	SPI.transfer(address & 0xFF);

	unselectChip();
	write_disable();
}


// -------------------------------------------------------------------------------------------------------------------------
// Formats a single page by writting 0xFF to all 256 cells
void Flash4MBit::erase_block256(uint32_t address)
{
	
}


// -------------------------------------------------------------------------------------------------------------------------
// erases a 4K block starting at address
void Flash4MBit::erase_block_4k(uint32_t address)
{
	// 0x20
	erase_block(0x20, address & 0xFFFFF000);	// blank out the bottom 12 bits
}


// -------------------------------------------------------------------------------------------------------------------------
// erases a 32K block starting at address
int Flash4MBit::erase_block_32k(uint32_t address)
{
	// 0x52
	erase_block(0x52, address & 0xFFFFF000);	// blank out the bottom 15 bits

	return write_succeeded();
}


// -------------------------------------------------------------------------------------------------------------------------
// erases a 64K block starting at address
int Flash4MBit::erase_block_64k(uint32_t address)
{
	// 0xD8
	erase_block(0xD8, address & 0xFFFF0000);	// blank out the bottom 16 bits

	return write_succeeded();
}


// -------------------------------------------------------------------------------------------------------------------------
// Reads a page of 256 bytes of data from the chip so that it can be formatted
// and re-written
void Flash4MBit::read_page(uint32_t address)
{

}