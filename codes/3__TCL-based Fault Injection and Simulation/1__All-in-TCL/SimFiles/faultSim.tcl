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
#	TCL script for handling fault simulation by the All-in-TCL method                                 
#******************************************************************************

vsim work.fulladder_TB
restart -force

set start_time [clock seconds]

variable numOfDetecteds 0
variable numOfFaults 0
variable coverage 0

set forReporting ""

set reportFile [open "reportFA_VHDL.txt" w+]
set faultFile [open "fault_list.flt" r]
fconfigure $faultFile -buffering line
while { [gets $faultFile fault] >= 0 } { 
	
	incr numOfFaults
	set wireName   [lindex $fault 0]
	set stuckAtVal [lindex $fault 1]
	force -freeze sim:$wireName $stuckAtVal
	append forReporting "faultNum = $numOfFaults is injected @ [expr $now/1000] ns, "
	
	set detected 0
	
	set testFile [open "test_list.txt" r]
	fconfigure $testFile -buffering line
	while { [gets $testFile testVector] >= 0 && $detected == 0 } {
		force inputs $testVector -deposit
		run 2 ns
		if { [examine outputs_FUT] != [examine outputs_GUT] } {
			set detected 1
			append forReporting "detected by testVector = $testVector @ [expr $now/1000] ns \n"
		}
	}
	close $testFile
	if { $detected == 1} {
		incr numOfDetecteds
	}
	noforce sim:$wireName
}
close $faultFile
puts $reportFile $forReporting
close $reportFile
set coverage [expr $numOfDetecteds / $numOfFaults];
echo "numOfDetecteds = $numOfDetecteds"
echo "numOfFaults = $numOfFaults"
echo "coverage = $coverage"

set delta_time [expr [clock seconds]-$start_time]
set delta_minutes [expr $delta_time / 60]
echo "SIMULATION TIME: $delta_time Sec. & $delta_minutes Minuten\n"