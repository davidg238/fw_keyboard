// Copyright 2021, 2022 Ekorau LLC

import fw_keyboard show Keyboard_Driver

main:

  val := null
  print "Start keyboard tests ..."

  fw_kbd := Keyboard_Driver
  fw_kbd.on
  kbd := fw_kbd.keyboard

  kbd.reset
  print "... reset"
  val = kbd.version
  print "Expected version major 0, got $(val)"
  print "Expected version minor 4, got $(val)"

  val = kbd.key_status
  print "Expected status 0, got $(val)"

  val = kbd.key_count
  print "Expected no keys pressed, counted $(val)"
  print "what happens when you read the FIFO without a key press?"
  val = kbd.read_fifo
  print "val is: $val"

  print "press any alphanumeric key, within 5 seconds"
  sleep --ms=5000
  val = kbd.key_count
  print "counted $val key events (press/hold/release)"
  print "Expected a key press+release, counted $(val)"
  

  print "... backlight is $(kbd.backlight)"
  kbd.backlight false
  print "sw  backlight off"
  print "... backlight is $(kbd.backlight)"
  print "---------------"
  print "... backlight2 is $(kbd.backlight2)"
  kbd.backlight2 false
  print "sw  backlight2 off"
  val = kbd.backlight2
  // expect (val == 0) --message="Expected backlight 0, got $(val)"
  print "Expected backlight 0, got $(val)"
  
  print "... done keyboard tests"      