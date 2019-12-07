/*
Example of using an ESP-01 512k module to connect to the internet and blink an LED

Yay!  Dual-core LED blinker!
*/

#include <WiFiServer.h>
#include <BearSSLHelpers.h>
#include <ESP8266WiFiScan.h>
#include <ESP8266WiFiType.h>
#include <ESP8266WiFi.h>
#include <WiFiClientSecure.h>
#include <ESP8266WiFiGeneric.h>
#include <WiFiServerSecureBearSSL.h>
#include <WiFiClientSecureAxTLS.h>
#include <WiFiServerSecureAxTLS.h>
#include <ESP8266WiFiSTA.h>
#include <WiFiClient.h>
#include <WiFiClientSecureBearSSL.h>
#include <CertStoreBearSSL.h>
#include <WiFiServerSecure.h>
#include <WiFiUdp.h>
#include <ESP8266WiFiAP.h>
#include <ESP8266WiFiMulti.h>



char msg[256];



void setup()
{
	pinMode(2, OUTPUT);
	digitalWrite(2, LOW);

	Serial.begin(115200);
	Serial.println();
	Serial.println();
	Serial.print(F("Connecting to access point"));

	WiFi.begin("dacrib", "ThisIsSparta");

	while (WiFi.status() != WL_CONNECTED)
	{
		delay(500);
		Serial.print(F("."));
	}
	Serial.println(F("connected."));
	Serial.println();
}

void loop() 
{
	digitalWrite(2, HIGH);
	delay(100);
	digitalWrite(2, LOW);
	delay(800);
}
