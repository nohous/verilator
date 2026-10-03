// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Petr Nohavica
// SPDX-License-Identifier: CC0-1.0

class Channel #(type T = int);
  T val;
endclass

class Tapped #(type T, type BaseT = Channel#(T));
  BaseT b;
endclass

module t;
  Tapped#(.T(int)) tp;
  initial begin
    tp = new;
    tp.b = new;
    tp.b.val = 5;
    if (tp.b.val != 5) $stop;
    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
