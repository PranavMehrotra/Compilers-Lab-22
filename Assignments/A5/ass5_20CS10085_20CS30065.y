%{
#include "ass5_20CS10085_20CS30065_translator.h"
#include <string>
#include<iomanip>
#include<iostream>
extern int yylex();
extern int lineno;
void yyerror(string s);
%}


%union{
    //for constants
    int intval;
    char *floatval;
    char *charval;
    char *stringval;
    
    //to keep a track of current instruction
    int inst_num;

    char unary_op;
    int num_params;
    
    expression* expr;
    statement* stmt;
    
    //for identifier
    ST_entry* idval;
    
    ST_entry_type* symbol_type;
    array_data_type* arr;
}

    //terminal are declared of type token
%token AUTO
%token BREAK
%token CASE 
%token CHAR
%token CONST
%token CONTINUE
%token DEFAULT
%token DO
%token DOUBLE
%token ELSE
%token ENUM
%token EXTERN
%token FLOAT
%token FOR 
%token GOTO
%token IF
%token INLINE
%token INT
%token LONG
%token REGISTER
%token RESTRICT
%token RETURN
%token SHORT
%token SIGNED
%token SIZEOF
%token STATIC
%token SWITCH
%token UNSIGNED
%token VOID
%token VOLATILE
%token WHILE
%token _BOOL
%token _COMPLEX
%token _IMAGINARY

    //token declaration for constants and identifier that will act as placeholders
%token<idval> IDENTIFIER
%token<intval> INTEGER_CONSTANT
%token<floatval> FLOATING_CONSTANT
%token<charval> CHARACTER_CONSTANT
%token<stringval> STRING_LITERAL

%token LEFT_SQUARE
%token SELF_INCREASE 
%token F_SLASH
%token QUESTION_MARK
%token ASSIGN 
%token COMMA
%token RIGHT_SQUARE
%token LEFT_PARENTHESES
%token LEFT_CURLY
%token RIGHT_CURLY
%token DOT
%token ARROW
%token MUL
%token PLUS
%token MINUS
%token TILDE
%token EXCLAMATION
%token MODULO
%token LEFT_SHIFT
%token RIGHT_SHIFT
%token LESS_THAN
%token GREATER_THAN
%token LESS_THAN_EQUAL
%token GREATER_THAN_EQUAL
%token COLON
%token SEMI_COLON
%token ELLIPSIS
%token MUL_ASSIGN 
%token DIV_ASSIGN 
%token MODULO_ASSIGN 
%token PLUS_ASSIGN 
%token MINUS_ASSIGN 
%token LEFT_SHIFT_ASSIGN 
%token SELF_DECREASE 
%token RIGHT_PARENTHESES
%token BITWISE_AND
%token EQUAL
%token BITWISE_XOR
%token BITWISE_OR
%token LOGICAL_AND
%token LOGICAL_BITWISE_OR
%token RIGHT_SHIFT_ASSIGN 
%token NOT_EQUAL
%token BITWISE_AND_ASSIGN 
%token BITWISE_XOR_ASSIGN
%token BITWISE_OR_ASSIGN 

%token INVALID

    //to prevent issues of ambiguity and dangling else
%right RIGHT_PARENTHESES
%right THEN ELSE

    //declare the start non terminal
%start translation_unit

    //to store unary operator as character
%type <unary_op> unary_operator

    //useful for storing number of parameters
%type <num_params> argument_expression_list argument_expression_listopt

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
        expression_statement

// Non-terminals of type statement
%type <stmt>
        compound_statement
        statement
        selection_statement
        iteration_statement
        labeled_statement 
        jump_statement
        block_item
        block_item_list
        block_item_listopt
        loop_statement

// pointer of type ST_entry_type 
%type <symbol_type> pointer

//type ST_entry* i.e. pointers to symbol table entry 
%type <idval> constant initializer
%type <idval> direct_declarator init_declarator declarator

// array data type
%type <arr> postfix_expression unary_expression cast_expression

//M marker to keep a track of next instruction during backpatching
%type <inst_num> M

// Auxiliary non-terminal N of type stmt to help in control flow statements
%type <stmt> N

%%
primary_expression: 
        IDENTIFIER
        {
            $$ = new expression();       // Create new expression
            $$->location = $1;           // Store pointer to symbol table entry
            $$->type = "non_bool";
        }
        | constant
        {
            $$ = new expression();       // Create new expression
            $$->location = $1;           // Store pointer to symbol table entry
        }
        | STRING_LITERAL
        {
            $$ = new expression();      // Create new expression
            // store the value of the string in a temporary variable
            $$->location = symbol_table::generate_tem_var(new ST_entry_type("ptr"), $1);  
            $$->location->type->derived_arr = new ST_entry_type("char");
        }
        | LEFT_PARENTHESES expression RIGHT_PARENTHESES
        {
            //copy the content of expression to primary_expression
            $$ = $2;    
        }
        ;

constant: //to handle constants of different
        INTEGER_CONSTANT
        {
            // store the integer constant in a new temporary variable
            $$ = symbol_table::generate_tem_var(new ST_entry_type("int"), convert_int_str($1));   
            //idval = intnum
            add_TAC("=", $$->name, $1);
        }
        | FLOATING_CONSTANT
        {
            //store the floating constant in a new temporary variable
            $$ = symbol_table::generate_tem_var(new ST_entry_type("float"), string($1));
            //idval = floatnum     
            add_TAC("=", $$->name, string($1));
        }
        | CHARACTER_CONSTANT
        {
            //store the character constant in a new temporary variable
            $$ = symbol_table::generate_tem_var(new ST_entry_type("float"), string($1));     
            //idval = char
            add_TAC("=", $$->name, string($1));
        }
        ;

