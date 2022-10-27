import system.services show ServiceClient ServiceDefinition ServiceResource ServiceResourceProxy
import pid show Controller
import .tank_ui show FaceplateProxy


class PIDController:
  //todo: the pid parameters are to be settable by a separate tuning service
  //todo: implement auto/manual, CO raise/lower
  //todo: revise PID algorithm: setpoint tracking in manual + avoid integral windup
  pv := 25.0
  sp := 25
  co := 20
  outflow_ := 7
  am := false


  pid_ := Controller --kp=20.0 --ki=0.0 --kd=0.0 --min=0.0 --max=100.0
  /* Assume have 50gal irrigation buffer tank, filled via a valve that can deliver 0-10gpm.
    Outlet varies randomly between 5-15gpm.
    Run loop every 6 sec.
  */
  run_sim -> none:
    while true:
      outflow_ = (random 5 12)
      pv = pv - outflow_/10.0 + (co /10.0)/10.0
      pv = min (max 0.0 pv) 50.0  // clamp tank level 0-50
      sleep --ms=6000


  run_control -> none:
    while not am :
        // need to enhance the pid controller for auto/manual transitions
        co = (pid_.update (sp - pv) (Duration --s=2)).round
        sleep --ms=2000   // According to Nyquist, run at least 2x process speed

class PIDResource extends ServiceResource:

  controller_ /PIDController := ?
  task_ := null

  constructor .controller_ service/ServiceDefinition client/int:
    super service client --notifiable
    task_ = task:: notify_periodically

  notify_periodically -> none:
    while not Task.current.is_canceled:
      sleep --ms=1000
      notify_ [controller_.pv, controller_.sp, controller_.co, controller_.am, controller_.outflow_ ]

  on_closed -> none:
    task_.cancel

/*
Faceplate refers to the UI for the PID controller.
Minimally shows Process Variable (PV), Setpoint (SP) and Control Output (CO),
with provisions for Auto/Manual (AM) and Output Raise (OR)/Output Lower (OL)
when the controller is in manual.
*/
interface PIDService:
  static UUID  /string ::= "4359b59e-aa3f-4e79-b7c1-9023eb56c294"
  static MAJOR /int    ::= 0
  static MINOR /int    ::= 2

  sp= val/int -> none
  co= setting /int -> none  // controlled output
  am= val/bool -> none      // switch control to manual, not according to PID control

  static PV /int ::= 0
  static CO_R /int ::= 1
  static CO_W /int ::= 2
  static SP_R /int ::= 3
  static SP_W /int ::= 4
  static AM_R /int ::=5
  static AM_W /int ::=6
  static FLOW_OUT /int ::=7
  static CREATE_FACEPLATE /int ::= 8

class PIDServiceClient extends ServiceClient implements PIDService:
  constructor --open/bool=true:
    super --open=open

  open -> PIDServiceClient?:
    return (open_ PIDService.UUID PIDService.MAJOR PIDService.MINOR) and this

  sp= setting/int -> none:
    invoke_ PIDService.SP_W setting

  co= setting/int -> none:
    invoke_ PIDService.CO_W setting

  am= setting/int -> none:
    invoke_ PIDService.AM_W setting
    
  create_faceplate -> FaceplateProxy:
    handle := invoke_ PIDService.CREATE_FACEPLATE []
    proxy := FaceplateProxy this handle
    return proxy


//todo: the variables need to be renamed to be generic, rather than for this demo
//todo: the implementation should be parameterized, so that multiple PIDs can be on a single device
class PIDServiceDefinition extends ServiceDefinition implements PIDService:

  controller := PIDController

  constructor:
    super "deviceIO" --major=0 --minor=1
    provides PIDService.UUID PIDService.MAJOR PIDService.MINOR

  handle pid/int client/int index/int arguments/any -> any:
    if index == PIDService.CO_W: co= arguments
    if index == PIDService.SP_W: sp= arguments
    if index == PIDService.AM_W: am= arguments
    if index == PIDService.CREATE_FACEPLATE: 
      resource := PIDResource controller this client
      return resource
    unreachable

  sp= argument/int -> none:
    controller.sp = argument

  co= argument/int -> none:
    controller.co = argument

  am= argument/bool -> none:
    controller.am = argument


main:
  tank := PIDServiceDefinition
  tank.install

  task:: sim_task tank.controller
  task:: control_task tank.controller


sim_task tank_pid:
  tank_pid.run_sim

control_task tank_pid:
  tank_pid.run_control

