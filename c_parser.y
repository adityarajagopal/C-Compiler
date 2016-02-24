%{
#include <iostream> 
#include <string>
#include <sstream>  

int yylex();
int yyerror(const char* s);

struct node
{
	int int_val;
	double d_val;
	float f_val;
	char char_val;
	std::string name;
	std::string type;
	std::string op;

	node* left;
	node* right;
	node* next;
	node* next_decl;
	node* next_statement;
};

void print_decl(node* root);
void print_node(node* root);
void print_func(node* root);
void print_arguments(node* root);
void print_scope(node* root);

node* make_node
(
	std::string i_type="none", 
	std::string i_name="none", 
	int ival=0, 
	double dval=0, 
	float fval=0,
	char cval=0
);

%}

%union 
{
	int i_num;
	float f_num;
	double d_num;
	char* string;
	struct node* tree_node;
}

%token SEMICOLON COMMA LCURLY RCURLY LBRAC RBRAC EQUALS
%token INT FLOAT DOUBLE BOOL
%token LONG UNSIGNED SIGNED CONST SHORT
%token VOID STRUCT UNION CHAR TYPEDEF VOLATILE
%token IDENTIFIER INT_VAL FLOAT_VAL STRING_LIT
%token IF ELSE

%type<tree_node> file external_decl decl decl_specifiers type_specifier init_list init_declarator declarator initial_val assign_expr expr unary_expr postfix_expr primary_expr function_def compound_statement statement_list expr_statement param_list param_decl decl_list selection_statement statement 
%type<string> IDENTIFIER assign_oper
%type<i_num> INT_VAL


%% 

file			: external_decl
	 			| file external_decl 
				;

external_decl	: function_def {print_func($1);} 
				| decl {print_decl($1);} 
				;

function_def	: decl_specifiers declarator compound_statement 
				  {
				  	$1->next = $2; 
				   	$2->next = $3;
				  }
				;

decl			: decl_specifiers SEMICOLON
				| decl_specifiers init_list SEMICOLON {$1->next = $2;}
				;

decl_specifiers	: type_specifier 
				| type_specifier decl_specifiers 
				;

decl_list		: decl
				| decl decl_list {$1->next_decl = $2;}
				;

type_specifier	: INT {$$ = make_node("type_specifier", "int");}
				;

init_list		: init_declarator  
				| init_declarator COMMA init_list {$1->next = $3;}
				;

init_declarator	: declarator  
				| declarator EQUALS initial_val 
				  {
					$$->op = "=";  
					$$->right = $3;
				  }
				;

statement_list	: statement
				| statement statement_list {$1->next_statement = $2;}
				;

statement		: compound_statement 
				| expr_statement
				| selection_statement
				;

declarator		: IDENTIFIER {$$ = make_node("declarator", $1);}
				| declarator LBRAC param_list RBRAC {$1->right = $3;} 
				| declarator LBRAC RBRAC 
				;

param_list		: param_decl
				| param_decl COMMA param_list {$1->next = $3;}
				;

param_decl		: decl_specifiers declarator {$1->right = $2;}
				;

compound_statement	: LCURLY RCURLY {$$ = make_node("scope_start");}
					| LCURLY statement_list RCURLY 
					  {
					  	$$ = make_node("scope_start");
						$$ -> next_statement = $2;
					  }
					| LCURLY decl_list RCURLY 
					  {
					  	$$ = make_node("scope_start");
						$$->next_decl = $2;
					  }
					| LCURLY decl_list statement_list RCURLY {}
					;

initial_val		: assign_expr
				;

selection_statement : IF LBRAC expr RBRAC statement 
					  {
					  	$$ = make_node("selection", "if");
						$$->right = $3; 
						$$->next = $5;
					  }
					| IF LBRAC expr RBRAC statement ELSE statement {}
					;

expr_statement 	: SEMICOLON {}
				| expr SEMICOLON {}
				;

expr			: assign_expr
				| expr COMMA assign_expr {}
				;

assign_expr		: unary_expr  //in the true grammar, this is a conditional_expr whcih can boil down to unary_expr
				| unary_expr assign_oper assign_expr 
				  {
					//$1->op = assign_oper;
					//$1->right = assign_expr;
				  }
				;

assign_oper		: EQUALS {}
				;

unary_expr		: postfix_expr
				;

postfix_expr	: primary_expr
				;

primary_expr	: IDENTIFIER {$$ = make_node("None", $1);}
				| INT_VAL {$$ = make_node("None", "None", $1);}
				| LBRAC expr RBRAC {}
				;
%%

int yyerror(const char* s)
{
	std::cout << s << std::endl;
	return -1;
}

node* make_node
(
	std::string i_type, 
	std::string i_name, 
	int ival, 
	double dval, 
	float fval,
	char cval
)
{
	node* new_node = new node;

	new_node->type = i_type;
	new_node->name = i_name;
	new_node->int_val = ival;
	new_node->d_val = dval;
	new_node->f_val = fval;
	new_node->char_val = cval;
	new_node->op = "none";

	new_node->left = NULL;
	new_node->right = NULL;
	new_node->next = NULL;

	return new_node;
}

void print_node(node* root)
{
	if(root != NULL)
	{
		std::cout << "name: " << root->name << std::endl;
		std::cout << "type: " << root->type << std::endl;
		std::cout << "int_val: " << root->int_val << std::endl;
	}
}

void print_decl(node* root)
{
	if(root != NULL)
	{
		if(root->type == "declarator")
		{
			std::cout << "VARIABLE : " << root->name << std::endl;
			/*
			if(root->op == "=")
			{
				print_node(root->right);
			}
			*/
		}
		print_decl(root->next);
	}
}

void print_func(node* root)
{
	if(root != NULL)
	{
		//print_node(root);
		if(root->type != "scope_start")
		{
			if(root->type == "declarator")
			{
				std::cout << "FUNCTION : " << root->name << std::endl;
				print_arguments(root->right);
				std::cout << "SCOPE" << std::endl;
				print_scope(root->next);
			}
			print_func(root->next);
		}
	}
}

void print_arguments(node* root)
{
	if(root != NULL)
	{
		std::cout << "\tPARAMETER : " << root->right->name << std::endl;
		print_arguments(root->next);
	}
}

void print_scope(node* root)
{
	if(root != NULL)
	{
		if(root->type == "type_specifier")
		{
			print_decl(root);
		}
		print_scope(root->next_decl);
	}
}

int main() 
{
	yyparse();
}
