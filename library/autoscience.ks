// This script will automatically collect and transmit science data
// https://www.reddit.com/r/Kos/comments/4p8szx/wrote_a_program_to_automate_the_collection_and/

declare function ListScienceModules {
  declare local scienceModules to list().
  declare local partList to ship:parts.

  for thePart in partList {
    declare local moduleList to thePart:modules.
    for theModule in moduleList {
      if (theModule = "ModuleScienceExperiment") or (theModule = "DMModuleScienceAnimate") {
        scienceModules:add(thePart:getmodule(theModule)).
      }
    }
  }
  return scienceModules.
}

// GetSpecifiedResource takes one parameter, a search term, and returns the resource with that search term
declare function GetSpecifiedResource {
  declare parameter searchTerm.

  declare local allResources to ship:resources.
  declare local theResult to "".

  for theResource in allResources {
    if theResource:name = searchTerm {
      set theResult to theResource.
      break.
    }
  }
  return theResult.
}

// Given some science data to transmit,
// - verify that sufficient electrical capacity exists to attempt to transmit
// - wait until sufficient charge before transmitting
declare function WaitForCharge {
  declare parameter scienceData.

  // This value are from http://wiki.kerbalspaceprogram.com/wiki/Antenna
  // for the Communotron 16 antenna.
  // It'd be better if I could search for the antenna and get these values,
  // but they don't appear to be there
  declare local electricalPerData to 6.

  declare local electricalResource to GetSpecifiedResource("ElectricCharge").
  declare local chargeMargin to 1.05.
  declare local canTransmit to true.
  declare local neededCharge to scienceData:dataamount * electricalPerData * chargeMargin.

  if electricalResource:capacity > neededCharge {
    if (electricalResource:amount < neededCharge) {
      until electricalResource:amount > neededCharge {
        print "Waiting for sufficient electrical charge" at (1,2).
        print "Need: " + round(neededCharge, 1) + "  Have: " + round(electricalResource:amount, 1) + "   " at (1,3).
        wait 1.
      }
    }
  } else {
    print "Insufficient electrical capacity to attempt transmission" at (1,2).
    set canTransmit to false.
  }
  return canTransmit.
}

declare function TransmitScience {
  declare parameter scienceModule.

  // This value is from http://wiki.kerbalspaceprogram.com/wiki/Antenna
  // for the Communotron 16 antenna.
  // It'd be better if I could search for the antenna and get these values,
  // but they don't appear to be there
  declare local timePerData to 10/3.
  declare local transmissionMargin to 1.05.

  // Figure out how long it'll take to transmit data.
  // Add 1 second for margin

  declare local transmissionTime to scienceModule:data[0]:dataamount / timePerData * transmissionMargin.

  print "Transmitting data                   " at (1,2).
  scienceModule:transmit().

  declare local startTime to time:seconds.
  until time:seconds > startTime + transmissionTime {
    print round(startTime + transmissionTime - time:seconds,1) + " seconds to go                " at (1,3).
    wait 0.2.
  }
}

declare function PerformScienceExperiments {
  declare local scienceModules to ListScienceModules().

  clearscreen.
  for theModule in scienceModules {
    if theModule:hasdata {
      print "Existing data found in " + theModule:part:title at (1,1).
      if WaitForCharge(theModule:data[0]) and (theModule:data[0]:transmitvalue > 0.1) {
        TransmitScience(theModule).
      }
    }
  }

  for theModule in scienceModules {
    clearscreen.
    print "Working with: " + theModule:part:title at (1,1).
    wait 0.1.
    if (not theModule:inoperable) and (theModule:rerunnable) and (not theModule:hasdata) {
      print "Collecting data                         " at (1,2).
      theModule:deploy().
      set starttime to time:seconds.
      wait until (theModule:hasdata) or (time:seconds > starttime + 10).
      if (theModule:HASDATA) and (WaitForCharge(theModule:data[0])) and (theModule:data[0]:transmitvalue > 0.1) {
        TransmitScience(theModule).
      }
    }
    wait 0.1.
  }
  print "All data collection and transmission complete".
}

PerformScienceExperiments().
