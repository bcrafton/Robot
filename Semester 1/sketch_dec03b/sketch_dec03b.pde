#include <PololuQTRSensors.h>

#define NUM_SENSORS   8     // number of sensors used
#define TIMEOUT       2500  // waits for 2500 us for sensor outputs to go low
#define EMITTER_PIN   2     // emitter is controlled by digital pin 2

PololuQTRSensorsRC qtrrc((unsigned char[]) {3, 4, 5, 6, 7, 8, 9, 10},
  NUM_SENSORS, TIMEOUT, EMITTER_PIN); 
unsigned int sensorValues[NUM_SENSORS], numeratorValues[NUM_SENSORS];

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
  unsigned int position = qtrrc.readLine(sensorValues);
  unsigned char i;
  for (i = 0; i < NUM_SENSORS; i++)
  {
    sensorValues[i]=((1000-sensorValues[i])/101);
    Serial.print(sensorValues[i]);
  }
  Serial.println();
  
  for (i = 0; i < NUM_SENSORS; i++)
  {
    numeratorValues[i] = sensorValues[i]*(i*1000);
  }
  Serial.println();
  
  delay(1000);
}
  
