package p; class C #(int W = 2); typedef logic [W-1:0] T; endclass endpackage
module t; p::C#(5)::T x; initial if ($bits(x) != 5) $stop; endmodule
