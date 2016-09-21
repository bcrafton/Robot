#include <Wire.h>

void setup() {
  // Setup the I2C interface
  Wire.begin();

  // Setup the serial interface
  Serial.begin(57600);
}

void loop() {
  // Variable  to hold the line sensor data
  byte data;

  // Request 1 byte from the line sensor
  Wire.requestFrom(0x28, 1);

  // Give the sensor time to process the data
  delay(1);

  // Receive data until buffer is empty
  while (Wire.available()) {
    // Receive and store the data
    data = Wire.receive();

    // Print to the serial window as binary
    Serial.println(data, DEC);
  } 

}
