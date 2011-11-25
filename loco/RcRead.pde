#include "RcRead.h"

#define RC_READ_DUTY_CNT 8

struct rcInput {
  byte edge;
  unsigned int count;
  byte dutyIdx;
  int duties[RC_READ_DUTY_CNT];
};

struct rcInput rcInputs[4];

void rc_read_init() {
  
//  // Enable the ISR on A1, A4 and D5
//  PCMSK1 = _BV(PCINT9) | _BV(PCINT12) | _BV(PCINT13);

  // Enable the ISR on D2, D3, D4 and D5
  PCMSK2 = _BV(PCINT18) | _BV(PCINT19) | _BV(PCINT20) | _BV(PCINT21);

  // Turn on interrupts on PortD
  PCICR |= (1 << PCIE2);
  
  // Setup Timer1
//  TCCR1A = B00000000;
//  TCCR1B = B00000010;
  
}

ISR(PCINT2_vect) {
  unsigned int cnt = TCNT1;
  byte port = PIND;
  
  rc_read_process_pin(port, pinRCThrust,
    cnt, &rcInputs[0], &rcThrust);

  rc_read_process_pin(port, pinRCSteer,
    cnt, &rcInputs[1], &rcSteer);
  
  rc_read_process_pin(port, pinRCAuto,
    cnt, &rcInputs[2], &rcAuto);
  
  rc_read_process_pin(port, pinRCSpare,
    cnt, &rcInputs[3], &rcSpare);
}

void rc_read_process_pin(byte port, byte pin,
 unsigned int cnt, struct rcInput* input,
 int* rcDuty) {
  
  if (port & (1 << pin)) {
    if (input->edge == 0) {
      input->edge = 1;
      input->count = cnt;
    }
  } else {
    if (input->edge != 0) {
      input->edge = 0;
      int duty = (cnt - input->count) / 2;
      if (duty < 5000) {
        input->duties[input->dutyIdx] = duty;
        input->dutyIdx = (input->dutyIdx + 1) % RC_READ_DUTY_CNT;
        long total = 0;
        int totalCnt = 0;
        for (byte i = 0; i < RC_READ_DUTY_CNT; i++) {
          total += input->duties[i];
          if (input->duties[i] > 0) {
            totalCnt++;
          }
        }
        *rcDuty = total / totalCnt;
      }
    }
  }
}