postfix_expression: 
        primary_expression
        {
            //primary expression contains the relevant details of the array
            //store these details in postfix_expression 
            $$ = new array_data_type();                 // Create a new array
            $$->array = $1->location;         // Store the location of the primary expression
            $$->type = $1->location->type;              // Update the type of array
            $$->location = $$->array;         //update the location
        }
        | postfix_expression LEFT_SQUARE expression RIGHT_SQUARE
        {
            //to compute addresses of multi-dimensional array
            $$ = new array_data_type();                  // Create a new array
            $$->type = $1->type->derived_arr;            // Set the type equal to the element type
            $$->array = $1->array;   // Copy the base
            
            // Store the new temporary variable
            $$->location = symbol_table::generate_tem_var(new ST_entry_type("int"));  
            $$->arr_type = "arr";                        // Set arr_type to "arr"

            if($1->arr_type == "arr") {      
                //if postfix_expression is of type arr, [expression] would increase teh dimension of array  
                // multiply the size of the type of subarray with the expression value

                ST_entry* sym = symbol_table::generate_tem_var(new ST_entry_type("int"));
                int size = type_sizeof($$->type);
                
                //a[i][j] = base + i*w1 + j*w2
                add_TAC("*", sym->name, $3->location->name, convert_int_str(size));
                add_TAC("+", $$->location->name, $1->location->name, sym->name);
            }
            else {                                       // if of the form id[E]
                int size = type_sizeof($$->type);
                add_TAC("*", $$->location->name, $3->location->name, convert_int_str(size));
            }
        }
        | postfix_expression LEFT_PARENTHESES argument_expression_listopt RIGHT_PARENTHESES
        {   
            //function call with the function name and parameter list
            $$ = new array_data_type();
            $$->array = symbol_table::generate_tem_var($1->type);
            //call func name, parameter count
            add_TAC("call", $$->array->name, $1->array->name, convert_int_str($3));
        }
        | postfix_expression DOT IDENTIFIER
        {}
        | postfix_expression ARROW IDENTIFIER
        {}
        | postfix_expression SELF_INCREASE
        {   
            $$ = new array_data_type();
            //create a new temp variable
            $$->array = symbol_table::generate_tem_var($1->array->type);      
            
            //for a++: t = a, a = t + 1
            add_TAC("=", $$->array->name, $1->array->name);            // First assign the old value
            add_TAC("+", $1->array->name, $1->array->name, "1");       // Then add 1
        }
        | postfix_expression SELF_DECREASE
        {
            $$ = new array_data_type();         
            //create a new temp variable
            $$->array = symbol_table::generate_tem_var($1->array->type);      
            
            //for a--: t = a, a = t-1
            add_TAC("=", $$->array->name, $1->array->name);            // First assign the old value
            add_TAC("-", $1->array->name, $1->array->name, "1");       // Then subtract 1
        }
        | LEFT_PARENTHESES type_name RIGHT_PARENTHESES LEFT_CURLY initializer_list RIGHT_CURLY
        {}
        | LEFT_PARENTHESES type_name RIGHT_PARENTHESES LEFT_CURLY initializer_list COMMA RIGHT_CURLY
        {}
        ;

argument_expression_listopt: 
        argument_expression_list
        {
            $$ = $1;    // assignment
        }
        |%empty
        {
            $$ = 0;     // No arguments i.e. 0/void
        }
        ;

argument_expression_list: 
        assignment_expression
        {
            $$ = 1;                                  // one argument
            add_TAC("param", $1->location->name);    // TAC: param parameter_1
        }
        | argument_expression_list COMMA assignment_expression
        {
            $$ = $1 + 1;                            // for the next parameter
            add_TAC("param", $3->location->name);   // TAC: param parameter_i
        }
        ;

unary_expression: 
        postfix_expression
        {
            $$ = $1;      // copy the content
        }
        | SELF_INCREASE unary_expression
        {
            //for ++a, a = a + 1
            //pre increment so no need for temporary variable
            add_TAC("+", $2->array->name, $2->array->name, "1");   // Add 1
            $$ = $2;    // Assign
        }
        | SELF_DECREASE unary_expression
        {
            //for --a, a = a - 1
            //pre derement so no need for temporary variable
            add_TAC("-", $2->array->name, $2->array->name, "1");   // Subtract 1
            $$ = $2;    // Assign
        }
        | unary_operator cast_expression
        {
            
            $$ = new array_data_type();
            
            switch($1) {
                case '&':   // Used for addressing (&p)
                    $$->array = symbol_table::generate_tem_var(new ST_entry_type("ptr"));    // Generate a pointer temporary
                    $$->array->type->derived_arr = $2->array->type;                 // Assign corresponding type
                    add_TAC("= &", $$->array->name, $2->array->name);              // generate the TAC quad
                    break;
                
                case '*':   // De-referencing eg *p
                    $$->arr_type = "ptr";
                    $$->location = symbol_table::generate_tem_var($2->array->type->derived_arr);   // Generate a temporary of the appropriate type
                    $$->array = $2->array;                                      // Assign
                    add_TAC("= *", $$->location->name, $2->array->name);                // generate the TAC quad
                    break;
                
                case '+':   // Unary plus eg +2
                    $$ = $2;   //transfer the content
                    break;
                
                case '-':   // Unary minus eg -2 apply the operator on cast_expression
                    $$->array = symbol_table::generate_tem_var(new ST_entry_type($2->array->type->type));    // Generate temporary of the same base type
                    add_TAC("= -", $$->array->name, $2->array->name);                              // generate the TAC quad
                    break;
                
                case '~':   // Bitwise not apply the operator on cast_expression
                    $$->array = symbol_table::generate_tem_var(new ST_entry_type($2->array->type->type));    // Generate temporary of the same base type
                    add_TAC("= ~", $$->array->name, $2->array->name);                              // generate the TAC quad
                    break;
                
                case '!':   // Logical not apply the operator on cast_expression
                    $$->array = symbol_table::generate_tem_var(new ST_entry_type($2->array->type->type));    // Generate temporary of the same base type
                    add_TAC("= !", $$->array->name, $2->array->name);                              // generate the TAC quad
                    break;
            }
        }
        | SIZEOF unary_expression
        {}
        | SIZEOF LEFT_PARENTHESES type_name RIGHT_PARENTHESES
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
        | MINUS
        {
            $$ = '-';
        }
        | EXCLAMATION
        {
            $$ = '!';
        }
        ;

cast_expression: 
    //typecasting
        unary_expression
        {
            $$ = $1;    // copy the content
        }
        | LEFT_PARENTHESES type_name RIGHT_PARENTHESES cast_expression
        {
            //(float)expression
            $$ = new array_data_type();
            // convert the type depending upon type_name
            $$->array = convert_type($4->array, prev_var);    
        }
        ;

