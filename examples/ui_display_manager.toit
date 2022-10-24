// Copyright 2021 Ekorau LLC

import .ui_elements show Story Page TYP_10 Eventable Displayable
import pixel_display.true_color show BLACK WHITE
import fw_keyboard show Event

class DisplayManager implements Eventable:

  display := ?
  ctx := null
  width := ?
  height := ?

  story_ := null
  page_ := null

  constructor --.display --.width --.height: 
/*
  handle event/Event:
      current.handle event

  navigate_to id/string -> none:
    pages_.do: 
      if (it.id == id):
        show it
        return
*/
  show page /Displayable:
    page_ = page
// Set the minimum defaults to allow drawing to proceed on the context
// where should this happen -- must only happen once to allow unrestricted nesting of layouts
    display.remove_all   
    display.background = BLACK
    ctx = display.context --landscape --color=WHITE --font=TYP_10
// --------------------    
    /*
      the parent is passed for interactivity
      the display, so textures can be added to the scene
      the context, so children can create their contexts, based on the parent context
    */
    page_.build this display ctx
    display.draw  // the scene is built

  show_story story /Story -> none:
    story_ = story
    show story.homepage

