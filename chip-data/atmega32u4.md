atmega32u4
==========

# Hardware

## Timer0 Settings
> Timer/Counter0 is a general purpose 8-bit Timer/Counter module, with two independent Output Compare Units, and with PWM support. It allows accurate program execution timing (event management) and wave generation.

```c

    // 
    TCCR0A  =   (0<<COM0A)  |
                (0<<COM0A)  |
                (0<<COM0B)  |
                (0<<COM0B)  |
                (0<<WGM0)   |
                (0<<WGM0);

    // 
    TCCR0B  =   (0<<FOC0A)  |
                (0<<FOC0B)  |
                (0<<WGM02)  |
                (0<<CS02)   |
                (0<<CS01)   |
                (0<<CS00);

    // 
    TCNT0   =   0;

    // Output Compare Register A
    OCR0A   =   0;
    
    // Output Compare Register B
    OCR0B   =   0;

    // Timer/Counter Interrupt Mask Register
    TIMSK0  =   (0<<OCIE0B) |
                (0<<OCIE0A) |
                (0<<TOIE0);

    // Timer/Counter 0 Interrupt Flag Register
    TIFR0   =   (0<<OCF0B)  |
                (0<<OCF0A)  |
                (0<<TOV0);
```

## Timer1 Settings
> The 16-bit Timer/Counter unit allows accurate program execution timing (event management),
wave generation, and signal timing measurement.

16-bit Timers/Counters (Timer/Counter1)
```c
    // Timer/Counter1 Control Register A
    TCCR1A  =   (0<<COM1A1) |
                (0<<COM1A0) |
                (0<<COM1B1) |
                (0<<COM1B0) |
                (0<<COM1C1) |
                (0<<COM1C0) |
                (0<<WGM11)  |
                (0<<WGM10);

    // Timer/Counter1 Control Register B
    TCCR1B  =   (0<<ICNC1)  |
                (0<<ICES1)  |
                (0<<WGM13)  |
                (0<<WGM12)  |
                (0<<CS12)   |
                (0<<CS11)   |
                (0<<CS10);

    // Timer/Counter1 Control Register C
    TCCR1C  =   (0<<FOC1A)  |
                (0<<FOC1B)  |
                (0<<FOC1C);

    // Timer/Counter1
    TCNT1H  =   0;
    TCNT1L  =   0;

    // Output Compare Register 1 A
    OCR1AH  =   0;
    OCR1AL  =   0;

    // Output Compare Register 1 B
    OCR1BH  =   0;
    OCR1BL  =   0;

    // Output Compare Register 1 C
    OCR1CH  =   0;
    OCR1CL  =   0;

    // Input Capture Register 1
    ICR1H   =   0;
    ICR1L   =   0;

    // Timer/Counter1 Interrupt Mask Register
    TIMSK1  =   (0<<ICIE1)  |
                (0<<OCIE1C) |
                (0<<OCIE1B) |
                (0<<OCIE1A) |
                (0<<TOIE1);

    // Timer/Counter1 Interrupt Flag Register
    TIFR1   =   (0<<ICF1)   |
                (0<<OCF1C)  |
                (0<<OCF1B)  |
                (0<<OCF1A)  |
                (0<<TOV1);
```


## Timer3 Settings
> The 16-bit Timer/Counter unit allows accurate program execution timing (event management),
wave generation, and signal timing measurement.

16-bit Timers/Counters (Timer/Counter3)
```c
    // Timer/Counter3 Control Register A
    TCCR3A  =   (0<<COM3A1) |
                (0<<COM3A0) |
                (0<<COM3B1) |
                (0<<COM3B0) |
                (0<<COM3C1) |
                (0<<COM3C0) |
                (0<<WGM31)  |
                (0<<WGM30);

    // Timer/Counter3 Control Register B
    TCCR3B  =   (0<<ICNC3)  |
                (0<<ICES3)  |
                (0<<WGM33)  |
                (0<<WGM32)  |
                (0<<CS32)   |
                (0<<CS31)   |
                (0<<CS30);

    // Timer/Counter3 Control Register C
    TCCR3C  =   (0<<FOC3A);

    // Timer/Counter3
    TCNT3H  =   0;
    TCNT3L  =   0;

    // Output Compare Register 3 A
    OCR3AH  =   0;
    OCR3AL  =   0;

    // Output Compare Register 3 B
    OCR3BH  =   0;
    OCR3BL  =   0;

    // Output Compare Register 3 C
    OCR3CH  =   0;
    OCR3CL  =   0;

    // Input Capture Register 3
    ICR3H   =   0;
    ICR3L   =   0;

    // Timer/Counter3 Interrupt Mask Register
    TIMSK3  =   (0<<ICIE3)  |
                (0<<OCIE3C) |
                (0<<OCIE3B) |
                (0<<OCIE3A) |
                (0<<TOIE3);

    // Timer/Counter3 Interrupt Flag Register
    TIFR3   =   (0<<ICF3)   |
                (0<<OCF3C)  |
                (0<<OCF3B)  |
                (0<<OCF3A)  |
                (0<<TOV3);

```


