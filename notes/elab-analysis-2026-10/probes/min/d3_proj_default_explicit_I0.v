class IW #(type T = int); typedef T same_t; endclass
class Deep #(type I0 = byte, type I1 = IW#(I0)::same_t); typedef I1 out_t; endclass
module t; Deep#(.I0(shortint))::out_t x; initial if ($bits(x) != 16) $stop; endmodule
