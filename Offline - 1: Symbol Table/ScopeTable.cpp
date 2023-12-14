#include<iostream>
#include<cstring>
#include "SymbolInfo.cpp"

using namespace std;


class ScopeTable{
    SymbolInfo** scopeTable;
    ScopeTable* parent_scope;
    int unNum;
    int num_buckets;

public:

    static unsigned long long SDBMHash(string str) {
        unsigned long long hash = 0;
        unsigned long long  i = 0;
        unsigned long long  len = str.length();

        for (i = 0; i < len; i++)
        {
            hash = (str[i]) + (hash << 6) + (hash << 16) - hash;
        }

        return hash;
    }

    ScopeTable(int un, int n) {
        unNum = un;
        num_buckets = n;
        scopeTable = new SymbolInfo*[num_buckets];

        for(int i = 0;i < num_buckets; i++) scopeTable[i] = NULL;
        
        parent_scope = NULL;

        cout << "\tScopeTable# " << un << " created" << endl;

    }

    bool insert(SymbolInfo* s) {
        int i = SDBMHash(s->getName()) % num_buckets;
        int j = 0;


        SymbolInfo *head = scopeTable[i];

        if(head == NULL) {
            scopeTable[i] = s;
            
        } else {

            j++;

            while (head->getNext() != NULL) 
            {
                if(head->getName() == s->getName()) {
                     cout << "\t'" << s->getName() <<  "' already exists in the current ScopeTable" << endl;
                    return false;
                }

                head = head->getNext();
                j++;
            }

            if(head->getName() == s->getName()) {
                     cout << "\t'" << s->getName() <<  "' already exists in the current ScopeTable" << endl;
                    return false;
            }

            head->setNext(s);
  
        }


        cout << "\tInserted in ScopeTable# " << unNum << " at position " << i+1 << ", " << j+1 << endl;

        return true;

         

    }

    SymbolInfo* look_up(string name){

        int i = SDBMHash(name) % num_buckets;

        int j = 0;

        SymbolInfo *s = scopeTable[i];

        while(s != NULL) {
            if(s->getName() == name) {
                cout << "\t'" << name << "' " << "found in ScopeTable# " << unNum << " at position " << i+1 << ", " << j+1 << endl;
                return s;
            }
            s = s->getNext();
            j++;
        }


        return NULL;
    
    }

    

    bool delete_symbol(string name) {
        int i = SDBMHash(name) %num_buckets;
        int j = 0;
        
        SymbolInfo *s = scopeTable[i];


        while (s != NULL)
        {
            if(s->getName() == name) {

                if(s == scopeTable[i]) {
                    scopeTable[i] = s->getNext();
                } else {
                    SymbolInfo* prev = scopeTable[i];
                    j++;
                    while (prev->getNext() != s) {

                        //  cout << prev->getName() << endl;
                         prev = prev->getNext();
                         j++;
                    }
                    prev->setNext(s->getNext());
                }

                cout << "\tDeleted '" << name << "' " << "from ScopeTable# " << unNum << " at position " << i+1 << ", " << j+1 << endl;

                return true;
            }
            s = s->getNext();
        }

        cout << "\tNot found in the current ScopeTable" << endl;
        
        return false;
        
    }

    void print() {

        cout << "\tScopeTable# " << unNum << endl;

        for(int i = 0; i < num_buckets; i++) {
            cout <<"\t" << i+1 << "--> ";
            SymbolInfo *s = scopeTable[i];

            while(s != NULL) {

                cout << "<" << s->getName() << "," << s->getType() << "> ";

                s = s->getNext();

                
            }

            cout << endl;

        }



    }

    ScopeTable* getParent() {
        return this->parent_scope;
    } 

    void setParent(ScopeTable *p) {
        this->parent_scope  = p;
    }

    ~ScopeTable() {

        delete scopeTable;

        cout << "\tScopeTable# " << unNum << " removed" << endl;
    }
  

        
};
