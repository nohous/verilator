class E #(int W = 2); typedef logic [W-1:0] value_t; endclass
module M #(int W = 3, int D = W + 2, type T = E#(D)::value_t, type U = T) (output U value);
  assign value = '1;
endmodule
module t; logic [6:0] value; M #(.W(5)) dut (.*); endmodule
