// Launch script using kOS on KSP
// This script does not execute the most efficient of launches,
// but is designed to work as best as possible with the widest 
// range of crafts, and it does that pretty well.


// Helper functions
function angleToUp {
  set sVec to SHIP:PROGRADE:VECTOR:NORMALIZED.
  set uVec to UP:VECTOR:NORMALIZED.
  set cosTheta to (uVec * sVec) / (uVec:MAG * sVec:MAG).
  set theta to ARCCOS(cosTheta).
  return theta.
}
// Get a pitch direction given an angle
function pitch {
  parameter theta.
  return ANGLEAXIS(theta, SHIP:PROGRADE:STARVECTOR:NORMALIZED) * SHIP:PROGRADE:VECTOR:NORMALIZED.
}

// Check if the craft needs to be staged, works with asparagus
// staging and standard
function stageIfNeeded {
  if SHIP:MAXTHRUST = 0 {
    stage.
  } else {
    // Get all engines
    set flamed to 0.
    list ENGINES in engines.
    for eng in engines {
      if eng:FLAMEOUT {
        set flamed to flamed + 1.
      }
    }

    if flamed > 0 {
      stage.
    }
    
  }
}

// Initial setup
// SAS doesn't seem to help...
SAS ON.
SET SASMODE TO "STABILITYASSIST".

// Config vars
set gravityTurnVel to 100.0.
set gravityTurnMult to 7.5.
// Follow the prograde vector round after the gravity turn, but behind
// by an offset of this many degrees
set gravityTurnRotate to 1.0.
set gravityTurnDirection to 90. // East
set desiredOrbitAlt to 100000.

set countdownLength to 5.

// State vars
set currentStage to 0.
set currentThrottle to 1.00.
set currentTurn to 90.
set outputTurn to false.
set outputPitch to false.

clearscreen.

// Run a countdown loop before launching to alleviate
// those "forgotten to add x" moments
print "Readying for launch...".

FROM {
  local countdown is countdownLength.
} UNTIL countdown = 0 STEP {
  set countdown to countdown - 1.
} DO {
  print "--" + countdown + "--".
  WAIT 1.
}

// Point the vessel straight up
LOCK STEERING TO UP.

LOCK THROTTLE TO currentThrottle.

// Launch the vessel
print "...Liftoff!".

UNTIL APOAPSIS >= desiredOrbitAlt {

  stageIfNeeded.

  // TODO: Add checks for minimum altitude
  IF SHIP:VELOCITY:SURFACE:MAG < gravityTurnVel {

    // Straight up, 'in the east direction'
    LOCK STEERING TO HEADING(gravityTurnDirection, 90).
    
  } ELSE {
    set currentTurn to
        90 - (SHIP:VELOCITY:SURFACE:MAG / gravityTurnVel) * gravityTurnMult.

    IF currentTurn <= 45.0 {
      // Track the prograde as gravity pulls it down

      // Check that the prograde has followed
      // If the prograde vector hasn't followed round yet,
      // just let gravity pull it down by thrusting prograde
      if angleToUp < 55.0 {
        LOCK STEERING TO PROGRADE.

      } else {
        if not outputPitch {
          print "Pitching slightly backwards as gravity pulls us down.".
          set outputPitch to true.
        }
        
        set newHeading to pitch(-gravityTurnRotate).
        LOCK STEERING TO newHeading.

        // If the above code isn't working, this may, but is less
        // efficient.
        //LOCK STEERING TO SHIP:PROGRADE.
      }
    } ELSE {

      IF not outputTurn {
        set outputTurn to true.
        PRINT "Initiating gravity turn.".
      }

      LOCK STEERING TO HEADING(gravityTurnDirection, currentTurn).
    }
  }
}


print "Apoapsis is above " + round(desiredOrbitAlt, 2) + "m, stopping.".
LOCK THROTTLE TO 0.0.