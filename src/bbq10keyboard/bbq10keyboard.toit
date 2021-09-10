// Copyright 2021 Ekorau LLC

// The keyboard is read over I2C, via the protocol defined at:
//   https://github.com/arturo182/bbq10kbd_i2c_sw#protocol

import i2c show *
import serial

REG_VER ::= 0x01    // Firmware version.
REG_CFG ::= 0x02    // Configuration.
REG_INT ::= 0x03    // Interrupt status.
REG_KEY ::= 0x04    // Key status.
REG_BKL ::= 0x05    // Backlight control.
REG_DEB ::= 0x06    // Debounce configuration, not implemented in SAMD20.
REG_FRQ ::= 0x07    // Poll frequency.
REG_RST ::= 0x08    // Chip reset.
REG_FIF ::= 0x09    // FIFO access.

class BBQ10Keyboard:

  samd20_/Device
  registers_/serial.Registers

  constructor samd20/Device:
    samd20_ = samd20
    registers_ = samd20_.registers
    
  status -> int:
    return registers_.read_u8 REG_KEY
/**
  version -> :
    ver := registers_.read_u8 REG_VER
*/
    

