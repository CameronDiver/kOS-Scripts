// A hover script to test the lib_pid loop
clearscreen.
set seekAlt to 30.

set ship:control:pilotmainthrottle to 0.

// Import libraries
run lib_physics.ks.
run lib_pid.ks.

declare function display_block {
  declare parameter
    startCol, startRow. // define where the block of text should be positioned

  print round(seekAlt,2) + "m    " at (startCol,startRow).
  print round(alt:radar,2) + "m    " at (startCol,startRow+1).
  print round(eqThrust,3) + "      " at (startCol,startRow+2).
  print round(offset,3) + "      " at (startCol,startRow+3).
  print round(throttle,3) + "      " at (startCol,startRow+4).
}.

until ship:availablethrust > 0 {
  wait 0.5.
  stage.
}.

// eqThrust the throttle setting that would exactly equal out gravity
set eqThrust to physics_localFg() / ship:availablethrust.

// offset is the offset to the eqThrust to use.
// This is the value which will be tuned by the PID loop
set offset to 0.

lock throttle to eqThrust + offset.

set hoverPID to pid_setup(0.02, 0.05, 0.05).

until ship:altitude > 10000 {
  set offset to pid_seek(hoverPID, seekAlt, alt:radar).
  lock throttle to eqThrust + offset.

  display_block(0,0).

  wait 0.001.
}
