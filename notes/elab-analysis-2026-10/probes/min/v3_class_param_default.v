class V #(int A = 1); localparam int M = A * 2; endclass
class W #(int B = V#(3)::M); localparam int K = B; endclass
module t; localparam int C = W#()::K; initial if (C != 6) $stop; endmodule
