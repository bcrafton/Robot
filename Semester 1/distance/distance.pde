const int pingPin = 53;

void setup() 
{
  Serial.begin(9600);
}

void loop()
{
  float duration, mm;
  pinMode(pingPin, OUTPUT);
  digitalWrite(pingPin, LOW);
  delayMicroseconds(2);
  digitalWrite(pingPin, HIGH);
  delayMicroseconds(5);
  digitalWrite(pingPin, LOW);
  
  pinMode(pingPin, INPUT);
  duration = pulseIn(pingPin, HIGH);

  mm = microsecondsToMillimeters(duration);

  Serial.print(mm);
  Serial.print("mm");
  Serial.println();
  
  delay(100);
}

long microsecondsToMillimeters(long microseconds)
{
  return (microseconds / 2.9 / 2);
}
