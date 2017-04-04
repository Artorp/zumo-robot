/*
Drive forward and turn left or right when border is detected
  - Only reflectionsensor 0 and 5 are used.
*/
#include <ZumoMotors.h>
#include <QTRSensors.h>
#include <ZumoReflectanceSensorArray.h>
#include <PLabBTSerial.h>
#include <NewPing.h>
 
// this might need to be tuned for different lighting conditions, surfaces, etc.
#define QTR_THRESHOLD  300 // 
  
// these might need to be tuned for different motor types
#define REVERSE_SPEED     400 // 0 is stopped, 400 is full speed
#define TURN_SPEED        400
int     FORWARD_SPEED    =400;
#define REVERSE_DURATION  200 // ms
#define TURN_DURATION     230 // ms

int FORWARD_TURN_INITIAL = 38;
int FORWARD_TURN_AVOID = 90;
int FORWARD_TURN_PERCENTAGE = FORWARD_TURN_INITIAL; // Percentage, 0..100, lower is less turn
int LEFT_NEG = 0;                 // Subtracted from left forward speed
int RIGHT_NEG = 0;                // Subtracted from right forward speed
long TURN_TIME = 0;                // Time in millis to keep turning sharp after not seeing anything
long TURN_START = 0;

#define LEFT_ID  1
#define RIGHT_ID 2
int PREV_SIDE = LEFT_ID;

//Ultralyd setup
const int echoPin = 6;
const int triggerPin = 5;
NewPing sonar(triggerPin, echoPin, 300);
 
ZumoMotors motors;
 
#define NUM_SENSORS 6
unsigned int sensor_values[NUM_SENSORS];
 
ZumoReflectanceSensorArray sensors;

boolean messageReceived = false;
const int serialBuffer = 128;
char inMsg[serialBuffer]; // Allocate some space for incoming messages
char inChar;
int inIndex = 0;



 
void setup()
{
  sensors.init();
  // use regular serial instead of btSerial, tx = 0, rx = 1
  Serial.begin(9600); // This is the Bluetooth serial port
}

void loop()
{
  // Check if something is behind the Zumo robot
  handleBackDoor();
  
  // Read sensors, handle motors
  handleMotors();
  
  
  // Handle Bluetooth functions:
  handleBluetooth();
}

void handleMotors() {
  
  sensors.read(sensor_values);

  if (sensor_values[0] < QTR_THRESHOLD)
  {
    // if leftmost sensor detects line, reverse and turn to the right
    motors.setSpeeds(-REVERSE_SPEED, -REVERSE_SPEED);
    delay(REVERSE_DURATION);
    motors.setSpeeds(TURN_SPEED, -TURN_SPEED);
    delay(TURN_DURATION);
    PREV_SIDE = RIGHT_ID;
  }
  else if (sensor_values[5] <  QTR_THRESHOLD)
  {
    // if rightmost sensor detects line, reverse and turn to the left
    motors.setSpeeds(-REVERSE_SPEED, -REVERSE_SPEED);
    delay(REVERSE_DURATION);
    motors.setSpeeds(-TURN_SPEED, TURN_SPEED);
    delay(TURN_DURATION);
    PREV_SIDE = LEFT_ID;
  }

  int magnitude = FORWARD_TURN_PERCENTAGE * FORWARD_SPEED / 100;

  // Calculate turn percentage
  if (PREV_SIDE == RIGHT_ID) {
    RIGHT_NEG = magnitude;
    LEFT_NEG = 0;
  } else {
    RIGHT_NEG = 0;
    LEFT_NEG = magnitude;
  }


  
  // go straight, the stuff above are using blocking calls
  motors.setSpeeds(FORWARD_SPEED - LEFT_NEG, FORWARD_SPEED - RIGHT_NEG);
}

void handleBackDoor(){
  unsigned int time = sonar.ping();
  float distance = sonar.convert_cm(time);
  
  if(distance < 15 && distance > 0.1f){
    FORWARD_TURN_PERCENTAGE = FORWARD_TURN_AVOID;
    TURN_START = millis();
  } else if ((TURN_TIME + TURN_START - millis()) < 0) {
    FORWARD_TURN_PERCENTAGE = FORWARD_TURN_INITIAL;
  }
  
}


void handleBluetooth() {
  while (Serial.available() && !messageReceived) { // Only look for data if there are some available
    //Serial.println("There was something available");
    if (inIndex < serialBuffer - 1) { // One less than buffer size is the last index
      inChar = Serial.read();
      //Serial.print("Read:");Serial.println(inChar, DEC);
      inMsg[inIndex] = inChar;
      inIndex++;
      inMsg[inIndex] = '\0'; // Null terminate the string
      if (inChar == '\n' || inChar == 0) { // Newline, end of message.
        messageReceived = true;
        break;
      }
    } else { // Input string was longer than buffer, just cut of the message
      inMsg[serialBuffer - 1] = '\0';
      messageReceived = true;
      break;
    }
  }

  if (messageReceived) {
    messageReceived = false;
    String ourMsg(inMsg); // Convert CharArray to String
    //Serial.println("We did receive a message! It was ->"+ourMsg+"<-"); // Debug message
    String response;
    parseMsg(ourMsg, response); // Pass the response object
    // response now has a response string

    // Send our response:
    if (response.length() > 0) {
      Serial.println(response);
      Serial.flush();
      response = "";
    }
    
    // Cleanup, ready to accept new message
    inIndex = 0;
    for (int i = 0; i < serialBuffer - 1; i++) {
      inMsg[i] = 0;
    }
  }
}

void parseMsg(String &incMessage, String &responseStr) {
  incMessage.trim();
  responseStr = "Unknown command|";
  if (incMessage.startsWith("HALO ")) {
    responseStr = "HELLO THERE|";
    return;
  } else if (incMessage.startsWith("SETTURN ")) {
    String newTurn = incMessage.substring(8);
    newTurn.trim();
    int intTurn = newTurn.toInt();
    setForwardTurnPerc(intTurn);
    responseStr = "OK NEW TURN SET|";
    return;
  } else if (incMessage.startsWith("SETSPEED ")) {
    String newSpeed = incMessage.substring(9);
    newSpeed.trim();
    int intSpeed = newSpeed.toInt();
    setForwardSpeed(intSpeed);
    responseStr = "OK NEW SPEED SET|";
    return;
  } else if (incMessage.startsWith("GETSPEED")) {
    responseStr = "SPEED IS "+String(FORWARD_SPEED)+"|";
    return;
  }
}



void setForwardTurnPerc(int n) {
  n = constrain(n, 0, 100);
  FORWARD_TURN_INITIAL = n;
}

void setForwardSpeed(int n) {
  n = constrain(n, 0, 400);
  FORWARD_SPEED = n;
}


