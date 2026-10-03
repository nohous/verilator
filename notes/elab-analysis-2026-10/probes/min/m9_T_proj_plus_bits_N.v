class E #(int W = 2); typedef logic [W-1:0] value_t; endclass
module M #(int W = 3, int D = W + 2, type T = E#(D)::value_t, int N = $bits(T) + 4) (output T value);
  assign value = T'(N);
endmodule
module t; logic [6:0] value; M #(.W(5)) dut (.*); endmodule
