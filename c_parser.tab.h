/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_C_PARSER_TAB_H_INCLUDED
# define YY_YY_C_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    SEMICOLON = 258,
    COMMA = 259,
    LCURLY = 260,
    RCURLY = 261,
    LBRAC = 262,
    RBRAC = 263,
    LSQBRAC = 264,
    RSQBRAC = 265,
    INT = 266,
    FLOAT = 267,
    DOUBLE = 268,
    BOOL = 269,
    LONG = 270,
    UNSIGNED = 271,
    SIGNED = 272,
    CONST = 273,
    SHORT = 274,
    VOID = 275,
    STRUCT = 276,
    UNION = 277,
    CHAR = 278,
    TYPEDEF = 279,
    VOLATILE = 280,
    STRING = 281,
    IDENTIFIER = 282,
    INT_VAL = 283,
    FLOAT_VAL = 284,
    STRING_LIT = 285,
    OCT_VAL = 286,
    HEX_VAL = 287,
    IF = 288,
    ELSE = 289,
    FOR = 290,
    WHILE = 291,
    GOTO_KWD = 292,
    CONTINUE_KWD = 293,
    BREAK = 294,
    RETURN = 295,
    EQUALS = 296,
    MUL_EQUALS = 297,
    DIV_EQUALS = 298,
    MOD_EQUALS = 299,
    ADD_EQUALS = 300,
    SUB_EQUALS = 301,
    LEFT_EQUALS = 302,
    RIGHT_EQUALS = 303,
    AND_EQUALS = 304,
    OR_EQUALS = 305,
    XOR_EQUALS = 306,
    ADD = 307,
    SUB = 308,
    MULT = 309,
    DIV = 310,
    MOD = 311,
    QUESTION_MARK = 312,
    COLON = 313,
    OR = 314,
    AND = 315,
    BW_OR = 316,
    BW_XOR = 317,
    BW_AND = 318,
    EQUAL_EQUAL = 319,
    NOT_EQUAL = 320,
    LT = 321,
    GT = 322,
    LE = 323,
    GE = 324,
    LEFT_SHIFT = 325,
    RIGHT_SHIFT = 326,
    INC = 327,
    DEC = 328,
    BW_NOT = 329,
    NOT = 330,
    ENUM = 331,
    CHAR_KWD = 332,
    FLOAT_KWD = 333,
    DOUBLE_KWD = 334,
    AUTO = 335,
    EXTERN = 336,
    REGISTER = 337,
    STATIC = 338,
    DO = 339,
    SWITCH = 340,
    CASE = 341,
    SIZEOF = 342,
    DEFAULT = 343,
    TYPE = 344
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 2552 "src/c_parser.y" /* yacc.c:1915  */

	char* string;
	int i_num; 
	float f_num;
	class Node* tree_node;
	class File* File;
	class ExternalDecl* Ext_Decl;
	class FuncDef* Func_Def; 
	class Decl* Decl;
	class DeclSpec* Decl_Spec;
	class TypeSpec* Type_Spec;
	class InitList* Init_List;
	class InitDeclr* Init_Declr;
	class Declr* Declr;
	class InitVal* Init_Val;
	class ParamList* Param_List;
	class ParamDecl* Param_Decl; 
	class Iden* Iden;
	class Expr* _Expr;
	class AssExpr* Ass_Expr;
	class PrimExpr* Prim_Expr;
	class CondExpr* Cond_Expr;
	class CompStat* Comp_Stat;
	class DeclList* Decl_List;
	class StatList* Stat_List;
	class Stat* Stat;
	class ExprStat* Expr_Stat;
	class Expression* Express;
	class UnaryExpr* Unary_Expr;
	class PostFixExpr* Postfix_Expr;
	class ArgList* Arg_List;
	class LoopStat* Loop_Stat;
	class DoStat* Do_Stat;
	class SelecStat* Selec_Stat;
	class IfElseExpr* IE_Expr;
	class InitValList* Init_Val_List;
	class TagStat* Tag_Stat;
	class Pointer* Pntr;

#line 184 "c_parser.tab.h" /* yacc.c:1915  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_C_PARSER_TAB_H_INCLUDED  */
