package p; class C; typedef logic [3:0] T; endclass endpackage
module t; p::C::T x; initial if ($bits(x) != 4) $stop; endmodule
