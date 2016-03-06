#ifndef C_PARSER_H
#define C_PARSER_H

#include <iostream> 
#include <string> 
#include <sstream> 

class Node;
class File;
class ExternalDecl;
class Decl;
class DeclSpec;
class TypeSpec;
class InitList;
class InitDeclr;
class Declr;
class Iden;
class InitVal;
class ParamList;
class AssExpr;
class PrimExpr;
class CondExpr;
class UnaryExpr;

class Node
{
public:
	virtual void print() =0; 
	virtual ~Node() {}
};

class File : public Node
{
private: 
	ExternalDecl* external_decl; 
	File* file;
public:
	File(ExternalDecl* _external_decl=NULL, File* _file=NULL);
	void print(); 
};

class ExternalDecl : public Node
{
private:
	Decl* decl;
public:
	ExternalDecl(Decl* _decl = NULL);
	void print(); 
};

class Decl : public Node
{
private:
	DeclSpec* decl_spec;
	InitList* init_list;
public:
	Decl(DeclSpec* _decl_spec = NULL, InitList* _init_list = NULL);
	void print();
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
};

class InitDeclr : public Node
{
private: 
	Declr* declr; 
	InitVal* init_val; 
public: 
	InitDeclr(Declr* _declr = NULL, InitVal* _init_val = NULL);
	void print(); 
};

class Declr : public Node
{
private:
	std::string id;
	Declr* declr;
	ParamList* param_list;
public:
	Declr(std::string _id="", Declr* _declr=NULL, ParamList* _param_list=NULL); 
	void print(); 
};

class InitVal : public Node
{
private:
	AssExpr* ass_expr; 
public:
	InitVal(AssExpr* _ass_expr=NULL); 
	void print();
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
};

class CondExpr : public Node
{
private:
	PrimExpr* prim_expr; 
public:
	CondExpr(PrimExpr* _prim_expr = NULL);
	void print(); 
};

class PrimExpr : public Node
{
private:
	std::string value;
public:
	PrimExpr(std::string _value = ""); 
	void print(); 
};

#endif
