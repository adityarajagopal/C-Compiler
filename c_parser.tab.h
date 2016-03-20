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
    INT = 264,
    FLOAT = 265,
    DOUBLE = 266,
    BOOL = 267,
    LONG = 268,
    UNSIGNED = 269,
    SIGNED = 270,
    CONST = 271,
    SHORT = 272,
    VOID = 273,
    STRUCT = 274,
    UNION = 275,
    CHAR = 276,
    TYPEDEF = 277,
    VOLATILE = 278,
    STRING = 279,
    IDENTIFIER = 280,
    INT_VAL = 281,
    FLOAT_VAL = 282,
    STRING_LIT = 283,
    OCT_VAL = 284,
    HEX_VAL = 285,
    IF = 286,
    ELSE = 287,
    FOR = 288,
    WHILE = 289,
    GOTO_KWD = 290,
    CONTINUE_KWD = 291,
    BREAK = 292,
    RETURN = 293,
    EQUALS = 294,
    MUL_EQUALS = 295,
    DIV_EQUALS = 296,
    MOD_EQUALS = 297,
    ADD_EQUALS = 298,
    SUB_EQUALS = 299,
    LEFT_EQUALS = 300,
    RIGHT_EQUALS = 301,
    AND_EQUALS = 302,
    OR_EQUALS = 303,
    XOR_EQUALS = 304,
    ADD = 305,
    SUB = 306,
    MULT = 307,
    DIV = 308,
    MOD = 309,
    QUESTION_MARK = 310,
    COLON = 311,
    OR = 312,
    AND = 313,
    BW_OR = 314,
    BW_XOR = 315,
    BW_AND = 316,
    EQUAL_EQUAL = 317,
    NOT_EQUAL = 318,
    LT = 319,
    GT = 320,
    LE = 321,
    GE = 322,
    LEFT_SHIFT = 323,
    RIGHT_SHIFT = 324,
    INC = 325,
    DEC = 326,
    BW_NOT = 327,
    NOT = 328,
    ENUM = 329,
    CHAR_KWD = 330,
    FLOAT_KWD = 331,
    DOUBLE_KWD = 332,
    AUTO = 333,
    EXTERN = 334,
    REGISTER = 335,
    STATIC = 336,
    DO = 337,
    SWITCH = 338,
    CASE = 339,
    SIZEOF = 340,
    DEFAULT = 341,
    TYPE = 342
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 1636 "src/c_parser.y" /* yacc.c:1915  */

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

#line 179 "c_parser.tab.h" /* yacc.c:1915  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_C_PARSER_TAB_H_INCLUDED  */
