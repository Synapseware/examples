//***********************************************************
// **** MAIN routine FOR Interfacing microSD/SDHC CARD ****
//***********************************************************
//Controller: ATmega32 (Clock: 8 Mhz-internal)
//Compiler	: AVR-GCC (winAVR with AVRStudio)
//Version 	: 2.3
//Author	: CC Dharmani, Chennai (India)
//			  www.dharmanitech.com
//Date		: 08 May 2010
//***********************************************************

//Link to the Post: http://www.dharmanitech.com/2009/01/sd-card-interfacing-with-atmega8-fat32.html

#include <avr/io.h>
#include <avr/pgmspace.h>
#include <avr/interrupt.h>
#include <util/delay.h>
#include "SPI_routines.h"
#include "SD_routines.h"
#include "UART_routines.h"
#include "FAT32.h"


void port_init(void)
{
	PORTB = 0xEF;
	DDRB  = 0xBF; //MISO line i/p, rest o/p
	PORTC = 0x00;
	DDRC  = 0x00;
	PORTD = 0x00;
	DDRD  = 0xFE;
}


//call this routine to initialize all peripherals
void init_devices(void)
{
	port_init();
	spi_init();
	uart0_init();
}

//*************************** MAIN *******************************//
int main(void)
{
	unsigned char option, error, data, FAT32_active;
	unsigned int i;
	unsigned char fileName[13];

	init_devices();

	PORTD |= 0x04; //switching ON the LED (for testing purpose only)

	TX_NEWLINE;
	TX_NEWLINE;
	transmitString_F (PSTR("*********************************************"));
	TX_NEWLINE;
	transmitString_F (PSTR("    Dharmani's microSD Card Testing..  "));
	TX_NEWLINE;
	transmitString_F (PSTR("*********************************************"));
	TX_NEWLINE;

	cardType = 0;

	for (i=0; i<10; i++)
	{
		error = SD_init();
		if(!error) break;
	}

	if(error)
	{
		if(error == 1)
			transmitString_F(PSTR("SD card not detected.."));
		if(error == 2)
			transmitString_F(PSTR("Card Initialization failed.."));

		while(1);  //wait here forever if error in SD init
	}

	switch (cardType)
	{
		case 1:
			transmitString_F(PSTR("Standard Capacity Card (Ver 1.x) Detected!"));
			break;
		case 2:
			transmitString_F(PSTR("High Capacity Card Detected!"));
			break;
		case 3:
			transmitString_F(PSTR("Standard Capacity Card (Ver 2.x) Detected!"));
			break;
		default:
			transmitString_F(PSTR("Unknown SD Card Detected!"));
			break;
	}

	SPI_HIGH_SPEED;	//SCK - 4 MHz
	_delay_ms(1);   //some delay

	FAT32_active = 1;
	error = getBootSectorData (); //read boot sector and keep necessary data in global variables
	if(error)
	{
		TX_NEWLINE;
		transmitString_F (PSTR("FAT32 not found!"));  //FAT32 incompatible drive
		FAT32_active = 0;
	}

	while(1)
	{
		TX_NEWLINE;
		transmitString_F(PSTR("Press any key..."));
		TX_NEWLINE;
		option = receiveByte();
		TX_NEWLINE;
		transmitString_F(PSTR("> 0 : Erase Blocks"));
		TX_NEWLINE;
		transmitString_F(PSTR("> 1 : Write single Block"));
		TX_NEWLINE;
		transmitString_F(PSTR("> 2 : Read single Block"));

		#ifndef FAT_TESTING_ONLY
		TX_NEWLINE;
		transmitString_F(PSTR("> 3 : Write multiple Blocks"));
		TX_NEWLINE;
		transmitString_F(PSTR("> 4 : Read multiple Blocks"));
		#endif


		TX_NEWLINE;
		transmitString_F(PSTR("> 5 : Get file list"));
		TX_NEWLINE;
		transmitString_F(PSTR("> 6 : Read File"));
		TX_NEWLINE;
		transmitString_F(PSTR("> 7 : Write File"));
		TX_NEWLINE;
		transmitString_F(PSTR("> 8 : Delete File"));
		TX_NEWLINE;
		transmitString_F(PSTR("> 9 : Read SD Memory Capacity (Total/Free)"));

		TX_NEWLINE;
		TX_NEWLINE;
		transmitString_F(PSTR("> Select Option (0-9): "));


		/*WARNING: If option 0, 1 or 3 is selected, the card may not be detected by PC/Laptop again,
		as it disturbs the FAT format, and you may have to format it again with FAT32.
		This options are given for learnig the raw data transfer to & from the SD Card*/

		option = receiveByte();
		transmitByte(option);

		if(option >=0x35 && option <=0x39)  //options 5 to 9 disabled if FAT32 not found
		{
			if(!FAT32_active)
			{
				TX_NEWLINE;
				TX_NEWLINE;
				transmitString_F(PSTR("FAT32 options disabled!"));
				continue;
			}
		}


		if((option >= 0x30) && (option <=0x34)) //get starting block address for options 0 to 4
		{
			TX_NEWLINE;
			TX_NEWLINE;
			transmitString_F(PSTR("Enter the Block number (0000-9999):"));
			data = receiveByte(); transmitByte(data);
			startBlock = (data & 0x0f) * 1000;
			data = receiveByte(); transmitByte(data);
			startBlock += (data & 0x0f) * 100;
			data = receiveByte(); transmitByte(data);
			startBlock += (data & 0x0f) * 10;
			data = receiveByte(); transmitByte(data);
			startBlock += (data & 0x0f);
			TX_NEWLINE;
		}

		totalBlocks = 1;

		#ifndef FAT_TESTING_ONLY

		if((option == 0x30) || (option == 0x33) || (option == 0x34)) //get total number of blocks for options 0, 3 or 4
		{
			TX_NEWLINE;
			TX_NEWLINE;
			transmitString_F(PSTR("How many blocks? (000-999):"));
			data = receiveByte(); transmitByte(data);
			totalBlocks = (data & 0x0f) * 100;
			data = receiveByte(); transmitByte(data);
			totalBlocks += (data & 0x0f) * 10;
			data = receiveByte(); transmitByte(data);
			totalBlocks += (data & 0x0f);
			TX_NEWLINE;
		}
		#endif

		switch (option)
		{
			case '0': //error = SD_erase (block, totalBlocks);
			error = SD_erase (startBlock, totalBlocks);
			TX_NEWLINE;
			if(error)
			transmitString_F(PSTR("Erase failed.."));
			else
			transmitString_F(PSTR("Erased!"));
			break;

			case '1': TX_NEWLINE;
			transmitString_F(PSTR(" Enter text (End with ~):"));
			i=0;
			do
			{
				data = receiveByte();
				transmitByte(data);
				buffer[i++] = data;
				if(data == 0x0d)
				{
					transmitByte(0x0a);
					buffer[i++] = 0x0a;
				}
				if(i == 512) break;
			}while (data != '~');

			error = SD_writeSingleBlock (startBlock);
			TX_NEWLINE;
			TX_NEWLINE;
			if(error)
			transmitString_F(PSTR("Write failed.."));
			else
			transmitString_F(PSTR("Write successful!"));
			break;

			case '2': error = SD_readSingleBlock (startBlock);
			TX_NEWLINE;
			if(error)
			transmitString_F(PSTR("Read failed.."));
			else
			{
				for(i=0;i<512;i++)
				{
					if(buffer[i] == '~') break;
					transmitByte(buffer[i]);
				}
				TX_NEWLINE;
				TX_NEWLINE;
				transmitString_F(PSTR("Read successful!"));
			}

			break;
			//next two options will work only if following macro is cleared from SD_routines.h
			#ifndef FAT_TESTING_ONLY

			case '3':
			error = SD_writeMultipleBlock (startBlock, totalBlocks);
			TX_NEWLINE;
			if(error)
			transmitString_F(PSTR("Write failed.."));
			else
			transmitString_F(PSTR("Write successful!"));
			break;

			case '4': error = SD_readMultipleBlock (startBlock, totalBlocks);
			TX_NEWLINE;
			if(error)
			transmitString_F(PSTR("Read failed.."));
			else
			transmitString_F(PSTR("Read successful!"));
			break;
			#endif

			case '5': TX_NEWLINE;
			findFiles(GET_LIST,0);
			break;

			case '6':
			case '7':
			case '8':
				TX_NEWLINE;
				TX_NEWLINE;
				transmitString_F(PSTR("Enter file name: "));
				for(i=0; i<13; i++)
					fileName[i] = 0x00;   //clearing any previously stored file name
				i=0;
				while(1)
				{
					data = receiveByte();
					if(data == 0x0d)
						break;  //'ENTER' key pressed
					if(data == 0x08)	//'Back Space' key pressed
					{
						if(i != 0)
						{
							transmitByte(data);
							transmitByte(' ');
							transmitByte(data);
							i--;
						}
						continue;
					}
					if(data <0x20 || data > 0x7e)
						continue;  //check for valid English text character
					transmitByte(data);
					fileName[i++] = data;
					if(i==13)
					{
						transmitString_F(PSTR(" file name too long.."));
						break;
					}
				}
				if(i>12)
					break;
		
		TX_NEWLINE;
		if(option == '6')
		readFile( READ, fileName);
		if(option == '7')
		writeFile(fileName);
		if(option == '8')
		deleteFile(fileName);
		break;

		case '9': memoryStatistics();
		break;

		default: TX_NEWLINE;
		TX_NEWLINE;
		transmitString_F(PSTR(" Invalid option!"));
		TX_NEWLINE;
	}

	TX_NEWLINE;
}
return 0;
}
//********** END *********** www.dharmanitech.com *************
