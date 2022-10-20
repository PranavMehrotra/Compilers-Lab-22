#include "ass5_20CS10085_20CS30065_translator.h"
#include <iomanip>
using namespace std;

ST_entry* curr_symbol;              //pointer to current symbol being processed
symbol_table* curr_symb_table;      //pointer to active symbol table
symbol_table* global_symb_table;    //pointer to global symbol table
quad_TAC_TAC_arr quad_TAC_TAC_list;         //list of TAC codes
int num_ST;                         //number of symbol tables
string block;                       //for naming nested blocks

string prev_var;                    // Used for storing the last encountered type

ST_entry_type::ST_entry_type(string type_, ST_entry_type* derived_arr_, int width_): // constructor for the ST_entry_type class
    type(type_), width(width_), derived_arr(derived_arr_) {}                        //parameter intialization


ST_entry::ST_entry(string name_, string temp, ST_entry_type* derived_arr, int width): name(name_), value("-"), offset(0), nestedTable(NULL) 
{
    // constructor for the symbol class
    type = new ST_entry_type(temp, derived_arr, width);
    size = type_sizeof(type);
}

ST_entry* ST_entry::update(ST_entry_type* temp) 
{
     // Member function for the symbol class
    type = temp;                //update the type of symbol element
    size = type_sizeof(temp);   //update the size i.e. number of bytes corresponding to type
    return this;                //return the present class object
}


symbol_table::symbol_table(string name_): name(name_), temporary_var(0) {} //constructor 

ST_entry* symbol_table::search_lexeme(string name) {
    
    for(list<ST_entry>::iterator iter = table.begin(); iter != table.end(); iter++)
    {
        if(iter->name == name) //traverse the entire table array  
        {
            return &(*iter);
        }
    }

    // if the lexeme is not found the table go to the parent table
    ST_entry* sample = NULL;
    if(this->parent != NULL) {
        sample = this->parent->search_lexeme(name);
    }

    //add the symbol to the current symbol table if the sample remained NULL i.e. the symbol doesn't exist 
    if(curr_symb_table == this && sample == NULL) {
        // If the symbol is not found, create the symbol and add it to the symbol table 
        ST_entry* symbol = new symbol(name);
        table.push_back(*symbol);
        return &(table.back());
    }
    else if(sample != NULL) {
        // If the symbol is found in one of the parent symbol tables, return it
        return sample;
    }

    return NULL;
}

ST_entry* symbol_table::generate_tem_var(ST_entry_type* temp, string intial_value) {
    // Create the name for the temporary
    string name = "t" + convertIntToString(curr_symb_table->temporary_var++); //make a t variable
    ST_entry* temp_sym = new ST_entry(name);
    temp_sym->type = temp;
    temp_sym->value = intial_value;         // Assign the initial value, if any
    temp_sym->size = type_sizeof(temp);

    // Add the temporary to the symbol table
    curr_symb_table->table.push_back(*temp_sym);
    return &(curr_symb_table->table.back());
}

void symbol_table::print_ST() {
    for(int i = 0; i < 120; i++) {
        cout << '-';
    }
    cout << endl;
    cout << "Symbol Table: " << setfill(' ') << left << setw(50) << this->name;
    cout << "Parent Table: " << setfill(' ') << left << setw(50) << ((this->parent != NULL) ? this->parent->name : "NULL") << endl;
    for(int i = 0; i < 120; i++) {
        cout << '-';
    }
    cout << endl;

    // Table Headers
    cout << setfill(' ') << left << setw(25) <<  "Name";
    cout << left << setw(25) << "Type";
    cout << left << setw(20) << "Initial Value";
    cout << left << setw(15) << "Size";
    cout << left << setw(15) << "Offset";
    cout << left << "Nested" << endl;

    for(int i = 0; i < 120; i++) {
        cout << '-';
    }
    cout << endl;

    list<symbol_table*> tableList;

    // Print the symbols in the symbol table
    for(list<ST_entry>::iterator it = this->table.begin(); it != this->table.end(); it++) {
        cout << left << setw(25) << it->name;
        cout << left << setw(25) << typecheck(it->type);
        cout << left << setw(20) << (it->value != "" ? it->value : "-");
        cout << left << setw(15) << it->size;
        cout << left << setw(15) << it->offset;
        cout << left;

        if(it->nestedTable != NULL) {
            cout << it->nestedTable->name << endl;
            tableList.push_back(it->nestedTable);
        }
        else {
            cout << "NULL" << endl;
        }
    }

    for(int i = 0; i < 120; i++) {
        cout << '-';
    }
    cout << endl << endl;

    // Recursively call the print function for the nested symbol tables
    for(list<symbol_table*>::iterator it = tableList.begin(); it != tableList.end(); it++) {
        (*it)->print();
    }

}

