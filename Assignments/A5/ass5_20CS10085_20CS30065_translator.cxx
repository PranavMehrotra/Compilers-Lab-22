#include "ass5_20CS10085_20CS30065_translator.h"
#include <iomanip>
using namespace std;

//Global Symbol Declaration
ST_entry* curr_symbol;                                                              //pointer to current symbol being processed
symbol_table* curr_symb_table;                                                      //pointer to active symbol table
symbol_table* global_symb_table;                                                    //pointer to global symbol table
quad_TAC_arr quad_TAC_list;                                                         //list of TAC codes
int num_ST;                                                                         //number of symbol tables
string block;                                                                       //for naming nested blocks
string prev_var;                                                                    //Used for storing the last encountered type

//Class ST_entry_type  
ST_entry_type::ST_entry_type(string type_, ST_entry_type* derived_arr_, int width_):// constructor for the ST_entry_type class
    type(type_), width(width_), derived_arr(derived_arr_) {}                        //parameter intialization

//-------------------------------------------------------------

//Class ST_entry
ST_entry::ST_entry(string name_, string temp, ST_entry_type* derived_arr, int width): name(name_), value("-"), offset(0), nested_symbol_table(NULL) 
{
    // constructor for the symbol class
    type = new ST_entry_type(temp, derived_arr, width);
    size = type_sizeof(type);
}

ST_entry* ST_entry::update_entry(ST_entry_type* temp) 
{
    // Member function for the symbol class
    type = temp;                //update the type of symbol element
    size = type_sizeof(temp);   //update the size i.e. number of bytes corresponding to temp
    return this;                //return the present class object
}

//-------------------------------------------------------------

//Class symbol_table
symbol_table::symbol_table(string name_): name(name_), temporary_var(0) {} //constructor 

ST_entry* symbol_table::search_lexeme(string name_var) {
    
    for(list<ST_entry>::iterator iter = table.begin(); iter != table.end(); iter++)
    {
        if(iter->name == name_var) //traverse the entire table array, if the name of the variable in the symbol table matches with input name return the address  
        {
            return &(*iter);
        }
    }

    // if the lexeme is not found in the table go to the parent symbol table, if any
    ST_entry* sample = NULL; //variable to store the pointer to symbol table entry in parent
    
    if(this->parent != NULL) { //if parent table exists
        sample = this->parent->search_lexeme(name_var); //recursively search all the parent tables
    }

    //after recursive calls to search_lexeme sample would contain pointer to symbol table entry of name_var
    //if the sample is still NULL, indicating that the variable is encountered for the first time thus create a new ST_entry object and insert it in the current symbol table
     
    if(curr_symb_table == this && sample == NULL) {
        ST_entry* new_symbol = new ST_entry(name_var);
        
        table.push_back(*new_symbol);
        return &(table.back());
    }
    else if(sample != NULL) {
        // If the symbol was found in any of the parent symbol tables, return teh pointer to symbol table entry of the name_var 
        return sample;
    }

    return NULL;//return NULL indicating certain error
}

//to create a temporary variables that will store intermediate expression values and push them in symbol table
ST_entry* symbol_table::generate_tem_var(ST_entry_type* temp, string intial_value) {
    
    string name = "t" + convert_int_str(curr_symb_table->temporary_var++); //temporary_var keeps a track of temporary variables created still
    // if temporary_var = 8  then this method will create a new variable with the name t9
    
    //create a new ST_entry object with type details from temp variable
    ST_entry* temp_sym = new ST_entry(name);
    temp_sym->type = temp;
    temp_sym->value = intial_value;         // Assign the initial value, if any
    temp_sym->size = type_sizeof(temp);

    // Add the temporary to the symbol table
    curr_symb_table->table.push_back(*temp_sym);
    return &(curr_symb_table->table.back());//the new temp variable is pushed at the end of the table and pointer to the entry is returned
}

