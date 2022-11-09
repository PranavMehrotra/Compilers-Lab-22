//mixed code
float add(float a, float b)
{
    return a+b;
}

int main(void)
{
    int i,j;
    int sum=0;
    for(i=0;i<10;++i)
    {
        for(j=0;j<10;++j)
        {
            sum = add(sum,i*j);
        }
    }
    j = 10;
}