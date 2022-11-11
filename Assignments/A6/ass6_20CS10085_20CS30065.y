%{
    #include <iostream>
    #include "ass6_20CS10085_20CS30065_translator.h"
    using namespace std;

    //from lexer
    extern int yylex();                     
    extern char* yytext;                    
    extern int yylineno;                    

    //to report error in bison
    void yyerror(string s);                 

    //to keep track of global data structures shared across all files
    extern int next_instruction;                   
    extern quad_TAC_arr TAC_list;              
    extern symbol_table ST_global;            
    extern symbol_table* ST;                 
    extern vector<string> string_constants;     

    int num_strings = 0;                       
%}

%union {
    //set of placeholders
    int intval;                     // For integer variable
    char charval;                   // For char variable
    float floatval;                 // For float variable
    void* ptr;                      // For pointer
    string* str;                    // For string

    ST_entry_type* symType;            
    ST_entry* symp;                   
    data_dtype dtype;                 
    opcode opc;                     
    expression* expr;               
    declaration* dec;               
    vector<declaration*> *decList;  
    param* parameter;                     
    vector<param*> *parameterList;        
}

/*
    All tokens
*/
%token AUTO BREAK CASE CHAR_ CONST CONTINUE DEFAULT DO DOUBLE ELSE ENUM EXTERN FLOAT_ FOR GOTO_ IF INLINE INT_ LONG REGISTER RESTRICT RETURN_ SHORT SIGNED SIZEOF STATIC STRUCT SWITCH TYPEDEF UNION UNSIGNED VOID_ VOLATILE WHILE BOOL_ COMPLEX IMAGINARY
%token LEFT_SQUARE RIGHT_SQUARE LEFT_PARENTHESIS RIGHT_PARENTHESIS LEFT_CURLY RIGHT_CURLY 
%token DOT ARROW SELF_INCREASE SELF_DECREASE BITWISE_AND MUL PLUS SUBTRACT BITWISE_NOR EXCLAMATION F_SLASH MODULO 
%token LEFT_SHIFT RIGHT_SHIFT LESS_THAN GREATER_THAN LESS_THAN_EQUAL GREATER_THAN_EQUAL EQUAL NOT_EQUAL BITWISE_XOR BITWISE_OR 
%token LOGICAL_AND LOGICAL_OR QUESTION_MARK COLON SEMICOLON ELLIPSIS 
%token ASSIGN_ MUL_ASSIGN F_SLASH_ASSIGN MODULO_ASSIGN PLUSASSIGN SUBTRACT_ASSIGN LEFT_SHIFT_ASSIGN RIGHT_SHIFT_ASSIGN BITWISE_AND_ASSIGN BITWISE_XOR_ASSIGN BITWISE_OR_ASSIGN COMMA HASH

// identifier
%token <str> IDENTIFIER

// integral constant
%token <intval> INTEGER_CONSTANT

// floating constant
%token <floatval> FLOATING_CONSTANT

//character constant
%token <charval> CHAR_CONSTANT

// string literals
%token <str> STRING_LITERAL

// Non-terminals of type expression
%type <expr> 
        expression
        primary_expression 
        multiplicative_expression
        additive_expression
        shift_expression
        relational_expression
        equality_expression
        and_expression
        exclusive_or_expression
        inclusive_or_expression
        logical_and_expression
        logical_or_expression
        conditional_expression
        assignment_expression
        postfix_expression
        unary_expression
        cast_expression
        expression_statement
        statement
        compound_statement
        selection_statement
        iteration_statement
        labeled_statement 
        jump_statement
        block_item
        block_item_list
        initializer
        M
        N

// Non-terminals for unary operator
%type <charval> unary_operator

// The pointer non-terminal 
%type <intval> pointer

// data type declarators
%type <dtype> type_specifier declaration_specifiers

// declartion type non terminals
%type <dec> direct_declarator initializer_list init_declarator declarator function_prototype

// list of declartions
%type <decList> init_declarator_list

// Non-terminals of type param
%type <parameter> parameter_declaration

// Non-terminals of type parameterList
%type <parameterList> parameter_list parameter_type_list parameter_type_list_opt argument_expression_list

// removes dangling else ambiguity
%expect 1
%nonassoc ELSE

// The start state is translation_unit
%start translation_unit

%%

primary_expression: 
        IDENTIFIER
        {
            $$ = new expression();                      // new expression node
            string s = *($1);
            ST->search_lexeme(s);                       //store the identifier in symbol table
            $$->location = s;                           // s now points to the pointer to symbol table entry
        }
        | INTEGER_CONSTANT
        {
            $$ = new expression();                  // new expression node
            $$->location = ST->generate_tem_var(INT);             // create a temporary variable to store the value
            add_TAC($$->location, $1, ASSIGN);          //create a TAC quad to assign the value of constant to temporary variable
            ST_entry_value* val = new ST_entry_value();
            val->initialize($1);                        // intialise 
            ST->search_lexeme($$->location)->initial_value = val;     // update the intial value of temporary variable
        }
        | FLOATING_CONSTANT
        {
            $$ = new expression();                  // new expression node
            $$->location = ST->generate_tem_var(FLOAT);           //create a temporary variable to store the value
            add_TAC($$->location, $1, ASSIGN);          //create a TAC quad to assign the value of constant to temporary variable
            ST_entry_value* val = new ST_entry_value();
            val->initialize($1);                    // // intialise 
            ST->search_lexeme($$->location)->initial_value = val;      // update the intial value of temporary variable
        }
        | CHAR_CONSTANT
        {
            $$ = new expression();                  // new expression node
            $$->location = ST->generate_tem_var(CHAR);            //create a temporary variable to store the value
            add_TAC($$->location, $1, ASSIGN);  //create a TAC quad to assign the value of constant to temporary variable
            ST_entry_value* val = new ST_entry_value();
            val->initialize($1);                    // intialise 
            ST->search_lexeme($$->location)->initial_value = val;      // update the intial value of temporary variable
        }
        | STRING_LITERAL
        {
            $$ = new expression();                          // new expression node
            $$->location = ".LC" + to_string(num_strings++);//create a new string label with prefix LC that indicates string parameters in .s files
            string_constants.push_back(*($1));          // update the number of strings, that will be used in naming label 
                                                        //add the string to set of string constants
        }
        | LEFT_PARENTHESIS expression RIGHT_PARENTHESIS
        {
            $$ = $2;                                // copy content from right to left
        }
        ;

