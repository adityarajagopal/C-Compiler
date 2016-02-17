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

struct node* tmp = NULL;
%}

%union 
{
	int i_num;
	float f_num;
	double d_num;
	char* string;
	struct node* tree_node;
}

%token SEMICOLON COMMA
%token INT FLOAT DOUBLE BOOL
%token LONG UNSIGNED SIGNED CONST SHORT
%token VOID STRUCT UNION CHAR TYPEDEF VOLATILE
%token IDENTIFIER

%type<tree_node> file external_decl decl decl_specifiers type_specifier su_specifier type_qualifier init_list init_declarator declarator 
%type<string> IDENTIFIER  

%% 

file			: external_decl
	 			| file external_decl

external_decl	: decl {print_nodes($$);}

decl			: decl_specifiers SEMICOLON
				| decl_specifiers init_list SEMICOLON 
				  {
				  	$$ = $2;
					tmp = $$;
					while(tmp != NULL)
					{
						tmp->type = $1->type;
						tmp = tmp->next;
					}
				  }

decl_specifiers	: type_specifier 
				| type_specifier decl_specifiers 
				| type_qualifier
				| type_qualifier decl_specifiers

type_specifier	: INT {$$ = make_node("int");}
				| LONG			{}
				| FLOAT			{}
				| DOUBLE {$$ = make_node ("double");}
				| VOID			{}
				| CHAR			{}
				| SHORT			{}
				| SIGNED		{}
				| UNSIGNED		{}
				| su_specifier
				| TYPEDEF		{}

su_specifier 	: STRUCT		{}
				| UNION			{}

type_qualifier	: CONST			{}
				| VOLATILE		{}

init_list		: init_declarator {push_node($$, $1);} 
				| init_list COMMA init_declarator {push_node($1, $3);}

init_declarator	: declarator 

declarator		: IDENTIFIER {$$ = make_node("None", $1);}

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
	if(root)
	{
		std::cout << "Type: " << root->type << std::endl;
		std::cout << "Name: " << root->name << std::endl;
		print_nodes(root->next);
	}
}

void push_node(node* hdr, node* to_add)
{
	node* tmp = hdr;
	while(tmp->next != NULL)
	{
		tmp = tmp->next;
	}
	tmp->next = to_add;
	to_add->next = NULL;
}

int main() 
{
	yyparse();
}
