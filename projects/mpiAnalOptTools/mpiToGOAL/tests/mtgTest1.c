#include <mpi.h>

// gather pattern

int main(int argc, char* argv[])
{
    MPI_Init(&argc, &argv);
    int rank, size, datasize = 8;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    char *send_buff, *recv_buff;

    send_buff = (char*) malloc(sizeof(char) * datasize);
    recv_buff = (char*) malloc(sizeof(char) * size * datasize);

    int i;
    MPI_Status status;
    #pragma goal region start
    if(!rank) {
        #pragma goal region dynamic
        for(i = 0; i < size; i++) {
            MPI_Recv((void*)recv_buff[i], datasize, MPI_CHAR, i, 0, MPI_COMM_WORLD, &status);
        }
    }
    else {
        MPI_Send(send_buff, datasize, MPI_CHAR, 0, 0, MPI_COMM_WORLD);
    }
    #pragma goal region end

    return 0;
}
