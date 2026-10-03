package p; class C #(int W = 2); typedef logic [W-1:0] T; endclass endpackage
module t; typedef p::C#(5) A; A::T x; initial if ($bits(x) != 5) $stop; endmodule
