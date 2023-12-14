#ifndef SYMBOL_INFO_H
#define SYMBOL_INFO_H

#include <string>
#include<regex>
#include<algorithm>

using namespace std;


class SymbolInfo{
    string name;
    string type;
    SymbolInfo* next;
    string extraInfo;


public:

    SymbolInfo() {
        this->name = "";
        this->type = "";
        this->next = NULL;
    }

    SymbolInfo(string name, string type) {
        this->name = name;
        this->type = type;
        this->extraInfo = "NOTHING EXTRA";
        this->next = NULL;
    }

    SymbolInfo(string name, string type, string extraInfo) {
        this->name = name;
        this->type = type;
        this->next = NULL;
        this->extraInfo = extraInfo;
    }


    string getName() {
        return this->name;
    }


    void setName(string name) {
        this->name = name;
    }

    string getType()
    {
        return this->type;
    }

    void setType(string type)
    {
        this->type = type;
    }

    SymbolInfo* getNext() const {
        return next;
    }

    void setNext(SymbolInfo* next) {
        this->next = next;
    }
 
    string getextraInfo() {
        return this->extraInfo;
    }

    void setextraInfo(string ex) {
        this->extraInfo = ex;
    }

    string getFirstInfo() {

        regex reg("\\s+");
        
        sregex_token_iterator iter(extraInfo.begin(), extraInfo.end(), reg, -1);
        sregex_token_iterator end;

        vector<string> vec(iter, end);

        string s1 = vec[0];
        transform(s1.begin(), s1.end(), s1.begin(), ::toupper);
        return s1;
    }


        
};

#endif