/*
To involve an arry in an expression, we need to find the correct address depending upon the indexing
and width of the array. temporary variables storing the appropriate address would be used for indexing

else for normal variables directly assign the values
*/

multiplicative_expression: 
        cast_expression
        {
            $$ = new expression();                  // Generate new expression
            if($1->arr_type == "arr") {             // arr_type "arr"
                // Generate new temporary variable to store the value of array at the index
                $$->location = symbol_table::generate_tem_var($1->location->type); 
                
                //temp = array [ addr ]
                add_TAC("=[]", $$->location->name, $1->array->name, $1->location->name);     // generate the TAC quad
            }
            else if($1->arr_type == "ptr") {          // variable type "ptr"
                
                $$->location = $1->location;          // Assign the pointer to symbol table directly
                //the above instruction is just like copy statement  
            }
            else {
                
                $$->location = $1->array;   //assign the pointers directly for all other variables
            }
        }
        | multiplicative_expression MUL cast_expression
        {   
            // Arithmetic operation requires both the operands to be of compatible type 
            if(typecheck($1->location, $3->array)) { 
                // Generate new expression    
                $$ = new expression();                                                  
                
                //create a new temporary variable to store the product
                $$->location = symbol_table::generate_tem_var(new ST_entry_type($1->location->type->type));    // Generate new temporary
                add_TAC("*", $$->location->name, $1->location->name, $3->array->name);                         // generate the TAC quad
            }
            else {
                //if the operands aren't compatible return error
                yyerror("Type Mismatch");
            }
        }
        | multiplicative_expression F_SLASH cast_expression
        {
            // Division operation require both operands to be type compatible
            if(typecheck($1->location, $3->array)) {
                // Generate new expression    
                $$ = new expression();    

                //create a temporary variable to store the quotient 

                                                          
                $$->location = symbol_table::generate_tem_var(new ST_entry_type($1->location->type->type));    // Generate new temporary
                add_TAC("/", $$->location->name, $1->location->name, $3->array->name);                         // generate the TAC quad
            }
            else {
                yyerror("Type Mismatch");
            }
        }
        | multiplicative_expression MODULO cast_expression
        {
            // modulo
            
            if(typecheck($1->location, $3->array)) {                                                            // Check for type compatibility
                $$ = new expression();                                                                          // Generate new expression
                $$->location = symbol_table::generate_tem_var(new ST_entry_type($1->location->type->type));     // Generate new temporary
                add_TAC("%", $$->location->name, $1->location->name, $3->array->name);                          // generate the TAC quad
            }
            else {
                yyerror("Type Mismatch");
            }
        }
        ;

additive_expression: 
        multiplicative_expression
        {
            $$ = $1;                                                                                             //transfer the content
        }
        | additive_expression PLUS multiplicative_expression
        {   
            // addition
            // Check for type compatibility
            if(typecheck($1->location, $3->location)) {       
                $$ = new expression();                                                                          // Generate new expression
                $$->location = symbol_table::generate_tem_var(new ST_entry_type($1->location->type->type));     // Generate new temporary
                
                add_TAC("+", $$->location->name, $1->location->name, $3->location->name);                       // generate the TAC quad
            }
            else {
                yyerror("Type Mismatch");
            }
        }
        | additive_expression MINUS multiplicative_expression
        {
            // subtraction
            if(typecheck($1->location, $3->location)) {                                                         // Check for type compatibility
                $$ = new expression();                                                                          // Generate new expression
                $$->location = symbol_table::generate_tem_var(new ST_entry_type($1->location->type->type));     // Generate new temporary
                add_TAC("-", $$->location->name, $1->location->name, $3->location->name);                       // generate the TAC quad
            }
            else {
                yyerror("Type Mismatch");
            }
        }
        ;

shift_expression: 
        additive_expression
        {
            $$ = $1;                                                                                            //transfer the content
        }
        | shift_expression LEFT_SHIFT additive_expression
        {
            // left shift
            if($3->location->type->type == "int") {                                                             // Check for type compatibility (int)
                $$ = new expression();                                                                          // Generate new expression
                $$->location = symbol_table::generate_tem_var(new ST_entry_type("int"));                        // Generate new temporary
                add_TAC("<<", $$->location->name, $1->location->name, $3->location->name);                      // generate the TAC quad
            }
            else {
                yyerror("Type Mismatch");
            }
        }
        | shift_expression RIGHT_SHIFT additive_expression
        {
            // right shift
            if($3->location->type->type == "int") {                                                             // Check for type compatibility (int)
                $$ = new expression();                                                                          // Generate new expression
                $$->location = symbol_table::generate_tem_var(new ST_entry_type("int"));                        // Generate new temporary
                add_TAC(">>", $$->location->name, $1->location->name, $3->location->name);                      // generate the TAC quad
            }
            else {
                yyerror("Type Mismatch");
            }
        }
        ;

/*

next set of instructions involve boolean expressions. 
boolean expressions have attributes truelist and falselist which will be backpatched later
*/

