// Copyright 2021 Ekorau LLC

import i2c show *
import serial
import .events show *
import monitor show Channel

MAX_12BIT     ::= 0x0fff
RESISTOR_VAL  ::= 280

/// Control Byte 0
REG_READ      ::= 0x01
REG_PND0      ::= 0x02
REG_X         ::= 0x0 << 3
REG_Y         ::= 0x1 << 3
REG_Z1        ::= 0x2 << 3
REG_Z2        ::= 0x3 << 3
REG_AUX       ::= 0x4 << 3
REG_TEMP1     ::= 0x5 << 3
REG_TEMP2     ::= 0x6 << 3
REG_STATUS    ::= 0x7 << 3
REG_AUX_HIGH  ::= 0x8 << 3
REG_AUX_LOW   ::= 0x9 << 3
REG_TEMP_HIGH ::= 0xA << 3
REG_TEMP_LOW  ::= 0xB << 3
REG_CFR0      ::= 0xC << 3
REG_CFR1      ::= 0xD << 3
REG_CFR2      ::= 0xE << 3
REG_CONV_FUNC ::= 0xF << 3

/// Control Byte 1
CMD           ::= 0x80
CMD_NORMAL    ::= 0x00
CMD_STOP      ::= 0x01
CMD_RESET     ::= 0x02
CMD_12BIT     ::= 0x04
  
/// Config Register 0
PRECHARGE_20US    ::= 0x00 << 5
PRECHARGE_84US    ::= 0x01 << 5
PRECHARGE_276US   ::= 0x02 << 5
PRECHARGE_340US   ::= 0x03 << 5
PRECHARGE_1_044MS ::= 0x04 << 5
PRECHARGE_1_108MS ::= 0x05 << 5
PRECHARGE_1_300MS ::= 0x06 << 5
PRECHARGE_1_364MS ::= 0x07 << 5

STABTIME_0US      ::= 0x00 << 8
STABTIME_100US    ::= 0x01 << 8
STABTIME_500US    ::= 0x02 << 8
STABTIME_1MS      ::= 0x03 << 8
STABTIME_5MS      ::= 0x04 << 8
STABTIME_10MS     ::= 0x05 << 8
STABTIME_50MS     ::= 0x06 << 8
STABTIME_100MS    ::= 0x07 << 8

CLOCK_4MHZ        ::= 0x00 << 11
CLOCK_2MHZ        ::= 0x01 << 11
CLOCK_1MHZ        ::= 0x02 << 11

TWELVE_BIT        ::= 1 << 13
STATUS            ::= 1 << 14
PENMODE           ::= 1 << 15

/// Config Register 1
BATCHDELAY_0MS    ::= (0x00 << 0)
BATCHDELAY_1MS    ::= (0x01 << 0)
BATCHDELAY_2MS    ::= (0x02 << 0)
BATCHDELAY_4MS    ::= (0x03 << 0)
BATCHDELAY_10MS   ::= (0x04 << 0)
BATCHDELAY_20MS   ::= (0x05 << 0)
BATCHDELAY_40MS   ::= (0x06 << 0)
BATCHDELAY_100MS  ::= (0x07 << 0)

/// Config Register 2
MAVE_Z    ::= 1 << 2
MAVE_Y    ::= 1 << 3
MAVE_X    ::= 1 << 4
AVG_7     ::= 0x01 << 11
MEDIUM_15 ::= 0x03 << 12

DAV_X     ::= 0x8000
DAV_Y     ::= 0x4000
DAV_Z1    ::= 0x2000
DAV_Z2    ::= 0x1000
DAV_MASK  ::= DAV_X | DAV_Y | DAV_Z1 | DAV_Z2

class TouchController:

  tsc2004_/Device
  registers_/serial.Registers
  payload := null
  event_channel := null

  constructor tsc2004/Device:
    tsc2004_ = tsc2004
    registers_ = tsc2004_.registers


  initialize -> none:

    reset

    cfr0 ::= STABTIME_1MS | CLOCK_1MHZ | TWELVE_BIT | PRECHARGE_276US | PENMODE
    write_register REG_CFR0 cfr0

    write_register REG_CFR1 BATCHDELAY_4MS

    cfr2 ::= MAVE_Z | MAVE_Y | MAVE_X | AVG_7 | MEDIUM_15
    write_register REG_CFR2 cfr2

    write_command CMD_NORMAL

  touch -> TouchEvent:
    while ((read_register REG_STATUS) & DAV_MASK) == 0:
      sleep --ms=10

    x  := read_register REG_X
    y  := read_register REG_Y
    z1 := read_register REG_Z1
    z2 := read_register REG_Z2

    if (x > MAX_12BIT) or (y > MAX_12BIT) or (z1 == 0) or (z2 > MAX_12BIT) or (z1 >= z2):
        return TouchEvent 0 0 0
    pressure  := x * (z2 - z1) / z1
    pressure   = (pressure * RESISTOR_VAL) / 4096
    return TouchEvent ((y * 320) / 4096) ((x * 240)/4096) pressure
    // XY axes flipped, display in landscape mode
    //todo fix the display touchscreen mismatch: physical offset+different size

  reset -> none:
    write_command CMD_RESET

  touch_events_to channel/Channel:
    event_channel = channel
    while true:
      while touched:
        event_channel.send touch
      sleep --ms=10 // right value?    

  touched -> bool:
    return (read_register (REG_CFR0 & (PENMODE | STATUS))) != 0

/// ---

  write_command command -> none:
    registers_.write_u8 (CMD | CMD_12BIT | command) 0

  read_register addr -> int:
    return registers_.read_u16_be (addr | REG_READ)

  write_register addr val -> none:
    registers_.write_u16_be (addr | REG_PND0) val



/**
Derived in part from  https://github.com/solderparty/arturo182_CircuitPython_tsc2004/blob/main/tsc2004.py  
and subject to the terms thereof:  

The MIT License (MIT)

Copyright (c) 2021 arturo182 for Solder Party AB

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