class Rendezvous; endclass
class Channel #(type T = int) extends Rendezvous; T val; endclass
class Tapped #(type T, type BaseT = Channel#(T)) extends BaseT; endclass
module t; Tapped#(int) tp; initial begin tp = new; tp.val = 5; if (tp.val != 5) $stop; end endmodule
