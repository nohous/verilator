package p; class C #(int W = 2); typedef struct packed { logic [W-1:0] a; } s_t; endclass endpackage
module t; typedef p::C#(5)::s_t S; S s; initial begin s.a = '1; if ($bits(s.a) != 5) $stop; end endmodule
