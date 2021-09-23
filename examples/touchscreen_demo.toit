// Copyright 2021 Ekorau LLC

import fw_keyboard show FW_Keyboard
import expect show *

import font show *
import pixel_display show *
import pixel_display.texture show TEXT_TEXTURE_ALIGN_RIGHT TEXT_TEXTURE_ALIGN_CENTER
import pixel_display.true_color show BLACK get_rgb

class TerminalDemo:

main:

    val := null

    fw_kbd := FW_Keyboard
    fw_kbd.on
    tscrn := fw_kbd.touchscreen

    tscrn.initialize
    print "... initialized"

    while true:
        while tscrn.touched:
            val = tscrn.touch
            print val
        sleep --ms=1000
