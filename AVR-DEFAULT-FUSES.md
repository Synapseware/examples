AVR Default Fuses
=================


## ATTiny85
LFUSE = 0xE2
HFUSE = 0xD7
EFUSE = 0xFF

```bash
avrdude -P /dev/ttyACM0 -c stk500v2 -p attiny85 -e \
    -U lfuse:w:0xE2:m \
    -U hfuse:w:0xD7:m \
    -U efuse:w:0xFF:m
```

### Description
- Internal RC clock @ 8mHz, no divide
- BSOD disabled
- Preserve EEPROM
- SPI programming enabled

## ATTiny84
LFUSE = 0xE2
HFUSE = 0xD7
EFUSE = 0xFF

```bash
avrdude -P /dev/ttyACM0 -c stk500v2 -p attiny84 -e \
    -U lfuse:w:0xE2:m \
    -U hfuse:w:0xD7:m \
    -U efuse:w:0xFF:m
```

### Description
- Internal RC clock @ 8mHz, no divide
- BSOD disabled
- Preserve EEPROM
- SPI programming enabled

## ATMega328P
LFUSE = 0xE2
HFUSE = 0xD1
EFUSE = 0xFF

```bash
avrdude -P /dev/ttyACM0 -c stk500v2 -p atmega328p -e \
    -U lfuse:w:0xE2:m \
    -U hfuse:w:0xD1:m \
    -U efuse:w:0xFF:m
```

#### Description
- Internal RC clock @ 8mHz, no divide
- BSOD disabled
- Preserve EEPROM
- SPI programming enabled
- Boot flash size = 2048


## ATMega168
LFUSE = 0xE2
HFUSE = 0xD7
EFUSE = 0xF9

```bash
avrdude -P /dev/ttyACM0 -c stk500v2 -p atmega168 -e \
    -U lfuse:w:0xE2:m \
    -U hfuse:w:0xD7:m \
    -U efuse:w:0xF9:m
```

#### Description
- Internal RC clock @ 8mHz, no divide
- BSOD disabled
- Preserve EEPROM
- SPI programming enabled
- Boot flash size = 2048

## ATMega88
LFUSE = 0xE2
HFUSE = 0xD7
EFUSE = 0xF9

```bash
avrdude -P /dev/ttyACM0 -c stk500v2 -p atmega88 -e \
    -U lfuse:w:0xE2:m \
    -U hfuse:w:0xD7:m \
    -U efuse:w:0xF9:m
```

#### Description
- Internal RC clock @ 8mHz, no divide
- BSOD disabled
- Preserve EEPROM
- SPI programming enabled
- Boot flash size = 2048

