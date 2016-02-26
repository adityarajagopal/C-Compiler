%option noyywrap
%{
#include "c_parser.tab.h"
#include <iostream> 
#define DEBUG 1
%}

PRE_SHARP			#[ ][0-9]+[ ]\"[^"]*\"([ ][1234])?([ ][1234])?([ ][1234])?([ ][1234])?$
INVALID_SHARP		#.*$
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
/*constants*/
OCTAL				0[0-7]*([uU][l|ll|LL|L]?|[l|L|ll|LL][uU]?)?
HEXADECIMAL			0(x|X)[0-9a-fA-F]+*([uU][l|ll|LL|L]?|[l|L|ll|LL][uU]?)?
DECIMAL				[0-9]+([uU][l|ll|LL|L]?|[l|L|ll|LL][uU]?)?
FLOAT				[0-9]*\.?[0-9]+|[0-9]+\.?[0-9]*)([eE][-\+]?[0-9]+[lLfF]?
CHAR				\'[^']*\'
STRING				\"(\\.|[^\\"])*\"
/*others*/
NEW_LINE			\n
TAB					(\t)*
SPACE 				[ ]*
%%

{SEMICOLON}			if(DEBUG){std::cout<<"SEMICOLON"<<std::endl;}return SEMICOLON;
{COMMA}				if(DEBUG){std::cout<<"COMMA"<<std::endl;}return COMMA;
{LCURLY}			if(DEBUG){std::cout<<"LCURLY"<<std::endl;}return LCURLY;
{RCURLY}			if(DEBUG){std::cout<<"RCURLY"<<std::endl;}return RCURLY;
{EQUALS}			{yylval.string = strdup(yytext); if(DEBUG){std::cout<<"EQUALS"<<std::endl;}return EQUALS;}
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
{LBRAC}				if(DEBUG){std::cout<<"LBRAC"<<std::endl;}return LBRAC;
{RBRAC}				if(DEBUG){std::cout<<"RBRAC"<<std::endl;}return RBRAC;
{OR}				{yylval.string = strdup(yytext); if(DEBUG){std::cout<<"OR"<<std::endl;}return OR;}
{AND}				{yylval.string = strdup(yytext); if(DEBUG){std::cout<<"AND"<<std::endl;}return AND;}
{BW_OR}				{yylval.string = strdup(yytext); return BW_OR;}
{BW_XOR}			{yylval.string = strdup(yytext); return BW_XOR;}
{BW_AND}			{yylval.string = strdup(yytext); return BW_AND;}
{EQUAL_EQUAL}		{yylval.string = strdup(yytext); return EQUAL_EQUAL;}
{NOT_EQUAL}			{yylval.string = strdup(yytext); return NOT_EQUAL;}
{LT}				{yylval.string = strdup(yytext); if(DEBUG){std::cout<<"LT"<<std::endl;}return LT;}
{GT}				{yylval.string = strdup(yytext); if(DEBUG){std::cout<<"GT"<<std::endl;}return GT;}
{LE}				{yylval.string = strdup(yytext); if(DEBUG){std::cout<<"LE"<<std::endl;}return LE;}
{GE}				{yylval.string = strdup(yytext); if(DEBUG){std::cout<<"GE"<<std::endl;}return GE;}
{LEFT_SHIFT}		{yylval.string = strdup(yytext); return LEFT_SHIFT;}
{RIGHT_SHIFT}		{yylval.string = strdup(yytext); return RIGHT_SHIFT;}
{ADD}				{yylval.string = strdup(yytext); if(DEBUG){std::cout<<"ADD"<<std::endl;}return ADD;}
{SUB}				{yylval.string = strdup(yytext); if(DEBUG){std::cout<<"SUB"<<std::endl;}return SUB;}
{MULT}				{yylval.string = strdup(yytext); if(DEBUG){std::cout<<"MULT"<<std::endl;}return MULT;}
{DIV}				{yylval.string = strdup(yytext); if(DEBUG){std::cout<<"DIV"<<std::endl;}return DIV;}
{MOD}				{yylval.string = strdup(yytext); if(DEBUG){std::cout<<"MOD"<<std::endl;}return MOD;}
{NOT}				{yylval.string = strdup(yytext); if(DEBUG){std::cout<<"NOT"<<std::endl;}return NOT;}
{BW_NOT}			{yylval.string = strdup(yytext); return BW_NOT;}
{INC}				{yylval.string = strdup(yytext); if(DEBUG){std::cout<<"INC"<<std::endl;}return INC;}
{DEC}				{yylval.string = strdup(yytext); if(DEBUG){std::cout<<"DEC"<<std::endl;}return DEC;}

{OCTAL}             {yylval.i_num = strtol(yytext,NULL,8); if(DEBUG){std::cout << strdup(yytext) << std::endl;} return INT_VAL;}
{HEXADECIMAL}       {yylval.i_num = strtol(yytext,NULL,16); return INT_VAL;}
{DECIMAL}			{yylval.i_num = strtol(yytext,NULL,10); if(DEBUG){std::cout << strdup(yytext) << std::endl;} return INT_VAL;}
{FLOAT}				{yylval.f_num = atof(yytext); return FLOAT_VAL;}

{INT_KWD}			if(DEBUG){std::cout<<"INT"<<std::endl;}return INT;
{IF_KWD}			if(DEBUG){std::cout<<"IF"<<std::endl;}return IF;
{ELSE_KWD}			if(DEBUG){std::cout<<"ELSE"<<std::endl;}return ELSE;
{WHILE_KWD}			if(DEBUG){std::cout<<"WHILE"<<std::endl;}return WHILE;
{FOR_KWD}			if(DEBUG){std::cout<<"FOR"<<std::endl;}return FOR;
{GOTO}				if(DEBUG){std::cout<<"GOTO"<<std::endl;}return GOTO;
{CONTINUE}			if(DEBUG){std::cout<<"CONTINUE"<<std::endl;}return CONTINUE;
{BREAK}				if(DEBUG){std::cout<<"BREAK"<<std::endl;}return BREAK; 
{RETURN}			if(DEBUG){std::cout<<"RETURN"<<std::endl;}return RETURN;

{IDENTIFIER}		{yylval.string = strdup(yytext); if(DEBUG){std::cout<<"IDENTIFIER"<<std::endl;}return IDENTIFIER;}

{TAB}|{SPACE}|{NEW_LINE}		{}

%%
