#include <iostream>
#include <mpi.h>
#include <cmath>
#include <cstdlib>

int main(int argc, char *argv[]) {
    MPI_Init(&argc, &argv);

    int procid, num_procs;
    MPI_Comm_rank(MPI_COMM_WORLD, &procid);
    MPI_Comm_size(MPI_COMM_WORLD, &num_procs);

    int N = atoi(argv[1]);
    int seg_numbers[N];

    MPI_Status status;
    MPI_Status stats[num_procs + 1];
    MPI_Request reqs[num_procs + 1];

    int part_len = N / num_procs;
    int resid = N % num_procs;

    double t1;
    if (procid == 0) {
        t1 = MPI_Wtime();
        for (int i = 0; i < N; i++) {
            seg_numbers[i] = i;
        }
        for (int  i = 0; i < num_procs - 1; i++) {
            MPI_Isend(&seg_numbers[i * part_len], part_len, MPI_INT, i, 0, MPI_COMM_WORLD, &reqs[i]);
        }
        MPI_Isend(&seg_numbers[(num_procs - 1) * part_len], part_len + resid, MPI_INT, num_procs - 1, 0, MPI_COMM_WORLD, &reqs[num_procs - 1]);
    }

    int seg_amount;
    MPI_Probe(0, 0, MPI_COMM_WORLD, &status);
    MPI_Get_count(&status, MPI_INT, &seg_amount);
    int* cur_numbers = new int[seg_amount];
    MPI_Recv(&cur_numbers[0], seg_amount, MPI_INT, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);

    double sum = (4.0 / (1 + pow(cur_numbers[0] / double(N), 2)) + 4.0 / (1 + pow((cur_numbers[seg_amount - 1] + 1) / double(N), 2))) / (2 * N);
    for (int i = 1; i < seg_amount; i++) {
        sum += (4.0 / (1 + pow(cur_numbers[i] / double(N), 2))) / N;
    }
    MPI_Isend(&sum, 1, MPI_DOUBLE, 0, procid, MPI_COMM_WORLD, &reqs[num_procs]);

    if (procid == 0) {
        MPI_Waitall(num_procs + 1, reqs, stats);
        double current_sum = 0;
        double recv_val;
        for (int i = 0; i < num_procs; i++) {
            MPI_Recv(&recv_val, 1, MPI_DOUBLE, MPI_ANY_SOURCE, MPI_ANY_TAG, MPI_COMM_WORLD, &status);
            std::cout << recv_val << " is calculated by process " << status.MPI_SOURCE << std::endl;
            current_sum += recv_val;
        }

        double t2 = MPI_Wtime();

        std::cout << "Many processes calculated " << current_sum << ". Absolute error is " << std::fabs(current_sum - M_PI) << ". Calculation took " << t2 - t1 << " seconds." << std::endl;

        double t3 = MPI_Wtime();

        double sum = 3.0 / N;
        for (int i = 1; i < N; i++) {
            sum += (4.0 / (1 + pow(i / double(N), 2))) / N;
        }

        double t4 = MPI_Wtime();
        std::cout << "One process calculated " << sum << ". Absolute error is " << std::fabs(sum - M_PI) << ". Calculation took " << t4 - t3 << " seconds." << std::endl;
    }

    MPI_Finalize();
    return 0;
}


