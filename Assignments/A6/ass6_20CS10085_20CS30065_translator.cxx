/**
* Vanshita Garg | 19CS10064
* Ashutosh Kumar Singh | 19CS30008
* Compilers Laboratory
* Assignment 6
*
* Source file for translation
*/

#include "ass6_20CS10085_20CS30065_translator.h"
#include <iomanip>
using namespace std;

// Initialize the global variables
int next_instruction = 0;

// Intiailize the static variables
int symbol_table::temporary_var = 0;

quad_TAC_arr TAC_list;
symbol_table ST_global;
symbol_table* ST;


// Implementations of constructors and functions for the ST_entry_value class
void ST_entry_value::initialize(int val) {
    c = f = i = val;
    p = NULL;
}

void ST_entry_value::initialize(char val) {
    c = f = i = val;
    p = NULL;
}

void ST_entry_value::initialize(float val) {
    c = f = i = val;
    p = NULL;
}


// Implementations of constructors and functions for the ST_entry class
ST_entry::ST_entry(): nested_symbol_table(NULL) {}


// Implementations of constructors and functions for the symbol_table class
symbol_table::symbol_table(): offset(0) {}

ST_entry* symbol_table::search_lexeme(string name, data_dtype t, int pc) {
    if(table.count(name) == 0) {
        ST_entry* sym = new ST_entry();
        sym->name = name;
        sym->type.type = t;
        sym->offset = offset;
        sym->initial_value = NULL;

        if(pc == 0) {
            sym->size = sizeOfType(t);
            offset += sym->size;
        }
        else {
            sym->size = 8;
            sym->type.next_elem_type = t;
            sym->type.pointers = pc;
            sym->type.type = ARRAY;
        }
        list_ST_entry.push_back(sym);
        table[name] = sym;
    }
    return table[name];
}

ST_entry* symbol_table::search_global_ST(string name) {
    return (table.count(name) ? table[name] : NULL);
}

string symbol_table::generate_tem_var(data_dtype t) {
    // Create the name for the temporary
    string tempName = "t" + to_string(symbol_table::temporary_var++);
    
    // Initialize the required attributes
    ST_entry* sym = new ST_entry();
    sym->name = tempName;
    sym->size = sizeOfType(t);
    sym->offset = offset;
    sym->type.type = t;
    sym->initial_value = NULL;

    offset += sym->size;
    list_ST_entry.push_back(sym);
    table[tempName] = sym;  // Add the temporary to the ST_entry table

    return tempName;
}

void symbol_table::print_ST(string tableName) {
    for(int i = 0; i < 120; i++) {
        cout << '-';
    }
    cout << endl;
    cout << "Symbol Table: " << setfill(' ') << left << setw(50) << tableName << endl;
    for(int i = 0; i < 120; i++)
        cout << '-';
    cout << endl;

    // Table Headers
    cout << setfill(' ') << left << setw(25) <<  "Name";
    cout << left << setw(25) << "Type";
    cout << left << setw(20) << "Initial Value";
    cout << left << setw(15) << "Size";
    cout << left << setw(15) << "Offset";
    cout << left << "Nested" << endl;

    for(int i = 0; i < 120; i++)
        cout << '-';
    cout << endl;

    // For storing nested ST_entry tables
    vector<pair<string, symbol_table*>> tableList;

    // Print the list_ST_entry in the ST_entry table
    for(int i = 0; i < (int)list_ST_entry.size(); i++) {
        ST_entry* sym = list_ST_entry[i];
        cout << left << setw(25) << sym->name;
        cout << left << setw(25) << checkType(sym->type);
        cout << left << setw(20) << getInitVal(sym);
        cout << left << setw(15) << sym->size;
        cout << left << setw(15) << sym->offset;
        cout << left;

        if(sym->nested_symbol_table != NULL) {
            string nested_symbol_tableName = tableName + "." + sym->name;
            cout << nested_symbol_tableName << endl;
            tableList.push_back({nested_symbol_tableName, sym->nested_symbol_table});
        }
        else
            cout << "NULL" << endl;
    }

    for(int i = 0; i < 120; i++)
        cout << '-';
    cout << endl << endl;

    // Recursively call the print function for the nested ST_entry tables
    for(vector<pair<string, symbol_table*>>::iterator it = tableList.begin(); it != tableList.end(); it++) {
        pair<string, symbol_table*> p = (*it);
        p.second->print_ST(p.first);
    }

}


// Implementations of constructors and functions for the quad class
quad::quad(string res_, string arg1_, string arg2_, opcode op_): op(op_), arg1(arg1_), arg2(arg2_), result(res_) {}

