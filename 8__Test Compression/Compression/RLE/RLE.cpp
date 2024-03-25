#include <string>
#include <vector>
#include <fstream>
#include <iostream>
#include "RLE.h"

using namespace std;

#define fileName "SAYAC.pat"
#define outfileName "SAYAC_RLE_compressed.pat"
#define MaxCWL 4


int main() {
	vector <string> testVector;
	vector<string> xoredTestVector;
	vector <string> compressedTestVector;
	vector<string> reorderedTestVector;
	
	get_input(testVector, fileName);
	//reorder_testvector(testVector, reorderedTestVector, 0);
	//xored_testvector(reorderedTestVector, xoredTestVector);

	RLE(testVector, MaxCWL, compressedTestVector);

	write_file(compressedTestVector, outfileName);

	return 0;
}