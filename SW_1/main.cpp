#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <map>
#include<limits>

using namespace std;


double calc_delayA(const string& signal,map<string,double>& timingsA, map<string,pair<string,vector<string>>>& connectionsA,
                   map<string,double> delay ){
    if (timingsA.find(signal) != timingsA.end()) {
        return timingsA[signal];
    } else {
        double delayVal = 0;
        for (const string& ins : connectionsA[signal].second) {
            delayVal = max(delayVal, calc_delayA(ins, timingsA, connectionsA, delay));
        }
        delayVal += delay[connectionsA[signal].first];
        timingsA[signal] = delayVal;
        return delayVal;
    }
}

double calc_delayB(const string& signal, map<string, double>& timingsB,map<string, vector<pair<string,string>>>&connectionsB,
                   map<string, double>& delay) {
    if (timingsB.find(signal) != timingsB.end()) {
        return timingsB[signal];
    } else {
        double delayVal = numeric_limits<double>::infinity();
        for (const pair<string, string>& gateIns : connectionsB[signal]) {
            delayVal = min(delayVal, calc_delayB(gateIns.second, timingsB, connectionsB, delay) - delay[gateIns.first]);
        }
        timingsB[signal] = delayVal;
        return delayVal;
    }
}

int main(int argc, char *argv[]) {



    vector<string> content;
    vector<string> input;
    vector<string> output;
    map<string, double> timingsA;
    map<string, pair<string,vector<string>>> connectionsA;
    map<string, double> timingsB;
    map<string, vector<pair<string,string>>> connectionsB;
    map<string, double> delay;







    // Extraction of data from the files....

    ifstream file("circuit.txt");
    if (file.is_open()) {
        string line;
        while (getline(file, line)) {
            if (!line.empty() && line[0] != '/' && line.find_first_not_of(" \t") != string::npos) {
                content.push_back(line);
            }
        }
        file.close();
    } else {
        cerr << "Error opening circuit.txt" << endl;
        return 1;
    }

    ifstream gateDelaysFile("gate_delays.txt");
    if (gateDelaysFile.is_open()) {
        string line;
        while (getline(gateDelaysFile, line)) {
            if (!line.empty() && line[0] != '/' && line.find_first_not_of(" \t") != string::npos) {
                content.push_back(line);
            }
        }
        gateDelaysFile.close();
    } else {
        cerr << "Error opening gate_delays.txt" << endl;
        return 1;
    }







    // Filling the data dictionary

    try {
        for (const string& line : content) {
            
            
            if (line.find("PRIMARY_INPUTS") == 0) {
                vector<string> tokens;
                size_t start = line.find_first_of(" \t");
                tokens.push_back(line.substr(0,start));
                while (start != string::npos) {
                    size_t end = line.find_first_of(" \t", start + 1);
                    tokens.push_back(line.substr(start+1,end-start-1));
                    start = end;
                }
                for (size_t i = 1; i < tokens.size(); i++) {
                    timingsA[tokens[i]] = 0;
                    input.push_back(tokens[i]);
                }
            } 
            
           
           
            else if (line.find("PRIMARY_OUTPUTS") == 0) {
                vector<string> tokens;
                size_t start = line.find_first_of(" \t");
                tokens.push_back(line.substr(0,start));
                while (start != string::npos) {
                    size_t end = line.find_first_of(" \t", start + 1);
                    tokens.push_back(line.substr(start+1, end-start-1));
                    start = end;
                }
                for (size_t i = 1; i < tokens.size(); i++) {
                    output.push_back(tokens[i]);
                }
            } 
            
            
            else if (line.find("NAND2") == 0 || line.find("NOR2") == 0 || line.find("INV") == 0 ||
                       line.find("XOR2") == 0 || line.find("AND2") == 0 || line.find("OR2") == 0 ||
                       line.find("XNOR2") == 0) {
                vector<string> tokens;
                size_t start = line.find_first_of(" \t");
                tokens.push_back(line.substr(0,start));
                while (start != string::npos) {
                    size_t end = line.find_first_of(" \t", start + 1);
                    tokens.push_back(line.substr(start+1,end-start-1));
                    start = end;
                }
                string gate = tokens[0];
                vector<string> inputs(tokens.begin() + 1, tokens.end());
                if (inputs.size() == 1) {
                    delay[gate] = stod(inputs[0]);
                } else {
                    vector<string>back_connection(inputs.begin(),inputs.end()-1);
                    connectionsA[inputs.back()]=(make_pair(gate,back_connection));
                    for (size_t i = 0; i < inputs.size() - 1; i++) {
                        connectionsB[inputs[i]].push_back(make_pair(gate, inputs.back()));
                    }
                }
            }
        }
    } catch (const exception& e) {
        cerr << e.what() << endl;
        return 1;
    }

    ifstream requiredDelaysFile("required_delays.txt");
    if (requiredDelaysFile.is_open()) {
        string line;
        while (getline(requiredDelaysFile, line)) {
            if (!line.empty() && line[0] != '/' && line.find_first_not_of(" \t") != string::npos) {
                vector<string> tokens;
                size_t start = line.find_first_of(" \t");
                tokens.push_back(line.substr(0,start));
                while (start != string::npos) {
                    size_t end = line.find_first_of(" \t", start + 1);
                    tokens.push_back(line.substr(start+1,end-start-1));
                    start = end;
                }
                timingsB[tokens[0]] = stod(tokens[1]);
            }
        }
        requiredDelaysFile.close();
    } else {
        cerr << "Error opening required_delays.txt" << endl;
        return 1;
    }

    







        // Writing the output........


    if (argc > 1 && argv[1][0] == 'A') {
        ofstream outputDelaysFile("output_delays.txt");
        if (outputDelaysFile.is_open()) {
            for (const string& signal : output) {
                double ret = calc_delayA(signal,timingsA,connectionsA,delay);
                if (ret == static_cast<int>(ret)) {
                    if(!signal.empty()){
                    outputDelaysFile << signal << " " << static_cast<int>(ret) << endl;}
                } else {
                    if(!signal.empty()){
                    outputDelaysFile << signal << " " << ret << endl;}
                }
            }
            outputDelaysFile.close();
        } else {
            cerr << "Error opening output_delays.txt" << endl;
            return 1;
        }
    } else {
        ofstream inputDelaysFile("input_delays.txt");
        if (inputDelaysFile.is_open()) {
            for (const string& signal : input) {
                double ret = calc_delayB(signal,timingsB,connectionsB,delay);
                if (ret == static_cast<int>(ret)) {
                    if(!signal.empty()){
                    inputDelaysFile << signal << " " << static_cast<int>(ret) << endl;}
                } else {
                    if(!signal.empty()){
                    inputDelaysFile << signal << " " << ret << endl;}
                }
            }
            inputDelaysFile.close();
        } else {
            cerr << "Error opening input_delays.txt" << endl;
            return 1;
        }
    }

    return 0;
}

