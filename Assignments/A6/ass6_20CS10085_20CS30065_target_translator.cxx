/**
* Pranav Mehrotra, 20CS10085
* Saransh Sharma, 20CS30065
* Compilers Laboratory
* Assignment 6
*
* File for Target Code Generation
*/

#include "ass6_20CS10085_20CS30065_translator.h"
#include <fstream>
#include <sstream>
#include <stack>
using namespace std;

// External variables
extern quad_TAC_arr TAC_list;
extern symbol_table* ST;
extern symbol_table ST_global;

// Declare global variables
string assembly_file;
int label_num = 0;
stack<pair<string, int>> params;
map<int, string> labels;
vector<string> f_strings;
string function_name = "";


// Prints the global information to the assembly file
void output_global_info(ofstream& sfile) {
    for(vector<ST_entry*>::iterator it = ST_global.list_ST_entry.begin(); it != ST_global.list_ST_entry.end(); it++) {
        ST_entry* sym = *it;
        // If object type is 'CHAR'
        if(sym->type.type == CHAR && sym->name[0] != 't') {
            // If initialised
            if(sym->initial_value != NULL) {
                sfile << "\t.globl\t" << sym->name << endl;
                sfile << "\t.data" << endl;
                sfile << "\t.type\t" << sym->name << ", @object" << endl;
                sfile << "\t.size\t" << sym->name << ", 1" << endl;
                sfile << sym->name << ":" << endl;
                sfile << "\t.byte\t" << sym->initial_value->c << endl;
            }
            else
                sfile << "\t.comm\t" << sym->name << ",1,1" << endl;
        }
        // If object type is 'INT'
        else if(sym->type.type == INT && sym->name[0] != 't') {
            // If initialised
            if(sym->initial_value != NULL) {
                sfile << "\t.globl\t" << sym->name << endl;
                sfile << "\t.data" << endl;
                sfile << "\t.align\t4" << endl;
                sfile << "\t.type\t" << sym->name << ", @object" << endl;
                sfile << "\t.size\t" << sym->name << ", 4" << endl;
                sfile << sym->name << ":" << endl;
                sfile << "\t.long\t" << sym->initial_value->i << endl;
            }
            else
                sfile << "\t.comm\t" << sym->name << ",4,4" << endl;
        }
    }
}

// Function to declare the strings in the assembly file 
void output_strings(ofstream& sfile) {
    // Declare the strings
    sfile << ".section\t.rodata" << endl;
    int i = 0;
    for(vector<string>::iterator it = f_strings.begin(); it != f_strings.end(); it++) {
        sfile << ".LC" << i++ << ":" << endl;       // String label
        sfile << "\t.string " << *it << endl;       // String value
    }
}

// Function to generate labels for different jump and branch statements of the code
void generate_labels() {
    int i = 0;
    for(vector<quad>::iterator it = TAC_list.TAC_quad_list.begin(); it != TAC_list.TAC_quad_list.end(); it++) {
        // If the quad is a goto statement
        if(it->op == GOTO || (it->op >= GOTO_EQ && it->op <= IF_FALSE_GOTO)) {
            // target label
            int target = atoi((it->result.c_str()));
            // If the label is not already present
            if(!labels.count(target)) {
                // Generate a new label
                string labelName = ".L" + to_string(label_num++);
                labels[target] = labelName;
            }
            // Assign the label to the quad
            it->result = labels[target];
        }
    }
}

// Function to generate the prologue for the functions
// It pushes the registers on the stack and allocates space for the local variables
void generate_prologue(int memory_bind, ofstream& sfile) {
    int width = 16;
    // Declare a function name
    sfile << endl << "\t.text" << endl;
    sfile << "\t.globl\t" << function_name << endl;
    sfile << "\t.type\t" << function_name << ", @function" << endl;
    sfile << function_name << ":" << endl;
    // Push the base pointer on the stack
    sfile << "\tpushq\t" << "%rbp" << endl;
    // Move the stack pointer to the base pointer
    sfile << "\tmovq\t" << "%rsp, %rbp" << endl;
    // Allocate space for the local variables
    sfile << "\tsubq\t$" << (memory_bind / width + 1) * width << ", %rsp" << endl;
}

