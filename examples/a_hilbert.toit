// Copyright 2021, 2022 Ekorau LLC

/* References:
- [Coding in the Cabana 3: Hilbert Curve](https://youtu.be/dSK-MW-zuAc) simple intro
- [Coding in the Cabana](https://github.com/CodingTrain/website/blob/main/challenges/coding-in-the-cabana/003_hilbert_curve/Processing/Hilbert/Hilbert.pde)
- [Iterative Algorithm for drawing Hilbert curve](http://blog.marcinchwedczuk.pl/iterative-algorithm-for-drawing-hilbert-curve)
- [Making 2D Hilbert Curve](https://bioconductor.org/packages/devel/bioc/vignettes/HilbertCurve/inst/doc/HilbertCurve.html)
*/

import fw_keyboard show  * //Keyboard_Driver BBQ10Keyboard KEY_L1 KEY_L2 KEY_R1 KEY_R2 KeyEvent

import font show *
import pixel_display show *
// import pixel_display.texture show TEXT_TEXTURE_ALIGN_RIGHT TEXT_TEXTURE_ALIGN_CENTER
import pixel_display.true_color show WHITE BLACK get_rgb
import font show *
import font_tiny.tiny as tiny
import font-x11-adobe.sans-10 as sans-10

import math show pow Point3f

hilbert1 := [
/* 0: */ Point3f 0 0 0,
/* 1: */ Point3f 0 1 0,
/* 2: */ Point3f 1 1 0,
/* 3: */ Point3f 1 0 0
]

run := true

TINY := Font [tiny.ASCII]
SANS := Font [sans_10.ASCII]

main:

  found := catch --trace:
    fw_kbd := Keyboard_Driver
    fw_kbd.on
    tft := fw_kbd.display
    kbd := fw_kbd.keyboard

    popup_msg tft "Function keys = Hilbert Curves, order 1-4"
    
    order := 4
    while run:
        if not (order < 1): draw_hilbert order tft 
        order = get_order kbd

    popup_msg tft "That's all folks ...."
    fw_kbd.off
    // sleep --ms=1000

popup_msg tft a_string/string -> none:
    clear_screen tft
    
    text := Label --x=160 --y=120 --text=a_string --font=SANS
    tft.add text
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
                // print k_event
                if k_event==U5_PRESS:
                        run = false
                        return -1
                else if k_event==L1_PRESS: return 1
                else if k_event==L2_PRESS: return 2
                else if k_event==R1_PRESS: return 3
                else if k_event==R2_PRESS: return 4
                return -1
    return -1



draw_hilbert order/int tft -> none:

    // Anything greater than order 4, program watchdogs.

    clear_screen tft

    N := (pow 2 order).to_int
    num_points := N * N
    length := (240 / N).to_int // 240 is the minimum dimension of the 320x240 display used
    offset := Point3f (length / 2).to_int (length / 2).to_int 0
    segment := null

    popup_msg tft "Order $(order) Hilbert Curve, has $(num_points) points"

    prev := ((Point3f 0 0 0) * length) + offset
    count := 0
    label := null

    for i := 0; i < num_points; i += 1:
        count++
        curr := hilbert i order
        curr = (curr * length) + offset // scale it to the screen
        if order < 4:  // at order 4, too many screen entities, draw fails
            label = Label --x=(curr.x).to_int --y=(curr.y).to_int --text=i.stringify --font=TINY
            tft.add label // to see the numbered curve points

        segment = tft.line prev.x.to_int prev.y.to_int curr.x.to_int curr.y.to_int
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
