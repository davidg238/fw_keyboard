// Copyright 2021 Ekorau LLC

L1_PRESS ::= KeyEvent.key 0x06 0x01
L2_PRESS ::= KeyEvent.key 0x11 0x01
R1_PRESS ::= KeyEvent.key 0x07 0x01
R2_PRESS ::= KeyEvent.key 0x12 0x01

U5_PRESS ::= KeyEvent.key 0x01 0x01
D5_PRESS ::= KeyEvent.key 0x02 0x01
L5_PRESS ::= KeyEvent.key 0x03 0x01
R5_PRESS ::= KeyEvent.key 0x04 0x01
S5_PRESS ::= KeyEvent.key 0x05 0x01


abstract class Event:


class AlsEvent extends Event:
  level/float

  constructor.level .level/float:

class KeyEvent extends Event:
  id/int
  state/int

  constructor.key .id/int .state/int: 

  operator == other:
    if other is not KeyEvent: return false
    return (id == other.id) and (state == other.state)

  hash_code:
    /// Refer BBQ10Keyboard.read_fifo: KeyEvent.key (val & 0xFF) (val >> 8) // keycode, state
    return (state << 8) | id

  stringify -> string:
    return "key $id:$state"

class NonEvent extends Event:

class TouchEvent extends Event:
  x/int?
  y/int?
  pressure/int?

  constructor .x .y .pressure:

  stringify: return "tch $x:$y:$pressure"