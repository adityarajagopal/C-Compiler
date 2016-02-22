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

	node* left;
	node* op;
	node* right;
	node* next;
};

void print_nodes(node* root);
void push_node(node* hdr, node* to_add);

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

%type<tree_node> file external_decl decl decl_specifiers type_specifier init_list init_declarator declarator initial_val assign_expr expr unary_expr assign_oper postfix_expr primary_expr 
%type<string> IDENTIFIER  
%type<i_num> INT_VAL


%% 

file			: external_decl
	 			| file external_decl
				;
external_decl	: decl {print_nodes($1);} 
				;
decl			: decl_specifiers SEMICOLON
				| decl_specifiers init_list SEMICOLON 
				  {
					$$=$2;
					$$->type=$1->type;
				  }
				;
decl_specifiers	: type_specifier 
				| type_specifier decl_specifiers 
				;	
type_specifier	: INT {$$ = make_node("int");}
				;
init_list		: init_declarator  
				| init_list COMMA init_declarator {$$->next=$3;}
				;
init_declarator	: declarator  
				| declarator EQUALS initial_val {$1->int_val=$3->int_val; $$ = $1;}
				;
declarator		: IDENTIFIER {$$ = make_node("None", $1);} 
				;
initial_val		: assign_expr
				;
expr			: assign_expr
				| expr COMMA assign_expr
				;
assign_expr		: unary_expr  //in the true grammar, this is a conditional_expr whcih can boil down to unary_expr
				| unary_expr assign_oper assign_expr
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

	new_node->left = NULL;
	new_node->op = NULL;
	new_node->right = NULL;
	new_node->next = NULL;

	return new_node;
}

void print_nodes(node* root)
{
	if(root!=NULL)
	{
		std::cout << "Type: " << root->type << std::endl;
		std::cout << "Name: " << root->name << std::endl;
		std::cout << "ival: " << root->int_val << std::endl;
		std::cout << "dval: " << root->d_val << std::endl;
		std::cout << "fval: " << root->f_val << std::endl;
		print_nodes(root->next);
	}
}

int main() 
{
	yyparse();
}
