class Channel #(int N = 1); logic [N-1:0] val; endclass
class Tapped #(int N, type BaseT = Channel#(N)); BaseT b; endclass
module t; Tapped#(.N(4)) tp; initial begin tp = new; tp.b = new; if ($bits(tp.b.val) != 4) $stop; end endmodule
