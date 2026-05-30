// Copyright 2026 Ekorau LLC

// Type on the Keyboard FeatherWing and see the text appear, live, on the TFT
// and on the serial console. Shift and Sym are applied by the keyboard firmware,
// so they "just work". Backspace edits; Enter submits the line.

import fw-keyboard show Keyboard-Driver KeyboardInput

import font show *
import font-x11-adobe.sans-10 as sans-10
import pixel-display show *
import pixel-display.true-color show WHITE BLACK

SANS ::= Font [sans-10.ASCII]

main:
  fw-kbd := Keyboard-Driver
  fw-kbd.on
  tft := fw-kbd.display
  input := KeyboardInput fw-kbd.keyboard

  tft.remove-all
  tft.background = BLACK
  prompt := Label --x=10 --y=30 --text="Type a message, Enter to submit:" --font=SANS --color=WHITE
  typed := Label --x=10 --y=70 --text="" --font=SANS --color=WHITE
  tft.add prompt
  tft.add typed
  tft.draw

  print "Type on the keyboard; Backspace edits, Enter submits."
  line := input.read-line --on-change=: | current/string |
    print "> $current"
    typed.text = current
    tft.draw

  print "You typed: \"$line\""
  result := Label --x=10 --y=110 --text="Got: $line" --font=SANS --color=WHITE
  tft.add result
  tft.draw
