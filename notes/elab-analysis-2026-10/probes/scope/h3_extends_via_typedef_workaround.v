package p; class O; class I; int v = 3; endclass endclass endpackage
typedef p::O::I Base;
class D extends Base; endclass
module t; D d; initial begin d = new; if (d.v != 3) $stop; end endmodule
