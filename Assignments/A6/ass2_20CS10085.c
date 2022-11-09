#include "myl.h"

#define BUFFER 21
#define PRECISION 7
#define INT_MAX 0x7fffffff
#define INT_MIN (-INT_MAX - 1)

int printStr(char *s){
    int i,len;
    for(i=0;s[i]!='\0';i++);
    len=i;
    __asm__ __volatile__(
        "movl $1, %%eax \n\t"
        "movq $1, %%rdi \n\t"
        "syscall \n\t"
        :
        : "S"(s), "d"(len));
    return len;
}

int printInt(int a){
    char str[BUFFER],zero='0';
    int i,j,k,digits,flag=0;
    i=0;
    if(a==0) str[i++]='0';
    else{
        if(a<0){
            if(a==INT_MIN){
                flag=1;
                a++;
            }
            str[i++]='-';
            a=-a;
        }
        while(a){
            int dig= a%10;
            str[i++] = zero+dig;
            a/=10;
        }
        if(str[0]=='-')j=1;
        else    j=0;
        k = i-1;
        while(j<k){
            char temp = str[j];
            str[j++] = str[k];
            str[k--] = temp;
        }
    }
    //For INT_MIN = -2147483648
    if(flag){
        str[i-1] = '8';
    }
    str[i]='\0';
    digits = i+1;
    __asm__ __volatile__(
        "movl $1, %%eax \n\t"
        "movq $1, %%rdi \n\t"
        "syscall \n\t"
        :
        : "S"(str), "d"(digits));
    return digits-1;
}

int readInt(int *n){
    char str[BUFFER],zero='0';
    int i,j,k,digits;
     __asm__ __volatile__ (
        "movl $0, %%eax \n\t" 
        "movq $0, %%rdi \n\t"
        "syscall \n\t"
        : "=a"(digits)
        :"S"(str), "d"(BUFFER));
    if(digits<0)    return ERR;
    int sign=1;
    i=0;
    long long num=0;
    if(digits==0){
        *n = num;
        return OK;
    }
    if(str[i] == '-') {
        sign = -1;
        i++;
    } 
    else if(str[i] == '+') {
        i++;
    }
    while(i<digits && str[i]!='\n'){
        if(str[i] < '0' || str[i] > '9')
            return ERR;
        num*=10;
        num+= (int)(str[i]-zero);
        if(num > 1LL*INT_MAX + 1)
            return ERR;
        i++;
    }
    if(sign==1 && num>INT_MAX)  return ERR;
    num*=sign;
    *n = (int)num;
    return OK;

}
