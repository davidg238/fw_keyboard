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
| Neopixel  |  |N | GPIO 11 is not available for the NeoPixel, refer Links 1.
| Ambient Light Sensor | |N | GPIO 26 as AI is not supported, refer Links 1.
| microSD connector |  |N | 
| Stemma QT/Qwiic connector |  | N | (Untested)
| GPIO solder jumpers  |  |N | 

## Examples

Run any of these with `jag run <file>` from the `examples/` directory:

- `a_keyboard.toit` — prints key events as you press them.
- `a_text_input.toit` — live text entry: type a line (Shift, Sym, Backspace and Enter all work), echoed to the TFT and the console.
- `a_hilbert.toit` — draws Hilbert curves; the four side buttons select the order.
- `a_touchscreen.toit` — prints raw touch events.

## Keyboard text input

Shift and Sym are applied by the keyboard firmware, so a printable key's decoded value is already the resulting character. `KeyboardInput` wraps the keyboard:

- `read-key` blocks for the next decoded key press.
- `keys-to channel` streams decoded presses to a channel.
- `read-line` accumulates a line (Backspace edits, Enter returns), with an optional `--on-change` block for echoing to a display.

## Links
1. [ESP32 Pins](https://docs.google.com/spreadsheets/d/12qL3ui2BkSn91O0ISJU8QIL2mcG-r_vlX0briknA2QQ)
2. [Cassowary](https://constraints.cs.washington.edu/cassowary/)
3. [box-drawing](https://github.com/adobe-type-tools/box-drawing/blob/master/boxDrawing.py)
4. [SVG Transformation](https://jenkov.com/tutorials/svg/svg-transformation.html)
