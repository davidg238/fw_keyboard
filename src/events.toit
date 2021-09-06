// Copyright 2021 Ekorau LLC

class Event:


class AlsEvent extends Event:
  level/float

  constructor.level .level/float:

class ButtonEvent extends Event:
  num/int

  constructor.num .num/int:

class KeyboardEvent extends Event:
  key/int

  constructor.key .key/int:
  constructor.char achar/string:
    key = achar[0]

class FiveWayEvent extends Event:
  l  := false
  r  := false
  u  := false
  d  := false
  s  := false

  constructor.left:
    l = true
  constructor.right:
    r = true
  constructor.up:
    u = true
  constructor.down:
    d = true
  constructor.select:
    s = true

  bstr in/bool -> string:
    return if in: "1" else: "0"

  stringify -> string:
    return "jog: $(bstr l) $(bstr r) $(bstr u) $(bstr d) $(bstr s)"