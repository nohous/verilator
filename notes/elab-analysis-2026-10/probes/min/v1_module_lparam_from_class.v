class V #(int A = 1); localparam int M = A * 2; endclass
module t; localparam int C = V#(3)::M; initial if (C != 6) $stop; endmodule
