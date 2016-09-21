#include <LiquidCrystal.h>
int y1 = A0;
int x2 = A1;
int y2 = A2;
int x1 = A3;
int place;
int x, y;
LiquidCrystal lcd(37, 36, 35, 34, 33, 32);

void setup() 
{
  lcd.begin(16,2);
} 

int readX(){
  pinMode(y1, INPUT);
  pinMode(x2, OUTPUT);
  pinMode(y2, INPUT);
  pinMode(x1, OUTPUT);

  digitalWrite(x2, LOW);
  digitalWrite(x1, HIGH);

  delay(5); //pause to allow lines to power up

  return analogRead(y1);
}

int readY(){

  pinMode(y1, OUTPUT);
  pinMode(x2, INPUT);
  pinMode(y2, OUTPUT);
  pinMode(x1, INPUT);

  digitalWrite(y1, LOW);
  digitalWrite(y2, HIGH);

  delay(5); //pause to allow lines to power up

  return analogRead(x2);
}

void loop()
{
  x = readX();
  y = readY();
  lcd.clear();
  if (x < 1000 & y < 1000)
  {
    placement();
    lcd.print(place);
  }
  delay(100); //just to slow this down so it is earier to read in the terminal - Remove if wanted
}

void placement()
{
  if (y>0 && y<377 && x>0 && x<367)
  {
    place = 3; 
  }
  else if (y>377 && y<624 && x>0 && x<367)
  {
    place = 6;
  }
  else if (y>624 && y<871 && x>0 && x<367)
  {
    place = 9;
  }
  
  
  else if (y>0 && y<377 && x>367 && x<634)
  {
    place = 2;
  }
  else if (y>377 && y<624 && x>367 && x<634)
  {
    place = 5;
  }
  else if (y>624 && y<871 && x>367 && x<634)
  {
    place = 8;
  }
  
  
  else if (y>0 && y<377 && x>634 && x<901)
  {
    place = 1;
  }
  else if (y>377 && y<624 && x>634 && x<901)
  {
    place = 4;
  }
  else if (y>624 && y<871 && x>634 && x<901)
  {
    place = 7;
  }
}
  
