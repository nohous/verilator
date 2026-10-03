// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Petr Nohavica
// SPDX-License-Identifier: CC0-1.0

interface Bus #(
    parameter int W = 3,
    parameter int D = W + 2
);
  logic [D-1:0] data;
endinterface

module t;
  Bus #(.W(5)) intf ();
  virtual Bus #(.W(5), .D(7)) v = intf;
  initial begin
    intf.data = 7'h55;
    if (v.data != 7'h55) $stop;
    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
