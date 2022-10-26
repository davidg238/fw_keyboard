import .tank_ioctl show Tank_ServiceClient

main:
  tank := Tank_ServiceClient

  // io.fill_valve 100

  print "lvl: $(%.1f tank.level) sp: $tank.level_sp out: $tank.fill_valve"


  
