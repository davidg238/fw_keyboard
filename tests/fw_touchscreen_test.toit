// Copyright 2021, 2022 Ekorau LLC

import fw-keyboard show Keyboard-Driver

main:

    print "touchscreen_demo starting ..."
    val := null

    fw-kbd := Keyboard-Driver
    fw-kbd.on
    tscrn := fw-kbd.touchscreen

    tscrn.initialize
    print "...touch initialized"

    while true:
        while tscrn.touched:
            print tscrn.touch
        sleep --ms=50
