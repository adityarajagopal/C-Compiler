%define parse.error verbose
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
	node* next_loop;
	node* compound_next;
	node* if_next;
	node* else_next;
	node* jump_next;
};

void print_decl(node* root, int tab);
void print_func(node* root, int tab);
void print_arguments(node* root, int tab);
void print_stat_list(node* root, int tab);
void print_loop(node* root, int tab);
void print_node(node* root);
void print_tab(int tab);

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

%token SEMICOLON COMMA LCURLY RCURLY LBRAC RBRAC
%token INT FLOAT DOUBLE BOOL
%token LONG UNSIGNED SIGNED CONST SHORT
%token VOID STRUCT UNION CHAR TYPEDEF VOLATILE
%token IDENTIFIER INT_VAL FLOAT_VAL STRING_LIT
%token IF ELSE FOR WHILE
%token GOTO CONTINUE BREAK RETURN 
%token EQUALS MUL_EQUALS DIV_EQUALS MOD_EQUALS ADD_EQUALS SUB_EQUALS LEFT_EQUALS RIGHT_EQUALS AND_EQUALS OR_EQUALS XOR_EQUALS ADD SUB MULT DIV MOD
%token QUESTION_MARK COLON OR AND BW_OR BW_XOR BW_AND EQUAL_EQUAL NOT_EQUAL LT GT LE GE LEFT_SHIFT RIGHT_SHIFT INC DEC BW_NOT NOT

%type<tree_node> file external_decl decl decl_specifiers type_specifier init_list init_declarator declarator initial_val assign_expr expr unary_expr postfix_expr primary_expr function_def compound_statement statement_list expr_statement param_list param_decl decl_list selection_statement statement loop_statement conditional_expr logical_or_expr logical_and_expr incl_or_expr excl_or_expr and_expr bool_equal_expr comparison_expr shift_expr addsub_expr multdivmod_expr jump_statement
%type<string> IDENTIFIER EQUALS MUL_EQUALS DIV_EQUALS MOD_EQUALS ADD_EQUALS SUB_EQUALS LEFT_EQUALS RIGHT_EQUALS AND_EQUALS OR_EQUALS XOR_EQUALS QUESTION_MARK COLON assign_oper OR AND BW_OR BW_XOR BW_AND EQUAL_EQUAL NOT_EQUAL LT GT LE GE LEFT_SHIFT RIGHT_SHIFT ADD SUB MULT DIV MOD unary_oper INC DEC BW_NOT NOT
%type<i_num> INT_VAL


%% 

file			: external_decl
	 			| file external_decl 
				;

external_decl	: function_def {print_func($1, 0);} 
				| decl {print_decl($1, 0);} 
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
				| loop_statement
				| jump_statement
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
					  	$$ = make_node("scope_start", "statement");
						$$ -> compound_next = $2;
					  }
					| LCURLY decl_list RCURLY 
					  {
					  	$$ = make_node("scope_start", "declaration");
						$$-> compound_next = $2;
					  }
					| LCURLY decl_list statement_list RCURLY 
					  {
						$$ = make_node("scope_start");
						$$-> compound_next = $2;
						$2-> compound_next = $3;
					  }
					;

initial_val		: assign_expr
				;

selection_statement : IF LBRAC expr RBRAC statement 
					  {
					  	$$ = make_node("selection", "if");
						if($5->type != "scope_start")
						{
							$$->if_next = make_node("scope_start");
							$$->if_next->compound_next = $5;
						}
						else
						{
							$$->if_next = $5;
						}
					  }
					| IF LBRAC expr RBRAC statement ELSE statement 
					  {
					  	$$ = make_node("selection", "if");
						if($5->type != "scope_start")
						{
							$$->if_next = make_node("scope_start");
							$$->if_next->compound_next = $5;
						}
						else
						{
							$$->if_next = $5;
						}
						if($7->type != "scope_start")
						{
							if($7->type == "selection")
							{$$->else_next = $7;}
							else
							{
								$$->else_next = make_node("scope_start");
								$$->else_next->compound_next = $7; 
							}
						}
						else
						{
							$$->else_next = $7;
						}
							
					  }
					;

