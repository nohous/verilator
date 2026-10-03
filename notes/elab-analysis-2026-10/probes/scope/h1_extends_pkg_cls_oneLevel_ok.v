package p; class B; int v = 3; endclass endpackage
class D extends p::B; endclass
module t; D d; initial begin d = new; if (d.v != 3) $stop; end endmodule
