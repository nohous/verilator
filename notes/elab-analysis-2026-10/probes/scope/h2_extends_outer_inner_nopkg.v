class O; class I; int v = 3; endclass endclass
class D extends O::I; endclass
module t; D d; initial begin d = new; if (d.v != 3) $stop; end endmodule
