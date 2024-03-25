#include <iostream>
#include <string>
#include <vector>
#include <fstream>
#include <bitset>


using namespace std;

template<typename T>
std::vector<T> slice(std::vector<T> const& v, int m, int n)
{
	auto first = v.cbegin() + m;
	auto last = v.cbegin() + n + 1;

	std::vector<T> vec(first, last);
	return vec;
}

void get_input(vector<string>& testVector, string fileName) {

	ifstream file(fileName);
	string str;
	while (getline(file, str)) {

		if (str.size() != 0)
			testVector.push_back(str);

	}

}

int hamming_distance(string a, string b) {
	int hamming_distance_val = -1;
	if (a.size() == b.size()) {
		hamming_distance_val = 0;
		for (int i = 0; i < a.size(); i++) {
			if (a[i] != b[i])
				hamming_distance_val++;
		}
	}

	return hamming_distance_val;
}

//Creates a complete graph where each node is testvector and each edge is the hamming distance of the two nodes
void create_table(vector<string>& testVector, vector<vector<int>> &table) {

	vector<int> current_row;
	table.clear();
	for (int i = 0; i < testVector.size(); i++) {
		//cout << i << " ";
		current_row.clear();
		for (int j = 0; j < testVector.size(); j++) {
			if (j < i) {
				current_row.push_back(table[j][i]);
			}
			else {
				current_row.push_back(hamming_distance(testVector[i], testVector[j]));
			}
			
			//cout << current_row[current_row.size() - 1];
			//cout << "  ";
		}
		//cout << "\n";
		table.push_back(current_row);
	}
}


//Reorders the testset using a greedy aproach in tsp problem
void reorder_testvector(vector<string>& testVector, vector<string>& reorderedTestVector, int start_from) {
	vector<vector<int>> table;
	vector<int> visited_nodes(testVector.size(),0);
	create_table(testVector, table);
	int current_node = start_from;
	int num_of_nodes_visited = 0;
	int min_cost;
	int next_node = current_node;
	vector<int> route;
	cout<<"Ready"<<endl;
	while (num_of_nodes_visited < testVector.size()) {
		min_cost = testVector[0].size()+1;
		num_of_nodes_visited++;
		visited_nodes[current_node] = 1;
		cout << current_node << "   ";
		route.push_back(current_node);
		for (int i = 0; i < table[current_node].size(); i++) {
			if (i != current_node && visited_nodes[i]== 0 && table[current_node][i] < min_cost) {
				next_node = i;
				min_cost = table[current_node][i];
			}
		}
		current_node = next_node;
	}
	cout << "\n" << route.size() << endl;
	reorderedTestVector.clear();
	for (int i = 0; i < route.size(); i++) {
		reorderedTestVector.push_back(testVector[route[i]]);
	}

}

void RLE(vector<string>& testVector, int MaxCWL, vector<string>& compressedTestVector) {

	int CurMax = 0;
	int max = (1 << MaxCWL) - 1;
	int sum = 0;
	string binary;
	vector <vector <int>> encodedTestVector;
	for (int i = 0; i < testVector.size(); i++) {
		int zerosCount = 0;
		string compressed = "";

		for (int j = 0; j < testVector[i].size(); j++) {
			if (testVector[i][j] == '1') {
				binary = bitset<32>(zerosCount).to_string();
				//cout << binary.substr(32 - MaxCWL, MaxCWL) << endl;
				compressed += binary.substr(32 - MaxCWL, MaxCWL);
				zerosCount = 0;
			}
			else {
				if (zerosCount == max) {
					binary = bitset<32>(zerosCount).to_string();
					//cout << binary.substr(32 - MaxCWL, MaxCWL) << endl;
					compressed += binary.substr(32 - MaxCWL, MaxCWL);
					zerosCount = 1;
				}
				else
					zerosCount++;
			}
		}
		if (zerosCount > 0) {
			binary = bitset<32>(zerosCount).to_string();
			//cout << binary.substr(32 - MaxCWL, MaxCWL) << endl;
			compressed += binary.substr(32 - MaxCWL, MaxCWL);
		}
		compressedTestVector.push_back(compressed);
	}

	//cout << "*********************************" << endl;

	cout << compressedTestVector.size();
}


void xored_testvector(vector<string>& testVector, vector<string>& xoredTestVector) {

	xoredTestVector.push_back(testVector[0]);
	string curXORedTestVector;

	for (int i = 1; i < testVector.size(); i++) {
		curXORedTestVector = "";
		for (int j = 0; j < testVector[i].size(); j++) {
			if (testVector[i][j] == testVector[i - 1][j]) {
				curXORedTestVector = curXORedTestVector + '0';
			}
			else {
				curXORedTestVector = curXORedTestVector + '1';
			}
		}
		xoredTestVector.push_back(curXORedTestVector);
		//cout << curXORedTestVector << endl;
	}
}


void write_file(vector<string>& compressedTestVector, string fileName) {

	ofstream out;
	out.open(fileName);
	for (int i = 0; i < compressedTestVector.size(); i++) {
		out << compressedTestVector[i] << endl;
	}

}
