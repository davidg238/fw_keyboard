import system.services show ServiceClient ServiceDefinition ServiceResource ServiceResourceProxy
import pid show Controller

/*
class TankResource extends ServiceResource:
  tank_/Tank_ServiceDefinition ::= ?
  task_ := null

  constructor .tank_ service/ServiceDefinition client/int:
    super service client --notifiable
    task_ = task:: notify_periodically

  notify_periodically -> none:
    while not Task.current.is_canceled:
      sleep --ms=1000
      notify_ []

  on_closed -> none:
    task_.cancel
*/
interface Tank_Service:
  static UUID  /string ::= "4359b59e-aa3f-4e79-b7c1-9023eb56c294"
  static MAJOR /int    ::= 0
  static MINOR /int    ::= 2

  level -> float               // input
  fill_valve -> int                 // output, to fill valve
  fill_valve= setting /int -> none  // output, to fill valve
  level_sp -> int
  level_sp= val/int -> none
  pid_manual -> bool                // answer if the loop is in manual/auto
  pid_manual= val/bool -> none      // switch control to manual, not according to PID control
  outflow -> int                    // simulated demand, in gallons per minute (gpm)


  static LEVEL /int ::= 0
  static FILL_VALVE_R /int ::= 1
  static FILL_VALVE_W /int ::= 2
  static LEVEL_SP_R /int ::= 3
  static LEVEL_SP_W /int ::= 4
  static PID_MANUAL_R /int ::=5
  static PID_MANUAL_W /int ::=6
  static OUTFLOW /int ::=7
  static GET_PROXY /int ::= 8

class Tank_ServiceClient extends ServiceClient implements Tank_Service:
  constructor --open/bool=true:
    super --open=open

  open -> Tank_ServiceClient?:
    return (open_ Tank_Service.UUID Tank_Service.MAJOR Tank_Service.MINOR) and this

  level -> float:
    return invoke_ Tank_Service.LEVEL []

  fill_valve -> int:
    return invoke_ Tank_Service.FILL_VALVE_R []

  fill_valve= setting/int -> none:
    invoke_ Tank_Service.FILL_VALVE_W setting

  level_sp -> int:
    return invoke_ Tank_Service.LEVEL_SP_R []

  level_sp= setting/int -> none:
    invoke_ Tank_Service.FILL_VALVE_W setting
    
  pid_manual -> bool:
    return invoke_ Tank_Service.PID_MANUAL_R []

  pid_manual= setting/int -> none:
    invoke_ Tank_Service.FILL_VALVE_W setting
    
  outflow -> int:
    return invoke_ Tank_Service.OUTFLOW []

  get_proxy -> TankProxy:
    handle := invoke_ Tank_Service.GET_PROXY []
    proxy := TankProxy this handle
    return proxy


class TankProxy extends ServiceResourceProxy:
  constructor client/ServiceClient handle/int:
    super client handle


class Tank_ServiceDefinition extends ServiceDefinition implements Tank_Service:
  level_ := 25.0
  fill_valve_ := 20
  level_sp_ := 25
  outflow_ := 7
  pid_manual_ := false

  tank_pid := Controller --kp=20.0 --ki=0.0 --kd=0.0 --min=0.0 --max=100.0

  constructor:
    super "deviceIO" --major=0 --minor=1
    provides Tank_Service.UUID Tank_Service.MAJOR Tank_Service.MINOR

  handle pid/int client/int index/int arguments/any -> any:
    if index == Tank_Service.LEVEL: return level
    if index == Tank_Service.FILL_VALVE_R: return fill_valve
    if index == Tank_Service.FILL_VALVE_W: fill_valve= arguments
    if index == Tank_Service.LEVEL_SP_R: return level_sp
    if index == Tank_Service.LEVEL_SP_W: level_sp= arguments
    if index == Tank_Service.PID_MANUAL_R: return pid_manual
    if index == Tank_Service.PID_MANUAL_W: pid_manual= arguments
    if index == Tank_Service.OUTFLOW: return outflow
  /*
    if index == Tank_Service.GET_PROXY:
      proxy := (resource client arguments) as TankResource
      return proxy
  */      
    unreachable

  level -> float: return level_

  fill_valve -> int: return fill_valve_

  fill_valve= argument/int -> none:
    fill_valve_ = argument

  level_sp -> int: return level_sp_

  level_sp= argument/int -> none:
    level_sp_ = argument

  pid_manual -> bool: return pid_manual_

  pid_manual= argument/bool -> none:
    pid_manual_ = argument

  outflow -> int: return outflow_

  /* Assume have 50gal irrigation buffer tank, filled via a valve that can deliver 0-10gpm.
    Outlet varies randomly between 5-15gpm.
    Run loop every 6 sec.
  */
  run_sim -> none:
    while true:
      outflow_ = (random 5 12)
      level_ = level_ - outflow_/10.0 + (fill_valve_ /10.0)/10.0
      level_ = min (max 0.0 level_) 50.0  // clamp tank level 0-50
      sleep --ms=6000


  run_control -> none:
    while not pid_manual_ :
        // need to enhance the pid controller for auto/manual transitions
        fill_valve = (tank_pid.update (level_sp - level) (Duration --s=2)).round
        sleep --ms=2000   // According to Nyquist, run at least 2x process speed


main:
  tank := Tank_ServiceDefinition
  tank.install

  task:: sim_task tank
  task:: control_task tank

sim_task tank:
  tank.run_sim

control_task tank:
  tank.run_control

