// Copyright 2021 Ekorau LLC

import gpio.adc as adc

import pubsub
import encoding.json
import gpio

import fw_keyboard show FW_Keyboard
import fw_keyboard.events show *
import fw_keyboard.bbq10keyboard show *

import monitor show *

import font show *
import pixel_display show *
import pixel_display.texture show TEXT_TEXTURE_ALIGN_RIGHT TEXT_TEXTURE_ALIGN_CENTER
import pixel_display.true_color show BLACK get_rgb

fw_kbd := FW_Keyboard
kbd := null
lcd := null

sans_ ::= Font.get "sans10"


main:

  fw_kbd.on
  print "fw_kbd.on ... done"
  kbd = fw_kbd.kbd
  // print kbd.status
  
  lcd = fw_kbd.lcd
  context := lcd.context --font=sans_

  lcd.background = BLACK
  blank
  lcd.text context 20 20 "Hello World"

  print "... fin"


blank:
  lcd.remove_all
  lcd.draw