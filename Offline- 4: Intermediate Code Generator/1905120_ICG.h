#ifndef _ICG_
#define _IGG_

#include<iostream>
#include<fstream>
#include<vector>
#include<string>
#include<regex>
#include "1905120_symbolTable.h"
#include "1905120_symbolInfo.h"
#include "parseNode.h"


using namespace std;


int levelNumber = 0;

FILE* asmout = fopen("asm_code.asm", "w");

// void start(parseNode* s);
void compound_statement(parseNode* s);
void statements(parseNode* s);
void statement(parseNode* s);
void expression_statement(parseNode* s);
void expression(parseNode* s);
void logic_expression(parseNode* s);
void rel_expression(parseNode* s);
void simple_expression(parseNode* s);
void term(parseNode* s);
void unary_expression(parseNode* s);
void factor(parseNode* s);


void compound_statement(parseNode* s) {
    if(s->getChildren().size() == 3) {
        // table.EnterScope();
        statements(s->getChildren()[2]);
        // table.ExitScope();
    }
}

void statements(parseNode* s) {
    if(s->getChildren().size() == 2) {
        statements(s->getChildren()[0]);
        statement(s->getChildren()[1]);
    } else  {
        statement(s->getChildren()[0]);
    }
}

void statement(parseNode* s) {
    if(s->getChildren()[0]->getSymbolName() == "expression_statement") 
        expression_statement(s->getChildren()[0]);
}

void expression_statement(parseNode* s) {
    if(s->getChildren().size() == 2) {
        expression(s->getChildren()[0]);
        fprintf(asmout, "POP AX\n");
    }
}

void expression(parseNode* s) {
    if(s->getChildren().size() == 1)  {
        logic_expression(s->getChildren()[0]);
    }
}

void logic_expression(parseNode* s) {
    if(s->getChildren().size() == 1)  {
        rel_expression(s->getChildren()[0]);
    } else {

        rel_expression(s->getChildren()[0]);
        rel_expression(s->getChildren()[2]);

        fprintf(asmout, "POP DX\n");
        fprintf(asmout, "POP CX\n");

        if(s->getChildren()[1]->getSymbolName() == "&&") {
            fprintf(asmout, "CMP CX, 0\n");
            fprintf(asmout, "JG FOR_LOGICOP%d\n", levelNumber);
        }

        if(s->getChildren()[1]->getSymbolName() == "||") {  
            fprintf(asmout, "JG FOR_LOGICOP%d\n", levelNumber);
        }

        

        fprintf(asmout, "MOV CX, 0\n");
        fprintf(asmout, "JMP END%d", levelNumber);
        fprintf(asmout, "FOR_RELOP%d:\n", levelNumber);
        fprintf(asmout, "MOV CX, 1\n");
        fprintf(asmout, "END%d:\n", levelNumber);
        fprintf(asmout, "PUSH CX\n");
        levelNumber++;
    }
}

void rel_expression(parseNode* s) {
    if(s->getChildren().size() == 1)  {
        simple_expression(s->getChildren()[0]);
    } else {

        simple_expression(s->getChildren()[0]);
        simple_expression(s->getChildren()[2]);

        fprintf(asmout, "POP DX\n");
        fprintf(asmout, "POP CX\n");
        fprintf(asmout, "CMP CX, DX\n");

        if(s->getChildren()[1]->getSymbolName() == ">")
            fprintf(asmout, "JG FOR_RELOP%d\n", levelNumber);

        if(s->getChildren()[1]->getSymbolName() == ">=")
            fprintf(asmout, "JGE FOR_RELOP%d\n", levelNumber);

        if(s->getChildren()[1]->getSymbolName() == "<")
            fprintf(asmout, "JL FOR_RELOP%d\n", levelNumber);

        if(s->getChildren()[1]->getSymbolName() == "<=")
            fprintf(asmout, "JLE FOR_RELOP%d\n", levelNumber);

        if(s->getChildren()[1]->getSymbolName() == "==")
            fprintf(asmout, "JE FOR_RELOP%d\n", levelNumber);

        if(s->getChildren()[1]->getSymbolName() == "!=")
            fprintf(asmout, "JNE FOR_RELOP%d\n", levelNumber);

        fprintf(asmout, "MOV CX, 0\n");
        fprintf(asmout, "JMP END%d", levelNumber);
        fprintf(asmout, "FOR_RELOP%d:\n", levelNumber);
        fprintf(asmout, "MOV CX, 1\n");
        fprintf(asmout, "END%d:\n", levelNumber);
        fprintf(asmout, "PUSH CX\n");

        levelNumber++;
    }
}


void simple_expression(parseNode* s) {
    if(s->getChildren().size() == 1)  {
        term(s->getChildren()[0]);
    } else {
        simple_expression(s->getChildren()[0]);
        term(s->getChildren()[2]);

        fprintf(asmout, "POP CX\n");
        fprintf(asmout, "POP DX\n");

        if(s->getChildren()[1]->getSymbolName() == "+") {
            fprintf(asmout, "ADD DX, CX\n");
        } else {
            fprintf(asmout, "SUB DX, CX\n");
        }

        fprintf(asmout, "PUSH DX\n");
    }
}


void term(parseNode *s) {
    if(s->getChildren().size() == 1) {
        unary_expression(s->getChildren()[0]);
    } else {
        term(s->getChildren()[0]);

        unary_expression(s->getChildren()[2]);


        fprintf(asmout, "POP BX\n");
        fprintf(asmout, "POP AX\n");

        if(s->getChildren()[1]->getSymbolName() == "*"){
            fprintf(asmout, "IMUL BX\n");
            fprintf(asmout, "PUSH AX\n");
        }
        else if(s->getChildren()[1]->getSymbolName() == "/"){
            fprintf(asmout, "CWD\n");
            fprintf(asmout, "IDIV BX\n");
            fprintf(asmout, "PUSH AX\n");
        }  
        else{
            fprintf(asmout, "CWD\n");
            fprintf(asmout, "IDIV BX\n");
            fprintf(asmout, "PUSH DX\n");
        }
    }
}

void unary_expression(parseNode *s) {

    if(s->getChildren().size() == 1) {
        factor(s->getChildren()[0]);
    } else {
        if(s->getChildren()[0]->getSymbolType() == "ADDOP") {

            if(s->getChildren()[0]->getSymbolName() == "+" ) {
                unary_expression(s->getChildren()[1]);
            } else {
                unary_expression(s->getChildren()[1]);
                fprintf(asmout, "POP CX\n");
                fprintf(asmout, "NEG CX\n");
                fprintf(asmout, "PUSH CX\n");
            }
            
        } else {
            unary_expression(s->getChildren()[1]);
            fprintf(asmout, "POP CX\n");
            fprintf(asmout, "CMP CX, 0\n");
            fprintf(asmout, "JE FOR_NOT%d\n", levelNumber);
            fprintf(asmout, "MOV CX, 0\n");
            fprintf(asmout, "JMP END%d", levelNumber);
            fprintf(asmout, "FOR_NOT:\n");
            fprintf(asmout, "MOV CX, 1\n");
            fprintf(asmout, "END%d:\n", levelNumber);
            fprintf(asmout, "PUSH CX\n");
            levelNumber++;
        }
    }

}



void factor(parseNode *s) {

    if(s->getChildren().size() == 1) {
        fprintf(asmout, "PUSH WORD PTR %s\n", s->getChildren()[0]->getSymbolName().c_str());
    } else if (s->getChildren().size() == 3) 
    
    {
        expression(s->getChildren()[1]);
    }
    
} 

// int main()
// {
//     return 0;
// }

#endif