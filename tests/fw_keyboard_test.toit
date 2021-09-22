import fw_keyboard show FW_Keyboard
import expect show *

main:

  val := null
  print "Start keyboard tests ..."

  fw_kbd := FW_Keyboard
  fw_kbd.on
  kbd := fw_kbd.kbd

  kbd.reset
  print "... reset"
  val = kbd.version
  expect (val[0] == 0) --message="Expected version major 0, got $(val)"
  expect (val[1] == 4) --message="Expected version minor 4, got $(val)"

  val = kbd.key_status
  expect (val == 0) --message="Expected status 0, got $(val)"

  val = kbd.key_count
  expect (val == 0) --message="Expected no keys pressed, counted $(val)"
  print "what happens when you read the FIFO without a key press?"
  val = kbd.readFIFO
  print "val is: $val"

  print "press any alphanumeric key, within 5 seconds"
  sleep --ms=5000
  val = kbd.key_count
  print "counted $val key events (press/hold/release)"
  expect (val > 1) --message="Expected a key press+release, counted $(val)"
  

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