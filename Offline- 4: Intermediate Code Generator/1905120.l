%option noyywrap yylineno

%x MULTI_COMMENT

%{
#include<cstdio>
#include<cstdlib>
#include<vector>
#include "1905120_symbolTable.h"
#include "1905120.tab.h"

using namespace std;

int line_count = 1;
int error_count = 0;

string multi_line_comment = "";
int multi_line_count = 0;

extern FILE *logout;
extern FILE *tokenout;
extern FILE *errorout;

// SymbolTable st(10);

char lexemToChar(const char* s){
   // '(\\[nt\\afrbv0\"])'
    if( strlen(s) == 3 ) return s[1];
	if( s[1] == '\\') {
		if( s[2] == 'n' ) return '\n';
		if( s[2] == 't' ) return '\t';
		if( s[2] == '\\' ) return '\\';
		if( s[2] == 'a' ) return '\a';
		if( s[2] == 'f' ) return '\f';
		if( s[2] == 'r' ) return '\r';
		if( s[2] == 'b' ) return '\b';
		if( s[2] == 'v' ) return '\v';
		if( s[2] == '0' ) return '\0';
		if( s[2] == '\"' ) return '\"';
	}

	return '5';
}



void printString(string s) {

	

	string s2 = "";
	string str = "";
	int str_line = 0;

	//removing "//n" and ""

	for(int i = 1; i < s.length()-1; i++) {
		if(s[i] == '\\' && s[i+1] == '\n') {
			i++;
			str_line++;
		} else {
			s2 += s[i];
		}
	}

	for(int i = 0; i < s2.length(); i++) {
		// cout << i << s << endl;
		if(s2[i] == '\\') {
			if( s2[i+1] == 'n' ) { str += '\n'; i++;} 
			else if( s2[i+1] == 't' ) { str += '\t'; i++;}
			else if( s2[i+1] == '\\' ) {str += '\\'; i++;}
			else if( s2[i+1] == 'a' ) {str += '\a'; i++;}
			else if( s2[i+1] == 'f' ) {str += '\f'; i++;}
			else if( s2[i+1] == 'r' ) {str += '\r'; i++;}
			else if( s2[i+1] == 'b' ) {str += '\b'; i++;}
			else if( s2[i+1] == 'v' ) {str += '\v'; i++;}
			else if( s2[i+1] == '0' ) {str += '\0'; i++;}
			else if( s2[i+1] == '\"' ) {str += '\"'; i++;}
			
		} else {
			str += s2[i];
		}
		
	}

	if(str_line == 0) {
			fprintf(tokenout,"<SINGLE LINE STRING, %s>\n", str.c_str());
			fprintf(logout,"Line# %d: Token <SINGLE LINE STRING> Lexeme %s found\n",line_count, s.c_str());
	} else {
			fprintf(tokenout,"<MULTI LINE STRING, %s>\n", str.c_str());
			fprintf(logout,"Line# %d: Token <MULTI LINE STRING> Lexeme %s found\n",line_count, s.c_str());
			line_count += str_line;
	}
}

void printSingleComment(string sText) {

	int str_line = 0;

	//removing "//n" and ""

	for(int i = 0; i < sText.length(); i++) {
		if(sText[i] == '\\' && sText[i+1] == '\n') {
			i++;
			str_line++;
		} 
	}

	string str = sText.substr(0, sText.length()-1);

	fprintf(logout,"Line# %d: Token <SINGLE LINE COMMENT> Lexeme %s found\n",line_count, str.c_str());
	
	line_count += str_line;
	line_count++;
}

void theEnd() {
	// st.print_all_scopeLex(logout);
	// line_count--;

	// fprintf(logout, "Total lines: %d\n", line_count);
	// fprintf(logout, "Total errors: %d\n", error_count);
}

%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n
ESCAPES ['"nt\\afrbv0]
%%


\n 		   {line_count++;}

"if"		{
				fprintf(tokenout,"<IF, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <IF> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "IF"), line_count);
				return IF;
// {NEWLINE} {line_count++;}
			}
		
"else"		{
				fprintf(tokenout,"<ELSE, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <ELSE> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "ELSE"), line_count);
				return ELSE;
			}

"for"		{
				fprintf(tokenout,"<FOR, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <FOR> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "FOR"), line_count);
				return FOR;
			}

"while"		{
				fprintf(tokenout,"<WHILE, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <WHILE> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "WHILE"), line_count);
				return WHILE;
			}

"do"		{
				fprintf(tokenout,"<DO, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <DO> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "DO"), line_count);
				return DO;
			}

"break"		{
				fprintf(tokenout,"<BREAK, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <BREAK> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "BREAK"), line_count);
				return BREAK;
			}

"int"		{
				fprintf(tokenout,"<INT, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <INT> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "INT"), line_count);
				return INT;
			}

"char"		{
				fprintf(tokenout,"<CHAR, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <CHAR> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "CHAR"), line_count);
				return CHAR;
			}

"float"		{
				fprintf(tokenout,"<FLOAT, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <FLOAT> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "FLOAT"), line_count);
				return FLOAT;
			}

"double"	{
				fprintf(tokenout,"<DOUBLE, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <DOUBLE> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "DOUBLE"), line_count);
				return DOUBLE;
			}	 	

"void"		{
				fprintf(tokenout,"<VOID, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <VOID> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "VOID"), line_count);
				return VOID;
			}

"return"	{
				fprintf(tokenout,"<RETURN, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <RETURN> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "RETURN"), line_count);
				return RETURN;
			}

"switch"	{
				fprintf(tokenout,"<SWITCH, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <SWITCH> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "SWITCH"), line_count);
				return SWITCH;
			}

"case"		{
				fprintf(tokenout,"<CASE, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <CASE> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "CASE"), line_count);
				return CASE;
			}

"default"	{
				fprintf(tokenout,"<DEFAULT, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <DEFAULT> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "DEFAULT"), line_count);
				return DEFAULT;
			}

"continue"	{
				fprintf(tokenout,"<CONTINUE, %s>n", yytext);
				fprintf(logout,"Line# %d: Token <CONTINUE> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "CONTINUE"), line_count);
				return CONTINUE;
			}


"println"	{
				fprintf(tokenout,"<PRINTLN, %s>n", yytext);
				fprintf(logout,"Line# %d: Token <PRINTLN> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "PRINTLN"), line_count);
				return PRINTLN;
			}


{DIGIT}+ 	{
				fprintf(tokenout,"<CONST_INT, %s>\n", yytext);

				fprintf(logout,"Line# %d: Token <CONST_INT> Lexeme %s found\n",line_count,yytext);

			
				// fprintf(logout, "Cos%d\n", 2);
				yylval = new parseNode(new SymbolInfo(yytext, "CONST_INT"), line_count);
				return CONST_INT;
			}

({DIGIT}*\.{DIGIT}+(E[+-]?{DIGIT}+)?)|({DIGIT}+E{DIGIT}+) {
				fprintf(tokenout,"<CONST_FLOAT, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
				// ({DIGIT}*(\.{DIGIT}+(E(+-)?{DIGIT}+)?))|({DIGIT}+E{DIGIT}+) 
				yylval = new parseNode(new SymbolInfo(yytext, "CONST_FLOAT"), line_count);
				return CONST_FLOAT;
			}

{DIGIT}*\.{DIGIT}+\.({DIGIT}|\.)* {
				error_count++;
				fprintf(errorout, "Error at line# %d: TOO_MANY_DECIMAL_POINTS %s\n", line_count, yytext);
			}

({DIGIT}*\.{DIGIT}+E[+-]?{DIGIT}+\.({DIGIT}|\.)*)|({DIGIT}+E{DIGIT}+\.({DIGIT}|\.)*)  {
				error_count++;
				fprintf(errorout, "Error at line# %d: ILLFORMED_NUMBER %s\n", line_count, yytext);
			}

\'[^\\]\' 		|
'(\\[nt\\afrbv0\"])'	{		
				char c = lexemToChar(yytext);
				fprintf(tokenout,"<CONST_CHAR, %c>\n", c);
				fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %c found\n",line_count, c);
				yylval = new parseNode(new SymbolInfo(yytext, "CONST_CHAR"), line_count);
				return CONST_CHAR;
			}


'' 			{
				error_count++;
				fprintf(errorout, "Error at line# %d: EMPTY_CONST_CHAR %s\n", line_count, yytext);
			}

'.(.|(\\[nt\\afrbv0\"]))+' 	{	
				error_count++;
				fprintf(errorout, "Error at line# %d: MULTICHAR_CONST_CHAR %s\n", line_count, yytext);
			}		

"'\\'"	|
'([^'\\\n]|(\\{ESCAPES}))*\n		{
				error_count++;
				fprintf(errorout, "Error at line# %d: UNFINISHED_CONST_CHAR %s\n", line_count, yytext);
				line_count++;
			}

"+"		|
"-"			{
				fprintf(tokenout,"<ADDOP, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <ADDOP> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "ADDOP"), line_count);
				return ADDOP;
			}

"*"		|
"/"		|
"%" 		{
				fprintf(tokenout,"<MULOP, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <MULOP> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "MULOP"), line_count);
				return MULOP;
			}

"++"	{
				fprintf(tokenout,"<INCOP, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <INCOP> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "INCOP"), line_count);
				return INCOP;
			}	

"--"	{
				fprintf(tokenout,"<DECOP, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <DECOP> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "DECOP"), line_count);
				return DECOP;
			}

"<"		|
"<="	|
">"		|
">="	|
"=="	|
"!="		{
				fprintf(tokenout,"<RELOP, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <RELOP> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "RELOP"), line_count);
				return RELOP;
			}

"="			{
				fprintf(tokenout,"<ASSIGNOP, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "ASSIGNOP"), line_count);
				return ASSIGNOP;
			}

"&&"	|
"||"		{
				fprintf(tokenout,"<LOGICOP, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <LOGICOP> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "LOGICOP"), line_count);
				return LOGICOP;
			}

"&"		|
"|"		|
"^"		|
"<<"	|
">>"		{
				fprintf(tokenout,"<BITOP, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <BITOP> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "BITOP"), line_count);
				return BITOP;
			}

"!"			{
				fprintf(tokenout,"<NOT, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <NOT> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "NOT"), line_count);
				return NOT;
			}

"("			{
				fprintf(tokenout,"<LPAREN, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <LPAREN> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "LPAREN"), line_count);
				return LPAREN;
			}

")"			{
				fprintf(tokenout,"<RPAREN, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <RPAREN> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "RPAREN"), line_count);
				return RPAREN;
			}

"{"			{
				fprintf(tokenout,"<LCURL, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <LCURL> Lexeme %s found\n",line_count,yytext);
				// st.enter_scope(2);

				yylval = new parseNode(new SymbolInfo(yytext, "LCURL"), line_count);
				return LCURL;
			}

"}"			{
				fprintf(tokenout,"<RCURL, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <RCURL> Lexeme %s found\n",line_count,yytext);
				// st.exit_scope();
				yylval = new parseNode(new SymbolInfo(yytext, "RCURL"), line_count);
				return RCURL;
			}

"["			{
				fprintf(tokenout,"<LSQUARE, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <LSQUARE> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "LSQUARE"), line_count);
				return LTHIRD;
			}

"]"			{
				fprintf(tokenout,"<RSQUARE, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <RSQUARE> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "RSQUARE"), line_count);
				return RTHIRD;
			}
","			{
				fprintf(tokenout,"<COMMA, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <COMMA> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "COMMA"), line_count);
				return COMMA;
			}

";"			{
				fprintf(tokenout,"<SEMICOLON, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <SEMICOLON> Lexeme %s found\n",line_count,yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "SEMICOLON"), line_count);
				return SEMICOLON;
			}

(_|{LETTER})({LETTER}|{DIGIT}|_)* {
				fprintf(tokenout,"<ID, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <ID> Lexeme %s found\n",line_count,yytext);
				// SymbolInfo *s = new SymbolInfo(yytext, "ID");
				// bool inserted = st.insert(s);
				// if(inserted)
				// 	st.print_all_scopeLex(logout);
				// 	// 
				// else 
				// 	fprintf(logout, "\t%s already exisits in the current ScopeTable\n", yytext);
				yylval = new parseNode(new SymbolInfo(yytext, "ID"), line_count);
				return ID;
			}

{DIGIT}({LETTER}|{DIGIT}|_)* {
				error_count++;
				fprintf(errorout, "Error at line# %d: INVALID_ID_SUFFIX_NUM_PREFIX %s\n", line_count, yytext);
	
			}
\"(([^"\\\n]|(\\{ESCAPES}))|("\\\n"))*\" {
				// fprintf(tokenout,"<STRING, %s>\n", yytext);
				// fprintf(logout,"Line# %d: Token <STRING> Lexeme %s found\n",line_count,yytext);
				printString(yytext);
				
			}
			

\"(([^"\\\n]|(\\{ESCAPES}))|("\\\n"))*\n {
				error_count++;
				string text = yytext;
				fprintf(errorout, "Error at line# %d: UNFINISHED STRING %s\n", line_count, text.substr(0, text.length() - 1).c_str());
				line_count++;
			}	

"//"(.|(\\\n))*\n	{
				printSingleComment(yytext);
			}


"/*" 		{
				multi_line_comment += yytext;
				BEGIN(MULTI_COMMENT);
			}

{WHITESPACE}+ {}
			
.			{
				error_count++;
				fprintf(errorout, "Error at line# %d: UNRECOGNIZED_CHAR %s\n", line_count, yytext);
			}


<MULTI_COMMENT>"*/" {
				BEGIN(INITIAL);
				multi_line_comment += yytext;
				fprintf(logout,"Line# %d: Token <MULTI LINE COMMENT> Lexeme %s found\n",line_count, multi_line_comment.c_str());
				multi_line_comment = "";
				line_count += multi_line_count;
				line_count++;
			}

<MULTI_COMMENT>(\n) {
				multi_line_comment += yytext;
				multi_line_count++;
				// fprintf(logout, "l: %d, s: %s", line_count, multi_line_comment.c_str());
			}
<MULTI_COMMENT>([^*])+|.	{
				multi_line_comment += yytext;
			}
<MULTI_COMMENT><<EOF>>  {
				fprintf(errorout, "Error at line# %d: UNFINISHED COMMENT %s\n", line_count, multi_line_comment.c_str());
				line_count += multi_line_count;
				line_count++;
				theEnd();
				return 0;
		}

<INITIAL><<EOF>>	{
				theEnd();
				return 0;
			}

%%

// int main(int argc, char** argv) {
// 	if(argc!=2){
// 		printf("Please provide input file name and try again\n");
// 		return 0;
// 	}
	
// 	FILE *fin=fopen(argv[1],"r");
// 	if(fin==NULL){
// 		printf("Cannot open specified file\n");
// 		return 0;
// 	}
	
// 	logout= fopen("1905120_log.txt","w");
// 	tokenout= fopen("1905120_token.txt","w");

// 	yyin= fin;
// 	yylex();
// 	fclose(yyin);
// 	fclose(tokenout);
// 	fclose(logout);
// 	return 0;
// }
