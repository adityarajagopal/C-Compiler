
%{
#include "src/c_parser.h"

#define TMP1 8
#define TMP2 9
#define TMP3 10
#define ARR_REG 11
#define CASE_REG 12

int yylex();
int yyerror(const char* s);

std::ofstream outfile;
File* root = NULL;
int offset = 0;
int num_arg = 0; 
int global_scope = 0; 
int arg_reg = 4;
int glbl_loop_num = 0;
int glbl_selec_num = 0;
int num_arguments = 0;
int num_parameters = 0;
int arr_index = 0;
int case_num = 0;
int break_num = 0; 

bool cases = true;

std::map<Tag, int> OffsetMap;
std::map<std::string, std::vector<Tag> > VarTagMap;
std::map<std::string, int> FuncMap;
std::map<Tag, int> ReturnValMap;
std::map<Tag, bool> IsArray;

std::vector<Tag> Arguments;
std::vector<int> Breaks; 

std::stringstream TUnit , Hdr, SetupFp, os, RestoreFp, Ftr, FuncInit, ArrayLabel;  

std::string set_offset()
{
	std::stringstream ss; 
	ss << "t_" << offset; 
	OffsetMap[ss.str()] = offset; 
	offset += 4; 
	return ss.str(); 
}

//Node::Node(int set) : tag(set_offset()) {}

File::File(ExternalDecl* _external_decl, File* _file) : external_decl(_external_decl), file(_file) {}
void File::print()
{
	if(file != NULL)
	{
		file->print(); 
	}
	if(external_decl != NULL)
	{
		external_decl->print();
	}
}
//std::string File::set_offset() {return "";}
void File::generate_code() 
{
	if(external_decl != NULL) {external_decl->generate_code();}
	
	TUnit << Hdr.str() << SetupFp.str() << FuncInit.str() << os.str() << RestoreFp.str() << Ftr.str() << std::endl; 
	
	Hdr.str(""); 
	SetupFp.str("");
	os.str("");
	FuncInit.str("");
	RestoreFp.str(""); 
	Ftr.str(""); 
	
	if(file != NULL) {file->generate_code();}
}

ExternalDecl::ExternalDecl(FuncDef* _func_def, Decl* _decl) : func_def(_func_def), decl(_decl) {}
void ExternalDecl::print()
{
	if(decl != NULL)
	{
		decl->print();
	}
	if(func_def != NULL)
	{
		func_def->print(); 
	}
}
void ExternalDecl::generate_code()
{
	if(func_def != NULL){func_def->generate_code();}
	if(decl != NULL) {decl->generate_code();}
}


FuncDef::FuncDef(DeclSpec* _decl_spec, Declr* _declr, CompStat* _comp_stat) : decl_spec(_decl_spec), declr(_declr), comp_stat(_comp_stat) {}
void FuncDef::print()
{
	if(decl_spec != NULL)
	{
		decl_spec->print(); 
	}
	if(declr != NULL)
	{
		declr->print(); 
	}
	if(comp_stat != NULL)
	{
		std::cerr << "{" << std::endl;
		comp_stat->print(); 
		std::cerr << "}" << std::endl;
	}
}
void FuncDef::generate_code()
{
	FuncMap[declr->get_id()] = offset;

	if(comp_stat != NULL)
	{
		offset=0;
		comp_stat->get_max_arguments(offset);
		std::cerr << "ARGUMETNS: " << offset << std::endl; 
		if(offset < 4) {offset = 16;}
		else {offset = offset * 4;}
	}
	else
	{
		offset = 16;
	}

	Hdr << "\t" << ".align\t2" << std::endl; 
	Hdr << "\t" << ".globl\t" << declr->get_id();
	Hdr << std::endl;
	Hdr << "\t" << ".ent\t" << declr->get_id() << std::endl; 
	Hdr << "\t" << ".type\t" << declr->get_id(); 
	Hdr << ", @function" << std::endl; 
	Hdr << declr->get_id();  
	Hdr << ":" << std::endl;

	Arguments.clear();
	
	if(declr != NULL)
	{
		global_scope++;
		declr->generate_code(); 
		global_scope--;
	}

	if(comp_stat != NULL)
	{
		comp_stat->generate_code();
	}
	
	offset+=12; //accounting for frame pointer and return address 
	for(int i=0; i<Arguments.size(); i++)
	{
		if(i<4)
		{
			FuncInit << "\tsw\t$a" << i << "," << OffsetMap[Arguments[i]] << "($fp)" << std::endl; 
		}
		else
		{
			FuncInit << "\tlw\t$" << TMP1 << "," << offset+(i*4) << "($fp)" << std::endl; 
			FuncInit << "\tsw\t$" << TMP1 << "," << OffsetMap[Arguments[i]] << "($fp)" << std::endl; 	
		}
	}

	SetupFp << "\taddiu\t$sp,$sp,-" << offset << std::endl;
	SetupFp << "\tsw\t$fp," << offset-8 << "($sp)" << std::endl;
	SetupFp << "\tsw\t$31," << offset-4 << "($sp)" << std::endl;
	SetupFp << "\tmove\t$fp,$sp" << std::endl;

	RestoreFp << "\tmove\t$sp,$fp" << std::endl; 
	RestoreFp << "\tlw\t$fp," << offset-8 << "($sp)" << std::endl; 
	RestoreFp << "\tlw\t$31," << offset-4 << "($sp)" << std::endl;
	RestoreFp << "\taddiu\t$sp,$sp," << offset << std::endl; 
	RestoreFp << "\tj\t" << "$31" << std::endl;
	RestoreFp << "\tnop" << std::endl; 

	//Ftr << "\t" << ".cprestore\t16" << std::endl; 
	Ftr << "\t" << ".end\t" << declr->get_id(); 
	Ftr << std::endl; 
	Ftr << "\t" << ".size\t" << declr->get_id(); 
	Ftr << ", .-" << declr->get_id(); 
	Ftr << std::endl;
	
	offset = FuncMap[declr->get_id()];
}

Decl::Decl(DeclSpec* _decl_spec, InitList* _init_list) : decl_spec(_decl_spec), init_list(_init_list) {}
void Decl::print()
{
	if(decl_spec != NULL)
	{
		decl_spec->print();
	}
	if(init_list != NULL)
	{
		init_list->print(); 
	}
	std::cerr << ";" << std::endl;
}
void Decl::generate_code()
{
	//is_func_dec = 1;
	if(init_list != NULL)
	{
		init_list->generate_code();
		arr_index = 0; 
	}
}

DeclSpec::DeclSpec(TypeSpec* _type_spec, DeclSpec* _decl_spec) : type_spec(_type_spec), decl_spec(_decl_spec) {}
void DeclSpec::print()
{
	if(type_spec != NULL)
	{
		type_spec->print();
	}
	if(decl_spec != NULL)
	{
		decl_spec->print();
	}
}

TypeSpec::TypeSpec(std::string i_type) : type(i_type) {}
void TypeSpec::print()
{
	std::cerr << type << " ";
}

InitList::InitList(InitDeclr* _init_declr, InitList* _init_list) : init_declr(_init_declr), init_list(_init_list) {}
void InitList::print()
{
	if(init_declr != NULL)
	{
		init_declr->print();
	}
	if(init_list != NULL)
	{
		std::cerr << ", ";
		init_list->print();
	}
}
void InitList::generate_code()
{
	if(init_declr != NULL){init_declr->generate_code();}
	if(init_list != NULL){init_list->generate_code();}
}

InitDeclr::InitDeclr(Declr* _declr, InitVal* _init_val) : declr(_declr), init_val(_init_val) {}
void InitDeclr::print()
{
	if(declr != NULL) 
	{
		declr->print();
	}
	if(init_val != NULL)
	{
		std::cerr << "= ";
		init_val->print(); 
	}
}
void InitDeclr::generate_code()
{
	if(declr != NULL){declr->generate_code();}
	if(init_val != NULL){init_val->generate_code();}

	std::string lhs_tag=""; 
	std::string rhs_tag="";
	if(init_val != NULL)
	{
		if(declr != NULL) declr->get_tag(lhs_tag); 
		init_val->get_tag(rhs_tag); 
		os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
		os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl; 
	}
}

Declr::Declr(std::string _id, Declr* _declr, ParamList* _param_list, int _fd, CondExpr* _cond_expr) : id(_id), declr(_declr), param_list(_param_list), func_dec(_fd), cond_expr(_cond_expr) {}

void Declr::print()
{
	if(id != "")
	{
		std::cerr << id << " "; 
	}
	if(declr != NULL)
	{
		declr->print();
	}
	if(param_list != NULL)
	{
		std::cerr << "(";
		param_list->print(); 
		std::cerr << ")" << std::endl;
	}
}
void Declr::generate_code()
{
	if(param_list != NULL){param_list->generate_code();}
	
	if(id != "")
	{
		tag = set_offset();
		VarTagMap[id].resize(global_scope + 1); 
		VarTagMap[id][global_scope] = tag;
	
		std::cerr << "TAG: " << tag << std::endl; 
		std::cerr << "ID: " << id << std::endl;
		std::cerr << "Global Scope: " << global_scope << std::endl;
		std::cerr << "vector: " << VarTagMap[id][global_scope] << std::endl; 
		std::cerr << std::endl; 
	}

	if(declr != NULL){declr->generate_code();}

	if(cond_expr != NULL)
	{
		declr->set_is_array();
		//tag = set_offset();
		cond_expr->generate_code(); 
		std::string size_tag; 
		declr->get_tag(size_tag); 
		//os << "\tlw\t$" << TMP1 << "," << OffsetMap[size_tag] << "($fp)" << std::endl;
		ArrayLabel << std::endl << "arr_" << OffsetMap[size_tag] << ":\t" << ".word"; 
		os << "\tla\t$" << ARR_REG << "," << "arr_" << OffsetMap[size_tag] << std::endl; 
		//os << "\tsw\t$" << ARR_REG << "," << OffsetMap[size_tag] << "($fp)" << std::endl;
	}
}
std::string Declr::get_id()
{
	if(declr != NULL) {return declr->get_id();}	
	return id; 
}
void Declr::get_tag(std::string& _tag)
{
	if(id != "") {_tag = tag;}
	if(declr != NULL) {declr->get_tag(_tag);}
	if(param_list != NULL) {param_list->get_tag(_tag);}
	if(cond_expr != NULL) {cond_expr->get_tag(_tag);}
}
void Declr::set_is_array()
{
	if(id != "") 
	{
		IsArray[tag] = true;
	}
}

InitVal::InitVal(AssExpr* _ass_expr, InitValList* _init_val_list) : ass_expr(_ass_expr), init_val_list(_init_val_list) {}
void InitVal::print()
{
	if(ass_expr != NULL)
	{
		ass_expr->print(); 
	}
}
void InitVal::generate_code()
{
	if(ass_expr != NULL)
	{
		ass_expr->generate_code();
	}
	if(init_val_list != NULL) 
	{
		init_val_list->generate_code();
	}
}
void InitVal::get_tag(std::string& _tag)
{
	if(ass_expr != NULL) {ass_expr->get_tag(_tag);}
	if(init_val_list != NULL) {init_val_list->get_tag(_tag);}
}

InitValList::InitValList(InitVal* _init_val, InitValList* _init_val_list) : init_val(_init_val), init_val_list(_init_val_list) {}
void InitValList::generate_code()
{
	if(init_val != NULL)
	{
		init_val->generate_code();
		std::string arr_tag; 
		init_val->get_tag(arr_tag);
		os << "\tlw\t$" << TMP1 << "," << OffsetMap[arr_tag]  << "($fp)" << std::endl;
		os << "\tsw\t$" << TMP1 << "," << arr_index*4 << "($" << ARR_REG << ")" << std::endl;
		ArrayLabel << "\t0,"; 
		arr_index++;
	}

	if(init_val_list != NULL)
	{
		init_val_list->generate_code();
	}
}
void InitValList::get_tag(std::string& _tag)
{
	if(init_val != NULL) {init_val->get_tag(_tag);}
	if(init_val_list != NULL){init_val_list->get_tag(_tag);}
}

ParamList::ParamList(ParamDecl* _param_decl, ParamList* _param_list) : param_decl(_param_decl), param_list(_param_list) {}
void ParamList::print()
{
	if(param_decl != NULL)
	{
		param_decl->print(); 
	}
	if(param_list != NULL)
	{
		param_list -> print(); 
	}
}
void ParamList::generate_code()
{
	if(param_decl != NULL) {param_decl->generate_code(); num_parameters++;}
	if(param_list != NULL) {param_list->generate_code();}
}
void ParamList::get_tag(std::string& _tag)
{
	if(param_decl != NULL) {param_decl->get_tag(_tag);}
}

ParamDecl::ParamDecl(DeclSpec* _decl_spec, Declr* _declr) : decl_spec(_decl_spec), declr(_declr) {}
void ParamDecl::print() 
{
	if(decl_spec != NULL)
	{
		decl_spec->print(); 
	}
	if(declr != NULL)
	{
		declr->print(); 
	}
	std::cerr << ", ";
}
void ParamDecl::generate_code()
{
	if(declr != NULL) 
	{
		declr->generate_code(); 
		std::string d_tag;
		declr->get_tag(d_tag);
		Arguments.push_back(d_tag); 
	}
}
void ParamDecl::get_tag(std::string& _tag)
{
	if(declr != NULL) {declr->get_tag(_tag);}
}

AssExpr::AssExpr(CondExpr* _cond_expr, UnaryExpr* _unary_expr, std::string _ass_oper, AssExpr* _ass_expr) : cond_expr(_cond_expr), unary_expr(_unary_expr), ass_oper(_ass_oper), ass_expr(_ass_expr) {}
void AssExpr::print()
{
	if(cond_expr != NULL)
	{
		cond_expr->print(); 
	}
	if(unary_expr != NULL)
	{
		unary_expr->print();
	}
	if(ass_oper != "")
	{
		std::cerr << ass_oper << " ";
	}
	if(ass_expr != NULL)
	{
		ass_expr->print();
	}
}
void AssExpr::generate_code()
{
	if(ass_oper != "") {tag = set_offset();}
	
	std::string lhs_tag="";
	std::string rhs_tag="";
	if(ass_oper != "")
	{	
		if(unary_expr != NULL) unary_expr->get_tag(lhs_tag);
		if(ass_expr != NULL) ass_expr->get_tag(rhs_tag);
		std::cerr << "TAG: " << tag << std::endl;
		std::cerr << "OP: " << ass_oper << std::endl; 
		std::cerr << "LHS: " << lhs_tag << std::endl; 
		std::cerr << "RHS: " << rhs_tag << std::endl;
		std::cerr << std::endl; 
	}
	
	if(cond_expr != NULL)
	{
		cond_expr->generate_code(); 
	}

	if(unary_expr != NULL)
	{
		std::string type; 
		if(unary_expr != NULL) {unary_expr->get_type(type);}
		if(type == "array") {unary_expr->set_modify(true);}
		unary_expr->generate_code();
	}
	
	if(ass_expr != NULL)
	{
		ass_expr->generate_code();
	}
	
	if(ass_oper == "+=")
	{
		std::string type; 
		if(unary_expr != NULL) {unary_expr->get_type(type);}
		if(type == "array")
		{
			lhs_tag="";
			rhs_tag="";
			unary_expr->get_tag(lhs_tag);
			ass_expr->get_tag(rhs_tag);
			
			os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl;
			os << "\tlw\t$" << TMP3 << ",0($" << TMP2 << ")" << std::endl; 
			os << "\tadd\t$" << TMP3 << ",$" << TMP3 << ",$" << TMP1 << std::endl; 
			os << "\tsw\t$" << TMP3 << ",0($" << TMP2 << ")" << std::endl;  	

			os << "\tsw" << "\t$" << TMP3 << "," << OffsetMap[tag] << "($fp)" << std::endl;
		}
		else
		{
			lhs_tag="";
			rhs_tag="";
			unary_expr->get_tag(lhs_tag);
			ass_expr->get_tag(rhs_tag);
			os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl; 
			os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\tadd" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl; 
			os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl; 
			os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
		}
	}
	
	if(ass_oper == "=")
	{
		std::string type; 
		if(unary_expr != NULL) {unary_expr->get_type(type);}
		if(type == "array")
		{
			lhs_tag="";
			rhs_tag="";
			unary_expr->get_tag(lhs_tag);
			ass_expr->get_tag(rhs_tag);
			
			os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl;
			os << "\tsw\t$" << TMP1 << ",0($" << TMP2 << ")" << std::endl;  	

			os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl;
		}
		else
		{
			lhs_tag="";
			rhs_tag="";
			unary_expr->get_tag(lhs_tag);
			ass_expr->get_tag(rhs_tag);
			
			os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl; 
			os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl;
		}
	}
	
	
	else if(ass_oper == "-=")
	{
		std::string type; 
		if(unary_expr != NULL) {unary_expr->get_type(type);}
		if(type == "array")
		{
			lhs_tag="";
			rhs_tag="";
			unary_expr->get_tag(lhs_tag);
			ass_expr->get_tag(rhs_tag);
			
			os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl;
			os << "\tlw\t$" << TMP3 << ",0($" << TMP2 << ")" << std::endl; 
			os << "\tsub\t$" << TMP3 << ",$" << TMP3 << ",$" << TMP1 << std::endl; 
			os << "\tsw\t$" << TMP3 << ",0($" << TMP2 << ")" << std::endl;  	

			os << "\tsw" << "\t$" << TMP3 << "," << OffsetMap[tag] << "($fp)" << std::endl;
		}
		else
		{
			lhs_tag="";
			rhs_tag="";
			unary_expr->get_tag(lhs_tag);
			ass_expr->get_tag(rhs_tag);
			os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl; 
			os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\tsub" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl; 
			os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl;
			os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
		}
	}
	
	else if(ass_oper == "*=")
	{
		std::string type; 
		if(unary_expr != NULL) {unary_expr->get_type(type);}
		if(type == "array")
		{
			lhs_tag="";
			rhs_tag="";
			unary_expr->get_tag(lhs_tag);
			ass_expr->get_tag(rhs_tag);
			
			os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl;
			os << "\tlw\t$" << TMP3 << ",0($" << TMP2 << ")" << std::endl; 
			os << "\tmul\t$" << TMP3 << ",$" << TMP3 << ",$" << TMP1 << std::endl; 
			os << "\tnop" << std::endl;
			os << "\tnop" << std::endl; 
			os << "\tsw\t$" << TMP3 << ",0($" << TMP2 << ")" << std::endl;  	

			os << "\tsw" << "\t$" << TMP3 << "," << OffsetMap[tag] << "($fp)" << std::endl;
		}
		else
		{
			lhs_tag="";
			rhs_tag="";
			unary_expr->get_tag(lhs_tag);
			ass_expr->get_tag(rhs_tag);
			os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl; 
			os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\tmul" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl; 
			os << "\tnop" << std::endl; 
			os << "\tnop" << std::endl; 
			os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl;
			os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
		}
	}
	
	else if(ass_oper == "/=")
	{
		std::string type; 
		if(unary_expr != NULL) {unary_expr->get_type(type);}
		if(type == "array")
		{
			lhs_tag="";
			rhs_tag="";
			unary_expr->get_tag(lhs_tag);
			ass_expr->get_tag(rhs_tag);
			
			os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl;
			os << "\tlw\t$" << TMP3 << ",0($" << TMP2 << ")" << std::endl; 
			os << "\tdiv\t$" << TMP3 << ",$" << TMP3 << ",$" << TMP1 << std::endl; 
			os << "\tnop" << std::endl; 
			os << "\tnop" << std::endl;
			os << "\tsw\t$" << TMP3 << ",0($" << TMP2 << ")" << std::endl;  	

			os << "\tsw" << "\t$" << TMP3 << "," << OffsetMap[tag] << "($fp)" << std::endl;
		}
		else
		{
			lhs_tag="";
			rhs_tag="";
			unary_expr->get_tag(lhs_tag);
			ass_expr->get_tag(rhs_tag);
			os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl; 
			os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\tdiv" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl; 
			os << "\tnop" << std::endl;
			os << "\tnop" << std::endl; 
			os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl;
			os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
		}
	}

	else if(ass_oper == "%=")
	{
		std::string type; 
		if(unary_expr != NULL) {unary_expr->get_type(type);}
		if(type == "array")
		{
			lhs_tag="";
			rhs_tag="";
			unary_expr->get_tag(lhs_tag);
			ass_expr->get_tag(rhs_tag);
			
			os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl;
			os << "\tlw\t$" << TMP3 << ",0($" << TMP2 << ")" << std::endl; 
			os << "\trem\t$" << TMP3 << ",$" << TMP3 << ",$" << TMP1 << std::endl; 
			os << "\tnop" << std::endl; 
			os << "\tnop" << std::endl; 
			os << "\tsw\t$" << TMP3 << ",0($" << TMP2 << ")" << std::endl;  	

			os << "\tsw" << "\t$" << TMP3 << "," << OffsetMap[tag] << "($fp)" << std::endl;
		}
		else
		{
			lhs_tag="";
			rhs_tag="";
			unary_expr->get_tag(lhs_tag);
			ass_expr->get_tag(rhs_tag);
			os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl; 
			os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\trem" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl; 
			os << "\tnop" << std::endl; 
			os << "\tnop" << std::endl; 
			os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl;
			os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
		}
	}

	else if(ass_oper == "<<=")
	{
		std::string type; 
		if(unary_expr != NULL) {unary_expr->get_type(type);}
		if(type == "array")
		{
			lhs_tag="";
			rhs_tag="";
			unary_expr->get_tag(lhs_tag);
			ass_expr->get_tag(rhs_tag);
			
			os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl;
			os << "\tlw\t$" << TMP3 << ",0($" << TMP2 << ")" << std::endl; 
			os << "\tsllv\t$" << TMP3 << ",$" << TMP3 << ",$" << TMP1 << std::endl; 
			os << "\tsw\t$" << TMP3 << ",0($" << TMP2 << ")" << std::endl;  	

			os << "\tsw" << "\t$" << TMP3 << "," << OffsetMap[tag] << "($fp)" << std::endl;
		}
		else
		{
			lhs_tag="";
			rhs_tag="";
			unary_expr->get_tag(lhs_tag);
			ass_expr->get_tag(rhs_tag);
			os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl; 
			os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\tsllv" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl; 
			os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl;
			os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
		}
	}

	else if(ass_oper == ">>=")
	{
		std::string type; 
		if(unary_expr != NULL) {unary_expr->get_type(type);}
		if(type == "array")
		{
			lhs_tag="";
			rhs_tag="";
			unary_expr->get_tag(lhs_tag);
			ass_expr->get_tag(rhs_tag);
			
			os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl;
			os << "\tlw\t$" << TMP3 << ",0($" << TMP2 << ")" << std::endl; 
			os << "\tsrav\t$" << TMP3 << ",$" << TMP3 << ",$" << TMP1 << std::endl; 
			os << "\tsw\t$" << TMP3 << ",0($" << TMP2 << ")" << std::endl;  	

			os << "\tsw" << "\t$" << TMP3 << "," << OffsetMap[tag] << "($fp)" << std::endl;
		}
		else
		{
			lhs_tag="";
			rhs_tag="";
			unary_expr->get_tag(lhs_tag);
			ass_expr->get_tag(rhs_tag);
			os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl; 
			os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\tsrav" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl; 
			os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl;
			os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
		}
	}

	else if(ass_oper == "&=")
	{
		std::string type; 
		if(unary_expr != NULL) {unary_expr->get_type(type);}
		if(type == "array")
		{
			lhs_tag="";
			rhs_tag="";
			unary_expr->get_tag(lhs_tag);
			ass_expr->get_tag(rhs_tag);
			
			os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl;
			os << "\tlw\t$" << TMP3 << ",0($" << TMP2 << ")" << std::endl; 
			os << "\tand\t$" << TMP3 << ",$" << TMP3 << ",$" << TMP1 << std::endl; 
			os << "\tsw\t$" << TMP3 << ",0($" << TMP2 << ")" << std::endl;  	

			os << "\tsw" << "\t$" << TMP3 << "," << OffsetMap[tag] << "($fp)" << std::endl;
		}
		else
		{
			lhs_tag="";
			rhs_tag="";
			unary_expr->get_tag(lhs_tag);
			ass_expr->get_tag(rhs_tag);
			os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl; 
			os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\tand" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl; 
			os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl;
			os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
		}
	}

	else if(ass_oper == "^=")
	{
		std::string type; 
		if(unary_expr != NULL) {unary_expr->get_type(type);}
		if(type == "array")
		{
			lhs_tag="";
			rhs_tag="";
			unary_expr->get_tag(lhs_tag);
			ass_expr->get_tag(rhs_tag);
			
			os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl;
			os << "\tlw\t$" << TMP3 << ",0($" << TMP2 << ")" << std::endl; 
			os << "\txor\t$" << TMP3 << ",$" << TMP3 << ",$" << TMP1 << std::endl; 
			os << "\tsw\t$" << TMP3 << ",0($" << TMP2 << ")" << std::endl;  	

			os << "\tsw" << "\t$" << TMP3 << "," << OffsetMap[tag] << "($fp)" << std::endl;
		}
		else
		{
			lhs_tag="";
			rhs_tag="";
			unary_expr->get_tag(lhs_tag);
			ass_expr->get_tag(rhs_tag);
			os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl; 
			os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\txor" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl; 
			os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl;
			os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
		}
	}

	else if(ass_oper == "|=")
	{
		std::string type; 
		if(unary_expr != NULL) {unary_expr->get_type(type);}
		if(type == "array")
		{
			lhs_tag="";
			rhs_tag="";
			unary_expr->get_tag(lhs_tag);
			ass_expr->get_tag(rhs_tag);
			
			os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl;
			os << "\tlw\t$" << TMP3 << ",0($" << TMP2 << ")" << std::endl; 
			os << "\tor\t$" << TMP3 << ",$" << TMP3 << ",$" << TMP1 << std::endl; 
			os << "\tsw\t$" << TMP3 << ",0($" << TMP2 << ")" << std::endl;  	

			os << "\tsw" << "\t$" << TMP3 << "," << OffsetMap[tag] << "($fp)" << std::endl;
		}
		else
		{
			lhs_tag="";
			rhs_tag="";
			unary_expr->get_tag(lhs_tag);
			ass_expr->get_tag(rhs_tag);
			os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl; 
			os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\tor" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl; 
			os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl;
			os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
		}
	}

	if(unary_expr != NULL) {unary_expr->set_modify(false);}
}
void AssExpr::get_tag(std::string& _tag)
{
	if(ass_oper != "") _tag = tag; 
	else if(unary_expr != NULL && _tag == "") unary_expr->get_tag(_tag); 
	else if(ass_expr != NULL && _tag == "") ass_expr->get_tag(_tag); 
	else if(cond_expr != NULL && _tag == "") cond_expr->get_tag(_tag);
}
void AssExpr::get_max_arguments(int& _offset)
{
	int ce=0, ue=0, ae=0; 
	std::vector<int> tmp; 
	if(cond_expr != NULL) 
	{
		cond_expr->get_max_arguments(ce);
		tmp.push_back(ce); 
	}
	if(unary_expr != NULL) 
	{
		unary_expr->get_max_arguments(ue);
		tmp.push_back(ue); 
	}
	if(ass_expr != NULL) 
	{
		ass_expr->get_max_arguments(ae);
		tmp.push_back(ae); 
	}
	
	if(!tmp.empty())
	{
		std::vector<int>::iterator i1; 
		i1 = std::max_element(tmp.begin(), tmp.end());
		std::cerr << "MAX1: " << *i1 << std::endl; 
		_offset = *i1;
		/*
		int max = tmp[0]; 
		for(int i=0; i<tmp.size(); i++)
		{
			std::cerr << tmp[i] << std::endl; 
			if(tmp[i] > max) 
			{
				max = tmp[i]; 
			}
		}
		std::cerr << "MAX1: " << max << std::endl; 
		_offset = max;
		*/
	}
}

CondExpr::CondExpr(Expression* _expression, IfElseExpr* _ie_expr) : expression(_expression), ie_expr(_ie_expr)
{
//	if(ie_expr != NULL) {tag = set_offset();}
}
void CondExpr::print()
{
	if(expression != NULL)
	{
		expression->print(); 
	}
	if(ie_expr != NULL)
	{
		ie_expr->print(); 
	}
}
void CondExpr::generate_code()
{
	//if(ie_expr != NULL) {tag = set_offset();}
	if(expression != NULL) {expression->generate_code();}
	if(ie_expr != NULL) {ie_expr->generate_code();}
}
void CondExpr::get_tag(std::string& _tag)
{
	if(ie_expr != NULL) {ie_expr->get_tag(_tag);} 
	else if(expression != NULL && _tag == "") expression->get_tag(_tag);
}
void CondExpr::get_max_arguments(int& _offset)
{
	if(expression != NULL) {expression->get_max_arguments(_offset);}	
}

PrimExpr::PrimExpr(std::string _value, int _flag, Expr* _e) : value(_value), expr(_e), flag(_flag) {}
void PrimExpr::print()
{
	if(value != "")
	{
		std::cerr << value << " ";
	}
	if(expr != NULL)
	{
		expr->print(); 
	}
}
void PrimExpr::generate_code() 
{
	int index = -1;
	if(value != "")
	{
		if(VarTagMap[value].empty())
		{
			std::cerr << "empty" << std::endl; 
			tag = set_offset();
			VarTagMap[value].resize(global_scope + 1); 
			VarTagMap[value][global_scope] = tag;
			index = global_scope;
		}
		else
		{
			std::cerr << "not empty" << std::endl;
			std::cerr << global_scope << std::endl; 
			std::cerr << VarTagMap[value].size() << std::endl;
			for(int i=global_scope; i>=0; i--)
			{
				if(i < VarTagMap[value].size())
				{
					if(!VarTagMap[value][i].empty())
					{
						tag = VarTagMap[value][i];
						index = i;
						break;
					}
				}
			}
			if(index == -1)
			{
				tag = set_offset(); 
				VarTagMap[value][global_scope] = tag; 
				index = global_scope; 
			}
		}
		std::cerr << "TAG = " << tag << std::endl; 
		std::cerr << "VAL = " << value << std::endl;
		std::cerr << global_scope << std::endl;
		std::cerr << std::endl; 
	}


	if (expr != NULL) 
	{
		expr->generate_code();
	}
	else
	{
		//os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[VarTagMap[value][global_scope]] << "($fp)" << std::endl; 
 		switch(flag)
		{
			case 1:
				os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[VarTagMap[value][index]] << "($fp)" << std::endl; 
				os << "\tli" << "\t$" << TMP1 << "," << std::stoi(value,NULL,10) << std::endl;
				os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[VarTagMap[value][index]] << "($fp)" << std::endl;
				break;
			case 2:
				os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[VarTagMap[value][index]] << "($fp)" << std::endl; 
				os << "\tli" << "\t$" << TMP1 << "," << std::stoi(value,NULL,8) << std::endl;  
				os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[VarTagMap[value][index]] << "($fp)" << std::endl;
				break;
			case 3: 
				os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[VarTagMap[value][index]] << "($fp)" << std::endl; 
				os << "\tli" << "\t$" << TMP1 << "," << std::stoi(value,NULL,16) << std::endl;  
				os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[VarTagMap[value][index]] << "($fp)" << std::endl;
				break;
			default:
				break;
		}
		//os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[VarTagMap[value][global_scope]] << "($fp)" << std::endl;
	}

}
void PrimExpr::get_tag(std::string& _tag)
{
	if(expr == NULL) {_tag = tag;}
	if(expr != NULL) {expr->get_tag(_tag);}
}
std::string PrimExpr::get_id()
{
	return value; 
}


CompStat::CompStat(StatList* _stat_list, DeclList* _decl_list) : stat_list(_stat_list), decl_list(_decl_list) 
{
	scope = global_scope;
}
void CompStat::print()
{
	if(decl_list != NULL)
	{
		decl_list->print();
	}
	if(stat_list != NULL)
	{
		stat_list->print(); 
	}
}
void CompStat::generate_code()
{
	global_scope++;

	if(decl_list != NULL){decl_list->generate_code();}
	if(stat_list != NULL){stat_list->generate_code();}
	//resize all vectors everytime we exit a scope so that past variables in deepr scopes aren't kept
	for(std::map<Tag,std::vector<Tag> >::iterator it = VarTagMap.begin(); it != VarTagMap.end(); ++it)
	{
		it->second.resize(global_scope); 
	}
	
	global_scope--;
}
void CompStat::get_max_arguments(int& _offset)
{
	if(stat_list != NULL){stat_list->get_max_arguments(_offset);}
}


DeclList::DeclList(Decl* _decl, DeclList* _decl_list) : decl(_decl), decl_list(_decl_list) {}
void DeclList::print()
{
	if(decl != NULL)
	{
		decl->print();
	}
	if(decl_list != NULL)
	{
		decl_list->print(); 
	}
}
void DeclList::generate_code()
{
	if(decl != NULL){decl->generate_code();}
	if(decl_list != NULL){decl_list->generate_code();}
}

StatList::StatList(Stat* _stat, StatList* _stat_list) : stat(_stat), stat_list(_stat_list) {}
void StatList::print()
{
	if(stat != NULL)
	{
		stat->print(); 
	}
	if(stat_list != NULL)
	{
		stat_list->print(); 
	}
}
void StatList::generate_code()
{
	if(stat != NULL) {stat->generate_code();}
	if(stat_list != NULL) {stat_list->generate_code();}
}
void StatList::get_max_arguments(int& _offset)
{
	int current_scope_count = 0; 
	if(stat != NULL){stat->get_max_arguments(current_scope_count);}
	if(current_scope_count > _offset) {_offset = current_scope_count;}
	if(stat_list != NULL) {stat_list->get_max_arguments(_offset);}
}

/*
Stat::Stat(CompStat* _comp_stat, ExprStat* _expr_stat, SelecStat* _selec_stat, LoopStat* _loop_stat, JumpStat* _jump_stat) : comp_stat(_comp_stat), expr_stat(_expr_stat), selec_stat(_selec_stat), loop_stat(_loop_stat), jump_stat(_jump_stat) {}
void Stat::print()
{
	if(comp_stat != NULL)
	{
		comp_stat->print(); 
	}
	if(expr_stat != NULL)
	{
		expr_stat->print(); 
	}
	if(selec_stat != NULL)
	{
		selec_stat->print(); 
	}
	if(loop_stat != NULL)
	{
		loop_stat->print(); 
	}
	if(jump_stat != NULL)
	{
		jump_stat->print(); 
	}
}
void Stat::generate_code()
{
	if(comp_stat != NULL) {comp_stat->generate_code();}
	if(expr_stat != NULL) {expr_stat->generate_code();}
}
*/

JumpStat::JumpStat(Expr* _expr, std::string _type) : expr(_expr), type(_type) {} 
void JumpStat::generate_code()
{
	if(type == "return")
	{	
		if(expr != NULL)
		{
			expr->generate_code();
			os << "\tlw\t"<< "$2,";
			std::string return_tag; 
			expr->get_tag(return_tag); 
			os << OffsetMap[return_tag] << "($fp)" << std::endl; 
		}
		else
		{
			os << "\tmove\t$2," << "$0" << std::endl; 
		}
		
	}

	if(type == "break")
	{
		os << "\tj\t" << "break_" << Breaks.back() << std::endl;  
	}
}
void JumpStat::get_max_arguments(int& _offset) 
{
	if(expr != NULL) {expr->get_max_arguments(_offset);}	
}

ExprStat::ExprStat(Expr* _expr) : expr(_expr) {}
void ExprStat::print()
{
	if(expr != NULL)
	{
		expr->print();
	}
}
void ExprStat::generate_code()
{
	if(expr != NULL) {expr->generate_code();}
}
void ExprStat::get_tag(std::string& _tag)
{
	if(expr != NULL) {expr->get_tag(_tag);}
}
void ExprStat::get_max_arguments(int& _offset)
{
	if(expr != NULL){expr->get_max_arguments(_offset);}
}

Expression::Expression(Expression* _lhs, Expression* _rhs, std::string _op, UnaryExpr* _unary_expr) : lhs(_lhs), rhs(_rhs), op(_op), unary_expr(_unary_expr) {}
void Expression::get_tag(std::string& _tag)
{
	if(op != "") _tag = tag; 
	else if(lhs != NULL && _tag == "") lhs->get_tag(_tag); 
	else if(rhs != NULL && _tag == "") rhs->get_tag(_tag); 
	else if(unary_expr != NULL && _tag == "") unary_expr->get_tag(_tag);
}
void Expression::print()
{
	if(op != "")
	{
		std::cerr << op << " "; 
	}
	if(lhs != NULL)
	{
		lhs->print(); 
	}
	if(unary_expr != NULL)
	{
		unary_expr->print();
	}
	if(rhs != NULL)
	{
		rhs->print(); 
	}
}
void Expression::generate_code()
{
	if(op !="") {tag = set_offset();}
	
	std::string tag_lhs="";
	std::string tag_rhs="";
	std::string tag_unary="";
	
	if(op != "")
	{
		std::cerr << "Tag = " << tag << std::endl; 
		std::cerr << "OP = " << op << std::endl;
		if(lhs != NULL) lhs->get_tag(tag_lhs); 
		if(rhs != NULL)	rhs->get_tag(tag_rhs); 
		std::cerr << "left = " << tag_lhs << std::endl; 
		std::cerr << "right = " << tag_rhs << std::endl; 
		std::cerr << "unary = " << tag_unary << std::endl; 
		std::cerr << std::endl; 
	}
	
	tag_lhs = "";
	tag_rhs = "";
	tag_unary = ""; 

	//std::stringstream ss; 
	if(rhs != NULL)
	{
		rhs->generate_code();
	}
	if(unary_expr != NULL)
	{
		std::cerr << "CALLING UNARY" << std::endl; 
		unary_expr->generate_code();
	}
	if(lhs != NULL)
	{
		lhs->generate_code();
	}
	
	if(op == "+")
	{
		if(lhs != NULL) lhs->get_tag(tag_lhs);
		if(rhs != NULL) rhs->get_tag(tag_rhs);

		os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[tag_lhs] << "($fp)" << std::endl; 
		os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[tag_rhs] << "($fp)" << std::endl; 
		os << "\tadd" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl; 
		os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
		
	}

	if(op == "-")
	{
		if(lhs != NULL)	lhs->get_tag(tag_lhs);
		if(rhs != NULL)	rhs->get_tag(tag_rhs);

		os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[tag_lhs] << "($fp)" << std::endl; 
		os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[tag_rhs] << "($fp)" << std::endl; 
		os << "\tsub" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl; 
		os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
	}

	if(op == "*")
	{
		if(lhs != NULL) lhs->get_tag(tag_lhs);
		if(unary_expr != NULL) unary_expr->get_tag(tag_rhs);

		os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[tag_lhs] << "($fp)" << std::endl; 
		os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[tag_rhs] << "($fp)" << std::endl; 
		os << "\tmult" << "\t$" << TMP1 << ",$" << TMP2 << std::endl; 
		os << "\tmflo" << "\t$" << TMP1 << std::endl;
		os << "\tnop" << std::endl; 
		os << "\tnop" << std::endl; 
		os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
	}

	if(op == "/")
	{
		if(lhs != NULL) lhs->get_tag(tag_lhs);
		if(unary_expr != NULL) unary_expr->get_tag(tag_rhs);

		os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[tag_lhs] << "($fp)" << std::endl; 
		os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[tag_rhs] << "($fp)" << std::endl; 
		os << "\tdiv" << "\t$" << TMP1 << ",$" << TMP2 << std::endl; 
		os << "\tmflo" << "\t$" << TMP1 << std::endl;
		os << "\tnop" << std::endl; 
		os << "\tnop" << std::endl; 
		os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
	}
	
	if(op == "%")
	{
		lhs->get_tag(tag_lhs);
		unary_expr->get_tag(tag_rhs);

		os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[tag_lhs] << "($fp)" << std::endl; 
		os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[tag_rhs] << "($fp)" << std::endl; 
		os << "\tdiv" << "\t$" << TMP1 << ",$" << TMP2 << std::endl; 
		os << "\tmfhi" << "\t$" << TMP1 << std::endl;
		os << "\tnop" << std::endl; 
		os << "\tnop" << std::endl; 
		os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
	}

	if(op == "<<")
	{
		lhs->get_tag(tag_lhs);
		rhs->get_tag(tag_rhs);

		os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[tag_lhs] << "($fp)" << std::endl; 
		os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[tag_rhs] << "($fp)" << std::endl; 
		os << "\tsllv" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl; 
		os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
	}

	if(op == ">>")
	{
		lhs->get_tag(tag_lhs);
		rhs->get_tag(tag_rhs);

		os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[tag_lhs] << "($fp)" << std::endl; 
		os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[tag_rhs] << "($fp)" << std::endl; 
		os << "\tsrav" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl; 
		os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
	}

	if(op == "<")
	{
		lhs->get_tag(tag_lhs);
		rhs->get_tag(tag_rhs);

		os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[tag_lhs] << "($fp)" << std::endl; 
		os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[tag_rhs] << "($fp)" << std::endl; 
		os << "\tslt" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl; 
		os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
	}
	
	if(op == ">")
	{
		lhs->get_tag(tag_lhs);
		rhs->get_tag(tag_rhs);

		os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[tag_lhs] << "($fp)" << std::endl; 
		os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[tag_rhs] << "($fp)" << std::endl; 
		os << "\tsgt" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl; 
		os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
	}

	if(op == "<=")
	{
		lhs->get_tag(tag_lhs);
		rhs->get_tag(tag_rhs);

		os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[tag_lhs] << "($fp)" << std::endl; 
		os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[tag_rhs] << "($fp)" << std::endl; 
		os << "\tsge" << "\t$" << TMP1 << ",$" << TMP2 << ",$" << TMP1 << std::endl; 
		os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
	}

	if(op == ">=")
	{
		lhs->get_tag(tag_lhs);
		rhs->get_tag(tag_rhs);

		os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[tag_lhs] << "($fp)" << std::endl; 
		os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[tag_rhs] << "($fp)" << std::endl; 
		os << "\tsge" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl; 
		os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
	}

	if(op == "==")
	{
		lhs->get_tag(tag_lhs);
		rhs->get_tag(tag_rhs);

		os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[tag_lhs] << "($fp)" << std::endl; 
		os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[tag_rhs] << "($fp)" << std::endl; 
		os << "\tseq" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl; 
		os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
	}
	
	if(op == "!=")
	{
		lhs->get_tag(tag_lhs);
		rhs->get_tag(tag_rhs);

		os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[tag_lhs] << "($fp)" << std::endl; 
		os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[tag_rhs] << "($fp)" << std::endl; 
		os << "\tsne" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl; 
		os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
	}
	
	if(op == "&")
	{
		lhs->get_tag(tag_lhs);
		rhs->get_tag(tag_rhs);

		os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[tag_lhs] << "($fp)" << std::endl; 
		os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[tag_rhs] << "($fp)" << std::endl; 
		os << "\tand" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl; 
		os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
	}

	if(op == "^")
	{
		lhs->get_tag(tag_lhs);
		rhs->get_tag(tag_rhs);

		os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[tag_lhs] << "($fp)" << std::endl; 
		os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[tag_rhs] << "($fp)" << std::endl; 
		os << "\txor" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl; 
		os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
	}

	if(op == "|")
	{
		lhs->get_tag(tag_lhs);
		rhs->get_tag(tag_rhs);

		os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[tag_lhs] << "($fp)" << std::endl; 
		os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[tag_rhs] << "($fp)" << std::endl; 
		os << "\tor" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl; 
		os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
	}

	if(op == "&&")
	{
		lhs->get_tag(tag_lhs);
		rhs->get_tag(tag_rhs);

		os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[tag_lhs] << "($fp)" << std::endl; 
		os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[tag_rhs] << "($fp)" << std::endl; 
		os << "\tsne" << "\t$" << TMP1 << ",$" << TMP1 << ",0" << std::endl; 
		os << "\tsne" << "\t$" << TMP2 << ",$" << TMP2 << ",0" << std::endl;
		os << "\tand" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl;
		os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
	}

	if(op == "||")
	{
		lhs->get_tag(tag_lhs);
		rhs->get_tag(tag_rhs);

		os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[tag_lhs] << "($fp)" << std::endl; 
		os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[tag_rhs] << "($fp)" << std::endl; 
		os << "\tsne" << "\t$" << TMP1 << ",$" << TMP1 << ",0" << std::endl; 
		os << "\tsne" << "\t$" << TMP2 << ",$" << TMP2 << ",0" << std::endl;
		os << "\tor" << "\t$" << TMP1 << ",$" << TMP1 << ",$" << TMP2 << std::endl;
		os << "\tsw" << "\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
	}
}
void Expression::get_max_arguments(int& _offset)
{
	int l=0, r=0, ue=0; 
	std::vector<int> tmp; 
	if(lhs != NULL)
	{
		lhs->get_max_arguments(l);
		tmp.push_back(l); 
	}
	if(rhs != NULL)
	{
		rhs->get_max_arguments(r);
		tmp.push_back(r); 
	}
	if(unary_expr != NULL) 
	{
		unary_expr->get_max_arguments(ue);
		tmp.push_back(ue); 
	}
	
	if(!tmp.empty())
	{
		std::vector<int>::iterator i1; 
		i1 = std::max_element(tmp.begin(), tmp.end());
		std::cerr << "MAX2: " << *i1 << std::endl; 
		_offset = *i1;
		/*
		int max = tmp[0]; 
		for(int i=0; i<tmp.size(); i++)
		{
			std::cerr << tmp[i] << std::endl; 
			if(tmp[i] > max) 
			{
				max = tmp[i]; 
			}
		}
		std::cerr << "MAX2: " << max << std::endl; 
		_offset = max;
		*/
	}
}

UnaryExpr::UnaryExpr(PostFixExpr* _post_fix_expr, UnaryExpr* _unary_expr, std::string _unary_op) : post_fix_expr(_post_fix_expr), unary_expr(_unary_expr), unary_op(_unary_op) {}
void UnaryExpr::print()
{
	if(post_fix_expr != NULL)
	{
		post_fix_expr->print();
	}

	if(unary_op != "")
	{
		std::cerr << unary_op << " ";
	}

	if(unary_expr != NULL)
	{
		unary_expr->print(); 
	}
}
void UnaryExpr::generate_code()
{
	if(post_fix_expr != NULL) {post_fix_expr->generate_code();}
	
	if(unary_expr != NULL)
	{
		tag = set_offset(); 
		std::cerr << "UNEXP: " << tag << std::endl; 
		unary_expr->generate_code(); 
		std::string rhs_tag; 
		unary_expr->get_tag(rhs_tag);

		if(unary_op == "++")
		{
			os << "\tlw\t$" << TMP1 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\taddi\t$" << TMP1 << ",$" << TMP1 << ",1" << std::endl; 
			os << "\tsw\t$" << TMP1 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl;  
			os << "\tsw\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl;  
		}
		if(unary_op == "--")
		{
			os << "\tlw\t$" << TMP1 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl; 
			os << "\taddi\t$" << TMP1 << ",$" << TMP1 << ",-1" << std::endl; 
			os << "\tsw\t$" << TMP1 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl;  
			os << "\tsw\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl;  
		}
		if(unary_op == "-")
		{
			os << "\tlw\t$" << TMP1 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl;
			os << "\tneg\t$" << TMP1 << ",$" << TMP1 << std::endl;
			os << "\tsw\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
		}
		if(unary_op == "+")
		{
			os << "\tlw\t$" << TMP1 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl;
			os << "\tsw\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
		}
		if(unary_op == "~")
		{
			os << "\tlw\t$" << TMP1 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl;
			os << "\tnot\t$" << TMP1 << ",$" << TMP1 << std::endl;
			os << "\tsw\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
		}
		if(unary_op == "!")
		{
			os << "\tlw\t$" << TMP1 << "," << OffsetMap[rhs_tag] << "($fp)" << std::endl;
			os << "\tmovn\t$" << TMP3 << ",$0,$" << TMP1 << std::endl;
			os << "\tli\t$" << TMP2 << ",1" << std::endl; 
			os << "\tmovz\t$" << TMP3 << ",$" << TMP2 << ",$" << TMP1 << std::endl; 
			os << "\tsw\t$" << TMP3 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
		}
	}
}
void UnaryExpr::get_tag(std::string& _tag)
{
	if(unary_expr != NULL) {_tag = tag;}
	if(post_fix_expr != NULL)
	{
		//if(_tag == "")
			post_fix_expr->get_tag(_tag); 
	}
}
void UnaryExpr::get_max_arguments(int& _offset)
{
	int pe=0, ue=0;
	if(post_fix_expr != NULL) {post_fix_expr->get_max_arguments(pe);}
	if(unary_expr != NULL) {unary_expr->get_max_arguments(ue);}

	if(pe > ue) {_offset = pe;}
	else {_offset = ue;}
}
void UnaryExpr::get_type(std::string& _type)
{
	if(post_fix_expr != NULL) {post_fix_expr->get_type(_type);}
}
void UnaryExpr::set_modify(bool status)
{
	if(post_fix_expr != NULL) {post_fix_expr->set_modify(status);}
}

PostFixExpr::PostFixExpr(PrimExpr* _prim_expr, PostFixExpr* _post_fix_expr, std::string _op, ArgList* _arg_list, Expr* _expr, bool _is_array) : prim_expr(_prim_expr), post_fix_expr(_post_fix_expr), op(_op), arg_list(_arg_list), expr(_expr), modify(false), is_array(_is_array) {}
void PostFixExpr::print()
{
	if(prim_expr != NULL)
	{
		prim_expr->print(); 
	}
	if(post_fix_expr != NULL)
	{
		post_fix_expr->print(); 
	}
	if(op != "")
	{
		std::cerr << op << " ";
	}
}
void PostFixExpr::generate_code()
{
	if(prim_expr != NULL){prim_expr->generate_code();}
	if(post_fix_expr != NULL) {post_fix_expr->generate_code();}
	if(arg_list != NULL) 
	{
		tag = set_offset();
		
		num_arguments = 0; 
		arg_list->generate_code();

		os << "\tla\t$" << TMP1 << "," << post_fix_expr->get_id() << std::endl; 
		os << "\tjalr\t$" << TMP1 << std::endl; 
		os << "\tnop" << std::endl; 
		/*
		os << "\tjal\t" << post_fix_expr->get_id() << std::endl; 
		os << "\tnop" << std::endl; 
		*/
		os << "\tsw\t$2," << OffsetMap[tag] << "($fp)" << std::endl;  
	}
	if(op != "")
	{
		tag = set_offset();
		
		std::cerr << "PFEXPR: " << tag << std::endl; 

		std::string lhs_tag; 
		if(post_fix_expr != NULL) {post_fix_expr->get_tag(lhs_tag);}

		std::cerr << "TAG: " << tag << std::endl; 
		std::cerr << "OP: " << op << std::endl; 
		std::cerr << "LHS: " << lhs_tag << std::endl;
		std::cerr << std::endl;

		if(op == "++")
		{
			os << "\tlw\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl; 
			os << "\tsw\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl;  
			os << "\taddi\t$" << TMP1 << ",$" << TMP1 << ",1" << std::endl; 
			os << "\tsw\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl;  
		}
		if(op == "--")
		{
			os << "\tlw\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl; 
			os << "\tsw\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl;  
			os << "\taddi\t$" << TMP1 << ",$" << TMP1 << ",-1" << std::endl; 
			os << "\tsw\t$" << TMP1 << "," << OffsetMap[lhs_tag] << "($fp)" << std::endl;  
		}
	}
	if(/*expr != NULL*/is_array)
	{
		tag = set_offset();

		expr->generate_code(); 
		std::string e_tag; 
		expr->get_tag(e_tag);
		os << "\tlw\t$" << TMP1 << "," << OffsetMap[e_tag] << "($fp)" << std::endl; 

		std::string pe_tag; 
		post_fix_expr->get_tag(pe_tag);
		os << "\tla\t$" << ARR_REG << ",arr_" << OffsetMap[pe_tag] << std::endl;
		os << "\tsll\t$" << TMP1 << ",$" << TMP1 << ",2" << std::endl; 
		os << "\tadd\t$" << ARR_REG << ",$" << ARR_REG << ",$" << TMP1 << std::endl;
		if(modify)
		{
			os << "\tsw\t$" << ARR_REG << "," << OffsetMap[tag] << "($fp)" << std::endl; 
		}
		else
		{
			os << "\tlw\t$" << TMP1 << ",0($" << ARR_REG << ")" << std::endl; 
			os << "\tsw\t$" << TMP1 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
		}
	}
}
void PostFixExpr::get_tag(std::string& _tag)
{
	if(op != "") {_tag = tag;}
	if(arg_list != NULL) {_tag = tag;}
	if(/*expr != NULL*/is_array){_tag = tag;}
	if(prim_expr != NULL) {prim_expr->get_tag(_tag);}
}
void PostFixExpr::get_max_arguments(int& _offset)
{
	if(arg_list != NULL) {arg_list->get_max_arguments(_offset);}
}
std::string PostFixExpr::get_id() 
{
	if(post_fix_expr != NULL) {return post_fix_expr->get_id();}
	if(prim_expr != NULL) {return prim_expr->get_id();}
}
void PostFixExpr::get_type(std::string& _type)
{
	if(/*expr != NULL*/is_array) {_type = "array";}
}
void PostFixExpr::set_modify(bool status)
{
	modify = status; 
}

ArgList::ArgList(AssExpr* _ass_expr, ArgList* _arg_list) : ass_expr(_ass_expr), arg_list(_arg_list)
{
/*
	if(ass_expr != NULL)
	{
		num_arg++;
	}
	else if(ass_expr == NULL)
	{
		if(num_arg > offset)
		{
			offset = num_arg; 
		}
		num_arg=0; 
	}
*/
}
void ArgList::generate_code()
{
	if(ass_expr != NULL) 
	{
		ass_expr->generate_code(); 
		std::string ass_tag = ""; 
		ass_expr->get_tag(ass_tag);
		
		if(IsArray[ass_tag]) {os << "\tla\t$" << TMP1 << "," << "arr_" << ass_tag << std::endl;}
		else{os << "\tlw\t$" << TMP1 << "," << OffsetMap[ass_tag] << "($fp)" << std::endl;}
	
		if(num_arguments < 4)
		{
			os << "\tmove\t$a" << num_arguments << ",$" << TMP1 << std::endl; 
		}
		os << "\tsw\t$" << TMP1 << "," << num_arguments*4 << "($fp)" << std::endl;
		
		num_arguments++; 
	}
	if(arg_list != NULL){arg_list->generate_code();}
}
void ArgList::get_max_arguments(int& _offset)
{
	if(arg_list != NULL){arg_list->get_max_arguments(_offset);}
	if(ass_expr != NULL) {_offset++;}
}

Expr::Expr(AssExpr* _ass_expr, Expr* _expr) : ass_expr(_ass_expr), expr(_expr) {}
void Expr::print() 
{
	if(ass_expr != NULL)
	{
		ass_expr->print();
		std::cerr << std::endl;
	}
	if(expr != NULL)
	{
		expr->print(); 
	}
}
void Expr::generate_code()
{
	if(expr != NULL) {expr->generate_code();}
	if(ass_expr != NULL) {ass_expr->generate_code();}
}
void Expr::get_tag(std::string& _tag)
{
	if(ass_expr != NULL) ass_expr->get_tag(_tag);
	if(expr != NULL) expr->get_tag(_tag); 
}
void Expr::get_max_arguments(int& _offset)
{
	int ae=0, e=0; 
	if(ass_expr != NULL) {ass_expr->get_max_arguments(ae);}
	if(expr != NULL) {expr->get_max_arguments(e);}

	if(ae > e) {_offset = ae;}
	else {_offset = e;}
}

LoopStat::LoopStat(ExprStat* _es1, ExprStat* _es2, Expr* _e, Stat* _s, DoStat* _ds) : expr_stat_1(_es1), expr_stat_2(_es2), expr(_e), stat(_s), do_stat(_ds) {}
void LoopStat::print()
{
	if(expr_stat_1 != NULL)
	{
		std::cerr << "for:" << std::endl;
		expr_stat_1->print(); 
	}
	if(expr_stat_2 != NULL)
	{
		expr_stat_2->print(); 
	}
	if(expr != NULL)
	{
		if(expr_stat_1 == NULL)
			std::cerr << "while:" << std::endl;
		expr->print(); 
		std::cerr << std::endl;
	}
	if(stat != NULL)
	{
		std::cerr << "\tbody:" << std::endl;
		stat->print(); 
	}
}
void LoopStat::generate_code()
{
	Breaks.push_back(++break_num);
	//increment loop number count
	int loop_num = glbl_loop_num; 
	//while loop
	if(expr_stat_1 == NULL)
	{
		if(expr != NULL)
		{
			loop_num++;
			glbl_loop_num++;
			os << "while_loop_" << loop_num << ":" << std::endl; 
			expr->generate_code(); 
			std::string tag_condition; 
			expr->get_tag(tag_condition); 
			os << "\tlw\t$" << TMP1 << "," << OffsetMap[tag_condition] << "($fp)" << std::endl; 
			os << "\tbeq\t$" << TMP1 << ",$0," << "end_loop_" << loop_num << std::endl;
			os << "\tnop" << std::endl; 
			if(stat != NULL) {stat->generate_code();}
			os << "\tb\t" << "while_loop_" << loop_num << std::endl; 
			os << "\tnop" << std::endl; 
			os << "end_loop_" << loop_num << ":" << std::endl; 
		}
	}
	//for loops
	else
	{
		loop_num++;
		glbl_loop_num++;
		expr_stat_1->generate_code();
		os << "for_loop_" << loop_num << ":" << std::endl; 
		if(expr_stat_2 != NULL) {expr_stat_2->generate_code();}
		std::string tag_condition = ""; 
		expr_stat_2->get_tag(tag_condition);
		os << "\tlw\t$" << TMP1 << "," << OffsetMap[tag_condition] << "($fp)" << std::endl; 
		os << "\tbeq\t$" << TMP1 << ",$0," << "end_loop_" << loop_num << std::endl;
		os << "\tnop" << std::endl;
		if(stat != NULL){stat->generate_code();}
		if(expr != NULL){expr->generate_code();}
		os << "\tb\t" << "for_loop_" << loop_num << std::endl;
		os << "\tnop" << std::endl; 
		os << "end_loop_" << loop_num << ":" << std::endl; 
	}
	//do while loop
	if(do_stat != NULL)
	{
		loop_num++;
		glbl_loop_num++;
		do_stat->generate_code();
	}
	
	loop_num--;
	os << "break_" << Breaks.back() << ":" << std::endl;
	Breaks.pop_back();
}
void LoopStat::get_max_arguments(int& _offset) 
{
	int es1=0, es2=0, e=0, s=0, ds=0; 
	std::vector<int> tmp; 
	if(expr_stat_1 != NULL)
	{
		expr_stat_1->get_max_arguments(es1);
		tmp.push_back(es1);
	}
	if(expr_stat_2 != NULL)
	{
		expr_stat_2->get_max_arguments(es2);
		tmp.push_back(es2);
	}
	if(expr != NULL)
	{
		expr->get_max_arguments(e);
		tmp.push_back(e);
	}
	if(stat != NULL)
	{
		stat->get_max_arguments(s);
		tmp.push_back(s);
	}
	if(do_stat != NULL)
	{
		do_stat->get_max_arguments(ds);
		tmp.push_back(ds); 
	}

	if(!tmp.empty())
	{
		std::vector<int>::iterator i1; 
		i1 = std::max_element(tmp.begin(), tmp.end());
		std::cerr << "MAX3: " << *i1 << std::endl; 
		_offset = *i1;
	}
}

DoStat::DoStat(Stat* _stat, Expr* _expr) : stat(_stat), expr(_expr) {}
void DoStat::print() 
{
	if(stat != NULL)
	{
		std::cerr << "do:" << std::endl; 
		stat->print(); 
	}
	if(expr != NULL)
	{
		std::cerr << "while:" << std::endl;
		expr->print(); 
	}
}
void DoStat::generate_code()
{
	if(expr != NULL)
	{
		os << "dw_loop_" << glbl_loop_num << ":" << std::endl; 
		if(stat != NULL) {stat->generate_code();}
		expr->generate_code(); 
		std::string tag_condition; 
		expr->get_tag(tag_condition); 
		os << "\tlw\t$" << TMP1 << "," << OffsetMap[tag_condition] << "($fp)" << std::endl; 
		os << "\tbne\t$" << TMP1 << ",$0," << "dw_loop_" << glbl_loop_num << std::endl;
		os << "\tnop" << std::endl; 
		//os << "end_loop_" << glbl_loop_num << ":" << std::endl; 
	}
}
void DoStat::get_max_arguments(int& _offset)
{
	int s=0, e=0;
	if(stat != NULL){stat->get_max_arguments(s);}
	if(expr != NULL){expr->get_max_arguments(e);}
	
	if(s > e){_offset = s;}
	else {_offset = e;}
}

SelecStat::SelecStat(Expr* _e, Stat* _si, Stat* _se, Stat* _s) : expr(_e), stat_if(_si), stat_else(_se), stat(_s) {}
void SelecStat::print() 
{
	if(expr != NULL)
	{
		std::cerr << "if: ";
		expr->print(); 
	}
	if(stat_if != NULL)
	{
		std::cerr << "\tbody:" << std::endl; 
		stat_if->print(); 
	}
	if(stat_else != NULL)
	{
		std::cerr << "else:" << std::endl;
		stat_else->print(); 
	}
}
void SelecStat::generate_code()
{
	int selec_num = glbl_selec_num; 
	if(stat_if != NULL)
	{
		selec_num++; 
		glbl_selec_num++;
		os << "if_" << selec_num << ":" << std::endl; 
		if(expr != NULL){expr->generate_code();}
		std::string tag_cond; 
		expr->get_tag(tag_cond);
		os << "\tlw\t$" << TMP1 << "," << OffsetMap[tag_cond] << "($fp)" << std::endl; 
		os << "\tbeq\t$" << TMP1 << ",$0," << "else_" << selec_num << std::endl;
		os << "\tnop" << std::endl;
		stat_if->generate_code();
		os << "\tb\t" << "if_out_" << selec_num << std::endl; 
		os << "else_" << selec_num << ":" << std::endl; 
	}
	if(stat_else != NULL)
	{
		//selec_num++;
		//glbl_selec_num++;
		stat_else->generate_code();
	}
	if(stat == NULL)
	{
		os << "if_out_" << selec_num << ":" << std::endl; 
		selec_num--;
	}
	else if(stat != NULL)
	{
		Breaks.push_back(++break_num);
		if(expr != NULL) 
		{
			expr->generate_code();
		}
		std::string e_tag; 
		expr->get_tag(e_tag);
		os << "\tlw\t$" << CASE_REG << "," << OffsetMap[e_tag] << "($fp)" << std::endl; 

		cases = true; 
		int curr_case_num = case_num; 
		stat->generate_code();
		
		cases = false;
		case_num = curr_case_num; 
		stat->generate_code();

		os << "break_" << Breaks.back() << ":" << std::endl;
		Breaks.pop_back();
	}
}
void SelecStat::get_max_arguments(int& _offset) 
{
	int e=0, si=0, se=0; 
	std::vector<int> tmp; 
	if(expr != NULL)
	{
		expr->get_max_arguments(e);
		tmp.push_back(e); 
	}
	if(stat_if != NULL)
	{
		stat_if->get_max_arguments(si);
		tmp.push_back(si);
	}
	if(stat_else != NULL)
	{
		stat_else->get_max_arguments(se);
		tmp.push_back(se); 
	}
	
	if(!tmp.empty())
	{
		std::vector<int>::iterator i1; 
		i1 = std::max_element(tmp.begin(), tmp.end());
		std::cerr << "MAX4: " << *i1 << std::endl; 
		_offset = *i1;
		/*
		int max = tmp[0]; 
		for(int i=0; i<tmp.size(); i++)
		{
			std::cerr << tmp[i] << std::endl; 
			if(tmp[i] > max) 
			{
				max = tmp[i]; 
			}
		}
		std::cerr << "MAX4: " << max << std::endl; 
		_offset = max;
		*/
	}
}

TagStat::TagStat(Stat* _stat, CondExpr* _cond_expr, std::string _id) : stat(_stat), cond_expr(_cond_expr), id(_id) {}
void TagStat::generate_code()	
{
	if(id != "")
	{
		os << "tag_" << id << ":" << std::endl; 
		if(stat != NULL)
		{
			stat->generate_code(); 
		}
	}
	//case statement
	if(cond_expr != NULL)
	{
		if(cases)
		{
			//os << "case_" << case_num << ":" << std::endl; 
			cond_expr->generate_code(); 
			std::string c_tag=""; 
			cond_expr->get_tag(c_tag);

			os << "\tlw\t$" << TMP1 << "," << OffsetMap[c_tag] << "($fp)" << std::endl; 
			//os << "\tli\t$" << TMP2 << "," << case_num << std::endl; 
			os << "\tbne\t$" << TMP1 << ",$" << CASE_REG << "," << "case_" << case_num+1 << std::endl;
			os << "\tnop" << std::endl;
			os << "\tj\t" << "body_" << case_num << std::endl;
			os << "\tnop" << std::endl;
			
			case_num++;
			os << "case_" << case_num << ":" << std::endl; 
		}
		else
		{
			os << "body_" << case_num << ":" << std::endl; 
			if(stat != NULL) 
			{
				stat->generate_code();
			}

			case_num++;
		}
		
		//os <<"case_" << case_num << ":" << std::endl;
		//os << "body_" << case_num << ":" << std::endl;
	}
	//default
	if(stat != NULL && cond_expr == NULL && id == "" && !cases)
	{
		//os <<"case_" << case_num << ":" << std::endl;
		//os << "body_" << case_num << ":" << std::endl;
		stat->generate_code();
	}
	
}

IfElseExpr::IfElseExpr(Expression* _ic, Expr* _ie, CondExpr* _ee) : if_cond(_ic), if_expr(_ie), else_expr(_ee) {}
void IfElseExpr::print()
{
	if(if_cond != NULL)
	{
		std::cerr << "if: ";
		if_cond->print(); 
	}
	if(if_expr != NULL)
	{
		std::cerr << "\tbody: "; 
		if_expr->print(); 
	}
	if(else_expr != NULL)
	{
		std::cerr << "else: ";
		else_expr->print();
	}
}
void IfElseExpr::generate_code()
{
	tag = set_offset(); 

	std::string condition_tag = ""; 
	std::string true_tag = ""; 
	std::string false_tag = ""; 
	
	if(if_expr != NULL)
	{
		if_expr->generate_code();
		if_expr->get_tag(true_tag);
	}
	if(else_expr != NULL)
	{
		else_expr->generate_code();
		else_expr->get_tag(false_tag);
	}
	if(if_cond != NULL)
	{
		if_cond->generate_code();
		if_cond->get_tag(condition_tag);
	}

	os << "\tlw" << "\t$" << TMP1 << "," << OffsetMap[condition_tag] << "($fp)" << std::endl; 
	os << "\tlw" << "\t$" << TMP2 << "," << OffsetMap[true_tag] << "($fp)" << std::endl; 
	os << "\tlw" << "\t$" << TMP3 << "," << OffsetMap[false_tag] << "($fp)" << std::endl;
	//os << "\tmovn" << "\t$" << TMP2 << ",$" << TMP2 << ",$" << TMP1 << std::endl; 
	os << "\tmovz" << "\t$" << TMP2 << ",$" << TMP3 << ",$" << TMP1 << std::endl;
	os << "\tsw" << "\t$" << TMP2 << "," << OffsetMap[tag] << "($fp)" << std::endl; 
}
void IfElseExpr::get_tag(std::string& _tag)
{
	_tag = tag; 
}

%}

