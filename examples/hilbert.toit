// Copyright 2021 Ekorau LLC

import fw_keyboard show FW_Keyboard
import bbq10keyboard show BBQ10Keyboard KEY_L1 KEY_L2 KEY_R1 KEY_R2
import events show R2_PRESS KeyEvent
import expect show *

import font show *
import pixel_display show *
import pixel_display.texture show TEXT_TEXTURE_ALIGN_RIGHT TEXT_TEXTURE_ALIGN_CENTER
import pixel_display.true_color show WHITE BLACK get_rgb
import font show *
import font.matthew_welch.tiny as tiny_4
import font.x11_100dpi.sans.sans_10 as sans_10

import math show pow Point3f
import pubsub

hilbert1 := [
/* 0: */ Point3f 0 0 0,
/* 1: */ Point3f 0 1 0,
/* 2: */ Point3f 1 1 0,
/* 3: */ Point3f 1 0 0
]

run := true

main:

    fw_kbd := FW_Keyboard
    fw_kbd.on
    tft := fw_kbd.tft
    kbd := fw_kbd.keyboard

    tiny := Font [tiny_4.ASCII]
    sans := Font [sans_10.ASCII]
    tiny_context := tft.context --landscape --color=WHITE --font=tiny
    context      := tft.context --landscape --color=WHITE --font=sans --alignment=TEXT_TEXTURE_ALIGN_CENTER

    popup_msg tft context "Function keys = Hilbert Curves, order 1-4"
    
    order := 1
    while run:
        if not (order < 1): draw_hilbert order tft context tiny_context
        order = get_order kbd
    fw_kbd.off
    print " ... hilbert end"
    // sleep --ms=1000
    pubsub.publish "device:end_app" "app_hilbert"


popup_msg tft context a_string/string -> none:
    clear_screen tft
    
    tft.text context 160 120 a_string
    tft.draw
    sleep --ms=2000
    clear_screen tft

get_order kbd/BBQ10Keyboard -> int:
    while run:
        sleep --ms=1000
        while run and (kbd.key_count > 0):
            event := kbd.read_fifo
            if event is KeyEvent: 
                k_event := event as KeyEvent
                if k_event==R2_PRESS:
                        run = false
                        return -1
                if k_event.state==1:
                    if      k_event.key==119: return 1
                    else if k_event.key==101: return 2
                    else if k_event.key==114: return 3
                    else if k_event.key==115: return 4
                return -1
    return -1



draw_hilbert order/int tft context tiny_context-> none:

    // Anything greater than order 4, program watchdogs.

    clear_screen tft

    N := (pow 2 order).to_int
    num_points := N * N
    length := (240 / N).to_int // 240 is the minimum dimension of the 320x240 display used
    offset := Point3f (length / 2).to_int (length / 2).to_int 0
    segment := null

    popup_msg tft context "Order $(order) Hilbert Curve, has $(num_points) points"

    prev := ((Point3f 0 0 0) * length) + offset
    count := 0
    for i := 0; i < num_points; i += 1:
        count++
        curr := hilbert i order
        curr = (curr * length) + offset // scale it to the screen
        if order < 4:  // at order 4, too many screen entities, draw fails
            tft.text tiny_context (curr.x).to_int (curr.y).to_int i.stringify  // to see the numbered curve points

        segment = tft.line context prev.x.to_int prev.y.to_int curr.x.to_int curr.y.to_int
        tft.add segment
        tft.draw       // to draw incrementally 
        prev = curr
        if count > 50: 
            count = 0
            yield      // to avoid watchdog
    // tft.draw        // to draw batch

clear_screen tft -> none:
    tft.remove_all
    tft.background = BLACK
    tft.draw

last2bits x/int -> int:
    return x & 3

hilbert i/int order/int-> Point3f:

    index := last2bits i
    point := hilbert1[index]
    quad := i
    for j := 1; j < order ; j++:
        quad = quad >>> 2
        index = last2bits quad
        len := pow 2 j
        if 0==index:
            point = Point3f point.y point.x 0
        else if 1==index:
            point = Point3f point.x (point.y + len) 0
        else if 2==index:
            point = Point3f (point.x + len) (point.y + len) 0
        else if 3==index:
            point = Point3f (len + len - 1 - point.y) (len - 1 - point.x) 0

    return point
