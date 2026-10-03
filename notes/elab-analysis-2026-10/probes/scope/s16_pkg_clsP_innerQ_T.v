package p; class O #(int W = 2); class I #(int D = 1); typedef logic [W+D-1:0] T; endclass endclass endpackage
module t; p::O#(5)::I#(2)::T x; initial if ($bits(x) != 7) $stop; endmodule