// Function to generate assembly code for a given three address quad
void generate_assembly(quad q, ofstream& sfile) {
    string strLabel = q.result;
    // If the quad has a string label
    bool hasStrLabel = (q.result[0] == '.' && q.result[1] == 'L' && q.result[2] == 'C');
    string toPrint1 = "", toPrint2 = "", toPrintRes = "";
    int off1 = 0, off2 = 0, offRes = 0;

    // Search the symbol table for the quad's operands
    ST_entry* location1 = ST->search_lexeme(q.arg1);
    ST_entry* location2 = ST->search_lexeme(q.arg2);
    ST_entry* location3 = ST->search_lexeme(q.result);
    ST_entry* glb1 = ST_global.search_global_ST(q.arg1);
    ST_entry* glb2 = ST_global.search_global_ST(q.arg2);
    ST_entry* glb3 = ST_global.search_global_ST(q.result);

    // If the local symbol table is not the same as global symbol table
    if(ST != &ST_global) {
        if(glb1 == NULL)
            off1 = location1->offset;
        if(glb2 == NULL)
            off2 = location2->offset;
        if(glb3 == NULL)
            offRes = location3->offset;

        if(q.arg1[0] < '0' || q.arg1[0] > '9') {
            if(glb1 != NULL)
                toPrint1 = q.arg1 + "(%rip)";
            else
                toPrint1 = to_string(off1) + "(%rbp)";
        }
        if(q.arg2[0] < '0' || q.arg2[0] > '9') {
            if(glb2 != NULL)
                toPrint2 = q.arg2 + "(%rip)";
            else
                toPrint2 = to_string(off2) + "(%rbp)";
        }
        if(q.result[0] < '0' || q.result[0] > '9') {
            if(glb3 != NULL)
                toPrintRes = q.result + "(%rip)";
            else
                toPrintRes = to_string(offRes) + "(%rbp)";
        }
    }
    else {
        toPrint1 = q.arg1;
        toPrint2 = q.arg2;
        toPrintRes = q.result;
    }

    // If the quad has a string label
    if(hasStrLabel)
        toPrintRes = strLabel;

    // If quad operation is an assigment operation
    if(q.op == ASSIGN) {
        if(q.result[0] != 't' || location3->type.type == INT || location3->type.type == POINTER) {
            if(location3->type.type != POINTER) {
                if(q.arg1[0] < '0' || q.arg1[0] > '9')
                {
                    sfile << "\tmovl\t" << toPrint1 << ", %eax" << endl;
                    sfile << "\tmovl\t%eax, " << toPrintRes << endl; 
                }
                else
                    sfile << "\tmovl\t$" << q.arg1 << ", " << toPrintRes << endl;
            }
            else {
                sfile << "\tmovq\t" << toPrint1 << ", %rax" << endl;
                sfile << "\tmovq\t%rax, " << toPrintRes << endl; 
            }
        }
        else {
            int temp = q.arg1[0];
            sfile << "\tmovb\t$" << temp << ", " << toPrintRes << endl;
        }
    }

    // If quad operation is Unary Minus
    else if(q.op == U_MINUS) {
        sfile << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        sfile << "\tnegl\t%eax" << endl;
        sfile << "\tmovl\t%eax, " << toPrintRes << endl;
    }
    // If quad operation is addition
    else if(q.op == ADD) {
        if(q.arg1[0] > '0' && q.arg1[0] <= '9')
            sfile << "\tmovl\t$" << q.arg1 << ", %eax" << endl;
        else
            sfile << "\tmovl\t" << toPrint1 << ", %eax" << endl; 
        if(q.arg2[0] > '0' && q.arg2[0] <= '9')
            sfile << "\tmovl\t$" << q.arg2 << ", %edx" << endl;
        else
            sfile << "\tmovl\t" << toPrint2 << ", %edx" << endl; 
        sfile << "\taddl\t%edx, %eax" << endl;
        sfile << "\tmovl\t%eax, " << toPrintRes << endl;
    }
    // If quad operation is subtraction
    else if(q.op == SUB) {
        if(q.arg1[0] > '0' && q.arg1[0] <= '9')
            sfile << "\tmovl\t$" << q.arg1 << ", %edx" << endl;
        else
            sfile << "\tmovl\t" << toPrint1 << ", %edx" << endl; 
        if(q.arg2[0]>'0' && q.arg2[0]<='9')
            sfile << "\tmovl\t$" << q.arg2 << ", %eax" << endl;
        else
            sfile << "\tmovl\t" << toPrint2 << ", %eax" << endl; 
        sfile << "\tsubl\t%eax, %edx" << endl;
        sfile << "\tmovl\t%edx, %eax" << endl;
        sfile << "\tmovl\t%eax, " << toPrintRes << endl;
    }
    // If quad operation is multiplication
    else if(q.op == MULT) {
        if(q.arg1[0] > '0' && q.arg1[0] <= '9')
            sfile << "\tmovl\t$" << q.arg1 << ", %eax" << endl;
        else
            sfile << "\tmovl\t" << toPrint1 << ", %eax" << endl; 
        sfile << "\timull\t";
        if(q.arg2[0] > '0' && q.arg2[0] <= '9')
            sfile << "$" << q.arg2 << ", %eax" << endl;
        else
            sfile << toPrint2 << ", %eax" << endl;
        sfile << "\tmovl\t%eax, " << toPrintRes << endl;
    }
    // If quad operation is division
    else if(q.op == DIV) {
        sfile << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        sfile << "\tcltd\n\tidivl\t" << toPrint2 << endl;
        sfile << "\tmovl\t%eax, " << toPrintRes << endl;
    }
    // If quad operation is modulo
    else if(q.op == MOD) {
        sfile << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        sfile << "\tcltd\n\tidivl\t" << toPrint2 << endl;
        sfile << "\tmovl\t%edx, " << toPrintRes << endl;
    }

    // If quad operation are Goto statements
    else if(q.op == GOTO)
        sfile << "\tjmp\t" << q.result << endl;
    else if(q.op == GOTO_LT) {
        sfile << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        sfile << "\tcmpl\t" << toPrint2 << ", %eax" << endl;
        sfile << "\tjge\t.L" << label_num << endl;
        sfile << "\tjmp\t" << q.result << endl;
        sfile << ".L" << label_num++ << ":" << endl;
    }
    else if(q.op == GOTO_GT) {
        sfile << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        sfile << "\tcmpl\t" << toPrint2 << ", %eax" << endl;
        sfile << "\tjle\t.L" << label_num << endl;
        sfile << "\tjmp\t" << q.result << endl;
        sfile << ".L" << label_num++ << ":" << endl;
    }
    else if(q.op == GOTO_GTE) {
        sfile << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        sfile << "\tcmpl\t" << toPrint2 << ", %eax" << endl;
        sfile << "\tjl\t.L" << label_num << endl;
        sfile << "\tjmp\t" << q.result << endl;
        sfile << ".L" << label_num++ << ":" << endl;
    }
    else if(q.op == GOTO_LTE) {
        sfile << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        sfile << "\tcmpl\t" << toPrint2 << ", %eax" << endl;
        sfile << "\tjg\t.L" << label_num << endl;
        sfile << "\tjmp\t" << q.result << endl;
        sfile << ".L" << label_num++ << ":" << endl;
    }
    else if(q.op == GOTO_GTE) {
        sfile << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        sfile << "\tcmpl\t" << toPrint2 << ", %eax" << endl;
        sfile << "\tjl\t.L" << label_num << endl;
        sfile << "\tjmp\t" << q.result << endl;
        sfile << ".L" << label_num++ << ":" << endl;
    }
    else if(q.op == GOTO_EQ) {
        sfile << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        if(q.arg2[0] >= '0' && q.arg2[0] <= '9')
            sfile << "\tcmpl\t$" << q.arg2 << ", %eax" << endl;
        else
            sfile << "\tcmpl\t" << toPrint2 << ", %eax" << endl;
        sfile << "\tjne\t.L" << label_num << endl;
        sfile << "\tjmp\t" << q.result << endl;
        sfile << ".L" << label_num++ << ":" << endl;
    }
    else if(q.op == GOTO_NEQ) {
        sfile << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        sfile << "\tcmpl\t" << toPrint2 << ", %eax" << endl;
        sfile << "\tje\t.L" << label_num << endl;
        sfile << "\tjmp\t" << q.result << endl;
        sfile << ".L" << label_num++ << ":" << endl;
    }
    else if(q.op == IF_GOTO) {
        sfile << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        sfile << "\tcmpl\t$0" << ", %eax" << endl;
        sfile << "\tje\t.L" << label_num << endl;
        sfile << "\tjmp\t" << q.result << endl;
        sfile << ".L" << label_num++ << ":" << endl;
    }
    else if(q.op == IF_FALSE_GOTO) {
        sfile << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        sfile << "\tcmpl\t$0" << ", %eax" << endl;
        sfile << "\tjne\t.L" << label_num << endl;
        sfile << "\tjmp\t" << q.result << endl;
        sfile << ".L" << label_num++ << ":" << endl;
    }
    else if(q.op == ARR_R) {
        sfile << "\tmovl\t" << toPrint2 << ", %edx" << endl;
        sfile << "cltq" << endl;
        if(off1 < 0) {
            sfile << "\tmovl\t" << off1 << "(%rbp,%rdx,1), %eax" << endl;
            sfile << "\tmovl\t%eax, " << toPrintRes << endl;
        }
        else {
            sfile << "\tmovq\t" << off1 << "(%rbp), %rdi" << endl;
            sfile << "\taddq\t%rdi, %rdx" << endl;
            sfile << "\tmovq\t(%rdx) ,%rax" << endl;
            sfile << "\tmovq\t%rax, " << toPrintRes << endl;
        }
    }
    else if(q.op == ARR_L) {
        sfile << "\tmovl\t" << toPrint2 << ", %edx" << endl;
        sfile << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        sfile << "cltq" << endl;
        if(offRes > 0) {
            sfile << "\tmovq\t" << offRes << "(%rbp), %rdi" << endl;
            sfile << "\taddq\t%rdi, %rdx" << endl;
            sfile << "\tmovl\t%eax, (%rdx)" << endl;
        }
        else
            sfile << "\tmovl\t%eax, " << offRes << "(%rbp,%rdx,1)" << endl;
    }
    else if(q.op == REFERENCE) {
        if(off1 < 0) {
            sfile << "\tleaq\t" << toPrint1 << ", %rax" << endl;
            sfile << "\tmovq\t%rax, " << toPrintRes << endl;
        }
        else {
            sfile << "\tmovq\t" << toPrint1 << ", %rax" << endl;
            sfile << "\tmovq\t%rax, " << toPrintRes << endl;
        }
    }
    else if(q.op == DEREFERENCE) {
        sfile << "\tmovq\t" << toPrint1 << ", %rax" << endl;
        sfile << "\tmovq\t(%rax), %rdx" << endl;
        sfile << "\tmovq\t%rdx, " << toPrintRes << endl;
    }
    else if(q.op == L_DEREF) {
        sfile << "\tmovq\t" << toPrintRes << ", %rdx" << endl;
        sfile << "\tmovl\t" << toPrint1 << ", %eax" << endl;
        sfile << "\tmovl\t%eax, (%rdx)" << endl;
    }
    // If quad is a parameter
    else if(q.op == PARAM) {
        int paramSize;
        data_dtype t;
        if(glb3 != NULL)
            t = glb3->type.type;
        else
            t = location3->type.type;
        if(t == INT)
            paramSize = 4;
        else if(t == CHAR)
            paramSize = 1;
        else
            paramSize = 8;
        stringstream ss;
        if(q.result[0] == '.')
            ss << "\tmovq\t$" << toPrintRes << ", %rax" <<endl;
        else if(q.result[0] >= '0' && q.result[0] <= '9')
            ss << "\tmovq\t$" << q.result << ", %rax" <<endl;
        else {
            if(location3->type.type != ARRAY) {
                if(location3->type.type != POINTER)
                    ss << "\tmovq\t" << toPrintRes << ", %rax" <<endl;
                else if(location3 == NULL)
                    ss << "\tleaq\t" << toPrintRes << ", %rax" <<endl;
                else
                    ss << "\tmovq\t" << toPrintRes << ", %rax" <<endl;
            }
            else {
                if(offRes < 0)
                    ss << "\tleaq\t" << toPrintRes << ", %rax" <<endl;
                else {
                    ss << "\tmovq\t" << offRes << "(%rbp), %rdi" <<endl;
                    ss << "\tmovq\t%rdi, %rax" <<endl;
                }
            }
        }
        params.push(make_pair(ss.str(), paramSize));
    }
    // If quad is making a call to another function
    else if(q.op == CALL) {
        int numParams = atoi(q.arg1.c_str());
        int totalSize = 0, k = 0;

        // If number of parameters is more than 6
        if(numParams > 6) {
            for(int i = 0; i < numParams - 6; i++) {
                string s = params.top().first;
                sfile << s << "\tpushq\t%rax" << endl;
                totalSize += params.top().second;
                params.pop();
            }
            sfile << params.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %r9d" << endl;
            totalSize += params.top().second;
            params.pop();
            sfile << params.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %r8d" << endl;
            totalSize += params.top().second;				
            params.pop();
            sfile << params.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rcx" << endl;
            totalSize += params.top().second;
            params.pop();
            sfile << params.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rdx" << endl;
            totalSize += params.top().second;
            params.pop();
            sfile << params.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rsi" << endl;
            totalSize += params.top().second;
            params.pop();
            sfile << params.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rdi" << endl;
            totalSize += params.top().second;
            params.pop();
        }
        // Else if number of parameters less than or eual to 6
        else {
            while(!params.empty()) {
                if(params.size() == 6) {
                    sfile << params.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %r9d" << endl;
                    totalSize += params.top().second;
                    params.pop();
                }
                else if(params.size() == 5) {
                    sfile << params.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %r8d" << endl;
                    totalSize += params.top().second;
                    params.pop();
                }
                else if(params.size() == 4) {
                    sfile << params.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rcx" << endl;
                    totalSize += params.top().second;
                    params.pop();
                }
                else if(params.size() == 3) {
                    sfile << params.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rdx" << endl;
                    totalSize += params.top().second;
                    params.pop();
                }
                else if(params.size() == 2) {
                    sfile << params.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rsi" << endl;
                    totalSize += params.top().second;
                    params.pop();
                }
                else if(params.size() == 1) {
                    sfile << params.top().first << "\tpushq\t%rax" << endl << "\tmovq\t%rax, %rdi" << endl;
                    totalSize += params.top().second;
                    params.pop();
                }
            }
        }
        sfile << "\tcall\t" << q.result << endl;
        if(q.arg2 != "")
            sfile << "\tmovq\t%rax, " << toPrint2 << endl;
        sfile << "\taddq\t$" << totalSize << ", %rsp" << endl;
    }

    // If quad is returning from a function
    else if(q.op == RETURN) {
        if(q.result != "")
            sfile << "\tmovq\t" << toPrintRes << ", %rax" << endl;
        sfile << "\tleave" << endl;
        sfile << "\tret" << endl;
    }

}