postfix_expression: 
        primary_expression
        {}
        | postfix_expression LEFT_SQUARE expression RIGHT_SQUARE
        {
            //to compute address of array
            ST_entry_type to = ST->search_lexeme($1->location)->type;      // extract the type of variable
            string f = "";
            if(!($1->order_dim)) {
                f = ST->generate_tem_var(INT);                       // Generate a new temporary variable
                add_TAC(f, 0, ASSIGN);
                $1->store_addr = new string(f);
            }
            string temp = ST->generate_tem_var(INT);

            
            add_TAC(temp, $3->location, "", ASSIGN);                //t = E.addr
            add_TAC(temp, temp, "4", MULT);                         //t = t * 4
            add_TAC(f, temp, "", ASSIGN);                           //f = t
            $$ = $1;
        }
        | postfix_expression LEFT_PARENTHESIS RIGHT_PARENTHESIS
        {  
             
            //function call with the function name no parameter
            symbol_table* function_ST = ST_global.search_lexeme($1->location)->nested_symbol_table;
            add_TAC($1->location, "0", "", CALL);   //call func_name, 0
        
        }
        | postfix_expression LEFT_PARENTHESIS argument_expression_list RIGHT_PARENTHESIS
        {   

            //function call with the function name and parameter list
            symbol_table* function_ST = ST_global.search_lexeme($1->location)->nested_symbol_table;
            vector<param*> parameters = *($3);                                      // Get the list of parameters
            vector<ST_entry*> paramsList = function_ST->list_ST_entry;

            for(int i = 0; i < (int)parameters.size(); i++) {
                add_TAC(parameters[i]->name, "", "", PARAM);                        //create a tac for each of the parameter
            }

            data_dtype return_type = function_ST->search_lexeme("RETVAL")->type.type;  // extract the return type of the function
            if(return_type == VOID)                                                     // If the function returns void
                add_TAC($1->location, (int)parameters.size(), CALL);                //tac would be like call func_name, param_num

            else {                                                                  // If the function returns a value
                string return_value = ST->generate_tem_var(return_type);                      //generate a temporary variable to store return value
                add_TAC($1->location, to_string(parameters.size()), return_value, CALL);  //t = call func_name, paaram_num
                $$ = new expression();
                $$->location = return_value;                                              
            }
        }
        | postfix_expression DOT IDENTIFIER
        {}
        | postfix_expression ARROW IDENTIFIER
        {}
        | postfix_expression SELF_INCREASE
        {   
            //for a++: t = a, a = t + 1
            $$ = new expression();                                                          // new expression node
            ST_entry_type t = ST->search_lexeme($1->location)->type;                       // generate a temporary vraiable of the same type as of the varible
            
            if(t.type == ARRAY) 
            {   //if the type of variable is array
                //ARR_R is like a = b[i]
                //ARR_L is like a[i] = b            

                $$->location = ST->generate_tem_var(ST->search_lexeme($1->location)->type.next_elem_type);
                add_TAC($$->location, $1->location, *($1->store_addr), ARR_R); //assign the old value of $$
                string temp = ST->generate_tem_var(t.next_elem_type);
                add_TAC(temp, $1->location, *($1->store_addr), ARR_R);  //t = a[i]
                add_TAC(temp, temp, "1", ADD);                      //t = t+1;
                add_TAC($1->location, temp, *($1->store_addr), ARR_L);  //a[i] = t
            }
            else {
                $$->location = ST->generate_tem_var(ST->search_lexeme($1->location)->type.type);
                
                //t = a++ i.e. t=a and a=a+1
                add_TAC($$->location, $1->location, "", ASSIGN);                         // return the old value 
                add_TAC($1->location, $1->location, "1", ADD);                           // then update the value by 1
            }
        }
        | postfix_expression SELF_DECREASE
        {
            //follow similar to self increment
            $$ = new expression();                                          // new expression node
            $$->location = ST->generate_tem_var(ST->search_lexeme($1->location)->type.type);          // Generate a new temporary variable
            ST_entry_type t = ST->search_lexeme($1->location)->type;
            if(t.type == ARRAY) {
                $$->location = ST->generate_tem_var(ST->search_lexeme($1->location)->type.next_elem_type);
                string temp = ST->generate_tem_var(t.next_elem_type);
                add_TAC(temp, $1->location, *($1->store_addr), ARR_R);
                add_TAC($$->location, temp, "", ASSIGN);
                add_TAC(temp, temp, "1", SUB);
                add_TAC($1->location, temp, *($1->store_addr), ARR_L);
            }
            else {
                $$->location = ST->generate_tem_var(ST->search_lexeme($1->location)->type.type);
                add_TAC($$->location, $1->location, "", ASSIGN);                         // return the old value
                add_TAC($1->location, $1->location, "1", SUB);                           // the update the value by decreasing by 1
            }
        }
        | LEFT_PARENTHESIS type_name RIGHT_PARENTHESIS LEFT_CURLY initializer_list RIGHT_CURLY
        {}
        | LEFT_PARENTHESIS type_name RIGHT_PARENTHESIS LEFT_CURLY initializer_list COMMA RIGHT_CURLY
        {}
        ;

argument_expression_list: 
        assignment_expression
        {
            param* first = new param();                     // Create a new parameter
            first->name = $1->location;                     //param would point to the symbol tabel entry of the parameter
            first->type = ST->search_lexeme($1->location)->type;//set the type of parameter
            $$ = new vector<param*>;
            $$->push_back(first);                       // Add the parameter to the list to keep track of all parameters
        }
        | argument_expression_list COMMA assignment_expression
        {
            //if there are more than first_operand parameters
            param* next = new param();                  // Create a new parameter
            next->name = $3->location;                  //set type and name of parameter
            next->type = ST->search_lexeme(next->name)->type;
            $$ = $1;
            $$->push_back(next);                        // Add the parameter to the list created in the above production. this list would contain all parameters name relevant to a function
        }
        ;

unary_expression: 
        postfix_expression
        {}
        | SELF_INCREASE unary_expression
        {
            $$ = new expression();
            ST_entry_type type = ST->search_lexeme($2->location)->type;
            if(type.type == ARRAY) {
                string t = ST->generate_tem_var(type.next_elem_type);
                add_TAC(t, $2->location, *($2->store_addr), ARR_R); //t = a[i]
                add_TAC(t, t, "1", ADD);                        //t = t+1
                add_TAC($2->location, t, *($2->store_addr), ARR_L); //a[i] = t
                $$->location = ST->generate_tem_var(ST->search_lexeme($2->location)->type.next_elem_type);
            }
            else {
                add_TAC($2->location, $2->location, "1", ADD);                       // Increment the value
                $$->location = ST->generate_tem_var(ST->search_lexeme($2->location)->type.type);
            }
            $$->location = ST->generate_tem_var(ST->search_lexeme($2->location)->type.type);
            add_TAC($$->location, $2->location, "", ASSIGN);                         // Assign the updated value to $$
        }
        | SELF_DECREASE unary_expression
        {
            $$ = new expression();
            ST_entry_type type = ST->search_lexeme($2->location)->type;
            if(type.type == ARRAY) {
                string t = ST->generate_tem_var(type.next_elem_type);
                add_TAC(t, $2->location, *($2->store_addr), ARR_R);
                add_TAC(t, t, "1", SUB);
                add_TAC($2->location, t, *($2->store_addr), ARR_L);
                $$->location = ST->generate_tem_var(ST->search_lexeme($2->location)->type.next_elem_type);
            }
            else {
                add_TAC($2->location, $2->location, "1", SUB);                       // Decrement the value
                $$->location = ST->generate_tem_var(ST->search_lexeme($2->location)->type.type);
            }
            add_TAC($$->location, $2->location, "", ASSIGN);                         // Assign the updated value to $$
        }
        | unary_operator cast_expression
        {
            // handle different unary operator using switch
            
            switch($1) {
                case '&':       // Address of variable i.e &n
                    $$ = new expression();
                    $$->location = ST->generate_tem_var(POINTER);                 // Generate temporary of the same data type i.e. pointer
                    add_TAC($$->location, $2->location, "", REFERENCE);          // this would be a reference operator a = &n 
                    break;
                case '*':   // De-referencing
                    $$ = new expression();
                    $$->location = ST->generate_tem_var(INT);                       // Generate temporary of the same data type
                    $$->order_dim = 1;                                                   //order_dim keeps a track of dimension
                    $$->store_addr = new string($2->location);                          //store_addr keeps a track of expression address whose address is provided
                    add_TAC($$->location, $2->location, "", DEREFERENCE);           // generate TAC quad a = *n
                    break;
                case '-':   // Unary minus
                    $$ = new expression();
                    $$->location = ST->generate_tem_var();                        // Generate temporary of the same data type
                    add_TAC($$->location, $2->location, "", U_MINUS);            // generate TAC quad
                    //$$ = -$2
                    break;
                case '!':   // Logical not 
                    $$ = new expression();
                    $$->location = ST->generate_tem_var(INT);                     // Generate temporary of the same data type
                    int temp = next_instruction + 2;
                    add_TAC(to_string(temp), $2->location, "0", GOTO_EQ);   
                    temp = next_instruction + 3;                            
                    add_TAC(to_string(temp), "", "", GOTO);                 
                    add_TAC($$->location, "1", "", ASSIGN);                 
                    temp = next_instruction + 2;
                    add_TAC(to_string(temp), "", "", GOTO);
                    add_TAC($$->location, "0", "", ASSIGN);
                    break;
            }
            /*
                in: if $2==0 goto in+2
                in+1: goto in+3
                in+2: $$ = 1
                in+3: goto in+4
                in+4: $$ = 0
            */

        }
        | SIZEOF unary_expression
        {}
        | SIZEOF LEFT_PARENTHESIS type_name RIGHT_PARENTHESIS
        {}
        ;

