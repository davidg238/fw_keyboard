// Copyright 2021 Ekorau LLC

import fw_keyboard show FW_Keyboard
import expect show *

import font show *
import pixel_display show *
import pixel_display.texture show TEXT_TEXTURE_ALIGN_RIGHT TEXT_TEXTURE_ALIGN_CENTER
import pixel_display.true_color show WHITE BLACK get_rgb
import font show *
import font.x11_100dpi.sans.sans_10 as sans_10

main:

    print "touchscreen_demo starting ..."
    val := null

    fw_kbd := FW_Keyboard
    fw_kbd.on
    tscrn := fw_kbd.touchscreen
    tft := fw_kbd.tft

    tscrn.initialize
    print "...touch initialized"

    sans := Font [sans_10.ASCII]
    context := tft.context --landscape --alignment=TEXT_TEXTURE_ALIGN_CENTER --color=WHITE --font=sans
    tft.remove_all
    tft.background = BLACK
    tft.draw

    location := tft.text context 160 120 "hello, world"
    tft.draw

    crosshair 25 20 tft context
    crosshair 275 20 tft context
    crosshair 25 200 tft context
    crosshair 275 200 tft context

    tft.draw

    while true:
        while tscrn.touched:
            show location tscrn.touch
            tft.draw
        sleep --ms=50
    print " ... that's all folks"

crosshair x y tft context -> none:
    x_line := tft.filled_rectangle context (x-10) y 20 1
    y_line := tft.filled_rectangle context x (y-10) 1 20
    posn   := tft.text context x (y+30) "$x, $y"
    tft.add x_line
    tft.add y_line
    tft.add posn

show location tch -> none:
    location.text = "$tch.x, $tch.y"