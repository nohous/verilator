class Chain #(type E = logic [7:0], type M = E [2:1]); M val; endclass
module t; Chain#() c; initial begin c = new; if ($bits(c.val) != 16) $stop; end endmodule
