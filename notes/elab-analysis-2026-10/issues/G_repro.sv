// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Petr Nohavica
// SPDX-License-Identifier: CC0-1.0

class Outer #(int W = 2);
  class Inner;
    typedef logic [W-1:0] T;
    localparam int M = W * 3;
  endclass
endclass

module t;
  Outer#(5)::Inner::T x;
  initial begin
    if ($bits(x) != 5) $stop;
    if (Outer#(5)::Inner::M != 15) $stop;
    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
