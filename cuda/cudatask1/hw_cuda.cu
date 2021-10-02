#include <iostream>
#include <time.h>

#define BLOCK_SIZE 4

void FillMatrix(float* matrix, int height, int width) {
        srand(time(NULL));
        for (int i = 0; i < height; ++i) {
                for (int j = 0; j < width; ++j) {
                        matrix[i * width + j] = rand() % 2;
                }
        }
}

void Transpose(float *matrix, int height, int width) {
        float transposed[height * width];
        for (int i = 0; i < width; ++i) {
                for (int j = 0; j < height; ++j) {
                        transposed[i * height + j] = matrix[j * width + i];
                }
        }
        for (int i = 0; i < width * height; ++i) {
                matrix[i] = transposed[i];
        }
}

bool AreEqual(float* lhs_matrix, float* rhs_matrix, int height, int width) {
        for (int i = 0; i < height; ++i) {
                for (int j = 0; j < width; ++j) {
                        if (lhs_matrix[i * width + j] != rhs_matrix[i * width + j]) {
                                return false;
                        }
                }
        }
        return true;
}

__global__
void NaiveMatrixMul(float* A, float* B, float* C, int mid_size) {
        int i = blockIdx.x * blockDim.x + threadIdx.x;
        int j = blockIdx.y * blockDim.y + threadIdx.y;
 
        int width = blockDim.y * gridDim.y;

        C[i * width + j] = .0f;

        for (int k = 0; k < mid_size; ++k) {
                C[i * width + j] += A[i * mid_size + k] * B[k * width + j];
        }
}

__global__
void MatrixMul(float* A, float* B, float* C, int mid_size) {
        int width = blockDim.y * gridDim.y;

        int local_trow = threadIdx.x;
        int local_tcol = threadIdx.y;

        int block_row = blockIdx.x;
        int block_col = blockIdx.y;

        float tres = .0f;

        for (int k = 0; k < (mid_size / BLOCK_SIZE); ++k) {
                __shared__ float A_block[BLOCK_SIZE][BLOCK_SIZE];
                __shared__ float B_block[BLOCK_SIZE][BLOCK_SIZE];
                int A_block_idx = block_row * mid_size * BLOCK_SIZE + k * BLOCK_SIZE;
                int B_block_idx = block_col * mid_size * BLOCK_SIZE + k * BLOCK_SIZE;

                A_block[local_trow][local_tcol] = A[A_block_idx + local_trow * mid_size + local_tcol];
                B_block[local_tcol][local_trow] = B[B_block_idx + local_tcol * mid_size + local_trow];

                __syncthreads();

                for (int i = 0; i < BLOCK_SIZE; ++i) {
                        tres += A_block[local_trow][i] * B_block[local_tcol][i];
                }
                __syncthreads();
        }
        C[block_row * BLOCK_SIZE * width + local_trow * width + block_col * BLOCK_SIZE + local_tcol] = tres;
}

int main() {
        float *h_A;
        float *h_B;
        float *h_C;
        float *h_C_naive;

        int A_height, A_width, B_height, B_width;

        std::cin >> A_height >> A_width >> B_height >> B_width;

        h_A = new float[A_height * A_width];
        h_B = new float[B_height * B_width];
        h_C = new float[A_height * B_width];
        h_C_naive = new float[A_height * B_width];

        FillMatrix(h_A, A_height, A_width);
        FillMatrix(h_B, B_height, B_width);

        float* d_A;
        float* d_B;
        float* d_C;

        cudaMalloc(&d_A, sizeof(float) * A_height * A_width);
        cudaMalloc(&d_B, sizeof(float) * B_height * B_width);
        cudaMalloc(&d_C, sizeof(float) * A_height * B_width);

        cudaMemcpy(d_A, h_A, sizeof(float) * A_height * A_width, cudaMemcpyHostToDevice);
        cudaMemcpy(d_B, h_B, sizeof(float) * B_height * B_width, cudaMemcpyHostToDevice);

        dim3 num_blocks(A_height / BLOCK_SIZE, B_width / BLOCK_SIZE);
        dim3 block_size(BLOCK_SIZE, BLOCK_SIZE);

        cudaEvent_t naive_start;
        cudaEvent_t naive_stop;
        cudaEventCreate(&naive_start);
        cudaEventCreate(&naive_stop);

        cudaEventRecord(naive_start);
        NaiveMatrixMul<<<num_blocks, block_size>>>(d_A, d_B, d_C, A_width);
        cudaEventRecord(naive_stop);
        cudaMemcpy(h_C_naive, d_C, sizeof(float) * A_height * B_width, cudaMemcpyDeviceToHost);
        cudaEventSynchronize(naive_stop);

        float milliseconds = 0;
        cudaEventElapsedTime(&milliseconds, naive_start, naive_stop);
        std::cout << "Duration of naive method:" << milliseconds << "\n";

        cudaEvent_t start;
        cudaEvent_t stop;
        cudaEventCreate(&start);
        cudaEventCreate(&stop);

        Transpose(h_B, B_height, B_width);
        cudaMemcpy(d_B, h_B, sizeof(float) * B_height * B_width, cudaMemcpyHostToDevice);
        cudaEventRecord(start);
        MatrixMul<<<num_blocks, block_size>>>(d_A, d_B, d_C, A_width);
        cudaEventRecord(stop);
        cudaMemcpy(h_C, d_C, sizeof(float) * A_height * B_width, cudaMemcpyDeviceToHost);
        cudaEventSynchronize(stop);

        milliseconds = 0;
        cudaEventElapsedTime(&milliseconds, start, stop);
        std::cout << "Duration of not naive method:" << milliseconds << "\n";

        if (AreEqual(h_C, h_C_naive, A_height, B_width)) {
                std::cout << "Matrices are equal\n";
        } else {
                std::cout << "Matrices are not equal\n";
        }

        cudaFree(d_A);
        cudaFree(d_B);
        cudaFree(d_C);

        delete[] h_A;
        delete[] h_B;
        delete[] h_C;
        delete[] h_C_naive;

        return 0;
}
