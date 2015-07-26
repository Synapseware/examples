atmega32u4
==========
The ATmega16U4/ATmega32U4 is a low-power CMOS 8-bit microcontroller based on the AVR enhanced RISC architecture. By executing powerful instructions in a single clock cycle, the ATmega16U4/ATmega32U4 achieves throughputs approaching 1 MIPS per MHz allowing the system designer to optimize power consumption versus processing speed.

# Interrupt Vectors in ATmega16U4/ATmega32U4
Reset and Interrupt Vectors
Vector No. | Program Address | Source | Interrupt Definition
------------------------------------------------------------
1 | $0000 | RESET | External Pin, Power-on Reset, Brown-out Reset, Watchdog Reset, and JTAG AVR Reset
2 | $0002 | INT0 | External Interrupt Request 0
3 | $0004 | INT1 | External Interrupt Request 1
4 | $0006 | INT2 | External Interrupt Request 2
5 | $0008 | INT3 | External Interrupt Request 3
6 | $000A | Reserved | Reserved
7 | $000C | Reserved | Reserved
8 | $000E | INT6 | External Interrupt Request 6
9 | $0010 | Reserved | Reserved
10 | $0012 | PCINT0 | Pin Change Interrupt Request 0
11 | $0014 | USB | General USB General Interrupt request
12 | $0016 | USB | Endpoint USB Endpoint Interrupt request
13 | $0018 | WDT | Watchdog Time-out Interrupt
14 | $001A | Reserved | Reserved
15 | $001C | Reserved | Reserved
16 | $001E | Reserved | Reserved
17 | $0020 | TIMER1 | CAPT Timer/Counter1 Capture Event
18 | $0022 | TIMER1 | COMPA Timer/Counter1 Compare Match A
19 | $0024 | TIMER1 | COMPB Timer/Counter1 Compare Match B
20 | $0026 | TIMER1 | COMPC Timer/Counter1 Compare Match C
21 | $0028 | TIMER1 | OVF Timer/Counter1 Overflow
22 | $002A | TIMER0 | COMPA Timer/Counter0 Compare Match A
23 | $002C | TIMER0 | COMPB Timer/Counter0 Compare match B
24 | $002E | TIMER0 | OVF Timer/Counter0 Overflow
25 | $0030 | SPI | (STC) SPI Serial Transfer Complete
26 | $0032 | USART1 | RX USART1 Rx Complete
27 | $0034 | USART1 | UDRE USART1 Data Register Empty
28 | $0036 | USART1TX | USART1 Tx Complete
29 | $0038 | ANALOG | COMP Analog Comparator
30 | $003A | ADC | ADC Conversion Complete
31 | $003C | EE | READY EEPROM Ready
32 | $003E | TIMER3 CAPT | Timer/Counter3 Capture Event
33 | $0040 | TIMER3 COMPA | Timer/Counter3 Compare Match A
34 | $0042 | TIMER3 COMPB | Timer/Counter3 Compare Match B
35 | $0044 | TIMER3 COMPC | Timer/Counter3 Compare Match C
36 | $0046 | TIMER3 OVF | Timer/Counter3 Overflow
37 | $0048 | TWI | 2-wire Serial Interface
38 | $004A | SPM | READY Store Program Memory Ready
39 | $004C | TIMER4 COMPA | Timer/Counter4 Compare Match A
40 | $004E | TIMER4 COMPB | Timer/Counter4 Compare Match B
41 | $0050 | TIMER4 COMPD | Timer/Counter4 Compare Match D
42 | $0052 | TIMER4 OVF | Timer/Counter4 Overflow
43 | $0054 | TIMER4 FPF | Timer/Counter4 Fault Protection Interrupt

## MCU Control Register – MCUCR
```c
    // MCU Control Register
    MCUCR   =   (0<<JTD)    |   // Bits 7 – JTD: JTAG Interface Disable
                (0<<PUD)    |   // Bit 4 – PUD: Pull-up Disable
                (0<<IVSEL)  |   // Bit 1 – IVSEL: Interrupt Vector Select
                (0<<IVCE);      // Bit 0 – IVCE: Interrupt Vector Change Enable
```


