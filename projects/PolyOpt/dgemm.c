#include <stdio.h>
#include <unistd.h>

#define N 512

double A[N][N];
double B[N][N];
double C[N][N];
double alpha = 1.345345;
double beta = 6.456546;


void init_array ()
{
    int i, j;

    for (i = 0; i < N; i++) {
        for (j = 0; j < N; j++) {
            A[i][j] = ((double) i*j)/N;
            B[i][j] = ((double) i*j)/N;
        }
    }
}


void print_array (char** argv)
{
    int i, j;
#ifndef TEST
    if (! strcmp (argv[0], ""))
#endif
      {
	for (i = 0; i < N; i++) {
	  for (j = 0; j < N; j++) {
	    fprintf(stderr, "%0.2lf ", C[i][j]);
	  }
	  if (i%80 == 20) fprintf(stderr, "\n");
	}
	fprintf(stderr, "\n");
      }
}


int
main (int argc, char** argv)
{
    int i, j, k;

    init_array ();

    for (i = 0; i < N; i++)
      for (j = 0; j < N; j++)
	{
	  C[i][j] *= beta;
	  for (k = 0; k < N; k++)
            C[i][j] += A[i][k] * B[k][j] * alpha;
	}

    print_array (argv);

    return 0;
}
