#include <PololuQTRSensors.h>
#include <LiquidCrystal.h>
#include <Wire.h>
#include <Servo.h>

#define NUM_SENSORS   8     // number of sensors used
#define TIMEOUT       2500  // waits for 2500 us for sensor outputs to go low
#define EMITTER_PIN   2     // emitter is controlled by digital pin 2
#define min_val       7     // minimum value for white line

PololuQTRSensorsRC qtrrc((unsigned char[]) {3, 4, 5, 6, 7, 8, 9, 10},
  NUM_SENSORS, TIMEOUT, EMITTER_PIN); 
unsigned int sensorValues[NUM_SENSORS], numeratorValues[NUM_SENSORS];
LiquidCrystal lcd(12, 11, 0, 1, 2, 13);

float verify_left, verify_right, position_top, position_bottom, horizontal_Difference, TNV, TDV, angle, degrees_per_second;
byte data;
int info, time;
Servo left, right;
int button_1=16, read_1;
boolean follow_line=false;
boolean white=false, black=false;

void setup()
{
  start();
  lcd_commands();
  degree_per_second();
  calibration();
}

void loop()
{
  sensors();
  find_angle();
  lcd_handle();
  motor();
}

void start()
{
  Wire.begin();
  lcd.begin(16,2);
  pinMode(button_1, INPUT);
}

void white_top_sensor()
{
  unsigned int position = qtrrc.readLine(sensorValues);
  unsigned char i;
  for (i = 0; i < NUM_SENSORS; i++)
  {
    sensorValues[i]=(1000-sensorValues[i])/101;
    verify_left = sensorValues[0];
    verify_right = sensorValues[7];
    if (sensorValues[i]<min_val)
    {
      sensorValues[i] = 0;
    }
    numeratorValues[i] = sensorValues[i]*(i*100);
  }
  TNV = (numeratorValues[0] + numeratorValues[1] + numeratorValues[2] + numeratorValues[3] + numeratorValues[4] + numeratorValues[5] + numeratorValues[6] + numeratorValues[7]);
  TDV = (sensorValues[0] + sensorValues[1] + sensorValues[2] + sensorValues[3] + sensorValues[4] + sensorValues[5] + sensorValues[6] + sensorValues[7]);
  position_top = (TNV/TDV);
  
  if (verify_left==0 && position_top==0)
  {
    position_top = 0;
  }
  else if (verify_right==0 && position_top==7000)
  {
    position_top = 0;
  }
  else 
  {
    position_top = ((position_top/700)*6.65)+1.43;
  }
}