## External Interrupts
> The External Interrupts are triggered by the INT6, INT3:0 pin or any of the PCINT7..0 pins.  Observe that, if enabled, the interrupts will trigger even if the INT[6;3:0] or PCINT7..0 pins are configured as outputs. This feature provides a way of generating a software interrupt.
> The Pin change interrupt PCI0 will trigger if any enabled PCINT7:0 pin toggles. PCMSK0 Register control which pins contribute to the pin change interrupts. Pin change interrupts on PCINT7..0 are detected asynchronously. This implies that these interrupts can be used for waking the part also from sleep modes other than Idle mode.

```c
    // External Interrupt Control Register A
    // Bits 7..0 – ISC31, ISC30 – ISC00, ISC00: External Interrupt 3 - 0 Sense Control Bits
    EICRA   =   (0<<ISC31)  |   // Bit - 7 Interrupt Sense Control 3
                (0<<ISC30)  |   // Bit - 6 ...
                (0<<ISC21)  |   // Bit - 5 Interrupt Sense Control 2
                (0<<ISC20)  |   // Bit - 4 ...
                (0<<ISC11)  |   // Bit - 3 Interrupt Sense Control 1
                (0<<ISC10)  |   // Bit - 2 ...
                (0<<ISC01)  |   // Bit - 1 Interrupt Sense Control 0
                (0<<ISC00);     // Bit - 0 ...

    // External Interrupt Control Register B
    // Bits 5, 4 – ISC61, ISC60: External Interrupt 6 Sense Control Bits
    EICRB   =   (0<<ISC61)  |
                (0<<ISC60);

    // External Interrupt Mask Register
    // Bits 6,3:0 – INT6, INT3 – INT0: External Interrupt Request 6, 3 - 0 Enable
    EIMSK   =   (0<<INT6)   |   // Bit 6 - INT6: 
                (0<<INT3)   |   // Bit 3 - INT3
                (0<<INT2)   |   // Bit 2 - INT2
                (0<<INT1)   |   // Bit 1 - INT1
                (0<<IINT0);     // Bit 0 - INT0

    // External Interrupt Flag Register
    EIFR    =   (0<<INTF6)  |   // Bit 6 - INTF6
                (0<<INTF3)  |   // Bit 3 - INTF3
                (0<<INTF2)  |   // Bit 2 - INTF2
                (0<<INTF1)  |   // Bit 1 - INTF1
                (0<<IINTF0);    // Bit 6 - INTF0
    
    // Pin Change Interrupt Control Register
    PCICR   =   (0<<PCIE0);     // Bit 0 – PCIE0: Pin Change Interrupt Enable 0
    
    // Pin Change Interrupt Flag Register
    PCIFR   =   (0<<PCIF0);     // Bit 0 – PCIF0: Pin Change Interrupt Flag 0

    // Pin Change Mask Register 0
    // Bit 7..0 – PCINT7..0: Pin Change Enable Mask 7..0
    PCMSK0  =   (0<<PCINT7) |
                (0<<PCINT6) |
                (0<<PCINT5) |
                (0<<PCINT4) |
                (0<<PCINT3) |
                (0<<PCINT2) |
                (0<<PCINT1) |
                (0<<PCINT0);
    
```


## Power Reduction Register
The Power Reduction Register, PRR, provides a method to stop the clock to individual peripher-als to reduce power consumption. The current state of the peripheral is frozen and the I/O registers can not be read or written. Resources used by the peripheral when stopping the clock will remain occupied, hence the peripheral should in most cases be disabled before stopping the clock. Waking up a module, which is done by clearing the bit in PRR, puts the module in the same state as before shutdown.

```c
    // Power Reduction Register 0
    PRR0    =   (0<<PRTWI)  |   // Bit 7 - PRTWI: TWI
                (0<<PRTIM2) |   // Bit 6 - Res: Reserved bit
                (0<<PRTIM0) |   // Bit 5 - PRTIM0: Timer/Counter0
                (0<<PRTIM1) |   // Bit 3 - PRTIM1: Timer/Counter1
                (0<<PRSPI)  |   // Bit 2 - PRSPI: SPI
                (0<<PRADC);     // Bit 0 - PRADC: PADC

    // Power Reduction Register 1
    PRR1    =   (0<<PRUSB)  |   // Bit 7 - PRUSB: USB
                (0<<PRTIM4) |   // Bit 4- PRTIM4: Timer/Counter4
                (0<<PRTIM3) |   // Bit 3 - PRTIM3: Timer/Counter3
                (0<<PRUSART1);  // Bit 0 - PRUSART1: USART1
```



