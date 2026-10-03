package p; class A; class B; class C; typedef logic [3:0] T; localparam int M = 9; endclass endclass endclass endpackage
module t; p::A::B::C::T x; initial if ($bits(x) != 4 || p::A::B::C::M != 9) $stop; endmodule
