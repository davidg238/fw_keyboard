// Copyright 2021,2022 Ekorau LLC

import gpio
import i2c
import spi

import color-tft show *
import pixel-display show *
import .bbq10keyboard show BBQ10Keyboard 
import .touch-controller show TouchController 
import .util

import monitor


class Keyboard-Driver implements Display:

  tft := null
  width ::= 320
  height ::= 240

  keyboard := null
  touchscreen := null


  i2c-bus_ := null
  spi-bus_ := null
  tft-device_ := null
  tft-driver_ := null
  samd20_  := null
  tsc2004_ := null
    
  on:
    i2c-bus_ = i2c.Bus
       --sda=gpio.Pin 23
       --scl=gpio.Pin 22
    samd20_  = i2c-bus_.device 0x1F
    tsc2004_ = i2c-bus_.device 0x4B
    keyboard = BBQ10Keyboard samd20_
    keyboard.reset
    touchscreen = TouchController tsc2004_
    touchscreen.initialize

    spi-bus_ = spi.Bus
        --mosi= gpio.Pin  18 
        --clock= gpio.Pin  5

    tft-device_ = spi-bus_.device
        --cs= gpio.Pin  15 
        --dc= gpio.Pin  33
        --frequency= 1_000_000 * 20 //(fails at 40)

    tft-driver_ = ColorTft tft-device_ width height
            --reset=  null
            --backlight= null
            --x-offset= 0
            --y-offset= 0
            --flags= COLOR-TFT-16-BIT-MODE | COLOR-TFT-FLIP-XY
            --invert-colors= false
    tft = PixelDisplay.true-color tft-driver_

  display -> PixelDisplay:
    return tft

  off:
    samd20_.close
    tsc2004_.close
    tft.close
    tft-driver_.close
//    tft_device_.close

//    i2c_bus_.close 
//    spi_bus_.close


/*
EXCEPTION error. 
WRONG_OBJECT_TYPE
  0: spi_device_close_         <sdk>/spi.toit:243:3
  1: Device_.close             <sdk>/spi.toit:159:7
  2: FW_Keyboard.off           <pkg:..>/fw_keyboard.toit:61:16
  3: handle_keyboard           /home/david/workspaceToit/fw_keyboard/examples/demo.toit:58:12
  4: main                      /home/david/workspaceToit/fw_keyboard/examples/demo.toit:37:5
  5: __entry__.<lambda>        <sdk>/core/entry.toit:46:20
*/
