// Copyright 2021 Ekorau LLC

import fw_keyboard show FW_Keyboard
import expect show *

import font show *
import pixel_display show *
import pixel_display.texture show TEXT_TEXTURE_ALIGN_RIGHT TEXT_TEXTURE_ALIGN_CENTER
import pixel_display.true_color show BLACK get_rgb

class TerminalDemo:

lcd := null

main:
    print "one day a terminal demo, until then ... press any key on the FW_Keyboard"

    val := null

    fw_kbd := FW_Keyboard
    fw_kbd.on
    kbd := fw_kbd.kbd

    kbd.reset
    print "... reset"

    sans_ ::= Font.get "sans10"
    
    lcd = fw_kbd.lcd
    context := lcd.context --font=sans_  --color=(get_rgb 230 230 50)

    lcd.background = BLACK
    blank
    lcd.text context 20 20 "Hello World"
    lcd.draw


    while true:
        while kbd.keyCount > 0:
            val = kbd.readFIFO
            print val
        sleep --ms=1000

blank:
  lcd.remove_all
  lcd.draw