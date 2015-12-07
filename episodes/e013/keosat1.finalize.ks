// KeoSat1 Adjustment Script
// Kevin Gisi
// http://youtube.com/gisikw

NOTIFY("Performing minor adjustments").

// Finalize orbital period
LOCK STEERING TO RETROGRADE.
WAIT 10.
LOCK THROTTLE TO 0.01.
WAIT UNTIL SHIP:OBT:PERIOD <= 21600.
LOCK THROTTLE TO 0.

// Align for sunlight
LOCK STEERING TO HEADING(0,0).
WAIT 60.
