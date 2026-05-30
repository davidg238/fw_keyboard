# Keyboard text input — design

Date: 2026-05-29
Status: approved

## Goal

Make it easy to *type* on the Keyboard FeatherWing and get characters/strings out,
with Shift and Sym respected. Add a reusable decode + line-editing layer to the
`fw_keyboard` package and a runnable text-input example.

## Key fact (no modifier logic needed)

The SAMD20 keyboard firmware already applies Shift/Sym/CapsLock. The FIFO value's
low byte is the **resulting ASCII character code** for printable keys (e.g. Shift+`a`
→ `0x41` 'A'). In this driver that byte is already surfaced as `KeyEvent.id`, and
`KeyEvent.state` is `1` press / `2` hold / `3` release.

Printable characters occupy `0x20..0x7E`. Every special key (backspace `0x08`,
enter `0x0A`/`0x0D`, nav joystick `0x01..0x05`, side buttons `0x06/0x07/0x11/0x12`)
is below `0x20`, so characters and special keys separate cleanly by range.

## Approach (A: pull-based core + optional push stream)

### New module: `src/keyboard_input.toit` (exported via the barrel)

```
class Key:
  value/int           // keycode; = character code for printable keys
  state/int           // 1 press, 2 hold, 3 release
  is-printable -> bool   // 0x20 <= value <= 0x7E
  is-enter     -> bool   // value == 0x0A or 0x0D
  is-backspace -> bool   // value == 0x08
  rune -> int            // the character code (== value)
  stringify -> string    // the character if printable, else "key 0xNN"

class KeyboardInput:
  constructor keyboard/BBQ10Keyboard
  read-key -> Key                    // blocks until next PRESS event, decoded
  keys-to channel/Channel            // background producer of decoded press Keys
  read-line [--on-change] -> string  // accumulate printable; backspace edits; Enter returns
```

### Behaviour

- **Press-only:** decode acts only on `state == 1`. Hold/release are ignored — no
  surprise key-repeat (a future enhancement could opt into repeat on hold).
- **`read-key`** polls the existing `BBQ10Keyboard.key-count` / `read-fifo`, sleeping
  ~25 ms between polls, returning the first press it decodes.
- **`keys-to`** loops `channel.send read-key` — for event-driven apps; run in a task.
- **`read-line`** loops `read-key`:
  - Enter → return the accumulated string.
  - Backspace → drop the last character (if any).
  - Printable → append the character.
  - Anything else (nav/side buttons/non-press) → ignored.
  - After each edit, if an `on-change` block was supplied, call it with the current
    string. The buffer is built from runes; all printable keys here are ASCII.
- **No display coupling:** the package never imports `pixel_display`. Rendering is
  the caller's job via `on-change`.

### New example: `examples/a_text_input.toit`

- `Keyboard-Driver` → `.on`, take `.keyboard` and `.display` (pixel_display 2.x).
- Build `KeyboardInput` from the keyboard.
- Draw a live text label on the 320x240 TFT (pixel_display 2.x element API).
- Call `read-line --on-change=...` whose block updates the on-screen label **and**
  prints the current line to the console; on Enter print the final string.

### Enter/backspace codes

`0x0A`/`0x0D` and `0x08` are handled; the exact Enter code is confirmed empirically
on-device (the console echo makes this trivial). Both Enter codes are accepted.

## Out of scope (YAGNI)

- Key auto-repeat on hold.
- Multi-line editing, cursor movement, selection.
- Mapping nav joystick / side buttons to actions (the raw `Key` exposes them; apps
  decide).

## Versioning

Adds public API (`Key`, `KeyboardInput`, barrel export). Folded into the in-progress
**v2.0.0** release before tagging (publish is paused at the commit stage).