# Hardware

## EEPROM Data Memory
> The ATmega16U4/ATmega32U4 contains 512Bytes/1K bytes of data EEPROM memory. It is organized as a separate data space, in which single bytes can be read and written. The EEPROM has an endurance of at least 100,000 write/erase cycles.

```c
    // The EEPROM Address Register
    // // Bits 11..0 – EEAR8..0: EEPROM Address
    EEARH   =   0;
    EEARL   =   0;

    // The EEPROM Data Register
    EEDR    =   0;

    // The EEPROM Control Register
    EECR    =   (0<<EEPM1)  |   // Bit 5 – EEPM1: EEPROM Prog. Mode
                (0<<EEPM0)  |   // Bit 4 – EEPM0: EEPROM Prog. Mode
                (0<<EERIE)  |   // Bit 3 – EERIE: EEPROM Ready Interrupt Enable
                (0<<EEMPE)  |   // Bit 2 – EEMPE: EEPROM Master Prog. Enable
                (0<<EEPE)   |   // Bit 1 – EEPE: EEPROM Prog. Enable
                (0<<EERE);      // Bit 0 – EERE: EEPROM Read Enable
```


## Watchdog

```c
    // Watchdog Timer Control Register
    WDTCSR  =   (0<<WDIF)   |   // Bit 7 - WDIF: Watchdog Interrupt Flag
                (0<<WDIE)   |   // Bit 6 - WDIE: Watchdog Interrupt Enable
                (0<<WDP3)   |   // Bit 5 - WDP3: Watchdog Timer Prescaler 3
                (0<<WDCE)   |   // Bit 4 - WDCE: Watchdog Change Enable
                (0<<WDE)    |   // Bit 3 - WDE: Watchdog System Reset Enable
                (0<<WDP2)   |   // Bit 2 - WDP2: Watchdog Timer 2
                (0<<WDP1)   |   // Bit 1 - WDP1: Watchdog Timer 1
                (0<<WDP0);      // Bit 0 - WDP0: Watchdog Timer 0
```


## External Interrupts
> 

## Timer0 Settings
> Timer/Counter0 is a general purpose 8-bit Timer/Counter module, with two independent Output Compare Units, and with PWM support. It allows accurate program execution timing (event management) and wave generation.

