#ifndef C_PARSER_H
#define C_PARSER_H

#include <iostream>
#include <algorithm>
#include <string>
#include <fstream> 
#include <sstream>
#include <map>
#include <vector>

class Node;
class File;
class ExternalDecl;
class FuncDef;
class Decl;
class DeclSpec;
class TypeSpec;
class InitList;
class InitDeclr;
class Declr;
class Iden;
class InitVal;
class ParamList;
class ParamDecl; 
class AssExpr;
class Expr;
class PrimExpr;
class CondExpr;
class UnaryExpr;
class CompStat;
class DeclList;
class StatList; 
class Stat;
class ExprStat; 
class LoopStat; 
class SelecStat; 
class JumpStat;
class Expression;
class PostFixExpr;
class ArgList;
class DoStat;
class IfElseExpr;
class InitValList;
class TagStat;

typedef std::string Tag;

class Node
{
protected:
	Tag tag;
	int scope;
public:
	Node() {};
	Node(int set);
	virtual void print() =0;
	virtual void generate_code() {};
	virtual void get_max_arguments(int& _offset) {};
	virtual ~Node() {};
};

class File : public Node
{
private: 
	ExternalDecl* external_decl; 
	File* file;
public:
	File(ExternalDecl* _external_decl=NULL, File* _file=NULL);
	void print(); 
	void generate_code();
	void get_max_arguments(int& _offset) {}; 
};

class ExternalDecl : public Node
{
private:
	FuncDef* func_def;
	Decl* decl;
public:
	ExternalDecl(FuncDef* _func_def=NULL, Decl* _decl = NULL);
	void print();
	void generate_code(); 

};

class FuncDef : public Node
{
private:
	DeclSpec* decl_spec; 
	Declr* declr; 
	CompStat* comp_stat;
public:
	FuncDef(DeclSpec* _decl_spec=NULL, Declr* _declr=NULL, CompStat* _comp_stat=NULL); 
	void print(); 
	void generate_code(); 
};

class Decl : public Node
{
private:
	DeclSpec* decl_spec;
	InitList* init_list;
public:
	Decl(DeclSpec* _decl_spec = NULL, InitList* _init_list = NULL);
	void print();
	void generate_code();
};

class DeclSpec : public Node
{
private:
	TypeSpec* type_spec;
	DeclSpec* decl_spec; 
public:
	DeclSpec(TypeSpec* _type_spec = NULL, DeclSpec* _decl_spec = NULL); 
	void print(); 
};

class TypeSpec : public Node
{
private:
	std::string type; 
public:
	TypeSpec(std::string i_type);
	void print(); 
};

class InitList : public Node
{
private:
	InitDeclr* init_declr;
	InitList* init_list; 
public:
	InitList(InitDeclr* _init_declr = NULL, InitList* _init_list = NULL); 
	void print();
	void generate_code();
};

class InitDeclr : public Node
{
private: 
	Declr* declr; 
	InitVal* init_val; 
public: 
	InitDeclr(Declr* _declr = NULL, InitVal* _init_val = NULL);
	void print();
	void generate_code();
};

class Declr : public Node
{
private:
	std::string id;
	Declr* declr;
	ParamList* param_list;
	CondExpr* cond_expr;
	int func_dec; 
public:
	Declr(std::string _id="", Declr* _declr=NULL, ParamList* _param_list=NULL, int _fd=0, CondExpr* _cond_expr=NULL); 
	void print(); 
	void generate_code();
	std::string get_id();
	void get_tag(std::string& _tag); 
};

class InitVal : public Node
{
private:
	AssExpr* ass_expr;
	InitValList* init_val_list;
public:
	InitVal(AssExpr* _ass_expr=NULL, InitValList* _init_val_list=NULL); 
	void print();
	void generate_code();
	void get_tag(std::string& _tag); 
};

class InitValList : public Node
{
private:
	InitVal* init_val; 
	InitValList* init_val_list;
public:
	InitValList(InitVal* _init_val=NULL, InitValList* _init_val_list=NULL);
	void print() {};
	void generate_code();
	void get_tag(std::string& _tag);
};

class ParamList : public Node
{
private:
	ParamDecl* param_decl; 
	ParamList* param_list; 
public:
	ParamList(ParamDecl* _param_decl=NULL, ParamList* _param_list=NULL);
	void print();
	void generate_code();
	void get_tag(std::string& _tag); 
};

class ParamDecl : public Node
{
private:
	DeclSpec* decl_spec; 
	Declr* declr; 
public:
	ParamDecl(DeclSpec* _decl_spec=NULL, Declr* _declr=NULL); 
	void print();
	void generate_code();
	void get_tag(std::string& _tag);
};

class AssExpr : public Node
{
private:
	CondExpr* cond_expr;
	UnaryExpr* unary_expr;
	std::string ass_oper; 
	AssExpr* ass_expr;
public:
	AssExpr(CondExpr* _cond_expr=NULL, UnaryExpr* _unary_expr=NULL, std::string _ass_oper="", AssExpr* _ass_expr=NULL);
	void print(); 
	void generate_code();
	void get_tag(std::string& _tag);
	void get_max_arguments(int& _offset);
};


class CondExpr : public Node
{
private:
	Expression* expression;
	IfElseExpr* ie_expr;
public:
	CondExpr(Expression* _expression = NULL, IfElseExpr* _ie_expr=NULL);
	void print();
	void get_tag(std::string& _tag);
	void generate_code();
	void get_max_arguments(int& _offset);
};

class IfElseExpr : public Node
{
private:
	Expression* if_cond; 
	Expr* if_expr; 
	CondExpr* else_expr;
public: 
	IfElseExpr(Expression* _ic=NULL, Expr* _ie=NULL, CondExpr* _ee=NULL); 
	void print();
	void generate_code();
	void get_tag(std::string& _tag);
};

