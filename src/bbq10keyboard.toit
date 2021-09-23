// Copyright 2021 Ekorau LLC

/**
The keyboard is read over I2C, via the protocol defined at:
https://github.com/solderparty/bbq10kbd_i2c_sw#protocol
*/     

import i2c show *
import serial
import .events show *
import monitor show Channel

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

KEY_L1 ::= 0x06
KEY_L2 ::= 0x11
KEY_R1 ::= 0x07
KEY_R2 ::= 0x12

KEY_U ::= 0x01
KEY_D ::= 0x02
KEY_L ::= 0x03
KEY_R ::= 0x04
KEY_S ::= 0x05


KEY_PRESS ::= 0x01
KEY_HOLD  ::= 0x02
KEY_REL   ::= 0x03

class BBQ10Keyboard:

  samd20_/Device
  registers_/serial.Registers
  payload := null
  event_channel := null

  constructor samd20/Device:
    samd20_ = samd20
    registers_ = samd20_.registers

  key_events_to channel/Channel:
    event_channel = channel
    while true:
      while key_count > 0:
        event_channel.send read_fifo
      sleep --ms=25 // right value?

  /// Return the number of key presses in the FIFO waiting to be read
  key_count -> int:
    return key_status & KEY_COUNT_MASK

  key_status -> int:
    return registers_.read_u8 REG_KEY

  /**
  Read the top of the FIFO, as an event.
  If the FIFO is empty, return a NonEvent
  */
  read_fifo -> Event:
    val := registers_.read_u16_be REG_FIF
    return 
      if 0 == val: NonEvent
      else: KeyEvent.key (val & 0xFF) (val >> 8) // keycode, state

  /**
  Invoked during FW_Keyboard .on, not expected to be called otherwise
  */
  reset -> none:
    registers_.write_u8 REG_RST 0
    sleep --ms=100  // vital, to allow SAMD20 time to boot
    
  version -> List:
    ver := registers_.read_u8 REG_VER
    return [ver >> 4, ver & 0x0F]

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


/**
Derived in part from  https://github.com/arturo182/arturo182_CircuitPython_BBQ10Keyboard/blob/master/bbq10keyboard.py  
and subject to the terms thereof:  
MIT License

Copyright (c) 2020 arturo182

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/