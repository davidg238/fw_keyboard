// Copyright 2021,2022 Ekorau LLC

import gpio
import serial.protocols.i2c as i2c
import spi

import color_tft show ColorTft COLOR_TFT_16_BIT_MODE COLOR_TFT_FLIP_XY
import pixel_display show TrueColorPixelDisplay
import .bbq10keyboard show BBQ10Keyboard 
import .touch_controller show TouchController 
import monitor


class Keyboard_Driver:

  i2c_bus := null
  spi_bus := null
  tft_device := null
  tft_driver := null

  tcpd := null
  keyboard := null
  touchscreen := null
  samd20  := null
  tsc2004 := null
    
  width ::= 320
  height ::= 240
  on:
    i2c_bus = i2c.Bus
       --sda=gpio.Pin 23
       --scl=gpio.Pin 22
    samd20  = i2c_bus.device 0x1F
    tsc2004 = i2c_bus.device 0x4B
    keyboard = BBQ10Keyboard samd20
    keyboard.reset
    touchscreen = TouchController tsc2004
    touchscreen.initialize

    spi_bus = spi.Bus
        --mosi= gpio.Pin  18 
        --clock= gpio.Pin  5

    tft_device = spi_bus.device
        --cs= gpio.Pin  15 
        --dc= gpio.Pin  33
        --frequency= 1_000_000 * 20 //(fails at 40)

    tft_driver = ColorTft tft_device width height
            --reset=  null
            --backlight= null
            --x_offset= 0
            --y_offset= 0
            --flags= COLOR_TFT_16_BIT_MODE | COLOR_TFT_FLIP_XY
            --invert_colors= false
    tcpd = TrueColorPixelDisplay tft_driver

  off:
    samd20.close
    tsc2004.close
    tcpd.close
    tft_driver.close
//    tft_device.close

//    i2c_bus.close 
//    spi_bus.close


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
