#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include<iostream>
#include<string>
#include "1905120_scopeTable.h"


using namespace std;

class SymbolTable{

    ScopeTable *curScope;
    int num_buckets;
    int scopeNo;
public:
    SymbolTable(int n) {
        num_buckets = n;
        scopeNo = 1;
        curScope = new ScopeTable(scopeNo, num_buckets);
    }

    void enter_scope() {
        scopeNo++;
        ScopeTable *sc = new ScopeTable(scopeNo, num_buckets);

        sc->setParent(curScope);
        curScope = sc;
        
    }

    void exit_scope() {
        if(curScope->getParent() != NULL) {
            ScopeTable *exitSc = curScope;
            curScope = curScope->getParent();

            delete exitSc;
        }
        else cout << "\tScopeTable# 1 cannot be removed" << endl;
    }

    bool insert(SymbolInfo *s) {
        return curScope->insert(s);
    }

    bool remove(string name) {
        return curScope->delete_symbol(name);
    }

    SymbolInfo* look_up(string name) {

        SymbolInfo *s = NULL;

        ScopeTable *c = curScope;

        while (c != NULL)
        {
            s = c->look_up(name);

            if(s != NULL) return s;

            c = c->getParent();
        }

        // cout << "\t'" << name << "' not found in any of the ScopeTables" << endl;

        return NULL;

    }

    void print_current_scope() {
        curScope->print();
    }

    void print_all_scope() {

        ScopeTable *c = curScope;

        while (c != NULL)
        {
            c->print();

            c = c->getParent();
        }
        
    }

    void print_all_scopeLex(FILE *logout) {

        ScopeTable *c = curScope;

        while (c != NULL)
        {
            c->printLex(logout);

            c = c->getParent();
        }
        
    }

    ~SymbolTable() {

        ScopeTable *temp = curScope;

        while (curScope != NULL)
        {
            temp = curScope;

            curScope = curScope->getParent();

            delete temp;
            
        }
        
    }
    


        
};


#endif