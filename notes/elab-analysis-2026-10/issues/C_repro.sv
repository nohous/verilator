// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Petr Nohavica
// SPDX-License-Identifier: CC0-1.0

class E #(int W = 2);
  typedef logic [W-1:0] value_t;
endclass

module M #(
    int W = 3,
    int D = W + 2,
    type T = E#(D)::value_t,
    int N = $bits(T) + 4
) (
    output T value
);
  assign value = T'(N);
endmodule

module t;
  logic [6:0] value;
  M #(.W(5)) dut (.*);
  initial begin
    if ($bits(value) != 7) $stop;
    if (dut.N != 11) $stop;
    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
