#******************************************************************************
#	Filename:		faultInjection_MEM.tcl
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
#	TCL script for handling fault simulation by the Static method                                 
#******************************************************************************

when -label trf_faultInjectionwhen " faultInjection_TRF == '1' and faultInjection_TRF'event " { 
	variable faultLoc [exa sim:/VirtualTester/TP_TRF/wireName]
	variable faultLoc [string trim $faultLoc "{}"]
	variable faultVal [exa sim:/VirtualTester/TP_TRF/stuckAtVal]
	variable faultVal [string trim $faultVal "{}"]
	
	force -freeze sim:$faultLoc $faultVal
}	
when -label trf_faultRemovalwhen " faultInjection_TRF == '0' and faultInjection_TRF'event " { 
	variable faultLoc [exa sim:/VirtualTester/TP_TRF/wireName]
	variable faultLoc [string trim $faultLoc "{}"]
	noforce sim:$faultLoc
}


when -label ram_faultInjectionwhen " faultInjection_RAM == '1' and faultInjection_RAM'event " { 
	variable faultLoc [exa sim:/VirtualTester/TP_RAM/wireName]
	variable faultLoc [string trim $faultLoc "{}"]
	variable faultVal [exa sim:/VirtualTester/TP_RAM/stuckAtVal]
	variable faultVal [string trim $faultVal "{}"]
	
	force -freeze sim:$faultLoc $faultVal
}
when -label ram_faultRemovalwhen " faultInjection_RAM == '0' and faultInjection_RAM'event " { 
	variable faultLoc [exa sim:/VirtualTester/TP_RAM/wireName]
	variable faultLoc [string trim $faultLoc "{}"]
	noforce sim:$faultLoc
}





