#ifndef _ICG_
#define _IGG

#include "parseNode.h"
#include "AsmWrite.h"
#include "1905120_symbolTable.h"
#include "astNode.h"
#include "helper.h"
#include<algorithm>

AsmWrite asmWrite;
SymbolTable ST_ICG(11);

int codeStart = false;
Helper helper(asmWrite, 1);

void startICG(parseNode* start);
void processUnit(parseNode *unit);
void global_var_declaration(parseNode *var_declr);
void fun_definition(parseNode *fun_def);
int compound_statement(parseNode *comp_stm, int var_count);
int statements(parseNode *stms, int var_count);
int statement(parseNode *stm, int var_count);
int var_declaration(parseNode *var_declr, int var_count);
string expression_statement(parseNode *exp_stm);
AstNode* expression(parseNode* exp);
AstNode* logic_expression(parseNode* logic_exp);
AstNode* rel_expression(parseNode* rel_exp);
AstNode* simple_expression(parseNode* sim_exp);
AstNode* term(parseNode* tm);
AstNode* unary_expression(parseNode* un_exp);
AstNode* factor(parseNode* fac);
AstNode* variable(parseNode* var);



vector<parseNode*> getUnitList(parseNode *program);
vector<SymbolInfo*> getdeclarationLists(parseNode *node, string type);
vector<string> getparameterListNamesICG(parseNode *node);
vector<parseNode*> getStatements(parseNode *statements);

void startICG(parseNode* start) {


    asmWrite.start();

    vector<parseNode*> units = getUnitList(start->getChildren()[0]);


		for(int i = 0 ; i < units.size(); i++) {
			// cout << "Test: " << units[i]->getSymbolName() << endl;
            processUnit(units[i]);
		}

	asmWrite.writeRaw("END MAIN");
} 



void processUnit(parseNode *unit) {
    if(unit->getSymbolName() == "var_declaration") {

		global_var_declaration(unit->getChildren()[0]);
        
    } else if (unit->getSymbolName() == "func_definition") {

		if(!codeStart) {
			asmWrite.writeRaw("\n.code\n");
			codeStart = true;

			asmWrite.func_println();
			asmWrite.func_newLine();
		}

        fun_definition(unit->getChildren()[0]);

    }
    
}


void global_var_declaration(parseNode *var_declr) {

		parseNode *type_specifier = var_declr->getChildren()[0];
        parseNode *declaration_list = var_declr->getChildren()[1];

        string type = type_specifier->getChildren()[0]->getSymbolType();
        

        vector<SymbolInfo*> declaration_lists = getdeclarationLists(declaration_list, type);


        for(SymbolInfo *s: declaration_lists) {

			s->setAccess_by(s->getName());

            ST_ICG.insert(s);
            // cout << s->getName() << " " << s->getType() << " " << s->getextraInfo() << endl;
            asmWrite.globalCode(s->getName());

			// cout << s->getAccess_by() << endl;

        }
}

void fun_definition(parseNode *fun_def) {


		if(fun_def->getChildren().size() == 6) {

			ST_ICG.enter_scope();

			int var_count = 0;

			string func_name = fun_def->getChildren()[1]->getSymbolName();

			asmWrite.func_start(func_name);

			vector<string> parameter_list_names = getparameterListNamesICG(fun_def->getChildren()[3]);

			for(string s: parameter_list_names) {
				
				var_count++;

				string access_by = "[BP-" + to_string(var_count*2) + "]";

				// cout << s << endl;
				SymbolInfo *param = new SymbolInfo(s, "INT");
				param->setAccess_by(access_by);
				ST_ICG.insert(param);
			}



		

			int total_param_var = compound_statement(fun_def->getChildren()[5], var_count);

			// ST_ICG.print_all_scope();

			asmWrite.func_end(func_name, total_param_var);


			helper.emptyAllReg();


		} else {

			ST_ICG.enter_scope();
			
			string func_name = fun_def->getChildren()[1]->getSymbolName();

			asmWrite.func_start(func_name);

			int total_param_var = compound_statement(fun_def->getChildren()[4], 0);

			// ST_ICG.print_all_scope();
			
			asmWrite.func_end(func_name, total_param_var);

			helper.emptyAllReg();

		}

		
}


