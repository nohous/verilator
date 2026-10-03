package p; class C; typedef enum logic [1:0] {A=1, B=2} e_t; endclass endpackage
module t; p::C::e_t e; initial begin e = p::C::B; if (e != 2) $stop; end endmodule
