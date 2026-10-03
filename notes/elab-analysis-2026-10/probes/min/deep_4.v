class IW #(type T = int); typedef T same_t; endclass
class Deep #(
    type I0 = byte,
    type I1 = IW#(I0)::same_t,
    type I2 = IW#(I1)::same_t,
    type I3 = IW#(I2)::same_t,
    type I4 = IW#(I3)::same_t
);
  typedef I4 out_t;
endclass
module t; Deep#()::out_t x; initial if ($bits(x) != 8) $stop; endmodule
