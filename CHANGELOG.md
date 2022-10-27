#1.0.11 - 2022-10-26
Service infrastructure working

#1.0.10 - 2022-10-25
Fix README

#1.0.9 - 2022-10-25
IOCTL service created, tank level sim/control runs

#1.0.8 - 2022-10-23
Demo UI renders, with text styling.

# 1.0.7 - 2022-10-17
Correct .yaml files and imports

# 1.0.6 - 2022-10-17
Updated project, compatible with toitlang and jag.

# 1.0.5 - 2021-11-16
Fix dependency; disable launcher

# 1.0.4 - 2021-11-01
Implement FW_Keyboard.off, launcher app; broken

# 1.0.1 - 2021-10-29
Dependencies updated

# 1.0.0 - 2021-09-27

# 0.7.0 - 2021-09-27
Touchscreen working and scaled to screen.  
Pleae report any unreliability seen using the touch_controller.

# 0.6.4 - 2021-09-23
Tidy examples

# 0.6.3 - 2021-09-23
Touchscreen working, with 2 issues:  
- accomodate touchscreen slightly different size than display screen
- exception after indeterminate period, even if no touch interactions

# 0.6.2 - 2021-09-22
Initial implementation of touchscreen (non-working)

# 0.6.1 - 2021-09-21
Fix examples/terminal_demo

# 0.6.0 - 2021-09-21
Toy graphics hierarchy working.  4 buttons + 5 way selector working.

# 0.5.8 - 2021-09-19
Toy graphics hierarchy included, to learn more language syntax (inheritance, super, named args)

# 0.5.7 - 2021-09-13
tft_demo.toit from color_tft runs (see /examples).

# 0.5.6 - 2021-09-12
Display working.
IO declarations were right; SPI frequency was too high -> exception.  Also set COLOR_TFT_FLIP_XY

# 0.5.5 - 2021-09-12
Attempt to get display working (does not).  
IO declarations match schematic, except --reset, which is not controllable

# 0.5.4 - 2021-09-10
I2C to SAMD20 established, miminal keyboard handling

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

## 0.5.3 - 2021-09-10
Dependency errors corrected
This is little more than a project skeleton, to understand code dependencies.  
Refer blog post [An example of creating a Toit library](https://ekorau.com/2021/09/09/Creating-Library-Example.html)

## 0.5.0 - 2021-09-06
Release only to resolve dependency errors with Toit