class Channel #(type T = int); T val; endclass
class Tapped #(type T, type BaseT = Channel#(T)); BaseT b; endclass
module t; Tapped#(int) tp; initial begin tp = new; tp.b = new; tp.b.val = 5; if (tp.b.val != 5) $stop; end endmodule
