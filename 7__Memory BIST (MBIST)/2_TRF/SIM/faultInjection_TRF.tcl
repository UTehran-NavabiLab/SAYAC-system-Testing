
when -label faultInjectionwhen " faultInjection_TRF == '1' and faultInjection_TRF'event " { 
	variable faultLoc [exa sim:/VirtualTester_TRF_MBIST/TP_TRF/wireName]
	variable faultLoc [string trim $faultLoc "{}"]
	variable faultVal [exa sim:/VirtualTester_TRF_MBIST/TP_TRF/stuckAtVal]
	variable faultVal [string trim $faultVal "{}"]
	
	force -freeze sim:$faultLoc $faultVal
}
when -label faultRemovalwhen " faultInjection_TRF == '0' and faultInjection_TRF'event " { 
	variable faultLoc [exa sim:/VirtualTester_TRF_MBIST/TP_TRF/wireName]
	variable faultLoc [string trim $faultLoc "{}"]
	noforce sim:$faultLoc
}



