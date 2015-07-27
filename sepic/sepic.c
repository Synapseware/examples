#include "sepic.h"

//----------------------------------------------------------------
// Fast PWM on OC1A/PB1
static void initPWM(void)
{
    TCCR1    =  (1<<CTC1)    |
                (1<<PWM1A)   |
                (1<<COM1A1)  |        // enable OC1A
                (0<<COM1A0)  |
                (0<<CS13)    |        // clk/1
                (0<<CS12)    |
                (0<<CS11)    |
                (1<<CS10);

    GTCCR    |= (0<<PWM1B)   |
                (0<<COM1B1)  |
                (0<<COM1B0)  |
                (0<<FOC1B)   |
                (0<<FOC1A)   |
                (0<<PSR1);

    PLLCSR    = (0<<LSM)     |
                (1<<PCKE)    |        // use 64MHz PLL for clock source
                (1<<PLLE)    |
                (0<<PLOCK);

    OCR1C    =    F_MAX-1;            // in this mode, counter restarts on OCR1C
    OCR1A    =    1;                  // PWM value

    DDRB    |=    (1<<PB1);           // enable OC1A I/O
}


//----------------------------------------------------------------
// Setup ADC to read trimpot on ADC2/PB4
static void initADC(void)
{
    ADMUX    =  (0<<REFS1)    |    // internal 1.1v ref
                (1<<REFS0)    |    // ...
                (0<<ADLAR)    |    // Left adjust so we can read ADCH only
                (0<<REFS2)    |    // internal 1.1v ref
                (0<<MUX3)     |    // MUX3:0 = 0010 => ADC2 (PB4)
                (0<<MUX2)     |    // ...
                (1<<MUX1)     |    // ...
                (0<<MUX0);        // ...

    ADCSRA    = (1<<ADEN)     |    // Enable ADC
                (0<<ADSC)     |    // Don't start a conversion just yet
                (1<<ADATE)    |    // Enable auto-triggering
                (1<<ADIF)     |    // Clear any previous interrupt
                (1<<ADIE)     |    // Enable ADC interrupts
                (1<<ADPS2)    |    // Max prescaler for fast CPU clock
                (1<<ADPS1)    |    // ...
                (1<<ADPS0);        // ...

    ADCSRB    = (0<<BIN)      |    // No-bipolar input mode
                (0<<IPR)      |    // don't reverse input polarity
                (0<<ADTS2)    |    // free-running
                (0<<ADTS1)    |    // ...
                (0<<ADTS0);        // ...

    DIDR0    =  (1<<ADC2D);

    DDRB    &=  ~(1<<PB4);
}


//----------------------------------------------------------------
// 
static void init(void)
{
    initPWM();

    initADC();

    sei();
}


//----------------------------------------------------------------
// 
int main(void)
{
    init();

    // start the first conversion
    ADCSRA |= (1<<ADSC);

    while(1)
    {
        // NO-OP
    }

    return 0;
}


//----------------------------------------------------------------
// ADC interrupt complete handler
ISR(ADC_vect)
{
    uint8_t sample    = ADCH;

    uint8_t result = (uint8_t) (sample * SCALE);

    // set bounds
    if (result > MAX)
        result = MAX;
    else if (result < 1)
        result = 1;

    // take ADC reading and set PWM output to that value
    OCR1A = result;
}
