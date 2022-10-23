%{
#include "ass5_20CS10085_20CS30065_translator.h"
#include <string>
#include<iomanip>
#include<iostream>
extern int yylex();
extern int lineno;
void yyerror(char *s);
%}


%union{
    int intval;
    char *floatval;
    char *charval;
    char *stringval;
    int inst_num;
    char unary_op;
    int num_params;
    expression* expr;
    statement* stmt;
    ST_entry* idval;
    ST_entry_type* symbol_type;
    array_data_type* arr;
}

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

%right RIGHT_PARENTHESES
%right THEN ELSE

%start translation_unit

%type <unary_op> unary_operator


%type <num_params> argument_expression_list argument_expression_listopt

// Non-terminals of type expr (denoting expressions)
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

// Non-terminals of type stmt (denoting statements)
%type <stmt>
        statement
        compound_statement
        loop_statement
        selection_statement
        iteration_statement
        labeled_statement 
        jump_statement
        blocationk_item
        blocationk_item_list
        blocationk_item_listopt

// The pointer non-terminal is treated with type ST_entry_type
%type <symbol_type> pointer

// Non-terminals of type idval (ST_entry*)
%type <idval> constant initializer
%type <idval> direct_declarator init_declarator declarator

// Non-terminals of type arr
%type <arr> postfix_expression unary_expression cast_expression

// Auxiliary non-terminal M of type instr to help in backpatching
%type <inst_num> M

// Auxiliary non-terminal N of type stmt to help in control flow statements
%type <stmt> N

%%
primary_expression: 
        IDENTIFIER
        {
            $$ = new expression();  // Create new expression
            $$->location = $1;           // Store pointer to entry in the symbol table
            $$->type = "non_bool";
        }
        | constant
        {
            $$ = new expression();  // Create new expression
            $$->location = $1;           // Store pointer to entry in the symbol table
        }
        | STRING_LITERAL
        {
            $$ = new expression();  // Create new expression
            $$->location = symbol_table::generate_tem_var(new ST_entry_type("ptr"), $1);  // Create a new temporary, and store the value in that temporary
            $$->location->type->derived_arr = new ST_entry_type("char");
        }
        | LEFT_PARENTHESES expression RIGHT_PARENTHESES
        {
            $$ = $2;    // Simple assignment
        }
        ;

constant: 
        INTEGER_CONSTANT
        {
            $$ = symbol_table::generate_tem_var(new ST_entry_type("int"), convert_int_str($1));   // Create a new temporary, and store the value in that temporary
            add_TAC("=", $$->name, $1);
        }
        | FLOATING_CONSTANT
        {
            $$ = symbol_table::generate_tem_var(new ST_entry_type("float"), string($1));     // Create a new temporary, and store the value in that temporary
            add_TAC("=", $$->name, string($1));
        }
        | CHARACTER_CONSTANT
        {
            $$ = symbol_table::generate_tem_var(new ST_entry_type("float"), string($1));     // Create a new temporary, and store the value in that temporary
            add_TAC("=", $$->name, string($1));
        }
        ;

postfix_expression: 
        primary_expression
        {
            $$ = new array_data_type();           // Create a new array_data_type
            $$->array_data_type = $1->location;        // Store the locationation of the primary expression
            $$->type = $1->location->type;   // Update the type
            $$->location = $$->array_data_type;
        }
        | postfix_expression LEFT_SQUARE expression RIGHT_SQUARE
        {
            $$ = new array_data_type();               // Create a new array_data_type
            $$->type = $1->type->derived_arr;   // Set the type equal to the element type
            $$->array_data_type = $1->array_data_type;          // Copy the base
            $$->location = symbol_table::generate_tem_var(new ST_entry_type("int"));  // Store address of new temporary
            $$->arr_type = "arr";              // Set arr_type to "arr"

            if($1->arr_type == "arr") {        // If we have an "arr" type then, multiply the size of the sub-type of array_data_type with the expression value and add
                ST_entry* sym = symbol_table::generate_tem_var(new ST_entry_type("int"));
                int sz = type_sizeof($$->type);
                add_TAC("*", sym->name, $3->location->name, convert_int_str(sz));
                add_TAC("+", $$->location->name, $1->location->name, sym->name);
            }
            else {                          // Compute the size
                int sz = type_sizeof($$->type);
                add_TAC("*", $$->location->name, $3->location->name, convert_int_str(sz));
            }
        }
        | postfix_expression LEFT_PARENTHESES argument_expression_listopt RIGHT_PARENTHESES
        {   
            // Corresponds to calling a function with the function name and the appropriate number of parameters
            $$ = new array_data_type();
            $$->array_data_type = symbol_table::generate_tem_var($1->type);
            add_TAC("call", $$->array_data_type->name, $1->array_data_type->name, convert_int_str($3));
        }
        | postfix_expression DOT IDENTIFIER
        { /* Ignored */ }
        | postfix_expression ARROW IDENTIFIER
        { /* Ignored */ }
        | postfix_expression SELF_INCREASE
        {   
            $$ = new array_data_type();
            $$->array_data_type = symbol_table::generate_tem_var($1->array_data_type->type);      // Generate a new temporary
            add_TAC("=", $$->array_data_type->name, $1->array_data_type->name);            // First assign the old value
            add_TAC("+", $1->array_data_type->name, $1->array_data_type->name, "1");       // Then add 1
        }
        | postfix_expression SELF_DECREASE
        {
            $$ = new array_data_type();
            $$->array_data_type = symbol_table::generate_tem_var($1->array_data_type->type);      // Generate a new temporary
            add_TAC("=", $$->array_data_type->name, $1->array_data_type->name);            // First assign the old value
            add_TAC("-", $1->array_data_type->name, $1->array_data_type->name, "1");       // Then subtract 1
        }
        | LEFT_PARENTHESES type_name RIGHT_PARENTHESES LEFT_CURLY initializer_list RIGHT_CURLY
        { /* Ignored */ }
        | LEFT_PARENTHESES type_name RIGHT_PARENTHESES LEFT_CURLY initializer_list COMMA RIGHT_CURLY
        { /* Ignored */ }
        ;