loop_statement	: WHILE LBRAC expr RBRAC statement
				  {
				    $$ = make_node("loop", "while");
					if($5->type != "scope_start")
					{
						$$->next_loop = make_node("scope_start");
						$$->next_loop->compound_next = $5;
					}
					else
					{
						$$ -> next_loop = $5;
					}
				  }
				| FOR LBRAC expr_statement expr_statement RBRAC statement 
				  {
				  	$$ = make_node("loop", "for");
					if($6->type != "scope_start")
					{
						$$->next_loop = make_node("scope_start");
						$$->next_loop->compound_next = $6;
					}
					else
					{
						$$ -> next_loop = $6;
					}
				  }
				| FOR LBRAC expr_statement expr_statement expr RBRAC statement 
				  {
				  	$$ = make_node("loop", "for");
					if($7->type != "scope_start")
					{
						$$->next_loop = make_node("scope_start");
						$$->next_loop->compound_next = $7;
					}
					else
					{
						$$ -> next_loop = $7;
					}
				  }
				;

expr_statement 	: SEMICOLON {}
				| expr SEMICOLON {}
				;

jump_statement	: GOTO IDENTIFIER SEMICOLON 
				  {
				  	$$ = make_node("jump", "goto"); 
				   	$$->jump_next = make_node("primary_expr", $2);
				  }
				| CONTINUE SEMICOLON {$$ = make_node("jump", "continue");}
				| BREAK SEMICOLON {$$ = make_node("jump", "break");}
				| RETURN SEMICOLON 
				  {
				  	$$ = make_node("jump", "return");
				  }
				| RETURN expr SEMICOLON 
				  {
				  	$$ = make_node("jump", "return");
				  	$$->jump_next = $2;
				  }
				;

expr			: assign_expr 
				| expr COMMA assign_expr {}
				;

assign_expr		: conditional_expr
				| unary_expr assign_oper assign_expr 
				  {
				  	$$ = make_node("assignment_expression");
					$$->left = $1;
					$$->op = $2;
					$$->right = $3;
				  }
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
				| INC unary_expr {$$ = $2;}
				| DEC unary_expr {$$ = $2;}
				| unary_oper unary_expr {$$ = $2;}
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

primary_expr	: IDENTIFIER {$$ = make_node("primary_expression", $1);}
				| INT_VAL {$$ = make_node("primary_expression", "integer", $1);}
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

void print_tab(int tab)
{
	for(int i=0; i<tab; i++)
	{
		std::cout << "    ";
	}
}

void print_decl(node* root, int tab)
{
	if(root != NULL)
	{
		if(root->type == "declarator")
		{
			print_tab(tab);
			std::cout << "VARIABLE : " << root->name << std::endl;
		}
		print_decl(root->next, tab);
	}
}

void print_func(node* root, int tab)
{
	if(root != NULL)
	{
		if(root->type != "scope_start")
		{
			if(root->type == "declarator")
			{
				std::cout << "FUNCTION : " << root->name << std::endl;
				tab++;
				print_arguments(root->right, tab);
				tab--;
				print_stat_list(root->next, tab);
			}
			print_func(root->next, tab);
		}
	}
}

void print_arguments(node* root, int tab)
{
	if(root != NULL)
	{
		print_tab(tab);
		std::cout << "PARAMETER : " << root->right->name << std::endl;
		print_arguments(root->next, tab);
	}
}

void print_loop(node* root, int tab)
{
	if(root->next_loop != NULL)
	{
		print_stat_list(root->next_loop, tab);
	}

}
void print_stat_list(node* root, int tab)
{
	if (root != NULL)
	{
		if(root->type == "assignment_expression")
		{
			//print_tab(tab);
			//std::cout << "VARIABLE : " << root->left->name << std::endl;
			print_stat_list(root->next_statement, tab);
		}
		else if(root->type == "loop")
		{
			print_stat_list(root->next_loop, tab);
			print_stat_list(root->next_statement, tab);
		}
		else if(root->type == "selection")
		{
			print_stat_list(root->if_next, tab);
			print_stat_list(root->else_next, tab);
			print_stat_list(root->next_statement, tab);
		}
		else if(root->type == "jump")
		{
			print_stat_list(root->jump_next, tab);
			print_stat_list(root->next_statement, tab);
		}
		else if(root->type == "scope_start")
		{
			print_tab(tab);
			std::cout << "SCOPE" << std::endl;
			tab++;
			print_stat_list(root->compound_next, tab);
		}
		else if(root->type == "type_specifier")
		{
			print_decl(root, tab);
			print_stat_list(root->next_decl, tab);
			print_stat_list(root->compound_next, tab);
			print_stat_list(root->next_loop, tab);
		}
		else
		{
			print_stat_list(root->next_statement, tab);
		}
	}
}

int main() 
{
	yyparse();
}
