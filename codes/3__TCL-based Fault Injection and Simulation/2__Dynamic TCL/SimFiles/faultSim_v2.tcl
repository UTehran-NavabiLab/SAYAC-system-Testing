#******************************************************************************
#	Filename:		faultSim.tcl
#	Project:		SAYAC Testing 
#   Version:		0.90
#	History:
#	Date:			20 June 2022
#	Last Author: 	Nooshin Nosrati
#  Copyright (C) 2022 University of Tehran
#  This source file may be used and distributed without
#  restriction provided that this copyright statement is not
#  removed from the file and that any derivative work contains
#  the original copyright notice and the associated disclaimer.
#
#******************************************************************************
#	File content description:
#	TCL script for handling fault simulation by the Dynamic method                                 
#******************************************************************************

vsim work.fulladder_TB
restart -force

set start_time [clock seconds]
variable testCycle 2

set faultFile [open "fault_list.flt" r]
fconfigure $faultFile -buffering line
while { [gets $faultFile fault] >= 0 } { 
	
	set wireName   [lindex $fault 0]
	set stuckAtVal [lindex $fault 1]
	force -freeze sim:$wireName $stuckAtVal
	force sim:/fulladder_TB/stopSim '1' -deposit
	
	run $testCycle ns

	while { [examine sim:/fulladder_TB/stopSim] == 1 } {
		run $testCycle ns
	}
	noforce sim:$wireName
}
close $faultFile

set delta_time [expr [clock seconds]-$start_time]
set delta_minutes [expr $delta_time / 60]
echo "SIMULATION TIME: $delta_minutes Minuten\n"