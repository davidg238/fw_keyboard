# Keyboard FeatherWing Rev 2

This library enables the [Adafruit HUZZAH32 - ESP32 Feather Board](https://www.adafruit.com/product/3405) to be used with the Solder Party [Keyboard FeatherWing Rev 2](https://www.solder.party/docs/keyboard-featherwing/rev2/)

## Wiring 

Plug the ESP32 feather into the back of the Featherwing Keyboard.

## Known Issues
 - the keyboard ALS does not work, because ESP32 Feather pin 26 is not supported as an Analog Input by Toit

## Status

At 0.5.4, there is minimal keyboard handling.  Exercise with either:  
`toit device run tests/fw_keyboard_test.toit`  

`toit device run examples/terminal_demo.toit`  
You should see something like:  
```
fw_keyboard $ toit device run examples/terminal_demo.toit
2021-09-11T07:05:02.178343Z: <process initiated>
one day a terminal demo, until then ... press any key on the FW_Keyboard
... reset
1: h
3: h
1: d
3: d
1: q
3: q
```
Key events are  *key state: key* and key state is 1=pressed, 2=hold, 3=released

## History  
At 0.5.3, this is little more than a project skeleton, to understand code dependencies.  
Refer blog post [An example of creating a Toit library](https://ekorau.com/2021/09/09/Creating-Library-Example.html)

