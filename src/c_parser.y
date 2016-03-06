%define parse.error verbose
%{
#include "src/c_parser.h"

int yylex();
int yyerror(const char* s);

ExternalDecl* root = NULL;

ExternalDecl::ExternalDecl(Decl* _decl) : decl(_decl) {}
void ExternalDecl::print()
{
	if(decl != NULL)
	{
		decl->print();
	}
}

Decl::Decl(DeclSpec* _decl_spec, InitList* _init_list) : decl_spec(_decl_spec), init_list(_init_list) {}
void Decl::print()
{
	if(decl_spec != NULL)
	{
		decl_spec->print();
	}
	if(init_list != NULL)
	{
		init_list->print(); 
	}
	std::cout << ";" << std::endl;
}

DeclSpec::DeclSpec(TypeSpec* _type_spec, DeclSpec* _decl_spec) : type_spec(_type_spec), decl_spec(_decl_spec) {}
void DeclSpec::print()
{
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
	std::cout << type << " ";
}

InitList::InitList(InitDeclr* _init_declr, InitList* _init_list) : init_declr(_init_declr), init_list(_init_list) {}
void InitList::print()
{
	if(init_declr != NULL)
	{
		init_declr->print();
	}
	if(init_list != NULL)
	{
		std::cout << ", ";
		init_list->print();
	}
}

InitDeclr::InitDeclr(Declr* _declr, InitVal* _init_val) : declr(_declr), init_val(_init_val) {}
void InitDeclr::print()
{
	if(declr != NULL) 
	{
		declr->print();
	}
	if(init_val != NULL)
	{
		std::cout << "= ";
		init_val->print(); 
	}
}

Declr::Declr(std::string _id, Declr* _declr, ParamList* _param_list) : id(_id), declr(_declr), param_list(_param_list) {}
void Declr::print()
{
	if(id != "")
	{
		std::cout << id << " "; 
	}
}

InitVal::InitVal(AssExpr* _ass_expr) : ass_expr(_ass_expr) {}
void InitVal::print()
{
	if(ass_expr != NULL)
	{
		ass_expr->print(); 
	}
}

AssExpr::AssExpr(CondExpr* _cond_expr, UnaryExpr* _unary_expr, std::string _ass_oper, AssExpr* _ass_expr) : cond_expr(_cond_expr), unary_expr(_unary_expr), ass_oper(_ass_oper), ass_expr(_ass_expr) {}
void AssExpr::print()
{
	if(cond_expr != NULL)
	{
		cond_expr->print(); 
	}
}

CondExpr::CondExpr(PrimExpr* _prim_expr) : prim_expr(_prim_expr) {}
void CondExpr::print()
{
	if(prim_expr != NULL)
	{
		prim_expr->print(); 
	}
}

PrimExpr::PrimExpr(std::string _value) : value(_value) {}
void PrimExpr::print()
{
	if(value != "")
	{
		std::cout << value << " ";
	}
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
	class InitList* Init_List;
	class InitDeclr* Init_Declr;
	class Declr* Declr;
	class InitVal* Init_Val;
	class Iden* Iden;
	class AssExpr* Ass_Expr;
	class PrimExpr* Prim_Expr;
	class CondExpr* Cond_Expr;
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
%type<tree_node> file expr function_def compound_statement statement_list expr_statement param_list param_decl decl_list selection_statement statement loop_statement jump_statement
%type<string> IDENTIFIER EQUALS MUL_EQUALS DIV_EQUALS MOD_EQUALS ADD_EQUALS SUB_EQUALS LEFT_EQUALS RIGHT_EQUALS AND_EQUALS OR_EQUALS XOR_EQUALS QUESTION_MARK COLON assign_oper OR AND BW_OR BW_XOR BW_AND EQUAL_EQUAL NOT_EQUAL LT GT LE GE LEFT_SHIFT RIGHT_SHIFT ADD SUB MULT DIV MOD unary_oper INC DEC BW_NOT NOT TYPE CHAR STRING INT_VAL FLOAT_VAL

%type<Ext_Decl> external_decl
%type<Decl> decl 
%type<Decl_Spec> decl_specifiers
%type<Type_Spec> type_specifier
%type<Init_List> init_list
%type<Init_Declr> init_declarator
%type<Declr> declarator
%type<Init_Val> initial_val
%type<Ass_Expr> assign_expr
%type<Cond_Expr> conditional_expr
%type<Prim_Expr> primary_expr logical_or_expr logical_and_expr incl_or_expr excl_or_expr and_expr bool_equal_expr comparison_expr shift_expr addsub_expr multdivmod_expr unary_expr postfix_expr
%% 

file			: external_decl 
	 			| file external_decl 
				;

external_decl	: function_def
				| decl {$$ = new ExternalDecl($1); root = $$;}
				;

function_def	: decl_specifiers declarator compound_statement 
				;

decl			: decl_specifiers SEMICOLON {$$ = new Decl($1);}
				| decl_specifiers init_list SEMICOLON {$$ = new Decl($1, $2);}
				;	

decl_specifiers	: type_specifier {$$ = new DeclSpec($1);}
				| type_specifier decl_specifiers {$$ = new DeclSpec($1, $2);} 
				;

decl_list		: decl
				| decl decl_list
				;

type_specifier	: TYPE {$$ = new TypeSpec($1);}
				;

init_list		: init_declarator {$$ = new InitList($1); } 
				| init_declarator COMMA init_list {$$ = new InitList($1, $3);} 
				;

init_declarator	: declarator {$$ = new InitDeclr($1);} 
				| declarator EQUALS initial_val {$$ = new InitDeclr($1, $3);}
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

declarator		: IDENTIFIER {$$ = new Declr($1);} 
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

initial_val		: assign_expr {$$ = new InitVal($1);}
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

assign_expr		: conditional_expr {$$ = new AssExpr($1);}
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

conditional_expr : logical_or_expr {$$ = new CondExpr($1);}
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

primary_expr	: IDENTIFIER {$$ = new PrimExpr($1);} 
				| INT_VAL {$$ = new PrimExpr($1);} 
				| FLOAT_VAL {$$ = new PrimExpr($1);}  
				| CHAR {$$ = new PrimExpr($1);}  
				| STRING {$$ = new PrimExpr($1);}  
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
