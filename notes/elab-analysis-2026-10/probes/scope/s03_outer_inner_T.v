class O; class I; typedef logic [3:0] T; endclass endclass
module t; O::I::T x; initial if ($bits(x) != 4) $stop; endmodule