unary_operator:
        BITWISE_AND
        {
            $$ = '&';
        }
        | MUL
        {
            $$ = '*';
        }
        | PLUS
        {
            $$ = '+';
        }
        | SUBTRACT
        {
            $$ = '-';
        }
        | BITWISE_NOR
        {
            $$ = '~';
        }
        | EXCLAMATION
        {
            $$ = '!';
        }
        ;

cast_expression: 
        unary_expression
        {}
        | LEFT_PARENTHESIS type_name RIGHT_PARENTHESIS cast_expression
        {}
        ;

/*
To involve an arry in an expression, we need to find the correct address depending upon the indexing
and width of the array. temporary variables storing the appropriate address would be used for indexing

else for normal variables directly assign the values
*/


multiplicative_expression: 
        cast_expression
        {
            $$ = new expression();                                  // Generate new expression
            ST_entry_type tp = ST->search_lexeme($1->location)->type;
            if(tp.type == ARRAY) {                                      // If the type is an array
                
                // Generate new temporary variable to store the value of array at the index
                string t = ST->generate_tem_var(tp.next_elem_type);                // Generate a temporary
                if($1->store_addr != NULL) {
                    add_TAC(t, $1->location, *($1->store_addr), ARR_R);   
                    $1->location = t;                                 
                    $1->type = tp.next_elem_type; 
                    $$ = $1;
                }
                else
                    $$ = $1;        // copy content from right to left
            }
            else
                $$ = $1;            // copy content from right to left
        }
        | multiplicative_expression MUL cast_expression
        {   
            // Indicates multiplication
            // Arithmetic operation requires both the operands to be of compatible type 
            $$ = new expression();
            ST_entry* first_operand = ST->search_lexeme($1->location);                      // Get the first operand from the ST_entry table
            ST_entry* second_operand = ST->search_lexeme($3->location);                     // Get the second operand from the ST_entry table
            if(second_operand->type.type == ARRAY) {                                        // If the second operand is an array, perform necessary operations 
            
            //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed
                
                string t = ST->generate_tem_var(second_operand->type.next_elem_type);
                add_TAC(t, $3->location, *($3->store_addr), ARR_R);
                $3->location = t;
                $3->type = second_operand->type.next_elem_type;
            }
            if(first_operand->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations

                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed
                string t = ST->generate_tem_var(first_operand->type.next_elem_type);
                add_TAC(t, $1->location, *($1->store_addr), ARR_R);
                $1->location = t;
                $1->type = first_operand->type.next_elem_type;            //next_elem_type keeps the type of elements pointer by pointer or array
            }

            // data type of result of the multiplication will depend upon relative precedance of data type of both operands 
            //assign data type after appropriate typecasting
            data_dtype final = ((first_operand->type.type > second_operand->type.type) ? (first_operand->type.type) : (second_operand->type.type));
            $$->location = ST->generate_tem_var(final);                       // Store the final result in a temporary
            add_TAC($$->location, $1->location, $3->location, MULT);
        }
        | multiplicative_expression F_SLASH cast_expression
        {
            // Indicates division
            $$ = new expression();
            ST_entry* first_operand = ST->search_lexeme($1->location);                  // Get the first operand from the ST_entry table
            ST_entry* second_operand = ST->search_lexeme($3->location);                  // Get the second operand from the ST_entry table
            if(second_operand->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed
                
                string t = ST->generate_tem_var(second_operand->type.next_elem_type);
                add_TAC(t, $3->location, *($3->store_addr), ARR_R);
                $3->location = t;
                $3->type = second_operand->type.next_elem_type;
            }
            if(first_operand->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations

                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed
                string t = ST->generate_tem_var(first_operand->type.next_elem_type);
                add_TAC(t, $1->location, *($1->store_addr), ARR_R);
                $1->location = t;
                $1->type = first_operand->type.next_elem_type;
            }

            //assign data type after appropriate typecasting
            data_dtype final = ((first_operand->type.type > second_operand->type.type) ? (first_operand->type.type) : (second_operand->type.type));
            $$->location = ST->generate_tem_var(final);                       // Store the final result in a temporary
            add_TAC($$->location, $1->location, $3->location, DIV);
        }
        | multiplicative_expression MODULO cast_expression
        {
            // Indicates modulo
            $$ = new expression();
            ST_entry* first_operand = ST->search_lexeme($1->location);                  // Get the first operand from the ST_entry table
            ST_entry* second_operand = ST->search_lexeme($3->location);                  // Get the second operand from the ST_entry table
            
            if(second_operand->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed
                
                string t = ST->generate_tem_var(second_operand->type.next_elem_type);
                add_TAC(t, $3->location, *($3->store_addr), ARR_R);
                $3->location = t;
                $3->type = second_operand->type.next_elem_type;
            }
            
            if(first_operand->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed
                string t = ST->generate_tem_var(first_operand->type.next_elem_type);
                add_TAC(t, $1->location, *($1->store_addr), ARR_R);
                $1->location = t;
                $1->type = first_operand->type.next_elem_type;
            }

            // Assign the data type after suitable typecasting
            data_dtype final = ((first_operand->type.type > second_operand->type.type) ? (first_operand->type.type) : (second_operand->type.type));
            $$->location = ST->generate_tem_var(final);                       // Store the final result in a temporary
            add_TAC($$->location, $1->location, $3->location, MOD);
        }
        ;

additive_expression: 
        multiplicative_expression
        {}
        | additive_expression PLUS multiplicative_expression
        {   
            // Indicates addition
            $$ = new expression();
            ST_entry* first_operand = ST->search_lexeme($1->location);                  // Get the first operand from the ST_entry table
            ST_entry* second_operand = ST->search_lexeme($3->location);                  // Get the second operand from the ST_entry table
            
            if(second_operand->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed
                
                string t = ST->generate_tem_var(second_operand->type.next_elem_type);
                add_TAC(t, $3->location, *($3->store_addr), ARR_R);
                $3->location = t;
                $3->type = second_operand->type.next_elem_type;
            }
            if(first_operand->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed
                string t = ST->generate_tem_var(first_operand->type.next_elem_type);
                add_TAC(t, $1->location, *($1->store_addr), ARR_R);
                $1->location = t;
                $1->type = first_operand->type.next_elem_type;
            }

            // Assign the data type after appropriate type casting
            data_dtype final = ((first_operand->type.type > second_operand->type.type) ? (first_operand->type.type) : (second_operand->type.type));
            $$->location = ST->generate_tem_var(final);                       // Store the final result in a temporary
            add_TAC($$->location, $1->location, $3->location, ADD);
        }
        | additive_expression SUBTRACT multiplicative_expression
        {
            // Indicates subtraction
            $$ = new expression();
            ST_entry* first_operand = ST->search_lexeme($1->location);                  // Get the first operand from the ST_entry table
            ST_entry* second_operand = ST->search_lexeme($3->location);                  // Get the second operand from the ST_entry table
            if(second_operand->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed
                
                string t = ST->generate_tem_var(second_operand->type.next_elem_type);
                add_TAC(t, $3->location, *($3->store_addr), ARR_R);
                $3->location = t;
                $3->type = second_operand->type.next_elem_type;
            }
            if(first_operand->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed 
                string t = ST->generate_tem_var(first_operand->type.next_elem_type);
                add_TAC(t, $1->location, *($1->store_addr), ARR_R);
                $1->location = t;
                $1->type = first_operand->type.next_elem_type;
            }

            // Assign the data type after appropriate type casting
            data_dtype final = ((first_operand->type.type > second_operand->type.type) ? (first_operand->type.type) : (second_operand->type.type));
            $$->location = ST->generate_tem_var(final);                       // Store the final result in a temporary
            add_TAC($$->location, $1->location, $3->location, SUB);
        }
        ;

