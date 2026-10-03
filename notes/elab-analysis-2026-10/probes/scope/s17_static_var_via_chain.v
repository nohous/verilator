package p; class C #(int W = 2); static int cnt = W; endclass endpackage
module t; initial if (p::C#(5)::cnt != 5) $stop; endmodule
