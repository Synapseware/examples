#include "example.h"


void SetupLedTimer(void)
{
	// 
}


void setup(void)
{
	cli();

	SetupLedTimer();

	sei();
}

int main(void)
{
	setup();

	while(1)
	{
		// main loop
	}

	return 0;
}
