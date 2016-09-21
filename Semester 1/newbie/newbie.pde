#include <Servo.h>
int green=13;                
int red=12;
int button1=11;
boolean on=false;
Servo left, right;

void setup()
{
  pinMode(green, OUTPUT);      
  pinMode(red, OUTPUT);
  pinMode(button1, INPUT);
}

void loop()
{
  if(digitalRead(button1)== HIGH)
  {
    on = !on;
  }
  if (on==true)
  {
    digitalWrite(green, HIGH);
    digitalWrite(red, LOW);
    start();
  }
  else 
  {
    digitalWrite(green, LOW);
    digitalWrite(red, HIGH);
    terminate();
  }
  delay(333);
}

void start()
{
  left.attach(16);
  right.attach(17);
  left.write(180);
  right.write(0);
}
void terminate()
{
  left.detach();
  right.detach();
}