argument_expression_listopt: 
        argument_expression_list
        {
            $$ = $1;    // Assign $1 to $$
        }
        | %empty
        {
            $$ = 0;     // No arguments, just equate to zero
        }
        ;

argument_expression_list: 
        assignment_expression
        {
            $$ = 1;                         // consider one argument
            add_TAC("param", $1->location->name);   // add_TAC parameter
        }
        | argument_expression_list COMMA assignment_expression
        {
            $$ = $1 + 1;                    // consider one more argument, so add 1
            add_TAC("param", $3->location->name);   // add_TAC parameter
        }
        ;

unary_expression: 
        postfix_expression
        {
            $$ = $1;    // Assign $1 to $$
        }
        | SELF_INCREASE unary_expression
        {
            add_TAC("+", $2->array_data_type->name, $2->array_data_type->name, "1");   // Add 1
            $$ = $2;    // Assign
        }
        | SELF_DECREASE unary_expression
        {
            add_TAC("-", $2->array_data_type->name, $2->array_data_type->name, "1");   // Subtract 1
            $$ = $2;    // Assign
        }
        | unary_operator cast_expression
        {
            // Case of unary operator
            $$ = new array_data_type();
            switch($1) {
                case '&':   // Address
                    $$->array_data_type = symbol_table::generate_tem_var(new ST_entry_type("ptr"));    // Generate a pointer temporary
                    $$->array_data_type->type->derived_arr = $2->array_data_type->type;                 // Assign corresponding type
                    add_TAC("= &", $$->array_data_type->name, $2->array_data_type->name);              // Emit the quad
                    break;
                case '*':   // De-referencing
                    $$->arr_type = "ptr";
                    $$->location = symbol_table::generate_tem_var($2->array_data_type->type->derived_arr);   // Generate a temporary of the appropriate type
                    $$->array_data_type = $2->array_data_type;                                      // Assign
                    add_TAC("= *", $$->location->name, $2->array_data_type->name);                // Emit the quad
                    break;
                case '+':   // Unary plus
                    $$ = $2;    // Simple assignment
                    break;
                case '-':   // Unary minus
                    $$->array_data_type = symbol_table::generate_tem_var(new ST_entry_type($2->array_data_type->type->type));    // Generate temporary of the same base type
                    add_TAC("= -", $$->array_data_type->name, $2->array_data_type->name);                              // Emit the quad
                    break;
                case '~':   // Bitwise not
                    $$->array_data_type = symbol_table::generate_tem_var(new ST_entry_type($2->array_data_type->type->type));    // Generate temporary of the same base type
                    add_TAC("= ~", $$->array_data_type->name, $2->array_data_type->name);                              // Emit the quad
                    break;
                case '!':   // Logical not 
                    $$->array_data_type = symbol_table::generate_tem_var(new ST_entry_type($2->array_data_type->type->type));    // Generate temporary of the same base type
                    add_TAC("= !", $$->array_data_type->name, $2->array_data_type->name);                              // Emit the quad
                    break;
            }
        }
        | SIZEOF unary_expression
        { /* Ignored */ }
        | SIZEOF LEFT_PARENTHESES type_name RIGHT_PARENTHESES
        { /* Ignored */ }
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
        unary_expression
        {
            $$ = $1;    // Simple assignment
        }
        | LEFT_PARENTHESES type_name RIGHT_PARENTHESES cast_expression
        {
            $$ = new array_data_type();
            $$->array_data_type = convert_type($4->array_data_type, prev_var);    // Generate a new symbol of the appropriate type
        }
        ;

multiplicative_expression: 
        cast_expression
        {
            $$ = new expression();          // Generate new expression
            if($1->arr_type == "arr") {        // arr_type "arr"
                $$->location = symbol_table::generate_tem_var($1->location->type);  // Generate new temporary
                add_TAC("=[]", $$->location->name, $1->array_data_type->name, $1->location->name);     // Emit the quad
            }
            else if($1->arr_type == "ptr") {   // arr_type "ptr"
                $$->location = $1->location;          // Assign the symbol table entry
            }
            else {
                $$->location = $1->array_data_type;
            }
        }
        | multiplicative_expression MUL cast_expression
        {   
            // Indicates multiplication
            if(typecheck($1->location, $3->array_data_type)) {     // Check for type compatibility
                $$ = new expression();                                                  // Generate new expression
                $$->location = symbol_table::generate_tem_var(new ST_entry_type($1->location->type->type));    // Generate new temporary
                add_TAC("*", $$->location->name, $1->location->name, $3->array_data_type->name);               // Emit the quad
            }
            else {
                yyerror("Type Error");
            }
        }
        | multiplicative_expression F_SLASH cast_expression
        {
            // Indicates division
            if(typecheck($1->location, $3->array_data_type)) {     // Check for type compatibility
                $$ = new expression();                                                  // Generate new expression
                $$->location = symbol_table::generate_tem_var(new ST_entry_type($1->location->type->type));    // Generate new temporary
                add_TAC("/", $$->location->name, $1->location->name, $3->array_data_type->name);               // Emit the quad
            }
            else {
                yyerror("Type Error");
            }
        }
        | multiplicative_expression MODULO cast_expression
        {
            // Indicates modulo
            if(typecheck($1->location, $3->array_data_type)) {     // Check for type compatibility
                $$ = new expression();                                                  // Generate new expression
                $$->location = symbol_table::generate_tem_var(new ST_entry_type($1->location->type->type));    // Generate new temporary
                add_TAC("%", $$->location->name, $1->location->name, $3->array_data_type->name);               // Emit the quad
            }
            else {
                yyerror("Type Error");
            }
        }
        ;

additive_expression: 
        multiplicative_expression
        {
            $$ = $1;    // Simple assignment
        }
        | additive_expression PLUS multiplicative_expression
        {   
            // Indicates addition
            if(typecheck($1->location, $3->location)) {       // Check for type compatibility
                $$ = new expression();                                                  // Generate new expression
                $$->location = symbol_table::generate_tem_var(new ST_entry_type($1->location->type->type));    // Generate new temporary
                add_TAC("+", $$->location->name, $1->location->name, $3->location->name);                 // Emit the quad
            }
            else {
                yyerror("Type Error");
            }
        }
        | additive_expression MINUS multiplicative_expression
        {
            // Indicates subtraction
            if(typecheck($1->location, $3->location)) {       // Check for type compatibility
                $$ = new expression();                                                  // Generate new expression
                $$->location = symbol_table::generate_tem_var(new ST_entry_type($1->location->type->type));    // Generate new temporary
                add_TAC("-", $$->location->name, $1->location->name, $3->location->name);                 // Emit the quad
            }
            else {
                yyerror("Type Error");
            }
        }
        ;

