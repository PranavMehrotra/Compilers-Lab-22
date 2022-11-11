/**
* Pranav Mehrotra, 20CS10085
* Saransh Sharma, 20CS30065
* Compilers Laboratory
* Assignment 6
*
* Source file for translation
*/

#include "ass6_20CS10085_20CS30065_translator.h"
#include <iomanip>
using namespace std;


int next_instruction = 0;
int symbol_table::temporary_var = 0;

//Global symbols
quad_TAC_arr TAC_list;
symbol_table ST_global;
symbol_table* ST;


//to intialize a symbol
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


// constructor of a symbol
ST_entry::ST_entry(): nested_symbol_table(NULL) {}


// constructor of a symbol table with running offset set to 0
symbol_table::symbol_table(): offset(0) {}

ST_entry* symbol_table::search_lexeme(string name, data_dtype t, int pc) {
    if(table.count(name) == 0) 
    {
        //if the table doesn't contain the lexeme
        ST_entry* sym = new ST_entry();//create a new symbol

        //initialise other attributes
        sym->name = name;
        sym->type.type = t;
        sym->offset = offset;
        sym->initial_value = NULL;

        //if the symbol is normal variable
        if(pc == 0) {
            sym->size = sizeof_dtype(t);
            offset += sym->size;//update offset
        }
        else {
            //if the symbol is of type pointer or array
            sym->size = 8;//set size of pointer to 8
            sym->type.next_elem_type = t;
            sym->type.pointers = pc;
            sym->type.type = ARRAY;
        }
        list_ST_entry.push_back(sym);//add the symbol to table
        table[name] = sym;//appropriately map the symbol to lexeme
    }
    return table[name];//else directly return pointer to symbol table 
}

ST_entry* symbol_table::search_global_ST(string name) {
    return (table.count(name) ? table[name] : NULL);//if you can find the lexeme return its location else return null
}

string symbol_table::generate_tem_var(data_dtype t) {
    // Create the name for the temporary
    string tempName = "t" + to_string(symbol_table::temporary_var++);   //create a temporaray variable with name starting from t followed by current count of variable number
    // if temporary_var = 8  then this method will create a new variable with the name t9
    

    //create a new ST_entry object with type details from temp variable
    ST_entry* sym = new ST_entry();
    sym->name = tempName;
    sym->size = sizeof_dtype(t);
    sym->offset = offset;
    sym->type.type = t;
    sym->initial_value = NULL;

    offset += sym->size;

    // Add the temporary to the symbol table
    list_ST_entry.push_back(sym);
    table[tempName] = sym;  
    return tempName;
}

void symbol_table::print_ST(string table_name) {
    for(int i = 0; i < 120; i++) {
        cout << '*';
    }
    cout << endl;
    cout << "\nSymbol Table: " << setfill(' ') << left << setw(50) << table_name << endl;
    for(int i = 0; i < 120; i++)
        cout << '*';
    cout << endl;

    // Symbol Table Column names
    cout << setfill(' ') << left << setw(25) <<  "\nName";
    cout << left << setw(25) << "Type";
    cout << left << setw(20) << "Initial Value";
    cout << left << setw(15) << "Size";
    cout << left << setw(15) << "Offset";
    cout << left << "Nested" << endl;

    //codes for basic formatting 
    for(int i = 0; i < 120; i++)
        cout << '*';
    cout << endl;
    cout<<"\n";

    // For storing nested symbol table
    vector<pair<string, symbol_table*>> tableList;

    //setfill sets the remaining character of width with space i.e. name will be printed with a width of 50 where the remaining places are replaced by space
    // Print the list_ST_entry in the ST_entry table
    for(int i = 0; i < (int)list_ST_entry.size(); i++) {
        ST_entry* sym = list_ST_entry[i];
        cout << left << setw(25) << sym->name;
        cout << left << setw(25) << typecheck(sym->type);
        cout << left << setw(20) << get_initial(sym);
        cout << left << setw(15) << sym->size;
        cout << left << setw(15) << sym->offset;
        cout << left;

        // Print the symbols in the symbol table
        //cout<<left makes padding at end and setw sets the width of symbol
    
        //in case the symbol table has nested symbol table
        if(sym->nested_symbol_table != NULL) {
            string nested_symbol_table_name = table_name + "." + sym->name;//print the name of nested symbol table
            cout << nested_symbol_table_name << endl;
            tableList.push_back({nested_symbol_table_name, sym->nested_symbol_table});//push all nested tabels
        }
        else
            cout << "NULL" << endl;//else print null
    }

    for(int i = 0; i < 120; i++)
        cout << '*';
    cout << endl << endl;

    // Recursively call the print function for the nested ST_entry tables
    for(vector<pair<string, symbol_table*>>::iterator it = tableList.begin(); it != tableList.end(); it++) {
        pair<string, symbol_table*> p = (*it);
        p.second->print_ST(p.first);
    }

}