shift_expression: 
        additive_expression
        {}
        | shift_expression LEFT_SHIFT additive_expression
        {
            // Indicates left shift
            $$ = new expression();
            ST_entry* first_operand = ST->search_lexeme($1->location);                  // Get the first operand from the ST_entry table
            ST_entry* second_operand = ST->search_lexeme($3->location);                  // Get the second operand from the ST_entry table
            if(second_operand->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                
                   //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed 
                
                string t = ST->generate_tem_var(second_operand->type.next_elem_type);
                add_TAC(t, $3->location, *($3->store_addr), ARR_R);
                $3->location = t;
                $3->type = second_operand->type.next_elem_type;
            }
            if(first_operand->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations

                   //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed 
                string t = ST->generate_tem_var(first_operand->type.next_elem_type);
                add_TAC(t, $1->location, *($1->store_addr), ARR_R);
                $1->location = t;
                $1->type = first_operand->type.next_elem_type;
            }
            $$->location = ST->generate_tem_var(first_operand->type.type);              // data type remains the same after shifting
            add_TAC($$->location, $1->location, $3->location, SL);
        }
        | shift_expression RIGHT_SHIFT additive_expression
        {
            // Indicates right shift
            $$ = new expression();
            ST_entry* first_operand = ST->search_lexeme($1->location);                  // Get the first operand from the ST_entry table
            ST_entry* second_operand = ST->search_lexeme($3->location);                  // Get the second operand from the ST_entry table
            
            if(second_operand->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                
                   //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed 
                
                string t = ST->generate_tem_var(second_operand->type.next_elem_type);
                add_TAC(t, $3->location, *($3->store_addr), ARR_R);
                $3->location = t;
                $3->type = second_operand->type.next_elem_type;
            }
            if(first_operand->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                
                   //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed 
                string t = ST->generate_tem_var(first_operand->type.next_elem_type);
                add_TAC(t, $1->location, *($1->store_addr), ARR_R);
                $1->location = t;
                $1->type = first_operand->type.next_elem_type;
            }
            $$->location = ST->generate_tem_var(first_operand->type.type);              //data type remains the same after right shift
            add_TAC($$->location, $1->location, $3->location, SR);
        }
        ;
/*

next set of instructions involve boolean expressions. 
boolean expressions have attributes truelist and falselist which will be backpatched later
*/

relational_expression: 
        shift_expression
        {}
        | relational_expression LESS_THAN shift_expression
        {
            $$ = new expression();
            ST_entry* first_operand = ST->search_lexeme($1->location);                      // Get the first operand from the ST_entry table
            ST_entry* second_operand = ST->search_lexeme($3->location);                     // Get the second operand from the ST_entry table
            if(second_operand->type.type == ARRAY) {                                        // If the second operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed 
                
                string t = ST->generate_tem_var(second_operand->type.next_elem_type);
                add_TAC(t, $3->location, *($3->store_addr), ARR_R);
                $3->location = t;
                $3->type = second_operand->type.next_elem_type;
            }
           
            if(first_operand->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                
                   //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed 
                string t = ST->generate_tem_var(first_operand->type.next_elem_type);
                add_TAC(t, $1->location, *($1->store_addr), ARR_R);
                $1->location = t;
                $1->type = first_operand->type.next_elem_type;
            }
            $$ = new expression();
            $$->location = ST->generate_tem_var();
            $$->type = BOOL;                                    // Assign the result of the relational expression to a boolean type
            add_TAC($$->location, "1", "", ASSIGN);
            
            $$->truelist = makelist(next_instruction);                 //backpatching
            add_TAC("", $1->location, $3->location, GOTO_LT);               
            add_TAC($$->location, "0", "", ASSIGN);
            $$->falselist = makelist(next_instruction);                //backpatching
            add_TAC("", "", "", GOTO);                            
            /*
                in: $$ = 1
                in+1: if $1 < $3 goto (to be backpatched) i.e. $$ will stay 1 and we will jump to truelist
                in+2: $$ = 0                            else $$ set to 0 and we jump to falselist
                in+3: goto (to be backpatched)
            */
        
        
        }
        | relational_expression GREATER_THAN shift_expression
        {
            $$ = new expression();
            ST_entry* first_operand = ST->search_lexeme($1->location);                  // Get the first operand from the ST_entry table
            ST_entry* second_operand = ST->search_lexeme($3->location);                  // Get the second operand from the ST_entry table
            if(second_operand->type.type == ARRAY) {                                      // If the second operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed
                string t = ST->generate_tem_var(second_operand->type.next_elem_type);
                add_TAC(t, $3->location, *($3->store_addr), ARR_R);
                $3->location = t;
                $3->type = second_operand->type.next_elem_type;
            }
            if(first_operand->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed
                string t = ST->generate_tem_var(first_operand->type.next_elem_type);
                add_TAC(t, $1->location, *($1->store_addr), ARR_R);
                $1->location = t;
                $1->type = first_operand->type.next_elem_type;
            }
            $$ = new expression();
            $$->location = ST->generate_tem_var();
            $$->type = BOOL;                                    // Assign the result of the relational expression to a boolean
            add_TAC($$->location, "1", "", ASSIGN);
            $$->truelist = makelist(next_instruction);                 // backpatching
            add_TAC("", $1->location, $3->location, GOTO_GT);               
            add_TAC($$->location, "0", "", ASSIGN);
            $$->falselist = makelist(next_instruction);                //backpatching
            add_TAC("", "", "", GOTO);                             

            /*
                in: $$ = 1
                in+1: if $1 > $3 goto (to be backpatched) i.e. $$ will stay 1 and we will jump to truelist
                in+2: $$ = 0                            else $$ set to 0 and we jump to falselist
                in+3: goto (to be backpatched)
            */
        }
        | relational_expression LESS_THAN_EQUAL shift_expression
        {
            $$ = new expression();
            ST_entry* first_operand = ST->search_lexeme($1->location);                  // Get the first operand from the ST_entry table
            ST_entry* second_operand = ST->search_lexeme($3->location);                  // Get the second operand from the ST_entry table
            if(second_operand->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed 
                string t = ST->generate_tem_var(second_operand->type.next_elem_type);
                add_TAC(t, $3->location, *($3->store_addr), ARR_R);
                $3->location = t;
                $3->type = second_operand->type.next_elem_type;
            }
            if(first_operand->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed 
                string t = ST->generate_tem_var(first_operand->type.next_elem_type);
                add_TAC(t, $1->location, *($1->store_addr), ARR_R);
                $1->location = t;
                $1->type = first_operand->type.next_elem_type;
            }
            $$ = new expression();
            $$->location = ST->generate_tem_var();
            $$->type = BOOL;                                    // Assign the result of the relational expression to a boolean
            add_TAC($$->location, "1", "", ASSIGN);
            $$->truelist = makelist(next_instruction);                 // backpatching
            add_TAC("", $1->location, $3->location, GOTO_LTE);               // Emit "if x <= y goto ..."
            add_TAC($$->location, "0", "", ASSIGN);
            $$->falselist = makelist(next_instruction);                //backpatching
            add_TAC("", "", "", GOTO);                             
             /*
                in: $$ = 1
                in+1: if $1 <= $3 goto (to be backpatched) i.e. $$ will stay 1 and we will jump to truelist
                in+2: $$ = 0                            else $$ set to 0 and we jump to falselist
                in+3: goto (to be backpatched)
            */
        
        
        }
        | relational_expression GREATER_THAN_EQUAL shift_expression
        {
            $$ = new expression();
            ST_entry* first_operand = ST->search_lexeme($1->location);                  // Get the first operand from the ST_entry table
            ST_entry* second_operand = ST->search_lexeme($3->location);                  // Get the second operand from the ST_entry table
            if(second_operand->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed 
                string t = ST->generate_tem_var(second_operand->type.next_elem_type);
                add_TAC(t, $3->location, *($3->store_addr), ARR_R);
                $3->location = t;
                $3->type = second_operand->type.next_elem_type;
            }
            if(first_operand->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed 
                string t = ST->generate_tem_var(first_operand->type.next_elem_type);
                add_TAC(t, $1->location, *($1->store_addr), ARR_R);
                $1->location = t;
                $1->type = first_operand->type.next_elem_type;
            }
            $$ = new expression();
            $$->location = ST->generate_tem_var();
            $$->type = BOOL;                                    // Assign the result of the relational expression to a boolean
            add_TAC($$->location, "1", "", ASSIGN);
            $$->truelist = makelist(next_instruction);                 // backpatching
            add_TAC("", $1->location, $3->location, GOTO_GTE);               // Emit "if x >= y goto ..."
            add_TAC($$->location, "0", "", ASSIGN);
            $$->falselist = makelist(next_instruction);                //backpatching
            add_TAC("", "", "", GOTO);                             
             /*
                in: $$ = 1
                in+1: if $1 >= $3 goto (to be backpatched) i.e. $$ will stay 1 and we will jump to truelist
                in+2: $$ = 0                            else $$ set to 0 and we jump to falselist
                in+3: goto (to be backpatched)
            */
        
        }
        ;

