![alt text](image.png)
# Test and Testability of SAYAC Embedded System

Focusing on post-manufacturing test analysis:\
1- We have developed an open-source test toolcahin called UT-DATE, which is available at: https://pypi.org/project/ut-date/ \
2- We have designed and incorporated several testability methods to test the SAYAC embedded system, including:
* Processor 
* Memory
* Interconnect

# Processor Testing
Several existing Design for Test (DFT) techniques are incorporated into the SAYAC processor to make it testable and evaluate its testability for post-manufacturing faults, considering stuck-at-fault models.

After several design modifications to make SAYAC test-ready, the following DFT techniques have been incorporated:
* Single and multiple scan testing
* Built-in self-test (BIST) architectures, including RTS & STUMPS
* Boundary-scan IEEE 1149.1 standard. 

# Memory Testing
Memory blocks of SAYAC, including RAM, instruction ROM, and register file have been tested for memory fault models through:
* Memory BIST architectures, and 
* Boundary scan IEEE 1149.1 architecture,
* Considering MARCH algorithms.
 
# Interconnect Testing
The data bus and address bus interconnects of the JTAG-compliant SAYAC processor are tested using the EXTEST instruction of the IEEE 1149.1 standard.


# Running Codes
* The code folders are organized according to the structure of the report document.
 
* Running some projects (like LBIST and MBIST) requires using VHDL 2008, as hierarchical access to signals is a part of the VHDL 2008 standard. To use VHDL 2008 in Modelsim, follow these steps: \
from the "view" tab -> 
select the "properties" option -> 
go to the "VHDL" tab -> 
select the "Use 1076-2008" option.
