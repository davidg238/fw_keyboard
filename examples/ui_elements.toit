// Copyright 2021 Ekorau LLC

/**
Note:  This is NOT a proper graphics hierarchy.
- It is a minimal hierarchy to demonstrate the FW_Keyboard features, so it complements the current Toit API with a little CompositeElementeractivity.
- It was a vehicle to understand certain syntax issues (answered on Slack, documented inline)
*/

import color_tft show *
import pixel_display show *
import pixel_display.texture show *
import pixel_display.true_color show *

import font show Font
import font.x11_100dpi.typewriter.typewriter_10 as typX11

import fw_keyboard show Event

/*
Something that can be displayed: a (page, drawing), element or composite element
*/
interface Displayable:

abstract class Layout implements Displayable:
  elements /List := ?  // a list of figures, to be laid out
  parent_ /Displayable? := null

  constructor .elements:

  abstract build tft/ColorTft --parent /Displayable-> none
// Auto_once
class Row extends Layout:
  constructor elements:
    super elements

  build tft/PixelDisplay --parent /Displayable-> none:
    parent_ = parent
    elements.do:
      it.build tft this

class Column extends Layout:

  constructor elements:
    super elements

  build tft/PixelDisplay --parent /Displayable-> none:
    parent_ = parent
    elements.do:
      it.build tft this

// Auto_continuous
//class Dynamic extends Layout:

// Manual
class Freeform extends Layout:

  constructor elements:
    super elements

  // used by a drawing, do nothing, items placed explicitly
  build tft/PixelDisplay --parent /Displayable -> none:
    parent_ = parent
    elements.do:
      it.build tft parent
      
// ----------------------------------------------------------------------------

class Story:
  home  /Link? := null
  index /Link? := null

  constructor page/Page:
    home = Link page
    index = home

  homepage -> Displayable:
    return home.cel

  add page/Page:
    next := Link page
    index.next = next
    index = next

  current_page -> Displayable:
    return index.cel

class Page implements Displayable:
  name /string := ?
  layout :=null

  /// Transient state.
  parent := null

  tft := null
  asc_10 := null
  txt_ctx := null  
  btn_ctx := null

  focus := null

  constructor --.name:
    focus = this

  add_handlers collection:
    handles.add_all collection

  clear_all tft/PixelDisplay -> none:
    tft.remove_all
    tft.background = BLACK  

  set_style tft/PixelDisplay -> none:
    // For now, single style per page
    asc_10 = Font [typX11.ASCII]
    txt_ctx = tft.context --landscape --color=WHITE --font=asc_10
    btn_ctx = tft.context --landscape --color=(get_rgb 0x5f 0x5f 0xff)  

  build display_mgr -> none:
    parent = display_mgr
    tft = parent.display

    clear_all tft
    set_style tft
    layout.build tft this

  draw -> none:
    tft.draw

  handle event: 
    if (focus == this):
      handles.do: 
        if (it.event == event):
          it.action.invoke
          return
    else:
      focus.handle event

  layout a_layout -> none:
    layout = a_layout

  navigate_to name/string -> none:
    parent.navigate_to name

  remove_texture texture -> none:
    tft.remove texture

// ----------------------------------------------------------------------------


abstract class Element:
  /// Defining properties of an element.
  handles := List  // For now, handlers are in a List
  model := null
  /// Transient state.
  parent := null

  // abstract handle event/Event -> none


abstract class CompositeElement extends Element:
  elements := List
  // nav_seq /Link := ?



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
  constructor --.x=0 --.y=0:

  setTxt aStr/string -> none:

class Text extends DisplayElement:
  /// `txt` must be non-final, to allow editing.
  txt/string := ?

  constructor --.txt --x=0 --y=0:
    super --x=x --y=y

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

class Spacing extends Text:

  constructor i/int:
    super --txt=(" "*i)

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
    super --x=x --y=y --txt=label

  build tft -> none:
    /// Rectangles are declares as origin/extent
    texture = tft.text (parent.txt_ctx.with --alignment=TEXT_TEXTURE_ALIGN_CENTER) x y txt
    box_texture = tft.filled_rectangle parent.btn_ctx (x-12) (y-15) (25) (22)
    
  handle event -> none:  // oops?

  on_press -> none:
    handler.invoke

class NullElement extends Element:

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
  invoke -> none: 
    el.set_text val
  stringify -> string: 
    return "act:$(el).txt= $val"

class NavTo extends Action:
  el/Page
  id/string

  constructor --.el --.id:
  
  invoke -> none:
    el.navigate_to id

class Link:
  cel /Displayable
  prev /Link? := null
  next /Link? := null

  constructor .cel:

/*
class Hub extends Link:
  constructor i:
    super i
    links.add null
    links.add null

  parent -> CompositeElement:
    return links[3]
  parent i/CompositeElement -> none:
    links[3] = i
  child -> CompositeElement:
    return links[2]
  child i/CompositeElement -> none:
    links[2] = i
*/