%union 
{
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
}

%token SEMICOLON COMMA LCURLY RCURLY LBRAC RBRAC LSQBRAC RSQBRAC
%token INT FLOAT DOUBLE BOOL
%token LONG UNSIGNED SIGNED CONST SHORT
%token VOID STRUCT UNION CHAR TYPEDEF VOLATILE STRING
%token IDENTIFIER INT_VAL FLOAT_VAL STRING_LIT OCT_VAL HEX_VAL
%token IF ELSE FOR WHILE
%token GOTO_KWD CONTINUE_KWD BREAK RETURN 
%token EQUALS MUL_EQUALS DIV_EQUALS MOD_EQUALS ADD_EQUALS SUB_EQUALS LEFT_EQUALS RIGHT_EQUALS AND_EQUALS OR_EQUALS XOR_EQUALS ADD SUB MULT DIV MOD
%token QUESTION_MARK COLON OR AND BW_OR BW_XOR BW_AND EQUAL_EQUAL NOT_EQUAL LT GT LE GE LEFT_SHIFT RIGHT_SHIFT INC DEC BW_NOT NOT
%token ENUM CHAR_KWD FLOAT_KWD DOUBLE_KWD AUTO EXTERN REGISTER STATIC DO SWITCH CASE SIZEOF DEFAULT TYPE
%type<tree_node> jump_statement 
%type<string> IDENTIFIER EQUALS MUL_EQUALS DIV_EQUALS MOD_EQUALS ADD_EQUALS SUB_EQUALS LEFT_EQUALS RIGHT_EQUALS AND_EQUALS OR_EQUALS XOR_EQUALS QUESTION_MARK COLON assign_oper OR AND BW_OR BW_XOR BW_AND EQUAL_EQUAL NOT_EQUAL LT GT LE GE LEFT_SHIFT RIGHT_SHIFT ADD SUB MULT DIV MOD unary_oper INC DEC BW_NOT NOT TYPE CHAR STRING INT_VAL FLOAT_VAL OCT_VAL HEX_VAL

