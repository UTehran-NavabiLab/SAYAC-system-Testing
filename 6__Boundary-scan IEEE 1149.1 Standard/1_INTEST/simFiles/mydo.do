#******************************************************************************
#	Filename:		mydo.tcl
#	Project:		SAYAC Testing 
#   Version:		0.90
#	History:
#	Date:			20 June 2022
#	Last Author: 	Nooshin Nosrati
#   Copyright (C) 2022 University of Tehran
#   This source file may be used and distributed without
#   restriction provided that this copyright statement is not
#   removed from the file and that any derivative work contains
#   the original copyright notice and the associated disclaimer.
#
#******************************************************************************
#	File content description:
#	do file for recording simulation time, 
#				handling the dumpMem and faultInjection tcl scripts, 
#				and running simulation                                  
#******************************************************************************

#echo "argc = $argc"
if { $argc < 1 } {
    puts "The DO file requires two arguments: "
    puts "1. TB_Name and 2. Process_Name in which the wireName & stuckAtVal variables are defined. "
    puts "Please try again with the following syntax: "
    puts "do doFileName.do TB_Name Process_Name"
    puts "In my case is:   do mydo.do VirtualTester FI"
} else {
    project compileall

    vsim -t ns -novopt work.$1

    if {[file exists wave.do]} {
        do wave.do
    }
	
	restart -force

    set logFile [open "log.txt" w+]

    source dumpMem.tcl
    do faultInjection.tcl $1 $2
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