%{
#include<iostream>
#include<fstream>
#include<vector>
#include<regex>
#include "1905120_symbolTable.h"
#include "1905120_symbolInfo.h"
#include "parseNode.h"
#include "ICG.h"

using namespace std;

int yyparse(void);
int yylex(void);

extern FILE *yyin;
extern int yylineno;
extern int error_count;

SymbolTable ST(11);
bool insideScope = false;
vector<string> definedFunction;

FILE *logout;
FILE *parseout;
FILE *errorout;
FILE *tokenout;


void yyerror(char *s)
{
	//write your code
}

vector<string> splitString(string str)
{
    regex reg("\\s+");

    sregex_token_iterator iter(str.begin(), str.end(), reg, -1);
    sregex_token_iterator end;

    vector<string> vec(iter, end);

	return vec;
}

vector<SymbolInfo*> getdeclarationList(parseNode *node, string type) {
	vector<parseNode*> children = node->getChildren();

	vector<SymbolInfo*> declaration_list;

	// cout << children.size() << endl;

	if(children.size() == 1) {

		string name = children[0]->getSymbolName();
		declaration_list.push_back(new SymbolInfo(name, type, "normal"));

	} else if(children.size() == 4) {

		string name = children[0]->getSymbolName();
		declaration_list.push_back(new SymbolInfo(name, type, "array"));	

	} else if(children.size() == 6) {

		declaration_list = getdeclarationList(children[0], type);

		string name = children[2]->getSymbolName();
		declaration_list.push_back(new SymbolInfo(name, type, "array"));

		
	} else if(children.size() == 3) {
		
		declaration_list = getdeclarationList(children[0], type);

		string name = children[2]->getSymbolName();
		declaration_list.push_back(new SymbolInfo(name, type, "normal"));
	}


	return declaration_list;
}

vector<string> getparameterListTypes(parseNode *node) {
	vector<parseNode*> children = node->getChildren();

	vector<string> parameter_list;

	if(children.size() == 1) {
		string type = children[0]->getChildren()[0]->getSymbolType(); //parameter-list -> type_specifier -> INT/FLOAT
		parameter_list.push_back(type);
		
	} else if(children.size() == 2) {
		string type = children[0]->getChildren()[0]->getSymbolType();
		parameter_list.push_back(type);


	} else if(children.size() == 3) {

		parameter_list = getparameterListTypes(children[0]);

		string type = children[2]->getChildren()[0]->getSymbolType();
		parameter_list.push_back(type);


	} else if(children.size() == 4) {

		parameter_list = getparameterListTypes(children[0]);

		string type = children[2]->getChildren()[0]->getSymbolType();

		parameter_list.push_back(type);


	}

	return parameter_list;

}

vector<string> getparameterListNames(parseNode *node) {
	vector<parseNode*> children = node->getChildren();

	vector<string> parameter_list;

	if(children.size() == 1) {
		// string type = children[0]->getChildren()[0]->getSymbolName(); //parameter-list -> type_specifier -> INT/FLOAT
		// parameter_list.push_back(type);
		
	} else if(children.size() == 2) {

		string type = children[1]->getSymbolName();
		parameter_list.push_back(type);


	} else if(children.size() == 3) {

		parameter_list = getparameterListNames(children[0]);

		// string type = children[2]->getChildren()[0]->getSymbolName();
		// parameter_list.push_back(type);


	} else if(children.size() == 4) {

		parameter_list = getparameterListNames(children[0]);

		string type = children[3]->getSymbolName();

		parameter_list.push_back(type);


	}

	return parameter_list;

}


vector<string> getargumentsTypes(parseNode *node) {
		
	vector<parseNode*> children = node->getChildren();

	vector<string> argumentsTypes;

	if(children.size() == 1) {
		argumentsTypes.push_back(children[0]->getextraInfo());
	} else if(children.size() == 3) {
		argumentsTypes = getargumentsTypes(children[0]);
		argumentsTypes.push_back(children[2]->getextraInfo());
	}

	return argumentsTypes;
}

vector<string> getargumentListTypes(parseNode *node) {

	//argument_list

	vector<parseNode*> children = node->getChildren();

	vector<string> argument_list;

	if(children.size() == 0) {

	} else if(children.size() == 1) {


		parseNode* arguments = children[0];

		//arguments

		argument_list = getargumentsTypes(arguments);
	}

	return argument_list;

}

int matchArgumentToParameter(vector<string> parameter_list_info, vector<string> argument_list) {


	int parameter_list_size = parameter_list_info.size() - 2;

	if(parameter_list_size > argument_list.size()) return -1;

	if(parameter_list_size < argument_list.size()) return -2;
	

	for(int i = 0; i < parameter_list_size; i++) {
		if(argument_list[i] != parameter_list_info[i+2]) return i+1;
	}

	return -3;

}


%}