void symbol_table::update_ST() {
    list<symbol_table*> tableList;
    int off_set;

    // Update the offsets of the symbols based on their sizes
    for(list<ST_entry>::iterator it = table.begin(); it != table.end(); it++) {
        if(it == table.begin()) {
            it->offset = 0;
            off_set = it->size;
        }
        else {
            it->offset = off_set;
            off_set = it->offset + it->size;
        }

        if(it->nestedTable != NULL) {
            tableList.push_back(it->nestedTable);
        }
    }

    // Recursively call the update function to update the offsets of symbols of the nested symbol tables
    for(list<symbol_table*>::iterator iter = tableList.begin(); iter != tableList.end(); iter++) {
        (*iter)->update();
    }
}

// Implementations of constructors and functions for the quad_TAC class
quad_TAC::quad_TAC(string res, string arg1_, string operation, string arg2_): result(res), arg1(arg1_), operation(operation), arg2(arg2_) {}

quad_TAC::quad_TAC(string res, int arg1_, string operation, string arg2_): result(res), operation(operation), arg2(arg2_) {
    arg1 = convertIntToString(arg1_);
}

quad_TAC::quad_TAC(string res, float arg1_, string operation, string arg2_): result(res), operation(operation), arg2(arg2_) {
    arg1 = convertFloatToString(arg1_);
}

void quad_TAC::print_quad() {
    if(op == "=")       // Simple assignment
        cout << result << " = " << arg1;
    else if(op == "*=")
        cout << "*" << result << " = " << arg1;
    else if(op == "[]=")
        cout << result << "[" << arg1 << "]" << " = " << arg2;
    else if(op == "=[]")
        cout << result << " = " << arg1 << "[" << arg2 << "]";
    else if(op == "goto" || op == "param" || op == "return")
        cout << op << " " << result;
    else if(op == "call")
        cout << result << " = " << "call " << arg1 << ", " << arg2;
    else if(op == "label")
        cout << result << ": ";

    // Binary Operators
    else if(op == "+" || op == "-" || op == "*" || op == "/" || op == "%" || op == "^" || op == "|" || op == "&" || op == "<<" || op == ">>")
        cout << result << " = " << arg1 << " " << op << " " << arg2;

    // Relational Operators
    else if(op == "==" || op == "!=" || op == "<" || op == ">" || op == "<=" || op == ">=")
        cout << "if " << arg1 << " " << op << " " << arg2 << " goto " << result;

    // Unary operators
    else if(op == "= &" || op == "= *" || op == "= -" || op == "= ~" || op == "= !")
        cout << result << " " << op << arg1;

    else
        cout << "Unknown Operator";
}

// Implementations of constructors and functions for the quad_TACArray class
void quad_TAC_arr::print_quad_list() {
    for(int i = 0; i < 120; i++) {
        cout << '-';
    }
    cout << endl;
    cout << "\nTHREE ADDRESS CODE (TAC):" << endl;
    for(int i = 0; i < 120; i++) {
        cout << '-';
    }
    cout << endl;

    int cnt = 0;
    // Print each of the quad_TACs one by one
    for(vector<quad_TAC>::iterator it = this->quad_list.begin(); it != this->quad_list.end(); it++, cnt++) {
        if(it->op != "label") {
            cout << left << setw(4) << cnt << ":    ";
            it->print();
        }
        else {
            cout << endl << left << setw(4) << cnt << ": ";
            it->print();
        }
        cout << endl;
    }
}

// Overloaded emit functions
void emit(string op, string result, string arg1, string arg2) {
    quad_TAC* q = new quad_TAC(result, arg1, op, arg2);
    quad_TACList.quad_TACs.push_back(*q);
}

void emit(string op, string result, int arg1, string arg2) {
    quad_TAC* q = new quad_TAC(result, arg1, op, arg2);
    quad_TACList.quad_TACs.push_back(*q);
}

void emit(string op, string result, float arg1, string arg2) {
    quad_TAC* q = new quad_TAC(result, arg1, op, arg2);
    quad_TACList.quad_TACs.push_back(*q);
}

// Implementation of the makelist function
list<int> makelist(int i) {
    list<int> l(1, i);
    return l;
}

