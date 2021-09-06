# Keyboard FeatherWing Rev 2

WARNING: This library version does not compile.

This library enables the [Adafruit HUZZAH32 - ESP32 Feather Board](https://www.adafruit.com/product/3405) to be used with the Solder Party [Keyboard FeatherWing Rev 2](https://www.solder.party/docs/keyboard-featherwing/rev2/)

## Hardware

## Wiring 

Plug the ESP32 feather into the back of the Featherwing Keyboard.

## Known Issues
 - the keyboard ALS does not work, because ESP32 Feather pin 26 is not supported as an Analog Input


## Questions

if in tests/package.lock, use:
```
prefixes:
  fw_keyboard: ..
  events: ..

packages:
  ..:
    path: ../src
```

```
/home/david/workspaceToit/fw_keyboard/tests/package.lock:7:11: error: Package '..' at '/home/david/workspaceToit/fw_keyboard/src' is missing a 'src' folder
    path: ../src
          ^~~~~~

```
which suggests src is inferred.  Removing from path, fixes compilation error.


toit pkg install --local --prefix=fw_keyboard ..

