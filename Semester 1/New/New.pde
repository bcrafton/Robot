#include <LiquidCrystal.h>
#include <PololuQTRSensors.h>
#include <Wire.h>
#include <Servo.h>
#define NUM_SENSORS   8
#define TIMEOUT       2500
#define EMITTER_PIN   QTR_NO_EMITTER_PIN   
double verify_left, verify_right, position_top, position_bottom, horizontal_Difference;
byte data;
int info, pin;
double angle, degrees_per_second;
Servo left,right;
boolean first=true, follow_line=false;
int time;
int button_1=16, button_2=17, read_1, read_2;

LiquidCrystal lcd(12, 11, 0, 1, 2, 13);
PololuQTRSensorsRC qtrrc((unsigned char[]) {3,4,5,6,7,8,9,10}, 
  NUM_SENSORS, TIMEOUT, EMITTER_PIN); 
  unsigned int sensorValues[NUM_SENSORS], numeratorValues[NUM_SENSORS];
  
void setup()
{
  Wire.begin();
  lcd.begin(16,2);
  start();
  lcd_commands();
  degree_per_second();
  calibration();
}
void loop()
{
  delay(1);
  top_sensor();
  bottom_sensor();
  find_angle();
  lcd_handle();
  motor();
}
void bottom_sensor()
{
  Wire.requestFrom(0x28, 1);
  data = Wire.receive();
  info = (int)data;
  info = info - 96;
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
    
    // end 
    case 31:
    lcd.clear();
    lcd.print("END");
    left.detach();
    right.detach();
    delay(25000);
    break; 
  }
}
void top_sensor()
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
void find_angle()
{ 
  horizontal_Difference = position_bottom - position_top;
  angle = (atan(8.8/abs(horizontal_Difference))*57.3);
  angle = 90-angle;
  time = ((angle/degrees_per_second)*1000); 
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
  if (first==true)
  {
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
    }
    left.detach();
    first=false;
  }
}
void start()
{
  left.attach(14);
  right.attach(17);
  left.detach();
  right.detach();
  pinMode(button_1, INPUT);
  pinMode(button_2, INPUT);
}
void lcd_handle()
{
  lcd.clear();
  lcd.print(angle);
  lcd.setCursor(0,1);
  lcd.print(time);
}
void degree_per_second()
{
    lcd.clear();
    lcd.println("Finding DPS");
    double i=0;
    boolean first=false, second=false, third=false;
    do{
    Wire.requestFrom(0x28, 1);
    data = Wire.receive();
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
    do{
    Wire.requestFrom(0x28, 1);
    data = Wire.receive();
    delay(1);
    i++;
    if (data == 96)
    {
      second = true;
    }
    }
    while(second==false);
    do{
    Wire.requestFrom(0x28, 1);
    data = Wire.receive();
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
  while (follow_line=false);
}

void white_top_sensor()
{
  double position_bottom;
  unsigned int position = qtrrc.readLine(sensorValues);
  unsigned char i;
  int intel = 0;
  for (i = 0; i < NUM_SENSORS; i++)
  {
    sensorValues[i]=(1000-sensorValues[i])/101;
  }
  for (i = 0; i < NUM_SENSORS; i++)
  {
    if (intel < sensorValues[i])
    {
      intel = sensorValues[i];
      pin = i;
    }
  }
  switch(pin)
  {
    case 0:
    position_bottom = 1.43;
    break;
    case 1:
    position_bottom = 3.38;
    break;
    case 2:
    position_bottom = 3.33;
    break;
    case 3:
    position_bottom = 4.28;
    break;
    case 4:
    position_bottom = 5.23;
    break;
    case 5:
    position_bottom = 6.18;
    break;
    case 6:
    position_bottom = 7.13;
    break;
    case 7:
    position_bottom = 8.08;
    break;
  }
}

void white_bottom_sensor()
{
  Wire.requestFrom(0x28, 1);
  data = Wire.receive();
  info = (int)data;
  info = info - 96;
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
    
    // end 
    case 31:
    lcd.clear();
    lcd.print("END");
    left.detach();
    right.detach();
    delay(25000);
    break; 
  }
}
