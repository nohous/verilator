class AW #(type T = int); typedef struct packed { T a; T b; } pair_t; endclass
class Deep #(type T0 = byte, type T1 = AW#(T0)::pair_t, type T2 = AW#(T1)::pair_t); typedef T2 out_t; endclass
module t; typedef Deep#()::out_t r_t; r_t x; initial if ($bits(x) != 32) $stop; endmodule
