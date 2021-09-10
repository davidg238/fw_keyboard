// Copyright 2021 Ekorau LLC

import i2c show *
import serial

class BBQ10Keyboard:

  samd20_/Device
  registers_/serial.Registers

  constructor samd20/Device:
    samd20_ = samd20
    registers_ = samd20_.registers
    
  status -> int:
    return registers_.read_u8 0x04
    

