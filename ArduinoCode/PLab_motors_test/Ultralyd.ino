#include <PLab_ZumoMotors.h>
#include <NewPing.h>



PLab_ZumoMotors PLab_motors;
const int echoPin = 6;
const int triggerPin = 5;

NewPing sonar(triggerPin, echoPin, 300);

void setup(){
  Serial.begin(9600);
  pinMode(triggerPin, OUTPUT);
  pinMode(echoPin, INPUT);
}

void loop(){

  unsigned int time = sonar.ping();
  float distance = sonar.convert_cm(time);
  Serial.println(distance);
  delay(100);

}
