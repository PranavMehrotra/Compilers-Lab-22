
#ifndef __TRANSLATOR_H
#define __TRANSLATOR_H

#include <iostream>
#include <vector>
#include <list>
#include <map>
using namespace std;


//enum specifying all legal data types
typedef enum {
    VOID,
    BOOL,
    CHAR,
    INT,
    FLOAT,
    ARRAY,
    POINTER,
    FUNCTION
} data_dtype;


//enum spcifying all legal opcodes
typedef enum  {
    ADD, SUB, MULT, DIV, MOD, SL, SR, //arithmetic
    BW_AND, BW_OR, BW_XOR, //binary operator
    BW_U_NOT ,U_PLUS, U_MINUS, REFERENCE, DEREFERENCE, U_NEG,//unary operators 
    GOTO_EQ, GOTO_NEQ, GOTO_GT, GOTO_GTE, GOTO_LT, GOTO_LTE, IF_GOTO, IF_FALSE_GOTO,//jump/ conditional jumps 
    CtoI, ItoC, FtoI, ItoF, FtoC ,CtoF,//type conversion 
    ASSIGN, GOTO, RETURN, PARAM, CALL, ARR_R, ARR_L, FUNC_BEG, FUNC_END, L_DEREF//miscellenous
} opcode;


class ST_entry;                 //Represents a symbol in the symbol table
class ST_entry_type;            //Represents the type of symbol
class ST_entry_value;           //Represents the value of the symbol
class symbol_table;             //data structure containing list of symbols i.e. symbol table

class quad;                     //a quad format code
class quad_TAC_arr;             //list of TAC_quad_list that will be used to print TAC codes      


//External functions exported from bison
extern char* yytext;
extern int yyparse();

class ST_entry_type {
    //type of symbol 
public: 
    int pointers;                       //only useful in case the symbol is of type pointer
    data_dtype type;                    //The data type of the symbol
    data_dtype next_elem_type;          //pointer to the type of elements in an arary or the data pointed to by a pointer
    vector<int> dims;                   //dimension of an array stored in the form of vector
};


class ST_entry_value {
//value of a symbol
public:
    int i;                          //to store int value
    char c;                         //to store char value
    float f;                        //to store float value
    void* p;                        //to store pointer value

    void initialize(int val);       //member function to assign initial value to member variables 
    void initialize(char val);
    void initialize(float val);
};

class ST_entry {
//symbol table row
public:
    string name;                            //name of symbol
    ST_entry_type type;                     //type of symbol
    ST_entry_value* initial_value;          //intial value of symbol
    int size;                               //size of symbol 
    int offset;                             //offset to keep track of relative addressing
    symbol_table* nested_symbol_table;      //nested_symbol_table for blocks and functions

    ST_entry();                             //constructor
};


class symbol_table {
public:
    map<string, ST_entry*> table;                                                   //map to map lexeme with its symbol table entry
    vector<ST_entry*> list_ST_entry;                                                //list of all suymbol table entries
    int offset;                                                                     //running value of offset
    static int temporary_var;                                                       //to keep track of number of temporary variables created

    symbol_table();                                                                 //constructor
    ST_entry* search_lexeme(string name, data_dtype t = INT, int pc = 0);           //search function to search for symbol table entry of lexeme
    ST_entry* search_global_ST(string name);                                        //search function to search for lexeme in global symbol table
    string generate_tem_var(data_dtype t = INT);                                    //generate temporary variable in symbol table
    void print_ST(string tableName);                                                //print symbol table
};

class quad {
//to store tac codes in quad format
public:
    opcode op;                                                          //opcode
    string arg1;                                                        //argument 1
    string arg2;                                                        //argumnet 2
    string result;                                                      //result 
    //result = arg1 op arg2
    quad(string, string, string, opcode);                               //generate a quad datastructure to store quad commands

    string print_TAC();                                                 //print TAC code in appropriate format
};

class quad_TAC_arr {
public:
    vector<quad> TAC_quad_list;//list of TAC codes which would be printed afterwards at one go

    void print_TAC();
};


//param class will be used to define parameters of function
class param {
public:
    string name;                //name of parameter
    ST_entry_type type;         //type of parameter
};


class expression {
public:
    int instr;                  //instruction number
    data_dtype type;            //type of instruction i.e. bool or non bool
    string location;            //location of the expression in symbol table
    list<int> truelist;         //truelist i.e. list of intructions that will jump to label if the expression evaluated to true
    list<int> falselist;        //falselist 
    list<int> nextlist;         //nextlist
    int order_dim;              //order_dim to keep track of dimension of arrays and pointers
    string* store_addr;         //store_addr keeps a track of expression address whose address is provided in case expression is of type array or pointer

    expression();               //constructor for expression
};


/*
    Class to represent a declaration
    class declaration
    ------------
    Member Variables:
        name: string                Name of the declaration
        pointers: int               Number of pointers
        type: data_dtype              Type of the declaration
        li: vector<int>             List of instructions for the declaration
        initial_value: expression*        Initial value of the declaration
        pc: int                     Useful for pointers and arrays
*/
class declaration 
{ //declaration class
public:
    string name;            //name of declaration
    int pointers;           //number of pointers in the declaration 
    data_dtype type;        //data type of all the elements present in the declaration
    data_dtype next_elem_type;  //next element type would be relevant in case data type of declaration is array or pointer
    
    //next element type would contain data type of elements in array/pointer
    vector<int> li; //list of instructions for the declaration
    expression* initial_value;//initial value of the declaration
    int pc;//
};


/*
    An overloaded method to add a (newly generated) quad of the form: result = arg1 op arg2 where op usually is a binary operator. 
    If arg2 is missing, op is unary. If op also is missing, this is a copy instruction.
    It is overloaded for different dtype of TAC_quad_list (int, float or string)
*/
void add_TAC(string result, string arg1, string arg2, opcode op);
void add_TAC(string result, int constant, opcode op);
void add_TAC(string result, char constant, opcode op);
void add_TAC(string result, float constant, opcode op);


/*
    A global function to create a new list containing only i, an index into the array of TAC_quad_list, 
    and to return a pointer to the newly created list
*/
list<int> makelist(int i);

/*
    A global function to concatenate two lists list1 and list2 and to return a pointer to the concatenated list
*/
list<int> merge(list<int> list1, list<int> list2);

/*
    A global function to insert address as the target label for each of the TAC_quad_list on the list l
*/
void backpatch(list<int> l, int address);

/*
    Converts a ST_entry of one type to another and returns a pointer to the converted ST_entry
*/
void convertToType(expression* arg, expression* res, data_dtype toType);

void convertToType(string t, data_dtype to, string f, data_dtype from);

/*
    Converts an int to a bool and adds required attributes
*/
void convertIntToBool(expression* expr);

/*
    Auxiliary function to get the size of a type
*/
int sizeOfType(data_dtype t);

/*
    Auxiliary function to print a type
*/
string checkType(ST_entry_type t);

/*
    Auxiliary function to get the initial value of a ST_entry
*/
string getInitVal(ST_entry* sym);

#endif