#include <Servo.h>
#include <LiquidCrystal.h>
const int pingPin = 7;
Servo left, right;
float duration, mm;
LiquidCrystal lcd(12, 11, 0, 1, 2, 13);

void setup() 
{
  lcd.begin(16,2);
  pinMode(pingPin, OUTPUT);
  pinMode(pingPin, INPUT);
}

void loop()
{
  ping();
  motors();
  delay(50);
  lcd.clear();
  lcd.println(mm);
}

long microsecondsToMillimeters(long microseconds)
{
  return (microseconds / 2.9 / 2);
}

void straight()
{
  left.attach(14);
  right.attach(17);
  left.write(180);
  right.write(0);
}

void _right()
{
  right.detach();
}

void _left()
{
  left.detach();
}

void ping()
{
  digitalWrite(pingPin, LOW);
  delayMicroseconds(2);
  digitalWrite(pingPin, HIGH);
  delayMicroseconds(5);
  digitalWrite(pingPin, LOW);
  duration = pulseIn(pingPin, HIGH);
  mm = microsecondsToMillimeters(duration);
}

void motors()
{
  if (mm <= 40)
  {
    _right();
  }
  else 
  {
    straight();
  }
}