## Timer4
> Timer/Counter4 is a general purpose high speed Timer/Counter module, with three independent Output Compare Units, and with enhanced PWM support.

```c

    // Timer/Counter4 Control Register A
    TCCR4A  =   (0<<COM4A1) |
                (0<<COM4A0) |
                (0<<COM4B1) |
                (0<<COM4B0) |
                (0<<FOC4A)  |
                (0<<FOC4B)  |
                (0<<PWM4A)  |
                (0<<PWM4B);

    // Timer/Counter4 Control Register B
    TCCR4B  =   (0<<PWM4X)  |
                (0<<PSR4)   |
                (0<<DTPS41) |
                (0<<DTPS40) |
                (0<<CS43)   |
                (0<<CS42)   |
                (0<<CS41)   |
                (0<<CS40);

    // Timer/Counter4 Control Register C
    TCCR4C  =   (0<<COM4A1S) |
                (0<<COM4A0S) |
                (0<<COM4B1S) |
                (0<<COMAB0S) |
                (0<<COM4D1)  |
                (0<<COM4D0)  |
                (0<<FOC4D)   |
                (0<<PWM4D);

    // Timer/Counter4 Control Register D
    TCCR4D  =   (0<<FPIE4)  |
                (0<<FPEN4)  |
                (0<<FPNC4)  |
                (0<<FPES4)  |
                (0<<FPAC4)  |
                (0<<FPF4)   |
                (0<<WGM41)  |
                (0<<WGM40);

    // Timer/Counter4 Control Register E
    TCCR4E  =   (0<<TLOCK4) |
                (0<<ENHC4)  |
                (0<<OC4OE5) |
                (0<<OC4OE4) |
                (0<<OC4OE3) |
                (0<<OC4OE2) |
                (0<<OC4OE1) |
                (0<<OC4OE0);

    // Timer/Counter4
    TCNT4   =   0;

    // Timer/Counter4 High Byte (only bits 2:0)
    TC4H    =   0;

    // Timer/Counter4 Output Compare Register A
    OCR4A   =   0;

    // Timer/Counter4 Output Compare Register B
    OCR4B   =   0;

    // Timer/Counter4 Output Compare Register C
    OCR4C   =   0;

    // Timer/Counter4 Output Compare Register D
    OCR4D   =   0;

    // Timer/Counter4 Interrupt Mask Register
    TIMSK4  =   (0<<OCIE4D) |
                (0<<OCIE4A) |
                (0<<OCIE4B) |
                (0<<TOIE4);

    // Timer/Counter4 Interrupt Flag Register
    TIFR4   =   (0<<OCF4D)  |
                (0<<OCF4A)  |
                (0<<OCF4B)  |
                (0<<TOV4);

    // Timer/Counter4 Dead Time Value
    DT4     =   (0<<DT4H3)  |
                (0<<DT4H2)  |
                (0<<DT4H1)  |
                (0<<DT4H0)  |
                (0<<DT4L3)  |
                (0<<DT4L2)  |
                (0<<DT4L1)  |
                (0<<DT4L0);
```


## USART
> The Universal Synchronous and Asynchronous serial Receiver and Transmitter (USART) is a highly flexible serial communication device.

