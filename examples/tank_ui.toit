import .tank_ioctl show PIDServiceClient
import system.services show ServiceClient ServiceResourceProxy
import monitor
import .ui_elements

class FaceplateProxy extends ServiceResourceProxy:

  changed ::= monitor.Signal
  pv_sp_co_ := List

  constructor client/ServiceClient handle/int:
    super client handle

  on_notified_ .pv_sp_co_/any -> none:
    changed.raise

  pv -> float:
    return pv_sp_co_[0]
  sp -> int:
    return pv_sp_co_[1]
  co -> int:
    return pv_sp_co_[2]

main:

  pid_in := PIDServiceClient
  pid_out := pid_in.create_faceplate

  while true:
    pid_out.changed.wait
    print "lvl: $(%.1f pid_out.pv) sp: $pid_out.sp out: $pid_out.co"

/*
class Tank_UI:

  inputs /PIDServiceClient
  outputs /FaceplateProxy
  story /Story? := null

  homepage -> Displayable:
    return story.homepage

  constructor .inputs .outputs:
    story = create_story_

  create_story_ -> Story:
    story = Story home
    return story

  home -> Page:
    page := Page --name="PID"
    page.layout (Freeform [
                  Text --style=(Style --color=0x8f_ff_9f) --txt="-PV-" --x=50 --y=50, 
                  Text --style=(Style --color=0xff_9f_9f) --txt="-SP-" --x=50 --y=80, 
                  Text --style=(Style --color=0xff_ff_00) --txt="-CO-" --x=50 --y=110,
      ])
    return page
*/