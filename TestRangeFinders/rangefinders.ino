#include "rangefinders.h"

void rangefinder_read_start(short addr) {
  Wire.beginTransmission(addr);
  Wire.write((byte) 0x00);
  Wire.write((byte) 0x51);
  Wire.endTransmission();
}

short rangefinder_read_result(short addr) {
  byte rev = 0;
  while (rev == 0) {
    Wire.beginTransmission(addr);
    Wire.write((byte) 0x01);
    Wire.endTransmission();
    Wire.requestFrom(addr, 1);
    rev = Wire.read();
  }
  
  Wire.beginTransmission(addr);
  Wire.write((byte) 0x02);
  Wire.endTransmission();
  Wire.requestFrom(addr, 1);
  byte high = Wire.read();
  
  Wire.beginTransmission(addr);
  Wire.write((byte) 0x03);
  Wire.endTransmission();
  Wire.requestFrom(addr, 1);
  byte low = Wire.read();
  
  return word(high, low);
}

short rangefinder_read(short addr) {
  rangefinder_read_start(addr);
  return rangefinder_read_result(addr);
}

