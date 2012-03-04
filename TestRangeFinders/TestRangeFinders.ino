#include "rangefinders.h"
#include <Wire.h>

const int ADDR_RF1 = 0xE2 >> 1;
const int ADDR_RF2 = 0XE4 >> 1;
const int ADDR_RF3 = 0XE6 >> 1;

void setup() {
  Serial.begin(115200);
  Wire.begin();
}

void loop() {
  short rf1 = rangefinder_read_result(ADDR_RF1);
  Serial.print(rf1, DEC);
  rangefinder_read_start(ADDR_RF1);
  Serial.print(", ");
  short rf2 = rangefinder_read_result(ADDR_RF2);
  Serial.print(rf2, DEC);
  rangefinder_read_start(ADDR_RF2);
  Serial.print(", ");
  short rf3 = rangefinder_read_result(ADDR_RF3);
  Serial.print(rf3, DEC);
  rangefinder_read_start(ADDR_RF3);
  Serial.println();
  delay(60);
}