void symbol_table::print_ST() {

    //codes for basic formatting 
    for(int i = 0; i < 120; i++) 
    {
        cout << '*';
    }

    cout << endl;
    //setfill sets the remaining character of width with space i.e. name will be printed with a width of 50 where the remaining places are replaced by space
    cout << "\nSymbol Table: " << setfill(' ') << left << setw(50) << this->name; //print the Symbol table name with appropriate format
    cout << "Parent Table: " << setfill(' ') << left << setw(50) << ((this->parent != NULL) ? this->parent->name : "NULL") << endl;
    
    for(int i = 0; i < 120; i++) 
    {
        cout << '*';
    }
    cout << "\n";

    // Symbol Table Column names
    cout << setfill(' ') << left << setw(25) <<  "\nName"; //name of variable
    cout << left << setw(25) << "Type";                  //type of variable
    cout << left << setw(20) << "Initial Value";         //intial value of variable if any
    cout << left << setw(15) << "Size";                  //size of the variable
    cout << left << setw(15) << "Offset";                //offset to keep track of relative addressing 
    cout << left << "Nested" << endl;                    //pointer to nested table if any

    for(int i = 0; i < 120; i++) 
    {
        cout << '*';
    }
    cout << endl;

    list<symbol_table*> list_table;//to keep a list of nested tables 

    // Print the symbols in the symbol table
    //cout<<left makes padding at end and setw sets the width of symbol
    for(list<ST_entry>::iterator iter = this->table.begin(); iter != this->table.end(); iter++) {
        cout << left << setw(25) << iter->name;
        cout << left << setw(25) << check_type(iter->type);
        cout << left << setw(20) << (iter->value != "" ? iter->value : "nil");
        cout << left << setw(15) << iter->size;
        cout << left << setw(15) << iter->offset;
        cout << left;

        //in case the symbol table has nested symbol table
        if(iter->nested_symbol_table != NULL) {
            cout << iter->nested_symbol_table->name << endl;//print the name of nested symbol table
            list_table.push_back(iter->nested_symbol_table);//push all nested tabels
        }
        else {
            cout << "NULL" << endl;//else print null
        }
    }

    for(int i = 0; i < 120; i++) {
        cout << '*';
    }
    cout << endl << endl;

    // Recursively call the print function for the nested symbol tables
    for(list<symbol_table*>::iterator iter = list_table.begin(); iter != list_table.end(); iter++) {
        (*iter)->print_ST();
    }
}

void symbol_table::update_entry() {
    list<symbol_table*> list_table;
    int offset;

    // Update the offsets of the symbols based on their sizes
    for(list<ST_entry>::iterator iter = table.begin(); iter != table.end(); iter++) {
        if(iter == table.begin()) {
            iter->offset = 0;//initial offset =0
            offset = iter->size;
        }
        else {
            iter->offset = offset;
            offset = iter->offset + iter->size;
        }

        if(iter->nested_symbol_table != NULL) {
            list_table.push_back(iter->nested_symbol_table);
        }
    }

    // Recursively call the update function to update the offsets of symbols of the nested symbol tables
    for(list<symbol_table*>::iterator iter = list_table.begin(); iter != list_table.end(); iter++) {
        (*iter)->update_entry();
    }
}

//--------------------------------------------------------------------------------------------


// Implementations of constructors and functions for the quad_TAC class
quad_TAC::quad_TAC(string result, string arg1_, string operation, string arg2_): result(result), arg1(arg1_), operation(operation), arg2(arg2_) {}

quad_TAC::quad_TAC(string result, int arg1_, string operation, string arg2_): result(result), operation(operation), arg2(arg2_) {
    arg1 = convert_int_str(arg1_);
}

quad_TAC::quad_TAC(string result, float arg1_, string operation, string arg2_): result(result), operation(operation), arg2(arg2_) {
    arg1 = convert_float_str(arg1_);
}

