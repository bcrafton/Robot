#include <PololuQTRSensors.h>

#define NUM_SENSORS   8     // number of sensors used
#define TIMEOUT       2500  // waits for 2500 us for sensor outputs to go low
#define EMITTER_PIN   2     // emitter is controlled by digital pin 2

double position_top;


PololuQTRSensorsRC qtrrc((unsigned char[]) {3, 4, 5, 6, 7, 8, 9, 10},
  NUM_SENSORS, TIMEOUT, EMITTER_PIN); 
unsigned int sensorValues[NUM_SENSORS], numeratorValues[NUM_SENSORS], TNV, TDV;


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
  unsigned int position = qtrrc.readLine(sensorValues);
  unsigned char i;
  int intel = 0;
  Serial.println();
  for (i = 0; i < NUM_SENSORS; i++)
  {
    sensorValues[i]=(1000-sensorValues[i])/101;
    if (sensorValues[i]<7)
    {
      sensorValues[i]  = 0;
    }
  }
  for (i = 0; i < NUM_SENSORS; i++)
  {
    numeratorValues[i] = sensorValues[i]*(i*1000);
  }
  TNV = numeratorValues[0] + numeratorValues[1] + numeratorValues[2] + numeratorValues[3] + numeratorValues[4] + numeratorValues[5] + numeratorValues[6] + numeratorValues[7];
  TDV = sensorValues[0] + sensorValues[1] + sensorValues[2] + sensorValues[3] + sensorValues[4] + sensorValues[5] + sensorValues[6] + sensorValues[7];
  position_top = (TNV/TDV);
  Serial.println(position_top);
  delay(1000);
}
