#include <iostream>
#include <vector>
#include <list>
using namespace std;

extern char* yytext; //external functions used by bison
extern int yyparse();

/*
    Forward Class Declarations
    ------------------
    ST_entry          
    ST_entry_type      
    symbol_table     

    quad            
    quad_TAC_arr        
*/

class ST_entry;         // Represents a row in the symbol table
class ST_entry_type;    // Represents the type of ST_entry
class symbol_table;     // Represents the symbol table data structure 

class quad_TAC;         // Denotes a TAC quad
class quad_TAC_arr;     // Denotes the entire list of quads
class array_data_type;  // Represents an array data type

/*
    Global variables used
    ---------------------
    currentSymbol       Pointer to the current symbol
    currentST           Pointer to the currently active symbol table
    globalST            Pointer to the global symbol table
    quadList            The list of quads for lazy spiting
    STCount             A count variable used for naming nested symbol tables
    blockName           A variable used for naming nested blocks in symbol tables
*/

extern ST_entry* curr_symbol;
extern symbol_table* curr_symb_table;
extern symbol_table* global_symb_table;
extern quad_TAC_arr quad_TAC_list;
extern int num_ST;
extern string block;


    // Class to represent the type of a ST_entry in the symbol table
    // these attributes will help us in finding the basic or derived array_data_type datatypes of the symbol table elements declared duirng declaration phase

class ST_entry_type {
public:
    //Member variables
    string type;                    // type of the symbol
    int width;                      // width eg: 1 for basic types and 10 for arr[10]
    ST_entry_type* derived_arr;     // symbol type for array_data_types i.e. derived data types i.e. multidimensional array_data_type 
    //for a = int array_data_type[10][20], a->type=arr, a->width = 10, a->derived_arr->type = arr, a->derived_arr->width = 20, a->array_data_typeType->array_data_typeType->type = int

    //Member function
    ST_entry_type(string type_, ST_entry_type* derived_arr_ = NULL, int width_ = 1); //constructor with default parameters
};


    // Class to represent a row/entry in the symbol table

class ST_entry {
public:

    // Member Variables
    string name;                        // name of the symbol(variable) entered in symbol table
    ST_entry_type* type;                // type of the symbol
    string value;                       //initial value of the variable if any or NULL
    int size;                           //size that is number of bytes used up by the variable 
    int offset;                         //offset of the symbol to keep track opf relative addressing 
    symbol_table* nested_symbol_table;  //nested_symbol_table for linking symbol tables of functions

    // Member functions
    ST_entry(string name_, string t = "int", ST_entry_type* derived_arr = NULL, int width = 0); // constructor with default ST_entry_type corresponding to a symbol of type int
    ST_entry* update_entry(ST_entry_type* t);                                                   // update the symbol table entry with the contents of t 
};


    // Class to represent the symbol table data structure
    

class array_data_type {
public:

    string arr_type;                 // type of array i.e. arr or pointer
    ST_entry* location;              // location of the array
    ST_entry* array_data_type;       // symbol table entry 
    ST_entry_type* type;             // used for multidimensional array 
};

class symbol_table {
public:
    // Member Variables
    string name;                    //name of the symbol
    int temporary_var;              //to keep a count of temporary variables in symbol table
    list<ST_entry> table;           //List of all symbols
    symbol_table* parent;           //pointer to parent in case the symbol table isn't the global symbol table

    // Member Functions
    symbol_table(string name_ = "NULL");    //constructor
    ST_entry* search_lexeme(string name);   //to return the pointer to symbol table entry given a lexeme/identifier name
    static ST_entry* generate_tem_var(ST_entry_type* t, string initValue = "");// to generate a temporray variable and insert it.

    void print_ST();    // prints the symbol table 
    void update_ST();   //updates the symbol table
};


    // Class to denote a quad in the Three Address Code translation
class quad_TAC {
public:

    // Member Variables
    string operation;
    string arg1;
    string arg2;
    string result;

    quad_TAC(string result, float arg1_, string operation = "=", string arg2_ = "");  //by default template for binary operation between float and strings
    quad_TAC(string result, int arg1_, string operation = "=", string arg2_ = "");    //by default template for binary operation between integer and strings
    quad_TAC(string result, string arg1_, string operation = "=", string arg2_ = ""); // by default template for binary operation between identrifiers or strings
    void print_quad();//to print the quad TAC in appropriate format
};


    // Class to denote the entire list of quad codes generated
class quad_TAC_arr {
public:
    vector<quad_TAC> quad_list; // vector of all quad codes generated

    void print_quad_list();
};



class expression {
public:
    string type;            // boolean or non_boolean
    ST_entry* location;     // symbol table entry position
    list<int> truelist;     // if boolean expression is true 
    list<int> falselist;    // if boolean expression is false
    list<int> nextlist;     // which instruction to exectute after the true/false control loop ends
};

class statement {
public:
    list<int> nextlist;     // list of keeping a track of what to execute after this statement.
};


/*
    add a quad of the form: result = arg1 op arg2 
    If arg2 is missing, operator is unary operator.
    If op is missing, result = arg1.
   
*/
void add_TAC(string operation, string result, string arg1 = "", string arg2 = ""); // TAC code for operation between strings i.e. identifiers or characters
void add_TAC(string operation, string result, int arg1, string arg2 = "");       // TAC code for operation between integer and strings
void add_TAC(string operation, string result, float arg1, string arg2 = "");     // TAC code for operation between float and strings

/*
    A global function to create a new list containing only i, an index into the array of quads, 
    and to return a pointer to the newly created list
*/
list<int> makelist(int i);

/*
    to concatenate two lists and return a pointer to the concatenated list
*/
list<int> merge(list<int> &list1, list<int> &list2);

/*
    to insert address as the target label for each of the quads on the list quad_list
*/
void backpatch(list<int> quad_list, int address);

/*
    Check if the types of the symbols s1 and s2 are same or not
*/
bool typecheck(ST_entry* &s1, ST_entry* &s2);
bool typecheck(ST_entry_type* t1, ST_entry_type* t2);

/*
    Converts a symbol of one type to another and returns a pointer to the converted symbol
*/
ST_entry* convertType(ST_entry* s, string t);

/*
    Converts an int to a string
*/
string convertIntToString(int i);

/*
    Converts a float to a string
*/
string convertFloatToString(float f);

/*
    Converts an int to a bool and adds required attributes
*/
expression* convertIntToBool(expression* expr);

/*
    Converts a bool to an int and adds required attributes
*/
expression* convertBoolToInt(expression* expr);

void move_to_table(symbol_table* temp); //to change the currently active symbol table to temp

int next_instr_count(); //count of next instructuin

int type_sizeof(ST_entry_type* t_var); // returns size of a data type

string print_type(ST_entry_type* t_var); // prints type of a symbol

