module M #(int W = 3, int D = W + 2, type T = logic [D-1:0], type U = T, int N = $bits(U) + 4) (output U value);
  assign value = U'(N);
endmodule
module t; logic [6:0] value; M #(.W(5)) dut (.*); endmodule