relational_expression: 
        shift_expression
        {
            $$ = $1;                                                                                            //transfer the content
        }
        | relational_expression LESS_THAN shift_expression
        {
            if(typecheck($1->location, $3->location)) {                                                         // Check for type compatibility
                $$ = new expression();                                                                          // Generate new boolean expression
                $$->type = "bool";                                                                              //synthesized attributes truelist and falselist
                $$->truelist = makelist(next_instr_count());                                                    // Create truelist for boolean expression
                $$->falselist = makelist(next_instr_count() + 1);                                               // Create falselist for boolean expression
                add_TAC("<", "", $1->location->name, $3->location->name);                                       // generate TAC code "if x < y goto ..."
                add_TAC("goto", "");                                                                            // generate TAC code "goto ..."
            }
            else {
                yyerror("Type Mismatch");
            }
        }
        | relational_expression GREATER_THAN shift_expression
        {
            if(typecheck($1->location, $3->location)) {                                                         // Check for type compatibility
                $$ = new expression();                                                                          // Generate new boolean expression
                $$->type = "bool";
                $$->truelist = makelist(next_instr_count());                                                    // Create truelist for boolean expression
                $$->falselist = makelist(next_instr_count() + 1);                                               // Create falselist for boolean expression
                add_TAC(">", "", $1->location->name, $3->location->name);                                       // generate TAC "if x > y goto ..."
                add_TAC("goto", "");                                                                            // generate TAC "goto ..."
            }
            else {
                yyerror("Type Mismatch");
            }
        }
        | relational_expression LESS_THAN_EQUAL shift_expression
        {
            if(typecheck($1->location, $3->location)) {                                                          // Check for type compatibility
                $$ = new expression();                                                                           // Generate new boolean expression
                $$->type = "bool";
                $$->truelist = makelist(next_instr_count());                                                     // Create truelist for boolean expression
                $$->falselist = makelist(next_instr_count() + 1);                                                // Create falselist for boolean expression
                add_TAC("<=", "", $1->location->name, $3->location->name);                                       // generate TAC "if x <= y goto ..."
                add_TAC("goto", "");                                                                             // generate TAC "goto ..."
            }
            else {
                yyerror("Type Mismatch");
            }
        }
        | relational_expression GREATER_THAN_EQUAL shift_expression
        {
            if(typecheck($1->location, $3->location)) {                                                         // Check for type compatibility
                $$ = new expression();                                                                          // Generate new boolean expression
                $$->type = "bool";
                $$->truelist = makelist(next_instr_count());                                                    // Create truelist for boolean expression
                $$->falselist = makelist(next_instr_count() + 1);                                               // Create falselist for boolean expression
                add_TAC(">=", "", $1->location->name, $3->location->name);                                      // generate TAC "if x >= y goto ..."
                add_TAC("goto", "");                                                                            // generate TAC "goto ..."
            }
            else {
                yyerror("Type Mismatch");
            }
        }
        ;

equality_expression: 
        relational_expression
        {
            $$ = $1;                                                                                            //transfer the content
        }
        | equality_expression EQUAL relational_expression
        {
            if(typecheck($1->location, $3->location)) {                                                         // Check for type compatibility
                convert_bool_int($1);                                                                           // Convert bool to int
                convert_bool_int($3);
                $$ = new expression();                                                                          // Generate new boolean expression
                $$->type = "bool";
                $$->truelist = makelist(next_instr_count());                                                    // Create truelist for boolean expression
                $$->falselist = makelist(next_instr_count() + 1);                                               // Create falselist for boolean expression
                add_TAC("==", "", $1->location->name, $3->location->name);                                      // generate TAC "if x == y goto ..."
                add_TAC("goto", "");                                                                            // generate TAC "goto ..."
            }
            else {
                yyerror("Type Mismatch");
            }
        }
        | equality_expression NOT_EQUAL relational_expression
        {
            if(typecheck($1->location, $3->location)) {                                                         // Check for type compatibility
                convert_bool_int($1);                                                                           // Convert bool to int
                convert_bool_int($3);
                $$ = new expression();                                                                          // Generate new boolean expression
                $$->type = "bool";
                $$->truelist = makelist(next_instr_count());                                                    // Create truelist for boolean expression
                $$->falselist = makelist(next_instr_count() + 1);                                               // Create falselist for boolean expression
                add_TAC("!=", "", $1->location->name, $3->location->name);                                      // generate TAC "if x != y goto ..."
                add_TAC("goto", "");                                                                            // generate TAC "goto ..."
            }
            else {
                yyerror("Type Mismatch");
            }
        }
        ;
/*
the next set of transaltions involve converting expressions to int/non-boolean type,
thus, truelist and falselist attributes now become invalid
a new temporary variable is generated to store the result of the intermediate operations
*/


and_expression: 
        equality_expression
        {
            $$ = $1;                                                                                             //transfer the content
        }
        | and_expression BITWISE_AND equality_expression
        {
            if(typecheck($1->location, $3->location)) {                                                         // Check for type compatibility
                convert_bool_int($1);                                                                           // Convert bool to int
                convert_bool_int($3);
                $$ = new expression();
                $$->type = "not_bool";                                                                          // The new result is not bool
                $$->location = symbol_table::generate_tem_var(new ST_entry_type("int"));                        // Create a new temporary
                add_TAC("&", $$->location->name, $1->location->name, $3->location->name);                       // generate the TAC quad
            }
            else {
                yyerror("Type Mismatch");
            }
        }
        ;

exclusive_or_expression: 
        and_expression
        {
            $$ = $1;                                                                                            //transfer the content
        }
        | exclusive_or_expression BITWISE_XOR and_expression
        {
            if(typecheck($1->location, $3->location)) {                                                         // Check for type compatibility
                convert_bool_int($1);                                                                           // Convert bool to int
                convert_bool_int($3);
                $$ = new expression();
                $$->type = "not_bool";                                                                          // The new result is not bool
                $$->location = symbol_table::generate_tem_var(new ST_entry_type("int"));                        // Create a new temporary
                add_TAC("^", $$->location->name, $1->location->name, $3->location->name);                       // generate the TAC quad
            }
            else {
                yyerror("Type Mismatch");
            }
        }
        ;

inclusive_or_expression: 
        exclusive_or_expression
        {
            $$ = $1;                                                                                            //transfer the content
        }
        | inclusive_or_expression BITWISE_OR exclusive_or_expression
        {
            if(typecheck($1->location, $3->location)) {                                                         // Check for type compatibility
                convert_bool_int($1);                                                                           // Convert bool to int
                convert_bool_int($3);
                $$ = new expression();
                $$->type = "not_bool";                                                                          // The new result is not bool
                $$->location = symbol_table::generate_tem_var(new ST_entry_type("int"));                        // Create a new temporary
                add_TAC("|", $$->location->name, $1->location->name, $3->location->name);                       // generate the TAC quad
            }
            else {
                yyerror("Type Mismatch");
            }
        }
        ;

