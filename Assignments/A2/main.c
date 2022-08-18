#include "myl.h"

char *nl = "\n";

void check_printStr(char *str){
    printStr("\""); 
    int returnValue = printStr(str); 
    printStr("\" -> number of printed characters = ");
    printInt(returnValue);
    printStr(nl);
}

void check_readInt(){
    int ntemp;
    int flag = 1;
    while(flag == 1){
        printStr("Enter an integer: ");
        int returnValue = readInt(&ntemp);
        if(returnValue == ERR) 
            printStr("Invalid input.");
        else{
            printStr("Read integer: ");
            printInt(ntemp);
        }
        printStr("\nTo test again enter 1 otherwise 0: ");
        readInt(&flag);
    }
}

void check_printInt(int integer){
        int returnValue = printInt(integer);
        printStr(" -> number of characters printed = ");
        printInt(returnValue);
        printStr(nl);
}

void check_readFlt(){
    float ftemp;
    int flag = 1;
    while(flag == 1){
        printStr("Enter a floating point number: ");
        int returnValue = readFlt(&ftemp);
        if(returnValue == ERR) 
            printStr("Invalid input.");
        else{
            printStr("Read float: ");
            printFlt(ftemp);
        }
        printStr("\nTo test again enter 1 otherwise 0: ");
        readInt(&flag);
    }
}

void check_printFlt(float floating_number){
    int returnValue = printFlt(floating_number);
    printStr(" -> number of characters printed = ");
    printInt(returnValue);
    printStr(nl);
}



int main(){

    printStr("*** Testing printStr ***\n");
    char *str[3] = {"Checking by printing a sample string.", "Now printing an empty string in the nextline", ""};
    for(int i=0; i<3; i++){
        check_printStr(str[i]);
    }
    printStr(nl);

    printStr("*** Testing readInt ***\n");
    check_readInt();
    printStr(nl);

    printStr("*** Testing printInt ***\n");
    int integer_array[6] = {17, -17, 198, -198, 17861, -17861};
    for(int i=0; i<6; i++){
        check_printInt(integer_array[i]);
    }
    printStr(nl);

    printStr("*** Testing readFlt ***\n");
    check_readFlt();
    printStr(nl);

    printStr("*** Testing printFlt ***\n");
    float float_array[7] = {-15.25, 15.25, -3, 3, 176.125, 0.003, -0.0102};
    for(int i=0; i<7; i++){
        check_printFlt(float_array[i]);
    }
    printStr(nl);

    return 0;
}

