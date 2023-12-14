#include<stdio.h>
#include<cstring>
#include "ScopeTable.cpp"

using namespace std;

class SymbolTable{

    ScopeTable *curScope;
    int num_buckets;
public:
    SymbolTable(int n) {
        num_buckets = n;
        curScope = new ScopeTable(1, num_buckets);
    }

    void enter_scope(int tableNo) {
        ScopeTable *sc = new ScopeTable(tableNo, num_buckets);

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

        cout << "\t'" << name << "' not found in any of the ScopeTables" << endl;

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


void splitString(string str, string arr[4])
{
    string word = "";

    int i = 0;

    for(int j = 0; j < 4; j++) arr[j] = "";

    for (auto x : str)
    {
        if (x == ' ')
        {
            arr[i++] = word;
            word = "";

            if(i == 4) return;
        }
        else {
            word = word + x;
        }
    }

    arr[i] = word;
    
}


int main() {

    freopen("in.txt", "r", stdin);
    freopen("out.txt", "w", stdout);

    // freopen("sample_input.txt", "r", stdin);
    // freopen("sample_output.txt", "w", stdout);

    int num_busket, cmd = 1, tableNo = 2, j = 0;

    string s;
    string arr[4];
    SymbolInfo symbols[10000];

    cin >> num_busket;

    getline(cin, s);

    SymbolTable st = SymbolTable(num_busket);



    while (1)
    {
        getline(cin, s);

        cout << "Cmd " << cmd++ << ": " << s << endl;

        splitString(s, arr);
        
        if(arr[3] != "") {
             cout << "\tNumber of parameters mismatch for the command " << arr[0] << endl;
        } else if(arr[0] == "I") {

            if(arr[1] == "" || arr[2] == "") cout << "\tNumber of parameters mismatch for the command " << arr[0] << endl;
            else {
                symbols[j] = SymbolInfo(arr[1], arr[2]);
                st.insert(&symbols[j++]);
            }

        } else if(arr[0] == "L") {
            
            if(arr[1] == "" || arr[2] != "") cout << "\tNumber of parameters mismatch for the command " << arr[0] << endl;
            else {
                st.look_up(arr[1]);
            }

        } else if(arr[0] == "D") {

            if(arr[1] == "" || arr[2] != "") cout << "\tNumber of parameters mismatch for the command " << arr[0] << endl;
            else {
                st.remove(arr[1]);
            }
            
        } else if(arr[0] == "P") {

            if(arr[1] == "" || arr[2] != "") cout << "\tNumber of parameters mismatch for the command " << arr[0] << endl;
            else {
                if(arr[1] == "A") st.print_all_scope();
                else if(arr[1] == "C") st.print_current_scope();
            }
             
        } else if(arr[0] == "S") {

            if(arr[1] != "" || arr[2] != "") cout << "\tNumber of parameters mismatch for the command " << arr[0] << endl;
            else {
                st.enter_scope(tableNo++);
            }

            
        } else if(arr[0] == "E") {

            if(arr[1] != "" || arr[2] != "") cout << "\tNumber of parameters mismatch for the command " << arr[0] << endl;
            else {
                st.exit_scope();
            }
            
        } else if(arr[0] == "Q") {

            if(arr[1] != "" || arr[2] != "") cout << "\tNumber of parameters mismatch for the command " << arr[0] << endl;
            else {
                return 0;
            }
            
        }
        
        
    }

}


