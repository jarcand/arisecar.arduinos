#include "RangeFinder.h"
#include <Wire.h>

const int ADDR_RF1 = 0xE2 >> 1;
const int ADDR_RF2 = 0XE4 >> 1;
const int ADDR_RF3 = 0XE6 >> 1;

RangeFinder rf1(ADDR_RF1);
RangeFinder rf2(ADDR_RF2);
RangeFinder rf3(ADDR_RF3);

void setup() {
  Serial.begin(115200);
  Wire.begin();
}

void loop() {
  short rf1v = rf1.result();
  Serial.print(rf1v, DEC);
  rf1.start();
  Serial.print(", ");
  short rf2v = rf1.result();
  Serial.print(rf2v, DEC);
  rf2.start();
  Serial.print(", ");
  short rf3v = rf3.result();
  Serial.print(rf3v, DEC);
  rf3.start();
  Serial.println();
  delay(60);
}


