// Launch script which using kOS


// Helper functions
function angleToUp {
  set sVec to SHIP:PROGRADE:VECTOR.
  set uVec to UP:VECTOR.
  set cosTheta to (uVec * sVec) / (uVec:MAG * sVec:MAG).
  set theta to ARCCOS(cosTheta).
  return theta.
}

function pitch {
  parameter theta.
  return ANGLEAXIS(theta, SHIP:PROGRADE:STARVECTOR) * SHIP:PROGRADE.
}

// Initial setup
// SAS doesn't seem to help...
// SAS ON.
SET SASMODE TO "STABILITYASSIST".

// Config vars
set gravityTurnVel to 100.0.
set gravityTurnMult to 10.
// Follow the prograde vector round after the gravity turn, but ahead
// by an offset of this many degrees
set gravityTurnFollowRetard to 1.5.
set gravityTurnDirection to 90. // East
set desiredOrbitAlt to 100000.

set countdownLength to 5.

// State vars
set currentStage to 0.
set currentThrottle to 0.75.
set currentTurn to 90.
set outputTurn to false.

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

WHEN MAXTHRUST = 0 THEN {
  set currentStage to currentStage + 1.

  print "Moving to stage " + currentStage.

  // Execute the stage
  STAGE.
  // Preserve this when clause
  PRESERVE.
}

UNTIL APOAPSIS >= desiredOrbitAlt {

// TODO: Add checks for minimum altitude
  IF SHIP:VELOCITY:SURFACE:MAG < gravityTurnVel {

    // Straight up, 'in the east direction'
    LOCK STEERING TO HEADING(gravityTurnDirection, 90).
    
  } ELSE {
    set currentTurn to
        90 - (SHIP:VELOCITY:SURFACE:MAG / gravityTurnVel) * gravityTurnMult.

    IF currentTurn <= 55.0 {
      // Track the prograde as gravity pulls it down

      // Check that the prograde has followed
      if angleToUp < 60.0 {
        //LOCK STEERING TO HEADING(gravityTurnDirection, 45.0).
        print "Pitching forwards slightly        " at (0, 15).
        set newHeading to pitch(1.5).
        LOCK STEERING TO newHeading.

      } else {
        print "Pitching forwards to complete turn" at (0,15).
        // Get the ships prograde, and aim some degrees above it
        // Get the rotation vector
        //set newHeading to pitch(-gravityTurnFollowRetard).
        
        set newHeading to pitch(gravityTurnRotate)
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

