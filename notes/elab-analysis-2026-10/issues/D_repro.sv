// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Petr Nohavica
// SPDX-License-Identifier: CC0-1.0

class NestedValue #(int A = NestedValue#()::M);
  localparam int M = A;
endclass

module t;
  localparam int C = NestedValue#()::M;
endmodule
