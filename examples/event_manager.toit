// Copyright 2021 Ekorau LLC

import monitor show Channel

import .display_manager show DisplayManager 
import events show Event

class EventManager:

    keyChannel := Channel 10
    buttonChannel := Channel 1
    touchChannel := Channel 10

    events/Channel := ?
    display_mgr/DisplayManager := ?
    event := null

    constructor --.events --.display_mgr:

    run -> none:
      while true:
        event = events.receive
        // print event
        display_mgr.handle event



