/*
Drive forward and turn left or right when border is detected
  - Only reflectionsensor 0 and 5 are used.
*/
#include <ZumoMotors.h>
#include <Pushbutton.h>
#include <QTRSensors.h>
#include <ZumoReflectanceSensorArray.h>
#include <NewPing.h>

 
#define LED 13
 
// this might need to be tuned for different lighting conditions, surfaces, etc.
#define QTR_THRESHOLD  300 // 
  
// these might need to be tuned for different motor types
#define REVERSE_SPEED     400 // 0 is stopped, 400 is full speed
#define TURN_SPEED        400
#define FORWARD_SPEED     400
#define FORWARD_TURN_MAGNITUDE 38 // Percentage, 0..100, lower is less turn
#define REVERSE_DURATION  200 // ms
#define TURN_DURATION     230 // ms

int left_neg = 0;
int right_neg = 0;

//Ultralyd setup
const int echoPin = 6;
const int triggerPin = 5;
NewPing sonar(triggerPin, echoPin, 300);
 
ZumoMotors motors;
Pushbutton button(ZUMO_BUTTON); // pushbutton on pin 12
 
#define NUM_SENSORS 6
unsigned int sensor_values[NUM_SENSORS];
 
ZumoReflectanceSensorArray sensors;


 
void setup()
{
   sensors.init();
   //button.waitForButton();
}

void loop()
{
  sensors.read(sensor_values);

  if (sensor_values[0] < QTR_THRESHOLD)
  {
    // if leftmost sensor detects line, reverse and turn to the right
    motors.setSpeeds(-REVERSE_SPEED, -REVERSE_SPEED);
    delay(REVERSE_DURATION);
    motors.setSpeeds(TURN_SPEED, -TURN_SPEED);
    delay(TURN_DURATION);
    left_neg = 0;
    right_neg = FORWARD_TURN_MAGNITUDE * FORWARD_SPEED / 100;
  }
  else if (sensor_values[5] <  QTR_THRESHOLD)
  {
    // if rightmost sensor detects line, reverse and turn to the left
    motors.setSpeeds(-REVERSE_SPEED, -REVERSE_SPEED);
    delay(REVERSE_DURATION);
    motors.setSpeeds(-TURN_SPEED, TURN_SPEED);
    delay(TURN_DURATION);
    left_neg = FORWARD_TURN_MAGNITUDE * FORWARD_SPEED / 100;
    right_neg = 0;
  }
  // go straight, the stuff above are using blocking calls
  motors.setSpeeds(FORWARD_SPEED - left_neg, FORWARD_SPEED - right_neg);

  handleBackDoor();
}

void handleBackDoor(){
  unsigned int time = sonar.ping();
  float distance = sonar.convert_cm(time);
  
  if(distance < 15 && distance > 0.1f){
    motors.setSpeeds(0,0);

    //Add a stuff to do if detected behind
    delay(5000);
  }
}

