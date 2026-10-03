package p; class O #(int W = 2); typedef logic [W-1:0] T; endclass endpackage
class C #(type T = int); typedef T U; endclass
module t; C#(p::O#(5)::T)::U x; initial if ($bits(x) != 5) $stop; endmodule
