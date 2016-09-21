#include <PololuQTRSensors.h>
#include <Wire.h>
#include <Servo.h>

#define NUM_SENSORS   8     // number of sensors used
#define TIMEOUT       2500  // waits for 2500 us for sensor outputs to go low
#define EMITTER_PIN   2     // emitter is controlled by digital pin 2

double verify_left, verify_right, position_top, position_bottom, horizontal_Difference;
byte data;
int info;
int pin;
double angle, degrees_per_second;
Servo left,right;
boolean first=true, follow_line=false;
int time;
int button_1=16, button_2=17, read_1, read_2;

PololuQTRSensorsRC qtrrc((unsigned char[]) {3, 4, 5, 6, 7, 8, 9, 10},
  NUM_SENSORS, TIMEOUT, EMITTER_PIN); 
unsigned int sensorValues[NUM_SENSORS];


void setup()
{
  Wire.begin();
  Serial.begin(9600);
  int i;
  for (i = 0; i < 400; i++)  // make the calibration take about 10 seconds
  {
    qtrrc.calibrate();       // reads all sensors 10 times at 2500 us per read (i.e. ~25 ms per call)
  }
}


void loop()
{
  delay(1000);
  white_top_sensor();
  white_bottom_sensor();
  find_angle();
  Serial.println(angle);
}
void white_top_sensor()
{
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
    position_top = 1.43;
    break;
    case 1:
    position_top = 3.38;
    break;
    case 2:
    position_top = 3.33;
    break;
    case 3:
    position_top = 4.28;
    break;
    case 4:
    position_top = 5.23;
    break;
    case 5:
    position_top = 6.18;
    break;
    case 6:
    position_top = 7.13;
    break;
    case 7:
    position_top = 8.08;
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
  }
}
void find_angle()
{ 
  horizontal_Difference = position_bottom - position_top;
  angle = (atan(8.8/abs(horizontal_Difference))*57.3);
  angle = 90-angle;
  time = ((angle/degrees_per_second)*1000); 
}

