class IW #(type T = int); typedef T same_t; endclass
class Deep #(
    type I0 = byte,
    type I1 = IW#(I0)::same_t,
    type I2 = IW#(I1)::same_t,
    type I3 = IW#(I2)::same_t,
    type I4 = IW#(I3)::same_t,
    type I5 = IW#(I4)::same_t,
    type I6 = IW#(I5)::same_t,
    type I7 = IW#(I6)::same_t,
    type I8 = IW#(I7)::same_t,
    type I9 = IW#(I8)::same_t,
    type I10 = IW#(I9)::same_t,
    type I11 = IW#(I10)::same_t,
    type I12 = IW#(I11)::same_t,
    type I13 = IW#(I12)::same_t,
    type I14 = IW#(I13)::same_t,
    type I15 = IW#(I14)::same_t,
    type I16 = IW#(I15)::same_t
);
  typedef I16 out_t;
endclass
module t; Deep#()::out_t x; initial if ($bits(x) != 8) $stop; endmodule
