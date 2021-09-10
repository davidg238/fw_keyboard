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

lcd := null

main:

  print "starting ..."

  sans_ ::= Font.get "sans10"
  fw_kbd := FW_Keyboard

  fw_kbd.on
  print "fw_kbd.on ... done"
  
  lcd = fw_kbd.lcd
  context := lcd.context --font=sans_

  lcd.background = BLACK
  blank
  lcd.text context 20 20 "Hello World"

  print "... done"


blank:
  lcd.remove_all
  lcd.draw