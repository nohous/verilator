class Deep #(type I0 = byte); typedef I0 out_t; endclass
module t; typedef Deep#()::out_t alias_t; alias_t x; initial if ($bits(x) != 8) $stop; endmodule
