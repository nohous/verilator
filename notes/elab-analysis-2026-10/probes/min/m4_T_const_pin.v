class E #(int W = 2); typedef logic [W-1:0] value_t; endclass
module M #(type T = E#(5)::value_t) (output T value);
  assign value = '1;
endmodule
module t; logic [4:0] value; M dut (.*); endmodule
