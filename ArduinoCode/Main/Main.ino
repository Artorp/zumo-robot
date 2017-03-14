/*
Drive forward and turn left or right when border is detected
  - Only reflectionsensor 0 and 5 are used.
*/
#include <ZumoMotors.h>
#include <QTRSensors.h>
#include <ZumoReflectanceSensorArray.h>
#include <PLabBTSerial.h>


#define LED 13
 
// this might need to be tuned for different lighting conditions, surfaces, etc.
#define QTR_THRESHOLD  300 // 
  
// these might need to be tuned for different motor types
#define REVERSE_SPEED     400 // 0 is stopped, 400 is full speed
#define TURN_SPEED        400
#define FORWARD_SPEED     400
#define REVERSE_DURATION  200 // ms
#define TURN_DURATION     230 // ms

int FORWARD_TURN_PERCENTAGE = 38; // Percentage, 0..100, lower is less turn
int LEFT_NEG = 0;                 // Subtracted from left forward speed
int RIGHT_NEG = 0;                // Subtracted from right forward speed
 
ZumoMotors motors;
 
#define NUM_SENSORS 6
unsigned int sensor_values[NUM_SENSORS];
 
ZumoReflectanceSensorArray sensors;

// Bluetooth stuff
#define txPin 2  // Tx pin on Bluetooth unit
#define rxPin 3  // Rx pin on Bluetooth unit
PLabBTSerial btSerial(txPin, rxPin);
boolean receivedMessage = false;
const int serialBuffer = 128;
char inMsg[serialBuffer]; // Allocate some space for incoming messages
char inChar;
int inIndex = 0;



 
void setup()
{
   sensors.init();
   btSerial.begin(9600);
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
    LEFT_NEG = 0;
    RIGHT_NEG = FORWARD_TURN_PERCENTAGE * FORWARD_SPEED / 100;
  }
  else if (sensor_values[5] <  QTR_THRESHOLD)
  {
    // if rightmost sensor detects line, reverse and turn to the left
    motors.setSpeeds(-REVERSE_SPEED, -REVERSE_SPEED);
    delay(REVERSE_DURATION);
    motors.setSpeeds(-TURN_SPEED, TURN_SPEED);
    delay(TURN_DURATION);
    LEFT_NEG = FORWARD_TURN_PERCENTAGE * FORWARD_SPEED / 100;
    RIGHT_NEG = 0;
  }
  // go straight, the stuff above are using blocking calls
  motors.setSpeeds(FORWARD_SPEED - LEFT_NEG, FORWARD_SPEED - RIGHT_NEG);


  // Handle Bluetooth functions:
  handleBluetooth();
}

void handleBluetooth() {
  while (btSerial.available() && !messageReceived) { // Only look for data if there are some available
    //Serial.println("There was something available");
    if (inIndex < serialBuffer - 1) { // One less than buffer size is the last index
      inChar = btSerial.read();
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
      btSerial.println(response);
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
  response = "Unknown command";
  if (incMessage.startsWith("HALO ")) {
    responseStr = "HELLO THERE";
    return;
  } else if (incMessage.startsWith("SETTURN ")) {
    String newTurn = incMessage.substring(8);
    newTurn.trim();
    int intTurn = newTurn.toInt();
    setForwardTurnPerc(intTurn);
    responseStr = "OK NEW TURN SET";
    return;
  }
}

void setForwardTurnPerc(int n) {
  n = constrain(n, 0, 100);
  FORWARD_TURN_PERCENTAGE = n;
}