logical_and_expression: 
        inclusive_or_expression
        {
            $$ = $1;                                                                                            //transfer the content
        }
        | logical_and_expression LOGICAL_AND M inclusive_or_expression
        {
            /*
                augmented the grammar with the non-terminal M marker to have a track of next instruction to be executed during backpatching
            */
            convert_int_bool($1);                                                                               // Convert the expressions from int to bool
            convert_int_bool($4);
            $$ = new expression();                                                                              // Create a new bool expression for the result
            $$->type = "bool";
            backpatch($1->truelist, $3);                                                                        // Backpatching
            $$->truelist = $4->truelist;                                                                        // Generate truelist from truelist of $4
            $$->falselist = merge_list($1->falselist, $4->falselist);                                           // Generate falselist by merging the falselists of $1 and $4
            // B-> B1 && MB2
            // B.truelist = B2.truelist
            // backpatch(B1.truelist, M.instr)
            //B.falselist = merge(B1.falselist, B2.falselist)
        
        }
        ;

logical_or_expression: 
        logical_and_expression
        {   
            $$ = $1;                                                                                            //transfer the content
        }
        | logical_or_expression LOGICAL_BITWISE_OR M logical_and_expression
        {
            convert_int_bool($1);                                                                              // Convert the expressions from int to bool
            convert_int_bool($4);
            $$ = new expression();                                                                             // Create a new bool expression for the result
            $$->type = "bool";
            backpatch($1->falselist, $3);                                                                      // Backpatching
            $$->falselist = $4->falselist;                                                                     // Generate falselist from falselist of $4
            $$->truelist = merge_list($1->truelist, $4->truelist);                                             // Generate truelist by merging the truelists of $1 and $4
            // B-> B1 || MB2
            // B.falselist = B2.falselist
            // backpatch(B1.falselist, M.instr)
            //B.truelist = merge(B1.truelist, B2.truelist)
        
        }
        ;

