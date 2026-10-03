class V #(int A = 1); localparam int M = A * 2; endclass
module M #(int N = V#(3)::M) (); initial if (N != 6) $stop; endmodule
module t; M m(); endmodule
