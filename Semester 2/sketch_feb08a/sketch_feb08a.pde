#include <Servo.h>
Servo spin;
void setup()
{
  spin.attach(11);
  spin.write(99);
}
void loop()
{
}
