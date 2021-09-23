// Copyright 2021 Ekorau LLC

/**
Note:  This is NOT a proper graphics hierarchy.
- It is a minimal hierarchy to demonstrate the FW_Keyboard features, so it complements the current Toit API with a little interactivity.
- It was a vehicle to understand certain syntax issues (answered on Slack, documented inline)
*/

import color_tft show *
import pixel_display show *
import pixel_display.texture show *
import pixel_display.true_color show *
import font show *
import font.x11_100dpi.sans.sans_10 as sans_10

import events show *


abstract class Element:
  /// Defining properties of an element.
  id/string
  /// Transient state.
  parent := null

  constructor --.id:

  abstract handle event/Event -> none
  navigate_to id/string -> none:

  stringify -> string:
    return "el.$id"

class Page extends Element:
  elements := List
  handlers := List  // For now, handlers are in a List
  model := null

  /// Transient state.
  tft := null
  txt_ctx := null   // Bad? short name for default text context.
  btn_ctx := null
  focus := null

  constructor --id:
    super --id=id
    focus = this

  add_elements collection:
    elements.add_all collection
    collection.do: it.parent = this

  add_handlers collection:
    handlers.add_all collection

  build display_mgr -> none:
    parent = display_mgr
    tft = parent.display
    tft.remove_all
    tft.background = BLACK
    sans := Font [sans_10.ASCII]
    txt_ctx = tft.context --landscape --color=WHITE --font=sans
    btn_ctx = tft.context --landscape --color=(get_rgb 0x5f 0x5f 0xff)

    elements.do:
      it.build tft

  draw -> none:
    tft.draw

  handle event: 
    if (focus == this):
      handlers.do: 
        if (it.event == event):
          it.action.invoke
          return
    else:
      focus.handle event

  navigate_to id/string -> none:
    parent.navigate_to id

  remove_texture texture -> none:
    tft.remove texture


abstract class DisplayElement extends Element:
  /// Defining properties of an element.
  x/int
  y/int
  /// Transient state.
  texture := null

  /** Notes:  
  - The `.` between the `--` and arg-name, is a shortcut syntax to assign the values, with named args.
     Similar to `.id .x .y`, where the args are un-named.
  - By supplying default values for x and y, the arguments are optional.
     This would be useful where there is a layout engine, rather than explicitly placing elements.
  */
  constructor --id --.x=0 --.y=0:
    super --id=id

  setTxt aStr/string -> none:

class Text extends DisplayElement:
  /// `txt` must be non-final, to allow editing.
  txt/string := ?

  constructor --id --x=0 --y=0 --.txt:
    super --id=id --x=x --y=y

  build tft -> none:
    texture = tft.text (parent.txt_ctx.with --alignment=TEXT_TEXTURE_ALIGN_LEFT) x y txt

  changed -> none:
    parent.remove_texture texture
    build parent.tft
    parent.draw

  set_text str/string -> none:
    txt = str
    changed

  handle event -> none:

class Button extends Text:  // not used, ugly, to be replaced using Windows
  /// The `?` designates that the value will be set in the constructor.
  handler := ?
  box_texture := null

  constructor --id --x=0 --y=0 --label --on_press:
    /** The `handler` must be set before the super call,
    otherwise the compiler will report `Field 'handler' not initialized on all paths`.
    A handler is used, since [Blocks cannot be stored in instance fields](https://docs.toit.io/language/blocks/).
    */
    handler = on_press
    /// There is no shortcut available here, so `super` must be called with explicit args.
    super --id=id --x=x --y=y --txt=label

  build tft -> none:
    /// Rectangles are declares as origin/extent
    texture = tft.text (parent.txt_ctx.with --alignment=TEXT_TEXTURE_ALIGN_CENTER) x y txt
    box_texture = tft.filled_rectangle parent.btn_ctx (x-12) (y-15) (25) (22)
    
  handle event -> none:  // oops?

  on_press -> none:
    handler.invoke

class NullElement extends Element:

  constructor:
    super --id=""

  handle Event -> none: 

/** ---
A handler is a Command object, used since ["Blocks cannot be stored in instance fields"](https://docs.toit.io/language/blocks/).
Handler respond to some event, by invoking a specific action on a target.
The handlers have restricted value, but work for this toy demo.
(In Smalltalk, you might store a block in an event target (with necessary foriegn references) that respond directly to the events).
*/

class Handler:
  event/Event := ?
  action/Action := ?

  constructor --.event --.action:
  invoke -> none: action.invoke

abstract class Action:
  abstract invoke -> none

class NonAction extends Action:  /// Take no action.
  invoke -> none:
  stringify -> string: return "act:none"

class SetTxt extends Action:
  el/Text
  val/string

  constructor --.el --.val:
  invoke -> none: el.set_text val
  stringify -> string: return "act:$(el).txt= $val"

class NavTo extends Action:
  el/Page
  id/string

  constructor --.el --.id:
  invoke -> none: el.navigate_to id

