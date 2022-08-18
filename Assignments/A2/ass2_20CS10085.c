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
    if(a==0)    str[i++]='0';
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
    str[i]='\n';
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

int readFlt(float *f){
    char str[BUFFER],zero='0';
    int i,k,digits;
     __asm__ __volatile__ (
        "movl $0, %%eax \n\t" 
        "movq $0, %%rdi \n\t"
        "syscall \n\t"
        : "=a"(digits)
        :"S"(str), "d"(BUFFER));
    if(digits<0)    return ERR;
    int sign=1;
    i=0;
    float num=0,frac=0.0,mul_fac=0.1,esign=1,emultiplier=0;
    long long integral=0;
    if(digits==0){
        *f = num;
        return OK;
    }
    if(str[i] == '-') {
        sign = -1;
        i++;
    } 
    else if(str[i] == '+') {
        i++;
    }
    while(i<digits && str[i]!='\n' && str[i]!='.' && str[i]!='E' && str[i]!='e'){
        if(str[i] < '0' || str[i] > '9')
            return ERR;
        integral*=10;
        integral+=(str[i]-zero);
        i++;
    }
    num+=integral;
    if(i<digits && str[i]=='.'){
        i++;
        while(i<digits && str[i]!='\n' && str[i]!='E' && str[i]!='e'){
            if(str[i] < '0' || str[i] > '9')
                return ERR;
            frac += ((str[i]-zero)*mul_fac);
            mul_fac/=10;
            i++;
        }
    }
    num+=frac;
    if(i<digits && (str[i]=='E' || str[i]=='e')){
        i++;
        if(i < digits) {
            if(str[i] == '-') {
                esign = -1;
                i++;
            } else if(str[i] == '+') {
                i++;
            }
        }
        while(i<digits && str[i]!='\n'){
            if(str[i] < '0' || str[i] > '9')
                return ERR;
            emultiplier*=10;
            emultiplier+=(str[i]-zero);
            i++;
        }
    }
    for(k=0;k<emultiplier;k++){
        if(esign==1){
            num*=10;
        }
        else{
            num/=10;
        }
    }
    *f = (num*sign);
    return OK;
}

int printFlt(float f){
    char str[BUFFER],zero='0';
    int i=0,j,k,digits;
    float frac=f;
    long long integral = (long long)f;
    frac -= integral;
    if(f<0){
        str[i++]='-';
        integral=-integral;
        frac=-frac;
    }
    if(integral==0){
        str[i++] = '0';
    }
    while(integral){
        int dig= integral%10;
        str[i++] = zero+dig;
        integral/=10;
    }
    if(str[0]=='-')j=1;
    else    j=0;
    k = i-1;
    while(j<k){
        char temp = str[j];
        str[j++] = str[k];
        str[k--] = temp;
    }
    str[i++]='.';
    if(frac==0) str[i++]=zero;
    else{
        for(int p=0;p<PRECISION;p++){
            frac*=10;
        }
    }
    int temp = frac;
    j=i;
    for(int p=0;p<PRECISION;p++){
        int dig = temp%10;
        str[i++] = zero+dig;
        temp/=10;
    }
    k=i-1;
    while(j<k){
        char tem = str[j];
        str[j++] = str[k];
        str[k--] = tem;
    }
    k=i-1;
    while(str[k]=='0'){
        i--;
        k--;
    }
    k=i-1;
    if(str[k]=='.'){
        str[i]='0';
        i++;
    }
    str[i]='\n';
    digits = i+1;
    __asm__ __volatile__(
        "movl $1, %%eax \n\t"
        "movq $1, %%rdi \n\t"
        "syscall \n\t"
        :
        : "S"(str), "d"(digits));
    return digits-1;
}
