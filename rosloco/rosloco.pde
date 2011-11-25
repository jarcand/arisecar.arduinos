/*
 * rosserial Servo Control Example
 *
 * This sketch demonstrates the control of hobby R/C servos
 * using ROS and the arduiono
 * 
 * For the full tutorial write up, visit
 * www.ros.org/wiki/rosserial_arduino_demos
 *
 * For more information on the Arduino Servo Library
 * Checkout :
 * http://www.arduino.cc/en/Reference/Servo
 */

#include <WProgram.h>

#include <Servo.h> 
#include <ros.h>
#include <std_msgs/Empty.h>
#include <std_msgs/String.h>
#include <std_msgs/UInt8.h>

#include "LocoStruct.h"

ros::NodeHandle  nh;

Servo servo1;
Servo servo2;
boolean allOff = false;
uint8_t servo1_val = 90;
uint8_t servo2_val = 90;

void all_off_cb(const std_msgs::Empty &cmd_msg) {
  allOff = !allOff;
  if (allOff) {
    servo1_val = 90;
    servo2_val = 90;
  }
  digitalWrite(13, allOff ? HIGH : LOW);
}

void servo1_cb(const std_msgs::UInt8 &cmd_msg) {
  if (!allOff) {
    servo1_val = cmd_msg.data;
  }
  digitalWrite(13, allOff ? HIGH : LOW);
}

void servo2_cb(const std_msgs::UInt8 &cmd_msg) {
  if (!allOff) {
    servo2_val = cmd_msg.data;
  }
  digitalWrite(13, allOff ? HIGH : LOW);
}

void servo_cb(const arisecar::LocoStruct& cmd_msg) {
  if (!allOff) {
    servo1_val = cmd_msg.x;
    servo2_val = cmd_msg.y;
  }
  digitalWrite(13, allOff ? HIGH : LOW);
}


ros::Subscriber<std_msgs::Empty> sub_all_off("all_off", all_off_cb);
ros::Subscriber<std_msgs::UInt8> sub_servo1("servo1", servo1_cb);
ros::Subscriber<std_msgs::UInt8> sub_servo2("servo2", servo2_cb);
//ros::Subscriber<arisecar::LocoStruct> sub_servo("servo", servo_cb);

std_msgs::String str_msg;
ros::Publisher debug("loco_debug", &str_msg);

void setup() {
  pinMode(13, OUTPUT);

  nh.initNode();
  nh.subscribe(sub_all_off);
  nh.subscribe(sub_servo1);
  nh.subscribe(sub_servo2);
  nh.advertise(debug);
  //  nh.subscribe(sub_servo);

  servo1.attach(9);
  servo2.attach(10);
}

int count = 0;

void loop() {

  if (count++ % 100 == 0) {
    char buf[10];
    itoa(servo1_val, buf, 10);
    str_msg.data = buf;
    debug.publish(&str_msg);
  }

  servo1.write(servo1_val);
  servo2.write(servo2_val);

  nh.spinOnce();
  delay(1);
}


