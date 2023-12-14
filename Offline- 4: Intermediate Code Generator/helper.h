#ifndef _helper_
#define _helper_

#include<vector>
#include<string>
#include<algorithm>
#include "AsmWrite.h"

using namespace std;

class Helper
{
private:
    vector<bool> reg;
    AsmWrite asmWrite;
    int line_no;
    int label_no;

public:
    Helper(AsmWrite asmWrite, int line_no);

    vector<bool>& getReg() {
        return reg;
    }

    AsmWrite getAsmWrite() {
        return asmWrite;
    }

    void setLineNo(int line_no) {

        if(this->line_no != line_no) label_no = 1;
        
        this->line_no = line_no;
    }

    int getLineNo() {
        return line_no;
    }

    string getLabel() {
        string label = "L_" + to_string(line_no) + "_" + to_string(label_no);
        label_no++;
        return label;
    }

    void emptyAllReg() {
			fill(reg.begin(), reg.end(), false);
    }
  
};

Helper::Helper(AsmWrite asmWrite, int line_no) {
    reg = vector<bool> (4, false);
    this->asmWrite = asmWrite;
    this->line_no = line_no;
    label_no = 1;
}





#endif