int compound_statement(parseNode *comp_stm, int var_count) {

	int total_var = var_count;

	vector<parseNode*> statements = getStatements(comp_stm->getChildren()[1]);

		// cout << comp_stm->getSymbolName() << " " << comp_stm->getSymbolType() << endl;


	for(parseNode* stmt: statements) {
		// cout << stmt->getSymbolName() << " " << stmt->getSymbolType() << endl;
		total_var += statement(stmt, var_count);
	}

	return total_var;

}



int statement(parseNode *stm, int var_count) {

	if(stm->getSymbolName() == "var_declaration") {

		return var_declaration(stm->getChildren()[0], var_count);

	} else if(stm->getSymbolName() == "expression_statement") {

		expression_statement(stm->getChildren()[0]);

	} else if(stm->getSymbolName() == "compound_statement") {

		compound_statement(stm->getChildren()[0], var_count);

	} else if(stm->getSymbolName() == "FOR LPAREN expression_statement expression_statement expression RPAREN statement") {


			helper.setLineNo(stm->getstartLineNo());
			string label = helper.getLabel();


			asmWrite.writeRaw(";\tLine " + to_string(stm->getstartLineNo()) + " FOR LOOP");


			expression_statement(stm->getChildren()[2]);


			asmWrite.writeRaw( label + "_for_condition:");

			string condReg = expression_statement(stm->getChildren()[3]);
			

			asmWrite.writeRaw("\tCMP " + condReg + ",0\n" +
			 				"\tJZ " + label + "_for_end"
			);

			statement(stm->getChildren()[6], var_count);

			expression(stm->getChildren()[4])->asmGenerate(helper);

			asmWrite.writeRaw("\tJMP " + label + "_for_condition");

			asmWrite.writeRaw( label + "_for_end:");

			helper.emptyAllReg();



	} else if(stm->getSymbolName() == "IF LPAREN expression RPAREN statement") {

			helper.setLineNo(stm->getstartLineNo());

			asmWrite.writeRaw(";\tLine " + to_string(stm->getstartLineNo()) + " IF condition");

			string condReg = expression(stm->getChildren()[2])->asmGenerate(helper);

			string label = helper.getLabel();

			asmWrite.writeRaw("\tCMP " + condReg + ",0\n" +
			 				"\tJZ " + label + "_if_end"
			);

			statement(stm->getChildren()[4], var_count);
			
			asmWrite.writeRaw( label + "_if_end:");

			helper.emptyAllReg();

	} else if(stm->getSymbolName() == "IF LPAREN expression RPAREN statement ELSE statement") {

			helper.setLineNo(stm->getstartLineNo());

			asmWrite.writeRaw(";\tLine " + to_string(stm->getstartLineNo()) + " IF ELSE condition");

			string condReg = expression(stm->getChildren()[2])->asmGenerate(helper);

			string label = helper.getLabel();

			asmWrite.writeRaw("\tCMP " + condReg + ",0\n" +
			 				"\tJZ " + label + "_if_else"
			);

			statement(stm->getChildren()[4], var_count);

			asmWrite.writeRaw("\tJMP " + label + "_if_end");


			asmWrite.writeRaw( label + "_if_else:");

			statement(stm->getChildren()[6], var_count);

			
			asmWrite.writeRaw( label + "_if_end:");

			helper.emptyAllReg();


	} else if(stm->getSymbolName() == "WHILE LPAREN expression RPAREN statement") {

			helper.setLineNo(stm->getstartLineNo());
			string label = helper.getLabel();


			asmWrite.writeRaw(";\tLine " + to_string(stm->getstartLineNo()) + " WHILE LOOP");

			asmWrite.writeRaw( label + "_while_start:");

			string condReg = expression(stm->getChildren()[2])->asmGenerate(helper);



			asmWrite.writeRaw("\tCMP " + condReg + ",0\n" +
			 				"\tJZ " + label + "_while_end"
			);

			statement(stm->getChildren()[4], var_count);

			asmWrite.writeRaw("\tJMP " + label + "_while_start");

			asmWrite.writeRaw( label + "_while_end:");

			helper.emptyAllReg();


	} else if(stm->getSymbolName() == "PRINTLN LPAREN ID RPAREN SEMICOLON") {

		string id_name = stm->getChildren()[2]->getSymbolName();

		string access_by = (ST_ICG.look_up(id_name)->getAccess_by());

		asmWrite.call_println(access_by);

	} else if(stm->getSymbolName() == "RETURN expression SEMICOLON") {

	} 

	return 0;
}

