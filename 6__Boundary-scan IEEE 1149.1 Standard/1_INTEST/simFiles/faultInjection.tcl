#******************************************************************************
#	Filename:		faultInjection.tcl
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

when -label faultInjectionwhen " faultInjection == '1' and faultInjection'event " { 
	variable faultLoc [exa sim:/$1/$2/wireName]
	variable faultLoc [string trim $faultLoc "{}"]
	variable faultVal [exa sim:/$1/$2/stuckAtVal]
	variable faultVal [string trim $faultVal "{}"]
	
	force -freeze sim:$faultLoc $faultVal
}
when -label faultRemovalwhen " faultInjection == '0' and faultInjection'event " { 
	variable faultLoc [exa sim:/$1/$2/wireName]
	variable faultLoc [string trim $faultLoc "{}"]
	
	noforce sim:$faultLoc
}



