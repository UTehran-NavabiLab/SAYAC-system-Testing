//******************************************************************************
//	Filename:		TB.v
//	Project:		SAYAC Testing
//  Version:		0.90
//	History:
//	Date:			20 June 2022
//	Last Author: 	Nooshin Nosrati
//  Copyright (C) 2022 University of Tehran
//  This source file may be used and distributed without
//  restriction provided that this copyright statement is not
//  removed from the file and that any derivative work contains
//  the original copyright notice and the associated disclaimer.
//
//******************************************************************************
//	File content description:
//	Testbench for generating the SAYAC fault list                                
//******************************************************************************

`timescale 1ns/1ns

module faultListGen_TB();

reg clk, rst, readyMEM;
reg [15:0] dataBusIn, p1TRF, p2TRF;
wire readMM, writeMM; 
wire [15:0] dataBusOut, addrBus;
wire [3:0]  outMuxrs1, outMuxrs2, outMuxrd;
wire [15:0] inDataTRF;
wire writeTRF, readInst;

LGC_Netlist_Ver FUT(clk, rst, readyMEM, dataBusIn, p1TRF, p2TRF, 
					readMM, writeMM, dataBusOut, addrBus, 
					outMuxrs1, outMuxrs2, outMuxrd, 
					inDataTRF, writeTRF, readInst);


initial begin

	$FaultCollapsing (faultListGen_TB.FUT, "SAYAC_PLI.flt");
	
	$stop;
end

endmodule