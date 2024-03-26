//******************************************************************************
//	Filename:		utilities.h
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
//	Fault Injection Module (FIM)                                  
//******************************************************************************

#include <string>
#include <iterator>
#include <vector>
#include <sstream>

#ifndef __UTILITIES_H__
#define __UTILITIES_H__


template<int width>
sc_dt::sc_lv<width> str2logic(std::string str){
    std::string::iterator it;
    sc_dt::sc_lv<width> logic_vector;
    int i = 0;

    for (it = str.begin(); it != str.end(); it++){
        if ((*it) == '1')
            logic_vector[width - i - 1] = '1';
        else if ((*it) == '0')
            logic_vector[width - i - 1] = '0';

        i = i + 1;
    }

    return logic_vector;
}

#endif