%code requires {
	#include "parseNode.h"
}

%define api.value.type { parseNode* }



%token IF FOR DO INT FLOAT VOID SWITCH DEFAULT ELSE WHILE BREAK CHAR DOUBLE RETURN CASE CONTINUE MAIN CONST_INT CONST_FLOAT CONST_CHAR ASSIGNOP NOT LPAREN RPAREN LTHIRD RTHIRD LCURL RCURL COMMA SEMICOLON ADDOP MULOP INCOP DECOP RELOP LOGICOP BITOP ID PRINTLN


%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%start start


%%

start : program
	{
		//write your code in this block in all the similar blocks below

		// cout << yylineno << endl;

		$$ = new parseNode(new SymbolInfo("program", "start"), yylineno);
		$$->addChild($1);

		$$->print(0, parseout);

		fprintf(logout, "start : program\n");

		fprintf(logout, "Total Lines: %d\n", yylineno);
		fprintf(logout, "Total Errors: %d\n", error_count);

		startICG($$);



	}
	;

program : program unit {
		$$ = new parseNode(new SymbolInfo("program unit", "program"), yylineno);
		$$->addChild($1);
		$$->addChild($2);

		fprintf(logout, "program : program unit\n");
	}
	| unit {
		$$ = new parseNode(new SymbolInfo("unit", "program"), yylineno);
		$$->addChild($1);	

		fprintf(logout, "program : unit\n");

	}
	;
	