conditional_expression: 
        logical_or_expression
        {
            $$ = $1;                                                                                            //transfer the content
        }
        | logical_or_expression N QUESTION_MARK M expression N COLON M conditional_expression
        {   
            /*
                grammar is augmented with the non-terminals M marker and N to keep track of next instruction during backpatching
            */
            $$->location = symbol_table::generate_tem_var($5->location->type);                                  // Generate temporary for the expression
            
            add_TAC("=", $$->location->name, $9->location->name);                                               //control through fall
            list<int> l1 = makelist(next_instr_count());
            add_TAC("goto", "");                                                                                // Prevent fall-through
            backpatch($6->nextlist, next_instr_count());                                                        // Make list with next instruction
            add_TAC("=", $$->location->name, $5->location->name);
            list<int> l2 = makelist(next_instr_count());                                                        // Make list with next instruction
            l1 = merge_list(l1, l2);                                                                            // Merge the two lists
            add_TAC("goto", "");                                                                                // Prevent fall-through
            backpatch($2->nextlist, next_instr_count());                                                        // Backpatching
            convert_int_bool($1);                                                                               // Convert expression to bool
            backpatch($1->truelist, $4);                                                                        // When $1 is true, control goes to $4 (expression)
            backpatch($1->falselist, $8);                                                                       // When $1 is false, control goes to $8 (conditional_expression)
            backpatch(l1, next_instr_count());
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

M:      %empty
        {  
            //M - > epsilon 
            //store the count of theb next instruction and will be used for backpatching in control flow statements
            $$ = next_instr_count();
        }
        ;

N:      %empty
        {
            // N -> epsilon 
            // Helps in control flow statments
            $$ = new statement();
            $$->nextlist = makelist(next_instr_count());
            add_TAC("goto", "");
        }
        ;

assignment_expression: 
        conditional_expression
        {
            $$ = $1;                                                                                                //transfer the content
        }
        | unary_expression assignment_operator assignment_expression
        {
            if($1->arr_type == "arr") {                                                                             // If arr_type is "arr", convert and create a TAC quad
                $3->location = convert_type($3->location, $1->type->type);
                add_TAC("[]=", $1->array->name, $1->location->name, $3->location->name);
            }
            else if($1->arr_type == "ptr") {                                                                        // If arr_type is "ptr", create a TAC quad 
                add_TAC("*=", $1->array->name, $3->location->name);
            }
            else {
                $3->location = convert_type($3->location, $1->array->type->type);                                   //for other types convert the data type to make them compatible and create a TAC quad
                add_TAC("=", $1->array->name, $3->location->name);
            }
            $$ = $3;
        }
        ;

assignment_operator: 
        ASSIGN
        {}
        | MUL_ASSIGN
        {}
        | DIV_ASSIGN
        {}
        | MODULO_ASSIGN
        {}
        | PLUS_ASSIGN
        {}
        | MINUS_ASSIGN
        {}
        | LEFT_SHIFT_ASSIGN
        {}
        | RIGHT_SHIFT_ASSIGN
        {}
        | BITWISE_AND_ASSIGN
        {}
        | BITWISE_OR_ASSIGN
        {}
        | BITWISE_XOR_ASSIGN
        {}
        ;

expression: 
        assignment_expression
        {
            $$ = $1;
        }
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
        declaration_specifiers init_declarator_list SEMI_COLON
        {}
        | declaration_specifiers SEMI_COLON
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
        {}
        | init_declarator_list COMMA init_declarator
        {}
        ;

init_declarator: 
        declarator
        {
            $$ = $1;
        }
        | declarator ASSIGN initializer
        {   
            //asssign the initial value to the symbol if any
            if($3->value != "") {
                $1->value = $3->value;
            }
            //generate a TAC quad for the same
            add_TAC("=", $1->name, $3->name);
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
        //since we are asked to handle only void char int and float data type, semantic rules for the same have been added.
        VOID
        {
            prev_var = "void";   // Store the latest encountered type in prev_var
        }
        | CHAR
        {
            prev_var = "char";   // Store the latest encountered type in prev_var
        }
        | SHORT
        {}
        | INT
        {
            prev_var = "int";    // Store the latest encountered type in prev_var
        }
        | LONG
        {}
        | FLOAT
        {
            prev_var = "float";  // Store the latest encountered type in prev_var
        }
        | DOUBLE
        {}
        | SIGNED
        {}
        | UNSIGNED
        {}
        | _BOOL
        {}
        | _COMPLEX
        {}
        | _IMAGINARY
        {}
        | enum_specifier
        {}
        ;

specifier_qualifier_list: 
        type_specifier specifier_qualifier_listopt
        {}
        | type_qualifier specifier_qualifier_listopt
        {}
        ;

specifier_qualifier_listopt: 
        specifier_qualifier_list
        {}
        |%empty
        {}
        ;

enum_specifier: 
        ENUM identifieropt LEFT_CURLY enumerator_list RIGHT_CURLY
        {}
        | ENUM identifieropt LEFT_CURLY enumerator_list COMMA RIGHT_CURLY
        {}
        | ENUM IDENTIFIER
        {}
        ;

identifieropt: 
        IDENTIFIER
        {}
        |%empty
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
        | IDENTIFIER ASSIGN constant_expression
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
            ST_entry_type* t = $1;
            // In case of multi-dimensional arrays, keep traversing down until t points to a basic data type
            while(t->derived_arr != NULL) {
                t = t->derived_arr;
            }
            t->derived_arr = $2->type;       // t now stores a basic data type
            $$ = $2->update_entry($1);       // Update the direct_declarator
        }
        | direct_declarator
        {}
        ;

direct_declarator: 
        IDENTIFIER
        {
            $$ = $1->update_entry(new ST_entry_type(prev_var));   // For the new identifier create a new symbol of previous symbol type
            curr_symbol = $$;                                     // Update pointer to current symbol
        }
        | LEFT_PARENTHESES declarator RIGHT_PARENTHESES
        {
            $$ = $2;                                              //transfer the content
        }
        | direct_declarator LEFT_SQUARE type_qualifier_list assignment_expression RIGHT_SQUARE
        {}
        | direct_declarator LEFT_SQUARE type_qualifier_list RIGHT_SQUARE
        {}
        | direct_declarator LEFT_SQUARE assignment_expression RIGHT_SQUARE
        {
            ST_entry_type* t = $1->type;
            ST_entry_type* prev = NULL;

            // traverse down the array to get the base data type of the array
            while(t->type == "arr") {
                prev = t;
                t = t->derived_arr;
            }
            if(prev == NULL) {
                //that is the type of t is not array
                // create a new array with base data type as type of direct_declarator and width is value of assignment_expression

                int temp = atoi($3->location->value.c_str());                   // Get initial value
                ST_entry_type* tp = new ST_entry_type("arr", $1->type, temp);   // Create that type
                $$ = $1->update_entry(tp);                                      // Update the symbol table for that symbol
            }
            else {
                //t is of type array i.e. this declaration will add a dimension to the array
                // another level of nesting with width being the value of assignment_expression
                
                int temp = atoi($3->location->value.c_str());                   // Get initial value
                prev->derived_arr = new ST_entry_type("arr", t, temp);          // Create that type
                $$ = $1->update_entry($1->type);                                // Update the symbol table for that symbol
            }
        }
        | direct_declarator LEFT_SQUARE RIGHT_SQUARE
        {
            ST_entry_type* t = $1->type;
            ST_entry_type* prev = NULL;
            
            // traverse down the array to get the basic data type
            while(t->type == "arr") {
                prev = t;
                t = t->derived_arr;
            }
            if(prev == NULL) {
                //if the t is not of tytpe array
                //this will create an array of size 0
                ST_entry_type* tp = new ST_entry_type("arr", $1->type, 0);
                $$ = $1->update_entry(tp);
            }
            else {
                //if t is already of type array, this will create a new level of nesting of width 0
                prev->derived_arr = new ST_entry_type("arr", t, 0);
                $$ = $1->update_entry($1->type);
            }
        }
        | direct_declarator LEFT_SQUARE STATIC type_qualifier_list assignment_expression RIGHT_SQUARE
        {}
        | direct_declarator LEFT_SQUARE STATIC assignment_expression RIGHT_SQUARE
        {}
        | direct_declarator LEFT_SQUARE type_qualifier_list STATIC assignment_expression RIGHT_SQUARE
        {}
        | direct_declarator LEFT_SQUARE type_qualifier_list MUL RIGHT_SQUARE
        {}
        | direct_declarator LEFT_SQUARE MUL RIGHT_SQUARE
        {}
        | direct_declarator LEFT_PARENTHESES change_table parameter_type_list RIGHT_PARENTHESES
        {
            //function declaration
            //extract the current symbol table
            curr_symb_table->name = $1->name;
            
            //if the return type of the function is void
            if($1->type->type != "void") {
                //look for the symbol table entry with name return
                ST_entry* s = curr_symb_table->search_lexeme("return");    
                //store the type void as the value of symbol return
                s->update_entry($1->type);
            }

            //make this table nested to the global symbol table
            $1->nested_symbol_table = curr_symb_table;
            curr_symb_table->parent = global_symb_table;    // Update parent of current symbol table
            move_to_table(global_symb_table);               // Switch current table to global symbol table
            curr_symbol = $$;                               // Update current symbol
        }
        | direct_declarator LEFT_PARENTHESES identifier_list RIGHT_PARENTHESES
        {}
        | direct_declarator LEFT_PARENTHESES change_table RIGHT_PARENTHESES
        {
            //function with no parameters
            //extract the current symbol table
            curr_symb_table->name = $1->name;
            //update the value of return symbol to void if the return data type is void
            if($1->type->type != "void") {
                ST_entry* s = curr_symb_table->search_lexeme("return");    // Lookup for return value
                s->update_entry($1->type);
            }

            //make the symbol table of the function as nested table of global symbol table
            $1->nested_symbol_table = curr_symb_table;
            curr_symb_table->parent = global_symb_table;        // Update parent symbol table
            move_to_table(global_symb_table);                   // Switch current table to global symbol table
            curr_symbol = $$;                                   // Update current symbol
        }
        ;

type_qualifier_listopt: 
        type_qualifier_list
        {}
        |%empty
        {}
        ;

// pointer declarations
pointer: 
        MUL type_qualifier_listopt
        {
            $$ = new ST_entry_type("ptr");                       //Create new symbol of type "ptr"
        }
        | MUL type_qualifier_listopt pointer
        {
            $$ = new ST_entry_type("ptr", $3);                   //Create new symbol of type "ptr"
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
        {}
        | parameter_list COMMA ELLIPSIS
        {}
        ;

parameter_list: 
        parameter_declaration
        {}
        | parameter_list COMMA parameter_declaration
        {}
        ;

parameter_declaration: 
        declaration_specifiers declarator
        {}
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
            $$ = $1->location;  //transfer the content
        }
        | LEFT_CURLY initializer_list RIGHT_CURLY
        {}
        | LEFT_CURLY initializer_list COMMA RIGHT_CURLY
        {}
        ;

initializer_list: 
        designationopt initializer
        {}
        | initializer_list COMMA designationopt initializer
        {}
        ;

designationopt: 
        designation
        {}
        |%empty
        {}
        ;

designation: 
        designator_list ASSIGN
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

// statements

statement: 
        labeled_statement
        {}
        | compound_statement
        {
            $$ = $1;                        //transfer the content
        }
        | expression_statement
        {
            $$ = new statement();           // Create new statement
            $$->nextlist = $1->nextlist;    // Assign same nextlist
        }
        | selection_statement
        {
            $$ = $1;                        //transfer the content
        }
        | iteration_statement
        {
            $$ = $1;                        //transfer the content
        }
        | jump_statement
        {
            $$ = $1;                        //transfer the content
        }
        ;

/* new non-terminal for loop */
loop_statement:
        labeled_statement
        {}
        | expression_statement
        {
            $$ = new statement();           // Create new statement
            $$->nextlist = $1->nextlist;    // Assign same nextlist
        }
        | selection_statement
        {
            $$ = $1;    // transfer the content
        }
        | iteration_statement
        {
            $$ = $1;    // transfer the content
        }
        | jump_statement
        {
            $$ = $1;    // transfer the content
        }
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
        LEFT_CURLY change_block change_table block_item_listopt RIGHT_CURLY
        {
            cout<<"compound_statement executed";
            /*
                change_block marker has been added to allow symbol table creation for different blocks
            */
            $$ = $4;
            move_to_table(curr_symb_table->parent);//block has been parsed completely, swicth back to the parent symbol table
        }
        ;

block_item_listopt: 
        block_item_list
        {
            $$ = $1;                //transfer the content
        }
        |%empty
        {
            $$ = new statement();   // Create new statement
        }
        ;

block_item_list: 
        block_item
        {
            $$ = $1;                       //transfer the content
        }
        | block_item_list M block_item
        {   
            /*
                M marker has been added to keep track of next instruction during backpatching
            */
            $$ = $3;
            backpatch($1->nextlist, $2);    // M.instr would be the next instruction after $1 so backpatch 
        }
        ;

block_item: 
        declaration
        {
            $$ = new statement();           // Create new statement
        }
        | statement
        {
            $$ = $1;                        //transfer the content
        }
        ;

expression_statement: 
        expression SEMI_COLON
        {
            $$ = $1;                        //transfer the content
        }
        | SEMI_COLON
        {
            $$ = new expression();          // Create new expression
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
        IF LEFT_PARENTHESES expression RIGHT_PARENTHESES M statement N %prec THEN
        {
            /*
                M and N markers help in backpatching
            */
            convert_int_bool($3);                                           // Convert expression to bool
            $$ = new statement();                                           // Create new statement
            backpatch($3->truelist, $5);                                    // Backpatching 
            
            // Merge falselist of expression, nextlist of statement and nextlist of the last N
            list<int> temp = merge_list($7->nextlist, $6->nextlist);
            $$->nextlist = merge_list($3->falselist, temp);
        }
        | IF LEFT_PARENTHESES expression RIGHT_PARENTHESES M statement N ELSE M statement
        {
            /*
                M and N markers help in backpatching
            */
            convert_int_bool($3);                                   // Convert expression to bool
            $$ = new statement();                                   // Create new statement
            backpatch($3->truelist, $5);                            // Backpatching
            backpatch($3->falselist, $9);
            
            // Merge nextlist of statement, nextlist of N and nextlist of the last statement
            list<int> temp = merge_list($6->nextlist, $7->nextlist);
            $$->nextlist = merge_list($10->nextlist, temp);
        }
        | SWITCH LEFT_PARENTHESES expression RIGHT_PARENTHESES statement
        {}
        ;

iteration_statement: 

        // W D and F will help us print the blockname (variable block)
        //which we need to set before change_block is matched
        // M and N markers are used as usual to keep a track of next instruction to be executed 
        //which would be used for backpatching. 
         WHILE W LEFT_PARENTHESES change_block change_table M expression RIGHT_PARENTHESES M loop_statement
        {   
            
            $$ = new statement();                   // Create a new statement
            convert_int_bool($7);                   // Convert expression to bool
            backpatch($10->nextlist, $6);           // Go back to M1 and expression after one iteration of loop_statement
            backpatch($7->truelist, $9);            // Go to M2 and loop_statement if expression is true
            $$->nextlist = $7->falselist;           // Exit loop if expression is false
            add_TAC("goto", convert_int_str($6));   // generate TAC for to prevent fall-through
            block = "";
            move_to_table(curr_symb_table->parent);
        }
        | WHILE W LEFT_PARENTHESES change_block change_table M expression RIGHT_PARENTHESES LEFT_CURLY M block_item_listopt RIGHT_CURLY
        {
            
            $$ = new statement();                   // Create a new statement
            convert_int_bool($7);                   // Convert expression to bool
            backpatch($11->nextlist, $6);           // Go back to M1 and expression after one iteration
            backpatch($7->truelist, $10);           // Go to M2 and block_item_listopt if expression is true
            $$->nextlist = $7->falselist;           // Exit loop if expression is false
            add_TAC("goto", convert_int_str($6));   // generate TAC for to prevent fall-through
            block = "";
            move_to_table(curr_symb_table->parent);
        }
        | DO D M loop_statement M WHILE LEFT_PARENTHESES expression RIGHT_PARENTHESES SEMI_COLON
        {
            $$ = new statement();                   // Create a new statement     
            convert_int_bool($8);                   // Convert expression to bool
            backpatch($8->truelist, $3);            // Go back to M1 and loop_statement if expression is true
            backpatch($4->nextlist, $5);            // Go to M2 to check expression after statement is complete
            $$->nextlist = $8->falselist;           // Exit loop if expression is false  
            block = "";
        }
        | DO D LEFT_CURLY M block_item_listopt RIGHT_CURLY M WHILE LEFT_PARENTHESES expression RIGHT_PARENTHESES SEMI_COLON
        {
            $$ = new statement();                   // Create a new statement  
            convert_int_bool($10);                  // Convert expression to bool
            backpatch($10->truelist, $4);           // Go back to M1 and block_item_listopt if expression is true
            backpatch($5->nextlist, $7);            // Go to M2 to check expression after block_item_listopt is complete
            $$->nextlist = $10->falselist;          // Exit loop if expression is false  
            block = "";
        }
        | FOR F LEFT_PARENTHESES change_block change_table declaration M expression_statement M expression N RIGHT_PARENTHESES M loop_statement
        {
            
            $$ = new statement();                   // Create a new statement
            convert_int_bool($8);                   // Convert expression to bool
            backpatch($8->truelist, $13);           // Go to M3 if expression is true
            backpatch($11->nextlist, $7);           // Go back to M1 after N
            backpatch($14->nextlist, $9);           // Go back to expression after loop_statement
            add_TAC("goto", convert_int_str($9));   // generate TAC for to prevent fall-through
            $$->nextlist = $8->falselist;           // Exit loop if expression_statement is false
            block = "";
            move_to_table(curr_symb_table->parent);
        }
        | FOR F LEFT_PARENTHESES change_block change_table expression_statement M expression_statement M expression N RIGHT_PARENTHESES M loop_statement
        {
            $$ = new statement();                   // Create a new statement
            convert_int_bool($8);                   // Convert expression to bool
            backpatch($8->truelist, $13);           // Go to M3 if expression is true
            backpatch($11->nextlist, $7);           // Go back to M1 after N
            backpatch($14->nextlist, $9);           // Go back to expression after loop_statement
            add_TAC("goto", convert_int_str($9));   // generate TAC for to prevent fall-through
            $$->nextlist = $8->falselist;           // Exit loop if expression_statement is false
            block = "";
            move_to_table(curr_symb_table->parent);
        }
        | FOR F LEFT_PARENTHESES change_block change_table declaration M expression_statement M expression N RIGHT_PARENTHESES M LEFT_CURLY block_item_listopt RIGHT_CURLY
        {
            $$ = new statement();                   // Create a new statement
            convert_int_bool($8);                   // Convert expression to bool
            backpatch($8->truelist, $13);           // Go to M3 if expression is true
            backpatch($11->nextlist, $7);           // Go back to M1 after N
            backpatch($15->nextlist, $9);           // Go back to expression after loop_statement
            add_TAC("goto", convert_int_str($9));   // generate TAC for to prevent fall-through
            $$->nextlist = $8->falselist;           // Exit loop if expression_statement is false
            block = "";
            move_to_table(curr_symb_table->parent);
        }
        | FOR F LEFT_PARENTHESES change_block change_table expression_statement M expression_statement M expression N RIGHT_PARENTHESES M LEFT_CURLY block_item_listopt RIGHT_CURLY
        {
            $$ = new statement();                   // Create a new statement
            convert_int_bool($8);                   // Convert expression to bool
            backpatch($8->truelist, $13);           // Go to M3 if expression is true
            backpatch($11->nextlist, $7);           // Go back to M1 after N
            backpatch($15->nextlist, $9);           // Go back to expression after loop_statement
            add_TAC("goto", convert_int_str($9));   // generate TAC for to prevent fall-through
            $$->nextlist = $8->falselist;           // Exit loop if expression_statement is false
            block = "";
            move_to_table(curr_symb_table->parent);
        }
        ;

F: %empty
        {   
            //For Loop
            block = "For";
        }
        ;

W: %empty
        {
           // While Loop
            block = "While";
        }
        ;

D: %empty
        {
            //Do While Loop
            block = "Do_While";
        }
        ;


change_block:%empty
        {   
            // Used for creating new nested symbol tables for nested blocks
            string newST = curr_symb_table->name +"->" + block + "." + to_string(num_ST++);  // Generate name for new symbol table
            ST_entry* sym = curr_symb_table->search_lexeme(newST);
            sym->nested_symbol_table = new symbol_table(newST);  // Create new symbol table
            sym->name = newST;
            sym->nested_symbol_table->parent = curr_symb_table;
            sym->type = new ST_entry_type("block");    // The type will be "block"
            curr_symbol = sym;    // Change the current symbol pointer
        }
        ;

change_table:%empty
        {   
            // to chnage the symbol table whenever a function is called
            if(curr_symbol->nested_symbol_table != NULL) {
                // If the symbol table for that function already exists, switch to that table
                move_to_table(curr_symbol->nested_symbol_table);
                add_TAC("label", curr_symb_table->name);
            }
            else {
                // If the symbol table for the function doesn't exist, create a new one and move to the new symbol table
                move_to_table(new symbol_table(""));
            }
        }
        ;

jump_statement: 
        GOTO IDENTIFIER SEMI_COLON
        {}
        | CONTINUE SEMI_COLON
        {
            $$ = new statement();
        }
        | BREAK SEMI_COLON
        {
            $$ = new statement();
        }
        | RETURN expression SEMI_COLON
        {
            $$ = new statement();
            add_TAC("return", $2->location->name);  // generate TAC for return alongwith return value
        }
        | RETURN SEMI_COLON
        {
            $$ = new statement();
            add_TAC("return", "");                   // generate TAC for return without any return value
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
        declaration_specifiers declarator declaration_listopt change_table LEFT_CURLY block_item_listopt RIGHT_CURLY
        {   
            curr_symb_table->parent = global_symb_table;
            num_ST = 0;
            move_to_table(global_symb_table);          // After reaching end of a function, change cureent symbol table to the global symbol table
        }
        ;

declaration_listopt: 
        declaration_list
        {}
        |%empty
        {}
        ;

declaration_list: 
        declaration
        {}
        | declaration_list declaration
        {}
        ;
               
%%

void yyerror(string s) {
    printf("error in Line: %d ( %s )\n" , lineno, s.c_str());
}