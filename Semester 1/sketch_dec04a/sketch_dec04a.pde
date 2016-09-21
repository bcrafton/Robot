int button_1=13, button_2=12;
int read_1, read_2;
void setup()
{
  Serial.begin(9600);
  pinMode(button_1, INPUT);
  pinMode(button_2, INPUT);
}
void loop()
{
  delay(100);
  button_read();
  Serial.println(read_1);
  Serial.println(read_2);
}


void button_read()
{
  read_1=0;
  read_2=0;
  if (digitalRead(button_1)==HIGH)
  {
    read_1=1;
  }
  else 
  {
    read_1=0;
  }
  if (digitalRead(button_2)==HIGH)
  {
    read_2=1;
  }
  else 
  {
    read_2=0;
  }
}
