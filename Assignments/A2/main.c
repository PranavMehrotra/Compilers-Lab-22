#include "myl.h"

#define INT_MAX __INT32_MAX__
#define INT_MIN (-INT_MAX - 1)

int main(){

    printStr("*** Testing printStr ***\n");
    char *str[3] = {"Checking by printing a sample string.", "Now printing an empty string in the nextline", ""};
    char *nl = "\n";
    for(int i=0; i<3; i++){
        printStr("\""); 
        int returnValue = printStr(str[i]); 
        printStr("\" -> number of printed characters = ");
        printInt(returnValue);
        printStr(nl);
    }
    printStr(nl);

    printStr("*** Testing printInt ***\n");
    int ints[11] = {0, 7, -7, 17, -17, 198, -198, 17861, -17861, INT_MAX, INT_MIN};
    for(int i=0; i<11; i++){
        int returnValue = printInt(ints[i]);
        printStr(" -> number of digits printed = ");
        printInt(returnValue);
        printStr(nl);
    }
    printStr(nl);

    printStr("*** Testing printFlt ***\n");
    float floats[10] = {0, -15.25, 15.25, -3, 3, 0.1093, -0.1093, 176.125, 0.003, -0.0102};
    for(int i=0; i<10; i++){
        int returnValue = printFlt(floats[i]);
        printStr(" -> number of digits printed = ");
        printInt(returnValue);
        printStr(nl);
    }
    printStr(nl);

    printStr("*** Testing readInt ***\n");
    int ntemp;
    int flag = 1;
    while(flag == 1){
        printStr("Enter an integer: ");
        int returnValue = readInt(&ntemp);
        if(returnValue == ERR) 
            printStr("Invalid input. ");
        else{
            printStr("Read integer: ");
            printInt(ntemp);
        }
        printStr("\nTo test again enter 1 otherwise 0: ");
        readInt(&flag);
    }
    printStr(nl);

    printStr("*** Testing readFlt ***\n");
    float ftemp;
    flag = 1;
    while(flag == 1){
        printStr("Enter a floating point number: ");
        int returnValue = readFlt(&ftemp);
        if(returnValue == ERR) 
            printStr("Invalid input. ");
        else{
            printStr("Read float: ");
            printFlt(ftemp);
        }
        printStr("\nTo test again enter 1 otherwise 0: ");
        readInt(&flag);
    }
    printStr(nl);

    return 0;
}