shift_expression: 
        additive_expression
        {
            $$ = $1;    // Simple assignment
        }
        | shift_expression LEFT_SHIFT additive_expression
        {
            // Indicates left shift
            if($3->location->type->type == "int") {      // Check for type compatibility (int)
                $$ = new expression();                                      // Generate new expression
                $$->location = symbol_table::generate_tem_var(new ST_entry_type("int"));      // Generate new temporary
                add_TAC("<<", $$->location->name, $1->location->name, $3->location->name);    // Emit the quad
            }
            else {
                yyerror("Type Error");
            }
        }
        | shift_expression RIGHT_SHIFT additive_expression
        {
            // Indicates right shift
            if($3->location->type->type == "int") {      // Check for type compatibility (int)
                $$ = new expression();                                      // Generate new expression
                $$->location = symbol_table::generate_tem_var(new ST_entry_type("int"));      // Generate new temporary
                add_TAC(">>", $$->location->name, $1->location->name, $3->location->name);    // Emit the quad
            }
            else {
                yyerror("Type Error");
            }
        }
        ;

relational_expression: 
        shift_expression
        {
            $$ = $1;    // Simple assignment
        }
        | relational_expression LESS_THAN shift_expression
        {
            if(typecheck($1->location, $3->location)) {                   // Check for type compatibility
                $$ = new expression();                          // Generate new expression of type bool
                $$->type = "bool";
                $$->truelist = makelist(next_instr_count());           // Create truelist for boolean expression
                $$->falselist = makelist(next_instr_count() + 1);      // Create falselist for boolean expression
                add_TAC("<", "", $1->location->name, $3->location->name);    // Emit "if x < y goto ..."
                add_TAC("goto", "");                               // Emit "goto ..."
            }
            else {
                yyerror("Type Error");
            }
        }
        | relational_expression GREATER_THAN shift_expression
        {
            if(typecheck($1->location, $3->location)) {                   // Check for type compatibility
                $$ = new expression();                          // Generate new expression of type bool
                $$->type = "bool";
                $$->truelist = makelist(next_instr_count());           // Create truelist for boolean expression
                $$->falselist = makelist(next_instr_count() + 1);      // Create falselist for boolean expression
                add_TAC(">", "", $1->location->name, $3->location->name);    // Emit "if x > y goto ..."
                add_TAC("goto", "");                               // Emit "goto ..."
            }
            else {
                yyerror("Type Error");
            }
        }
        | relational_expression LESS_THAN_EQUAL shift_expression
        {
            if(typecheck($1->location, $3->location)) {                   // Check for type compatibility
                $$ = new expression();                          // Generate new expression of type bool
                $$->type = "bool";
                $$->truelist = makelist(next_instr_count());           // Create truelist for boolean expression
                $$->falselist = makelist(next_instr_count() + 1);      // Create falselist for boolean expression
                add_TAC("<=", "", $1->location->name, $3->location->name);   // Emit "if x <= y goto ..."
                add_TAC("goto", "");                               // Emit "goto ..."
            }
            else {
                yyerror("Type Error");
            }
        }
        | relational_expression GREATER_THAN_EQUAL shift_expression
        {
            if(typecheck($1->location, $3->location)) {                   // Check for type compatibility
                $$ = new expression();                          // Generate new expression of type bool
                $$->type = "bool";
                $$->truelist = makelist(next_instr_count());           // Create truelist for boolean expression
                $$->falselist = makelist(next_instr_count() + 1);      // Create falselist for boolean expression
                add_TAC(">=", "", $1->location->name, $3->location->name);   // Emit "if x >= y goto ..."
                add_TAC("goto", "");                               // Emit "goto ..."
            }
            else {
                yyerror("Type Error");
            }
        }
        ;

equality_expression: 
        relational_expression
        {
            $$ = $1;    // Simple assignment
        }
        | equality_expression EQUAL relational_expression
        {
            if(typecheck($1->location, $3->location)) {                   // Check for type compatibility
                convert_bool_int($1);                           // Convert bool to int
                convert_bool_int($3);
                $$ = new expression();                          // Generate new expression of type bool
                $$->type = "bool";
                $$->truelist = makelist(next_instr_count());           // Create truelist for boolean expression
                $$->falselist = makelist(next_instr_count() + 1);      // Create falselist for boolean expression
                add_TAC("==", "", $1->location->name, $3->location->name);   // Emit "if x == y goto ..."
                add_TAC("goto", "");                               // Emit "goto ..."
            }
            else {
                yyerror("Type Error");
            }
        }
        | equality_expression NOT_EQUAL relational_expression
        {
            if(typecheck($1->location, $3->location)) {                   // Check for type compatibility
                convert_bool_int($1);                           // Convert bool to int
                convert_bool_int($3);
                $$ = new expression();                          // Generate new expression of type bool
                $$->type = "bool";
                $$->truelist = makelist(next_instr_count());           // Create truelist for boolean expression
                $$->falselist = makelist(next_instr_count() + 1);      // Create falselist for boolean expression
                add_TAC("!=", "", $1->location->name, $3->location->name);   // Emit "if x != y goto ..."
                add_TAC("goto", "");                               // Emit "goto ..."
            }
            else {
                yyerror("Type Error");
            }
        }
        ;

and_expression: 
        equality_expression
        {
            $$ = $1;    // Simple assignment
        }
        | and_expression BITWISE_AND equality_expression
        {
            if(typecheck($1->location, $3->location)) {                               // Check for type compatibility
                convert_bool_int($1);                                       // Convert bool to int
                convert_bool_int($3);
                $$ = new expression();
                $$->type = "not_bool";                                      // The new result is not bool
                $$->location = symbol_table::generate_tem_var(new ST_entry_type("int"));      // Create a new temporary
                add_TAC("&", $$->location->name, $1->location->name, $3->location->name);     // Emit the quad
            }
            else {
                yyerror("Type Error");
            }
        }
        ;

