#******************************************************************************
#	Filename:		dumpMem.tcl
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
#	TCL script for dumping the data memory content                                  
#******************************************************************************

when -label dumpMemWhen " dumpDataMemory == '1' and dumpDataMemory'event " { 
    set dumpFile [open "dumpDataMem.txt" w+]
    set i 100
	for {set i_modes 100} {$i_modes < 120} {incr i_modes} {
        puts $dumpFile [exa sim:/VirtualTester/FUT/Data_MEMORY/memory($i)]
        incr i
    }
    close $dumpFile
}
