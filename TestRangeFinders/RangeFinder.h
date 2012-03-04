#ifndef RangeFinder_H
#define RangeFinder_H

#include "Arduino.h"

class RangeFinder {
  public:
    RangeFinder(short address);
    void start();
    short result();
    short read();
  private:
    short _address;
};

#endif
