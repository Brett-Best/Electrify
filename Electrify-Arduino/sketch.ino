#include <Arduino.h>
#include <Wire.h>

extern HardwareSerial Serial;

#define SLAVE_ADDRESS 0x04
#define TEMT6000PIN A0
#define AVG_LENGTH 750   // 30 seconds @ 0.04 samples/sec
#define SAMPLE_RATE 0.04 // The sample rate in seconds.

int lumenReadings[AVG_LENGTH];
int readIndex = 0;
unsigned long lumensTotal = 0;
int lumensAverage = 0;

bool averageIsReady = false;

void setup()
{
  Serial.begin(9600);

  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);

  for (int thisReading = 0; thisReading < AVG_LENGTH; thisReading++)
  {
    lumenReadings[thisReading] = 0;
  }

  Wire.begin(SLAVE_ADDRESS);
  Wire.onRequest(sendLumens);
}

void loop()
{
  delay(SAMPLE_RATE * 1000);

  int lumenReading = analogRead(TEMT6000PIN);

  lumensTotal = lumensTotal - lumenReadings[readIndex];
  lumenReadings[readIndex] = lumenReading;
  lumensTotal = lumensTotal + lumenReadings[readIndex];

  readIndex++;

  if (readIndex >= AVG_LENGTH)
  {
    readIndex = 0;
  }

  lumensAverage = max(lumensTotal / AVG_LENGTH, 1); // Lowest lumens value is 1

  Serial.print("Lumen Reading: ");
  Serial.print(lumenReading);
  Serial.print(", ");
  Serial.print("Lumens Average: ");
  Serial.println(lumensAverage);
}

void sendLumens()
{
  uint8_t lumensAverageBytes[2] = {lumensAverage & 0xFF, (lumensAverage >> 8) & 0xFF};
  uint8_t averageNotReadyBytes[2] = { 0x00, 0x00 }; // 0: Averages not ready.

  Wire.write(averageIsReady ? lumensAverageBytes : averageNotReadyBytes, 2);
}