%type<File> file
%type<Ext_Decl> external_decl
%type<Func_Def> function_def
%type<Decl> decl 
%type<Decl_Spec> decl_specifiers
%type<Type_Spec> type_specifier
%type<Init_List> init_list
%type<Init_Declr> init_declarator
%type<Declr> declarator
%type<Init_Val> initial_val
%type<Param_List> param_list
%type<Param_Decl> param_decl
%type<Ass_Expr> assign_expr
%type<_Expr> expr
%type<Cond_Expr> conditional_expr
%type<Comp_Stat> compound_statement
%type<Loop_Stat> loop_statement
%type<Do_Stat> do_statement
%type<Selec_Stat> selection_statement
%type<Decl_List> decl_list
%type<Stat_List> statement_list
%type<Stat> statement
%type<Expr_Stat> expr_statement
%type<Express> logical_or_expr logical_and_expr incl_or_expr excl_or_expr and_expr bool_equal_expr comparison_expr shift_expr addsub_expr multdivmod_expr 
%type<Unary_Expr> unary_expr
%type<Postfix_Expr> postfix_expr
%type<Arg_List> argument_list
%type<Prim_Expr> primary_expr
%type<IE_Expr> ie_expr
%type<Init_Val_List> init_val_list
%type<Tag_Stat> tag_statement

