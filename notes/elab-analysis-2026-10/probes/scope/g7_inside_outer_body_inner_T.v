class O #(int W = 2); class I; typedef logic [W-1:0] T; endclass I::T member; endclass
module t; O#(5) o; initial begin o = new; if ($bits(o.member) != 5) $stop; end endmodule