exclusive_or_expression: 
        and_expression
        {
            $$ = $1;    // Simple assignment
        }
        | exclusive_or_expression BITWISE_XOR and_expression
        {
            if(typecheck($1->location, $3->location)) {                               // Check for type compatibility
                convert_bool_int($1);                                       // Convert bool to int
                convert_bool_int($3);
                $$ = new expression();
                $$->type = "not_bool";                                      // The new result is not bool
                $$->location = symbol_table::generate_tem_var(new ST_entry_type("int"));      // Create a new temporary
                add_TAC("^", $$->location->name, $1->location->name, $3->location->name);     // Emit the quad
            }
            else {
                yyerror("Type Error");
            }
        }
        ;

inclusive_or_expression: 
        exclusive_or_expression
        {
            $$ = $1;    // Simple assignment
        }
        | inclusive_or_expression BITWISE_OR exclusive_or_expression
        {
            if(typecheck($1->location, $3->location)) {                               // Check for type compatibility
                convert_bool_int($1);                                       // Convert bool to int
                convert_bool_int($3);
                $$ = new expression();
                $$->type = "not_bool";                                      // The new result is not bool
                $$->location = symbol_table::generate_tem_var(new ST_entry_type("int"));      // Create a new temporary
                add_TAC("|", $$->location->name, $1->location->name, $3->location->name);     // Emit the quad
            }
            else {
                yyerror("Type Error");
            }
        }
        ;

logical_and_expression: 
        inclusive_or_expression
        {
            $$ = $1;    // Simple assignment
        }
        | logical_and_expression LOGICAL_AND M inclusive_or_expression
        {
            /*
                Here, we have augmented the grammar with the non-terminal M to facilitate backpatching
            */
            convert_int_bool($1);                                   // Convert the expressions from int to bool
            convert_int_bool($4);
            $$ = new expression();                                  // Create a new bool expression for the result
            $$->type = "bool";
            backpatch($1->truelist, $3);                            // Backpatching
            $$->truelist = $4->truelist;                            // Generate truelist from truelist of $4
            $$->falselist = merge_list($1->falselist, $4->falselist);    // Generate falselist by merging the falselists of $1 and $4
        }
        ;

logical_or_expression: 
        logical_and_expression
        {
            $$ = $1;    // Simple assignment
        }
        | logical_or_expression LOGICAL_BITWISE_OR M logical_and_expression
        {
            convert_int_bool($1);                                   // Convert the expressions from int to bool
            convert_int_bool($4);
            $$ = new expression();                                  // Create a new bool expression for the result
            $$->type = "bool";
            backpatch($1->falselist, $3);                           // Backpatching
            $$->falselist = $4->falselist;                          // Generate falselist from falselist of $4
            $$->truelist = merge_list($1->truelist, $4->truelist);       // Generate truelist by merging the truelists of $1 and $4
        }
        ;

conditional_expression: 
        logical_or_expression
        {
            $$ = $1;    // Simple assignment
        }
        | logical_or_expression N QUESTION_MARK M expression N COLON M conditional_expression
        {   
            /*
                Note the augmented grammar with the non-terminals M and N
            */
            $$->location = symbol_table::generate_tem_var($5->location->type);      // Generate temporary for the expression
            $$->location->update_entry($5->location->type);
            add_TAC("=", $$->location->name, $9->location->name);            // Assign the conditional expression
            list<int> l1 = makelist(next_instr_count());
            add_TAC("goto", "");                                   // Prevent fall-through
            backpatch($6->nextlist, next_instr_count());               // Make list with next instruction
            add_TAC("=", $$->location->name, $5->location->name);
            list<int> l2 = makelist(next_instr_count());               // Make list with next instruction
            l1 = merge_list(l1, l2);                                 // Merge the two lists
            add_TAC("goto", "");                                   // Prevent fall-through
            backpatch($2->nextlist, next_instr_count());               // Backpatching
            convert_int_bool($1);                               // Convert expression to bool
            backpatch($1->truelist, $4);                        // When $1 is true, control goes to $4 (expression)
            backpatch($1->falselist, $8);                       // When $1 is false, control goes to $8 (conditional_expression)
            backpatch(l1, next_instr_count());
        }
        ;

M: %empty
        {   
            // Stores the next instruction value, and helps in backpatching
            $$ = next_instr_count();
        }
        ;

N: %empty
        {
            // Helps in control flow
            $$ = new statement();
            $$->nextlist = makelist(next_instr_count());
            add_TAC("goto", "");
        }
        ;

assignment_expression: 
        conditional_expression
        {
            $$ = $1;    // Simple assignment
        }
        | unary_expression assignment_operator assignment_expression
        {
            if($1->arr_type == "arr") {        // If arr_type is "arr", convert and add_TAC
                $3->location = convert_type($3->location, $1->type->type);
                add_TAC("[]=", $1->array_data_type->name, $1->location->name, $3->location->name);
            }
            else if($1->arr_type == "ptr") {   // If arr_type is "ptr", add_TAC 
                add_TAC("*=", $1->array_data_type->name, $3->location->name);
            }
            else {
                $3->location = convert_type($3->location, $1->array_data_type->type->type);
                add_TAC("=", $1->array_data_type->name, $3->location->name);
            }
            $$ = $3;
        }
        ;

assignment_operator: 
        ASSIGN
        { /* Ignored */ }
        | MUL_ASSIGN
        { /* Ignored */ }
        | DIV_ASSIGN
        { /* Ignored */ }
        | MODULO_ASSIGN
        { /* Ignored */ }
        | PLUS_ASSIGN
        { /* Ignored */ }
        | MINUS_ASSIGN
        { /* Ignored */ }
        | LEFT_SHIFT_ASSIGN
        { /* Ignored */ }
        | RIGHT_SHIFT_ASSIGN
        { /* Ignored */ }
        | BITWISE_AND_ASSIGN
        { /* Ignored */ }
        | BITWISE_OR_ASSIGN
        { /* Ignored */ }
        | BITWISE_XOR_ASSIGN
        { /* Ignored */ }
        ;

