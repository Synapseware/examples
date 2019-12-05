#include <ESP8266WiFiGeneric.h>
#include <WiFiClientSecureAxTLS.h>
#include <WiFiServerSecureBearSSL.h>
#include <BearSSLHelpers.h>
#include <ESP8266WiFi.h>
#include <ESP8266WiFiSTA.h>
#include <ESP8266WiFiAP.h>
#include <WiFiServerSecureAxTLS.h>
#include <WiFiClient.h>
#include <ESP8266WiFiType.h>
#include <ESP8266WiFiMulti.h>
#include <WiFiClientSecure.h>
#include <WiFiServer.h>
#include <ESP8266WiFiScan.h>
#include <WiFiClientSecureBearSSL.h>
#include <CertStoreBearSSL.h>
#include <WiFiServerSecure.h>
#include <WiFiUdp.h>

#include <DallasTemperature.h>

#include <OneWire.h>

#include <dummy.h>

/*
  Blink
*/

// ledPin refers to ESP32 GPIO 23
const int ledPin = 16;

// the setup function runs once when you press reset or power the board
void setup() {
  // initialize digital pin ledPin as an output.
  pinMode(ledPin, OUTPUT);
}

// the loop function runs over and over again forever
void loop() {
  digitalWrite(ledPin, HIGH);   // turn the LED on (HIGH is the voltage level)
  delay(1000);                  // wait for a second
  digitalWrite(ledPin, LOW);    // turn the LED off by making the voltage LOW
  delay(1000);                  // wait for a second
}
