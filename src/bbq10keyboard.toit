// Copyright 2021 Ekorau LLC

// The keyboard is read over I2C, via the protocol defined at:
//  https://github.com/solderparty/bbq10kbd_i2c_sw#protocol

import i2c show *
import serial
import .events show KeyEvent

REG_VER ::= 0x01    // Firmware version.
REG_CFG ::= 0x02    // Configuration.
REG_INT ::= 0x03    // Interrupt status.
REG_KEY ::= 0x04    // Key status.
REG_BKL ::= 0x05    // Backlight control.
REG_DEB ::= 0x06    // Debounce configuration, not implemented in SAMD20.
REG_FRQ ::= 0x07    // Poll frequency.
REG_RST ::= 0x08    // Chip reset.
REG_FIF ::= 0x09    // FIFO access.
REG_BK2 ::= 0x0A    // Secondary backlight control.
REG_DIR ::= 0x0B    // GPIO direction.
REG_PUE ::= 0x0C    // GPIO input pull enable.
REG_PUD ::= 0x0D    // GPIO input pull direction.
REG_GIO ::= 0x0E    // GPIO value.
REG_GIC ::= 0x0F    // GPIO interrupt config.
REG_GIN ::= 0x10    // GPIO interrupt status.

KEY_NUMLOCK_MASK ::= 1 << 6
KEY_CAPSLOCK_MASK ::= 1 << 5
KEY_COUNT_MASK ::= 0x1F

class BBQ10Keyboard:

  samd20_/Device
  registers_/serial.Registers
  payload := null

  constructor samd20/Device:
    samd20_ = samd20
    registers_ = samd20_.registers

  // Return the number of key presses in the FIFO waiting to be read
  keyCount -> int:
    return keyStatus & KEY_COUNT_MASK

  keyStatus -> int:
    return registers_.read_u8 REG_KEY

  readFIFO -> KeyEvent:
    val := registers_.read_u16_be REG_FIF
    return KeyEvent.key (val >> 8) (val & 0xFF)

  reset -> none:
    registers_.write_u8 REG_RST 0
    sleep --ms=100
    
  version -> List:
    ver := registers_.read_u8 REG_VER
    return [ver >> 4, ver & 0x0F]
/**
  backlight -> int:
    return registers_.read_u8 REG_BKL
//    return ((registers_.read_u8 REG_BKL) / 255) > 0

  backlight on/bool -> none:
    val := if on: 0xFF else: 0x00
    registers_.write_u8 REG_BKL val

  backlight2 -> int:
    return registers_.read_u8 REG_BK2

  backlight2 on/bool -> none:
    val := if on: 0xFF else: 0x00
    registers_.write_u8 REG_BK2 val
*/
