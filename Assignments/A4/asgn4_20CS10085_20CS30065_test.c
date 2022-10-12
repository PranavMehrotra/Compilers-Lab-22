/*
    Pranav Mehrotra - 20CS10085
    Saransh Sharma - 20CS30065
    //
    //
    *
    *
*/

int function1(int , volatile int );
inline float function2(char *, int );
extern void func3(int *restrict q);

signed main(){
    int a,b=-1,c=10;
    int **t = (int){b,c,21,-32};
    a = b+c;
    a<<=1;
    a>>=1;
    a%=c;
    a*=21;
    a/=2;
    a-=b;
    a&=a;
    a|=a;
    a^=a;
    a = (b<c)?1:-1;

    restart:

    a = a+ b*c+ c*c + c%a - b;
    char e1[] = "Hello!", e2 = 'p';
    e1[1] = 'a';

    unsigned long p1 = 21212324434;
    double p2 = 3.77e+3;
    float p3 = 7.794;
    short p4 = 213;
    _Bool p5 = !0;
    _Complex p6;

    c = (int) p3;
    b = *(&p4);
    a = sizeof(b);

    for(int i=0;i<10;i++);
    for(int i=0;;);
    for(;;);
    int i=0;
    while(i<10){
        ++i;
        if(a>=10)   break;
    }
    i=5;
    do{
        i++;
        continue;
    }while(i<10);

    if(a<10)    goto restart;
    else if(a<5){
        switch (b)
        {
        case 0:
            c=10;
            break;
        
        default:
            c=5;
            break;
        }
    }
    else{
        enum e1;
        enum e2 { P1, P2 };
        enum { P3 = 0,  P4 } e3;
        function1(a,b);
        function2(e1,c);
    }

    return 0;
}



inline float function2(char *a, int n){
    auto x = n;
    const int q1 = 10;
    static double q2 = 1.1;
    register short c1;
    return 1.1;
}
