import .tank_ioctl show Tank_ServiceClient

main:
  tank := Tank_ServiceClient

  // io.fill_valve 100

  print "lvl: $(%.1f tank.level) sp: $tank.level_sp out: $tank.fill_valve"


  
/*
class Greenhouse_UI:

  greenhouse := Greenhouse
  story /Story? := null

  homepage -> Displayable:
    return story.homepage

  constructor:
    story = create_story_

  create_story_ -> Story:
    story = Story home
    story.add pid
    story.add history
    story.add wifi
    return story

  home -> Page:
    page := Page --name="Home"
    page.layout (Column [
      Text --txt="Greenhouse Control",
    ])
    return page

  pid -> Page:
    page := Page --name="PID"
    page.layout (Column [
        PID_Faceplate --name="Tank" --input=greenhouse.tank_level --output=greenhouse.tank_fill --sp=greenhouse.tank_sp
      ])
    return page

  history -> Page:
    page := Page --name="Tank"  
    page.layout (Column [
        Histogram --name="Level" --input=greenhouse.tank_level
      ])
    return page

  wifi -> Page:
    page := Page --name="Home"
    page.layout (Column --style=[Align.left, Spacing 20] [
      Row [
        Text --txt="Device ID:",
        Spacing 2,
        Text --txt=greenhouse.device_id
      ],
      Row [
        Text --txt="Address",
        Spacing 2,
        Text --txt=greenhouse.network_address
      ],      
    ])
    return page
*/