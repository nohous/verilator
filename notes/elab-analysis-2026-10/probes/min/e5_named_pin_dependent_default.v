class Channel #(type T = int); T val; endclass
class Tapped #(type T, type BaseT = Channel#(T)); BaseT b; endclass
module t; Tapped#(.T(int)) tp; initial begin tp = new; tp.b = new; end endmodule