class PrimExpr : public Node
{
private:
	std::string value;
	int flag;
	Expr* expr;
public:
	PrimExpr(std::string _value = "", int _flag=-1,Expr* _e=NULL); 
	void print();
	void generate_code();
	void get_tag(std::string& _tag);
	std::string get_id();
};

class CompStat : public Node
{
private:
	StatList* stat_list; 
	DeclList* decl_list;
public:
	CompStat(StatList* _stat_list=NULL, DeclList* _decl_list=NULL);
	void print();
	void generate_code();
	void get_max_arguments(int& _offset); 
};

class DeclList : public Node
{
private:
	Decl* decl; 
	DeclList* decl_list; 
public: 
	DeclList(Decl* _decl=NULL, DeclList* _decl_list=NULL); 
	void print();
	void generate_code();
};

class StatList : public Node
{
private:
	Stat* stat;
	StatList* stat_list; 
public:
	StatList(Stat* _stat=NULL, StatList* _stat_list=NULL);
	void print();
	void generate_code();
	void get_max_arguments(int& _offset);
};

class Stat : public Node
{
/*
private:
	CompStat* comp_stat; 
	ExprStat* expr_stat; 
	SelecStat* selec_stat; 
	LoopStat* loop_stat; 
	JumpStat* jump_stat; 
public: 
	Stat(CompStat* _comp_stat=NULL, ExprStat* _expr_stat=NULL, SelecStat* _selec_stat=NULL, LoopStat* _loop_stat=NULL, JumpStat* _jump_stat=NULL);
	void print(); 
	void generate_code(); 
*/
};

class JumpStat : public Node
{
private: 
	Expr* expr;
	std::string type;
public: 
	JumpStat(Expr* _expr, std::string _type); 
	void generate_code();
	void print() {};
	void get_max_arguments(int& _offset); 
};

class TagStat : public Node
{
private:
	Stat* stat; 
	CondExpr* cond_expr;
	std::string id; 
public:
	TagStat(Stat* _stat=NULL, CondExpr* _cond_expr=NULL, std::string _id="");
	void print() {};
	void generate_code();
};

class ExprStat : public Node
{
private:
	Expr* expr;
public:
	ExprStat(Expr* _expr=NULL);
	void print();
	void generate_code();
	void get_tag(std::string& _tag);
	void get_max_arguments(int& _offset);
};

class Expr : public Node
{
private:
	AssExpr* ass_expr;
	Expr* expr;
public:
	Expr(AssExpr* _ass_exp=NULL, Expr* _expr=NULL);
	void print();
	void generate_code();
	void get_tag(std::string& _tag);
	void get_max_arguments(int& _offset);
};

class Expression : public Node
{
private:
	Expression* lhs; 
	Expression* rhs; 
	std::string op;
	UnaryExpr* unary_expr;
public: 
	Expression(Expression* _lhs=NULL, Expression* rhs=NULL, std::string _op="", UnaryExpr* _unary_expr=NULL);
	void get_tag(std::string& _tag); 
	void print(); 
	void generate_code();
	void get_max_arguments(int& _offset);
};

class UnaryExpr : public Node
{
private:
	PostFixExpr* post_fix_expr;
	UnaryExpr* unary_expr;
	std::string unary_op;
public:
	UnaryExpr(PostFixExpr* _post_fix_expr=NULL, UnaryExpr* _unary_expr=NULL, std::string _unary_op="");
	void print();
	void generate_code();
	void get_tag(std::string& _tag);
	void get_max_arguments(int& _offset);
	void get_type(std::string& _type);
	void set_modify(); 
};

class PostFixExpr : public Node
{
private:
	PrimExpr* prim_expr; 
	PostFixExpr* post_fix_expr; 
	std::string op;
	ArgList* arg_list;
	Expr* expr; 
	bool modify;
public:
	PostFixExpr(PrimExpr* _prim_expr=NULL, PostFixExpr* _post_fix_expr=NULL, std::string _op="", ArgList* _arg_list=NULL, Expr* _expr=NULL);
	void print();
	void generate_code(); 
	void get_tag(std::string& _tag); 
	void get_max_arguments(int& _offset);
	std::string get_id();
	void get_type(std::string& _type);
	void set_modify();
};

class ArgList : public Node
{
private:
	AssExpr* ass_expr; 
	ArgList* arg_list; 
public:
	ArgList(AssExpr* _ass_expr=NULL, ArgList* _arg_list=NULL); 
	void print() {};
	void generate_code();
	void get_max_arguments(int& _offset);
};

class LoopStat : public Node
{
private:
	ExprStat* expr_stat_1; 
	ExprStat* expr_stat_2; 
	Expr* expr; 
	Stat* stat;
	DoStat* do_stat;
public: 
	LoopStat(ExprStat* _es1=NULL, ExprStat* _es2=NULL, Expr* _e=NULL, Stat* _s=NULL, DoStat* _ds=NULL);
	void print();
	void generate_code();
	void get_max_arguments(int& _offset); 
};

class DoStat : public Node
{
private:
	Stat* stat; 
	Expr* expr; 
public:
	DoStat(Stat* _stat=NULL, Expr* _expr=NULL);
	void print();
	void generate_code();
	void get_max_arguments(int& _offset);
};

class SelecStat : public Node
{
private:
	Expr* expr; 
	Stat* stat_if; 
	Stat* stat_else;
	Stat* stat; 
public:
	SelecStat(Expr* _e=NULL, Stat* _si=NULL, Stat* _se=NULL, Stat* _s=NULL); 
	void print();
	void generate_code();
	void get_max_arguments(int& _offset); 
};

#endif
