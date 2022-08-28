#include <iostream>
#include <cmath>
#include <cstdio>
#include <string.h>
#include <stdlib.h>

using namespace std;
typedef struct
{
  int *Arr;
  int queue_size, start_id, end_id;
}QUEUE;//queue structure defined

void init(QUEUE *qP,int size)
{
  qP->Arr = (int *)malloc(size * sizeof(int));
  qP->start_id=0;
  qP->end_id=0;//queue initialised
  qP->queue_size=size;
}
int isempty(QUEUE qP)//to check if the queue is empty
{
  if (qP.start_id == qP.end_id) return 1;
  return 0;
}
void enqueue(QUEUE *qP, int data)
{
  qP->end_id=(((qP->end_id)+1));
  qP->Arr[qP->end_id] = data; //to add a data
}
int dequeue(QUEUE *qP)
{
  int a = qP->Arr[(qP->start_id)+1];
  qP->start_id =(((qP->start_id)+1));//to delete an element
  return a;
}
void display_queue(QUEUE *qP)
{
    int i;
    for(i=qP->start_id+1;i<=(qP->end_id);++i)
    printf("%d,",qP->Arr[i]);//print the elements of the queue
}
int bfs(QUEUE *q,int *indegree,int n,int ** adj, int* topo_order)//bfs
{
  int i,k=0;
  for(i=0;i<n;++i)topo_order[i]=0;//initialising topo_order
  for(i=0;i<n;++i)
  {
     if(indegree[i]==0)//if indegree 0
     {
       enqueue(q,i);//enqueue
       indegree[i]=-1;//mark the indegree -1 so that it is not travelled again
     }
  }
  while (!isempty(*q))//if the queue is not empty
  {
     int currentVertex = dequeue(q);//dequeue the queue
     topo_order[k]=currentVertex;//add the element in the topological order array
     k++;
     for(i=0;i<n;++i)
     {
        if(adj[currentVertex][i]==1)//if an edge exist
        {
            indegree[i]=indegree[i]-1;//decrease the indegree
        }
     }
     for(i=0;i<n;++i)
     {
        if(indegree[i]==0)
        {
          enqueue(q,i);     //enqueu all nodes with indegree 0
          indegree[i]=-1;//mark the indegree -1 so that it is not travelled again
        }
     }
  }
  if(k!=n)//if all nodes not vsisited once
  {
      return 0;//cycle exists
  }
  else return 1;//no cycle exists if each node travelled only once
}
void indeg( int *indegree, int ** adj, int n)
{
  int i,j;
  for(j=0;j<n;++j)
  {
      indegree[j]=0;//initialise indegree array
  }
  for(i=0;i<n;++i)
  {
      for(j=0;j<n;++j)
      {
          if(adj[i][j]==1)
          indegree[j]++;//indegree array updated
      }
  }
}
int main(void)
{
  QUEUE q,qp;
  int n,m,i,j,l,k,num=0;
  cin>>n;//number of players
  cin>>m;//number of nodes

  int **adj;//adjacency matrix defined of size n*n
  adj = (int **)malloc(n * sizeof(int *));
  for(int i=0; i<n; i++)adj[i] = (int *)malloc(n * sizeof(int));
  int * topo_order=(int *)malloc(n * sizeof(int));//topological order array defined
  int *indegree=(int *)malloc(n* sizeof(int));

  for(i=0;i<n;++i)//adjacency matrix initialised
  {
    for(j=0;j<n;++j)
    {
      adj[i][j]=0;
    }
  }

  for(int i=0;i<m;i++)//scanning the matches and updating adjacency matrix
  {
      scanf("%d %d",&l,&k);
      adj[l][k]++;
  }

  indeg(indegree,adj,n);

  init(&q,n);
}