%option noyywrap

%{
#include <iostream> 

enum
{	
}
%}

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
IDENTIFIER			[a-zA-Z][a-zA-Z0-9\_]*
/*operators*/
ARITHMETIC_OP		\+|-|\*|\/|%|\+\+|--
RELATION_OP			==|!=|>|<|>=|<=
LOGICAL_OP			&&|\|\||!
BITWISE_OP			&|\||\^|<<|>>
ASSIGNMENT_OP		=|\+=|-=|\*=|\/=|%=|\|=|&=|\^=
CONDITIONAL_OP		\?|\:
PUNCTUATOR_OP		\[|\]|\(|\)|\{|\}|;|\.\.\.|\"

%%
