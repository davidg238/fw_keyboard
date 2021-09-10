// Copyright 2021 Ekorau LLC

import gpio
import serial.protocols.i2c as i2c
import spi

import color_tft show ColorTft COLOR_TFT_16_BIT_MODE
import pixel_display show TrueColorPixelDisplay
import .bbq10keyboard show BBQ10Keyboard

i2c_bus := null
spi_bus := null
lcd_device := null
lcd_driver := null

class FW_Keyboard:

  lcd := null
  kbd := null
  samd20  := null
  tsc2004 := null
  
  on:
    i2c_bus = i2c.Bus
       --sda=gpio.Pin 4
       --scl=gpio.Pin 5
    samd20  = i2c_bus.device 0x1F
    tsc2004 = i2c_bus.device 0x4B
    kbd = BBQ10Keyboard samd20

    spi_bus = spi.Bus
        --mosi= gpio.Pin  13
        --clock= gpio.Pin 14
    print "create lcd_device"
    lcd_device = spi_bus.device
        --cs= gpio.Pin 9 
        --dc= gpio.Pin 10
        --frequency= 1_000_000 * 40
    print "create lcd_driver"    
    lcd_driver = ColorTft lcd_device 320 240
            --reset=  gpio.Pin 16                                        ///todo, fake
            --backlight= null
            --x_offset= 0
            --y_offset= 0
            --flags= COLOR_TFT_16_BIT_MODE
            --invert_colors= false
    lcd = TrueColorPixelDisplay lcd_driver

  off:


