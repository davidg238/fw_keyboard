# Keyboard FeatherWing Rev 2

This library enables the Solder Party [Keyboard FeatherWing Rev 2](https://www.solder.party/docs/keyboard-featherwing/rev2/) to be used with ESP32 FeatherWings running [Toit](https://toit.io/).  
FeatherWings tested and known to work:  
- [Adafruit HUZZAH32 - ESP32 Feather Board](https://www.adafruit.com/product/3405)

## Wiring 

Plug the ESP32 feather into the back of the Featherwing Keyboard.

## Library support of hardware features:

|  Feature, support  | Y | N |Notes |
| :---      |:-:|:-:|:- |
| 2.6” 320x240 16-bit color LCD  | Y | | |
| Resistive touch screen | Y | |  |
| QWERTY keyboard | Y | | 
| 5-way button | Y | | 
| 4 soft tactile buttons | Y | | 
| Neopixel  |  |N | ToDo ... integrate Pixel_Strip
| Ambient Light Sensor | |N | Toit does not support ESP32 Feather pin 26 as AI
| microSD connector |  |N | 
| Stemma QT/Qwiic connector |  | N | (Untested)
| GPIO solder jumpers  |  |N | 

## ToDo
- Is touchscreen fully robust?
- Only minimal samples provided (HotDraw based code removed for further development) 