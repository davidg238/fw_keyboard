// Copyright 2021 Ekorau LLC

import .ui_elements show Page
import fw_keyboard show Event

class DisplayManager:

  display := ?
  pages_ := null
  current := null

  constructor --.display:

  handle event/Event:
      current.handle event

  navigate_to id/string -> none:
    pages_.do: 
      if (it.id == id):
        show it
        return

  show_pages pages/List:
      pages_ = pages
      show pages_.first

  show page/Page:
      current = page
      current.build this
      current.draw

