interface Bus #(parameter int W = 3, parameter int D = W + 2); logic [D-1:0] data; endinterface
module t;
  Bus #(.W(5)) intf ();
  virtual Bus #(.W(5), .D(7)) v = intf;
  initial begin intf.data = 7'h55; if (v.data != 7'h55) $stop; $finish; end
endmodule