int var_declaration(parseNode *var_declr, int var_count) {
	parseNode *type_specifier = var_declr->getChildren()[0];
	parseNode *declaration_list = var_declr->getChildren()[1];

	string type = type_specifier->getChildren()[0]->getSymbolType();
	

	vector<SymbolInfo*> declaration_lists = getdeclarationLists(declaration_list, type);
	
	for(SymbolInfo* s: declaration_lists) {
		var_count++;
		s->setAccess_by("[BP-" + to_string(var_count*2) + "]" );
		ST_ICG.insert(s);
	}

    asmWrite.varWrite(var_count);

	return var_count;

}


string expression_statement(parseNode *exp_stm) {
	vector<parseNode*> children = exp_stm->getChildren();

	asmWrite.writeRaw("\n;\tLine " + to_string(exp_stm->getstartLineNo()) + "\n");


	AstNode* node;

	string exp_result = "";

	if(children.size() == 2) {
		node = expression(children[0]);
		exp_result = node->asmGenerate(helper);

	} 

	return exp_result;
	
}

AstNode* expression(parseNode* exp) {

	vector<parseNode*> children = exp->getChildren();

	AstNode* node;

	if(children.size() == 1) {
		node = logic_expression(children[0]);
	} else if(children.size() == 3) {
		// cout << children[1]->getSymbolName() << " " << children[1]->getSymbolType() << endl;

		node = new AstNode(variable(children[0]), logic_expression(children[2]), children[1]->getSymbolName());
	}


	// asmWrite.writeRaw("\n;\tLine " + to_string(exp->getstartLineNo()) + "\n");

	helper.setLineNo(exp->getstartLineNo());


	//line number print

	return node;

}


AstNode* logic_expression(parseNode* logic_exp) {

	vector<parseNode*> children = logic_exp->getChildren();

	AstNode* node;

	if(children.size() == 1) {
		node = rel_expression(children[0]);
	} else if(children.size() == 3) {
		node = new AstNode(rel_expression(children[0]), rel_expression(children[2]), children[1]->getSymbolName());
	}

	return node;

}


AstNode* rel_expression(parseNode* rel_exp) {
	vector<parseNode*> children = rel_exp->getChildren();

	AstNode* node;

	if(children.size() == 1) {
		node = simple_expression(children[0]);
	} else if (children.size() == 3) {
		node = new AstNode(simple_expression(children[0]), simple_expression(children[2]), children[1]->getSymbolName());
	}
	
	return node;

}

AstNode* simple_expression(parseNode* sim_exp) {
	vector<parseNode*> children = sim_exp->getChildren();

	AstNode* node;

	if(children.size() == 1) {
		node = term(children[0]);
	} else if (children.size() == 3) {
		node = new AstNode(simple_expression(children[0]), term(children[2]), children[1]->getSymbolName());
	}
	
	return node;

}
AstNode* term(parseNode* tm) {
	vector<parseNode*> children = tm->getChildren();

	AstNode* node;

	if(children.size() == 1) {
		node = unary_expression(children[0]);
	} else if (children.size() == 3) {
		node = new AstNode(term(children[0]), unary_expression(children[2]), children[1]->getSymbolName());
	}
	
	return node;
}

