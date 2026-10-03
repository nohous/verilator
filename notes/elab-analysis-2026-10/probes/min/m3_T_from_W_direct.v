class E #(int W = 2); typedef logic [W-1:0] value_t; endclass
module M #(int W = 3, type T = E#(W)::value_t) (output T value);
  assign value = '1;
endmodule
module t; logic [2:0] value; M #(.W(3)) dut (.*); endmodule
