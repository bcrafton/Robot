#include <Wire.h>
byte data;
void setup()
{
  Serial.begin(9600);
  Wire.begin();
}
void loop()
{
  Wire.requestFrom(0x28, 1);
  data = Wire.receive();
  Serial.println(data, DEC);
}
