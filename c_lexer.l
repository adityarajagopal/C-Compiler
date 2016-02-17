%option noyywrap
%{
#include "c_parser.tab.h"
%}

PRE_SHARP			#[ ][0-9]+[ ]\"[^"]*\"([ ][1234])?([ ][1234])?([ ][1234])?([ ][1234])?$
INVALID_SHARP		#.*$
/*constants*/
OCTAL				0[0-7]*([uU][l|ll|LL|L]?|[l|L|ll|LL][uU]?)?
HEXADECIMAL			0(x|X)[0-9a-fA-F]+*([uU][l|ll|LL|L]?|[l|L|ll|LL][uU]?)?
DECIMAL				[-\+]?[0-9]+([uU][l|ll|LL|L]?|[l|L|ll|LL][uU]?)?
FLOAT				[-\+]?([0-9]*\.?[0-9]+|[0-9]+\.?[0-9]*)([eE][-\+]?[0-9]+[lLfF]?)?
CHAR				\'[^']*\'
STRING				\"(\\.|[^\\"])*\"
/*keywords*/
USER_DEF_KWD		enum
INT_KWD				int
CHAR_KWD			char
FLOAT_KWD			float
DOUBLE_KWD			double
SIGNED_KWD			signed
UNSIGNED_KWD		unsigned
SHORT_KWD			short
LONG_KWD			long
TYPEDEF_KWD			typedef
STRUCT_KWD			struct
UNION_KWD			union
VOID_KWD			void	
CONST_KWD			const
VOLATILE_KWD		volatile
STORAGE_CLASS_KWD	auto|extern|register|static
LOOP_KWD			for|while|do
DESCISION_KWD		if|else|switch|case|default
JUMP_KWD			goto|continue|break
FUNCTION_KWD		return 
OTHER_KWD			sizeof
/*identifiers*/				
IDENTIFIER			[a-zA-Z_][a-zA-Z0-9_]*
/*operators*/
ARITHMETIC_OP		\+|-|\*|\/|%|\+\+|--
RELATION_OP			==|!=|>|<|>=|<=
LOGICAL_OP			&&|\|\||!
BITWISE_OP			&|\||\^|<<|>>|~
ASSIGNMENT_OP		=|\+=|-=|\*=|\/=|%=|\|=|&=|\^=|<<=|>>=
CONDITIONAL_OP		\?|\:
PUNCTUATOR_OP		\[|\]|\(|\)|\{|\}|\.\.\.|\.|\-\>
SEMICOLON			;
COMMA				\,
/*others*/
NEW_LINE			\n
TAB					(\t)*
SPACE 				[ ]*
%%
{SEMICOLON}			return SEMICOLON;
{INT_KWD}			return INT;
{DOUBLE_KWD}		return DOUBLE;
{IDENTIFIER}		{yylval.string = strdup(yytext); return IDENTIFIER;}
{COMMA}				return COMMA;
%%