%% 

file			: external_decl {$$ = new File($1); root = $$;} 
	 			| external_decl file  {$$ = new File($1, $2); root = $$;}
				;

external_decl	: function_def {$$ = new ExternalDecl($1);}
				| decl {$$ = new ExternalDecl(NULL, $1);}
				;

function_def	: decl_specifiers declarator compound_statement {$$ = new FuncDef($1,$2,$3);} 
				;

decl			: decl_specifiers SEMICOLON {$$ = new Decl($1);}
				| decl_specifiers init_list SEMICOLON {$$ = new Decl($1, $2);}
				;	

decl_specifiers	: type_specifier {$$ = new DeclSpec($1);}
				| type_specifier decl_specifiers {$$ = new DeclSpec($1, $2);} 
				;

decl_list		: decl {$$ = new DeclList($1);}
				| decl decl_list {$$ = new DeclList($1,$2);}
				;

type_specifier	: TYPE {$$ = new TypeSpec($1);}
				;

init_list		: init_declarator {$$ = new InitList($1); } 
				| init_declarator COMMA init_list {$$ = new InitList($1, $3);} 
				;

init_declarator	: declarator {$$ = new InitDeclr($1);} 
				| declarator EQUALS initial_val {$$ = new InitDeclr($1, $3);}
				;

