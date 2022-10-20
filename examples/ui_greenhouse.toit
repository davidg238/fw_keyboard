// Copyright (C) 2022 Ekorau LLC
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the LICENSE file.

import solar_position show *
import encoding.json show *


US_85224_LONGITUDE ::= 33.3062
US_85224_LATITUDE  ::= 111.8413

/// The same IDs are used in the web_ui
HOUR ::= "hour"

IN_TEMP ::= "inside_temperature"
IN_HUM ::= "inside_humidity"
IN_LUM ::= "inside_luminance"
IN_AIRQ ::= "inside_air_quality"

OUT_TEMP ::= "outside_temperature"
OUT_HUM ::= "outside_humidity"
OUT_WINDSPEED ::= "outside_windspeed"
OUT_WINDDIRECTION ::= "outside_winddirection"
OUT_RAINRATE ::= "outside_rainrate"

FAN_SPEED_SP ::= "fan_speed_sp"
FAN_SPEED ::= "fan_speed"
PUMP_RUN ::= "pump_run"
PUMP_RNG ::= "pump_rng"

DOOR ::= "door"

PANEL_V ::= "panel_voltage"
BATTERY_V ::= "battery_voltage"
LOAD_I ::= "load_current"
MAINS ::= "mains_power"

d_command ::= "device:command"
d_telemetry ::= "device:telemetry"


class Greenhouse_Sim:

  hour := 6 // start simulation at 6am, a decent hour
  sunrise := 7
  sunset := 18

  sim := [-6, -7, -8, -9, -10, -11, -8, -4, -2, -1, 2, 4, 6, 10, 13, 15, 14, 10, 8, 6, 5, 2, -1, -3,]

  world := {
    HOUR: 0,
    IN_TEMP: 60,
    IN_HUM: 30,
    IN_LUM: 0,
    IN_AIRQ: 0,
    OUT_TEMP: 0,
    OUT_HUM: 0,
    OUT_WINDSPEED: 0,
    OUT_WINDDIRECTION: "SSW",
    OUT_RAINRATE: 0,
    PANEL_V: 0,
    BATTERY_V: 12,
    LOAD_I: 230,
    MAINS: 1,
    PUMP_RNG: 0,
    FAN_SPEED: 0,
    DOOR: 0,
  }

  outside_baseline := {
    OUT_TEMP: 50,
    OUT_HUM: 10,
    OUT_WINDSPEED: 1,
    OUT_WINDDIRECTION: "SSW",
    OUT_RAINRATE: 0,
  }

  invoke output/string value/any -> none:
    if output == PUMP_RUN: 
      world[PUMP_RNG] = value // assume if pump commanded to run, it does
    else if output == FAN_SPEED_SP:
      world[FAN_SPEED] = value // assume speed = SP
    //todo: send immediate confirmation to UI

  is_light -> bool:
    return (hour>=sunrise) and (hour<=sunset)

  evap_sys_on -> bool:
    return ((world[PUMP_RNG]>0) and (world[FAN_SPEED] > 10))? true: false

  tick -> none:
    hour += 1
    hour = hour > 23? 0: hour

  update_world -> none:
    tick

    world[HOUR] = hour
    // inside
    world[IN_TEMP] = world[OUT_TEMP] + (evap_sys_on? -15: 0 )
    world[IN_HUM] = world[OUT_HUM] + (evap_sys_on? 30: 5 )
    // outside
    world[OUT_TEMP] = outside_baseline[OUT_TEMP] + sim[hour]
    // power
    world[PANEL_V] = 24 * (is_light? 1: 0)

    str := (encode world).to_string
    // print str
    publish d_telemetry str
    print hour

  dispatch_commands -> none:

    subscribe d_command --blocking --auto_acknowledge: | msg/Message |
      commands := decode msg.payload
      commands.do: |key value|
        invoke key value
        print "k: $key, v: $value"

  t1 -> float:
    return world[IN_TEMP]

  fs -> float:
    return world[FAN_SPEED]

  fs= val /float -> none:
    world[FAN_SPEED] = val

  device_id -> string:
    return "a60cd8c8-e99c-4c86-ae28-abec3b8a5a78"  //todo, find api call
  
  network_address -> string:
    return "192.168.0.123" //todo, replace

main:

  clock_tick := Duration --s=5
  greenhouse := Greenhouse_Sim

  task::
    greenhouse.dispatch_commands

  task::
    clock_tick.periodic:
      greenhouse.update_world
