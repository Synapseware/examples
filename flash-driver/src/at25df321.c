// -------------------------------------------------------------------------------------------------------------------------
// reads the status register byte and returns it
uint8_t read_status_register(int chip_cs_pin)
{
	digitalWrite(chip_cs_pin, 0);
	SPI.transfer(0x05);
	uint8_t status = SPI.transfer(0);	// write a dummy byte so we can clock in the data from the device
	digitalWrite(chip_cs_pin, 1);

	return status;
}

// -------------------------------------------------------------------------------------------------------------------------
// returns a 1 if the device is ready for erase or program operations
uint8_t device_is_ready(int chip_cs_pin)
{
	// if bit 0 is cleared then the device is ready
	if ((read_status_register(chip_cs_pin) & 0x01) == 0)
		return 1;

	// device is not ready
	return 0;
}

// -------------------------------------------------------------------------------------------------------------------------
// returns 1 if the device encountered an erase or program error
uint8_t write_succeeded(int chip_cs_pin)
{
	// if bit 5 is clear, no error was detected so return true
	if ((read_status_register(chip_cs_pin) & (1<<5)) == 0)
		return 1;

	// return false to indicate an error
	return 0;
}

// -------------------------------------------------------------------------------------------------------------------------
// Enable writes by setting the write enable bit
inline void write_enable(int chip_cs_pin)
{
	// write 06h to the chip to enable the write mode
	digitalWrite(chip_cs_pin, 0);
	SPI.transfer(0x06);
	digitalWrite(chip_cs_pin, 1);
}

// -------------------------------------------------------------------------------------------------------------------------
// Disable writes by clearing the write enable bit
inline void write_disable(int chip_cs_pin)
{
	// write 04h to the chip to disable the write mode
	digitalWrite(chip_cs_pin, 0);
	SPI.transfer(0x04);
	digitalWrite(chip_cs_pin, 1);
}

// -------------------------------------------------------------------------------------------------------------------------
// returns a 1 if the chip is an at25df321, 0 if not
int is_valid(int chip_cs_pin)
{
	digitalWrite(chip_cs_pin, 0);

	uint8_t
		mfgid	= 0,
		devid1	= 0;

	SPI.transfer(0x9f);
	mfgid	= SPI.transfer(0);
	devid1	= SPI.transfer(0);
	SPI.transfer(0);
	SPI.transfer(0);

	digitalWrite(chip_cs_pin, 1);

	return mfgid == 0x1F && devid1 == 0x47;
}

// -------------------------------------------------------------------------------------------------------------------------
// Globally allow sector unprotection
void global_unprotect(int chip_cs_pin)
{
	write_enable(chip_cs_pin);

	digitalWrite(chip_cs_pin, 0);
	SPI.transfer(0x01);				// allow setting of the SPRL bit and the global protect/unprotect flags
	SPI.transfer
	(
		(0<<7) |					// SPRL bit.  0 = unlocked (default), 1 = locked
		(0<<5) |					// bits 5:2 must be cleared
		(0<<4) |
		(0<<3) |
		(0<<2)
	);
	digitalWrite(chip_cs_pin, 1);
}

// -------------------------------------------------------------------------------------------------------------------------
// Sets a sector as unprotected
void unprotect_sector(int chip_cs_pin, uint8_t sector)
{
	write_enable(chip_cs_pin);

	digitalWrite(chip_cs_pin, 0);
	SPI.transfer(0x39);
	SPI.transfer(sector & 0x3F);
	SPI.transfer(0);
	SPI.transfer(0);
	digitalWrite(chip_cs_pin, 1);
}

// -------------------------------------------------------------------------------------------------------------------------
// Sets a sector as unprotected
void protect_sector(int chip_cs_pin, uint8_t sector)
{
	write_enable(chip_cs_pin);

	digitalWrite(chip_cs_pin, 0);
	SPI.transfer(0x36);
	SPI.transfer(sector & 0x3F);
	SPI.transfer(0);
	SPI.transfer(0);
	digitalWrite(chip_cs_pin, 1);
}

// -------------------------------------------------------------------------------------------------------------------------
// helper function which performs the actual erase operation
void erase_block(int chip_cs_pin, uint8_t mode, uint32_t address)
{
	write_enable(chip_cs_pin);
	digitalWrite(chip_cs_pin, 0);

	SPI.transfer(mode);
	SPI.transfer((address >> 16) & 0x3F);
	SPI.transfer(address >> 8);
	SPI.transfer(address & 0xFF);

	digitalWrite(chip_cs_pin, 1);
	write_disable(chip_cs_pin);
}

// -------------------------------------------------------------------------------------------------------------------------
// 
void erase_block_4k(int chip_cs_pin, uint32_t address)
{
	// 0x20
	erase_block(chip_cs_pin, 0x20, address & 0xFFFFF000);	// blank out the bottom 12 bits
}

// -------------------------------------------------------------------------------------------------------------------------
// 
int erase_block_32k(int chip_cs_pin, uint32_t address)
{
	// 0x52
	erase_block(chip_cs_pin, 0x52, address & 0xFFFFF000);	// blank out the bottom 15 bits

	return write_succeeded(chip_cs_pin);
}

// -------------------------------------------------------------------------------------------------------------------------
// 
int erase_block_64k(int chip_cs_pin, uint32_t address)
{
	// 0xD8
	erase_block(chip_cs_pin, 0xD8, address & 0xFFFF0000);	// blank out the bottom 16 bits

	return write_succeeded(chip_cs_pin);
}

// -------------------------------------------------------------------------------------------------------------------------
// erases the complete chip
int erase_chip(int chip_cs_pin)
{
	write_enable(chip_cs_pin);

	digitalWrite(chip_cs_pin, 0);
	SPI.transfer(0x60);
	digitalWrite(chip_cs_pin, 1);

	return write_succeeded(chip_cs_pin);
}

// -------------------------------------------------------------------------------------------------------------------------
// Writes a block of data to the chip.  Block can be 1 to 256 bytes wide.
int write_block(int chip_cs_pin, uint32_t address, int count, const uint8_t * pbuff)
{
	write_enable(chip_cs_pin);

	digitalWrite(chip_cs_pin, 0);
	SPI.transfer(0x02);
	SPI.transfer((address >> 16) & 0x3F);
	SPI.transfer(address >> 8);
	SPI.transfer(address & 0xff);

	int index = 0;
	while(index < count)
	{
		SPI.transfer(pbuff[index++]);
	}

	digitalWrite(chip_cs_pin, 1);

	write_disable(chip_cs_pin);

	return write_succeeded(chip_cs_pin);
}

// -------------------------------------------------------------------------------------------------------------------------
// reads 'count' bytes into 'pbuff' array and returns the number of bytes read
int read_block(int chip_cs_pin, uint32_t address, int count, uint8_t* pbuff)
{
	digitalWrite(chip_cs_pin, 0);

	SPI.transfer(0x03);	// high-speed SPI clock because it's good for all clock values
	SPI.transfer((address >> 16) & 0x3F);
	SPI.transfer(address >> 8);
	SPI.transfer(address & 0xFF);
	//SPI.transfer(0);	// since we are using 0x0B clock mode, write a dummy byte (per datasheet)

	int index = 0;
	while (index < count)
	{
		// clock in the data from the chip
		pbuff[index++] = SPI.transfer(0);
	}
	digitalWrite(chip_cs_pin, 1);

	return index;
}


