class V #(int A = 1); localparam int M = A * 2; endclass
class W #(int A = 3, int B = V#(A)::M); localparam int K = B; endclass
module t; localparam int C = W#(.A(4))::K; initial if (C != 8) $stop; endmodule
