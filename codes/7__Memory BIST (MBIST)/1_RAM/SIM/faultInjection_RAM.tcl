when -label faultInjectionwhen " faultInjection_RAM == '1' and faultInjection_RAM'event " { 
	variable faultLoc [exa sim:/VirtualTester_RAM_MBIST/TP_RAM/wireName]
	variable faultLoc [string trim $faultLoc "{}"]
	variable faultVal [exa sim:/VirtualTester_RAM_MBIST/TP_RAM/stuckAtVal]
	variable faultVal [string trim $faultVal "{}"]
	
	force -freeze sim:$faultLoc $faultVal
}
when -label faultRemovalwhen " faultInjection_RAM == '0' and faultInjection_RAM'event " { 
	variable faultLoc [exa sim:/VirtualTester_RAM_MBIST/TP_RAM/wireName]
	variable faultLoc [string trim $faultLoc "{}"]
	noforce sim:$faultLoc
}