expression: 
        assignment_expression
        {
            $$ = $1;
        }
        | expression COMMA assignment_expression
        { /* Ignored */ }
        ;

constant_expression: 
        conditional_expression
        { /* Ignored */ }
        ;

declaration: 
        declaration_specifiers init_declarator_list SEMI_COLON
        { /* Ignored */ }
        | declaration_specifiers SEMI_COLON
        { /* Ignored */ }
        ;

declaration_specifiers: 
        storage_class_specifier declaration_specifiers
        { /* Ignored */ }
        |storage_class_specifier
        { /* Ignored */ }
        | type_specifier declaration_specifiers
        { /* Ignored */ }
        | type_specifier
        { /* Ignored */ }
        | type_qualifier declaration_specifiers
        { /* Ignored */ }
        | type_qualifier
        { /* Ignored */ }
        | function_specifier declaration_specifiers
        { /* Ignored */ }
        | function_specifier
        { /* Ignored */ }
        ;

init_declarator_list: 
        init_declarator
        { /* Ignored */ }
        | init_declarator_list COMMA init_declarator
        { /* Ignored */ }
        ;

init_declarator: 
        declarator
        {
            $$ = $1;
        }
        | declarator ASSIGN initializer
        {   
            // Find out the initial value and add_TAC it
            if($3->value != "") {
                $1->value = $3->value;
            }
            add_TAC("=", $1->name, $3->name);
        }
        ;

storage_class_specifier: 
        EXTERN
        { /* Ignored */ }
        | STATIC
        { /* Ignored */ }
        | AUTO
        { /* Ignored */ }
        | REGISTER
        { /* Ignored */ }
        ;

type_specifier: 
        VOID
        {
            prev_var = "void";   // Store the latest encountered type in prev_var
        }
        | CHAR
        {
            prev_var = "char";   // Store the latest encountered type in prev_var
        }
        | SHORT
        { /* Ignored */ }
        | INT
        {
            prev_var = "int";    // Store the latest encountered type in prev_var
        }
        | LONG
        { /* Ignored */ }
        | FLOAT
        {
            prev_var = "float";  // Store the latest encountered type in prev_var
        }
        | DOUBLE
        { /* Ignored */ }
        | SIGNED
        { /* Ignored */ }
        | UNSIGNED
        { /* Ignored */ }
        | _BOOL
        { /* Ignored */ }
        | _COMPLEX
        { /* Ignored */ }
        | _IMAGINARY
        { /* Ignored */ }
        | enum_specifier
        { /* Ignored */ }
        ;

specifier_qualifier_list: 
        type_specifier specifier_qualifier_listopt
        { /* Ignored */ }
        | type_qualifier specifier_qualifier_listopt
        { /* Ignored */ }
        ;

specifier_qualifier_listopt: 
        specifier_qualifier_list
        { /* Ignored */ }
        | %empty
        { /* Ignored */ }
        ;

enum_specifier: 
        ENUM identifieropt LEFT_CURLY enumerator_list RIGHT_CURLY
        { /* Ignored */ }
        | ENUM identifieropt LEFT_CURLY enumerator_list COMMA RIGHT_CURLY
        { /* Ignored */ }
        | ENUM IDENTIFIER
        { /* Ignored */ }
        ;

identifieropt: 
        IDENTIFIER
        {/* Ignored */}
        | %empty
        {/* Ignored */}
        ;

enumerator_list: 
        enumerator
        {/* Ignored */}
        | enumerator_list COMMA enumerator
        {/* Ignored */}
        ;

enumerator: 
        IDENTIFIER
        {/* Ignored */}
        | IDENTIFIER ASSIGN constant_expression
        {/* Ignored */}
        ;

type_qualifier: 
        CONST
        {/* Ignored */}
        | RESTRICT
        {/* Ignored */}
        | VOLATILE
        {/* Ignored */}
        ;

function_specifier: 
        INLINE
        {/* Ignored */}
        ;

declarator: 
        pointer direct_declarator
        {
            ST_entry_type* t = $1;
            // In case of multi-dimesnional array_data_types, keep on going down in a hierarchial fashion to get the base type
            while(t->derived_arr != NULL) {
                t = t->derived_arr;
            }
            t->derived_arr = $2->type;  // Store the base type
            $$ = $2->update_entry($1);    // Update
        }
        | direct_declarator
        {/* Ignored */}
        ;

