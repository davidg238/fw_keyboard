// Copyright 2021 Ekorau LLC

import gpio
import serial.protocols.i2c as i2c
import spi

import color_tft show ColorTft COLOR_TFT_16_BIT_MODE COLOR_TFT_FLIP_XY
import pixel_display show TrueColorPixelDisplay
import .bbq10keyboard show BBQ10Keyboard
import monitor

i2c_bus := null
spi_bus := null
lcd_device := null
lcd_driver := null

class FW_Keyboard:

  lcd := null
  kbd := null
  samd20  := null
  tsc2004 := null
  // events/Channel
  
  on:
    i2c_bus = i2c.Bus
       --sda=gpio.Pin 23
       --scl=gpio.Pin 22
    samd20  = i2c_bus.device 0x1F
    tsc2004 = i2c_bus.device 0x4B
    kbd = BBQ10Keyboard samd20
    // kbd.eventTo events

    spi_bus = spi.Bus
        --mosi= gpio.Pin  18 
        --clock= gpio.Pin  5
    // print "create lcd_device"
    lcd_device = spi_bus.device
        --cs= gpio.Pin  15 
        --dc= gpio.Pin  33
        --frequency= 1_000_000 * 20 //(fails at 40)
    // print "create lcd_driver"    
    lcd_driver = ColorTft lcd_device 320 240
            --reset=  gpio.Pin 16                                        ///todo, fake
            --backlight= null
            --x_offset= 0
            --y_offset= 0
            --flags= COLOR_TFT_16_BIT_MODE | COLOR_TFT_FLIP_XY
            --invert_colors= false
    lcd = TrueColorPixelDisplay lcd_driver

  off:


