#echo "argc = $argc"
if { $argc < 1 } {
    puts "The DO file requires one arguments: "
    puts "Please try again with the following syntax: "
    puts "do doFileName.do TB_Name"
    puts "In my case is:   do TRFdo.do VirtualTester_TRF_MBIST"
} else {
    project compileall

    vsim -t ns work.$1

    if {[file exists wave.do]} {
        do wave.do
    }
	
	restart -force

    set logFile [open "log.txt" w+]

    source faultInjection_TRF.tcl 
    when {stopSimulation} {
        puts $logFile "Simulation is done successfully :) @ $now ns"
		
		set delta_time [expr [clock seconds]-$start_time]
		set delta_minutes [expr $delta_time / 60]
		set delta_hours [expr $delta_time / 3600]
	
		set sim_hour $delta_hours
		set sim_min  [expr $delta_minutes - ($delta_hours*60)]
		set sim_sec  [expr $delta_time - ($delta_minutes*60)]
	
		puts $logFile "SIMULATION TIME: $sim_hour h & $sim_min min & $sim_sec sec"
		puts $logFile "All TIME Units => $delta_time sec ~ $delta_minutes min ~ $delta_hours h"
		
		close $logFile
		
		stop
    }

    set start_time [clock seconds]

    run -all
}