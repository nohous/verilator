package p; class O #(int W = 2); class I; typedef logic [W-1:0] T; endclass endclass endpackage
module t; p::O#(5)::I::T x; initial if ($bits(x) != 5) $stop; endmodule
