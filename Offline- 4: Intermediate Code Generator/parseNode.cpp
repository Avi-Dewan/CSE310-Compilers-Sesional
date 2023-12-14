#include "parseNode.h"


parseNode::~parseNode()
{
    if(symbolInfo != nullptr)
        delete symbolInfo;
}


parseNode::parseNode(SymbolInfo *symbolInfo, int startLineNo)
{
    this->symbolInfo = symbolInfo;
    this->startLineNo = startLineNo;
    this->endLineNo = startLineNo;
    this->isLeaf = false;

    vector<string>  leaves {
                        "IF", "FOR", "DO", "INT", "FLOAT", "VOID", "SWITCH", "DEFAULT", "ELSE", "WHILE", "BREAK", "CHAR", "DOUBLE",
                        "RETURN", "CASE" , "CONTINUE",  "MAIN", "CONST_INT", "CONST_FLOAT", "CONST_CHAR", "ASSIGNOP", "NOT",
                        "LPAREN", "RPAREN", "LSQUARE", "RSQUARE" , "LCURL", "RCURL",
                        "COMMA", "SEMICOLON", "ADDOP", "MULOP", "INCOP", "DECOP", "RELOP", "LOGICOP", "BITOP", "ID", "PRINTLN"

    }; 

    //     

    vector<string>::iterator it;

    it = find(leaves.begin(), leaves.end(), symbolInfo->getType());

    if( it != leaves.end()) {
        this->isLeaf = true;
    } 

}

void parseNode::addChild(parseNode *c) {

    if(children.size() == 0) {
        this->setstartLineNo(c->getstartLineNo());
    } 

    children.push_back(c);
    
    this->setendLineNo(c->getendLineNo());
}

void parseNode::print(int spaceCount, FILE *parseout) {

    string space = "";

    for(int i = 0; i < spaceCount; i++) space += " ";

    if(isLeaf) {
        fprintf(parseout,"%s%s : %s\t<Line: %d>\n",space.c_str(), symbolInfo->getType().c_str(), symbolInfo->getName().c_str(), startLineNo);
        
    } else {
        fprintf(parseout,"%s%s : %s \t<Line: %d-%d>\n",space.c_str(), symbolInfo->getType().c_str(), symbolInfo->getName().c_str(), startLineNo, endLineNo);
    }


    for(parseNode* p: children) {
        p->print(spaceCount+1, parseout);
    }

}


