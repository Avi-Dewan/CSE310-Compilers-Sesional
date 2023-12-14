%option noyywrap 

%x MULTI_COMMENT

%{
#include<cstdio>
#include<cstdlib>
#include<vector>
#include "1905120_symbolTable.h"

using namespace std;

int line_count = 1;
int error_count = 0;

string multi_line_comment = "";
int multi_line_count = 0;

FILE *logout;
FILE *tokenout;

SymbolTable st(10);

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
	st.print_all_scopeLex(logout);
	line_count--;
	fprintf(logout, "Total lines: %d\n", line_count);
	fprintf(logout, "Total errors: %d\n", error_count);
}

%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n
ESCAPES ['"nt\\afrbv0]
%%

{NEWLINE} {line_count++;}

"if"		{
				fprintf(tokenout,"<IF, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <IF> Lexeme %s found\n",line_count,yytext);
			}
		
"else"		{
				fprintf(tokenout,"<ELSE, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <ELSE> Lexeme %s found\n",line_count,yytext);
			}

"for"		{
				fprintf(tokenout,"<FOR, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <FOR> Lexeme %s found\n",line_count,yytext);
			}

"while"		{
				fprintf(tokenout,"<WHILE, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <WHILE> Lexeme %s found\n",line_count,yytext);
			}

"do"		{
				fprintf(tokenout,"<DO, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <DO> Lexeme %s found\n",line_count,yytext);
			}

"break"		{
				fprintf(tokenout,"<BREAK, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <BREAK> Lexeme %s found\n",line_count,yytext);
			}

"int"		{
				fprintf(tokenout,"<INT, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <INT> Lexeme %s found\n",line_count,yytext);
			}

"char"		{
				fprintf(tokenout,"<CHAR, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <CHAR> Lexeme %s found\n",line_count,yytext);
			}

"float"		{
				fprintf(tokenout,"<FLOAT, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <FLOAT> Lexeme %s found\n",line_count,yytext);
			}

"double"	{
				fprintf(tokenout,"<DOUBLE, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <DOUBLE> Lexeme %s found\n",line_count,yytext);
			}	 	

"void"		{
				fprintf(tokenout,"<VOID, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <VOID> Lexeme %s found\n",line_count,yytext);
			}

"return"	{
				fprintf(tokenout,"<RETURN, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <RETURN> Lexeme %s found\n",line_count,yytext);
			}

"switch"	{
				fprintf(tokenout,"<SWITCH, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <SWITCH> Lexeme %s found\n",line_count,yytext);
			}

"case"		{
				fprintf(tokenout,"<CASE, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <CASE> Lexeme %s found\n",line_count,yytext);
			}

"default"	{
				fprintf(tokenout,"<DEFAULT, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <DEFAULT> Lexeme %s found\n",line_count,yytext);
			}

"continue"	{
				fprintf(tokenout,"<CONTINUE, %s>n", yytext);
				fprintf(logout,"Line# %d: Token <CONTINUE> Lexeme %s found\n",line_count,yytext);
			}

		
{DIGIT}+ 	{
				fprintf(tokenout,"<CONST_INT, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <CONST_INT> Lexeme %s found\n",line_count,yytext);
			}

({DIGIT}*\.{DIGIT}+(E[+-]?{DIGIT}+)?)|({DIGIT}+E{DIGIT}+) {
				fprintf(tokenout,"<CONST_FLOAT, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
				// ({DIGIT}*(\.{DIGIT}+(E(+-)?{DIGIT}+)?))|({DIGIT}+E{DIGIT}+) 
			}

{DIGIT}*\.{DIGIT}+\.({DIGIT}|\.)* {
				error_count++;
				fprintf(logout, "Error at line# %d: TOO_MANY_DECIMAL_POINTS %s\n", line_count, yytext);
			}

({DIGIT}*\.{DIGIT}+E[+-]?{DIGIT}+\.({DIGIT}|\.)*)|({DIGIT}+E{DIGIT}+\.({DIGIT}|\.)*)  {
				error_count++;
				fprintf(logout, "Error at line# %d: ILLFORMED_NUMBER %s\n", line_count, yytext);
			}

\'[^\\]\' 		|
'(\\[nt\\afrbv0\"])'	{		
				char c = lexemToChar(yytext);
				fprintf(tokenout,"<CONST_CHAR, %c>\n", c);
				fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %c found\n",line_count, c);
			}


'' 			{
				error_count++;
				fprintf(logout, "Error at line# %d: EMPTY_CONST_CHAR %s\n", line_count, yytext);
			}

'.(.|(\\[nt\\afrbv0\"]))+' 	{	
				error_count++;
				fprintf(logout, "Error at line# %d: MULTICHAR_CONST_CHAR %s\n", line_count, yytext);
			}		

"'\\'"	|
'([^'\\\n]|(\\{ESCAPES}))*\n		{
				error_count++;
				fprintf(logout, "Error at line# %d: UNFINISHED_CONST_CHAR %s\n", line_count, yytext);
				line_count++;
			}

"+"		|
"-"			{
				fprintf(tokenout,"<ADDOP, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <ADDOP> Lexeme %s found\n",line_count,yytext);
			}

"*"		|
"/"		|
"%" 		{
				fprintf(tokenout,"<MULOP, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <MULOP> Lexeme %s found\n",line_count,yytext);
			}

"++"	|
"--"		{
				fprintf(tokenout,"<INOP, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <INOP> Lexeme %s found\n",line_count,yytext);
			}	

"<"		|
"<="	|
">"		|
">="	|
"=="	|
"!="		{
				fprintf(tokenout,"<RELOP, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <RELOP> Lexeme %s found\n",line_count,yytext);
			}

"="			{
				fprintf(tokenout,"<ASSIGNOP, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
			}

"&&"	|
"||"		{
				fprintf(tokenout,"<LOGICOP, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <LOGICOP> Lexeme %s found\n",line_count,yytext);
			}

"&"		|
"|"		|
"^"		|
"<<"	|
">>"		{
				fprintf(tokenout,"<BITOP, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <BITOP> Lexeme %s found\n",line_count,yytext);
			}

"!"			{
				fprintf(tokenout,"<NOT, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <NOT> Lexeme %s found\n",line_count,yytext);
			}

"("			{
				fprintf(tokenout,"<LPAREN, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <LPAREN> Lexeme %s found\n",line_count,yytext);
			}

")"			{
				fprintf(tokenout,"<RPAREN, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <RPAREN> Lexeme %s found\n",line_count,yytext);
			}

"{"			{
				fprintf(tokenout,"<LCURL, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <LCURL> Lexeme %s found\n",line_count,yytext);
				st.enter_scope(2);
			}

"}"			{
				fprintf(tokenout,"<RCURL, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <RCURL> Lexeme %s found\n",line_count,yytext);
				st.exit_scope();
			}

"["			{
				fprintf(tokenout,"<LSQUARE, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <LSQUARE> Lexeme %s found\n",line_count,yytext);
			}

"]"			{
				fprintf(tokenout,"<RSQUARE, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <RSQUARE> Lexeme %s found\n",line_count,yytext);
			}
","			{
				fprintf(tokenout,"<COMMA, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <COMMA> Lexeme %s found\n",line_count,yytext);
			}

";"			{
				fprintf(tokenout,"<SEMICOLON, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <SEMICOLON> Lexeme %s found\n",line_count,yytext);
			}

"_"		|
_?{LETTER}+({LETTER}|{DIGIT}|_)*  {
				fprintf(tokenout,"<ID, %s>\n", yytext);
				fprintf(logout,"Line# %d: Token <ID> Lexeme %s found\n",line_count,yytext);
				SymbolInfo *s = new SymbolInfo(yytext, "ID");
				bool inserted = st.insert(s);
				if(inserted)
					st.print_all_scopeLex(logout);
				else 
					fprintf(logout, "\t%s already exisits in the current ScopeTable\n", yytext);
			}

{DIGIT}+_?{LETTER}+({LETTER}|{DIGIT}|_)* {
				error_count++;
				fprintf(logout, "Error at line# %d: INVALID_ID_SUFFIX_NUM_PREFIX %s\n", line_count, yytext);
	
			}
\"(([^"\\\n]|(\\{ESCAPES}))|("\\\n"))*\" {
				// fprintf(tokenout,"<STRING, %s>\n", yytext);
				// fprintf(logout,"Line# %d: Token <STRING> Lexeme %s found\n",line_count,yytext);
				printString(yytext);
			}
			

\"(([^"\\\n]|(\\{ESCAPES}))|("\\\n"))*\n {
				error_count++;
				string text = yytext;
				fprintf(logout, "Error at line# %d: UNFINISHED STRING %s\n", line_count, text.substr(0, text.length() - 1).c_str());
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
				fprintf(logout, "Error at line# %d: UNRECOGNIZED_CHAR %s\n", line_count, yytext);
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
				fprintf(logout, "Error at line# %d: UNFINISHED COMMENT %s\n", line_count, multi_line_comment.c_str());
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

int main(int argc, char** argv) {
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("1905120_log.txt","w");
	tokenout= fopen("1905120_token.txt","w");

	yyin= fin;
	yylex();
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}
