import fw_keyboard show FW_Keyboard

main:

  print "starting ..."

  fw_kbd := FW_Keyboard

  fw_kbd.on
  print "fw_kbd.on ... done"
  
  // print "keyboard status: $(fw_kbd.kbd.version)"  //todo, fails

  print "... done"      