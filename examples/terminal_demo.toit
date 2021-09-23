// Copyright 2021 Ekorau LLC

import fw_keyboard show FW_Keyboard
import expect show *

import font show *
import pixel_display show *
import pixel_display.texture show TEXT_TEXTURE_ALIGN_RIGHT TEXT_TEXTURE_ALIGN_CENTER
import pixel_display.true_color show BLACK get_rgb

class TerminalDemo:

tft := null

main:
    print "one day a terminal demo, until then ... press any key on the FW_Keyboard"

    val := null

    fw_kbd := FW_Keyboard
    fw_kbd.on
    kbd := fw_kbd.keyboard

    kbd.reset
    print "... reset"

    sans_ ::= Font.get "sans10"
    
    tft = fw_kbd.tft
    context := tft.context --font=sans_  --color=(get_rgb 230 230 50)

    tft.background = BLACK
    blank
    tft.text context 20 20 "Hello World"
    tft.draw


    while true:
        while kbd.key_count > 0:
            val = kbd.read_fifo
            print val
        sleep --ms=1000

blank:
  tft.remove_all
  tft.draw