class O; class I #(int W = 2); typedef logic [W-1:0] T; endclass endclass
module t; O::I#(5)::T x; initial if ($bits(x) != 5) $stop; endmodule
