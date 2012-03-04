#ifndef RangeFinders_H
#define RangeFinders_H

#if ARDUINO >= 100
  #include <Arduino.h>
  #include <Wire.h>
#else
  #include <WProgram.h>
  #include <Wire.h>
#endif

short rangefinder_read(short);
void rangefinder_read_start(short);
short rangefinder_read_result(short);

#endif