```c

    //USART I/O Data Register 0
    UDR0    =   0;

    // USART Co0trol a0d Status Register A
    UCSR0A  =   (0<<RXC0)   |
                (0<<TXC0)   |
                (0<<UDRE0)  |
                (0<<FE0)    |
                (0<<DOR0)   |
                (0<<UPE0)   |
                (0<<U2X0)   |
                (0<<MPCM0);

    // USART Co0trol a0d Status Register 0 B
    UCSR0B  =   (0<<RXCIE0) |
                (0<<TXCIE0) |
                (0<<UDRIE0) |
                (0<<RXE00)  |
                (0<<TXE00)  |
                (0<<UCSZ02) |
                (0<<RXB80)  |
                (0<<TXB80);

    // USART Co0trol a0d Status Register 0 C
    UCSR0C  =   (0<<UMSEL01)|
                (0<<UMSEL00)|
                (0<<UPM01)  |
                (0<<UPM00)  |
                (0<<USBS0)  |
                (0<<UCSZ01) |
                (0<<UCSZ00) |
                (0<<UCPOL0);
    
    // USART Co0trol a0d Status Register 0 D
    UCSR0D  =   (0<<CTSE0)  |
                (0<<RTSE0);
    
    // USART Baud Rate Registers
    UBRRL0  =   0;
    UBRRH0  =   0;
```


## Serial Peripheral Interface – SPI
> The Serial Peripheral Interface (SPI) allows high-speed synchronous data transfer between the ATmega16U4/ATmega32U4 and peripheral devices or between several AVR devices.

### Slave Mode
When the SPI is configured as a Slave, the Slave Select (SS) pin is always input. When SS is held low, the SPI is activated, and MISO becomes an output if configured so by the user.

```c
    // SPI Control Register
    SPCR    =   (0<<SPIE)   |   // Bit 7 – SPIE: SPI Interrupt Enable
                (0<<SPE)    |   // Bit 6 – SPE: SPI Enable
                (0<<DORD)   |   // Bit 5 – DORD: Data Order
                (0<<MSTR)   |   // Bit 4 – MSTR: Master/Slave Select
                (0<<CPOL)   |   // Bit 3 – CPOL: Clock Polarity
                (0<<CPHA)   |   // Bit 2 – CPHA: Clock Phase
                (0<<SPR1)   |   // Bit 1 - SPR1: SPI Clock Rate Select
                (0<<SPR0);      // Bit 0 - SPR0: SPI Clock Rate Select
    
    // SPI Status Register
    SPSR    =   (0<<SPIF)   |   // Bit 7 – SPIF: SPI Interrupt Flag
                (0<<WCOL)   |   // Bit 6 – WCOL: Write COLlision Flag
                (0<<SPI2X);     // Bit 0 – SPI2X: Double SPI Speed Bit
    
    // SPI Data Register
    SPDR    =   0;
```


## 2-wire Serial Interface - TWI/I2C
> The 2-wire Serial Interface (TWI) is ideally suited for typical microcontroller applications. The TWI protocol allows the systems designer to interconnect up to 128 different devices using only two bi-directional bus lines, one for clock (SCL) and one for data (SDA).

```c
    // TWI Bit Rate Register
    TWBR    =   0;

    // TWI Control Register
    TWCR    =   (0<<TWINT)  |   // Bit 7 – TWINT: TWI Interrupt Flag
                (0<<TWEA)   |   // Bit 6 – TWEA: TWI Enable Acknowledge Bit
                (0<<TWSTA)  |   // Bit 5 – TWSTA: TWI START Condition Bit
                (0<<TWSTO)  |   // Bit 4 – TWSTO: TWI STOP Condition Bit
                (0<<TWWC)   |   // Bit 3 – TWWC: TWI Write Collision Flag
                (0<<TWEN)   |   // Bit 2 – TWEN: TWI Enable Bit
                (0<<TWIE);      // Bit 0 – TWIE: TWI Interrupt Enable

    // TWI Status Register
    TWSR    =   (0<<TWS7)   |   // Bits 7..3 – TWS: TWI Status
                (0<<TWS6)   |   // 
                (0<<TWS5)   |   // 
                (0<<TWS4)   |   // 
                (0<<TWS3)   |   // 
                (0<<TWPS1)  |   // Bits 1..0 – TWPS: TWI Prescaler Bits
                (0<<TWPS0);     // 

    // TWI Data Register
    TWDR    =   0;

    // TWI (Slave) Address Register
    // Bits 7..1 – TWAM: TWI Address Mask
    TWAR    =   0;

    // TWI (Slave) Address Mask Register
    TWAMR   =   0;
```

