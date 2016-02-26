%option noyywrap
%{
#include "c_parser.tab.h"
%}

PRE_SHARP			#[ ][0-9]+[ ]\"[^"]*\"([ ][1234])?([ ][1234])?([ ][1234])?([ ][1234])?$
INVALID_SHARP		#.*$
/*constants*/
OCTAL				0[0-7]*([uU][l|ll|LL|L]?|[l|L|ll|LL][uU]?)?
HEXADECIMAL			0(x|X)[0-9a-fA-F]+*([uU][l|ll|LL|L]?|[l|L|ll|LL][uU]?)?
DECIMAL				[0-9]+([uU][l|ll|LL|L]?|[l|L|ll|LL][uU]?)?
FLOAT				([0-9]*\.?[0-9]+|[0-9]+\.?[0-9]*)([eE][-\+]?[0-9]+[lLfF]?)?
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
IF_KWD				if
ELSE_KWD			else
WHILE_KWD			while
FOR_KWD				for
STORAGE_CLASS_KWD	auto|extern|register|static
LOOP_KWD			do
DESCISION_KWD		switch|case|default
GOTO 				goto
CONTINUE			continue
BREAK 				break 
RETURN 				return 
SIZEOF				sizeof
/*identifiers*/				
IDENTIFIER			[a-zA-Z_][a-zA-Z0-9_]*
/*operators*/
INC 				\+\+
DEC					--
MULT				\*
DIV					\/
MOD					%
ADD					\+
SUB					-
EQUAL_EQUAL			==
NOT_EQUAL			!=
LT					<
GT					>
LE					<=
GE					>=
OR 					\|\|
AND 				\&\&
NOT					!
BW_NOT				~
LEFT_SHIFT			<<
RIGHT_SHIFT			>>
BW_OR				\|
BW_XOR				\^
BW_AND				\&
MUL_EQUALS 			\*=
DIV_EQUALS 			\/=
MOD_EQUALS			%=
ADD_EQUALS			\+=
SUB_EQUALS			-=
LEFT_EQUALS			<<=
RIGHT_EQUALS 		>>=
AND_EQUALS			&=
OR_EQUALS			\|=
XOR_EQUALS			\^=
CONDITIONAL_OP		\?|\:
PUNCTUATOR_OP		\[|\]|\(|\)|\.\.\.|\.|\-\>
SEMICOLON			;
COMMA				\,
LCURLY				\{
RCURLY				\}
EQUALS				=
LBRAC				\(
RBRAC				\)
/*others*/
NEW_LINE			\n
TAB					(\t)*
SPACE 				[ ]*
%%

{OR}				{yylval.string = strdup(yytext); return OR;}
{AND}				{yylval.string = strdup(yytext); return AND;}
{BW_OR}				{yylval.string = strdup(yytext); return BW_OR;}
{BW_XOR}			{yylval.string = strdup(yytext); return BW_XOR;}
{BW_AND}			{yylval.string = strdup(yytext); return BW_AND;}
{EQUAL_EQUAL}		{yylval.string = strdup(yytext); return EQUAL_EQUAL;}
{NOT_EQUAL}			{yylval.string = strdup(yytext); return NOT_EQUAL;}
{LT}				{yylval.string = strdup(yytext); return LT;}
{GT}				{yylval.string = strdup(yytext); return GT;}
{LE}				{yylval.string = strdup(yytext); return LE;}
{GE}				{yylval.string = strdup(yytext); return GE;}
{LEFT_SHIFT}		{yylval.string = strdup(yytext); return LEFT_SHIFT;}
{RIGHT_SHIFT}		{yylval.string = strdup(yytext); return RIGHT_SHIFT;}
{ADD}				{yylval.string = strdup(yytext); return ADD;}
{SUB}				{yylval.string = strdup(yytext); return SUB;}
{MULT}				{yylval.string = strdup(yytext); return MULT;}
{DIV}				{yylval.string = strdup(yytext); return DIV;}
{MOD}				{yylval.string = strdup(yytext); return MOD;}
{NOT}				{yylval.string = strdup(yytext); return NOT;}
{BW_NOT}			{yylval.string = strdup(yytext); return BW_NOT;}
{INC}				{yylval.string = strdup(yytext); return INC;}
{DEC}				{yylval.string = strdup(yytext); return DEC;}
{SEMICOLON}			{return SEMICOLON;}
{COMMA}				{return COMMA;}
{LCURLY}			{return LCURLY;}
{RCURLY}			{return RCURLY;}
{EQUALS}			{yylval.string = strdup(yytext); return EQUALS;}
{MUL_EQUALS} 		{yylval.string = strdup(yytext); return MUL_EQUALS;}
{DIV_EQUALS}		{yylval.string = strdup(yytext); return DIV_EQUALS;} 
{MOD_EQUALS}	   	{yylval.string = strdup(yytext); return MOD_EQUALS;}	 	
{ADD_EQUALS}		{yylval.string = strdup(yytext); return ADD_EQUALS;}	
{SUB_EQUALS}		{yylval.string = strdup(yytext); return SUB_EQUALS;}
{LEFT_EQUALS}		{yylval.string = strdup(yytext); return LEFT_EQUALS;}
{RIGHT_EQUALS}		{yylval.string = strdup(yytext); return RIGHT_EQUALS;} 
{AND_EQUALS}		{yylval.string = strdup(yytext); return AND_EQUALS;}	
{OR_EQUALS}			{yylval.string = strdup(yytext); return OR_EQUALS;}
{XOR_EQUALS}		{yylval.string = strdup(yytext); return XOR_EQUALS;}
{LBRAC}				{return LBRAC;}
{RBRAC}				{return RBRAC;}

{OCTAL}             {yylval.i_num = strtol(yytext,NULL,8); return INT_VAL;}
{HEXADECIMAL}       {yylval.i_num = strtol(yytext,NULL,16); return INT_VAL;}
{DECIMAL}			{yylval.i_num = strtol(yytext,NULL,10); return INT_VAL;}
{FLOAT}				{yylval.f_num = atof(yytext); return FLOAT_VAL;}
{CHAR}				{yylval.string = strdup(yytext); return CHAR;}
{STRING}			{yylval.string = strdup(yytext); return STRING;}

{INT_KWD}			{return INT;}
{IF_KWD}			{return IF;}
{ELSE_KWD}			{return ELSE;}
{WHILE_KWD}			{return WHILE;}
{FOR_KWD}			{return FOR;}
{GOTO}				{return GOTO;}
{CONTINUE}			{return CONTINUE;}
{BREAK}				{return BREAK;}
{RETURN}			{return RETURN;}

{IDENTIFIER}		{yylval.string = strdup(yytext); return IDENTIFIER;}

{TAB}|{SPACE}|{NEW_LINE}		{}

%%
