class Chain #(type E = logic [7:0], type M = E [2:1]); typedef M out_t; endclass
module t; Chain#()::out_t x; initial if ($bits(x) != 16) $stop; endmodule
