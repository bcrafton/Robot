#include <math.h>
#include <LiquidCrystal.h>
LiquidCrystal lcd(37, 36, 35, 34, 33, 32);
float temp1, temp2;

double Thermister(int RawADC) 
{
 double Temp;
 Temp = log(((10240000/RawADC) - 10000));
 Temp = 1 / (0.001129148 + (0.000234125 * Temp) + (0.0000000876741 * Temp * Temp * Temp));
 Temp = Temp - 273.15;            // Convert Kelvin to Celcius
 Temp = (Temp * 9.0)/ 5.0 + 32.0; // Convert Celcius to Fahrenheit
 return Temp;
}

void setup() 
{
 lcd.begin(16,2);
}

void loop() 
{
  temperature();
  delay(250);
  lcd.clear();
  lcd.println(temp1);
  lcd.setCursor(0,1);
  lcd.println(temp2);
}

void temperature()
{
  temp1 = Thermister(analogRead(14));
  temp2 = Thermister(analogRead(15));
}
