class O #(int W = 2); class I; typedef logic [3:0] T; endclass endclass
module t; O#(5)::I::T x; initial if ($bits(x) != 4) $stop; endmodule