string quad::print_TAC() {
    string out = "";
    if(op >= ADD && op <= BW_XOR) {                 // Binary operators
        out += (result + " = " + arg1 + " ");
        switch(op) {
            case ADD: out += "+"; break;
            case SUB: out += "-"; break;
            case MULT: out += "*"; break;
            case DIV: out += "/"; break;
            case MOD: out += "%"; break;
            case SL: out += "<<"; break;
            case SR: out += ">>"; break;
            case BW_AND: out += "&"; break;
            case BW_OR: out += "|"; break;
            case BW_XOR: out += "^"; break;
        }
        out += (" " + arg2);
    }
    else if(op >= BW_U_NOT && op <= U_NEG) {        // Unary operators
        out += (result + " = ");
        switch(op) {
            case BW_U_NOT: out += "~"; break;
            case U_PLUS: out += "+"; break;
            case U_MINUS: out += "-"; break;
            case REFERENCE: out += "&"; break;
            case DEREFERENCE: out += "*"; break;
            case U_NEG: out += "!"; break;
        }
        out += arg1;
    }
    else if(op >= GOTO_EQ && op <= IF_FALSE_GOTO) { // Conditional operators
        out += ("if " + arg1 + " ");
        switch(op) {
            case GOTO_EQ: out += "=="; break;
            case GOTO_NEQ: out += "!="; break;
            case GOTO_GT: out += ">"; break;
            case GOTO_GTE: out += ">="; break;
            case GOTO_LT: out += "<"; break;
            case GOTO_LTE: out += "<="; break;
            case IF_GOTO: out += "!= 0"; break;
            case IF_FALSE_GOTO: out += "== 0"; break;
        }
        out += (" " + arg2 + " goto " + result);
    }
    else if(op >= CtoI && op <= CtoF) {             // Type Conversion functions
        out += (result + " = ");
        switch(op) {
            case CtoI: out += "CharToInt"; break;
            case ItoC: out += "IntToChar"; break;
            case FtoI: out += "FloatToInt"; break;
            case ItoF: out += "IntToFloat"; break;
            case FtoC: out += "FloatToChar"; break;
            case CtoF: out += "CharToFloat"; break;
        }
        out += ("(" + arg1 + ")");
    }

    else if(op == ASSIGN)                       // Assignment operator
        out += (result + " = " + arg1);
    else if(op == GOTO)                         // Goto
        out += ("goto " + result);
    else if(op == RETURN)                       // Return from a function
        out += ("return " + result);
    else if(op == PARAM)                        // Parameters for a function
        out += ("param " + result);
    else if(op == CALL) {                       // Call a function
        if(arg2.size() > 0)
            out += (arg2 + " = ");
        out += ("call " + result + ", " + arg1);
    }
    else if(op == ARR_R)                  // Array indexing
        out += (result + " = " + arg1 + "[" + arg2 + "]");
    else if(op == ARR_L)                  // Array indexing
        out += (result + "[" + arg2 + "] = " + arg1);
    else if(op == FUNC_BEG)                     // Function begin
        out += (result + ": ");
    else if(op == FUNC_END) {                   // Function end
        out += ("function " + result + " ends");
    }
    else if(op == L_DEREF)                      // Dereference
        out += ("*" + result + " = " + arg1);

    return out;
}


// Implementations of constructors and functions for the quad_TAC_arr class
void quad_TAC_arr::print_TAC() {
    for(int i = 0; i < 120; i++)
        cout << '-';
    cout << endl;
    cout << "THREE ADDRESS CODE (TAC):" << endl;
    for(int i = 0; i < 120; i++)
        cout << '-';
    cout << endl;

    // Print each of the TAC_quad_list one by one
    for(int i = 0; i < (int)TAC_quad_list.size(); i++) {
        if(TAC_quad_list[i].op != FUNC_BEG && TAC_quad_list[i].op != FUNC_END)
            cout << left << setw(4) << i << ":    ";
        else if(TAC_quad_list[i].op == FUNC_BEG)
            cout << endl << left << setw(4) << i << ": ";
        else if(TAC_quad_list[i].op == FUNC_END)
            cout << left << setw(4) << i << ": ";
        cout << TAC_quad_list[i].print_TAC() << endl;
    }
    cout << endl;
}


// Implementations of constructors and functions for the expression class
expression::expression(): order_dim(0), store_addr(NULL) {}


// Overloaded add_TAC functions
void add_TAC(string result, string arg1, string arg2, opcode op) {
    quad q(result, arg1, arg2, op);
    TAC_list.TAC_quad_list.push_back(q);
    next_instruction++;
}

void add_TAC(string result, int constant, opcode op) {
    quad q(result, to_string(constant), "", op);
    TAC_list.TAC_quad_list.push_back(q);
    next_instruction++;
}

void add_TAC(string result, char constant, opcode op) {
    quad q(result, to_string(constant), "", op);
    TAC_list.TAC_quad_list.push_back(q);
    next_instruction++;
}

