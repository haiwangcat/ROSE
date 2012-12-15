#include "omp.h"


int foo(int a, int b)
{   
	int c; 
	c = a + b;
	return  c;
 }
int main()
{

  int a;
  int b;
   int c;
    int pp;
	int q;
	omp_lock_t locka;
	omp_init_lock( &locka);
 #pragma omp parallel private(a,b) shared(pp)
	{
//#pragma omp for private(q)
		for( int y = 0; y < 10 ; y++)
		{q++;}
		q =q + 1;
	omp_set_lock(&locka);	   
      a = a + 1; 
	  omp_unset_lock(&locka);      
    #pragma omp critical

    c = c + 1;
 }

#pragma omp parallel shared(a,c)
	{
		a = a + 1;	
	}
 return 0;


}


