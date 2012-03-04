/* @name    ARISE SecBot Locomotion Arduino Firmware
 * @author  Jeffrey Arcand <jeffrey.arcand@ariselab.ca>
 * @date    2011-11-23
 * @license GPLv3
 * @refs    Based on code for the ARISE ASUV and the CSTM HHW.
 */
#include <Servo.h>
#include "RcRead.h"
#include <Wire.h>

#define DEBUG     false
#define DEADBAND   20
#define MOTOR_RAMP 50
#define M1_CAL     0
#define M2_CAL     8

const byte devID       = 0x70;
const byte noMsgMax    = 70;  
const byte pinLed      = 13;

const byte pinKSo      = 12;
const byte pinKSi      = 8;

const byte pinMotor1   = 9;
const byte pinMotor2   = 10;

// ------------------------------------------------------------------------

byte KSo, KSi;
byte motor1t, motor2t;
short motor1s, motor2s;
int d = 0;

// ------------------------------------------------------------------------

Servo serMotor1;
Servo serMotor2;

int mWC = 0;

byte noMsg = noMsgMax;
boolean flaFast = true;
int flaCounter = 0;

// ------------------------------------------------------------------------

void setup() {
  Serial.begin(115200);

  rc_read_init();

  pinMode(pinLed,  OUTPUT);

  pinMode(pinKSo,  OUTPUT);
  pinMode(pinKSi,  INPUT);
  digitalWrite(pinKSi, LOW); // No pull-up resistor

  serMotor1.attach(pinMotor1);
  serMotor2.attach(pinMotor2);
}

void loop() {
  if (receiveFromComp()) {
    noMsg = 0;
    flaFast = false;
  } else if (noMsg < noMsgMax) {
    noMsg++;
  } else if (noMsg == noMsgMax) {
    failsafe();
    flaFast = true;
  }
  updateVals();
  updateFlashing();
  sendToComp();  
  delay(20);
}

// ------------------------------------------------------------------------

boolean receiveFromComp() {
  if (Serial.available() < 32)
    return false;
  if (Serial.read() != 0x55)
    return false;
  if (Serial.read() != 0xFF)
    return false;
  if (Serial.read() != 0xAB)
    return false;
  if (Serial.read() != devID)
    return false;

  byte gpio = Serial.read();
  motor1t = Serial.read();
  motor2t = Serial.read();

  for (int i = 0; i < 25; i++) {
    Serial.read();
  }

  KSo = bitRead(gpio, 0);

  return true;
}

void sendToComp() {
  writeByte(0x55);
  writeByte(0xFF);
  writeByte(0xAA);
  writeByte(devID);

  writeByte(0);
  writeByte(motor1t);
  writeByte(motor2t);
  writeShort(motor1s);
  writeShort(motor2s);
  
  for (int i = 0; i < 21; i++) {
    Serial.write('.');
  }
  if (DEBUG) {
    Serial.println();
  }
}

void updateVals() {

  // Read the kill switch input
  KSi = digitalRead(pinKSi);

  // Update the Java GPIO outputs
  digitalWrite(pinKSo, KSo);

  // Check if RC transmitter is off
  if (rcAuto < 1000) {
    motor1s = 1500;
    motor2s = 1500;
    
  // Check if in RC/RF mode
  } else if (rcAuto < 1500) {
    updateSetpointsRC();
    
  // Otherwise in autonomous/PC mode
  } else {
    updateSetpointsPC();
  }

  // Apply deadbands to the motor outputs
  if (1500 - DEADBAND <= motor1s && motor1s <= 1500 + DEADBAND) {
    motor1s = 1500;
  }
  if (1500 - DEADBAND <= motor2s && motor2s <= 1500 + DEADBAND) {
    motor2s = 1500;
  }
  
  // Write the motor outputs
  serMotor1.writeMicroseconds(motor1s + M1_CAL);
  serMotor2.writeMicroseconds(3000 - motor2s - M2_CAL);
}

void updateSetpointsPC() {
  
  // Convert the angles to pulse lengths
  short m1t = map(motor1t, 0, 180, 1100, 1900);
  short m2t = map(motor2t, 0, 180, 1100, 1900);
  
  // Calculate the difference between the setpoints and the targets,
  // and constrain their size
  short m1d = constrain(m1t - motor1s, -MOTOR_RAMP, MOTOR_RAMP);
  short m2d = constrain(m2t - motor2s, -MOTOR_RAMP, MOTOR_RAMP);
  
  // Make the changes to the setpoints
  motor1s += m1d;
  motor2s += m2d;
}

void updateSetpointsRC() {

  if (rcThrust == 0 || rcSteer == 0) {
    return;
  }

  int th = rcThrust;
  int st = rcSteer;

  float thf = (th - 1500) / 500.0;
  float stf = (st - 1500) / 500.0;

  motor1s = constrain((thf + stf) * 500 + 1500, 1000, 2000);
  motor2s = constrain((thf - stf) * 500 + 1500, 1000, 2000);
}

void failsafe() {
  motor1t = 90;
  motor2t = 90;
  motor1s = 1500;
  motor2s = 1500;
  KSo = 0;
}

// ------------------------------------------------------------------------

void writeByte(byte val) {
  if (DEBUG) {
    Serial.print(val, DEC);
    Serial.print(':');
  } else {
    Serial.write(val);
  }
}

void writeShort(short val) {
  if (DEBUG) {
    Serial.print(val, DEC);
    Serial.print(':');
  } else {
    Serial.write(highByte(val));
    Serial.write(lowByte(val));
  }
}

void updateFlashing() {
  flaCounter++;
  if (flaCounter / (flaFast ? 2 : 20) % 2 == 0) {
    digitalWrite(pinLed, LOW);
  } else {
    digitalWrite(pinLed, HIGH);
  }
}