void add_TAC(string result, float constant, opcode op) {
    quad q(result, to_string(constant), "", op);
    TAC_list.TAC_quad_list.push_back(q);
    next_instruction++;
}


// Implementation of the makelist function
list<int> makelist(int i) {
    list<int> l(1, i);
    return l;
}

// Implementation of the merge function
list<int> merge(list<int> list1, list<int> list2) {
    list1.merge(list2);
    return list1;
}

// Implementation of the backpatch function
void backpatch(list<int> l, int address) {
    string str = to_string(address);
    for(list<int>::iterator it = l.begin(); it != l.end(); it++) {
        TAC_list.TAC_quad_list[*it].result = str;
    }
}


// Implementation of the overloaded convertToType functions
void convertToType(expression* arg, expression* res, data_dtype toType) {
    if(res->type == toType)
        return;

    if(res->type == FLOAT) {
        if(toType == INT)
            add_TAC(arg->location, res->location, "", FtoI);
        else if(toType == CHAR)
            add_TAC(arg->location, res->location, "", FtoC);
    }
    else if(res->type == INT) {
        if(toType == FLOAT)
            add_TAC(arg->location, res->location, "", ItoF);
        else if(toType == CHAR)
            add_TAC(arg->location, res->location, "", ItoC);
    }
    else if(res->type == CHAR) {
        if(toType == FLOAT)
            add_TAC(arg->location, res->location, "", CtoF);
        else if(toType == INT)
            add_TAC(arg->location, res->location, "", CtoI);
    }
}

void convertToType(string t, data_dtype to, string f, data_dtype from) {
    if(to == from)
        return;
    
    if(from == FLOAT) {
        if(to == INT)
            add_TAC(t, f, "", FtoI);
        else if(to == CHAR)
            add_TAC(t, f, "", FtoC);
    }
    else if(from == INT) {
        if(to == FLOAT)
            add_TAC(t, f, "", ItoF);
        else if(to == CHAR)
            add_TAC(t, f, "", ItoC);
    }
    else if(from == CHAR) {
        if(to == FLOAT)
            add_TAC(t, f, "", CtoF);
        else if(to == INT)
            add_TAC(t, f, "", CtoI);
    }
}

// Implementation of the convertIntToBool function
void convertIntToBool(expression* expr) {
    if(expr->type != BOOL) {
        expr->type = BOOL;
        expr->falselist = makelist(next_instruction);    // Add falselist for boolean expressions
        add_TAC("", expr->location, "", IF_FALSE_GOTO);
        expr->truelist = makelist(next_instruction);     // Add truelist for boolean expressions
        add_TAC("", "", "", GOTO);
    }
}

// Implementation of the sizeOfType function
int sizeOfType(data_dtype t) {
    if(t == VOID)
        return 0;
    else if(t == CHAR)
        return 1;
    else if(t == INT)
        return 4;
    else if(t == POINTER)
        return 8;
    else if(t == FLOAT)
        return 8;
    else if(t == FUNCTION)
        return 0;
    else
        return 0;
}

// Implementation of the checkType function
string checkType(ST_entry_type t) {
    if(t.type == VOID)
        return "void";
    else if(t.type == CHAR)
        return "char";
    else if(t.type == INT)
        return "int";
    else if(t.type == FLOAT)
        return "float";
    else if(t.type == FUNCTION)
        return "function";

    else if(t.type == POINTER) {        // Depending on type of pointer
        string tp = "";
        if(t.next_elem_type == CHAR)
            tp += "char";
        else if(t.next_elem_type == INT)
            tp += "int";
        else if(t.next_elem_type == FLOAT)
            tp += "float";
        tp += string(t.pointers, '*');
        return tp;
    }

    else if(t.type == ARRAY) {          // Depending on type of array
        string tp = "";
        if(t.next_elem_type == CHAR)
            tp += "char";
        else if(t.next_elem_type == INT)
            tp += "int";
        else if(t.next_elem_type == FLOAT)
            tp += "float";
        vector<int> dim = t.dims;
        for(int i = 0; i < (int)dim.size(); i++) {
            if(dim[i])
                tp += "[" + to_string(dim[i]) + "]";
            else
                tp += "[]";
        }
        if((int)dim.size() == 0)
            tp += "[]";
        return tp;
    }

    else
        return "unknown";
}

// Implementation of the getInitVal function
string getInitVal(ST_entry* sym) {
    if(sym->initial_value != NULL) {
        if(sym->type.type == INT)
            return to_string(sym->initial_value->i);
        else if(sym->type.type == CHAR)
            return to_string(sym->initial_value->c);
        else if(sym->type.type == FLOAT)
            return to_string(sym->initial_value->f);
        else
            return "-";
    }
    else
        return "-";
}
