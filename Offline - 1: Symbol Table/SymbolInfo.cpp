#include<iostream>
#include<cstring>

using namespace std;

class SymbolInfo{
    string name;
    string type;
    SymbolInfo* next;


public:

    SymbolInfo() {
        this->name = "";
        this->type = "";
        this->next = NULL;
    }

    SymbolInfo(string name, string type) {
        this->name = name;
        this->type = type;
        this->next = NULL;
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

        
};
