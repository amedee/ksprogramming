COPYPATH("0:/library/autoscience.ks", "1:/").
WAIT 0.1.
RUNPATH("1:/autoscience.ks").

PRINT "Counting down:".
FROM {local countdown is 10.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "..." + countdown.
    WAIT 1.
}

LOCK STEERING TO HEADING(90, 90).

PRINT "Launching!".
STAGE.

WAIT 1.
RUNPATH("1:/autoscience.ks").

WAIT UNTIL STAGE:SOLIDFUEL < 0.1.
WAIT 0.1.
PRINT "Discarding boosters.".
STAGE.

WAIT UNTIL SHIP:ALTITUDE > 18000.
WAIT 0.1.
RUNPATH("1:/autoscience.ks").

WAIT UNTIL SHIP:ALTITUDE > 70000.
WAIT 0.1.
RUNPATH("1:/autoscience.ks").

WAIT UNTIL SHIP:ALTITUDE > 250000.
WAIT 0.1.
RUNPATH("1:/autoscience.ks").
