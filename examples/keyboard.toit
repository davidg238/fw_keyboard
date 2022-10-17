// Copyright 2021, 2022 Ekorau LLC

import fw_keyboard show Keyboard_Driver
import expect show *

import font show *
import pixel_display show *
import pixel_display.texture show TEXT_TEXTURE_ALIGN_RIGHT TEXT_TEXTURE_ALIGN_CENTER
import pixel_display.true_color show BLACK get_rgb

tft := null

main:
    print "Print KeyEvents as they arrive ... press any key on the FW_Keyboard"

    val := null

    fw_kbd := Keyboard_Driver
    fw_kbd.on
    kbd := fw_kbd.keyboard

    kbd.reset
    print "... reset"

    while true:
        while kbd.key_count > 0:
            val = kbd.read_fifo
            print val
        sleep --ms=1000