equality_expression: 
        relational_expression
        {
            $$ = new expression();
            $$ = $1;                // copy content from right to left
        }
        | equality_expression EQUAL relational_expression
        {
            $$ = new expression();
            ST_entry* first_operand = ST->search_lexeme($1->location);                  // Get the first operand from the ST_entry table
            ST_entry* second_operand = ST->search_lexeme($3->location);                  // Get the second operand from the ST_entry table
            if(second_operand->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed 
                string t = ST->generate_tem_var(second_operand->type.next_elem_type);
                add_TAC(t, $3->location, *($3->store_addr), ARR_R);
                $3->location = t;
                $3->type = second_operand->type.next_elem_type;
            }
            if(first_operand->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed 
                string t = ST->generate_tem_var(first_operand->type.next_elem_type);
                add_TAC(t, $1->location, *($1->store_addr), ARR_R);
                $1->location = t;
                $1->type = first_operand->type.next_elem_type;
            }
            $$ = new expression();
            $$->location = ST->generate_tem_var();
            $$->type = BOOL;                                    // Assign the result of the relational expression to a boolean
            add_TAC($$->location, "1", "", ASSIGN);
            $$->truelist = makelist(next_instruction);                 // backpatching
            add_TAC("", $1->location, $3->location, GOTO_EQ);                
            add_TAC($$->location, "0", "", ASSIGN);
            $$->falselist = makelist(next_instruction);                //backpatching
            add_TAC("", "", "", GOTO);                             
            /*
                in: $$ = 1
                in+1: if $1 == $3 goto (to be backpatched) i.e. $$ will stay 1 and we will jump to truelist
                in+2: $$ = 0                            else $$ set to 0 and we jump to falselist
                in+3: goto (to be backpatched)
            */
        
        }
        | equality_expression NOT_EQUAL relational_expression
        {
            $$ = new expression();
            ST_entry* first_operand = ST->search_lexeme($1->location);                  // Get the first operand from the ST_entry table
            ST_entry* second_operand = ST->search_lexeme($3->location);                  // Get the second operand from the ST_entry table
            if(second_operand->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed 
                string t = ST->generate_tem_var(second_operand->type.next_elem_type);
                add_TAC(t, $3->location, *($3->store_addr), ARR_R);
                $3->location = t;
                $3->type = second_operand->type.next_elem_type;
            }
            if(first_operand->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed 
                string t = ST->generate_tem_var(first_operand->type.next_elem_type);
                add_TAC(t, $1->location, *($1->store_addr), ARR_R);
                $1->location = t;
                $1->type = first_operand->type.next_elem_type;
            }
            $$ = new expression();
            $$->location = ST->generate_tem_var();
            $$->type = BOOL;                                    // Assign the result of the relational expression to a boolean
            add_TAC($$->location, "1", "", ASSIGN);
            $$->truelist = makelist(next_instruction);                 // backpatching
            add_TAC("", $1->location, $3->location, GOTO_NEQ);               
            add_TAC($$->location, "0", "", ASSIGN);
            $$->falselist = makelist(next_instruction);                //backpatching
            add_TAC("", "", "", GOTO);                             
            /*
                in: $$ = 1
                in+1: if $1 != $3 goto (to be backpatched) i.e. $$ will stay 1 and we will jump to truelist
                in+2: $$ = 0                            else $$ set to 0 and we jump to falselist
                in+3: goto (to be backpatched)
            */
        }
        ;

/*
the next set of translations involve converting expressions to int/non-boolean type,
thus, truelist and falselist attributes now become invalid
a new temporary variable is generated to store the result of the intermediate operations
*/

and_expression: 
        equality_expression
        {}
        | and_expression BITWISE_AND equality_expression
        {
            $$ = new expression();
            ST_entry* first_operand = ST->search_lexeme($1->location);                  // Get the first operand from the ST_entry table
            ST_entry* second_operand = ST->search_lexeme($3->location);                  // Get the second operand from the ST_entry table
            if(second_operand->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed 
                string t = ST->generate_tem_var(second_operand->type.next_elem_type);
                add_TAC(t, $3->location, *($3->store_addr), ARR_R);
                $3->location = t;
                $3->type = second_operand->type.next_elem_type;
            }
            if(first_operand->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed 
                string t = ST->generate_tem_var(first_operand->type.next_elem_type);
                add_TAC(t, $1->location, *($1->store_addr), ARR_R);
                $1->location = t;
                $1->type = first_operand->type.next_elem_type;
            }
            $$ = new expression();
            $$->location = ST->generate_tem_var();                            // Create a temporary variable to store the result
            add_TAC($$->location, $1->location, $3->location, BW_AND);            // generate TAC quad
            // $$  = $1 & $3
        }
        ;

exclusive_or_expression: 
        and_expression
        {
            $$ = $1;    // copy content from right to left
        }
        | exclusive_or_expression BITWISE_XOR and_expression
        {
            $$ = new expression();
            ST_entry* first_operand = ST->search_lexeme($1->location);                  // Get the first operand from the ST_entry table
            ST_entry* second_operand = ST->search_lexeme($3->location);                  // Get the second operand from the ST_entry table
            if(second_operand->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed 
                string t = ST->generate_tem_var(second_operand->type.next_elem_type);
                add_TAC(t, $3->location, *($3->store_addr), ARR_R);
                $3->location = t;
                $3->type = second_operand->type.next_elem_type;
            }
            if(first_operand->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed 
                string t = ST->generate_tem_var(first_operand->type.next_elem_type);
                add_TAC(t, $1->location, *($1->store_addr), ARR_R);
                $1->location = t;
                $1->type = first_operand->type.next_elem_type;
            }
            $$ = new expression();
            $$->location = ST->generate_tem_var();                            // Create a temporary variable to store the result
            add_TAC($$->location, $1->location, $3->location, BW_XOR);            // generate TAC quad
            //$$ =$1 ^ $3
        }
        ;

inclusive_or_expression: 
        exclusive_or_expression
        {
            $$ = new expression();
            $$ = $1;                // copy content from right to left
        }
        | inclusive_or_expression BITWISE_OR exclusive_or_expression
        {
            $$ = new expression();
            ST_entry* first_operand = ST->search_lexeme($1->location);                  // Get the first operand from the ST_entry table
            ST_entry* second_operand = ST->search_lexeme($3->location);                  // Get the second operand from the ST_entry table
            if(second_operand->type.type == ARRAY) {                       // If the second operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed 
                string t = ST->generate_tem_var(second_operand->type.next_elem_type);
                add_TAC(t, $3->location, *($3->store_addr), ARR_R);
                $3->location = t;
                $3->type = second_operand->type.next_elem_type;
            }
            if(first_operand->type.type == ARRAY) {                       // If the first operand is an array, perform necessary operations
                
                //extract the value stored in array and save it in a temporary variable so that arithmetic operation can be performed 
                string t = ST->generate_tem_var(first_operand->type.next_elem_type);
                add_TAC(t, $1->location, *($1->store_addr), ARR_R);
                $1->location = t;
                $1->type = first_operand->type.next_elem_type;
            }
            $$ = new expression();
            $$->location = ST->generate_tem_var();                            // Create a temporary variable to store the result
            add_TAC($$->location, $1->location, $3->location, BW_OR);             // generate TAC quad
            //$$ = $1 | $3
        }
        ;

