class Tapped #(type T, type U = T); U b; endclass
module t; Tapped#(int) tp; initial begin tp = new; end endmodule
