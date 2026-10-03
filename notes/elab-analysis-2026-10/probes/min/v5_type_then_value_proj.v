class V #(int A = 1); typedef logic [A-1:0] t; localparam int M = $bits(t); endclass
class W #(int A = 3, type T = V#(A)::t, int B = V#(A)::M); T x; localparam int K = B; endclass
module t; localparam int C = W#(.A(4))::K; initial if (C != 4) $stop; endmodule
