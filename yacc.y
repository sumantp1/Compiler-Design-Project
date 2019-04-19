%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "stack.h"

int yylex();
int yyerror();
void add_quad(char op[5], char arg1[10], char arg2[10], char result[10]);

extern FILE* yyin;
extern STACK indent;

#define LOCAL 0
#define GLOBAL 1
extern int scope;


struct symbol_table
{
    char name[80];
    int token;
    char value;
    int lineno;
    char scope[80];
} st[100];

struct Quad
{
    char op[5];
    char arg1[10];
    char arg2[10];
    char result[10];
};
struct Quad QUAD[500];

int table_row = 0;
extern int linenum;

int quad_row=0;
int tIndex = 0;
char temp='A';
int l_no=0;

%}

%union
{
    char* strval;
};


%start statements
%token ID NUM NOT AND OR ROP LPAREN RPAREN LBRACE RBRACE RBRACK LBRACK SEMI COMMA ASOP MDOP COLON
%token EQUALS CONTINUE BREAK RETURN IF ELIF ELSE WHILE LEADSPACE LEADTAB SOP 
%token TEXT INDENT DEDENT END_STATEMENT

%%

statements
	: statements statement
	| statement
	| END_STATEMENT
	;
	
statement
	: ifstatement INDENT
	| whilestatement INDENT
	| AssignExpr INDENT
	| ifstatement END_STATEMENT
	| whilestatement END_STATEMENT
	| AssignExpr END_STATEMENT
	| ifstatement
	| whilestatement
	| AssignExpr
	;

condition
    : relexp
    | condition logop relexp
    | NOT relexp
    ;
    
ifstatement:
	IF condition COLON codeblock
	;
	
codeblock
    : INDENT statements DEDENT
    ;
    
whilestatement
	: WHILE condition COLON codeblock
	;
	
relexp 
    : E ROP E
    ;

logop 
    : AND | OR
    ;

AssignExpr 
    : ID EQUALS E
    | Unary_operation
    ;
    
E
	: E ASOP T 
	| T	
	;
	
T 
    : T MDOP F  
    | F {printf("%s", $<strval>1);}
    ;
	
F 
    : ID  
    | NUM    
    | LPAREN E RPAREN   
	;
	
Unary_operation 
    : ID SOP ID 
    | ID SOP NUM 
    | ID SOP LPAREN E RPAREN
    ;


%%


void add_quad(char op[5],char arg1[10],char arg2[10],char result[10]) {
	/*memcpy(Quadtable[quad_row].op, op, sizeof(op));
    Quadtable[quad_row].arg1=arg1;
    Quadtable[quad_row].arg2=arg2;
    quad_row++;
    temp++;
    Quadtable[quad_row].result=temp;
    return temp; 
    */
   	strcpy(QUAD[quad_row].op,op);
	strcpy(QUAD[quad_row].arg1,arg1);
	strcpy(QUAD[quad_row].arg2,arg2);
	sprintf(QUAD[quad_row].result,"t%d",tIndex++);
	strcpy(result,QUAD[quad_row++].result);   
}

void print_quad() {
	printf("quad_rows: %d\n", quad_row);
    for(int i=0;i<quad_row;i++){
        printf("%s\t%s\t%s\t%s\n",QUAD[i].op,QUAD[i].arg1,QUAD[i].arg2,QUAD[i].result);
    }
}

int already(char*n, char*s) {
    for(int i = 0; i < table_row; ++i) {
        if (strcmp(st[i].name, n) == 0 && strcmp(st[i].scope, s) == 0) {
            return i;
        }
    } 
    return -1;
}

int insert(char *n, int t, char val, int line, char *scop) {
    int already_value = already(n, scop);
    if(already_value == -1) {
        strcpy(st[table_row].name, n);
        st[table_row].token = t;
        st[table_row].value = val;
        st[table_row].lineno = line;
        strcpy(st[table_row].scope, scop);
        ++table_row;
        return -1;
    }
    else {
        return already_value;
    }
}


int install_id(char *n) {
    int insert_val;
    
    if(scope == GLOBAL)
        insert_val = insert(n, ID, 0, linenum, "global");
    else
        insert_val = insert(n, ID, 0, linenum, "local");
        
    if(insert_val == -1) {
        return(table_row-1);
    }
    else {
        return insert_val;
    }
}


void print_table() {
	printf("\t------------SYMBOL TABLE-----------\n");	
	printf("\tName\tToken\tValue\tLine\tScope\n");
    for(int i = 0; i < table_row; ++i) {
        printf("\t%s\t%d\t%d\t%d\t%s\n", st[i].name, st[i].token, st[i].value, st[i].lineno, st[i].scope);
    }
}

int main() {
	printf("parsing...\n");
	initStack(&indent, 20);
	yyin = fopen("t.txt", "r");
	yyparse();
	printf("\n\n");
	print_table();
	printf("\n\n");
	print_quad();
	return 0;
}

int yyerror() {
	printf("Error at line no.: %d\n", linenum);
	return 0;
}




























