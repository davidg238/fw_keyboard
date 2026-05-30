// Copyright 2026 Ekorau LLC

import monitor show Channel
import .bbq10keyboard show BBQ10Keyboard
import .events show Event KeyEvent

/** Key code for the backspace key. */
BACKSPACE-CODE ::= 0x08
/** Key code for the line-feed form of the enter key. */
ENTER-LF-CODE ::= 0x0a
/** Key code for the carriage-return form of the enter key. */
ENTER-CR-CODE ::= 0x0d

/** Key state reported by the keyboard for a key that was just pressed. */
PRESS-STATE_ ::= 1

/**
A decoded key from the $BBQ10Keyboard.

The keyboard firmware applies the Shift and Sym modifiers itself, so for a
  printable key the $value is already the resulting character code (for example
  Shift+'a' yields 0x41, 'A').
*/
class Key:
  /** The key code. For a printable key this is the character code. */
  value/int
  /** The key state: 1 pressed, 2 held, 3 released. */
  state/int

  constructor .value .state:

  /** Whether this is a printable character (in the range 0x20..0x7e). */
  is-printable -> bool:
    return 0x20 <= value <= 0x7e

  /** Whether this is the enter/return key. */
  is-enter -> bool:
    return value == ENTER-LF-CODE or value == ENTER-CR-CODE

  /** Whether this is the backspace key. */
  is-backspace -> bool:
    return value == BACKSPACE-CODE

  /** The character code of this key. Equal to $value. */
  rune -> int:
    return value

  stringify -> string:
    if is-printable: return string.from-rune value
    return "key 0x$(%02x value)"

/**
Decodes keyboard events into characters and provides simple line editing.

Wraps a $BBQ10Keyboard and reads from its key FIFO.
*/
class KeyboardInput:
  keyboard_/BBQ10Keyboard
  poll-period-ms_/int

  /**
  Constructs a $KeyboardInput that reads from $keyboard.

  When the FIFO is empty it polls again every $poll-period-ms milliseconds.
  */
  constructor keyboard/BBQ10Keyboard --poll-period-ms/int=25:
    keyboard_ = keyboard
    poll-period-ms_ = poll-period-ms

  /**
  Blocks until the next key press and returns it decoded.

  Only press events are returned; held and released events are skipped.
  */
  read-key -> Key:
    while true:
      while keyboard_.key-count > 0:
        event/Event := keyboard_.read-fifo
        if event is KeyEvent:
          key-event := event as KeyEvent
          if key-event.state == PRESS-STATE_:
            return Key key-event.id key-event.state
      sleep --ms=poll-period-ms_

  /**
  Sends decoded key presses to $channel forever.

  Intended to be run in its own task for event-driven applications.
  */
  keys-to channel/Channel -> none:
    while true:
      channel.send read-key

  /**
  Reads a line of text, returning it when the enter key is pressed.

  Printable keys are appended, backspace removes the last character, and the
    enter key terminates and returns the accumulated string (without a trailing
    newline). Other keys, such as the navigation joystick and the side buttons,
    are ignored.
  */
  read-line -> string:
    return read-line --on-change=: null

  /**
  Variant of $read-line that echoes edits.

  Calls $on-change with the current string after every edit, which is useful
    for echoing the text to a display.
  */
  read-line [--on-change] -> string:
    line := ""
    while true:
      key := read-key
      if key.is-enter:
        return line
      else if key.is-backspace:
        if line.size > 0: line = line[..line.size - 1]
      else if key.is-printable:
        line += string.from-rune key.value
      else:
        continue
      on-change.call line
