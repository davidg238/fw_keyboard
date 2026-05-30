// Copyright 2021 Ekorau LLC

import fw_keyboard show Keyboard_Driver
import expect show *

import font show *
import pixel_display show *
import pixel_display.true_color show WHITE BLACK get-rgb
import font show *
import font-x11-adobe.sans-10 as sans-10

main:

    print "touchscreen_demo starting ..."
    val := null

    fw_kbd := Keyboard_Driver
    fw_kbd.on
    tscrn := fw_kbd.touchscreen
    tft := fw_kbd.display

    tscrn.initialize
    print "...touch initialized"

    sans := Font [sans-10.ASCII]
    
    tft.remove_all
    tft.background = BLACK
    tft.draw

    location := Label --x=26 --y=199 --text=". 26, 199" --font=sans --color=WHITE
    tft.add location
    tft.draw
    sleep --ms=1000

    tft.add (Crosshair --x=25 --y=20)
    tft.add (Crosshair --x=275 --y=20)
    tft.add (Crosshair --x=25 --y=200)
    tft.add (Crosshair --x=275 --y=200)

    tft.draw

    while true:
        while tscrn.touched:
            print "$tscrn.touch: $tscrn.touch.x, $tscrn.touch.y"
            location.move-to tscrn.touch.x tscrn.touch.y
            tft.draw
        sleep --ms=1000

    print " ... that's all folks"

/*
crosshair x y tft  -> none:
    x_line := Rectangle (x - 10) y --w=20 --h=1
    y_line := tft.filled_rectangle context x (y - 10) 1 20
    posn   := tft.text context x (y+30) "$x, $y"
    tft.add x_line
    tft.add y_line
    tft.add posn
*/
show location tch -> none:
    location.text = "$tch.x, $tch.y"

//  horizontal_ canvas/Canvas --x/int --y/int --w/int:
//  canvas.rectangle x y --w=w --h=thickness --color=color

class Crosshair extends CustomElement:
  color/int := ?

  constructor --x/int?=null --y/int?=null --.color/int=WHITE:
    super --x=(x - 10) --y= (y - 10) --w=20 --h=20

  custom-draw canvas/Canvas -> none:
    canvas.rectangle 0 10 --w=20 --h=1  --color=WHITE
    canvas.rectangle 10 0 --w=1  --h=20 --color=WHITE
    // canvas.text x (y + 30) --text="$x, $y"