void white_bottom_sensor()
{
  value();
  switch(info)
  {
    //1hit
    case 15:
    position_bottom = 2.51; //97
    break;
    case 23:
    position_bottom = 3.79; //98
    break;
    case 27:
    position_bottom = 5.06; //100
    break;
    case 29: 
    position_bottom = 6.34; //104
    break;
    case 30:
    position_bottom = 7.61; //112
    
    //2hits
    
    case 7:
    position_bottom = 3.15; //99
    break;
    case 19:
    position_bottom = 4.43;//102
    break;
    case 25:
    position_bottom = 5.70; //108
    break;
    case 28:
    position_bottom = 6.98; //120
    break;
    
    
    //3hits
    
    
    case 3:
    position_bottom = 3.79;
    break;
    case 17:
    position_bottom = 5.06;
    break;
    case 24:
    position_bottom = 6.34;
    break;
    
    case 0:
    left.detach();
    right.detach();
    lcd.clear();
    lcd.print("END");
    delay(25000);
  }
}
void find_angle()
{ 
  horizontal_Difference = position_bottom - position_top;
  angle = (atan(8.8/abs(horizontal_Difference))*57.3);
  angle = 90-angle;
  time = ((angle/degrees_per_second)*1000); 
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

void leftit()
{
  left.attach(14);
  left.write(180);
  right.detach();
  delay(time);
}
void rightit()
{
  right.attach(17);
  right.write(0);
  left.detach();
  delay(time);
}
void forwards()
{
  left.attach(14);
  left.write(180);
}
void backwards()
{
  left.attach(14);
  left.write(0);
}
void straight()
{
  left.attach(14);
  right.attach(17);
  left.write(180);
  right.write(0);
}
void motor()
{
  if ((horizontal_Difference<0)  &&  angle>7)
  {
    leftit();
  }
  else if ((horizontal_Difference>0)  &&  angle>7)
  {
    rightit();
  } 
  else 
  {
    straight();
  }
}
void calibration()
{
  lcd.clear();
  lcd.println("Calibrating");
  int j;
  for (j=0;j<400;j++)
  {
    switch(j)
    {
      case 1:
      forwards();
      break;
      case 51:
      backwards();
      break;
      case 151:
      forwards();
      break;
      case 251:
      backwards();
      break;
      case 271:
      left.detach();
      break;
    }
    qtrrc.calibrate();
    value();
    lcd.setCursor(0, 1);
    lcd.println(info);
  }
  left.detach();
}

void lcd_commands()
{
  lcd.println("Line Follow?");
  do 
  {
    button_read();
    if (read_1==1)
    {
      follow_line=true;
    }
  }
  while (follow_line==false);
  delay(250);
  lcd.clear();
  lcd.println("White?, wait 5");
  lcd.setCursor(0, 1);
  lcd.println("seconds if black");
  do
  {
    int i;
    i++;
    delay(1);
    button_read();
    if (read_1==1)
    {
      white=true;
    }
    else if (i==5000)
    {
      black=true;
    }
  }
  while (black==false && white==false);
}

void button_read()
{
  read_1=0;
  if (digitalRead(button_1)==HIGH)
  {
    read_1=1;
  }
  else 
  {
    read_1=0;
  }
}
void lcd_handle()
{
  lcd.clear();
  lcd.print(angle);
  lcd.setCursor(0,1);
  lcd.print(time);
}

void black_top_sensor()
{
  unsigned int position = qtrrc.readLine(sensorValues);
  verify_left = sensorValues[0]*10/1001;
  verify_right = sensorValues[7]*10/1001;
  position_top = (double)position;
  position_top = ((position_top/7000)*6.65)+1.43;
  if (verify_left == 0 && position == 0)
  {
    position_top = 0;
  }
  else if (verify_right == 0 && position == 7000)
  {
    position_top = 0;
  }
}

void black_bottom_sensor()
{
  value();
  switch(info)
  {
    //1hit
    case 16:
    position_bottom = 2.51; //97
    break;
    case 8:
    position_bottom = 3.79; //98
    break;
    case 4:
    position_bottom = 5.06; //100
    break;
    case 2: 
    position_bottom = 6.34; //104
    break;
    case 1:
    position_bottom = 7.61; //112
    
    //2hits
    
    case 24:
    position_bottom = 3.15; //99
    break;
    case 12:
    position_bottom = 4.43;//102
    break;
    case 6:
    position_bottom = 5.70; //108
    break;
    case 3:
    position_bottom = 6.98; //120
    break;
    
    
    //3hits
    
    
    case 28:
    position_bottom = 3.79;
    break;
    case 14:
    position_bottom = 5.06;
    break;
    case 7:
    position_bottom = 6.34;
    break;
  }
}

void sensors()
{
  if (black==true)
  {
    black_top_sensor();
    black_bottom_sensor();
  }
  else if (white==true)
  {
    white_top_sensor();
    white_bottom_sensor();
  }
}


void black_degree_per_second()
{
  lcd.clear();
  lcd.println("Finding DPS");
  int i=0;
  boolean first=false, second=false, third=false;
  do
  {
    value();
    delay(1);
    if (data == 98 || data == 100 || data == 102 || data == 104 || data == 108 || data == 110)
    {
      left.attach(14);
      left.write(180);
      first = true;
    }
  }
  while(first==false);
  delay(5000);
  do
  {
    value();
    delay(1);
    i++;
    if (data == 96)
    {
      second = true;
    }
  }
  while(second==false);
  do
  {
    value();
    delay(1);
    i++;
    if (data == 98 || data == 100 || data == 102 || data == 104 || data == 108 || data == 110)
    {
      third = true;
      left.detach();
    }
  }
  while(third==false);
  i = i+5000;
  degrees_per_second = 360/(i/1000);
  lcd.print(degrees_per_second);
}

void white_degree_per_second()
{
  lcd.clear();
  lcd.println("Finding DPS");
  int i=0;
  boolean first=false, second=false, third=false;
  do
  {
    value();
    delay(1);
    if (data == 125 || data == 123 || data == 121 || data == 119 || data == 111 || data == 110)
    {
      left.attach(14);
      left.write(180);
      first = true;
    }
  }
  while(first==false);
  delay(5000);
  do
  {
    value();
    delay(1);
    i++;
    if (data == 127)
    {
      second = true;
    }
  }
  while(second==false);
  do
  {
    value();
    delay(1);
    i++;
    if (data == 125 || data == 123 || data == 121 || data == 119 || data == 111 || data == 110)
    {
      third = true;
      left.detach();
    }
  }
  while(third==false);
  i = i+5000;
  degrees_per_second = 360/(i/1000);
  lcd.print(degrees_per_second);
}

void degree_per_second()
{
  if (black == true)
  {
    black_degree_per_second();
  }
  else if (white == true)
  {
    white_degree_per_second();
  }
}