// Implementations of constructors and functions for the quad class
//constructor
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


void quad_TAC_arr::print_TAC() {
    for(int i = 0; i < 120; i++)
        cout << '*';
    cout << endl;
    cout << "\nTHREE ADDRESS CODE (TAC):" << endl;
    for(int i = 0; i < 120; i++)
        cout << '*';
    cout<<'\n' << endl;

    // Print TAC in appropriate format
    for(int i = 0; i < (int)TAC_quad_list.size(); i++) {
        if(TAC_quad_list[i].op != FUNC_BEG && TAC_quad_list[i].op != FUNC_END)
            cout << left << setw(4) << i << ":    ";
        else if(TAC_quad_list[i].op == FUNC_BEG)
            cout << endl << left << setw(4) << i << ": ";
        else if(TAC_quad_list[i].op == FUNC_END)
            cout << left << setw(4) << i << ": ";//print the label and print the function symbol table once all TAC of function have been read
        cout << TAC_quad_list[i].print_TAC() << endl;
    }
    cout << endl;
}


//constructors
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
list<int> merge_list(list<int> list1, list<int> list2) {
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
void convertToType(expression* arg, expression* input, data_dtype data_type) {
    if(input->type == data_type)
        return;

    if(input->type == FLOAT) {
        if(data_type == INT)
            add_TAC(arg->location, input->location, "", FtoI);
        else if(data_type == CHAR)
            add_TAC(arg->location, input->location, "", FtoC);
    }
    else if(input->type == INT) {
        if(data_type == FLOAT)
            add_TAC(arg->location, input->location, "", ItoF);
        else if(data_type == CHAR)
            add_TAC(arg->location, input->location, "", ItoC);
    }
    else if(input->type == CHAR) {
        if(data_type == FLOAT)
            add_TAC(arg->location, input->location, "", CtoF);
        else if(data_type == INT)
            add_TAC(arg->location, input->location, "", CtoI);
    }
}

void convertToType(string t, data_dtype target, string f, data_dtype source) {
    if(target == source)
        return;
    
    if(source == FLOAT) {
        if(target == INT)
            add_TAC(t, f, "", FtoI);
        else if(target == CHAR)
            add_TAC(t, f, "", FtoC);
    }
    else if(source == INT) {
        if(target == FLOAT)
            add_TAC(t, f, "", ItoF);
        else if(target == CHAR)
            add_TAC(t, f, "", ItoC);
    }
    else if(source == CHAR) {
        if(target == FLOAT)
            add_TAC(t, f, "", CtoF);
        else if(target == INT)
            add_TAC(t, f, "", CtoI);
    }
}

// Implementation of the convert_int_bool function
void convert_int_bool(expression* expr) {
    if(expr->type != BOOL) {
        expr->type = BOOL;
        expr->falselist = makelist(next_instruction);    // Add falselist for boolean expressions
        add_TAC("", expr->location, "", IF_FALSE_GOTO);
        expr->truelist = makelist(next_instruction);     // Add truelist for boolean expressions
        add_TAC("", "", "", GOTO);
    }
}

// Implementation of the sizeof_dtype function
int sizeof_dtype(data_dtype t) {
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

// Implementation of the typecheck function
string typecheck(ST_entry_type t) {
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
        if(t.next_elem_type == CHAR)//char *
            tp += "char";
        else if(t.next_elem_type == INT)//int *
            tp += "int";
        else if(t.next_elem_type == FLOAT)//float *
            tp += "float";
        tp += string(t.pointers, '*');
        return tp;
    }

    else if(t.type == ARRAY) {          // Depending on type of array
        string tp = "";
        if(t.next_elem_type == CHAR)//char[dimension] or char[]
            tp += "char";
        else if(t.next_elem_type == INT)//int[dimension] or int[]
            tp += "int";
        else if(t.next_elem_type == FLOAT)//float[dimension] or float[]
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
        return "unknown";//to flag an error or invalid data
}

// return the intial value stored in i,c,f depending upon type of variable
string get_initial(ST_entry* sym) {
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
