/** import bbq10keyboard show BBQ10Keyboard STATE_PRESS STATE_RELEASE STATE_LONG_PRESS

i2c = board.I2C()
kbd = BBQ10Keyboard(i2c)

kbd.backlight = 0.5

key := null
key_count := null
state := ""

main:
    while true:
        key_count = kbd.key_count
        if key_count > 0:
            key = kbd.key
            state = "pressed"
            if key[0] == STATE_LONG_PRESS:
                state = "held down"
            else if key[0] == STATE_RELEASE:
                state = "released"

            // print "key: '%s' (dec %d, hex %02x) %s" % (key[1], ord(key[1]), ord(key[1]), state))
            print "key: $(key[1]) (dec %d, hex %02x) $(state) (, ord(key[1]), ord(key[1]), ))





  exception := catch:
    print "Press q"
    with_timeout --ms=5000:
      kyb.key.wait_for KeyEvent 'q'
      print "Key: Pass, $(kyb.key.read)"
  if exception:
      print "Key: Fail"
*/            