statement_list	: statement {$$ = new StatList($1);}
				| statement statement_list {$$ = new StatList($1,$2);}
				

statement		: compound_statement {} 
				| expr_statement {}
				| selection_statement {}
				| loop_statement {}
				| jump_statement {}
				| tag_statement {}
				;

declarator		: IDENTIFIER {$$ = new Declr($1);} 
				| declarator LBRAC param_list RBRAC {$$ = new Declr("", $1, $3, 1);} 
				| declarator LBRAC RBRAC {$$ = new Declr("", $1, NULL, 1);}
				| declarator LSQBRAC conditional_expr RSQBRAC {$$ = new Declr("",$1,NULL,0,$3);}
				| declarator LSQBRAC RSQBRAC {$$ = new Declr("",$1,NULL,0,NULL);}
				;

param_list		: param_decl {$$ = new ParamList($1);}
				| param_decl COMMA param_list {$$ = new ParamList($1, $3);}
				;

param_decl		: decl_specifiers declarator {$$ = new ParamDecl($1,$2);} 
				;

compound_statement	: LCURLY RCURLY {$$ = new CompStat();} 
					| LCURLY statement_list RCURLY {$$ = new CompStat($2);} 
					| LCURLY decl_list RCURLY {$$ = new CompStat(NULL,$2);} 
					| LCURLY decl_list statement_list RCURLY {$$ = new CompStat($3,$2);}
					;

