#include <Wire.h>
#include <LiquidCrystal.h>
LiquidCrystal lcd(37, 36, 35, 34, 33, 32);
byte data; 
int info; 


void setup()
{
  Wire.begin();
  lcd.begin(16, 2);
}

void loop()
{
  lcd.clear();
  value();
  lcd.println(data, DEC);
  delay(500);
}

void value()
{
  data = 0;
  info = 0;
  Wire.requestFrom(0x28, 1);
  data = Wire.receive();
  info = (int)data;
  info = info - 96;
}