unit : var_declaration {
		$$ = new parseNode(new SymbolInfo("var_declaration", "unit"), yylineno);
		$$->addChild($1);

		fprintf(logout, "unit : var_declaration\n" );

	}
     | func_declaration {
		$$ = new parseNode(new SymbolInfo("func_declaration", "unit"), yylineno);
		$$->addChild($1);
		
		fprintf(logout, "unit : func_declaration\n");

	 }
     | func_definition {
		$$ = new parseNode(new SymbolInfo("func_definition", "unit"), yylineno);
		$$->addChild($1);
		fprintf(logout,"unit : func_definition\n" );

	 }
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {	

			//check_error: Function re-declaration
			
			string type = $1->getChildren()[0]->getSymbolType();
			string name = $2->getSymbolName();

			vector<string> parameter_list_types = getparameterListTypes($4);	


			string extra_info = "function " +  to_string(parameter_list_types.size()) + " ";

			// cout << parameter_list_types.size() << endl;

			for(string t: parameter_list_types){
				extra_info += (t + " ");
			}


			SymbolInfo *s = new SymbolInfo(name, type, extra_info);

			
			// cout << s->getName() << " " << s->getType() << " " << s->getextraInfo() << endl;
			
			bool isInserted = ST.insert(s);

			if(!isInserted) {
				fprintf(errorout, "Line# %d: Function re-declaration\n" , yylineno );
				error_count++;
			}

			
			

			$$ = new parseNode(new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN SEMICOLON", "func_declaration"), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->addChild($6);

			fprintf(logout, "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n");

		}
		| type_specifier ID LPAREN RPAREN SEMICOLON {

			//check_error: Function re-declaration

			string type = $1->getChildren()[0]->getSymbolType();
			string name = $2->getSymbolName();


			SymbolInfo *s = new SymbolInfo(name, type, "function");

			
			// cout << s->getName() << " " << s->getType() << " " << s->getextraInfo() << endl;
			
			bool isInserted = ST.insert(s);

			if(!isInserted) {
				fprintf(errorout, "Line# %d: Function re-declaration\n" , yylineno );
				error_count++;
			}


			$$ = new parseNode(new SymbolInfo("type_specifier ID LPAREN RPAREN SEMICOLON", "func_declaration"), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			fprintf(logout, "func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n");

		}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN {


			string type = $1->getChildren()[0]->getSymbolType();
			string name = $2->getSymbolName();

			vector<string> parameter_list_types = getparameterListTypes($4);	
			vector<string> parameter_list_names = getparameterListNames($4);

			string extra_info = "function " +  to_string(parameter_list_types.size()) + " ";

			// cout << parameter_list_types.size() << endl;

			for(string t: parameter_list_types){
				extra_info += (t + " ");
			}

			SymbolInfo *s = new SymbolInfo(name, type, extra_info);

			
			// cout << s->getName() << " " << s->getType() << " " << s->getextraInfo() << endl;
			
			bool isInserted = ST.insert(s);

			if(find(definedFunction.begin(), definedFunction.end(), name) != definedFunction.end()) {
				fprintf(errorout, "Line# %d: Function re-declaration\n" , yylineno );
				error_count++;
			} else {

				if(!isInserted) {

					SymbolInfo *declaredSymbol = ST.look_up(name);

					if(s->getFirstInfo() != declaredSymbol->getFirstInfo()) {

						fprintf(errorout, "Line# %d: '%s' redeclared as different kind of symbol\n" , yylineno, name.c_str());
						error_count++; 

					} else if(s->getFirstInfo() == "FUNCTION") {

						if(type != declaredSymbol->getType()) {

							fprintf(errorout, "Line# %d: Conflicting types for '%s'\n" , yylineno, name.c_str());
							error_count++;

						} else {

							definedFunction.push_back(name);
							
						}
					}
					
				}
			}


			ST.enter_scope(); 
			// cout << "enter scope" << yylineno << endl;
			insideScope = true;

			for(int i = 0, j = 0; i < parameter_list_types.size(); i++) {

				SymbolInfo *newS = new SymbolInfo(parameter_list_names[j], parameter_list_types[i]);

				bool isInserted = ST.insert(newS);

				if(!isInserted) {
					fprintf(errorout, "Line# %d: Redefinition of parameter '%s'\n" , yylineno, parameter_list_names[j].c_str());

				}


				j++;
			}

			
			} compound_statement {


			$$ = new parseNode(new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN compound_statement", "func_definition"), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->addChild($7);


			fprintf(logout, "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n");
			
	
		}
		| type_specifier ID LPAREN RPAREN {


			string type = $1->getChildren()[0]->getSymbolType();
			string name = $2->getSymbolName();
			string extra_info = "FUNCTION";

			SymbolInfo *s = new SymbolInfo(name, type, extra_info);

			// cout << s->getName() << " " << s->getType() << " " << s->getextraInfo() << endl;
			
			bool isInserted = ST.insert(s);

			if(find(definedFunction.begin(), definedFunction.end(), name) != definedFunction.end()) {
				fprintf(errorout, "Line# %d: Function re-declaration\n" , yylineno );
				error_count++;
			} else {

				if(!isInserted) {
					SymbolInfo *declaredSymbol = ST.look_up(name);

					if(type != declaredSymbol->getType()) {
						fprintf(errorout, "Line# %d: Conflicting types for '%s'\n" , yylineno, name.c_str());
						error_count++;
					} else {
						definedFunction.push_back(name);
					}
				}
			}

			

			ST.enter_scope(); 
			// cout << "enter scope" << yylineno << endl;
			insideScope = true;

			} compound_statement {

			

			$$ = new parseNode(new SymbolInfo("type_specifier ID LPAREN RPAREN compound_statement", "func_definition"), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($6);
			
			fprintf(logout, "func_definition : type_specifier ID LPAREN RPAREN compound_statement\n");

			
		}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID {

		//check_error: redefinition of parameter 

			$$ = new parseNode(new SymbolInfo("parameter_list COMMA type_specifier ID", "parameter_list"), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			
			fprintf(logout, "parameter_list  : parameter_list COMMA type_specifier ID\n");

		}
		| parameter_list COMMA type_specifier {
			$$ = new parseNode(new SymbolInfo("parameter_list COMMA type_specifier", "parameter_list"), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			
			fprintf(logout, "parameter_list  : parameter_list COMMA type_specifier\n" );

		}
 		| type_specifier ID {

			//check_error: redefination of parameter 
			
			$$ = new parseNode(new SymbolInfo("type_specifier ID", "parameter_list"), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			
			fprintf(logout, "parameter_list  : type_specifier ID\n");
		

		}
		| type_specifier {
			$$ = new parseNode(new SymbolInfo("type_specifier", "parameter_list"), yylineno);
			$$->addChild($1);
			
			fprintf(logout, "parameter_list  : type_specifier\n");

		}
 		;

 		
compound_statement : LCURL{
				if(!insideScope) {
					ST.enter_scope();
					// cout << "enter scope" << yylineno << endl;
				} 
				insideScope = false;

} statements RCURL {
				$$ = new parseNode(new SymbolInfo("LCURL statements RCURL", "compound_statement"), yylineno);
				$$->addChild($1);
				$$->addChild($3);
				$$->addChild($4);
			
				fprintf(logout, "compound_statement : LCURL statements RCURL\n");

				ST.print_all_scopeLex(logout);
				ST.exit_scope();		

				// compound_statement($$);	
			}
 		    | LCURL RCURL {
				$$ = new parseNode(new SymbolInfo("LCURL RCURL", "compound_statement"), yylineno);
				$$->addChild($1);
				$$->addChild($2);
			
				fprintf(logout, "compound_statement : LCURL RCURL\n");
			}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON {

			//check_error: Variable of field declared void, redefination of parameter

			string type = $1->getChildren()[0]->getSymbolType();

			if(type == "VOID") {
				fprintf(errorout, "Line# %d: Variable or field ' ' declared void\n" , yylineno);
				
				error_count++;
			}

			vector<SymbolInfo*> declaration_list = getdeclarationList($2, type);

			for(SymbolInfo *s: declaration_list) {
				// cout << s->getName() << " " << s->getType() << " " << s->getextraInfo() << endl;
				
				bool isInserted = ST.insert(s);

				if(!isInserted) {
					fprintf(errorout, "Line# %d: redifinition of parameter \'%s\'\n" , yylineno, s->getName().c_str());
					error_count++;
					delete s;
				}
			}

			// ST.print_current_scope();
			// cout << type << endl;

			$$ = new parseNode(new SymbolInfo("type_specifier declaration_list SEMICOLON", "var_declaration"), yylineno);
			$$->addChild($1); // new
			$$->addChild($2);
			$$->addChild($3);

			fprintf(logout, "var_declaration : type_specifier declaration_list SEMICOLON\n");
		}
 		 ;
 		 
type_specifier	: INT {
			$$ = new parseNode(new SymbolInfo("INT", "type_specifier"), yylineno);
			$$->addChild($1);
			
			fprintf(logout, "type_specifier\t: INT\n");

		}
 		| FLOAT {
			$$ = new parseNode(new SymbolInfo("FLOAT", "type_specifier"), yylineno);
			$$->addChild($1);
			
			fprintf(logout, "type_specifier\t: FLOAT\n");

		}
 		| VOID {
			$$ = new parseNode(new SymbolInfo("VOID", "type_specifier"), yylineno);
			$$->addChild($1);
			
			fprintf(logout, "type_specifier\t: VOID\n");

		}
 		;
 		
declaration_list : declaration_list COMMA ID {
			$$ = new parseNode(new SymbolInfo("declaration_list COMMA ID", "declaration_list"), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			
			fprintf(logout, "declaration_list : declaration_list COMMA ID\n");


		  }
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
			$$ = new parseNode(new SymbolInfo("declaration_list COMMA ID LSQUARE CONST_INT RSQUARE", "declaration_list"), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->addChild($6);
			
			fprintf(logout, "declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE\n");

		  }
 		  | ID {
			$$ = new parseNode(new SymbolInfo("ID", "declaration_list"), yylineno);
			$$->addChild($1);

			
			fprintf(logout, "declaration_list : ID\n");
	
		  }
 		  | ID LTHIRD CONST_INT RTHIRD {
			$$ = new parseNode(new SymbolInfo("ID LSQUARE CONST_INT RSQUARE", "declaration_list"), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			
			fprintf(logout, "declaration_list : ID LSQUARE CONST_INT RSQUARE\n");


		  }
 		  ;
 		  
statements : statement {
			$$ = new parseNode(new SymbolInfo("statement", "statements"), yylineno);
			$$->addChild($1);
			
			fprintf(logout, "statements : statement\n");

			// statements($$);


	    }
	   | statements statement {
			$$ = new parseNode(new SymbolInfo("statements statement", "statements"), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			
			fprintf(logout, "statements : statements statement\n");

			// statements($$);

	   }
	   ;
	   
statement : var_declaration {
			$$ = new parseNode(new SymbolInfo("var_declaration", "statement"), yylineno);
			$$->addChild($1);
			
			fprintf(logout, "statement : var_declaration\n" );

		}
	  | expression_statement {
			$$ = new parseNode(new SymbolInfo("expression_statement", "statement"), yylineno);
			$$->addChild($1);
			
			fprintf(logout, "statement : expression_statement\n");

	  }
	  | compound_statement {
			$$ = new parseNode(new SymbolInfo("compound_statement", "statement"), yylineno);
			$$->addChild($1);
			
			fprintf(logout, "statement : compound_statement\n");

	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
			$$ = new parseNode(new SymbolInfo("FOR LPAREN expression_statement expression_statement expression RPAREN statement", "statement"), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->addChild($6);
			$$->addChild($7);
			
			fprintf(logout, "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n");

	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE { // shift-reduce conflict
			$$ = new parseNode(new SymbolInfo("IF LPAREN expression RPAREN statement", "statement"), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			
			fprintf(logout, "statement : IF LPAREN expression RPAREN statement %%prec THEN\n");
			
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement {
			$$ = new parseNode(new SymbolInfo("IF LPAREN expression RPAREN statement ELSE statement", "statement"), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			$$->addChild($6);
			$$->addChild($7);
			
			fprintf(logout, "statement : IF LPAREN expression RPAREN statement ELSE statement\n");

	  }
	  | WHILE LPAREN expression RPAREN statement {
			$$ = new parseNode(new SymbolInfo("WHILE LPAREN expression RPAREN statement", "statement"), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			
			fprintf(logout, "statement : WHILE LPAREN expression RPAREN statement\n");

	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {
			$$ = new parseNode(new SymbolInfo("PRINTLN LPAREN ID RPAREN SEMICOLON", "statement"), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			$$->addChild($5);
			
			fprintf(logout,"statement: PRINTLN LPAREN ID RPAREN SEMICOLON\n" );

	  }
	  | RETURN expression SEMICOLON {
			$$ = new parseNode(new SymbolInfo("RETURN expression SEMICOLON", "statement"), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			
			fprintf(logout, "statement : RETURN expression SEMICOLON\n");

	  }
	  ;
	  
expression_statement 	: SEMICOLON {
			$$ = new parseNode(new SymbolInfo("SEMICOLON", "expression_statement"), yylineno);
			$$->addChild($1);
			
			fprintf(logout, "expression_statement : SEMICOLON\n");

		
		}	
		| expression SEMICOLON {
			$$ = new parseNode(new SymbolInfo("expression SEMICOLON", "expression_statement"), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			
			fprintf(logout, "expression_statement : expression SEMICOLON\n");

		}
		;
	  
variable : ID {

		//check_error: undeclared variable, function cannot used as variable, array used as normal variable

		string type = "INT";
		SymbolInfo *symbol = ST.look_up($1->getSymbolName());

		if(symbol == NULL) {
			fprintf(errorout, "Line# %d: Undeclared variable '%s'\n", yylineno, $1->getSymbolName().c_str());
			error_count++;
		} else {
			type =  symbol->getType();
			
			// cout << "variable: " << type << endl;

			if(symbol->getFirstInfo()== "FUNCTION") {
				fprintf(errorout, "Line# %d: Fuction used as a normal variable\n", yylineno );
				error_count++;
			} else if(symbol->getFirstInfo()== "ARRAY") {
				fprintf(errorout, "Line# %d: Array used as a normal variable\n", yylineno );
				error_count++;
			}
		}


		$$ = new parseNode(new SymbolInfo("ID", "variable", type), yylineno);
		$$->addChild($1);
			
		fprintf(logout, "variable : ID\n");

	 }	
	 | ID LTHIRD expression RTHIRD {

		//check_error: undeclared variable, function cannot used as variable, array used as normal variable, array access operation is not integer

		string type = "INT";
		SymbolInfo *symbol = ST.look_up($1->getSymbolName());

		if(symbol == NULL) {
			fprintf(errorout, "Line# %d: undeclared variable\n", yylineno);
			error_count++;
		} else {
			type =  symbol->getType();
			

			if(symbol->getextraInfo() == "normal") {
				fprintf(errorout, "Line# %d: '%s' is not an array\n", yylineno, symbol->getName().c_str() );
				error_count++;
			}
		}

		if($3->getextraInfo() != "INT") {
				fprintf(errorout, "Line# %d: Array subscript is not an integer\n", yylineno );
				error_count++;
		}

		$$ = new parseNode(new SymbolInfo("ID LSQUARE expression RSQUARE", "variable"), yylineno);
		$$->addChild($1);
		$$->addChild($2);
		$$->addChild($3);
		$$->addChild($4);
			
		fprintf(logout, "variable : ID LSQUARE expression RSQUARE\n");

	 }
	 ;
	 
 expression : logic_expression {
			$$ = new parseNode(new SymbolInfo("logic_expression", "expression", $1->getextraInfo()), yylineno);
			$$->addChild($1);
			
			fprintf(logout, "expression \t: logic_expression\n");

 		}
	   | variable ASSIGNOP logic_expression  {

		//check_error: Void cannot be used in expression, Assignment of float to int

			string type1 = $1->getextraInfo();
			string type2 = $3->getextraInfo();

			string type = "INT";

			if(type1 == "VOID" || type2 == "VOID") {
				
				fprintf(errorout, "Line# %d: Void cannot be used in expression\n", yylineno);
				error_count++;
			}

			if(type1 == "INT" && type2 == "FLOAT") {
				fprintf(errorout, "Line# %d : Warning: possible loss of data in assignment of FLOAT to INT\n", yylineno);
				error_count++;
			}
			

			$$ = new parseNode(new SymbolInfo("variable ASSIGNOP logic_expression", "expression", $1->getextraInfo()), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			
			fprintf(logout, "expression \t: variable ASSIGNOP logic_expression\n");

	   }	
	   ;
			
logic_expression : rel_expression {
			$$ = new parseNode(new SymbolInfo("rel_expression", "logic_expression", $1->getextraInfo()), yylineno);
			$$->addChild($1);
			
			fprintf(logout, "logic_expression : rel_expression\n" );
		}
		 | rel_expression LOGICOP rel_expression {

		//check_error: Void cannot be used in expression

			string type1 = $1->getextraInfo();
			string type2 = $3->getextraInfo();

			string type = "INT";

			if(type1 == "VOID" || type2 == "VOID") {
				// fprintf(errorout, "Error at line# %d : operation cannot be of void\n", yylineno);
				fprintf(errorout, "Line# %d: Void cannot be used in expression\n", yylineno);
				error_count++;

			}

			$$ = new parseNode(new SymbolInfo("rel_expression LOGICOP rel_expression", "logic_expression", "INT"), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			
			fprintf(logout, "logic_expression : rel_expression LOGICOP rel_expression\n");

		 }
		 ;
			
rel_expression	: simple_expression {
			$$ = new parseNode(new SymbolInfo("simple_expression", "rel_expression", $1->getextraInfo()), yylineno);
			$$->addChild($1);
			
			fprintf(logout,"rel_expression\t: simple_expression\n" );


		}	
		| simple_expression RELOP simple_expression	{

		//check_error: Void cannot be used in expression

			string type1 = $1->getextraInfo();
			string type2 = $3->getextraInfo();

			string type = "INT";

			if(type1 == "VOID" || type2 == "VOID") {
				// fprintf(errorout, "Error at line# %d : operation cannot be of void", yylineno);
				fprintf(errorout, "Line# %d: Void cannot be used in expression\n", yylineno);
				error_count++;
			}

			$$ = new parseNode(new SymbolInfo("simple_expression RELOP simple_expression", "rel_expression", "INT"), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			
			fprintf(logout, "rel_expression\t: simple_expression RELOP simple_expression\n");

		}
		;
				
simple_expression : term {
			$$ = new parseNode(new SymbolInfo("term", "simple_expression", $1->getextraInfo()), yylineno);
			$$->addChild($1);
			
			fprintf(logout, "simple_expression : term\n" );


		}
		| simple_expression ADDOP term {

		//check_error: Void cannot be used in expression

			string type1 = $1->getextraInfo();
			string type2 = $3->getextraInfo();

			string type = "INT";

			if(type1 == "VOID" || type2 == "VOID") {
				// fprintf(errorout, "operation cannot be of void");
				fprintf(errorout, "Line# %d: Void cannot be used in expression\n", yylineno);
				error_count++;
			}

			if(type1 == "FLOAT" || type2 == "FLOAT") type = "FLOAT";
			
			$$ = new parseNode(new SymbolInfo("simple_expression ADDOP term", "simple_expression", type), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			
			fprintf(logout, "simple_expression : simple_expression ADDOP term\n" );
			

		}
		  ;
					
term :	unary_expression {
			$$ = new parseNode(new SymbolInfo("unary_expression", "term", $1->getextraInfo()), yylineno);
			$$->addChild($1);
			
			fprintf(logout, "term :\tunary_expression\n");


	}
     |  term MULOP unary_expression {

		//check_error: Void cannot be used in expression

			string type1 = $1->getextraInfo();
			string type2 = $3->getextraInfo();

			string type = "INT";

			if($2->getSymbolName() == "%") {
				if(type1 != "INT" || type2 != "INT") {
					fprintf(errorout, "Line# %d : Operands of modulus must be integers\n", yylineno);
					error_count++;
				}
			}

			if(type1 == "VOID" || type2 == "VOID") {
				fprintf(errorout, "Line# %d: Void cannot be used in expression\n", yylineno);
				error_count++;
			}

			if(type1 == "FLOAT" || type2 == "FLOAT") type = "FLOAT";



			$$ = new parseNode(new SymbolInfo("term MULOP unary_expression", "term", type), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			
			fprintf(logout, "term :\tterm MULOP unary_expression\n");

	 }
     ;

unary_expression : ADDOP unary_expression {

		//check_error: Void cannot be used in expression

			string type = $2->getextraInfo();

			if(type == "VOID") {
				fprintf(errorout, "Line# %d: Void cannot be used in expression\n", yylineno);
				error_count++;

			}

			$$ = new parseNode(new SymbolInfo("ADDOP unary_expression", "unary_expression", $2->getextraInfo()), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			
			fprintf(logout, "unary_expression : ADDOP unary_expression\n");

		}  
		 | NOT unary_expression {

		//check_error: Void cannot be used in expression

			string type = $2->getextraInfo();

			if(type == "VOID") {
				fprintf(errorout, "Line# %d: Void cannot be used in expression\n", yylineno);
				error_count++;
			}

			$$ = new parseNode(new SymbolInfo("NOT unary_expression", "unary_expression", "INT"), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			
			fprintf(logout, "unary_expression: NOT unary_expression\n");

		 }
		 | factor {
			$$ = new parseNode(new SymbolInfo("factor", "unary_expression", $1->getextraInfo()), yylineno);
			$$->addChild($1);
			
			fprintf(logout, "unary_expression : factor\n");

		 }
		 ;
	
factor	: variable {
			$$ = new parseNode(new SymbolInfo("variable", "factor", $1->getextraInfo()), yylineno);
			$$->addChild($1);
			
			fprintf(logout, "factor\t: variable\n");

	}
	| ID LPAREN argument_list RPAREN {

		//check_error: undeclared function, cannot call variable, arguments does not match


			string type = "INT";
			SymbolInfo *symbol = ST.look_up($1->getSymbolName());


			if(symbol == NULL) {
				fprintf(errorout, "Line# %d: Undeclared function '%s'\n", yylineno, $1->getSymbolName().c_str());
				error_count++;
			} else {
				type =  symbol->getType();
				
				// cout << "variable: " << type << endl;

				vector<string> split_extraInfo = splitString(symbol->getextraInfo());

				// for(string s: split_extraInfo ) cout << s << endl;

				if(split_extraInfo[0] != "function") {
					fprintf(errorout, "Line# %d: Cannot call variable\n", yylineno );
					error_count++;
				}


				vector<string> argumentType_list = getargumentListTypes($3);

				// for(string s: argumentType_list) cout << s << " ";

				// cout <<endl;

				int matched = matchArgumentToParameter(split_extraInfo, argumentType_list);


				if(matched == -1)  {
					fprintf(errorout, "Line# %d: Too few arguments to function '%s'\n", yylineno, symbol->getName().c_str() );
					error_count++;
				} else if(matched == -2) {
					fprintf(errorout, "Line# %d: Too many arguments to function '%s'\n", yylineno, symbol->getName().c_str() );
					error_count++;
				} else if(matched == -3) {

				} else {
					fprintf(errorout, "Line# %d: Type mismatch for argument %d of '%s'\n", yylineno, matched, symbol->getName().c_str() );
					error_count++;
				}
			}

			$$ = new parseNode(new SymbolInfo("ID LPAREN argument_list RPAREN", "factor", type), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			$$->addChild($4);
			
			fprintf(logout, "factor\t: ID LPAREN argument_list RPAREN\n");

	}
	| LPAREN expression RPAREN {
			$$ = new parseNode(new SymbolInfo("LPAREN expression RPAREN", "factor", $2->getextraInfo()), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			$$->addChild($3);
			
			fprintf(logout, "factor\t: LPAREN expression RPAREN\n");

	}
	| CONST_INT {
			$$ = new parseNode(new SymbolInfo("CONST_INT", "factor", "INT"), yylineno);
			$$->addChild($1);
			
			fprintf(logout, "factor\t: CONST_INT\n");

	}
	| CONST_FLOAT {
			$$ = new parseNode(new SymbolInfo("CONST_FLOAT", "factor", "FLOAT"), yylineno);
			$$->addChild($1);
			
			fprintf(logout, "factor\t: CONST_FLOAT\n");

	}
	| variable INCOP {

		//check_error: Void cannot be used in expression

			string type = $1->getextraInfo();

			if(type == "VOID") {
				fprintf(errorout, "Line# %d: Void cannot be used in expression\n", yylineno);
				error_count++;
				type = "INT";
			}

			$$ = new parseNode(new SymbolInfo("variable INCOP", "factor", type), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			
			fprintf(logout, "factor\t: variable INCOP\n");

			// cout

	}
	| variable DECOP {

		//check_error: Void cannot be used in expression

			string type = $1->getextraInfo();

			if(type == "VOID") {
				fprintf(errorout, "Line# %d: Void cannot be used in expression\n", yylineno);
				error_count++;
				type = "INT";
			}

			$$ = new parseNode(new SymbolInfo("variable DECOP", "factor", type), yylineno);
			$$->addChild($1);
			$$->addChild($2);
			
			fprintf(logout, "factor\t: variable DECOP\n");

	}
	;
	
argument_list : arguments {
				$$ = new parseNode(new SymbolInfo("arguments", "argument_list"), yylineno);
				$$->addChild($1);
			
				fprintf(logout, "argument_list : arguments\n");

		}
		|  {
				$$ = new parseNode(new SymbolInfo("", "argument_list"), yylineno);
			
				fprintf(logout, "argument_list : \n" );

		}
		;
	
arguments : arguments COMMA logic_expression {
				$$ = new parseNode(new SymbolInfo("arguments COMMA logic_expression", "arguments", $3->getextraInfo()), yylineno);
				$$->addChild($1);
				$$->addChild($2);
				$$->addChild($3);
			
				fprintf(logout, "arguments : arguments COMMA logic_expression\n");

		  }
	      | logic_expression {
				$$ = new parseNode(new SymbolInfo("logic_expression", "arguments", $1->getextraInfo()), yylineno);
				$$->addChild($1);
			
				fprintf(logout, "arguments : logic_expression\n");

		  }
	      ;
 

%%
int main(int argc,char *argv[])
{
	auto fp = fopen(argv[1], "r");

	if(fp == NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	// fp2= fopen(argv[2],"w");
	// fclose(fp2);
	// fp3= fopen(argv[3],"w");
	// fclose(fp3);
	
	// fp2= fopen(argv[2],"a");
	// fp3= fopen(argv[3],"a");
	

	yyin=fp;


	logout = fopen("1905120_log.txt","w");
	parseout = fopen("1905120_parser.txt", "w");
	errorout = fopen("1905120_error.txt", "w");
	tokenout = fopen("1905120_token.txt", "w");

	// printf("%p %p %p %p\n", logout, parseout, errorout, tokenout);

	yyparse();
	

	// fclose(fp2);
	// fclose(fp3);

	fclose(fp);
	
	return 0;
}

