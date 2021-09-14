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