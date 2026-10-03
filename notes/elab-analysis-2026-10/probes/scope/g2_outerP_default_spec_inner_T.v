class O #(int W = 2); class I; typedef logic [W-1:0] T; endclass endclass
module t; O#()::I::T x; initial if ($bits(x) != 2) $stop; endmodule
