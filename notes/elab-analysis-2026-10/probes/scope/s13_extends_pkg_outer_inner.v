package p; class O; class I; int v = 3; endclass endclass endpackage
class D extends p::O::I; endclass
module t; D d; initial begin d = new; if (d.v != 3) $stop; end endmodule
