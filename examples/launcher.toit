// Copyright 2021 Ekorau LLC

import fw_keyboard show FW_Keyboard
import .displaylist show DisplayList Element Text Button TxtHandler

import pixel_display.true_color show *

class Launcher:

fwk := FW_Keyboard
tft := null

main:

    fwk.on
    tft = fwk.tft

//    task:: keyboard_task
//    task:: button_task
    task:: display_task

button_task:


display_task:
    homepage := homepage_on tft
    homepage.build
    homepage.draw

homepage_on tft -> DisplayList:
    d_list := DisplayList --id="homepage" --tft=tft
    txt_el := Text --id="msgTxt" --x=140 --y=120 --txt="Hello World"
    d_list.add_all [
            txt_el,
            Button --id="l1" --label="L1" --x=15  --y=230 --on_press= (TxtHandler --el=txt_el --val="L1"),
            Button --id="l2" --label="L2" --x=90  --y=230 --on_press= (TxtHandler --el=txt_el --val="L2"),
            Button --id="r3" --label="R3" --x=220 --y=230 --on_press= (TxtHandler --el=txt_el --val="R3"),
            Button --id="r4" --label="R4" --x=300 --y=230 --on_press= (TxtHandler --el=txt_el --val="R4"),
        ]
    return d_list

