class IW #(type T = int); typedef T same_t; endclass
class AW #(type T = int); typedef struct packed { T a; T b; } pair_t; endclass
class DeepI #(type I0 = byte, type I1 = IW#(I0)::same_t); typedef I1 out_t; endclass
class DeepP #(type T0 = byte, type T1 = AW#(T0)::pair_t); typedef T1 out_t; endclass
module t; typedef DeepP#()::out_t p_t; p_t p; typedef DeepI#()::out_t i_t; i_t i; initial if ($bits(p) + $bits(i) != 24) $stop; endmodule
