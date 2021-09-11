import fw_keyboard show FW_Keyboard
import expect show *


class TerminalDemo:

main:
    print "one day a terminal demo, until then ... press any key on the FW_Keyboard"

    val := null

    fw_kbd := FW_Keyboard
    fw_kbd.on
    kbd := fw_kbd.kbd

    kbd.reset
    print "... reset"

    while true:
        while kbd.keyCount > 0:
            val = kbd.readFIFO
            print val
        sleep --ms=1000
