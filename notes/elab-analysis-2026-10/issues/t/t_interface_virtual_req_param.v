// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Petr Nohavica
// SPDX-License-Identifier: CC0-1.0

interface required_if #(
    type T,
    int W
);
  T data;
endinterface

module t;
  class Cls #(type T = int);
  endclass

  typedef Cls#(virtual required_if#(logic [6:0], 7)) cls_t;

  initial begin
    cls_t e;
    e = new;
    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
