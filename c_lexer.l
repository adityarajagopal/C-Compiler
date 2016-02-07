%option noyywrap
%{

#include <iostream> 
#include <string>
#include <sstream>  
enum
{
	DT_KWD=256,Q_KWD,UD_KWD,SC_KWD,LOOP_KWD,DESC_KWD,JUMP_KWD,DER_KWD,FUNC_KWD,OTHER_KWD,
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
DECIMAL				[0-9]+[uUlL]?[uUlL]?	
FLOAT				[0-9]*\.?[0-9]+([eE][-\+][0-9]+[lLfF]?)?
CHAR				\'.*\'
STRING				\".*\"
/*keywords*/
DATA_TYPES_KWD		int|char|float|double
QUALIFIERS_KWD		signed|unsigned|short|long
USER_DEF_KWD		typedef|enum 
STORAGE_CLASS_KWD	auto|extern|register|static
LOOP_KWD			for|while|do
DESCISION_KWD		if|else|switch|case|default
JUMP_KWD			goto|continue|break
DERIVED_KWD			struct|union
FUNCTION_KWD		void|return 
OTHER_KWD			const|volatile|sizeof
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

{DATA_TYPES_KWD}					return DT_KWD; 
{QUALIFIERS_KWD}					return Q_KWD; 
{USER_DEF_KWD}						return UD_KWD; 
{STORAGE_CLASS_KWD}					return SC_KWD; 
{LOOP_KWD}							return LOOP_KWD; 
{DESCISION_KWD}						return DESC_KWD; 
{JUMP_KWD}							return JUMP_KWD; 
{DERIVED_KWD}						return DER_KWD; 
{FUNCTION_KWD}						return FUNC_KWD; 
{OTHER_KWD}							return OTHER_KWD; 

{IDENTIFIER}						return ID; 

{ARITHMETIC_OP}						return ARITH_OP; 
{RELATION_OP}						return REL_OP;
{LOGICAL_OP}						return REL_OP;
{BITWISE_OP}						return BW_OP;
{ASSIGNMENT_OP}						return ASSI_OP;
{CONDITIONAL_OP}					return COND_OP;
{PUNCTUATOR_OP}						return PUNC_OP;

{NEW_LINE}							{line_num++;}
{PRE_SHARP}						 	return PRE_PROC;
{TAB}								return CONSUME; 
{SPACE}								return CONSUME;
{INVALID_SHARP}						return CONSUME;

%%
void update_file_name(char* yytext); 
void class_constant(char* yytext,int token_type,int line_num,std::string& file_name,int src_line,std::string& output);
void class_keyword(char* yytext,int token_type,int line_num,std::string& file_name,int src_line,std::string& output);
void class_operator(char* yytext,int token_type,int line_num, std::string& file_name,int src_line,std::string& output);
void class_identifier(char* yytext,int line_num, std::string& file_name,int src_line,std::string& output);
void class_invalid(char* yytext,int line_num, std::string& file_name,int src_line,std::string& output);
void class_string_literal(char* yytext,int line_num, std::string& file_name,int src_line,std::string& output);

int main()
{
	int lexcode = yylex();
	std::string output; 
	while(lexcode != 0)
	{
		switch (lexcode)
		{
			case OCT_CONST...CHAR_CONST:
				class_constant(yytext,lexcode,line_num,file_name,src_line,output);
				std::cout << output << std::endl;
				break;
			case DT_KWD...OTHER_KWD:
				class_keyword(yytext,lexcode,line_num,file_name,src_line,output);
				std::cout << output << std::endl;
				break;
			case ARITH_OP...PUNC_OP:
				class_operator(yytext,lexcode,line_num,file_name,src_line,output);
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

	src_line = std::stoi(input_line.substr(sharp+2,(start-sharp-1)));
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

void class_keyword(char* yytext, int token_type, int line_num, std::string& file_name, int src_line, std::string& output)
{
	std::string tokenType;
	switch (token_type)
	{
		case DT_KWD:
			tokenType = "DATA_TYPE"; 
			break;
		case Q_KWD:
			tokenType = "QUALIFIER";
			break;
		case UD_KWD:
			tokenType = "USER_DEFINED";
			break;
		case SC_KWD:
			tokenType = "STORAGE_CLASS";
			break;
		case LOOP_KWD:
			tokenType = "LOOP";
			break; 
		case DESC_KWD:
			tokenType = "DESCISION";
			break;
		case JUMP_KWD:
			tokenType = "JUMP";
			break;
		case DER_KWD:
			tokenType = "DERIVED";
			break;
		case FUNC_KWD:	
			tokenType = "FUNCTION";
			break; 
		case OTHER_KWD:
			tokenType = "MISC";
			break;
	}
	std::stringstream ss; 	
	ss << yytext << " " << "Keyword" << " " << tokenType << " " << line_num << " " << file_name << " " << src_line;
	output = ss.str(); 
}

void class_operator(char* yytext, int token_type, int line_num, std::string& file_name, int src_line, std::string& output)
{
	std::string tokenType;
	switch (token_type)
	{
		case ARITH_OP:
			tokenType = "ARITHMETIC"; 
			break;
		case REL_OP:
			tokenType = "RELATION";
			break;
		case LOG_OP:
			tokenType = "LOGICAL";
			break;
		case BW_OP:
			tokenType = "BITWISE";
			break;
		case ASSI_OP:
			tokenType = "ASSIGNMENT";
			break; 
		case COND_OP:
			tokenType = "CONDITIONAL";
			break;
		case PUNC_OP:
			tokenType = "PUNCTUATOR";
			break;
	}
	std::stringstream ss;
	ss << yytext << " " << "Operator" << " " << tokenType << " " << line_num << " " << file_name << " " << src_line;
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
