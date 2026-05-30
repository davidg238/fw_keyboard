// Copyright 2021 Ekorau LLC

import i2c show Device
import serial
import .events show *
import monitor show Channel

MAX-12BIT     ::= 0x0fff
RESISTOR-VAL  ::= 280

/// Control Byte 0
REG-READ      ::= 0x01
REG-PND0      ::= 0x02
REG-X         ::= 0x0 << 3
REG-Y         ::= 0x1 << 3
REG-Z1        ::= 0x2 << 3
REG-Z2        ::= 0x3 << 3
REG-AUX       ::= 0x4 << 3
REG-TEMP1     ::= 0x5 << 3
REG-TEMP2     ::= 0x6 << 3
REG-STATUS    ::= 0x7 << 3
REG-AUX-HIGH  ::= 0x8 << 3
REG-AUX-LOW   ::= 0x9 << 3
REG-TEMP-HIGH ::= 0xA << 3
REG-TEMP-LOW  ::= 0xB << 3
REG-CFR0      ::= 0xC << 3
REG-CFR1      ::= 0xD << 3
REG-CFR2      ::= 0xE << 3
REG-CONV-FUNC ::= 0xF << 3

/// Control Byte 1
CMD           ::= 0x80
CMD-NORMAL    ::= 0x00
CMD-STOP      ::= 0x01
CMD-RESET     ::= 0x02
CMD-12BIT     ::= 0x04
  
/// Config Register 0
PRECHARGE-20US    ::= 0x00 << 5
PRECHARGE-84US    ::= 0x01 << 5
PRECHARGE-276US   ::= 0x02 << 5
PRECHARGE-340US   ::= 0x03 << 5
PRECHARGE-1-044MS ::= 0x04 << 5
PRECHARGE-1-108MS ::= 0x05 << 5
PRECHARGE-1-300MS ::= 0x06 << 5
PRECHARGE-1-364MS ::= 0x07 << 5

STABTIME-0US      ::= 0x00 << 8
STABTIME-100US    ::= 0x01 << 8
STABTIME-500US    ::= 0x02 << 8
STABTIME-1MS      ::= 0x03 << 8
STABTIME-5MS      ::= 0x04 << 8
STABTIME-10MS     ::= 0x05 << 8
STABTIME-50MS     ::= 0x06 << 8
STABTIME-100MS    ::= 0x07 << 8

CLOCK-4MHZ        ::= 0x00 << 11
CLOCK-2MHZ        ::= 0x01 << 11
CLOCK-1MHZ        ::= 0x02 << 11

TWELVE-BIT        ::= 1 << 13
STATUS            ::= 1 << 14
PENMODE           ::= 1 << 15

/// Config Register 1
BATCHDELAY-0MS    ::= (0x00 << 0)
BATCHDELAY-1MS    ::= (0x01 << 0)
BATCHDELAY-2MS    ::= (0x02 << 0)
BATCHDELAY-4MS    ::= (0x03 << 0)
BATCHDELAY-10MS   ::= (0x04 << 0)
BATCHDELAY-20MS   ::= (0x05 << 0)
BATCHDELAY-40MS   ::= (0x06 << 0)
BATCHDELAY-100MS  ::= (0x07 << 0)

/// Config Register 2
MAVE-Z    ::= 1 << 2
MAVE-Y    ::= 1 << 3
MAVE-X    ::= 1 << 4
AVG-7     ::= 0x01 << 11
MEDIUM-15 ::= 0x03 << 12

DAV-X     ::= 0x8000
DAV-Y     ::= 0x4000
DAV-Z1    ::= 0x2000
DAV-Z2    ::= 0x1000
DAV-MASK  ::= DAV-X | DAV-Y | DAV-Z1 | DAV-Z2

class TouchController:

  tsc2004_ /Device
  registers_ /serial.Registers
  payload := null
  event-channel := null

  constructor tsc2004 /Device:
    tsc2004_ = tsc2004
    registers_ = tsc2004_.registers


  initialize -> none:

    reset

    cfr0 ::= STABTIME-1MS | CLOCK-1MHZ | TWELVE-BIT | PRECHARGE-276US | PENMODE
    write-register REG-CFR0 cfr0

    write-register REG-CFR1 BATCHDELAY-4MS

    cfr2 ::= MAVE-Z | MAVE-Y | MAVE-X | AVG-7 | MEDIUM-15
    write-register REG-CFR2 cfr2

    write-command CMD-NORMAL

  touch -> TouchEvent:
    xs := 0
    ys := 0
    while ((read-register REG-STATUS) & DAV-MASK) == 0:
      sleep --ms=10

    // Burst-read X, Y, Z1, Z2 (4 x u16-be = 8 bytes) in one transaction, as the
    // Linux tsc200x driver does: the chip auto-increments the register pointer
    // and exposes a coherent snapshot. Individual addressed reads of the Z
    // registers do not return reliably.
    data := registers_.read-bytes (REG-X | REG-READ) 8
    x  := (data[0] << 8) | data[1]
    y  := (data[2] << 8) | data[3]
    z1 := (data[4] << 8) | data[5]
    z2 := (data[6] << 8) | data[7]

    if (x > MAX-12BIT) or (y > MAX-12BIT) or (z1 == 0) or (z2 > MAX-12BIT) or (z1 >= z2):
        return TouchEvent -1 -1 -1
    pressure  := x * (z2 - z1) / z1
    pressure   = (pressure * RESISTOR-VAL) / 4096
    /** 
    XY axes flipped, display in landscape mode
    Raw touchscreen events for the screen corners range from 200, 200 to 3700, 3800
    */
    xs = (((y - 200) * 320) / 3500).to-int
    xs = xs < 0? 0 : xs
    xs = xs > 320 ? 320 : xs

    ys = (240 - (((x - 200) * 240)) / 3600)
    ys = ys < 0? 0 : ys
    ys = ys > 240? 240 : ys

    return TouchEvent xs ys pressure

  reset -> none:
    write-command CMD-RESET

  touch-events-to channel/Channel:
    event-channel = channel
    while true:
      while touched:
        event-channel.send touch
      sleep --ms=10 // right value?    

  touched -> bool:
    return ((read-register REG-STATUS) & DAV-MASK) != 0

/// ---

  write-command command -> none:
    tsc2004_.write #[CMD | CMD-12BIT | command]

  read-register addr -> int:
    return retry-read-3 addr

  read-register_ addr -> int:
    return registers_.read-u16-be (addr | REG-READ)

  write-register addr val -> none:
    registers_.write-u16-be (addr | REG-PND0) val

/** 
Used to mostly? avoid exceptions on reading the touchscreen.
Previously exceptions were thrown after about 100 events.
With this retry, sofar none seen in light testing
*/

  retry-read-3 addr:
    tries := 0
    while tries < 2:
      exception := catch:
        return read-register_ addr
      if exception:
        sleep --ms=1
    return read-register_ addr


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