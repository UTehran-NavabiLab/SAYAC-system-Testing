//******************************************************************************
//	Filename:		sc_main.cpp
//	Project:		SAYAC Testing 
//  Version:		0.90
//	History:
//	Date:			20 June 2022
//	Last Author: 	Ebrahim Nouri
//  Copyright (C) 2022 University of Tehran
//  This source file may be used and distributed without
//  restriction provided that this copyright statement is not
//  removed from the file and that any derivative work contains
//  the original copyright notice and the associated disclaimer.
//
//******************************************************************************
//	File content description:
//	Main                                  
//******************************************************************************

#include "systemc.h"
#include "testbench.h"
#include "chrono"
#include "iostream"
#include "fstream"

using namespace std;

int sc_main(int argc, char* argv[]){
	auto begin = std::chrono::high_resolution_clock::now();

    testbench* fault_simulation = new testbench("testbench");

	sc_start(18393, SC_NS); //18400

	auto end = std::chrono::high_resolution_clock::now();
	auto elapsed = std::chrono::duration_cast<std::chrono::seconds>(end - begin);
	cout << "sim. time = " << elapsed.count() << " seconds" << endl;
    return 0;
}