// Implementation of the merge function
list<int> merge(list<int> &list1, list<int> &list2) {
    list1.merge(list2);
    return list1;
}

// Implementation of the backpatch function
void backpatch(list<int> l, int address) {
    string str = convertIntToString(address);
    for(list<int>::iterator it = l.begin(); it != l.end(); it++) {
        quad_TACList.quad_TACs[*it].result = str;
    }
}

// Implementation of the typecheck functions
bool typecheck(ST_entry* &s1, ST_entry* &s2) {
    ST_entry_type* t1 = s1->type;
    ST_entry_type* t2 = s2->type;

    if(typecheck(t1, t2))
        return true;
    else if(s1 = convertType(s1, t2->type))
        return true;
    else if(s2 = convertType(s2, t1->type))
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

// Implementation of the convertType function
ST_entry* convertType(ST_entry* s, string t) {
    ST_entry* temp = symbol_table::generate_tem_var(new ST_entry_type(t));

    if(s->type->type == "float") {
        if(t == "int") {
            emit("=", temp->name, "float2int(" + s->name + ")");
            return temp;
        }
        else if(t == "char") {
            emit("=", temp->name, "float2char(" + s->name + ")");
            return temp;
        }
        return s;
    }

    else if(s->type->type == "int") {
        if(t == "float") {
            emit("=", temp->name, "int2float(" + s->name + ")");
            return temp;
        }
        else if(t == "char") {
            emit("=", temp->name, "int2char(" + s->name + ")");
            return temp;
        }
        return s;
    }

    else if(s->type->type == "char") {
        if(t == "float") {
            emit("=", temp->name, "char2float(" + s->name + ")");
            return temp;
        }
        else if(t == "int") {
            emit("=", temp->name, "char2int(" + s->name + ")");
            return temp;
        }
        return s;
    }

    return s;
}

string convertIntToString(int i) {
    return std::to_string(i);
}

string convertFloatToString(float f) {
    return std::to_string(f);
}

// Implementation of the convertIntToBool function
expression* convertIntToBool(expression* expr) {
    if(expr->type != "bool") {
        expr->falselist = makelist(nextinstr());    // Add falselist for boolean expressions
        emit("==", expr->loc->name, "0");
        expr->truelist = makelist(nextinstr());     // Add truelist for boolean expressions
        emit("goto", "");
    }
    return expr;
}

// Implementation of the convertBoolToInt function
expression* convertBoolToInt(expression* expr) {
    if(expr->type == "bool") {
        expr->loc = symbol_table::generate_tem_var(new ST_entry_type("int"));
        backpatch(expr->truelist, nextinstr());
        emit("=", expr->loc->name, "true");
        emit("goto", convertIntToString(nextinstr() + 1));
        backpatch(expr->falselist, nextinstr());
        emit("=", expr->loc->name, "false");
    }
    return expr;
}

void switchTable(symbol_table* newTable) {
    curr_symb_table =temporary_var;
}

int nextinstr() {
    return quad_TACList.quad_TACs.size();
}

int type_sizeof(ST_entry_type* t) {
    if(t->type == "void")
        return __VOID_SIZE;
    else if(t->type == "char")
        return __CHARACTER_SIZE;
    else if(t->type == "int")
        return __INTEGER_SIZE;
    else if(t->type == "ptr")
        return __POINTER_SIZE;
    else if(t->type == "float")
        return __FLOAT_SIZE;
    else if(t->type == "arr")
        return t->width * type_sizeof(t->derived_arr);
    else if(t->type == "func")
        return __FUNCTION_SIZE;
    else
        return -1;
}

string checkType(ST_entry_type* t) {
    if(t == NULL)
        return "null";
    else if(t->type == "void" || t->type == "char" || t->type == "int" || t->type == "float" || t->type == "block" || t->type == "func")
        return t->type;
    else if(t->type == "ptr")
        return "ptr(" + checkType(t->derived_arr) + ")";
    else if(t->type == "arr")
        return "arr(" + convertIntToString(t->width) + ", " + checkType(t->derived_arr) + ")";
    else
        return "unknown";
}

int main() {
    STCount = 0;                            // Initialize STCount to 0
    globalST = new symbol_table("Global");   // Create global symbol table
    curr_symb_table =temporary_var;                   // Make global symbol table the currently active symbol table
    blockName = "";

    yyparse();
    globalST->update();
    quad_TACList.print();       // Print Three Address Code
    cout << endl;
    //globalST->print();      // Print symbol tables

    return 0;
}