direct_declarator: 
        IDENTIFIER
        {
            $$ = $1->update_entry(new ST_entry_type(prev_var));   // For an identifier, update the type to prev_var
            curr_symbol = $$;                         // Update pointer to current symbol
        }
        | LEFT_PARENTHESES declarator RIGHT_PARENTHESES
        {
            $$ = $2;    // Simple assignment
        }
        | direct_declarator LEFT_SQUARE type_qualifier_list assignment_expression RIGHT_SQUARE
        { /* Ignored */ }
        | direct_declarator LEFT_SQUARE type_qualifier_list RIGHT_SQUARE
        { /* Ignored */ }
        | direct_declarator LEFT_SQUARE assignment_expression RIGHT_SQUARE
        {
            ST_entry_type* t = $1->type;
            ST_entry_type* prev = NULL;
            // Keep moving recursively to get the base type
            while(t->type == "arr") {
                prev = t;
                t = t->derived_arr;
            }
            if(prev == NULL) {
                int temp = atoi($3->location->value.c_str());                // Get initial value
                ST_entry_type* tp = new ST_entry_type("arr", $1->type, temp); // Create that type
                $$ = $1->update_entry(tp);                                    // Update the symbol table for that symbol
            }
            else {
                int temp = atoi($3->location->value.c_str());                // Get initial value
                prev->derived_arr = new ST_entry_type("arr", t, temp);         // Create that type
                $$ = $1->update_entry($1->type);                              // Update the symbol table for that symbol
            }
        }
        | direct_declarator LEFT_SQUARE RIGHT_SQUARE
        {
            ST_entry_type* t = $1->type;
            ST_entry_type* prev = NULL;
            // Keep moving recursively to get the base type
            while(t->type == "arr") {
                prev = t;
                t = t->derived_arr;
            }
            if(prev == NULL) {
                ST_entry_type* tp = new ST_entry_type("arr", $1->type, 0);
                $$ = $1->update_entry(tp);
            }
            else {
                prev->derived_arr = new ST_entry_type("arr", t, 0);
                $$ = $1->update_entry($1->type);
            }
        }
        | direct_declarator LEFT_SQUARE STATIC type_qualifier_list assignment_expression RIGHT_SQUARE
        { /* Ignored */ }
        | direct_declarator LEFT_SQUARE STATIC assignment_expression RIGHT_SQUARE
        { /* Ignored */ }
        | direct_declarator LEFT_SQUARE type_qualifier_list STATIC assignment_expression RIGHT_SQUARE
        { /* Ignored */ }
        | direct_declarator LEFT_SQUARE type_qualifier_list MUL RIGHT_SQUARE
        { /* Ignored */ }
        | direct_declarator LEFT_SQUARE MUL RIGHT_SQUARE
        { /* Ignored */ }
        | direct_declarator LEFT_PARENTHESES change_table parameter_type_list RIGHT_PARENTHESES
        {
            curr_symb_table->name = $1->name;
            if($1->type->type != "void") {
                ST_entry* s = curr_symb_table->search_lexeme("return");    // Lookup for return value
                s->update_entry($1->type);
            }
            $1->nested_symbol_table = curr_symb_table;
            curr_symb_table->parent = global_symb_table;   // Update parent symbol table
            move_to_table(global_symb_table);          // Switch current table to point to the global symbol table
            curr_symbol = $$;             // Update current symbol
        }
        | direct_declarator LEFT_PARENTHESES identifier_list RIGHT_PARENTHESES
        { /* Ignored */ }
        | direct_declarator LEFT_PARENTHESES change_table RIGHT_PARENTHESES
        {
            curr_symb_table->name = $1->name;
            if($1->type->type != "void") {
                ST_entry* s = curr_symb_table->search_lexeme("return");    // Lookup for return value
                s->update_entry($1->type);
            }
            $1->nested_symbol_table = curr_symb_table;
            curr_symb_table->parent = global_symb_table;   // Update parent symbol table
            move_to_table(global_symb_table);          // Switch current table to point to the global symbol table
            curr_symbol = $$;             // Update current symbol
        }
        ;

type_qualifier_listopt: 
        type_qualifier_list
        { /* Ignored */ }
        | %empty
        { /* Ignored */ }
        ;

pointer: 
        MUL type_qualifier_listopt
        {
            $$ = new ST_entry_type("ptr");     //  Create new type "ptr"
        }
        | MUL type_qualifier_listopt pointer
        {
            $$ = new ST_entry_type("ptr", $3); //  Create new type "ptr"
        }
        ;

type_qualifier_list: 
        type_qualifier
        { /* Ignored */ }
        | type_qualifier_list type_qualifier
        { /* Ignored */ }
        ;

parameter_type_list: 
        parameter_list
        { /* Ignored */ }
        | parameter_list COMMA ELLIPSIS
        { /* Ignored */ }
        ;

parameter_list: 
        parameter_declaration
        { /* Ignored */ }
        | parameter_list COMMA parameter_declaration
        { /* Ignored */ }
        ;

parameter_declaration: 
        declaration_specifiers declarator
        { /* Ignored */ }
        | declaration_specifiers
        { /* Ignored */ }
        ;

identifier_list: 
        IDENTIFIER
        { /* Ignored */ }
        | identifier_list COMMA IDENTIFIER
        { /* Ignored */ }
        ;

type_name: 
        specifier_qualifier_list
        { /* Ignored */ }
        ;

initializer: 
        assignment_expression
        {
            $$ = $1->location;   // Simple assignment
        }
        | LEFT_CURLY initializer_list RIGHT_CURLY
        { /* Ignored */ }
        | LEFT_CURLY initializer_list COMMA RIGHT_CURLY
        { /* Ignored */ }
        ;

initializer_list: 
        designationopt initializer
        { /* Ignored */ }
        | initializer_list COMMA designationopt initializer
        { /* Ignored */ }
        ;

designationopt: 
        designation
        { /* Ignored */ }
        | %empty
        { /* Ignored */ }
        ;

designation: 
        designator_list ASSIGN
        { /* Ignored */ }
        ;

designator_list: 
        designator
        { /* Ignored */ }
        | designator_list designator
        { /* Ignored */ }
        ;

designator: 
        LEFT_SQUARE constant_expression RIGHT_SQUARE
        { /* Ignored */ }
        | DOT IDENTIFIER
        { /* Ignored */ }
        ;

statement: 
        labeled_statement
        { /* Ignored */ }
        | compound_statement
        {
            $$ = $1;    // Simple assignment
        }
        | expression_statement
        {
            $$ = new statement();           // Create new statement
            $$->nextlist = $1->nextlist;    // Assign same nextlist
        }
        | selection_statement
        {
            $$ = $1;    // Simple assignment
        }
        | iteration_statement
        {
            $$ = $1;    // Simple assignment
        }
        | jump_statement
        {
            $$ = $1;    // Simple assignment
        }
        ;

/* New non-terminal that has been added to facilitate the structure of loops */
loop_statement:
        labeled_statement
        { /* Ignored */ }
        | expression_statement
        {
            $$ = new statement();           // Create new statement
            $$->nextlist = $1->nextlist;    // Assign same nextlist
        }
        | selection_statement
        {
            $$ = $1;    // Simple assignment
        }
        | iteration_statement
        {
            $$ = $1;    // Simple assignment
        }
        | jump_statement
        {
            $$ = $1;    // Simple assignment
        }
        ;

labeled_statement: 
        IDENTIFIER COLON statement
        { /* Ignored */ }
        | CASE constant_expression COLON statement
        { /* Ignored */ }
        | DEFAULT COLON statement
        { /* Ignored */ }
        ;

compound_statement: 
        LEFT_CURLY X change_table blocationk_item_listopt RIGHT_CURLY
        {
            /*
                Here, the grammar has been augmented with non-terminals like X and change_table to allow creation of nested symbol tables
            */
            $$ = $4;
            move_to_table(curr_symb_table->parent);     // Update current symbol table
        }
        ;

