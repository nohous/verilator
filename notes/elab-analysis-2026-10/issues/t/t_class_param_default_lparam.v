// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Petr Nohavica
// SPDX-License-Identifier: CC0-1.0

class V #(int A = 1);
  localparam int M = A * 2;
endclass

class W #(int B = V#(3)::M);
  localparam int K = B;
endclass

module t;
  localparam int C = W#()::K;
  initial begin
    if (C != 6) $stop;
    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
