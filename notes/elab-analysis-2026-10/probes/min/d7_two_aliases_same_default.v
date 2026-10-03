class IW #(type T = int); typedef T same_t; endclass
class Deep #(type I0 = byte, type I1 = IW#(I0)::same_t); typedef I1 out_t; endclass
module t; typedef Deep#()::out_t alias_t; alias_t x; typedef Deep#()::out_t alias2_t; alias2_t y; initial if ($bits(x) + $bits(y) != 16) $stop; endmodule
