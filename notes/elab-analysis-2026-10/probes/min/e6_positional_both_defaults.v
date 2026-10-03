class Channel #(type T = int); T val; endclass
class Tapped #(type T = byte, type BaseT = Channel#(T)); BaseT b; endclass
module t; Tapped#(int) tp; initial begin tp = new; tp.b = new; end endmodule
