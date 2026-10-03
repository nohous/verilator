class Channel #(type T = int); T val; endclass
class Tapped #(type T = byte, type BaseT = Channel#(T)) extends BaseT; endclass
module t; Tapped#() tp; initial begin tp = new; if ($bits(tp.val) != 8) $stop; end endmodule
