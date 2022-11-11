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

class ST_entry;         // Represents a row in the ST_entry table
class ST_entry_type;    // Represents the type of ST_entry
class symbol_table;     // Represents the ST_entry table data structure 

class quad_TAC;         // Denotes a TAC quad
class quad_TAC_arr;     // Denotes the entire list of quads
class array_data_type;  // Represents an array data type

/*
    Global variables used
    ---------------------
    curr_ST_entry       Pointer to the current ST_entry
    curr_symb_table           Pointer to the currently active ST_entry table
    global_symb_table            Pointer to the global ST_entry table
    quadList            The list of quads for lazy spiting
    num_ST             A count variable used for naming nested ST_entry tables
    blocationk           A variable used for naming nested blocationks in ST_entry tables
*/

extern ST_entry* curr_ST_entry;
extern symbol_table* curr_symb_table;
extern symbol_table* global_symb_table;
extern quad_TAC_arr quad_TAC_list;
extern int num_ST;
extern string blocationk;
extern string prev_var;


    // Class to represent the type of a ST_entry in the ST_entry table
    // these attributes will help us in finding the basic or derived array datadtype of the ST_entry table elements declared duirng declaration phase

class ST_entry_type {
public:
    //Member variables
    string type;                    // type of the ST_entry
    int width;                      // width eg: 1 for basic dtype and 10 for arr[10]
    ST_entry_type* derived_arr;     // ST_entry type for array i.e. derived data dtype i.e. multidimensional array_data_type 
    //for a = int array[10][20], a->type=arr, a->width = 10, a->derived_arr->type = arr, a->derived_arr->width = 20, a->array_data_typeType->array_data_typeType->type = int

    //Member function
    ST_entry_type(string type_, ST_entry_type* derived_arr_ = NULL, int width_ = 1); //constructor with default parameters
};


    // Class to represent a row/entry in the ST_entry table

class ST_entry {
public:

    // Member Variables
    string name;                        // name of the ST_entry(variable) entered in ST_entry table
    ST_entry_type* type;                // type of the ST_entry
    string value;                       //initial value of the variable if any or NULL
    int size;                           //size that is number of bytes used up by the variable 
    int offset;                         //offset of the ST_entry to keep track opf relative addressing 
    symbol_table* nested_symbol_table;  //nested_symbol_table for linking ST_entry tables of functions

    // Member functions
    ST_entry(string name_, string t = "int", ST_entry_type* derived_arr = NULL, int width = 0); // constructor with default ST_entry_type corresponding to a ST_entry of type int
    ST_entry* update_entry(ST_entry_type* t);                                                   // update the ST_entry table entry with the contents of t 
};


    // Class to represent the ST_entry table data structure
    

class array_data_type {
public:

    string arr_type;                 // type of array i.e. arr or pointer
    ST_entry* locationation;              // locationation of the array
    ST_entry* array;       // ST_entry table entry 
    ST_entry_type* type;             // used for multidimensional array 
};

class symbol_table {
public:
    // Member Variables
    string name;                    //name of the ST_entry
    int temporary_var;              //to keep a count of temporary variables in ST_entry table
    list<ST_entry> table;           //List of all ST_entrys
    symbol_table* parent;           //pointer to parent in case the ST_entry table isn't the global ST_entry table

    // Member Functions
    symbol_table(string name_ = "NULL");    //constructor
    ST_entry* search_lexeme(string name);   //to return the pointer to ST_entry table entry given a lexeme/identifier name
    static ST_entry* generate_tem_var(ST_entry_type* t, string initial_valueue = "");// to generate a temporray variable and insert it.

    void print_ST();    // prints the ST_entry table 
    void update_entry();   //updates the ST_entry table
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
    ST_entry* locationation;     // ST_entry table entry position
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


//Auxillary functions for backpatching
list<int> makelist(int i);
/*
    to create a new list containing only i, an index into the array of quads, 
    and to return a pointer to the newly created list
*/

list<int> merge_list(list<int> &list1, list<int> &list2);
/*
    to concatenate two lists and return a pointer to the concatenated list
*/

void backpatch(list<int> quad_list, int address);
/*
    inserts i as target label for each of the quads on the list pointed by p
*/


//Type compatibility testing function between two ST_entry table entries or two data dtype
bool typecheck(ST_entry* &s1, ST_entry* &s2);
bool typecheck(ST_entry_type* t1, ST_entry_type* t2);


// Type conversion functions to make both the data dtype compatible
ST_entry* convert_type(ST_entry* s, string t);
string convert_int_str(int i);               //convert int to string
string convert_float_str(float f);           //convert float to string
expression* convert_int_bool(expression* expr); //convert int to boolean
expression* convert_bool_int(expression* expr); //convert boolean to int


void move_to_table(symbol_table* temp); //to change the currently active ST_entry table to temp
int next_instr_count(); //count of next instructuin
int type_sizeof(ST_entry_type* t_var); // returns size of a data type
string check_type(ST_entry_type* t_var); // returns type of a ST_entry
