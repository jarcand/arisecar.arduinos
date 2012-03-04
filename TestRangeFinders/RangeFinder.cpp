#include "RangeFinder.h"
#include <Wire.h>

RangeFinder::RangeFinder(short address) {
  _address = address;
}

void RangeFinder::start() {
  Wire.beginTransmission(_address);
  Wire.write((byte) 0x00);
  Wire.write((byte) 0x51);
  Wire.endTransmission();
}

short RangeFinder::result() {
  byte rev = 0;
  while (rev == 0) {
    Wire.beginTransmission(_address);
    Wire.write((byte) 0x01);
    Wire.endTransmission();
    Wire.requestFrom(_address, 1);
    rev = Wire.read();
  }
  
  Wire.beginTransmission(_address);
  Wire.write((byte) 0x02);
  Wire.endTransmission();
  Wire.requestFrom(_address, 1);
  byte high = Wire.read();
  
  Wire.beginTransmission(_address);
  Wire.write((byte) 0x03);
  Wire.endTransmission();
  Wire.requestFrom(_address, 1);
  byte low = Wire.read();
  
  return word(high, low);
}

short RangeFinder::read() {
  start();
  return result();
}

