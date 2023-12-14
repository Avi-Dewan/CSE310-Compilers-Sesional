#ifndef __PARSE_NODE_H__
#define __PARSE_NODE_H__

#include"1905120_symbolInfo.h"
#include<iostream>
#include<vector>
#include <algorithm>

using namespace std;


class parseNode
{
private:
    
    SymbolInfo *symbolInfo;
    int startLineNo;
    int endLineNo;
    bool isLeaf;
    vector<parseNode*> children;

public:
    parseNode(SymbolInfo *symbolInfo, int startLineNo);
    void addChild(parseNode *c);
    void print(int spaceCount, FILE *parseout);
    int getstartLineNo() {return startLineNo;}
    int getendLineNo() {return endLineNo;}
    void setstartLineNo(int startLineNo) { this->startLineNo = startLineNo; }
    void setendLineNo(int endLineNo) { this-> endLineNo = endLineNo; }
    SymbolInfo* getSymbol() {return symbolInfo;}
    string getSymbolName() {return symbolInfo->getName(); }
    string getSymbolType() {    return symbolInfo->getType(); }
    string getextraInfo() { return symbolInfo->getextraInfo();}

    vector<parseNode*> getChildren() {return children; }

    ~parseNode();
};


#endif