```c
    // Timer/Counter Control Register A
    TCCR0A  =   (0<<COM0A)  |
                (0<<COM0A)  |
                (0<<COM0B)  |
                (0<<COM0B)  |
                (0<<WGM0)   |
                (0<<WGM0);

    // Timer/Counter Control Register B
    TCCR0B  =   (0<<FOC0A)  |
                (0<<FOC0B)  |
                (0<<WGM02)  |
                (0<<CS02)   |
                (0<<CS01)   |
                (0<<CS00);

    // Timer/Counter Register
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


## Analog to Digital Converter - ADC
> The ATmega16U4/ATmega32U4 features a 10-bit successive approximation ADC. The ADC is connected to an 12-channel Analog Multiplexer which allows six single-ended voltage inputs constructed from several pins of Port B, D and F. The single-ended voltage inputs refer to 0V (GND).

```c
    // ADC Multiplexer Selection Register
    ADMUX   =   (0<<REFS1)  |   // Bit 7:6 – REFS1:0: Reference Selection Bits
                (0<<REFS0)  |   // ...
                (0<<ADLAR)  |   // Bit 5 – ADLAR: ADC Left Adjust Result
                (0<<MUX4)   |   // Bits 4:0 – MUX4:0: Analog Channel Selection
                (0<<MUX3)   |   // ...
                (0<<MUX2)   |   // ...
                (0<<MUX1)   |   // ...
                (0<<MUX0);      // ...

    // ADC Control and Status Register A
    ADCSRA  =   (0<<ADEN)   |   // Bit 7 – ADEN: ADC Enable
                (0<<ADSC)   |   // Bit 6 – ADSC: ADC Start Conversion
                (0<<ADATE)  |   // Bit 5 – ADATE: ADC Auto Trigger Enable
                (0<<ADIF)   |   // Bit 4 – ADIF: ADC Interrupt Flag
                (0<<ADIE)   |   // Bit 3 – ADIE: ADC Interrupt Enable
                (0<<ADPS2)  |   // Bits 2:0 – ADPS2:0: ADC Prescaler Select
                (0<<ADPS1)  |   // ...
                (0<<ADPS0);     // ...

    // ADC Control and Status Register B
    ADCSRB  =   (0<<ADHSM)  |   // Bit 7 – ADHSM: ADC High Speed Mode
                (0<<ACME)   |   // Bit 6 – ACME: Analog Comparator Mux Enable
                (0<<MUX5)   |   // Bit 5 – MUX5: Analog Channel Selection
                (0<<ADTS3)  |   // Bit 3:0 – ADTS3:0: ADC Auto Trigger Source
                (0<<ADTS2)  |   // ...
                (0<<ADTS1)  |   // ...
                (0<<ADTS0);     // ...
    
    // Digital Input Disable Register 0
    // Bit 7:4, 1:0 – ADC1:0 Digital Input Disable
    DIDR0   =   (0<<ADC7D)  |   // Bit 7
                (0<<ADC6D)  |   // Bit 6
                (0<<ADC5D)  |   // Bit 5
                (0<<ADC4D)  |   // Bit 4
                (0<<ADC1D)  |   // Bit 1
                (0<<ADC0D);     // Bit 0
    
    // Digital Input Disable Register 2
    // Bit 5:0 – Digital Input Disable
    DIDR2   =   (0<<ADC13D) |   // Bit 5
                (0<<ADC12D) |   // Bit 4
                (0<<ADC11D) |   // Bit 3
                (0<<ADC10D) |   // Bit 2
                (0<<ADC9D) |    // Bit 1
                (0<<ADC8D);     // Bit 0
```

*Note: When an ADC conversion is complete, the result is found in these two registers. If differential channels are used, the result is presented in two’s complement form.  When ADCL is read, the ADC Data Register is not updated until ADCH is read. Consequently, if the result is left adjusted and no more than 8-bit precision (7 bit + sign bit for differential input channels) is required, it is sufficient to read ADCH. Otherwise, ADCL must be read first, then ADCH. The ADLAR bit in ADMUX, and the MUXn bits in ADMUX affect the way the result is read from the registers. If ADLAR is set, the result is left adjusted. If ADLAR is cleared (default), the result is right adjusted.*

## Analog Comparator- AC
> The Analog Comparator compares the input values on the positive pin AIN+ and negative pin AIN-. When the voltage on the positive pin AIN+ is higher than the voltage on the negative pin AIN-, the Analog Comparator output, ACO, is set.

```c
    // ADC Control and Status Register B
    // Bit 6 – ACME: Analog Comparator Multiplexer Enable
    ADCSRB  =   (0<<ACME);

    // Analog Comparator Control and Status Register
    ACSR    =   (0<<ACD)    |   // Bit 7 – ACD: Disable
                (0<<ACBG)   |   // Bit 6 – ACBG: Bandgap Select
                (0<<ACO)    |   // Bit 5 – ACO: Analog Comparator Output
                (0<<ACI)    |   // Bit 4 – ACI: Interrupt Flag
                (0<<ACIE)   |   // Bit 3 – ACIE: Interrupt Enable
                (0<<ACIC)   |   // Bit 2 – ACIC: Input Capture Enable
                (0<<ACIS1)  |   // Bit 1 - ACIS1: Interrupt Mode Select
                (0<<ACIS0);     // Bit 0 - ACIS0: Interrupt Mode Select

    // Digital Input Disable Register 1
    DIDR1   =   (0<<AIN0D);     // Bit 0 – AIN0D: AIN0 Digital Input Disable
```