void quad_TAC::print_quad() {
    if(operation == "=")       // Simple assignment
        cout << result << " = " << arg1;

    else if(operation == "call")
        cout << result << " = " << "call " << arg1 << ", " << arg2;//opcode for function call

    else if(operation == "[]=")
        cout << result << "[" << arg1 << "]" << " = " << arg2;//opcode for instructions like a[i] = j

    else if(operation == "goto" || operation == "param" || operation == "return")
        cout << operation << " " << result;//opcode for jumps, function parameter declaration and return instructions        
    
    else if(operation == "=[]")
        cout << result << " = " << arg1 << "[" << arg2 << "]";//opcode for instructions like j = a[i]

    else if(operation == "*=")
        cout << "*" << result << " = " << arg1;//opcodes for instructions like *ptr = a;
    
    else if(operation == "label")
        cout << result << ": ";//opcode for Label

    // Binary Operators
    else if(operation == "+" || operation == "-" || operation == "*" || operation == "/" || operation == "%" || operation == "^" || operation == "|" || operation == "&" || operation == "<<" || operation == ">>")
        cout << result << " = " << arg1 << " " << operation << " " << arg2;

    // Relational operators
    else if(operation == "==" || operation == "!=" || operation == "<" || operation == ">" || operation == "<=" || operation == ">=")
        cout << "if " << arg1 << " " << operation << " " << arg2 << " goto " << result;

    // Unary operators
    else if(operation == "= &" || operation == "= *" || operation == "= -" || operation == "= ~" || operation == "= !")
        cout << result << " " << operation << arg1;

    else
        cout << "Invalid operator";
}

//---------------------------------------------------------------------------------------------------------


// Implementations of constructors and functions for the quad_TAC_array class
void quad_TAC_arr::print_quad_list() {
    for(int i = 0; i < 120; i++) {
        cout << '*';
    }
    cout << endl;
    cout << "\nThree Address Code (TAC):" << endl;
    for(int i = 0; i < 120; i++) {
        cout << '*';
    }
    cout << endl;

    int count = 0;
    // Print each of the quad_TACs one by one
    for(vector<quad_TAC>::iterator iter = this->quad_list.begin(); iter != this->quad_list.end(); iter++, count++) {
        if(iter->operation != "label") {
            cout << left << setw(4) << count << ":    ";//if the opcode is not a label print num: code
            iter->print_quad();
        }
        else {
            cout << endl << left << setw(4) << count << ": ";//if opcode is a label print \n num: label:
            iter->print_quad();
        }
        cout << endl;
    }
}

//--------------------------------------------------------------------------------------


// Overload add_TAC function
void add_TAC(string operation, string result, string arg1, string arg2) {
    quad_TAC* temp = new quad_TAC(result, arg1, operation, arg2);
    quad_TAC_list.quad_list.push_back(*temp);
}

void add_TAC(string operation, string result, int arg1, string arg2) {
    quad_TAC* temp = new quad_TAC(result, arg1, operation, arg2);
    quad_TAC_list.quad_list.push_back(*temp);
}

void add_TAC(string operation, string result, float arg1, string arg2) {
    quad_TAC* temp = new quad_TAC(result, arg1, operation, arg2);
    quad_TAC_list.quad_list.push_back(*temp);
}

//----------------------------------------------------------------------------------------

// Implementation of the makelist function
list<int> makelist(int i) {
    list<int> list_i(1, i);
    return list_i;
}

// Implementation of the merge_list function
list<int> merge_list(list<int> &list1, list<int> &list2) {
    list1.merge(list2);
    return list1;
}

// Implementation of the backpatch function
void backpatch(list<int> l, int addr) {
    string str = convert_int_str(addr);
    for(list<int>::iterator iter = l.begin(); iter != l.end(); iter++) {
        quad_TAC_list.quad_list[*iter].result = str;
    }
}

// Implementation of the typecheck functions
bool typecheck(ST_entry* &s1, ST_entry* &s2) {
    ST_entry_type* t1 = s1->type;
    ST_entry_type* t2 = s2->type;

    if(typecheck(t1, t2))
        return true;
    else if(s1 = convert_type(s1, t2->type))
        return true;
    else if(s2 = convert_type(s2, t1->type))
        return true;
    else
        return false;
}

