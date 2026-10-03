// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Petr Nohavica
// SPDX-License-Identifier: CC0-1.0

package p;
  class Outer;
    class Inner;
      int v = 3;
    endclass
  endclass
endpackage

class Derived extends p::Outer::Inner;
endclass

module t;
  Derived d;
  initial begin
    d = new;
    if (d.v != 3) $stop;
    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
