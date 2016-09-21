#include <PololuQTRSensors.h>
#include <LiquidCrystal.h>
#include <Wire.h>

#define NUM_SENSORS   8     // number of sensors used
#define TIMEOUT       2500  // waits for 2500 us for sensor outputs to go low
#define EMITTER_PIN   2     // emitter is controlled by digital pin 2
#define min_val       7     // minimum value for white line

PololuQTRSensorsRC qtrrc((unsigned char[]) {3, 4, 5, 6, 7, 8, 9, 10},
  NUM_SENSORS, TIMEOUT, EMITTER_PIN); 
unsigned int sensorValues[NUM_SENSORS], numeratorValues[NUM_SENSORS];
LiquidCrystal lcd(12, 11, 0, 1, 2, 13);

float verify_left, verify_right, position_top, position_bottom, horizontal_Difference, TNV, TDV, angle;
byte data;
int info;
int time;

void setup()
{
  lcd.begin(16, 2);
  Wire.begin();
  lcd.print("calibrating");
  int i;
  for (i = 0; i < 400; i++)  // make the calibration take about 10 seconds
  {
    qtrrc.calibrate();       // reads all sensors 10 times at 2500 us per read (i.e. ~25 ms per call)
  }
}
void loop()
{
  delay(1000);
  lcd.clear();
  white_top_sensor();
  white_bottom_sensor();
  find_angle();
  lcd.println(angle);
}
void white_top_sensor()
{
  unsigned int position = qtrrc.readLine(sensorValues);
  unsigned char i;
  for (i = 0; i < NUM_SENSORS; i++)
  {
    sensorValues[i]=(1000-sensorValues[i])/101;
    if (sensorValues[i]<min_val)
    {
      sensorValues[i] = 0;
    }
    numeratorValues[i] = sensorValues[i]*(i*100);
  }
  TNV = (numeratorValues[0] + numeratorValues[1] + numeratorValues[2] + numeratorValues[3] + numeratorValues[4] + numeratorValues[5] + numeratorValues[6] + numeratorValues[7]);
  TDV = (sensorValues[0] + sensorValues[1] + sensorValues[2] + sensorValues[3] + sensorValues[4] + sensorValues[5] + sensorValues[6] + sensorValues[7]);
  position_top = (TNV/TDV);
  position_top = ((position_top/700)*6.65)+1.43;
  Serial.println(angle);
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
  angle = (atan(8.8/abs(horizontal_Difference))*57.3);
  angle = 90-angle;
  time = ((angle/30)*1000); 
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

