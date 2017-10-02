// Describe Takeoff Process
CLEARSCREEN.
BRAKES ON.
// Just delete this part from here {
PRINT "Simple routine to put a spaceplane in a".
PRINT "relatively cirularised orbit".
PRINT "By Reddit.com/u/Senior_Engineer".
PRINT "Use it however you like!".
Wait 7.
CLEARSCREEN.
// } TO here

// Usage Instructions:
// Save to the \Ships\Script folder in your KSP folder for example in steam C:\Program Files (x86)\Steam\steamapps\common\Kerbal Space Program\Ships\Script\takeoff.ks (file name must end in .ks)
// Create a spaceplane with two stages, air breathing engines in stage 1 and vacuum engines in stave 2
// Make sure it has a KOS module on board, or install "KOS for Everyone" mod
// Launch the vehicle to the run way, turn on the brakes
// Right click the KOS module or command pod and select "Open Terminal"
// Type switch to 0.
// press enter
// Type run takeoff.
// press enter
// sit back and watch everything work perfectly, or end with hilarious crashes!
// Enjoy!


// Things still to do:
// Switch on Radiators when speed greater than 1km/s and in atmosphere (figure something out for NERVS?)
// Switch off radiators when out of atmosphere
// Deploy solar panels when out of atmosphere
// Retract solar panels when below apoapsis and descending and periapsis is below 70k
// Write the landing part and probably it to another function
// Figure out how to load the program in KOS and allow the user to trigger the functions for takeoff and deorbit/landing
// Max Q handling/reduction
// GForce handling/reduction


// Declare Start of runway as Touchdown Zone and current altitude as Touchdown altitude for later when we are trying to land
SET TDZ to SHIP:GEOPOSITION.
SET TDA to ALT:RADAR.
// Function Takeoff so you can call it from an existing program and isolate it
FUNCTION TAKEOFF {
	
// Throttle Up
LOCK THROTTLE TO 1.
LIGHTS ON.
// Count Down
FROM {local countdown is 5.} UNTIL countdown = 0 STEP {SET countdown to countdown - 1.} DO {
    PRINT "Holding for Takeoff:" AT(0,0).
    PRINT "                      " AT(0,1).
    // bodgy clear line
    PRINT "..." + countdown AT(0,1).
    WAIT 1.
	}
PRINT "...0" AT(0,1).
// Bodgy hack to print a zero and not have it just stay saying 1
PRINT "Cleared for Takeoff" AT (0,2).
// Trying to put meaningful language in to the outputs
// Set heading to not pitch down and hopefully not crash as we taxi
// Also set all steering inputs to this variable for ease of use
SET MyHeading TO HEADING(90,1).
LOCK STEERING TO MyHeading.
// Stage change to action group 1 later maybe
STAGE.
PRINT "Activating Jet Engines" AT (0,3).
// Spool up some initial thrust I could make this trigger the brakes when they are overwhelmed by the thrust
PRINT "Spooling" AT (0,4).
// Bodgy spooling hack because "thrust" isn't able to be queried and I don't know if maxthrust will work

// Taxi
UNTIL SHIP:VELOCITY:SURFACE:MAG > 151 {

	IF SHIP:VELOCITY:SURFACE:MAG < 0.5 {
	// Do anything you want to do while spooling and prior to taxiing here
	}

	ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 0.5 AND SHIP:VELOCITY:SURFACE:MAG < 1{
	BRAKES OFF.
	// Hopefully turns the brakes off as soon as the thrust from the spool up has defeated them
	}

	ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 1 AND SHIP:VELOCITY:SURFACE:MAG < 150 {
	PRINT "Taxiing" AT (0,5).
	}

	ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 150 {
	PRINT "Rotate at Pitch of 15" AT (0,6).
	LOCK MyHeading TO HEADING(90,15).
	}

	ELSE {
	PRINT "Unhandled" AT (0,30).
	}
}

UNTIL SHIP:ALTITUDE > 20000 {

	IF SHIP:ALTITUDE >= 72 AND SHIP:ALTITUDE < 150 {
	// Tell us when we are almost or just off the ground hopefully
	PRINT "Liftoff" AT (0,7).

	}

//Gear Up
	ELSE IF SHIP:ALTITUDE >= 150 AND SHIP:ALTITUDE < 250 {
	// Lift the gear when we are 150m up
	GEAR OFF.
	PRINT "Gear Up" AT (0,8).
	}

//Climb
	ELSE IF SHIP:ALTITUDE >= 250 AND SHIP:ALTITUDE < 2000 {
	// Climb conservatively first to build speed
	// All these heading changes are probably detrimental, but this is mostly an exercise in ensuring everything works
	LOCK MyHeading TO HEADING(90,10).
	PRINT "Accelerating at Pitch of 10" AT (0,9).
	}

	ELSE IF SHIP:ALTITUDE >= 2000 AND SHIP:ALTITUDE < 5000 {
	// Lets get out of this thick atmosphere quick
	LOCK MyHeading TO HEADING(90,25).
	PRINT "Climbing at Pitch of 25" AT (0,10).
	}


	ELSE IF SHIP:ALTITUDE >= 5000 AND SHIP:ALTITUDE < 10000 {
	// Probably starting to lose thrust, reduce pitch and accelerate again
	LOCK MyHeading TO HEADING(90,15).
	PRINT "Reducing Pitch To 15" AT (0,11).
	}

// Level
	ELSE IF SHIP:ALTITUDE >= 10000 AND SHIP:ALTITUDE < 19000 {
	// Definately starting to lose thrust, ruduce pitch to allow more acceleration
	LOCK MyHeading TO HEADING(90,12.5).
	PRINT "Reducing Pitch to 12.5" AT (0,12).
	}	

	ELSE IF SHIP:ALTITUDE >= 19000 AND SHIP:ALTITUDE < 20000 {
	// This is right at the cusp of the air breathing engines in my setup (whiplash engine fed by shock cones) so lets flatten out again
	LOCK MyHeading TO HEADING(90,10).
	PRINT "Reducing Pitch to 10" AT (0,13).
	}		

}

// Stage change to AG2 later
STAGE.
PRINT "Activating Rocket Engines" AT (0,13).
PRINT "Activating RCS" AT (0,14).
RCS ON.
PRINT "Burning to Achieve 100,000m Apoapsis" AT(0,15).
PRINT "RCS ON" AT (0,21).
// Because rockets are much more powerful and the air is thin lets get out of the atmosphere as much as we can
PRINT "Raising Pitch to 20" AT(0,16).
LOCK MyHEading TO HEADING(90,20).

// Burn Until Apoapsis Achieved
SET TweakCount TO 0.
// Set in atmosphere warp to physics
SET KUNIVERSE:TIMEWARP:MODE to "PHYSICS".
UNTIL SHIP:ALTITUDE > 70000 {
	// Coast/Tweak until 70000
	IF SHIP:APOAPSIS >= 100000 {
		// Ship has reached apoapsis warp 2x
		LOCK THROTTLE TO 0.
		PRINT "Coasting to Edge of Atmosphere" AT (0,18).
		SET TweakCount TO 1.
		// Turns out it's a REALLY bad idea to physics warp like this take off the comments if you're brave
		// SET KUNIVERSE:TIMEWARP:WARP to 1.
		// WAIT 0.
		// Wait one physics tick before doing anything else
		// Using warp; 0 is 1x, 1 is 2x, 2 is 3x, 3 is 4x in "physics" mode
	}
	ELSE IF SHIP:APOAPSIS < 100000 and TweakCount = 0 {
	// We are still pushing apoapsis up
		LOCK THROTTLE TO 1.
	}
	// Reduce overshoots by only partially throttling after initial apoapsis 100000
	Else IF SHIP:APOAPSIS < 100000 and TweakCount > 0 {
		// Apoapsis has declined due to drag, stop warp and tweak with micro burn
		LOCK THROTTLE TO 0.005.
		PRINT "Tweaking Apoapsis" AT (0,19).
		// SET KUNIVERSE:TIMEWARP:WARP TO 0.
		// WAIT 0.
		// Wait one physics tick before doing aything else
	}
	// Reduce drag and burn prograde when atmosphere mostly gone
	IF SHIP:ALTITUDE > 40000 {
		LOCK MyHeading TO SHIP:PROGRADE.
		PRINT "Burning Prograde" AT (0,17).
	}
}
SET IveBeenToSpace TO 1. 
// Safety variable to put in to entire proceedure later to ensure it doesn't run again when returning from space
LIGHTS OFF.
PRINT "Apoapsis Achieved " + ROUND(SHIP:APOAPSIS,0)+ "m" AT(0,20).
LOCK THROTTLE TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
//RCS off for coast to stop impacting on APO/PERI
RCS OFF.
PRINT "RCS OFF" AT (0,21).
// As we are out of the atmosphere change warp mode to rails
SET KUNIVERSE:TIMEWARP:MODE to "RAILS".

// Circularise

UNTIL SHIP:PERIAPSIS > 90000 {
	
	IF SHIP:ALTITUDE >= 70000 AND SHIP:ALTITUDE < 95000 {
	PRINT "Coasting to Circularisation Burn" AT (0,22).
	// Because we are coasting lets increase our time factor to 10x (warp to 2 in rails)
	SET KUNIVERSE:TIMEWARP:WARP to 2.
	WAIT 0.
	// Wait one physics tick before doing anything else
	}

	ELSE IF SHIP:ALTITUDE >= 95000 AND SHIP:ALTITUDE < 97000 {
	// Becasue we are close tou our circulisation burn lets go back to normal time (warp to 0)
	// This will allow 2000m to reorient to prograde and adjust the APO back to 100k
	SET KUNIVERSE:TIMEWARP:WARP to 0.
	// WAIT 0.
	// Wait one physics tick before doing anything else
	// We will turn the RCS back on here to make sure we can get reoriented in time
	RCS ON.
	PRINT "       " AT (0,21).
	PRINT "RCS ON" AT (0,21).
	LOCK MyHeading TO SHIP:PROGRADE.
	}

	ELSE IF SHIP:ALTITUDE >= 99990 {
	// Bodgy time to burn becasue burning at the apoapsis is giving me strange results
	LOCK THROTTLE TO 1.
	PRINT "Circularising" AT (0,23).
	}

	IF SHIP:PERIAPSIS < 0 {
	PRINT "Crashing" AT (0,24).
	}

	ELSE IF SHIP:PERIAPSIS > 0 AND SHIP:PERIAPSIS < 70000 {
	PRINT "          " AT (0,24).
	PRINT "Suborbital" AT (0,24).
	}


	ELSE IF SHIP:PERIAPSIS >= 70000 {
	PRINT "          " AT (0,24).
	PRINT "Orbital" AT (0,24).
	}

	IF SHIP:APOAPSIS < 100000 AND SHIP:ALTITUDE < 97000 AND SHIP:HEADING = SHIP:PROGRADE {
	// This is to correct for minor apoapsis drops during positioning prograde
	LOCK THROTTLE TO 0.001.
	}

	ELSE IF SHIP:APOAPSIS >= 100000 AND SHIP:ALTITUDE < 97000 {
	// Once we have got the apoapsis back to 100k let's turn off the throttle
	LOCK THROTTLE TO 0.
	}

}

// Cleanup and script end below
RCS OFF.
LOCK THROTTLE TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
PRINT "Circularised" AT (0,24).
PRINT "Function TAKEOFF Completed" AT(0,25).
WAIT 10.
Clearscreen.

}
// This brace ends the function


// Calls the function once it has loaded in to KOS
TAKEOFF().

// Function De-Orbit

// Set Retrograde
// Burn Opposite Touchdown Zone
// Set Periapsis Height ~ 25000

// End Funtion

// Function Descend
// Decelerate to below 1km/s
// Descend to below 18000 m
// Set Heading 90 -5
// Set target Altitude at distance from TDZ as maths formula
// Set target Speed 250ms
// Descend and Decelerate
// Increase AoA
// Gear Down
// Kill Engine
// Touchdown at TDZ & TDA hopefully
// Brake

// End Function