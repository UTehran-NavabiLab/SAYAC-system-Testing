#include <string>
#include <vector>
#include <fstream>
#include <iostream>
#include "Golomb.h"

using namespace std;

#define fileName "SAYAC.pat"
#define outfileName "SAYAC_golomb_compressed.pat"
#define MaxCWL 4


int main() {
	vector <string> testVector;
	vector<string> xoredTestVector;
	string compressedTestVector;
	vector<string> reorderedTestVector;


	get_input(testVector, fileName);
	xored_testvector(testVector, xoredTestVector);
	Golomb(xoredTestVector, MaxCWL, compressedTestVector);
	write_file(compressedTestVector, outfileName);


	return 0;
}