logical_and_expression: 
        inclusive_or_expression
        {}
        | logical_and_expression LOGICAL_AND M inclusive_or_expression
        {
            /*
                augmented the grammar with the non-terminal M marker to have a track of next instruction to be executed during backpatching
            */
            backpatch($1->truelist, $3->instr);                     // Backpatching
            $$->falselist = merge($1->falselist, $4->falselist);    // Generate falselist by merging the falselists of $1 and $4
            $$->truelist = $4->truelist;                            // Generate truelist from truelist of $4
            $$->type = BOOL;                                        // Set the type of the expression to boolean
            // B-> B1 && MB2
            // B.truelist = B2.truelist
            // backpatch(B1.truelist, M.instr)
            //B.falselist = merge(B1.falselist, B2.falselist)
        
        
        }
        ;

logical_or_expression: 
        logical_and_expression
        {}
        | logical_or_expression LOGICAL_OR M logical_and_expression
        {
            backpatch($1->falselist, $3->instr);                    // Backpatching
            $$->truelist = merge($1->truelist, $4->truelist);       // Generate falselist by merging the falselists of $1 and $4
            $$->falselist = $4->falselist;                          // Generate truelist from truelist of $4
            $$->type = BOOL;                                        // Set the type of the expression to boolean
            // B-> B1 || MB2
            // B.falselist = B2.falselist
            // backpatch(B1.falselist, M.instr)
            //B.truelist = merge(B1.truelist, B2.truelist)
        
        }
        ;

conditional_expression: 
        logical_or_expression
        {
            $$ = $1;    // copy content from right to left
        }
        | logical_or_expression N QUESTION_MARK M expression N COLON M conditional_expression
        {   
            /*
                grammar is augmented with the non-terminals M marker and N to keep track of next instruction during backpatching
            */
            ST_entry* first_operand = ST->search_lexeme($5->location);
            $$->location = ST->generate_tem_var(first_operand->type.type);      
            $$->type = first_operand->type.type;
            
            add_TAC($$->location, $9->location, "", ASSIGN);         
            list<int> temp = makelist(next_instruction);
            
            add_TAC("", "", "", GOTO);                     
            backpatch($6->nextlist, next_instruction);         
            
            add_TAC($$->location, $5->location, "", ASSIGN);
            temp = merge(temp, makelist(next_instruction));
            
            add_TAC("", "", "", GOTO);                     
            backpatch($2->nextlist, next_instruction);     
            convertIntToBool($1);                       
            backpatch($1->truelist, $4->instr);         
            backpatch($1->falselist, $8->instr);        
            backpatch($2->nextlist, next_instruction);  
            
            /*
            For E -> E1 N1 ? M1 E2 N2 : M2 E3
            E.loc = gentemp();
            E.type = E2.type; // Assume E2.type = E3.type
            add_TAC(E.loc ’=’ E3 .loc); // Control gets here by fall-through
            l = makelist(nextinstr);
            add_TAC(goto .... );
            backpatch(N 2 .nextlist, nextinstr);
            add_TAC(E .loc ’=’ E 2 .loc);
            l = merge(l, makelist(nextinstr));
            add_TAC(goto .... );                   
            backpatch(N1 .nextlist, nextinstr);
            convInt2Bool(E1);
            backpatch(E1 .truelist, M1 .instr); //backpatching
            backpatch(E1 .falselist, M2 .instr);
            backpatch(l, nextinstr);
            */
        }
        ;

M: %empty
        {   
            
            //M - > epsilon 
            //store the count of theb next instruction and will be used for backpatching in control flow statements
            $$ = new expression();
            $$->instr = next_instruction;
        }
        ;

N: %empty
        {
             // N -> epsilon 
            // Helps in control flow statments
           
            $$ = new expression();
            $$->nextlist = makelist(next_instruction);
            add_TAC("", "", "", GOTO);
        }
        ;

assignment_expression: 
        conditional_expression
        {}
        | unary_expression assignment_operator assignment_expression
        {
            ST_entry* sym1 = ST->search_lexeme($1->location);         // Get the first operand from the ST_entry table
            ST_entry* sym2 = ST->search_lexeme($3->location);         // Get the second operand from the ST_entry table
            if($1->order_dim == 0) {
                if(sym1->type.type != ARRAY)
                    add_TAC($1->location, $3->location, "", ASSIGN);
                else
                    add_TAC($1->location, $3->location, *($1->store_addr), ARR_L);
            }
            else
                add_TAC(*($1->store_addr), $3->location, "", L_DEREF);
            $$ = $1;        // Assignment 
        }
        ;

assignment_operator: 
        ASSIGN_
        {}
        | MUL_ASSIGN
        {}
        | F_SLASH_ASSIGN
        {}
        | MODULO_ASSIGN
        {}
        | PLUSASSIGN
        {}
        | SUBTRACT_ASSIGN
        {}
        | LEFT_SHIFT_ASSIGN
        {}
        | RIGHT_SHIFT_ASSIGN
        {}
        | BITWISE_AND_ASSIGN
        {}
        | BITWISE_XOR_ASSIGN
        {}
        | BITWISE_OR_ASSIGN
        {}
        ;

expression: 
        assignment_expression
        {}
        | expression COMMA assignment_expression
        {}
        ;

constant_expression: 
        conditional_expression
        {}
        ;

//declaration
//these productions will be responsible for updating and creating symbol table

declaration: 
        declaration_specifiers init_declarator_list SEMICOLON
        {
            data_dtype current_dtype = $1;
            int current_dsize = -1;

            // assign size according to the datatype
            if(current_dtype == INT)
                current_dsize = 4;
            else if(current_dtype == CHAR)
                current_dsize = 1;
            else if(current_dtype == FLOAT)
                current_dsize = 8;
           
            //get the set of declarations
            vector<declaration*> decs = *($2);
            
            //iterate over declarations
            for(vector<declaration*>::iterator it = decs.begin(); it != decs.end(); it++) {
                declaration* currDec = *it;
                
                //if a function declaration is found
                if(currDec->type == FUNCTION) {
                    //move back to gloabl symbol table
                    ST = &ST_global;
                    //add a TAC code marking the end of function
                    add_TAC(currDec->name, "", "", FUNC_END);
                    
                    //find the func in the global symbol table
                    ST_entry* first_operand = ST->search_lexeme(currDec->name);        // Create an entry for the function

                    //find the lexeme with name return value in nested table of the entry corresponding to func name
                    //i.e. search for return lexeme in function symbol table
                    ST_entry* second_operand = first_operand->nested_symbol_table->search_lexeme("RETVAL", current_dtype, currDec->pointers);
                    
                    //update func symbol's attributes in global symbol table
                    first_operand->size = 0;
                    first_operand->initial_value = NULL;
                    continue;
                }

                //if the current declaration is not of type function
                ST_entry* three = ST->search_lexeme(currDec->name, current_dtype);        // create a new symbol
                three->nested_symbol_table = NULL;                                         //since this is not a function there won't be nested tables
                
                if(currDec->li == vector<int>() && currDec->pointers == 0) {
                    three->type.type = current_dtype;                                       //assign the data type to all variables
                    three->size = current_dsize;                                            //assign data type's size to all variables
                    
                    if(currDec->initial_value != NULL) {                                    //if it has an initial value
                        string rval = currDec->initial_value->location;
                        add_TAC(three->name, rval, "", ASSIGN);
                        three->initial_value = ST->search_lexeme(rval)->initial_value;      //assign the intial value to this variable
                    }
                    else
                        three->initial_value = NULL;                                        //else assign null as initial value     
                }       
                else if(currDec->li != vector<int>()) {                                     // Handle array data type
                    three->type.type = ARRAY;                                               //set type as arary
                    three->type.next_elem_type = current_dtype;                             //array elements would of type current data type
                    three->type.dims = currDec->li;                                         //set the dimension of array
                    vector<int> temp = three->type.dims;                                    //if the array is of type ar[3][4][5] then 3,4,5 would be stored in the vector

                    int size = current_dsize;
                    for(int i = 0; i < (int)temp.size(); i++)                                //temp holds the value of dimensions
                        size *= temp[i];
                    ST->offset += size;                                                      //multiply the dimension to find total number of bytes occupied by array
                    three->size = size;
                    ST->offset -= 4;
                }
                else if(currDec->pointers != 0) {                                           //to handle pointer data type
                    three->type.type = POINTER;                                             //set data type of the variable
                    three->type.next_elem_type = current_dtype;                             //set the data type of the element pointed by the pointer
                    three->type.pointers = currDec->pointers;                               
                    ST->offset += (8 - current_dsize);                                      //update the offset but since pointer is of size 8 add that to the offset. 
                    three->size = 8;
                }
            }
        }
        | declaration_specifiers SEMICOLON
        {}
        ;