initial_val		: assign_expr {$$ = new InitVal($1);}
				| LCURLY init_val_list RCURLY {$$ = new InitVal(NULL,$2);}
				;

init_val_list 	: initial_val {$$ = new InitValList($1);}
				| initial_val COMMA init_val_list {$$ = new InitValList($1,$3);}
				;

selection_statement : IF LBRAC expr RBRAC statement {$$ = new SelecStat($3,$5);} 
					| IF LBRAC expr RBRAC statement ELSE statement {$$ = new SelecStat($3,$5,$7);}
					| SWITCH LBRAC expr RBRAC statement {$$ = new SelecStat($3,NULL,NULL,$5);}
					;

loop_statement	: WHILE LBRAC expr RBRAC statement {$$ = new LoopStat(NULL,NULL,$3,$5);}
				| do_statement {$$ = new LoopStat(NULL,NULL,NULL,NULL,$1);}
				| FOR LBRAC expr_statement expr_statement RBRAC statement {$$ = new LoopStat($3,$4,NULL,$6);}
				| FOR LBRAC expr_statement expr_statement expr RBRAC statement {$$ = new LoopStat($3,$4,$5,$7);}
				;

do_statement 	: DO statement WHILE LBRAC expr RBRAC SEMICOLON {$$ = new DoStat($2,$5);} 
				;