bool typecheck(ST_entry_type* t1, ST_entry_type* t2) {
    if(t1 == NULL && t2 == NULL)
        return true;
    else if(t1 == NULL || t2 == NULL)
        return false;
    else if(t1->type != t2->type)
        return false;

    return typecheck(t1->derived_arr, t2->derived_arr);
}

// Implementation of the convert_type function
ST_entry* convert_type(ST_entry* s, string t) {
    ST_entry* temp = symbol_table::generate_tem_var(new ST_entry_type(t));

    if(s->type->type == "float") {
        if(t == "int") {
            add_TAC("=", temp->name, "float2int(" + s->name + ")");
            return temp;
        }
        else if(t == "char") {
            add_TAC("=", temp->name, "float2char(" + s->name + ")");
            return temp;
        }
        return s;
    }

    else if(s->type->type == "int") {
        if(t == "float") {
            add_TAC("=", temp->name, "int2float(" + s->name + ")");
            return temp;
        }
        else if(t == "char") {
            add_TAC("=", temp->name, "int2char(" + s->name + ")");
            return temp;
        }
        return s;
    }

    else if(s->type->type == "char") {
        if(t == "float") {
            add_TAC("=", temp->name, "char2float(" + s->name + ")");
            return temp;
        }
        else if(t == "int") {
            add_TAC("=", temp->name, "char2int(" + s->name + ")");
            return temp;
        }
        return s;
    }

    return s;
}

string convert_int_str(int i) {
    return std::to_string(i);
}

string convert_float_str(float f) {
    return std::to_string(f);
}

// Implementation of the convert_int_bool function
expression* convert_int_bool(expression* expr) {
    if(expr->type != "bool") {
        expr->falselist = makelist(next_instr_count());    // Add falselist for boolean expressions
        add_TAC("==", expr->location->name, "0");
        expr->truelist = makelist(next_instr_count());     // Add truelist for boolean expressions
        add_TAC("goto", "");
    }
    return expr;
}

// Implementation of the convert_bool_int function
expression* convert_bool_int(expression* expr) {
    if(expr->type == "bool") {
        expr->location = symbol_table::generate_tem_var(new ST_entry_type("int"));
        backpatch(expr->truelist, next_instr_count());
        add_TAC("=", expr->location->name, "true");
        add_TAC("goto", convert_int_str(next_instr_count() + 1));
        backpatch(expr->falselist, next_instr_count());
        add_TAC("=", expr->location->name, "false");
    }
    return expr;
}

void move_to_table(symbol_table* temporary_var) {
    curr_symb_table =temporary_var;
}

int next_instr_count() {
    return quad_TAC_list.quad_list.size();
}

int type_sizeof(ST_entry_type* t) {
    if(t->type == "void")
        return 0;
    else if(t->type == "char")
        return 1;
    else if(t->type == "int")
        return 4;
    else if(t->type == "ptr")
        return 4;
    else if(t->type == "float")
        return 8;
    else if(t->type == "arr")
        return t->width * type_sizeof(t->derived_arr);
    else if(t->type == "func")
        return 0;
    else
        return -1;
}

string check_type(ST_entry_type* t_var) {
    if(t_var == NULL)
        return "null";
    else if(t_var->type == "void" || t_var->type == "char" || t_var->type == "int" || t_var->type == "float" || t_var->type == "block" || t_var->type == "func")
        return t_var->type;
    else if(t_var->type == "ptr")
        return "ptr(" + check_type(t_var->derived_arr) + ")";
    else if(t_var->type == "arr")
        return "arr(" + convert_int_str(t_var->width) + ", " + check_type(t_var->derived_arr) + ")";
    else
        return "unknown";
}

int main() {
    num_ST = 0;                            // Initialize num_ST to 0
    global_symb_table = new symbol_table("Global");   // Create global symbol table
    cout<<"\n\n\n\n";
    curr_symb_table =global_symb_table;                   // Make global symbol table the currently active symbol table
    block = "";

    yyparse();
    global_symb_table->update_entry();
    quad_TAC_list.print_quad_list();       // Print Three Address Code
    cout << endl;
    global_symb_table->print_ST();      // Print symbol tables

    return 0;
}
