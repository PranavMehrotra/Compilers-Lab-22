// function call and loops

int max_array(int a[10])
{
    int max=a[0],i=0;
    while(i<10)
    {
        if(a[i] >= max)
        max = a[i];
        i = i+1;
    }
    return max;
}

int max(int x, int y) {
    int max;
    
    if(x < 0 || y < 0 )
        max = -1;
    else if (x > y)                      
        max = x;
    else
        max = y;
        
    return max;
}