declaration_specifiers: 
        storage_class_specifier declaration_specifiers
        {}
        |storage_class_specifier
        {}
        | type_specifier declaration_specifiers
        {}
        | type_specifier
        {}
        | type_qualifier declaration_specifiers
        {}
        | type_qualifier
        {}
        | function_specifier declaration_specifiers
        {}
        | function_specifier
        {}
        ;

init_declarator_list: 
        init_declarator
        {
            $$ = new vector<declaration*>;      // add all declarations to the vector
            $$->push_back($1);
        }
        | init_declarator_list COMMA init_declarator
        {
            $1->push_back($3);                  // continue adding declaration to the vector
            $$ = $1;
        }
        ;

init_declarator: 
        declarator
        {
            $$ = $1;
            $$->initial_value = NULL;         // Initialize the initial_value to NULL as no initiali value given
        }
        | declarator ASSIGN_ initializer
        {   
            $$ = $1;
            $$->initial_value = $3;           // Initialize the initial_value to the value provided
        }
        ;

storage_class_specifier: 
        EXTERN
        {}
        | STATIC
        {}
        | AUTO
        {}
        | REGISTER
        {}
        ;

type_specifier: 
        VOID_
        {
            $$ = VOID;
        }
        | CHAR_
        {
            $$ = CHAR;
        }
        | SHORT
        {}
        | INT_
        {
            $$ = INT; 
        }
        | LONG
        {}
        | FLOAT_
        {
            $$ = FLOAT;
        }
        | DOUBLE
        {}
        | SIGNED
        {}
        | UNSIGNED
        {}
        | BOOL_
        {}
        | COMPLEX
        {}
        | IMAGINARY
        {}
        | enum_specifier
        {}
        ;

specifier_qualifier_list: 
        type_specifier specifier_qualifier_list_opt
        {}
        | type_qualifier specifier_qualifier_list_opt
        {}
        ;

specifier_qualifier_list_opt: 
        specifier_qualifier_list
        {}
        | %empty
        {}
        ;

enum_specifier: 
        ENUM LEFT_CURLY enumerator_list RIGHT_CURLY
        {}
        | ENUM IDENTIFIER LEFT_CURLY enumerator_list RIGHT_CURLY
        {}
        | ENUM IDENTIFIER LEFT_CURLY enumerator_list COMMA RIGHT_CURLY
        {}
        | ENUM IDENTIFIER
        {}
        ;

enumerator_list: 
        enumerator
        {}
        | enumerator_list COMMA enumerator
        {}
        ;

enumerator: 
        IDENTIFIER
        {}
        | IDENTIFIER ASSIGN_ constant_expression
        {}
        ;

type_qualifier: 
        CONST
        {}
        | RESTRICT
        {}
        | VOLATILE
        {}
        ;

function_specifier: 
        INLINE
        {}
        ;

declarator: 
        pointer direct_declarator
        {
            $$ = $2;
            $$->pointers = $1;
        }
        | direct_declarator
        {
            $$ = $1;
            $$->pointers = 0;
        }
        ;

direct_declarator: 
        IDENTIFIER
        {
            $$ = new declaration();
            $$->name = *($1);
        }
        | LEFT_PARENTHESIS declarator RIGHT_PARENTHESIS
        {}
        | direct_declarator LEFT_SQUARE type_qualifier_list_opt RIGHT_SQUARE
        {
            $1->type = ARRAY;       // Array type
            $1->next_elem_type = INT;     // Array of ints
            $$ = $1;
            $$->li.push_back(0);
        }
        | direct_declarator LEFT_SQUARE type_qualifier_list_opt assignment_expression RIGHT_SQUARE
        {
            $1->type = ARRAY;       // Array type
            $1->next_elem_type = INT;     // Array of ints
            $$ = $1;
            int index = ST->search_lexeme($4->location)->initial_value->i;
            $$->li.push_back(index);
        }
        | direct_declarator LEFT_SQUARE STATIC type_qualifier_list assignment_expression RIGHT_SQUARE
        {}
        | direct_declarator LEFT_SQUARE type_qualifier_list STATIC assignment_expression RIGHT_SQUARE
        {}
        | direct_declarator LEFT_SQUARE type_qualifier_list_opt MUL RIGHT_SQUARE
        {
            $1->type = POINTER;     // Pointer type
            $1->next_elem_type = INT;
            $$ = $1;
        }
        | direct_declarator LEFT_PARENTHESIS parameter_type_list_opt RIGHT_PARENTHESIS
        {
            $$ = $1;
            $$->type = FUNCTION;    // Function type
            ST_entry* funcData = ST->search_lexeme($$->name, $$->type);
            symbol_table* function_ST = new symbol_table();
            funcData->nested_symbol_table = function_ST;
            vector<param*> paramList = *($3);   // Get the parameter list
            for(int i = 0; i < (int)paramList.size(); i++) {
                param* curParam = paramList[i];
                if(curParam->type.type == ARRAY) {          // If the parameter is an array
                    function_ST->search_lexeme(curParam->name, curParam->type.type);
                    function_ST->search_lexeme(curParam->name)->type.next_elem_type = INT;
                    function_ST->search_lexeme(curParam->name)->type.dims.push_back(0);
                }
                else if(curParam->type.type == POINTER) {   // If the parameter is a pointer
                    function_ST->search_lexeme(curParam->name, curParam->type.type);
                    function_ST->search_lexeme(curParam->name)->type.next_elem_type = INT;
                    function_ST->search_lexeme(curParam->name)->type.dims.push_back(0);
                }
                else                                        // If the parameter is a anything other than an array or a pointer
                    function_ST->search_lexeme(curParam->name, curParam->type.type);
            }
            ST = function_ST;         // Set the pointer to the ST_entry table to the function's ST_entry table
            add_TAC($$->name, "", "", FUNC_BEG);
        }
        | direct_declarator LEFT_PARENTHESIS identifier_list RIGHT_PARENTHESIS
        {}
        ;

parameter_type_list_opt:
        parameter_type_list
        {}
        | %empty
        {
            $$ = new vector<param*>;
        }
        ;

type_qualifier_list_opt: 
        type_qualifier_list
        {}
        | %empty
        {}
        ;

pointer: 
        MUL type_qualifier_list
        {}
        | MUL
        {
            $$ = 1;
        }
        | MUL type_qualifier_list pointer
        {}
        | MUL pointer
        {
            $$ = 1 + $2;
        }
        ;

type_qualifier_list: 
        type_qualifier
        {}
        | type_qualifier_list type_qualifier
        {}
        ;

parameter_type_list: 
        parameter_list
        | parameter_list COMMA ELLIPSIS
        ;

parameter_list: 
        parameter_declaration
        {
            $$ = new vector<param*>;         // Create a new vector of parameters
            $$->push_back($1);              // Add the parameter to the vector
        }
        | parameter_list COMMA parameter_declaration
        {
            $1->push_back($3);              // Add the parameter to the vector
            $$ = $1;
        }
        ;

parameter_declaration: 
        declaration_specifiers declarator
        {
            $$ = new param();
            $$->name = $2->name;
            if($2->type == ARRAY) {
                $$->type.type = ARRAY;
                $$->type.next_elem_type = $1;
            }
            else if($2->pc != 0) {
                $$->type.type = POINTER;
                $$->type.next_elem_type = $1;
            }
            else
                $$->type.type = $1;
        }
        | declaration_specifiers
        {}
        ;

identifier_list: 
        IDENTIFIER
        {}
        | identifier_list COMMA IDENTIFIER
        {}
        ;

type_name: 
        specifier_qualifier_list
        {}
        ;

initializer: 
        assignment_expression
        {
            $$ = $1;   // copy content from right to left
        }
        | LEFT_CURLY initializer_list RIGHT_CURLY
        {}
        | LEFT_CURLY initializer_list COMMA RIGHT_CURLY
        {}
        ;