blocationk_item_listopt: 
        blocationk_item_list
        {
            $$ = $1;    // Simple assignment
        }
        | %empty
        {
            $$ = new statement();   // Create new statement
        }
        ;

blocationk_item_list: 
        blocationk_item
        {
            $$ = $1;    // Simple assignment
        }
        | blocationk_item_list M blocationk_item
        {   
            /*
                This production rule has been augmented with the non-terminal M
            */
            $$ = $3;
            backpatch($1->nextlist, $2);    // After $1, move to blocationk_item via $2
        }
        ;

blocationk_item: 
        declaration
        {
            $$ = new statement();   // Create new statement
        }
        | statement
        {
            $$ = $1;    // Simple assignment
        }
        ;

expression_statement: 
        expression SEMI_COLON
        {
            $$ = $1;    // Simple assignment
        }
        | SEMI_COLON
        {
            $$ = new expression();  // Create new expression
        }
        ;

selection_statement: 
        IF LEFT_PARENTHESES expression N RIGHT_PARENTHESES M statement N %prec THEN
        {
            /*
                This production rule has been augmented for control flow
            */
            backpatch($4->nextlist, next_instr_count());                   // nextlist of N now has next_instr_count
            convert_int_bool($3);                                   // Convert expression to bool
            $$ = new statement();                                   // Create new statement
            backpatch($3->truelist, $6);                            // Backpatching - if expression is true, go to M
            // Merge falselist of expression, nextlist of statement and nextlist of the last N
            list<int> temp = merge_list($3->falselist, $7->nextlist);
            $$->nextlist = merge_list($8->nextlist, temp);
        }
        | IF LEFT_PARENTHESES expression N RIGHT_PARENTHESES M statement N ELSE M statement
        {
            /*
                This production rule has been augmented for control flow
            */
            backpatch($4->nextlist, next_instr_count());                   // nextlist of N now has next_instr_count
            convert_int_bool($3);                                   // Convert expression to bool
            $$ = new statement();                                   // Create new statement
            backpatch($3->truelist, $6);                            // Backpatching - if expression is true, go to first M, else go to second M
            backpatch($3->falselist, $10);
            // Merge nextlist of statement, nextlist of N and nextlist of the last statement
            list<int> temp = merge_list($7->nextlist, $8->nextlist);
            $$->nextlist = merge_list($11->nextlist, temp);
        }
        | SWITCH LEFT_PARENTHESES expression RIGHT_PARENTHESES statement
        { /* Ignored */ }
        ;

iteration_statement: 
        WHILE W LEFT_PARENTHESES X change_table M expression RIGHT_PARENTHESES M loop_statement
        {   
            /*
                This production rule has been augmented with non-terminals like W, X, change_table and M to handle the control flow, 
                backpatching, detect the kind of loop, create a separate symbol table for the loop blocationk and give it an appropriate name
            */
            $$ = new statement();                   // Create a new statement
            convert_int_bool($7);                   // Convert expression to bool
            backpatch($10->nextlist, $6);           // Go back to M1 and expression after one iteration of loop_statement
            backpatch($7->truelist, $9);            // Go to M2 and loop_statement if expression is true
            $$->nextlist = $7->falselist;           // Exit loop if expression is false
            add_TAC("goto", convert_int_str($6));   // Emit to prevent fall-through
            block = "";
            move_to_table(curr_symb_table->parent);
        }
        | WHILE W LEFT_PARENTHESES X change_table M expression RIGHT_PARENTHESES LEFT_CURLY M blocationk_item_listopt RIGHT_CURLY
        {
            /*
                This production rule has been augmented with non-terminals like W, X, change_table and M to handle the control flow, 
                backpatching, detect the kind of loop, create a separate symbol table for the loop blocationk and give it an appropriate name
            */
            $$ = new statement();                   // Create a new statement
            convert_int_bool($7);                   // Convert expression to bool
            backpatch($11->nextlist, $6);           // Go back to M1 and expression after one iteration
            backpatch($7->truelist, $10);           // Go to M2 and blocationk_item_listopt if expression is true
            $$->nextlist = $7->falselist;           // Exit loop if expression is false
            add_TAC("goto", convert_int_str($6));   // Emit to prevent fall-through
            block = "";
            move_to_table(curr_symb_table->parent);
        }
        | DO D M loop_statement M WHILE LEFT_PARENTHESES expression RIGHT_PARENTHESES SEMI_COLON
        {
            /*
                This production rule has been augmented with non-terminals like D and M to handle the control flow, backpatching and detect the kind of loop
            */
            $$ = new statement();                   // Create a new statement     
            convert_int_bool($8);                   // Convert expression to bool
            backpatch($8->truelist, $3);            // Go back to M1 and loop_statement if expression is true
            backpatch($4->nextlist, $5);            // Go to M2 to check expression after statement is complete
            $$->nextlist = $8->falselist;           // Exit loop if expression is false  
            block = "";
        }
        | DO D LEFT_CURLY M blocationk_item_listopt RIGHT_CURLY M WHILE LEFT_PARENTHESES expression RIGHT_PARENTHESES SEMI_COLON
        {
            /*
                This production rule has been augmented with non-terminals like D and M to handle the control flow, backpatching and detect the kind of loop
            */
            $$ = new statement();                   // Create a new statement  
            convert_int_bool($10);                  // Convert expression to bool
            backpatch($10->truelist, $4);           // Go back to M1 and blocationk_item_listopt if expression is true
            backpatch($5->nextlist, $7);            // Go to M2 to check expression after blocationk_item_listopt is complete
            $$->nextlist = $10->falselist;          // Exit loop if expression is false  
            block = "";
        }
        | FOR F LEFT_PARENTHESES X change_table declaration M expression_statement M expression N RIGHT_PARENTHESES M loop_statement
        {
            /*
                This production rule has been augmented with non-terminals like F, X, change_table and M to handle the control flow, 
                backpatching, detect the kind of loop, create a separate symbol table for the loop blocationk and give it an appropriate name
            */
            $$ = new statement();                   // Create a new statement
            convert_int_bool($8);                   // Convert expression to bool
            backpatch($8->truelist, $13);           // Go to M3 if expression is true
            backpatch($11->nextlist, $7);           // Go back to M1 after N
            backpatch($14->nextlist, $9);           // Go back to expression after loop_statement
            add_TAC("goto", convert_int_str($9));   // Emit to prevent fall-through
            $$->nextlist = $8->falselist;           // Exit loop if expression_statement is false
            block = "";
            move_to_table(curr_symb_table->parent);
        }
        | FOR F LEFT_PARENTHESES X change_table expression_statement M expression_statement M expression N RIGHT_PARENTHESES M loop_statement
        {
            /*
                This production rule has been augmented with non-terminals like F, X, change_table and M to handle the control flow, 
                backpatching, detect the kind of loop, create a separate symbol table for the loop blocationk and give it an appropriate name
            */
            $$ = new statement();                   // Create a new statement
            convert_int_bool($8);                   // Convert expression to bool
            backpatch($8->truelist, $13);           // Go to M3 if expression is true
            backpatch($11->nextlist, $7);           // Go back to M1 after N
            backpatch($14->nextlist, $9);           // Go back to expression after loop_statement
            add_TAC("goto", convert_int_str($9));   // Emit to prevent fall-through
            $$->nextlist = $8->falselist;           // Exit loop if expression_statement is false
            block = "";
            move_to_table(curr_symb_table->parent);
        }
        | FOR F LEFT_PARENTHESES X change_table declaration M expression_statement M expression N RIGHT_PARENTHESES M LEFT_CURLY blocationk_item_listopt RIGHT_CURLY
        {
            /*
                This production rule has been augmented with non-terminals like F, X, change_table and M to handle the control flow, 
                backpatching, detect the kind of loop, create a separate symbol table for the loop blocationk and give it an appropriate name
            */
            $$ = new statement();                   // Create a new statement
            convert_int_bool($8);                   // Convert expression to bool
            backpatch($8->truelist, $13);           // Go to M3 if expression is true
            backpatch($11->nextlist, $7);           // Go back to M1 after N
            backpatch($15->nextlist, $9);           // Go back to expression after loop_statement
            add_TAC("goto", convert_int_str($9));   // Emit to prevent fall-through
            $$->nextlist = $8->falselist;           // Exit loop if expression_statement is false
            block = "";
            move_to_table(curr_symb_table->parent);
        }
        | FOR F LEFT_PARENTHESES X change_table expression_statement M expression_statement M expression N RIGHT_PARENTHESES M LEFT_CURLY blocationk_item_listopt RIGHT_CURLY
        {
            /*
                This production rule has been augmented with non-terminals like F, X, change_table and M to handle the control flow, 
                backpatching, detect the kind of loop, create a separate symbol table for the loop blocationk and give it an appropriate name
            */
            $$ = new statement();                   // Create a new statement
            convert_int_bool($8);                   // Convert expression to bool
            backpatch($8->truelist, $13);           // Go to M3 if expression is true
            backpatch($11->nextlist, $7);           // Go back to M1 after N
            backpatch($15->nextlist, $9);           // Go back to expression after loop_statement
            add_TAC("goto", convert_int_str($9));   // Emit to prevent fall-through
            $$->nextlist = $8->falselist;           // Exit loop if expression_statement is false
            block = "";
            move_to_table(curr_symb_table->parent);
        }
        ;

