#include <stdlib.h>
#include <assert.h>

#define __PACE_MAX_NB_TILE_SIZES 42
int* ___gl_pace_tile_sizes = NULL;


int* PACETileSizeVectorAlloc(int size)
{
  int* ret = (int*)malloc(sizeof(int) * size);
  assert(ret != NULL);
  int i;
  for (i = 0; i < __PACE_MAX_NB_TILE_SIZES; ++i)
    ret[i] = 32;

  return ret;
}


void PACETileSizeVectorInit(int* pace_tile_sizes, int nestedLoops, int scopId)
{
  for (int i = 0; i < nestedLoops; ++i)
    pace_tile_sizes[i] = 5;
}


void PACETileSizeVectorFree(int* tile_sizes)
{
  if (tile_sizes)
    free(tile_sizes);
}

