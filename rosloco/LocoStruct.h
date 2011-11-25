#ifndef _ROS_arisecar_LocoStruct_h
#define _ROS_arisecar_LocoStruct_h

#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include "ros/msg.h"

namespace arisecar
{

  class LocoStruct : public ros::Msg
  {
    public:
      uint8_t x;
      uint8_t y;

    virtual int serialize(unsigned char *outbuffer) const
    {
      int offset = 0;
      *(outbuffer + offset + 0) = (this->x >> (8 * 0)) & 0xFF;
      offset += sizeof(this->x);
      *(outbuffer + offset + 0) = (this->y >> (8 * 0)) & 0xFF;
      offset += sizeof(this->y);
      return offset;
    }

    virtual int deserialize(unsigned char *inbuffer)
    {
      int offset = 0;
      this->x |= ((uint8_t) (*(inbuffer + offset + 0))) << (8 * 0);
      offset += sizeof(this->x);
      this->y |= ((uint8_t) (*(inbuffer + offset + 0))) << (8 * 0);
      offset += sizeof(this->y);
     return offset;
    }

    const char * getType(){ return "arisecar/LocoStruct"; };
    const char * getMD5(){ return "99999999999999999999999999999999"; };

  };

}
#endif
