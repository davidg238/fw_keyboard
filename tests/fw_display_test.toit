// Copyright 2021, 2022 Ekorau LLC

import gpio.adc as adc

import encoding.json
import gpio

import fw-keyboard show Keyboard-Driver

import monitor show *

import font show *
import font-x11-adobe.sans-14-bold as sans-14
import font-x11-adobe.sans-24-bold as sans-24-bold

import pixel_display show *
import pixel_display.two-color show *


SANS := Font [sans-14.ASCII]
SANS-BIG := Font [sans-24-bold.ASCII]

main:

  print "Starting display test..."

  sans_ ::= Font.get "sans10"
  fw-kbd := Keyboard-Driver

  fw-kbd.on
  print "fw_kbd.on ... done"
  
  tft := fw-kbd.tft
  kbd := fw-kbd.keyboard

  sans-36 := Style
    --font = SANS-BIG
    --color = 0x32ff32
    --align-center

  tft.background = BLACK
  [
    Label  --style=sans-36 --x=160 --y=30 --text="Hello from",
    Label  --style=sans-36 --x=160 --y=65 --text="TOITWARE",
  ].do: tft.add it
  
  tft.draw

  print "... done"
