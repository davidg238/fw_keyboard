// Copyright 2021 Ekorau LLC

import gpio
import serial.protocols.i2c as i2c
import spi

import color_tft show ColorTft COLOR_TFT_16_BIT_MODE
import pixel_display show TrueColorPixelDisplay

i2c_bus := null
spi_bus := null
samd20  := null
tsc2004 := null
lcd_device := null
lcd_driver := null


lcd := null
kbd := null

class FW_Keyboard:

  on:
    i2c_bus = i2c.Bus
        --sda=gpio.Pin 12                  
        --scl=gpio.Pin 11

    samd20  = i2c_bus.device 0x1F
    tsc2004 = i2c_bus.device 0x4B

    spi_bus = spi.Bus
        --mosi= gpio.Pin  18
        --clock= gpio.Pin 11

    lcd_device = spi_bus.device
        --cs= gpio.Pin 15  
        --dc= gpio.Pin 33
        --frequency= 1_000_000 * 40
    
    lcd_driver = ColorTft lcd_device 320 240
            --reset=  gpio.Pin 16                                        ///todo, fake
            --backlight= null
            --x_offset= 0
            --y_offset= 0
            --flags= COLOR_TFT_16_BIT_MODE
            --invert_colors= false
    lcd = TrueColorPixelDisplay lcd_driver

  off:
