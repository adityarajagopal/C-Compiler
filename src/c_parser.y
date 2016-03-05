%define parse.error verbose
%{
#include "src/c_parser.h"

int yylex();
int yyerror(const char* s);

ExternalDecl* root = NULL;

ExternalDecl::ExternalDecl(Decl* _decl) : decl(_decl) {}
void ExternalDecl::print()
{
	std::cout << "ED" << std::endl;
	if(decl != NULL)
	{
		decl->print();
	}
}

Decl::Decl(DeclSpec* _decl_spec) : decl_spec(_decl_spec) {}
void Decl::print()
{
	std::cout << "D" << std::endl; 
	if(decl_spec != NULL)
	{
		decl_spec->print();
	}
}

DeclSpec::DeclSpec(TypeSpec* _type_spec, DeclSpec* _decl_spec) : type_spec(_type_spec), decl_spec(_decl_spec) {}
void DeclSpec::print()
{
	std::cout << "DS" << std::endl; 
	if(type_spec != NULL)
	{
		type_spec->print();
	}
	if(decl_spec != NULL)
	{
		decl_spec->print();
	}
}

TypeSpec::TypeSpec(std::string i_type) : type(i_type) {}
void TypeSpec::print()
{
	std::cout << type << std::endl;
}
%}

%union 
{
	char* string;
	int i_num; 
	float f_num;
	class Node* tree_node;
	class ExternalDecl* Ext_Decl;
	class Decl* Decl;
	class DeclSpec* Decl_Spec;
	class TypeSpec* Type_Spec;
}

%token SEMICOLON COMMA LCURLY RCURLY LBRAC RBRAC
%token INT FLOAT DOUBLE BOOL
%token LONG UNSIGNED SIGNED CONST SHORT
%token VOID STRUCT UNION CHAR TYPEDEF VOLATILE STRING
%token IDENTIFIER INT_VAL FLOAT_VAL STRING_LIT
%token IF ELSE FOR WHILE
%token GOTO_KWD CONTINUE_KWD BREAK RETURN 
%token EQUALS MUL_EQUALS DIV_EQUALS MOD_EQUALS ADD_EQUALS SUB_EQUALS LEFT_EQUALS RIGHT_EQUALS AND_EQUALS OR_EQUALS XOR_EQUALS ADD SUB MULT DIV MOD
%token QUESTION_MARK COLON OR AND BW_OR BW_XOR BW_AND EQUAL_EQUAL NOT_EQUAL LT GT LE GE LEFT_SHIFT RIGHT_SHIFT INC DEC BW_NOT NOT
%token ENUM CHAR_KWD FLOAT_KWD DOUBLE_KWD AUTO EXTERN REGISTER STATIC DO SWITCH CASE SIZEOF DEFAULT TYPE
%type<tree_node> file init_list init_declarator declarator initial_val assign_expr expr unary_expr postfix_expr primary_expr function_def compound_statement statement_list expr_statement param_list param_decl decl_list selection_statement statement loop_statement conditional_expr logical_or_expr logical_and_expr incl_or_expr excl_or_expr and_expr bool_equal_expr comparison_expr shift_expr addsub_expr multdivmod_expr jump_statement
%type<string> IDENTIFIER EQUALS MUL_EQUALS DIV_EQUALS MOD_EQUALS ADD_EQUALS SUB_EQUALS LEFT_EQUALS RIGHT_EQUALS AND_EQUALS OR_EQUALS XOR_EQUALS QUESTION_MARK COLON assign_oper OR AND BW_OR BW_XOR BW_AND EQUAL_EQUAL NOT_EQUAL LT GT LE GE LEFT_SHIFT RIGHT_SHIFT ADD SUB MULT DIV MOD unary_oper INC DEC BW_NOT NOT TYPE
%type<i_num> INT_VAL
%type<f_num> FLOAT_VAL

%type<Ext_Decl> external_decl
%type<Decl> decl 
%type<Decl_Spec> decl_specifiers
%type<Type_Spec> type_specifier

%% 

file			: external_decl 
	 			| file external_decl 
				;

external_decl	: function_def
				| decl {$$ = new ExternalDecl; $$->decl = $1; root = $$;}
				;

function_def	: decl_specifiers declarator compound_statement 
				;

decl			: decl_specifiers SEMICOLON {$$ = new Decl; $$->decl_spec = $1;}
				| decl_specifiers init_list SEMICOLON 
				;

decl_specifiers	: type_specifier {$$ = new DeclSpec; $$->type_spec = $1;}
				| type_specifier decl_specifiers 
				;

decl_list		: decl
				| decl decl_list
				;

type_specifier	: TYPE {$$ = new TypeSpec($1);}
				;

init_list		: init_declarator  
				| init_declarator COMMA init_list 
				;

init_declarator	: declarator  
				| declarator EQUALS initial_val 
				;

statement_list	: statement
				| statement statement_list 
				;

statement		: compound_statement 
				| expr_statement
				| selection_statement
				| loop_statement
				| jump_statement
				;

declarator		: IDENTIFIER 
				| declarator LBRAC param_list RBRAC 
				| declarator LBRAC RBRAC 
				;

param_list		: param_decl
				| param_decl COMMA param_list 
				;

param_decl		: decl_specifiers declarator 
				;

compound_statement	: LCURLY RCURLY 
					| LCURLY statement_list RCURLY 
					| LCURLY decl_list RCURLY 
					| LCURLY decl_list statement_list RCURLY 
					;

initial_val		: assign_expr
				;

selection_statement : IF LBRAC expr RBRAC statement 
					| IF LBRAC expr RBRAC statement ELSE statement 
					;

loop_statement	: WHILE LBRAC expr RBRAC statement
				| FOR LBRAC expr_statement expr_statement RBRAC statement 
				| FOR LBRAC expr_statement expr_statement expr RBRAC statement 
				;

expr_statement 	: SEMICOLON {}
				| expr SEMICOLON {}
				;

jump_statement	: GOTO_KWD IDENTIFIER SEMICOLON 
				| RETURN SEMICOLON 
				| RETURN expr SEMICOLON 
				;

expr			: assign_expr 
				| expr COMMA assign_expr {}
				;

assign_expr		: conditional_expr
				| unary_expr assign_oper assign_expr 
				;

assign_oper		: EQUALS {}
				| MUL_EQUALS {}
				| DIV_EQUALS {}
				| MOD_EQUALS {}
				| ADD_EQUALS {}
				| SUB_EQUALS {}
				| LEFT_EQUALS {}
				| RIGHT_EQUALS {}
				| AND_EQUALS {}
				| XOR_EQUALS {}
				| OR_EQUALS {}
				;

conditional_expr : logical_or_expr
			     | logical_or_expr QUESTION_MARK expr COLON conditional_expr
				 ;

logical_or_expr : logical_and_expr
				| logical_or_expr OR logical_and_expr
				;

logical_and_expr : incl_or_expr
				 | logical_and_expr AND incl_or_expr
				 ;

incl_or_expr 	: excl_or_expr
				| incl_or_expr BW_OR excl_or_expr
				;

excl_or_expr	: and_expr
				| excl_or_expr BW_XOR and_expr
				;

and_expr		: bool_equal_expr
				| and_expr BW_AND bool_equal_expr
				;

bool_equal_expr : comparison_expr
				| bool_equal_expr EQUAL_EQUAL comparison_expr
				| bool_equal_expr NOT_EQUAL comparison_expr
				;

comparison_expr : shift_expr
				| comparison_expr LT shift_expr
				| comparison_expr GT shift_expr
				| comparison_expr LE shift_expr
				| comparison_expr GE shift_expr
				;

shift_expr 		: addsub_expr
				| shift_expr LEFT_SHIFT addsub_expr
				| shift_expr RIGHT_SHIFT addsub_expr
				;

addsub_expr		: multdivmod_expr
				| addsub_expr ADD multdivmod_expr
				| addsub_expr SUB multdivmod_expr
				;

multdivmod_expr : unary_expr
				| multdivmod_expr MULT unary_expr
				| multdivmod_expr DIV unary_expr
				| multdivmod_expr MOD unary_expr
				;

unary_expr		: postfix_expr
				| INC unary_expr 
				| DEC unary_expr 
				| unary_oper unary_expr 
				;

unary_oper		: BW_AND
				| MULT
				| ADD 
				| SUB
				| BW_NOT
				| NOT
				;

postfix_expr	: primary_expr
				| postfix_expr INC
				| postfix_expr DEC
				;

primary_expr	: IDENTIFIER 
				| INT_VAL 
				| FLOAT_VAL 
				| CHAR 
				| STRING 
				| LBRAC expr RBRAC {}
				;
%%

int yyerror(const char* s)
{
	std::cout << s << std::endl;
	return -1;
}

int main() 
{
	yyparse();
	root->print();
}
