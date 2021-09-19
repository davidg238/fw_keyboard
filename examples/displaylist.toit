// Copyright 2021 Ekorau LLC

import color_tft show *
import pixel_display show *
import pixel_display.texture show *
import pixel_display.true_color show *
import font show *
import font.x11_100dpi.sans.sans_10 as sans_10


class Element:
  /// Defining properties of an element.
  id/string
  x/int
  y/int
  /// Runtime properties of an element.
  parent := null
  texture := null

  /** Note the `.` between the `--` and arg-name.
  This is a shortcut syntax to assign the values, with named args.
  Similar to `.id .x .y`, where the args are un-named.
  */
  constructor --.id --.x --.y:

  setTxt aStr/string -> none:

class Text extends Element:
  /// `txt` must be non-final, to allow editing.
  txt/string := ?

  constructor --id --x --y --.txt:
    super --id=id --x=x --y=y

  build tft -> none:
    texture = tft.text (parent.txt_ctx.with --alignment=TEXT_TEXTURE_ALIGN_CENTER) x y txt

  set_text str/string -> none:
    txt = str
    parent.draw

class Button extends Text:
  /// The `?` designates that the value will be set in the constructor.
  handler := ?
  box_texture := null

  constructor --id --x --y --label --on_press:
    /** The `handler` must be set before the super call,
    otherwise the compiler will report `Field 'handler' not initialized on all paths`.
    */
    handler = on_press
    /// There is no shortcut available here, so `super` must be called with explicit args.
    super --id=id --x=x --y=y --txt=label

  build tft -> none:
    /// Rectangles are declares as origin/extent
    box_texture = tft.filled_rectangle parent.btn_ctx (x-12) (y-15) (25) (22)
    super tft
    

  on_press -> none:
    handler.invoke


class DisplayList:
  id := ?
  tft := ?
  txt_ctx := ?   // Bad? short name for default text context.
  btn_ctx := ?
  elements := List
  
  constructor --.id --.tft:
    tft.remove_all
    tft.background = BLACK
    sans := Font [sans_10.ASCII]
    txt_ctx = tft.context --landscape --color=WHITE --font=sans
    btn_ctx = tft.context --landscape --color=(get_rgb 0x5f 0x5f 0xff)

  add_all collection:
    elements.add_all collection
    collection.do: it.parent = this

  select anId/string -> Element:
    return elements.select: it.id == anId

  draw -> none:
    tft.draw

  build -> none:
    elements.do:
      it.build tft

class Handler:

class TxtHandler extends Handler:
  el/Text
  val/string

  constructor --.el --.val:

  invoke -> none:
    el.set_text val


