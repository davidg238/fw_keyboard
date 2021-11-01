// Copyright 2021 Ekorau LLC

import fw_keyboard show FW_Keyboard
import bbq10keyboard show BBQ10Keyboard KEY_L1 KEY_L2 KEY_R1 KEY_R2
import events show KeyEvent
import expect show *

import font show *
import pixel_display show *
import pixel_display.texture show TEXT_TEXTURE_ALIGN_LEFT TEXT_TEXTURE_ALIGN_CENTER
import pixel_display.true_color show WHITE BLACK get_rgb
import font show *
import font.matthew_welch.tiny as tiny_4
import font.x11_100dpi.sans.sans_10 as sans_10

import pubsub

run := true

main:

    fw_kbd := FW_Keyboard
    fw_kbd.on
    tft := fw_kbd.tft
    kbd := fw_kbd.keyboard

    sans := Font [sans_10.ASCII]
    context      := tft.context --landscape --color=WHITE --font=sans --alignment=TEXT_TEXTURE_ALIGN_LEFT

    clear_screen tft

    tft.text context 40 60  "Demonstrations"
    tft.text context 60 100 "0: TFT graphics"
    tft.text context 60 120 "1: Hilbert Curves"
    tft.draw

    handle_keyboard kbd

clear_screen tft -> none:
    tft.remove_all
    tft.background = BLACK
    tft.draw

handle_keyboard kbd/BBQ10Keyboard -> none:
    while run:
        while kbd.key_count > 0:
            event := kbd.read_fifo
            if event is KeyEvent: 
                k_event := event as KeyEvent
                if k_event.state==1:
                    if      k_event.key==126:
                        pubsub.publish "device:run_tft" "launcher"
                        run = false
                    else if k_event.key==119:
                        pubsub.publish "device:run_hilbert" "launcher"
                        run = false
        sleep --ms=1000