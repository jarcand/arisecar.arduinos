#include <Wire.h>

const int ADDR_RF = 0xE0 >> 1;
const int ADDR_RF2 = 0XE6;
const int ADDR_RF3 = 0XE6 >> 1;

void setup() {
  Serial.begin(115200);
  Serial.println("setup1");
  Wire.begin();
  Serial.println("setup2");
  rangefinder_change_addr();
  Serial.println("setup3");
}

void loop() {
  short range = rangefinder_read();
//  if (range > 0) {
    Serial.print(range < 200 ? "Present" : "Empty");
    Serial.println(range, DEC);
//  }
  delay(30);
}

void rangefinder_change_addr() {
  Wire.beginTransmission(ADDR_RF);
  Wire.send(0x00);
  Wire.send(0xA0);
  Wire.endTransmission();
  delay(7);
  
  Wire.beginTransmission(ADDR_RF);
  Wire.send(0x00);
  Wire.send(0xAA);
  Wire.endTransmission();
  delay(7);
  
  Wire.beginTransmission(ADDR_RF);
  Wire.send(0x00);
  Wire.send(0xA5);
  Wire.endTransmission();
  delay(7);
  
  Wire.beginTransmission(ADDR_RF);
  Wire.send(0x00);
  Wire.send(ADDR_RF2);
  Wire.endTransmission();
  delay(7);
}

short rangefinder_read() {
  Wire.beginTransmission(ADDR_RF3);
  Wire.send(0x00);
  Wire.send(0x51);
  Wire.endTransmission();
  delay(70);
  
  Wire.beginTransmission(ADDR_RF3);
  Wire.send(0x02);
  Wire.endTransmission();
  Wire.requestFrom(ADDR_RF3, 1);
  byte high = Wire.receive();
  
  Wire.beginTransmission(ADDR_RF3);
  Wire.send(0x03);
  Wire.endTransmission();
  Wire.requestFrom(ADDR_RF3, 1);
  byte low = Wire.receive();
  
  return word(high, low);
}

