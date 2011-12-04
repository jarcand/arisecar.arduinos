/* @name    ARISE SecBot Locomotion Arduino Firmware
 * @author  Jeffrey Arcand <jeffrey.arcand@ariselab.ca>
 * @date    2011-11-23
 * @license GPLv3
 * @refs    Based on code for the ARISE ASUV and the CSTM HHW.
 */
#include <Servo.h>
#include "RcRead.h"

#define DEBUG     true
#define DEADBAND   20
#define M1_CAL    -5
#define M2_CAL     4

const byte devID       = 0x70;
const byte noMsgMax    = 70;
const byte pinLed      = 13;

const byte pinKSo      = 12;
const byte pinKSi      = 8;

const byte pinMotor1   = 9;
const byte pinMotor2   = 10;

// ------------------------------------------------------------------------

byte KSo, KSi;
byte motor1, motor2;
int d = 0;

// ------------------------------------------------------------------------

Servo serMotor1;
Servo serMotor2;

int mWC = 0;

byte noMsg = 0;
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
  } 
  else if (noMsg < noMsgMax) {
    noMsg++;
  } 
  else if (noMsg == noMsgMax) {
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
  motor1 = Serial.read();
  motor2 = Serial.read();

  for (int i = 0; i < 25; i++) {
    Serial.read();
  }

  KSo = bitRead(gpio, 0);

  return true;
}

void sendToComp() {
  if (DEBUG) {
    if (d++ % 10 == 0) {
      /*      Serial.print(rcThrust, DEC);
       Serial.print(",");
       Serial.print(rcSteer, DEC);
       Serial.print(",");
       Serial.print(rcAuto, DEC);
       Serial.print(",");
       Serial.print(rcSpare, DEC);
       Serial.println("");*/
    }
  } 
  else {
    Serial.write(0x55);
    Serial.write(0xFF);
    Serial.write(0xAA);
    Serial.write(devID);

    Serial.write((uint8_t) 0);
    Serial.write(motor1);
    Serial.write(motor2);
    writeShort(0);
    writeShort(0);
    writeShort(0);
    writeShort(0);
    writeShort(0);
    writeShort(0);
    writeShort(0);
    writeShort(0);

    for (int i = 0; i < 9; i++) {
      Serial.write('.');
    }
  }
}

void updateVals() {

  // Read the kill switch input
  KSi = digitalRead(pinKSi);

  // Update the Java GPIO outputs
  digitalWrite(pinKSo, KSo);

  if (rcAuto > 1500) {
    // Update the motors
    serMotor1.write(motor1);
    serMotor2.write(180 - motor2);

    Serial.print(motor1, DEC);
    Serial.print(",");
    Serial.print(motor2, DEC);
    Serial.print(",");
  } 
  else {

    outputRC();
  }
}

void outputRC() {

  if (rcThrust == 0 || rcSteer == 0) {
    return;
  }

  int th = rcThrust;
  int st = rcSteer;

  float thf = (th - 1500) / 500.0;
  float stf = (st - 1500) / 500.0;

  int m1 = constrain((thf + stf) * 500 + 1500, 1000, 2000) + M1_CAL;
  int m2 = constrain((thf - stf) * 500 + 1500, 1000, 2000) + M2_CAL;

  if (1500 - DEADBAND <= m1 && m1 <= 1500 + DEADBAND) {
    m1 = 1500 + M1_CAL;
  }
  if (1500 - DEADBAND <= m2 && m2 <= 1500 + DEADBAND) {
    m2 = 1500 + M2_CAL;
  }
  
  serMotor1.writeMicroseconds(m1);
  serMotor2.writeMicroseconds(3000 - m2);
  
}

void failsafe() {
  motor1 = 90;
  motor2 = 90;
  KSo = 0;
}

// ------------------------------------------------------------------------

void writeShort(short val) {
  Serial.write(highByte(val));
  Serial.write(lowByte(val));
}

void updateFlashing() {
  flaCounter++;
  if (flaCounter / (flaFast ? 2 : 20) % 2 == 0) {
    digitalWrite(pinLed, LOW);
  } 
  else {
    digitalWrite(pinLed, HIGH);
  }
}


