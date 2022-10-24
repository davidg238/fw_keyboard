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
import font_x11_adobe.typewriter_10 as typ_10
import font_x11_adobe.typewriter_18 as typ_18
import font.matthew_welch.tiny as tiny_4

import fw_keyboard show Event
import .ui_display_manager show DisplayManager

TYP_10 ::= Font [typ_10.ASCII]
TYP_18 ::= Font [typ_18.ASCII]
TINY_4 ::= Font [tiny_4.ASCII]

class Style:
  color /int?
  font /Font?
  align /int?

  constructor --.color=WHITE --.font=TYP_10 --.align=TEXT_TEXTURE_ALIGN_LEFT:

/*
Something that can be displayed: a page, an element or a layout.
*/
interface Displayable:
interface Eventable:
// ----------------------------------------------------------------------------

interface Locating extends Displayable:
/*
Layouts take on 3 forms (static, dynamic and freeform) to locate the page elements
  on the display.  Layouts must be able to nest, are Displayable but have no visual indicator
  other than the consequence of their presence in element location.

Static layouts may comprise rows, columns, grids etc to place elements once at page creation
  according to a layout algorithm.

Dynamic layouts infers the elements are continuously moving, based on some algorithm.  So
  in a drawing of planetary bodies, the planets are animated by the rules of gravity. 
  (In HotDraw, this was achieved by subclassing Drawing, but here there is the opportunity to 
  extract the behavior.)

Freeform layouts, elements are placed explicitly, by hand (in an editor) or code.

Is it tractable for a dynamic layout to wrap a freeform, so you could live edit a dynamic page?
*/


abstract class Layout implements Locating Eventable:
  style_ /Style?
  elements_ /List := ?  // a list of figures, to be laid out
  parent_ /Eventable? := null

  constructor --.style_=null .elements_:

  abstract build parent/Eventable display/TrueColorPixelDisplay ctx/GraphicsContext-> none


class Row extends Layout:
  x /int := 0
  y /int := 0

  constructor --style elements:
    super --style_=style elements

  build parent /Eventable display/TrueColorPixelDisplay ctx/GraphicsContext -> none :
    parent_ = parent
    // add any Row styling to the context here
    elements_.do:
      it.build this display ctx

  advance x_inc /int y_inc /int -> none:
    x = x + x_inc
    y = y + y_inc

class Column extends Layout:

  constructor --style elements:
    super --style_=style elements

  build parent /Eventable display/TrueColorPixelDisplay ctx/GraphicsContext -> none :
    parent_ = parent
    // add any Column styling to the context here
    elements_.do:
      it.build this display ctx

// Auto_continuous
//class Dynamic extends Layout:

// Manual
class Freeform extends Layout:

  constructor --style=null elements:
    super --style_=style elements

  build parent/Eventable  display/TrueColorPixelDisplay ctx/GraphicsContext -> none :
    parent_ = parent
    // add any Freeform styling to the context here
    elements_.do:
      it.build this display ctx
      
// ----------------------------------------------------------------------------
// A Story is a chain of Pages, where you can go forward and back only
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

  next -> Displayable:
    index = index.next
    return index.cel
  prev -> Displayable:
    index = index.prev
    return index.cel

class Page implements Displayable Eventable:
  name /string := ""
  layout_ :=null

  /// Transient state.
  parent_ /Eventable? := null
  // focus := null
  constructor --.name:
//    focus = this
/*

  add_handlers collection:
    handles.add_all collection
*/

  build parent/Eventable display/TrueColorPixelDisplay ctx/GraphicsContext -> none:
    parent_ = parent
    // add any Page styling to the context here
    layout_.build this display ctx

/*
  handle event: 
    if (focus == this):
      handles.do: 
        if (it.event == event):
          it.action.invoke
          return
    else:
      focus.handle event
*/
  layout a_layout -> none:
    layout_ = a_layout
/*
  navigate_to name/string -> none:
    parent.navigate_to name

  remove_texture texture -> none:
    parent.display.remove texture
*/
// ----------------------------------------------------------------------------

/*
In Toit Display architecture, a display maintains a list of objects that it is 
currently displaying, called Textures.  Textures are mutatable.  To update the
display, you add/remove/modify the textures, then call `draw` on the display.

A Story comprises Pages, that represent the individual screens of the UI 
and their sequence. Within a Page, Elements are a wrapper for Textures, 
to capture interactivity and animation.

Story, Pages and Elements may be written in a textual format, derivative of 
the concepts of Elm-UI, Flutter and HotDraw, but scoped for the limited displays of
embedded devices.
*/
abstract class Element:
  handles := List
  model_ := null
  // Transient state.
  parent_ := null

  // abstract handle event/Event -> none

abstract class DisplayElement extends Element implements Eventable:
  x/int
  y/int
  style /Style?
  texture_ /Texture? := null

  /** Notes:  
  - The `.` between the `--` and arg-name, is a shortcut syntax to assign the values, with named args.
     Similar to `.id .x .y`, where the args are un-named.
  - By supplying default values for x and y, the arguments are optional.
     This would be useful where there is a layout engine, rather than explicitly placing elements.
  */
  constructor --.style=null --.x=0 --.y=0:

abstract class CompositeElement extends DisplayElement:
  elements := List
  // nav_seq /Link := ?

class Text extends DisplayElement:
  /// `txt` must be non-final, to allow editing.
  txt/string := ?

  constructor --style --.txt --x=0 --y=0:
    super --style=style --x=x --y=y

  build parent/Displayable display/TrueColorPixelDisplay ctx/GraphicsContext -> none:
    parent_ = parent
    texture_ = display.text (ctx.with --color=style.color --font=style.font --alignment=style.align) x y txt

  // Refer to `GraphicsContext.with` in pixel_display.toit !!!!
  /*
    if font_name_:

    else:

    texture_ = tft.text (parent.txt_ctx.with --alignment=TEXT_TEXTURE_ALIGN_LEFT) x y txt
  */
  /*
  changed -> none:
    parent.remove_texture texture_
    build parent.tft  // do we maintain enough info to rebuild?
    parent.draw
*/
  set_text str/string -> none:
    txt = str
  //  changed

  // handle event -> none:
/*
class Spacing:

  space_ /int

  constructor .space_ /int:
  
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
*/
/** ---
A handler is a Command object, used since ["Blocks cannot be stored in instance fields"](https://docs.toit.io/language/blocks/).
Handler respond to some event, by invoking a specific action on a target.
The handlers have restricted value, but work for this toy demo.
(In Smalltalk, you might store a block in an event target (with necessary foriegn references) that respond directly to the events).
*/
/*
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
*/
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