AstNode* unary_expression(parseNode* un_exp) {
	vector<parseNode*> children = un_exp->getChildren();

	AstNode* node;

	if(children.size() == 1) {
		node = factor(children[0]);

	} else if (children.size() == 2) {
		
		node = new AstNode(unary_expression(children[1]), children[0]->getSymbolName());
		
	}
	
	return node;

}

AstNode* factor(parseNode* fac) {
	vector<parseNode*> children = fac->getChildren();

	AstNode* node;

	if(children.size() == 1) {

		if(children[0]->getSymbolType() == "variable") {
			node = variable(children[0]);
		} else if(children[0]->getSymbolType() == "CONST_INT") {
			// cout << children[0]->getSymbolName() << endl;

			node = new AstNode(children[0]->getSymbolName());

		} else if(children[0]->getSymbolType() == "CONST_FLOAT") {

			node = new AstNode(children[0]->getSymbolName());

		} 
		

	} else if (children.size() == 2) {

		node = new AstNode(variable(children[0]), children[1]->getSymbolName());
	
	}  else if (children.size() == 3) {
	
		node = expression(children[1]);
	
	}  else if (children.size() == 4) {
		
	}
	
	return node;
}

AstNode* variable(parseNode* var) {

	vector<parseNode*> children = var->getChildren();


	AstNode* node;

	if(children.size() == 1) {
		
		SymbolInfo *symbol = ST_ICG.look_up(children[0]->getSymbolName());

		// cout << symbol->getAccess_by() << endl;

		node = new AstNode(symbol->getAccess_by());
	

	} else if (children.size() == 4) {
		
	}
	
	return node;
}

vector<parseNode*> getUnitList(parseNode *program) {


	vector<parseNode*> children = program->getChildren();

	vector<parseNode*> units;
	
	// cout << children.size() << endl;

	if(children.size() == 1) {

		units.push_back(children[0]);

	} else if(children.size() == 2) {

		units = getUnitList(children[0]);
        units.push_back(children[1]);

	} 

	return units;
}


vector<SymbolInfo*> getdeclarationLists(parseNode *node, string type) {
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

		declaration_list = getdeclarationLists(children[0], type);

		string name = children[2]->getSymbolName();
		declaration_list.push_back(new SymbolInfo(name, type, "array"));

		
	} else if(children.size() == 3) {
		
		declaration_list = getdeclarationLists(children[0], type);

		string name = children[2]->getSymbolName();
		declaration_list.push_back(new SymbolInfo(name, type, "normal"));
	}


	return declaration_list;
}

vector<string> getparameterListNamesICG(parseNode *node) {
	vector<parseNode*> children = node->getChildren();

	vector<string> parameter_list;

	if(children.size() == 1) {
		// string type = children[0]->getChildren()[0]->getSymbolName(); //parameter-list -> type_specifier -> INT/FLOAT
		// parameter_list.push_back(type);
		
	} else if(children.size() == 2) {

		string type = children[1]->getSymbolName();
		parameter_list.push_back(type);


	} else if(children.size() == 3) {

		parameter_list = getparameterListNamesICG(children[0]);

		// string type = children[2]->getChildren()[0]->getSymbolName();
		// parameter_list.push_back(type);


	} else if(children.size() == 4) {

		parameter_list = getparameterListNamesICG(children[0]);

		string type = children[3]->getSymbolName();

		parameter_list.push_back(type);


	}

	return parameter_list;

}


vector<parseNode*> getStatements(parseNode *statements) {
	
	vector<parseNode*> children = statements->getChildren();

	vector<parseNode*> statementList;
	
	// cout << children.size() << endl;

	if(children.size() == 1) {

		statementList.push_back(children[0]);

	} else if(children.size() == 2) {

		statementList = getStatements(children[0]);
        statementList.push_back(children[1]);

	} 

	return statementList;
}



#endif