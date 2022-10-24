// Copyright 2021 Ekorau LLC

import fw_keyboard show *

import .ui_display_manager show DisplayManager
import .ui_event_manager show EventManager
import .ui_elements show *
import .ui_view_tft show *
import monitor show Channel

import pixel_display.true_color show *

class Launcher:

fwk := Keyboard_Driver
key_events := Channel 1
touch_events := Channel 1

tft := null
kbd := null
tscrn := null
event_mgr := null
display_mgr := null

tft_ui := TFT_ui

main:

  fwk.on
  kbd = fwk.keyboard
  tscrn = fwk.touchscreen
  display_mgr = DisplayManager --display=fwk.tcpd --width=fwk.width --height=fwk.height
  event_mgr = EventManager --key=key_events --touch=touch_events --display_mgr=display_mgr


  /// The keyboard dispatches events for the alphnumeric keys, 4 buttons, 5 way selector and touch screen.
  task:: keyboard_task
//    task:: touchscreen_task // todo
  task:: event_task
  task:: display_task

keyboard_task:
  kbd.key_events_to key_events

touchscreen_task:
  tscrn.touch_events_to touch_events

event_task:
  event_mgr.run

display_task:

  display_mgr.show_story tft_ui.story



/** ----
Declare some simple page content
*/
/*
home -> Page:
    page := Page --id="home"
    txt_el := Text --id="msg" --x=40 --y=120 --txt="Built on Toit"
    page.add_handlers [
            Handler --event=L1_PRESS --action= (SetTxt --el=txt_el --val="Built Toit"),
            Handler --event=L2_PRESS --action= (SetTxt --el=txt_el --val="Built with Toit"),
            Handler --event=R1_PRESS --action= (SetTxt --el=txt_el --val="Toit Powered"),
            Handler --event=R2_PRESS --action= (SetTxt --el=txt_el --val="Toit Gebouwd"),
            Handler --event=R5_PRESS --action= (NavTo --el=page  --id="page_1"),
    ]
    page.add_elements [
            Text --id="toit" --x=10 --y=80 --txt="Press the 4 buttons below to change...",
            txt_el,
            Text --id="explore" --x=10 --y=160 --txt="Navigate pages L/R with the 5 way ...",
    ]
    return page

page_1 -> Page:
    page := Page --id="page_1"
    txt_el := Text --id="msg" --x=40 --y=120 --txt="PAGE_1"
    page.add_handlers [
            Handler --event=L5_PRESS   --action= (NavTo --el=page --id="home"),
            Handler --event=R5_PRESS   --action= (NavTo --el=page  --id="page_2"),
    ]
    page.add_elements [
            txt_el,
            Text --id="explore" --x=10 --y=160 --txt="Navigate pages L/R with the 5 way ...",
    ]
    return page

page_2 -> Page:
    page := Page --id="page_2"
    txt_el := Text --id="msg" --x=40 --y=120 --txt="PAGE_2"
    page.add_handlers [
            Handler --event=L5_PRESS --action= (NavTo --el=page --id="page_1"),
            Handler --event=R5_PRESS --action= (NavTo --el=page  --id="page_3"),
    ]
    page.add_elements [
            txt_el,
            Text --id="explore" --x=10 --y=160 --txt="Navigate pages L/R with the 5 way ...",
    ]
    return page

page_3 -> Page:
    page := Page --id="page_3"
    txt_el := Text --id="msg" --x=40 --y=120 --txt="PAGE_3"
    page.add_handlers [
            Handler --event=L5_PRESS --action= (NavTo --el=page --id="page_2"),
            Handler --event=R5_PRESS --action= (NavTo --el=page  --id="home"),
    ]
    page.add_elements [
            txt_el,
            Text --id="explore" --x=10 --y=160 --txt="Navigate pages L/R with the 5 way ...",
    ]
    return page
*/