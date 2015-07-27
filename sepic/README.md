SMPS Example
============
This example project uses an ATTiny85 to drive at 250kHz PWM signal.  The PWM output is usually fed into a MOSFET which is driving either a buck, boost or inverting SMPS circuit.  Other variants of the ATTiny85 (such as the attiny25 or attiny85v) should substitute out with little effort.

*This circuit attempts to do in firmware what an off-the-shelf driver can accomplish, but with fewer parts and software configurability.*

# ADC Input
The ADC is configured for free-running mode.  The input to the ADC should pass through an RC filter or an RLC filter for improved noise immunity.

## Input Pin
The ADC is configured to read from PB4.

## ADC Sense Line
The input to the ADC should be constrained to 0.0v through 1.1v.  This gives the most accuracy on the ADC and allows for a small load/sense resistor.

# PWM Output
Timer1 is used in a Fast-PWM configuration with the 64mHz PLL clock.  This allows for a maximum of 250kHz switching frequency.  Relatively low by today's standards but very workable on a proto board or hand-made board.

## PWM Output Pin
The PWM output is available on PB1.  The output should not be filtered since it must be fed to the SMPS switching element.  Care should be taken to keep this line short and include an appropriately sized pull-down/pull-up resistor to ensure safe operation of the power MOSFET or other switching transistor.

# Other Chip Information
The AVR uC is configured to use it's internal R/C oscillator.  High clock accuracy is not needed by this circuit and keeping the part count low is a goal of this example.


# Build
This project compiles and uploads just fine using Linux and avr-gnu.