initializer_list: 
        designation_opt initializer
        {}
        | initializer_list COMMA designation_opt initializer
        {}
        ;

designation_opt: 
        designation
        {}
        | %empty
        {}
        ;

designation: 
        designator_list ASSIGN_
        {}
        ;

designator_list: 
        designator
        {}
        | designator_list designator
        {}
        ;

designator: 
        LEFT_SQUARE constant_expression RIGHT_SQUARE
        {}
        | DOT IDENTIFIER
        {}
        ;

statement: 
        labeled_statement
        {}
        | compound_statement
        | expression_statement
        | selection_statement
        | iteration_statement
        | jump_statement
        ;

labeled_statement: 
        IDENTIFIER COLON statement
        {}
        | CASE constant_expression COLON statement
        {}
        | DEFAULT COLON statement
        {}
        ;

compound_statement: 
        LEFT_CURLY RIGHT_CURLY
        {}
        | LEFT_CURLY block_item_list RIGHT_CURLY
        {
            $$ = $2;
        }
        ;

block_item_list: 
        block_item
        {
            $$ = $1;    // copy content from right to left
            backpatch($1->nextlist, next_instruction);
        }
        | block_item_list M block_item
        {   
            
            /*
                M marker has been added to keep track of next instruction during backpatching
            */
            $$ = new expression();
            backpatch($1->nextlist, $2->instr);    // M.instr would be the next instruction after $1 so backpatch 
            $$->nextlist = $3->nextlist;
        }
        ;

block_item: 
        declaration
        {
            $$ = new expression();   // new expression node
        }
        | statement
        ;

expression_statement: 
        expression SEMICOLON
        {}
        | SEMICOLON
        {
            $$ = new expression();  // new expression node
        }
        ;

selection_statement:
/*

If Else

%prec THEN is to remove conflicts/ambiguity

Marker M to keep track of next isntruction and N to keep track of nextlist

S -> if (B) M S1 N
backpatch(B.truelist, M.instr )
temp = merge(S1.nextlist, N.nextlist)
S.nextlist = merge(B.falselist,temp)

S -> if (B) M1 S1 N else M2 S2
backpatch(B.truelist, M1.instr)
backpatch(B.falselist, M2.instr)
temp = merge(S1.nextlist, N.nextlist)
S.nextlist = merge(temp, S2 .nextlist)

*/

        IF LEFT_PARENTHESIS expression N RIGHT_PARENTHESIS M statement N
        {
            /*
                M and N markers help in backpatching
            */
            backpatch($4->nextlist, next_instruction);         //backpatching
            convertIntToBool($3);                       // Convert expression to bool
            backpatch($3->truelist, $6->instr);         // Backpatching 
            $$ = new expression();                      // new expression node
            
            // Merge falselist of expression, nextlist of statement and nextlist of the last N
            $7->nextlist = merge($8->nextlist, $7->nextlist);
            $$->nextlist = merge($3->falselist, $7->nextlist);
        }
        | IF LEFT_PARENTHESIS expression N RIGHT_PARENTHESIS M statement N ELSE M statement N
        {
            /*
                M and N markers help in backpatching
            */
            backpatch($4->nextlist, next_instruction);         // backpatching
            convertIntToBool($3);                       // Convert expression to bool
            backpatch($3->truelist, $6->instr);         // backpatching
            backpatch($3->falselist, $10->instr);
            $$ = new expression();                      // new expression node
            
            // Merge nextlist of statement, nextlist of N and nextlist of the last statement
            $$->nextlist = merge($7->nextlist, $8->nextlist);
            $$->nextlist = merge($$->nextlist, $11->nextlist);
            $$->nextlist = merge($$->nextlist, $12->nextlist);
        }
        | SWITCH LEFT_PARENTHESIS expression RIGHT_PARENTHESIS statement
        {}
        ;

iteration_statement: 
        // M and N markers are used as usual to keep a track of next instruction to be executed 
        //which would be used for backpatching. 
        WHILE M LEFT_PARENTHESIS expression N RIGHT_PARENTHESIS M statement
        {   
            
            $$ = new expression();                      // Create a new expression
            add_TAC("", "", "", GOTO);                  // add TAC with missing label
            
            backpatch(makelist(next_instruction - 1), $2->instr);
            backpatch($5->nextlist, next_instruction);
            convertIntToBool($4);                       // Convert expression to bool
            $$->nextlist = $4->falselist;               // Exit loop if expression is false
            backpatch($4->truelist, $7->instr);         // Go to M2 and loop_statement if expression is true
            backpatch($8->nextlist, $2->instr);         // Go back to M1 and expression after one iteration of loop_statement
        }
        | DO M statement M WHILE LEFT_PARENTHESIS expression N RIGHT_PARENTHESIS SEMICOLON
        {
            
            $$ = new expression();                  // Create a new expression  
            backpatch($8->nextlist, next_instruction);     // Backpatching 
            convertIntToBool($7);                   // Convert expression to bool
            backpatch($7->truelist, $2->instr);     // Go back to M1 and loop_statement if expression is true
            backpatch($3->nextlist, $4->instr);     // Go to M2 to check expression after statement is complete
            $$->nextlist = $7->falselist;           // Exit loop if expression is false
        }
        | FOR LEFT_PARENTHESIS expression_statement M expression_statement N M expression N RIGHT_PARENTHESIS M statement
        {
            
            $$ = new expression();                   // Create a new expression
            add_TAC("", "", "", GOTO);
            $12->nextlist = merge($12->nextlist, makelist(next_instruction - 1));
            backpatch($12->nextlist, $7->instr);    
            backpatch($9->nextlist, $4->instr);     
            backpatch($6->nextlist, next_instruction);     
            convertIntToBool($5);                   // Convert expression to bool
            backpatch($5->truelist, $11->instr);    // backpatching
            $$->nextlist = $5->falselist;           // Exit loop if expression is false
        }
        ;

jump_statement: 
        GOTO_ IDENTIFIER SEMICOLON
        {}
        | CONTINUE SEMICOLON
        {}
        | BREAK SEMICOLON
        {}
        | RETURN_ SEMICOLON
        {
            if(ST->search_lexeme("RETVAL")->type.type == VOID) {
                add_TAC("", "", "", RETURN);           // generate TAC quad when return type is void
            }
            $$ = new expression();
        }
        | RETURN_ expression SEMICOLON
        {
            if(ST->search_lexeme("RETVAL")->type.type == ST->search_lexeme($2->location)->type.type) {
                add_TAC($2->location, "", "", RETURN);      // generate TAC quad when return type is not void
            }
            $$ = new expression();
        }
        ;

translation_unit: 
        external_declaration
        {}
        | translation_unit external_declaration
        {}
        ;

external_declaration: 
        function_definition
        {}
        | declaration
        {}
        ;

function_definition: 
        declaration_specifiers declarator declaration_list compound_statement
        {}
        | function_prototype compound_statement
        {
            ST = &ST_global;                     // Reset the symbol table to global symbol table
            add_TAC($1->name, "", "", FUNC_END);
        }
        ;

function_prototype:
        //function initialiser
        declaration_specifiers declarator
        {
            data_dtype current_dtype = $1;//extract the type of return 
            int current_dsize = -1;
            if(current_dtype == CHAR)
                current_dsize = 1;
            if(current_dtype == INT)
                current_dsize = 4;
            if(current_dtype == FLOAT)
                current_dsize = 8;

            declaration* currDec = $2;
            ST_entry* sym = ST_global.search_lexeme(currDec->name);
            
            if(currDec->type == FUNCTION) {//if the type of declarator is function
                ST_entry* retval = sym->nested_symbol_table->search_lexeme("RETVAL", current_dtype, currDec->pointers);   // Create entry for return value
                sym->size = 0;
                sym->initial_value = NULL;//intialize return value as NULL
            }
            $$ = $2;
        }
        ;

declaration_list: 
        declaration
        {}
        | declaration_list declaration
        {}
        ;

%%

void yyerror(string s) {
printf("error in Line: %d ( %s )\n" , yylineno, s.c_str());
}