expr_statement 	: SEMICOLON {$$ = new ExprStat();}
				| expr SEMICOLON {$$ = new ExprStat($1);}
				;

jump_statement	: GOTO_KWD IDENTIFIER SEMICOLON {} 
				| RETURN SEMICOLON {$$ = new JumpStat(NULL, "return");}
				| RETURN expr SEMICOLON {$$ = new JumpStat($2, "return");}
				| BREAK SEMICOLON {$$ = new JumpStat(NULL, "break");}
				;

tag_statement 	: IDENTIFIER COLON statement {$$ = new TagStat($3, NULL, $1);}
				| CASE conditional_expr COLON statement {$$ = new TagStat($4,$2);}
				| DEFAULT COLON statement {$$ = new TagStat($3);}
				;				

expr			: assign_expr {$$ = new Expr($1);}  
				| expr COMMA assign_expr {$$ = new Expr($3,$1);}
				;

assign_expr		: conditional_expr {$$ = new AssExpr($1);}
				| unary_expr assign_oper assign_expr {$$ = new AssExpr(NULL,$1,$2,$3);}  
				;

assign_oper		: EQUALS {}
				| MUL_EQUALS {}
				| DIV_EQUALS {}
				| MOD_EQUALS {}
				| ADD_EQUALS {}
				| SUB_EQUALS {}
				| LEFT_EQUALS {}
				| RIGHT_EQUALS {}
				| AND_EQUALS {}
				| XOR_EQUALS {}
				| OR_EQUALS {}
				;