F: %empty
        {   
            /*
            This non-terminal indicates the start of a for loop
            */
            block = "FOR";
        }
        ;

W: %empty
        {
            /*
            This non-terminal indicates the start of a while loop
            */
            block = "WHILE";
        }
        ;

D: %empty
        {
            /*
            This non-terminal indicates the start of a do-while loop
            */
            block = "DO_WHILE";
        }
        ;

X: %empty
        {   
            // Used for creating new nested symbol tables for nested blocationks
            string newST = curr_symb_table->name + "." + block + "$" + to_string(num_ST++);  // Generate name for new symbol table
            ST_entry* sym = curr_symb_table->search_lexeme(newST);
            sym->nested_symbol_table = new symbol_table(newST);  // Create new symbol table
            sym->name = newST;
            sym->nested_symbol_table->parent = curr_symb_table;
            sym->type = new ST_entry_type("blocationk");    // The type will be "blocationk"
            curr_symbol = sym;    // Change the current symbol pointer
        }
        ;

change_table: %empty
        {   
            // Used for changing the symbol table on encountering functions
            if(curr_symbol->nested_symbol_table != NULL) {
                // If the symbol table already exists, switch to that table
                move_to_table(curr_symbol->nested_symbol_table);
                add_TAC("label", curr_symb_table->name);
            }
            else {
                // If the symbol table does not exist already, create it and switch to it
                move_to_table(new symbol_table(""));
            }
        }
        ;

jump_statement: 
        GOTO IDENTIFIER SEMI_COLON
        { /* Ignored */ }
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
            add_TAC("return", $2->location->name);  // Emit return alongwith return value
        }
        | RETURN SEMI_COLON
        {
            $$ = new statement();
            add_TAC("return", "");             // Emit return without any return value
        }
        ;

translation_unit: 
        external_declaration
        { /* Ignored */ }
        | translation_unit external_declaration
        { /* Ignored */ }
        ;

external_declaration: 
        function_definition
        { /* Ignored */ }
        | declaration
        { /* Ignored */ }
        ;

function_definition: 
        declaration_specifiers declarator declaration_listopt change_table LEFT_CURLY blocationk_item_listopt RIGHT_CURLY
        {   
            curr_symb_table->parent = global_symb_table;
            num_ST = 0;
            move_to_table(global_symb_table);          // After reaching end of a function, change cureent symbol table to the global symbol table
        }
        ;

declaration_listopt: 
        declaration_list
        { /* Ignored */ }
        | %empty
        { /* Ignored */ }
        ;

declaration_list: 
        declaration
        { /* Ignored */ }
        | declaration_list declaration
        { /* Ignored */ }
        ;
               
%%

void yyerror(char* s) {
    cout << "Error occurred: " << s << endl;
    cout << "Line no.: " << lineno << endl;
    cout << "Unable to parse: " << yytext << endl;
}