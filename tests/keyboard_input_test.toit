// Copyright 2026 Ekorau LLC

import expect show *
import fw-keyboard show Key BACKSPACE-CODE ENTER-LF-CODE ENTER-CR-CODE

main:
  // Printable characters. The firmware applies Shift/Sym, so the decoded value
  // is already the resulting character code.
  expect (Key 'a' 1).is-printable
  expect (Key 'A' 1).is-printable
  expect (Key '?' 1).is-printable
  expect (Key ' ' 1).is-printable
  expect-equals 'A' (Key 'A' 1).rune
  expect-equals "A" (Key 'A' 1).stringify

  // Backspace and both forms of enter are recognised and are not printable.
  expect (Key BACKSPACE-CODE 1).is-backspace
  expect (not (Key BACKSPACE-CODE 1).is-printable)
  expect (Key ENTER-LF-CODE 1).is-enter
  expect (Key ENTER-CR-CODE 1).is-enter
  expect (not (Key ENTER-LF-CODE 1).is-printable)

  // Navigation joystick and side-button codes are below 0x20: not printable,
  // and neither enter nor backspace.
  expect (not (Key 0x01 1).is-printable)
  expect (not (Key 0x01 1).is-enter)
  expect (not (Key 0x01 1).is-backspace)
  expect-equals "key 0x01" (Key 0x01 1).stringify

  print "All keyboard-input decode tests passed."
