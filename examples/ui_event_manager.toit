// Copyright 2021 Ekorau LLC

import monitor show Channel

import .ui_display_manager show DisplayManager 
import fw_keyboard show Event

class EventManager:

    key/Channel := ?
    touch/Channel := ?
    display_mgr/DisplayManager := ?
    event := null

    constructor --.key --.touch --.display_mgr:

    run -> none:
      while true:
        event = key.receive
        // print event
        display_mgr.handle event



