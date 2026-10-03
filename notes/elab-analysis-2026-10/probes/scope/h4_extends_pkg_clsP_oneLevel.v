package p; class B #(int W = 2); logic [W-1:0] v; endclass endpackage
class D extends p::B#(5); endclass
module t; D d; initial begin d = new; if ($bits(d.v) != 5) $stop; end endmodule
