import pid show Controller


class Greenhouse:

  tank_level := 22.0
  tank_sp := 70

  tank_pid := Controller --kp=0.7 --ki=0.3 --kd=0 --min=0.0 --max=100.0

  device_id -> string:
    return "b3ae3f26-4a19-4e52-8d5b-348d497b767a"

  network_address -> string:
    return "192.168.0.245"

  run:
    while true:
        tank_fill := tank_pid.update (tank_level-tank_sp) (Duration --s=1)
        sleep --ms=1000

/*
  dispatch_commands -> none:

    subscribe d_command --blocking --auto_acknowledge: | msg/Message |
      commands := decode msg.payload
      commands.do: |key value|
        invoke key value
        print "k: $key, v: $value"

main:

  clock_tick := Duration --s=5
  greenhouse := Greenhouse_Sim

  task::
    greenhouse.dispatch_commands

  task::
    clock_tick.periodic:
      greenhouse.update_world
*/