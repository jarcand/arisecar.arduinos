#ifndef RangeFinders_H
#define RangeFinders_H

#include <Wire.h>

short rangefinder_read(short);
void rangefinder_read_start(short);
short rangefinder_read_result(short);

#endif
