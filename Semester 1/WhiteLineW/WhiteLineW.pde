#include <PololuQTRSensors.h>

#define NUM_SENSORS   8     // number of sensors used
#define TIMEOUT       2500  // waits for 2500 us for sensor outputs to go low
#define EMITTER_PIN   2     // emitter is controlled by digital pin 2
int pin;

PololuQTRSensorsRC qtrrc((unsigned char[]) {3, 4, 5, 6, 7, 8, 9, 10},
  NUM_SENSORS, TIMEOUT, EMITTER_PIN); 
unsigned int sensorValues[NUM_SENSORS];


void setup()
{
  Serial.begin(9600);
  int i;
  for (i = 0; i < 400; i++)  // make the calibration take about 10 seconds
  {
    qtrrc.calibrate();       // reads all sensors 10 times at 2500 us per read (i.e. ~25 ms per call)
  }
}


void loop()
{
  white_top_sensor();
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
  Serial.println(position_bottom);
}
