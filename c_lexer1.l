%option noyywrap
%{

#include <iostream> 
#include <string>
#include <sstream>  
enum
{
	KEYWORD=256,
	ID,
	ARITH_OP,REL_OP,LOG_OP,BW_OP,ASSI_OP,COND_OP,PUNC_OP,
	OCT_CONST,HEX_CONST,DEC_CONST,FLOAT_CONST,CHAR_CONST,
	STR_LIT,
	CONSUME,PRE_PROC	
};

int line_num = 1;
std::string file_name; 
int src_line; 

%}

PRE_SHARP			#[ ][0-9]+[ ]\".*\"([ ][1234])?([ ][1234])?([ ][1234])?([ ][1234])?$
INVALID_SHARP		#.*$
/*constants*/
OCTAL				0[0-7]*[uUlL]?[uUlL]?
HEXADECIMAL			0(x|X)[0-9a-fA-F]+[uUlL]?[uUlL]?
DECIMAL				[-\+]?[0-9]+[uUlL]?[uUlL]?	
FLOAT				[-\+]?([0-9]*\.?[0-9]+|[0-9]+\.?[0-9]*)([eE][-\+]?[0-9]+[lLfF]?)?
CHAR				\'.*\'
STRING				\".*\"
/*keywords*/
KEYWORD				int|char|float|double|signed|unsigned|short|long|typedef|enum|auto|extern|register|static|for|while|do|if|else|switch|case|default|goto|continue|break|struct|union|void|return|const|volatile|sizeof
/*identifiers*/
IDENTIFIER			[a-zA-Z\_][a-zA-Z0-9\_]*
/*operators*/
ARITHMETIC_OP		\+|-|\*|\/|%|\+\+|--
RELATION_OP			==|!=|>|<|>=|<=
LOGICAL_OP			&&|\|\||!
BITWISE_OP			&|\||\^|<<|>>
ASSIGNMENT_OP		=|\+=|-=|\*=|\/=|%=|\|=|&=|\^=
CONDITIONAL_OP		\?|\:
PUNCTUATOR_OP		\[|\]|\(|\)|\{|\}|;|\.\.\.|\"|\'|\,
/*others*/
NEW_LINE			\n
TAB					(\t)*
SPACE 				[ ]*
%%

{OCTAL}								return OCT_CONST;
{HEXADECIMAL}						return HEX_CONST;
{DECIMAL}							return DEC_CONST;
{FLOAT}								return FLOAT_CONST;
{CHAR}								return CHAR_CONST; 
{STRING}							return STR_LIT;

{KEYWORD}							return KEYWORD;

{IDENTIFIER}						return ID; 

{ARITHMETIC_OP}						return ARITH_OP; 
{RELATION_OP}						return REL_OP;
{LOGICAL_OP}						return REL_OP;
{BITWISE_OP}						return BW_OP;
{ASSIGNMENT_OP}						return ASSI_OP;
{CONDITIONAL_OP}					return COND_OP;
{PUNCTUATOR_OP}						return PUNC_OP;

{NEW_LINE}							{
										line_num++;
										src_line++;
									}
{PRE_SHARP}						 	return PRE_PROC;
{TAB}								return CONSUME; 
{SPACE}								return CONSUME;
{INVALID_SHARP}						return CONSUME;

%%
void update_file_name(char* yytext); 
void class_constant(char* yytext,int token_type,int line_num,std::string& file_name,int src_line,std::string& output);
void class_keyword(char* yytext,int line_num,std::string& file_name,int src_line,std::string& output);
void class_operator(char* yytext,int line_num, std::string& file_name,int src_line,std::string& output);
void class_identifier(char* yytext,int line_num, std::string& file_name,int src_line,std::string& output);
void class_invalid(char* yytext,int line_num, std::string& file_name,int src_line,std::string& output);
void class_string_literal(char* yytext,int line_num, std::string& file_name,int src_line,std::string& output);

int main()
{
	int lexcode = yylex();
	std::string output; 
	std::string consume; 
	while(lexcode != 0)
	{
		switch (lexcode)
		{
			case OCT_CONST...CHAR_CONST:
				class_constant(yytext,lexcode,line_num,file_name,src_line,output);
				std::cout << output << std::endl;
				break;
			case KEYWORD:
				class_keyword(yytext,line_num,file_name,src_line,output);
				std::cout << output << std::endl;
				break;
			case ARITH_OP...PUNC_OP:
				class_operator(yytext,line_num,file_name,src_line,output);
				std::cout << output << std::endl;
				break;
			case ID:
				class_identifier(yytext,line_num,file_name,src_line,output);
				std::cout << output << std::endl;
				break;
			case STR_LIT:
				class_string_literal(yytext,line_num,file_name,src_line,output);
				std::cout << output << std::endl;
				break;
			case PRE_PROC:
				update_file_name(yytext);
				break;
			case CONSUME:
				break;
			default:
				class_invalid(yytext,line_num,file_name,src_line,output);
				std::cout << output << std::endl;
				break;
		}
		lexcode = yylex();
	}
	return 0;
}

void update_file_name(char* yytext)
{
	std::string input_line(yytext);
	std::size_t sharp = input_line.find("#");
	std::size_t	start = input_line.find('"');
	std::size_t	end = input_line.find('"', start+1);

	src_line = std::stoi(input_line.substr(sharp+2,(start-sharp-1))) - 1;
	file_name = input_line.substr(start+1, (end-start-1));	
}

void class_constant(char* yytext, int token_type, int line_num, std::string& file_name, int src_line, std::string& output)
{
	std::string tokenType;
	switch (token_type)
	{
		case OCT_CONST:
			tokenType = "OCTAL"; 
			break;
		case HEX_CONST:
			tokenType = "HEXADECIMAL";
			break;
		case DEC_CONST:
			tokenType = "DECIMAL";
			break;
		case FLOAT_CONST:
			tokenType = "FLOAT";
			break;
		case CHAR_CONST:
			tokenType = "CHAR";
			break; 
	}
	std::stringstream ss;	
	ss << yytext << " " << "Constant" << " " << tokenType << " " << line_num << " " << file_name << " " << src_line;
	output = ss.str(); 
}

void class_keyword(char* yytext, int line_num, std::string& file_name, int src_line, std::string& output)
{
	std::stringstream ss; 	
	ss << yytext << " " << "Keyword" << " " << "T_" << yytext << " " << line_num << " " << file_name << " " << src_line;
	output = ss.str(); 
}

void class_operator(char* yytext, int line_num, std::string& file_name, int src_line, std::string& output)
{
	std::stringstream ss;
	ss << yytext << " " << "Operator" << " " << "T_" << yytext << " " << line_num << " " << file_name << " " << src_line;
	output = ss.str(); 
}

void class_identifier(char* yytext,int line_num, std::string& file_name,int src_line,std::string& output)
{	
	std::stringstream ss;
	ss << yytext << " " << "Identifier" << " " << "ID" << " " << line_num << " " << file_name << " " << src_line;
	output = ss.str(); 
}

void class_string_literal(char* yytext,int line_num, std::string& file_name,int src_line,std::string& output)
{
	std::stringstream ss;
	ss << yytext << " " << "String_Literal" << " " << "STRING" << " " << line_num << " " << file_name << " " << src_line;
	output = ss.str(); 
}

void class_invalid(char* yytext,int line_num, std::string& file_name,int src_line,std::string& output)
{
	std::stringstream ss;
	ss << yytext << " " << "Invalid" << " " << "UNKNOWN" << " " << line_num << " " << file_name << " " << src_line;
	output = ss.str(); 	
}
