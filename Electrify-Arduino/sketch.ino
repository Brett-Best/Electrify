#include <Arduino.h>
#include <Wire.h>

extern HardwareSerial Serial;

#define SLAVE_ADDRESS 0x04
#define UPDATE_FREQUENCY 500

int lumens;
 
void setup() {
  Serial.begin(9600);
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);

  Wire.begin(SLAVE_ADDRESS);
  Wire.onRequest(sendLumens);
}
 
void loop() {
  delay(UPDATE_FREQUENCY);
  lumens = analogRead(A0);
}
 
void sendLumens(){
  uint8_t lumensBytes[2] = {lumens & 0xFF, (lumens >> 8) & 0xFF};
  Wire.write(lumensBytes, 2);
}