

#include "at25df321.h"
#include <SPI.h>
#include <avr/pgmspace.h>

// Flash chip SS select lines
#define CHIP_1		8
#define CHIP_2		9

// SPI data & clock pins
#define DATAOUT 11
#define DATAIN  12
#define SPICLOCK  13


uint8_t buffer[256];


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
	// if bit 5 is set then an error was detected
	if ((read_status_register(chip_cs_pin) & (1<<5)) == 0)
		return 1;

	// no errors detected
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


// -------------------------------------------------------------------------------------------------------------------------
// setup
void setup()
{
	Serial.begin(9600);
	Serial.println(F("Setting up AT25DF321 chip #1 for a quick format, write and read operation."));

	// bring the 2 chip select lines high
	digitalWrite(CHIP_1, 1);
	digitalWrite(CHIP_2, 1);
	pinMode(CHIP_1, OUTPUT);
	pinMode(CHIP_2, OUTPUT);

	// prepare SPI lines
	pinMode(DATAOUT, OUTPUT);
	pinMode(DATAIN, INPUT);
	pinMode(SPICLOCK, OUTPUT);

	// set SPI communication parameters
	SPI.setClockDivider(SPI_CLOCK_DIV16);
	SPI.setDataMode(SPI_MODE0);
	SPI.setBitOrder(MSBFIRST);

	// begin
	SPI.begin();

	// format the chip
	if (erase_chip(CHIP_1))
		Serial.println(F("Chip erase OK"));
	else
	{
		Serial.println(F("Chip erase failed!"));
		return;
	}

	// wait for erase to complete
	while(!device_is_ready(CHIP_1));

	// write some test data to the buffer so we have something to send to the chip!
	strcpy_P((char*)buffer, PSTR("This is some silly data we're going to write to the chip!"));

	// write some data
	if (write_block(CHIP_1, 0, sizeof(buffer), buffer))
		Serial.println(F("Data written OK"));
	else
	{
		Serial.println(F("Write block failed"));
		return;
	}

	// wait for erase to complete
	while(!device_is_ready(CHIP_1));

	// clear the buffer to prove the read works (and hence the write is good)
	memset(buffer, 0, sizeof(buffer));

	// read some data
	read_block(CHIP_1, 0, sizeof(buffer), buffer);

	// display it on the serial port
	Serial.print(F("Buffer read: "));
	Serial.write(buffer, sizeof(buffer));
	Serial.println();

	// and done!
	SPI.end();

	Serial.println(F("Done!"));
}



// -------------------------------------------------------------------------------------------------------------------------
// Main program loop
void loop()
{

}