// Function to generate target assembly code for the given TAC file
void generate_target(ofstream& sfile) {
    output_global_info(sfile);
    output_strings(sfile);
    symbol_table* curr_function_table = NULL;
    ST_entry* curr_function = NULL;
    generate_labels();

    for(int i = 0; i < (int)TAC_list.TAC_quad_list.size(); i++) {
        // Print the TAC as comment in the file
        sfile << "# " << TAC_list.TAC_quad_list[i].print_TAC() << endl;
        if(labels.count(i))
            sfile << labels[i] << ":" << endl;

        // Function definition and required actions
        if(TAC_list.TAC_quad_list[i].op == FUNC_BEG) {
            i++;
            if(TAC_list.TAC_quad_list[i].op != FUNC_END)
                i--;
            else
                continue;
            curr_function = ST_global.search_global_ST(TAC_list.TAC_quad_list[i].result);
            curr_function_table = curr_function->nested_symbol_table;
            ST = curr_function_table;
            int has_param = 1, memory_bind = 16;
            for(int j = 0; j < (int)curr_function_table->list_ST_entry.size(); j++) {
                if(curr_function_table->list_ST_entry[j]->name == "RETVAL") {
                    has_param = 0;
                    memory_bind = 0;
                    if(curr_function_table->list_ST_entry.size() > j + 1)
                        memory_bind = -curr_function_table->list_ST_entry[j + 1]->size;
                }
                else {
                    if(!has_param) {
                        curr_function_table->list_ST_entry[j]->offset = memory_bind;
                        if(curr_function_table->list_ST_entry.size() > j + 1)
                            memory_bind -= curr_function_table->list_ST_entry[j + 1]->size;
                    }
                    else {
                        curr_function_table->list_ST_entry[j]->offset = memory_bind;
                        memory_bind += 8;
                    }
                }
            }
            if(memory_bind >= 0)
                memory_bind = 0;
            else
                memory_bind *= -1;
            function_name = TAC_list.TAC_quad_list[i].result;
            generate_prologue(memory_bind, sfile);
        }

        // Function which is called when returning from a function
        else if(TAC_list.TAC_quad_list[i].op == FUNC_END) {
            ST = &ST_global;
            function_name = "";
            sfile << "\tleave" << endl;
            sfile << "\tret" << endl;
            sfile << "\t.size\t" << TAC_list.TAC_quad_list[i].result << ", .-" << TAC_list.TAC_quad_list[i].result << endl;
        }

        if(function_name != "")
            generate_assembly(TAC_list.TAC_quad_list[i], sfile);
    }
}

// Main function
int main(int argc, char* argv[]) {
    ST = &ST_global;
    yyparse();

    assembly_file = "ass6_20CS10085_20CS30065_" + string(argv[argc - 1]) + ".s";
    ofstream sfile;
    sfile.open(assembly_file);

    TAC_list.print_TAC();               // Print the three address TAC_quad_list

    ST->print_ST("ST.global");         // Print the ST_entry tables

    ST = &ST_global;

    generate_target(sfile);      // Function to generate the target assembly code

    sfile.close();

    return 0;
}
