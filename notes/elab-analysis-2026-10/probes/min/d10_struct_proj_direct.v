class AW #(type T = int); typedef struct packed { T a; T b; } pair_t; endclass
module t; typedef AW#(byte)::pair_t r_t; r_t x; initial if ($bits(x) != 16) $stop; endmodule
