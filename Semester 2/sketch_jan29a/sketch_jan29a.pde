#include <PololuQTRSensors.h>
#include <LiquidCrystal.h>
#include <Wire.h>
#include <Servo.h>
#include <math.h>

#define NUM_SENSORS   8     // number of sensors used
#define TIMEOUT       2500  // waits for 2500 us for sensor outputs to go low
#define EMITTER_PIN   2     // emitter is controlled by digital pin 2
#define min_val       7     // minimum value for white line
#define turn_min      2
#define turn_max      6

PololuQTRSensorsRC qtrrc((unsigned char[]) {45, 44, 43, 42, 41, 40, 39, 38},
  NUM_SENSORS, TIMEOUT, EMITTER_PIN); 
unsigned int sensorValues[NUM_SENSORS], numeratorValues[NUM_SENSORS];
LiquidCrystal lcd(37, 36, 35, 34, 33, 32);

float verify_left, verify_right, position_top, position_bottom, horizontal_Difference, TNV, TDV, angle, degrees_per_second;
float duration, mm;
byte data;
int info, time;
Servo left, right, drop;
int pingPin=53;
int x, y;
boolean follow_line=false, salt_drop_yes=false, salt_drop_no=false, salt_drop=false;
boolean white=false, black=false, express_mode_yes=false, express_mode_no=false;
int y1 = A0;
int x2 = A1;
int y2 = A2;
int x1 = A3;
int place;
int spin;
boolean spin_chosen=false, centered=false;
int thermistor_1=14, thermistor_2=15; 

void setup()
{
  start();
  lcd_commands();
  degree_per_second();
  calibration();
  center();
  lcd_handle();
  express_salt_drop();
}

void loop()
{
  sensors();
  find_angle();
  motor();
  drop_salt();
}

void start()
{
  Wire.begin();
  lcd.begin(16,2);
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
  }
}
void find_angle()
{ 
  horizontal_Difference = position_bottom - position_top;
  if (horizontal_Difference<0)
  {
    if (position_top<turn_min && position_bottom<turn_min)
    {
      position_bottom = 8.08 - position_bottom;
      horizontal_Difference = position_bottom - position_top;
    }
    else if (position_top>turn_max && position_bottom>turn_max)
    {
      position_bottom = 8.08 - position_bottom;
      horizontal_Difference = position_bottom - position_top;
    }
  }
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
  for (j=0;j<252;j++)
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
    }
    qtrrc.calibrate();
  }
}

void center_white()
{
  lcd.clear();
  lcd.println("Centering");
  do 
  {
    value();
    if (data == 123 || data == 121 || data == 115)
    {
      delay(40000/degrees_per_second);
      left.detach();
      centered = true;
    }
  }
  while (centered==false);
}

void center_black()
{
  lcd.clear();
  lcd.println("Centering");
  do 
  {
    value();
    if (data == 100 || data == 102 || data == 108)
    {
      delay(40000/degrees_per_second);
      left.detach();
      centered = true;
    }
  }
  while (centered==false);
}

void center()
{
  if (black == true)
  {
    center_black();
  }
  else if (white == true)
  {
    center_white();
  }
}

void lcd_commands()
{
  lcd.println("Express Mode?");
  do 
  { 
    delay(5);
    touch_screen();
    if (place == 1)
    {
      express_mode_yes = true;
      express_mode_no = false;
    }
    if (place == 2)
    {
      express_mode_yes = false;
      express_mode_no = true;
    }
  }
  while (express_mode_yes==false && express_mode_no==false);
  
  
      
  lcd.println("Line Follow?");
  do 
  {
    touch_screen();
    if (place==1)
    {
      follow_line=true;
    }
  }
  while (follow_line==false && express_mode_yes == false);
  
  
  lcd.clear();
  lcd.println("White = 1");
  lcd.setCursor(0, 1);
  lcd.println("Black = 2");
  delay(500);
  
  do
  {
    touch_screen();
    if (place==1)
    {
      white=true;
    }
    if (place==2)
    {
      black=true;
    }
  }
  while (black==false && white==false);
  
  
  if (express_mode_no == true)
  {
    lcd.clear();
    lcd.println("Drop Salt?");
    delay(500);
    do 
    {
      touch_screen();
      if (place==1)
      {
        salt_drop_yes=true;
      }
      if (place==2)
      {
        salt_drop_no=true;
      }
    }
  while (salt_drop_yes==false && salt_drop_no==false);
  }
  if (salt_drop_yes==true && express_mode_yes == false)
  {
    lcd.clear();
    lcd.print("Slow Medium Fast");
    lcd.setCursor(0,1);
    lcd.print("1,2,3");
    delay(500);
    
    do 
    {
      touch_screen();
      if (place==1)
      {
        spin = 97;
        spin_chosen = true;
      }
      else if (place==2)
      {
        spin = 99;
        spin_chosen = true;
      }
      else if (place==3)
      {
        spin = 180;
        spin_chosen = true;
      }
    }
    while (spin_chosen==false);
  }
  if (express_mode_yes == true)
  {
    int i; 
    for (i=0; i<100; i++)
    {
      analogRead(14);
      analogRead(15);
      delay(5);
    }
    thermistor_read();
  }
}

void lcd_handle()
{
  lcd.clear();
  lcd.println("Completing Task");
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
    if (data == 125 || data == 123 || data == 121 || data == 119 || data == 115 || data == 113)
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
    if (data == 125 || data == 123 || data == 121 || data == 119 || data == 115 || data == 113)
    {
      third = true;
      left.detach();
    }
  }
  while(third==false);
  i = i+5000;
  degrees_per_second = 360/(i/1000);
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

int readX()
{
  pinMode(y1, INPUT);
  pinMode(x2, OUTPUT);
  pinMode(y2, INPUT);
  pinMode(x1, OUTPUT);

  digitalWrite(x2, LOW);
  digitalWrite(x1, HIGH);

  delay(5); //pause to allow lines to power up

  return analogRead(y1);
}

int readY()
{
  pinMode(y1, OUTPUT);
  pinMode(x2, INPUT);
  pinMode(y2, OUTPUT);
  pinMode(x1, INPUT);

  digitalWrite(y1, LOW);
  digitalWrite(y2, HIGH);

  delay(5); //pause to allow lines to power up

  return analogRead(x2);
}



void touch_screen()
{
  place = 0;
  
  y = readY(); 
  x = readX();
  
  if (x<1000 & y<1000)
  {
    placement();
  }
}

void drop_salt()
{
  if (salt_drop_yes==true)
  {
    drop.attach(11);
    drop.write(spin);
  }
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

double Thermister(int RawADC) 
{
 double Temp;
 Temp = log(((10240000/RawADC) - 10000));
 Temp = 1 / (0.001129148 + (0.000234125 * Temp) + (0.0000000876741 * Temp * Temp * Temp));
 Temp = Temp - 273.15;            // Convert Kelvin to Celcius
 Temp = (Temp * 9.0)/ 5.0 + 32.0; // Convert Celcius to Fahrenheit
 return Temp;
}

void thermistor_read()
{
  int thermistor_a, thermistor_b;
  float temperature;
  thermistor_a = Thermister(analogRead(14));
  thermistor_b = Thermister(analogRead(15));  
  temperature = (thermistor_a + thermistor_b)/2; 
  if (temperature<=36)
  {
    salt_drop = true; 
  }
}

void express_salt_drop()
{
  if (salt_drop == true)
  {
    drop.write(180);
  }
}
  
  
  