conditional_expr : logical_or_expr {$$ = new CondExpr($1);}
			     | ie_expr {$$ = new CondExpr(NULL, $1);}
				 ;

ie_expr			 : logical_or_expr QUESTION_MARK expr COLON conditional_expr {$$ = new IfElseExpr($1,$3,$5);}
				 ;

logical_or_expr : logical_and_expr {$$ = new Expression($1);}
				| logical_or_expr OR logical_and_expr {$$ = new Expression($1,$3,"||");}
				;

logical_and_expr : incl_or_expr {$$ = new Expression($1);}
				 | logical_and_expr AND incl_or_expr{$$ = new Expression($1,$3,"&&");}
				 ;

incl_or_expr 	: excl_or_expr{$$ = new Expression($1);}
				| incl_or_expr BW_OR excl_or_expr{$$ = new Expression($3,$1,"|");} 
				;

excl_or_expr	: and_expr{$$ = new Expression($1);}
				| excl_or_expr BW_XOR and_expr{$$ = new Expression($1,$3,"^");}
				;

and_expr		: bool_equal_expr{$$ = new Expression($1);}
				| and_expr BW_AND bool_equal_expr{$$ = new Expression($1,$3,"&");}
				;

bool_equal_expr : comparison_expr{$$ = new Expression($1);}
				| bool_equal_expr EQUAL_EQUAL comparison_expr{$$ = new Expression($1,$3,"==");}
				| bool_equal_expr NOT_EQUAL comparison_expr{$$ = new Expression($1,$3,"!=");}
				;

comparison_expr : shift_expr{$$ = new Expression($1);}
				| comparison_expr LT shift_expr{$$ = new Expression($1,$3,"<");}
				| comparison_expr GT shift_expr{$$ = new Expression($1,$3,">");}
				| comparison_expr LE shift_expr{$$ = new Expression($1,$3,"<=");}
				| comparison_expr GE shift_expr{$$ = new Expression($1,$3,">=");}
				;

shift_expr 		: addsub_expr{$$ = new Expression($1);}
				| shift_expr LEFT_SHIFT addsub_expr{$$ = new Expression($1,$3,"<<");}
				| shift_expr RIGHT_SHIFT addsub_expr{$$ = new Expression($1,$3,">>");}
				;

addsub_expr		: multdivmod_expr {$$ = new Expression($1);}
				| addsub_expr ADD multdivmod_expr{$$ = new Expression($1,$3,"+");}
				| addsub_expr SUB multdivmod_expr{$$ = new Expression($1,$3,"-");}
				;

multdivmod_expr : unary_expr {$$ = new Expression(NULL,NULL,"",$1);}
				| multdivmod_expr MULT unary_expr{$$ = new Expression($1,NULL,"*",$3);}
				| multdivmod_expr DIV unary_expr{$$ = new Expression($1,NULL,"/",$3);}
				|multdivmod_expr MOD unary_expr{$$ = new Expression($1,NULL,"%",$3);}
				;

unary_expr		: postfix_expr {$$ = new UnaryExpr($1);}
				| INC unary_expr {$$ = new UnaryExpr(NULL,$2,$1);}
				| DEC unary_expr {$$ = new UnaryExpr(NULL,$2,$1);}
				| unary_oper unary_expr {$$ = new UnaryExpr(NULL,$2,$1);} 
				;

unary_oper		: BW_AND
				| MULT
				| ADD 
				| SUB
				| BW_NOT
				| NOT
				;

postfix_expr	: primary_expr {$$ = new PostFixExpr($1);}
				| postfix_expr LBRAC RBRAC {$$ = new PostFixExpr(NULL,$1);}
				| postfix_expr LBRAC argument_list RBRAC {$$ = new PostFixExpr(NULL,$1,"",$3);}
				| postfix_expr INC {$$ = new PostFixExpr(NULL, $1, $2);}
				| postfix_expr DEC {$$ = new PostFixExpr(NULL, $1, $2);}
				| postfix_expr LSQBRAC expr RSQBRAC {$$ = new PostFixExpr(NULL, $1, "", NULL, $3,true);}
				;

argument_list 	: assign_expr {$$ = new ArgList($1);}
				| assign_expr COMMA argument_list {$$ = new ArgList($1,$3);}
				;

primary_expr	: IDENTIFIER {$$ = new PrimExpr($1,0);} 
				| INT_VAL {$$ = new PrimExpr($1,1);}
				| OCT_VAL {$$ = new PrimExpr($1,2);}
				| HEX_VAL {$$ = new PrimExpr($1,3);}
				| FLOAT_VAL {$$ = new PrimExpr($1,4);}  
				| CHAR {$$ = new PrimExpr($1,5);}  
				| STRING {$$ = new PrimExpr($1,6);}  
				| LBRAC expr RBRAC {$$ = new PrimExpr("",-1,$2);}
				;
%%

int yyerror(const char* s)
{
	std::cerr << s << std::endl;
	return -1;
}

int main() 
{
	yyparse();
	root->generate_code();
	TUnit << "\t.data\n" << ArrayLabel.str() << std::endl; 
	std::cout << "\t.text\n" << TUnit.str(); 
}
