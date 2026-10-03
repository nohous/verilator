class Chain #(type E = logic [7:0], type M = E [2:1], type L = M [4:2]); typedef L out_t; endclass
module t; Chain#()::out_t x; initial if ($bits(x) != 48) $stop; endmodule
