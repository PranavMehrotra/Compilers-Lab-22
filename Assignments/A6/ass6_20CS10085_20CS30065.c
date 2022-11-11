/**
* Pranav Mehrotra, 20CS10085
* Saransh Sharma, 20CS30065
* Compilers Laboratory
* Assignment 6
*
*file taken from assignment-2
*/

#include "myl.h"
#define BUFF_SIZE 100
#define INT_MAX __INT32_MAX__                       //max integer value
#define INT_MIN (-INT_MAX - 1)                      //min integer value

int printStr(char *str)
{
    int len = 0;                //intialise len variable to store length of string
    while(str[len] != '\0')     //increment len until str[len]=='\0'
        len++;

    __asm__ __volatile__ (          //codes fro printing string
        "movl $1, %%eax \n\t"       //eax <-- 1 (write) parameters to write
        "movq $1, %%rdi \n\t"       //rdi <-- 1 (stdout)
        "syscall \n\t"              //software interrupt
        :
        :"S"(str), "d"(len)         //pass the starting address of string and the length of the string to be printed
    );
    return len;                     //return the length of the string
}


int readInt(int *eP)
{

    char buff[BUFF_SIZE];                   //create an array to store input from stdin
    int len, i = 0, sign = 0;
    long int num = 0;                       //n is stored in a variable of type long ( this is done so that INT_MIN doesn't overflow when we take mod of it i.e. -n would become out of range if we deal with int data types)
    int n;

    __asm__ __volatile__ (
        "movl $0, %%eax \n\t"               //eax <-- 0 (call read) 
        "movq $0, %%rdi \n\t"               //rdi <-- 0 read from stdin
        "syscall \n\t"                      //system interrupt
        :"=a"(len)                          //to store length of input string (return value of read)
        :"S"(buff), "d"(BUFF_SIZE)          //the input string will be stored in str of size BUFF
    );

    if(len <= 0) {                          //if length is non-positive i.e. error incurred
        *eP = ERR;
        return 0;
    }

    //check if the first character is valid
    if((buff[0] != '+') && (buff[0] != '-') && (buff[0] < '0' || buff[0] > '9')) 
    {    
        *eP = ERR;
        return 0;
    }

    //extract the sign from first digit
    if(buff[0] == '-' || buff[0] == '+') {      
        if(buff[0] == '-')
            sign = 1;
        i++;
        //check if the next digit after sign is invalid
        if(buff[i] < '0' || buff[i] > '9') 
        {
            *eP = ERR;
            return 0;
        }
    }

    // until end of input is reached
    while(buff[i] != ' ' && buff[i] != '\n' && buff[i] != '\t') {
        if(buff[i] < '0' || buff[i] > '9') 
        {   //check for invalid digits    
            *eP = ERR;
            return 0;
        }
        int digit = buff[i] - '0'; //extract the character and convert to digit

        // check if the number obtained from stdin is out of range
        if(!sign && 1L * num * 10 + digit > INT_MAX) {
            *eP = ERR;
            return 0;
        }
        else if(sign && 1L * num * 10 + digit > INT_MIN) {
            *eP = ERR;
            return 0;
        }
        
        num = num * 10 + digit;             //keep on extracting the digits and multiply them with appropriate powers of 10
        i++;                                //keep on iterating
    }

    if(sign)      //if sign is 1 multiply the number by -1
        num *= -1;
    n = (int)num; //store num in n
    *eP = OK;     //indicate no error
    return n;       //return the num
}


int printInt(int n)
{   
    char buff[BUFF_SIZE];   //intialise the character array to store numbers in the form of strings
    int i = 0, j, k;
    int sign = (n < 0 ? -1 : 1);//extract the sign
    if(n == 0)
        buff[i++] = '0';        // n = 0 
    else {
        if(n < 0)               //if n is negative
            buff[i++] = '-';    //store -1 in first digit

        while(n) {
            buff[i++] = '0' + ((n % 10) * sign);    //extract ones digit and multiply by sign and keep on storing them
            n /= 10;
        }

        j = (buff[0] == '-' ? 1 : 0);//if the first bit is sign iterate from next bit
        k = i - 1;
        for(; j < k; j++, k--) {//reverse the array
            char temp = buff[j];
            buff[j] = buff[k];
            buff[k] = temp;
        }
    }
    int size = i;//store the size of the string representation of number 

    __asm__ __volatile__ (
        "movl $1, %%eax \n\t"   //eax <-- 1 (write) parameters to write
        "movq $1, %%rdi \n\t"   //rdi <-- 1 stdout
        "syscall \n\t"          //system interrupt
        :
        :"S"(buff), "d"(size)   //pass the string to be printed and len of the string
    );
    return size;                //return the length of the string printed
}
