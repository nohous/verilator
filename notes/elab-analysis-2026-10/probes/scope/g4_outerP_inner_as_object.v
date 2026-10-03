class O #(int W = 2); class I; logic [W-1:0] v; endclass endclass
module t; O#(5)::I obj; initial begin obj = new; obj.v = '1; if ($bits(obj.v) != 5) $stop; end endmodule
