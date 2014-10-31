#---------------- User options --------------------------------
BOARD_TAG    = atmega328
ARDUINO_LIBS = SPI



# Arduino make variables
ARDUINO_DIR   = /usr/share/arduino
ARDMK_DIR     = /usr/share/arduino
AVR_TOOLS_DIR = /usr

#Suppress output of arduino-make variables
ARDUINO_QUIET = true

BUILD_FOLDER = build-$(BOARD_TAG)


#---------------- Chip settings --------------------------------
# Fuses
L_FUSE	= 0xFF
H_FUSE	= 0xDA
E_FUSE	= 0xFD
#E_FUSE	= 0x05


#---------------- Programming Options (avrdude) ----------------

# Programming hardware
# Type: avrdude -c ?
# to get a full listing.
#
AVRDUDE_PROGRAMMER = stk500v2

# com1 = serial port. Use lpt1 to connect to parallel port.
AVRDUDE_PORT = com1    # programmer connected to serial device
AVRDUDE_PORT = /dev/ttyACM0    # programmer connected to serial device

AVRDUDE_WRITE_FLASH = -U flash:w:$(BUILD_FOLDER)/src.hex
#AVRDUDE_WRITE_EEPROM = -U eeprom:w:$(BUILD_FOLDER)/src.eep


# Uncomment the following if you want avrdude's erase cycle counter.
# Note that this counter needs to be initialized first using -Yn,
# see avrdude manual.
#AVRDUDE_ERASE_COUNTER = -y

# Uncomment the following if you do /not/ wish a verification to be
# performed after programming the device.
#AVRDUDE_NO_VERIFY = -V

# Increase verbosity level.  Please use this when submitting bug
# reports about avrdude. See <http://savannah.nongnu.org/projects/avrdude> 
# to submit bug reports.
AVRDUDE_VERBOSE = -v -v

AVRDUDE_FLAGS = -p $(MCU) -P $(AVRDUDE_PORT) -c $(AVRDUDE_PROGRAMMER)
AVRDUDE_FLAGS += $(AVRDUDE_NO_VERIFY)
AVRDUDE_FLAGS += $(AVRDUDE_VERBOSE)
AVRDUDE_FLAGS += $(AVRDUDE_ERASE_COUNTER)


#-------------------------------------------------------------------------------------
# Make steps

# Define messages
MSG_SIZE_BEFORE = Size before: 
MSG_SIZE_AFTER = Size after:


all: sizebefore


# Display size of file.
HEXSIZE = $(SIZE) $(BUILD_FOLDER)/src.hex
ELFSIZE = $(SIZE) --mcu=$(MCU) --format=avr $(BUILD_FOLDER)/src.elf



sizebefore:
	@if test -f $(BUILD_FOLDER)/src.elf; then echo; echo $(MSG_SIZE_BEFORE); $(ELFSIZE); \
	2>/dev/null; echo; fi


sizeafter:
	@if test -f $(TARGET).elf; then echo; echo $(MSG_SIZE_AFTER); $(ELFSIZE); \
	2>/dev/null; echo; fi


# Program the device.  
program: $(BUILD_FOLDER)/src.hex $(BUILD_FOLDER)/src.eep
	$(AVRDUDE) $(AVRDUDE_FLAGS) $(AVRDUDE_WRITE_FLASH) $(AVRDUDE_WRITE_EEPROM)


# Write fuse values
wfuses:
	$(AVRDUDE) $(AVRDUDE_FLAGS) -U lfuse:w:$(L_FUSE):m -U hfuse:w:$(H_FUSE):m -U efuse:w:$(E_FUSE):m


rfuses:
	$(AVRDUDE) $(AVRDUDE_FLAGS) -U hfuse:r:high.txt:h -U lfuse:r:low.txt:h -U efuse:r:ext.txt:h


#Arduino makefile!
include /src/sudar/arduino-makefile/Arduino.mk

